`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v1_9_ddr_phy_prbs_rdlvl #
  (
   parameter TCQ             = 100,    
   parameter nCK_PER_CLK     = 2,      
   parameter DQ_WIDTH        = 64,     
   parameter DQS_CNT_WIDTH   = 3,      
   parameter DQS_WIDTH       = 8,      
   parameter DRAM_WIDTH      = 8,      
   parameter RANKS           = 1,      
   parameter SIM_CAL_OPTION  = "NONE", 
   parameter PRBS_WIDTH      = 8       
   )
  (
   input                        clk,
   input                        rst,
   input                        prbs_rdlvl_start,
   output reg                   prbs_rdlvl_done,
   output reg                   prbs_last_byte_done,
   output reg                   prbs_rdlvl_prech_req,
   input                        prech_done,
   input                        phy_if_empty,
   input [2*nCK_PER_CLK*DQ_WIDTH-1:0] rd_data,
   input [2*nCK_PER_CLK*PRBS_WIDTH-1:0] compare_data,
   input [5:0]                  pi_counter_read_val,
   output reg                   pi_en_stg2_f,
   output reg                   pi_stg2_f_incdec,
   output [255:0]               dbg_prbs_rdlvl,
   output [DQS_CNT_WIDTH:0]     pi_stg2_prbs_rdlvl_cnt   
   );
  localparam [5:0] PRBS_IDLE                 = 6'h00;
  localparam [5:0] PRBS_NEW_DQS_WAIT         = 6'h01;
  localparam [5:0] PRBS_PAT_COMPARE          = 6'h02;
  localparam [5:0] PRBS_DEC_DQS              = 6'h03;
  localparam [5:0] PRBS_DEC_DQS_WAIT         = 6'h04;
  localparam [5:0] PRBS_INC_DQS              = 6'h05;
  localparam [5:0] PRBS_INC_DQS_WAIT         = 6'h06;
  localparam [5:0] PRBS_CALC_TAPS            = 6'h07;
  localparam [5:0] PRBS_TAP_CHECK            = 6'h08;
  localparam [5:0] PRBS_NEXT_DQS             = 6'h09;
  localparam [5:0] PRBS_NEW_DQS_PREWAIT      = 6'h0A;
  localparam [5:0] PRBS_DONE                 = 6'h0B;
  localparam [11:0] NUM_SAMPLES_CNT  = (SIM_CAL_OPTION == "NONE") ? 12'hFFF : 12'h001; 
  localparam [11:0] NUM_SAMPLES_CNT1 = (SIM_CAL_OPTION == "NONE") ? 12'hFFF : 12'h001;
  localparam [11:0] NUM_SAMPLES_CNT2 = (SIM_CAL_OPTION == "NONE") ? 12'hFFF : 12'h001;
  wire [DQS_CNT_WIDTH+2:0]prbs_dqs_cnt_timing;
  reg [DQS_CNT_WIDTH+2:0] prbs_dqs_cnt_timing_r;
  reg [DQS_CNT_WIDTH:0]   prbs_dqs_cnt_r;
  reg                     prbs_prech_req_r;
  reg [5:0]               prbs_state_r;
  reg [5:0]               prbs_state_r1;
  reg                     wait_state_cnt_en_r;
  reg [3:0]               wait_state_cnt_r;
  reg                     cnt_wait_state;
  reg                     found_edge_r;
  reg                     prbs_found_1st_edge_r;
  reg                     prbs_found_2nd_edge_r;
  reg [5:0]               prbs_1st_edge_taps_r;
  reg                     found_stable_eye_r;
  reg [5:0]               prbs_dqs_tap_cnt_r;
  reg [5:0]               prbs_dec_tap_calc_plus_3;
  reg [5:0]               prbs_dec_tap_calc_minus_3;
  reg                     prbs_dqs_tap_limit_r;
  reg [5:0]               prbs_inc_tap_cnt;
  reg [5:0]               prbs_dec_tap_cnt;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall0_r1;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall1_r1;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise0_r1;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise1_r1;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall2_r1;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall3_r1;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise2_r1;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise3_r1;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall0_r2;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall1_r2;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise0_r2;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise1_r2;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall2_r2;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall3_r2;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise2_r2;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise3_r2;
  reg                     mux_rd_valid_r;
  reg                     rd_valid_r1;
  reg                     rd_valid_r2;
  reg                     rd_valid_r3;
  reg                     new_cnt_dqs_r;
  reg                     prbs_tap_en_r;
  reg                     prbs_tap_inc_r;
  reg                     pi_en_stg2_f_timing;
  reg                     pi_stg2_f_incdec_timing;
  wire [DQ_WIDTH-1:0]     rd_data_rise0;
  wire [DQ_WIDTH-1:0]     rd_data_fall0;
  wire [DQ_WIDTH-1:0]     rd_data_rise1;
  wire [DQ_WIDTH-1:0]     rd_data_fall1;
  wire [DQ_WIDTH-1:0]     rd_data_rise2;
  wire [DQ_WIDTH-1:0]     rd_data_fall2;
  wire [DQ_WIDTH-1:0]     rd_data_rise3;
  wire [DQ_WIDTH-1:0]     rd_data_fall3;
  wire [PRBS_WIDTH-1:0]   compare_data_r0;
  wire [PRBS_WIDTH-1:0]   compare_data_f0;
  wire [PRBS_WIDTH-1:0]   compare_data_r1;
  wire [PRBS_WIDTH-1:0]   compare_data_f1;
  wire [PRBS_WIDTH-1:0]   compare_data_r2;
  wire [PRBS_WIDTH-1:0]   compare_data_f2;
  wire [PRBS_WIDTH-1:0]   compare_data_r3;
  wire [PRBS_WIDTH-1:0]   compare_data_f3;
  reg [DQS_CNT_WIDTH:0]   rd_mux_sel_r;
  reg [5:0]               prbs_2nd_edge_taps_r;
  reg [6*DQS_WIDTH*RANKS-1:0] prbs_final_dqs_tap_cnt_r;
  reg [1:0]               rnk_cnt_r;
  reg [5:0]               rdlvl_cpt_tap_cnt;
  reg                     prbs_rdlvl_start_r;
  reg                     compare_err;
  reg                     compare_err_r0;
  reg                     compare_err_f0;
  reg                     compare_err_r1;
  reg                     compare_err_f1;
  reg                     compare_err_r2;
  reg                     compare_err_f2;
  reg                     compare_err_r3;
  reg                     compare_err_f3;
  reg                     samples_cnt1_en_r;
  reg                     samples_cnt2_en_r;
  reg [11:0]              samples_cnt_r;
  reg                     num_samples_done_r;
  reg [DQS_WIDTH-1:0]     prbs_tap_mod;
   assign dbg_prbs_rdlvl[0+:8]  = compare_data_r0;
   assign dbg_prbs_rdlvl[8+:8]  = compare_data_f0;
   assign dbg_prbs_rdlvl[16+:8] = compare_data_r1;
   assign dbg_prbs_rdlvl[24+:8] = compare_data_f1;
   assign dbg_prbs_rdlvl[32+:8] = compare_data_r2;
   assign dbg_prbs_rdlvl[40+:8] = compare_data_f2;
   assign dbg_prbs_rdlvl[48+:8] = compare_data_r3;
   assign dbg_prbs_rdlvl[56+:8] = compare_data_f3;
   assign dbg_prbs_rdlvl[64+:8]  = mux_rd_rise0_r2;
   assign dbg_prbs_rdlvl[72+:8]  = mux_rd_fall0_r2;
   assign dbg_prbs_rdlvl[80+:8]  = mux_rd_rise1_r2;
   assign dbg_prbs_rdlvl[88+:8]  = mux_rd_fall1_r2;
   assign dbg_prbs_rdlvl[96+:8]  = mux_rd_rise2_r2;
   assign dbg_prbs_rdlvl[104+:8] = mux_rd_fall2_r2;
   assign dbg_prbs_rdlvl[112+:8] = mux_rd_rise3_r2;
   assign dbg_prbs_rdlvl[120+:8] = mux_rd_fall3_r2;
   assign dbg_prbs_rdlvl[128+:6] = pi_counter_read_val;
   assign dbg_prbs_rdlvl[134+:6] = prbs_dqs_tap_cnt_r;
   assign dbg_prbs_rdlvl[140]    = prbs_found_1st_edge_r;
   assign dbg_prbs_rdlvl[141]    = prbs_found_2nd_edge_r;
   assign dbg_prbs_rdlvl[142]    = compare_err;
   assign dbg_prbs_rdlvl[143]    = phy_if_empty;
   assign dbg_prbs_rdlvl[144]    = prbs_rdlvl_start;
   assign dbg_prbs_rdlvl[145]    = prbs_rdlvl_done;
   assign dbg_prbs_rdlvl[146+:5] = prbs_dqs_cnt_r;
   assign dbg_prbs_rdlvl[151+:6] = rdlvl_cpt_tap_cnt;
   assign dbg_prbs_rdlvl[157+:6] = prbs_1st_edge_taps_r;
   assign dbg_prbs_rdlvl[163+:6] = prbs_2nd_edge_taps_r;
   assign dbg_prbs_rdlvl[169+:9] = prbs_tap_mod;
   assign dbg_prbs_rdlvl[255:178]= 'b0;
  generate
    if (nCK_PER_CLK == 4) begin: rd_data_div4_logic_clk
      assign rd_data_rise0 = rd_data[DQ_WIDTH-1:0];
      assign rd_data_fall0 = rd_data[2*DQ_WIDTH-1:DQ_WIDTH];
      assign rd_data_rise1 = rd_data[3*DQ_WIDTH-1:2*DQ_WIDTH];
      assign rd_data_fall1 = rd_data[4*DQ_WIDTH-1:3*DQ_WIDTH];
      assign rd_data_rise2 = rd_data[5*DQ_WIDTH-1:4*DQ_WIDTH];
      assign rd_data_fall2 = rd_data[6*DQ_WIDTH-1:5*DQ_WIDTH];
      assign rd_data_rise3 = rd_data[7*DQ_WIDTH-1:6*DQ_WIDTH];
      assign rd_data_fall3 = rd_data[8*DQ_WIDTH-1:7*DQ_WIDTH];
      assign compare_data_r0 = compare_data[PRBS_WIDTH-1:0];
      assign compare_data_f0 = compare_data[2*PRBS_WIDTH-1:PRBS_WIDTH];
      assign compare_data_r1 = compare_data[3*PRBS_WIDTH-1:2*PRBS_WIDTH];
      assign compare_data_f1 = compare_data[4*PRBS_WIDTH-1:3*PRBS_WIDTH];
      assign compare_data_r2 = compare_data[5*PRBS_WIDTH-1:4*PRBS_WIDTH];
      assign compare_data_f2 = compare_data[6*PRBS_WIDTH-1:5*PRBS_WIDTH];
      assign compare_data_r3 = compare_data[7*PRBS_WIDTH-1:6*PRBS_WIDTH];
      assign compare_data_f3 = compare_data[8*PRBS_WIDTH-1:7*PRBS_WIDTH];
    end else begin: rd_data_div2_logic_clk
      assign rd_data_rise0 = rd_data[DQ_WIDTH-1:0];
      assign rd_data_fall0 = rd_data[2*DQ_WIDTH-1:DQ_WIDTH];
      assign rd_data_rise1 = rd_data[3*DQ_WIDTH-1:2*DQ_WIDTH];
      assign rd_data_fall1 = rd_data[4*DQ_WIDTH-1:3*DQ_WIDTH];
      assign compare_data_r0 = compare_data[PRBS_WIDTH-1:0];
      assign compare_data_f0 = compare_data[2*PRBS_WIDTH-1:PRBS_WIDTH];
      assign compare_data_r1 = compare_data[3*PRBS_WIDTH-1:2*PRBS_WIDTH];
      assign compare_data_f1 = compare_data[4*PRBS_WIDTH-1:3*PRBS_WIDTH];
    end
  endgenerate
  always @(posedge clk) begin
    rd_mux_sel_r <= #TCQ prbs_dqs_cnt_r;
  end
  generate
    genvar mux_i;
    for (mux_i = 0; mux_i < DRAM_WIDTH; mux_i = mux_i + 1) begin: gen_mux_rd
      always @(posedge clk) begin
        mux_rd_rise0_r1[mux_i] <= #TCQ rd_data_rise0[DRAM_WIDTH*rd_mux_sel_r + mux_i];
        mux_rd_fall0_r1[mux_i] <= #TCQ rd_data_fall0[DRAM_WIDTH*rd_mux_sel_r + mux_i];
        mux_rd_rise1_r1[mux_i] <= #TCQ rd_data_rise1[DRAM_WIDTH*rd_mux_sel_r + mux_i];
        mux_rd_fall1_r1[mux_i] <= #TCQ rd_data_fall1[DRAM_WIDTH*rd_mux_sel_r + mux_i];
        mux_rd_rise2_r1[mux_i] <= #TCQ rd_data_rise2[DRAM_WIDTH*rd_mux_sel_r + mux_i];
        mux_rd_fall2_r1[mux_i] <= #TCQ rd_data_fall2[DRAM_WIDTH*rd_mux_sel_r + mux_i];
        mux_rd_rise3_r1[mux_i] <= #TCQ rd_data_rise3[DRAM_WIDTH*rd_mux_sel_r + mux_i];
        mux_rd_fall3_r1[mux_i] <= #TCQ rd_data_fall3[DRAM_WIDTH*rd_mux_sel_r + mux_i];
      end
    end
  endgenerate
  generate
    genvar muxr2_i;
    if (nCK_PER_CLK == 4) begin: gen_mux_div4
        for (muxr2_i = 0; muxr2_i < DRAM_WIDTH; muxr2_i = muxr2_i + 1) begin: gen_rd_4
          always @(posedge clk) begin
            if (mux_rd_valid_r) begin
              mux_rd_rise0_r2[muxr2_i] <= #TCQ mux_rd_rise0_r1[muxr2_i];
              mux_rd_fall0_r2[muxr2_i] <= #TCQ mux_rd_fall0_r1[muxr2_i];
              mux_rd_rise1_r2[muxr2_i] <= #TCQ mux_rd_rise1_r1[muxr2_i];
              mux_rd_fall1_r2[muxr2_i] <= #TCQ mux_rd_fall1_r1[muxr2_i];
              mux_rd_rise2_r2[muxr2_i] <= #TCQ mux_rd_rise2_r1[muxr2_i];
              mux_rd_fall2_r2[muxr2_i] <= #TCQ mux_rd_fall2_r1[muxr2_i];
              mux_rd_rise3_r2[muxr2_i] <= #TCQ mux_rd_rise3_r1[muxr2_i];
              mux_rd_fall3_r2[muxr2_i] <= #TCQ mux_rd_fall3_r1[muxr2_i];
            end
          end
                end
    end else if (nCK_PER_CLK == 2) begin: gen_mux_div2
        for (muxr2_i = 0; muxr2_i < DRAM_WIDTH; muxr2_i = muxr2_i + 1) begin: gen_rd_2
          always @(posedge clk) begin
            if (mux_rd_valid_r) begin
              mux_rd_rise0_r2[muxr2_i] <= #TCQ mux_rd_rise0_r1[muxr2_i];
              mux_rd_fall0_r2[muxr2_i] <= #TCQ mux_rd_fall0_r1[muxr2_i];
              mux_rd_rise1_r2[muxr2_i] <= #TCQ mux_rd_rise1_r1[muxr2_i];
              mux_rd_fall1_r2[muxr2_i] <= #TCQ mux_rd_fall1_r1[muxr2_i];      
            end
                  end
        end
    end
  endgenerate
  always @(posedge clk) begin
    mux_rd_valid_r <= #TCQ ~phy_if_empty && prbs_rdlvl_start;
    rd_valid_r1    <= #TCQ mux_rd_valid_r;
    rd_valid_r2    <= #TCQ rd_valid_r1;
  end
  always @(posedge clk)
    if (rst)
      samples_cnt_r <= #TCQ 'b0;
    else begin
      if (!rd_valid_r1 ||
          (prbs_state_r == PRBS_DEC_DQS_WAIT) ||
          (prbs_state_r == PRBS_INC_DQS_WAIT) ||
          (prbs_state_r == PRBS_DEC_DQS) ||
          (prbs_state_r == PRBS_INC_DQS) ||
          (samples_cnt_r == NUM_SAMPLES_CNT) ||
          (samples_cnt_r == NUM_SAMPLES_CNT1))
        samples_cnt_r <= #TCQ 'b0;
      else if (rd_valid_r1 && 
               (((samples_cnt_r < NUM_SAMPLES_CNT) && ~samples_cnt1_en_r) ||
                ((samples_cnt_r < NUM_SAMPLES_CNT1) && ~samples_cnt2_en_r) ||
                ((samples_cnt_r < NUM_SAMPLES_CNT2) && samples_cnt2_en_r)))
        samples_cnt_r <= #TCQ samples_cnt_r + 1;
    end
  always @(posedge clk)
    if (rst)
      samples_cnt1_en_r <= #TCQ 1'b0;
    else begin 
      if ((prbs_state_r == PRBS_IDLE) || 
          (prbs_state_r == PRBS_DEC_DQS) ||
          (prbs_state_r == PRBS_INC_DQS) ||
          (prbs_state_r == PRBS_NEW_DQS_PREWAIT))
        samples_cnt1_en_r <= #TCQ 1'b0;
      else if ((samples_cnt_r == NUM_SAMPLES_CNT) && rd_valid_r1)
        samples_cnt1_en_r <= #TCQ 1'b1;
    end
  always @(posedge clk)
    if (rst)
      samples_cnt2_en_r <= #TCQ 1'b0;
    else begin 
      if ((prbs_state_r == PRBS_IDLE) || 
          (prbs_state_r == PRBS_DEC_DQS) ||
          (prbs_state_r == PRBS_INC_DQS) ||
          (prbs_state_r == PRBS_NEW_DQS_PREWAIT))
        samples_cnt2_en_r <= #TCQ 1'b0;
      else if ((samples_cnt_r == NUM_SAMPLES_CNT1) && rd_valid_r1 && samples_cnt1_en_r)
        samples_cnt2_en_r <= #TCQ 1'b1;
    end
  always @(posedge clk)
    if (rst)
      num_samples_done_r <= #TCQ 1'b0;
    else begin 
      if (!rd_valid_r1 ||
          (prbs_state_r == PRBS_DEC_DQS) ||
          (prbs_state_r == PRBS_INC_DQS))
        num_samples_done_r <= #TCQ 'b0;
      else begin
        if ((samples_cnt_r == NUM_SAMPLES_CNT2-1) && samples_cnt2_en_r)
          num_samples_done_r <= #TCQ 1'b1;
      end
    end
  generate
    if (nCK_PER_CLK == 4) begin: cmp_err_4to1
      always @ (posedge clk) begin
        if (rst || new_cnt_dqs_r) begin
              compare_err    <= #TCQ 1'b0;
              compare_err_r0 <= #TCQ 1'b0;
              compare_err_f0 <= #TCQ 1'b0;
              compare_err_r1 <= #TCQ 1'b0;
              compare_err_f1 <= #TCQ 1'b0;
              compare_err_r2 <= #TCQ 1'b0;
              compare_err_f2 <= #TCQ 1'b0;
              compare_err_r3 <= #TCQ 1'b0;
              compare_err_f3 <= #TCQ 1'b0;
            end else if (rd_valid_r1) begin
              compare_err_r0  <= #TCQ (mux_rd_rise0_r2 != compare_data_r0);
              compare_err_f0  <= #TCQ (mux_rd_fall0_r2 != compare_data_f0);
              compare_err_r1  <= #TCQ (mux_rd_rise1_r2 != compare_data_r1);
              compare_err_f1  <= #TCQ (mux_rd_fall1_r2 != compare_data_f1);
              compare_err_r2  <= #TCQ (mux_rd_rise2_r2 != compare_data_r2);
              compare_err_f2  <= #TCQ (mux_rd_fall2_r2 != compare_data_f2);
              compare_err_r3  <= #TCQ (mux_rd_rise3_r2 != compare_data_r3);
              compare_err_f3  <= #TCQ (mux_rd_fall3_r2 != compare_data_f3);
              compare_err     <= #TCQ (compare_err_r0 | compare_err_f0 |
                                       compare_err_r1 | compare_err_f1 |
                                                           compare_err_r2 | compare_err_f2 |
                                                           compare_err_r3 | compare_err_f3);
            end
      end
        end else begin: cmp_err_2to1
          always @ (posedge clk) begin
        if (rst || new_cnt_dqs_r) begin
              compare_err    <= #TCQ 1'b0;
              compare_err_r0 <= #TCQ 1'b0;
              compare_err_f0 <= #TCQ 1'b0;
              compare_err_r1 <= #TCQ 1'b0;
              compare_err_f1 <= #TCQ 1'b0;
            end else if (rd_valid_r1) begin
              compare_err_r0  <= #TCQ (mux_rd_rise0_r2 != compare_data_r0);
              compare_err_f0  <= #TCQ (mux_rd_fall0_r2 != compare_data_f0);
              compare_err_r1  <= #TCQ (mux_rd_rise1_r2 != compare_data_r1);
              compare_err_f1  <= #TCQ (mux_rd_fall1_r2 != compare_data_f1);
              compare_err     <= #TCQ (compare_err_r0 | compare_err_f0 |
                                       compare_err_r1 | compare_err_f1);
            end
      end
        end
  endgenerate
  always @(posedge clk) begin
    if (rst) begin
      pi_en_stg2_f_timing     <= #TCQ 'b0;
      pi_stg2_f_incdec_timing <= #TCQ 'b0;
    end else if (prbs_tap_en_r) begin
      pi_en_stg2_f_timing     <= #TCQ 1'b1;  
      pi_stg2_f_incdec_timing <= #TCQ prbs_tap_inc_r;
    end else begin
      pi_en_stg2_f_timing     <= #TCQ 'b0;
      pi_stg2_f_incdec_timing <= #TCQ 'b0;
    end
  end
  always @(posedge clk) begin
    pi_en_stg2_f     <= #TCQ pi_en_stg2_f_timing;
    pi_stg2_f_incdec <= #TCQ pi_stg2_f_incdec_timing;
  end
  always @(posedge clk)
    if (rst)
      prbs_rdlvl_prech_req <= #TCQ 1'b0;
    else
      prbs_rdlvl_prech_req <= #TCQ prbs_prech_req_r;
  always @(posedge clk)
    if (rst) begin
      prbs_dqs_tap_cnt_r   <= #TCQ 'b0;
      rdlvl_cpt_tap_cnt    <= #TCQ 'b0;
    end else if (new_cnt_dqs_r) begin
      prbs_dqs_tap_cnt_r   <= #TCQ pi_counter_read_val;
      rdlvl_cpt_tap_cnt    <= #TCQ pi_counter_read_val;
    end else if (prbs_tap_en_r) begin
      if (prbs_tap_inc_r)
        prbs_dqs_tap_cnt_r <= #TCQ prbs_dqs_tap_cnt_r + 1;
      else if (prbs_dqs_tap_cnt_r != 'd0)
        prbs_dqs_tap_cnt_r <= #TCQ prbs_dqs_tap_cnt_r - 1;
    end
  always @(posedge clk)
    if (rst) begin
      prbs_dec_tap_calc_plus_3  <= #TCQ 'b0;
      prbs_dec_tap_calc_minus_3 <= #TCQ 'b0;
    end else if (new_cnt_dqs_r) begin
      prbs_dec_tap_calc_plus_3  <= #TCQ 'b000011;
      prbs_dec_tap_calc_minus_3 <= #TCQ 'b111100;
    end else begin
      prbs_dec_tap_calc_plus_3  <= #TCQ (prbs_dqs_tap_cnt_r  - rdlvl_cpt_tap_cnt + 3);
      prbs_dec_tap_calc_minus_3 <= #TCQ (prbs_dqs_tap_cnt_r  - rdlvl_cpt_tap_cnt - 3);
    end
  always @(posedge clk)
    if (rst || new_cnt_dqs_r)
      prbs_dqs_tap_limit_r <= #TCQ 1'b0;
    else if (prbs_dqs_tap_cnt_r == 6'd63)
      prbs_dqs_tap_limit_r <= #TCQ 1'b1;
  assign prbs_dqs_cnt_timing = {2'd0, prbs_dqs_cnt_r};
  always @(posedge clk)
    prbs_dqs_cnt_timing_r <= #TCQ prbs_dqs_cnt_timing;
   always @(posedge clk) begin
     if (rst) begin
       prbs_final_dqs_tap_cnt_r <= #TCQ 'b0;
     end else if ((prbs_state_r == PRBS_NEXT_DQS) && (prbs_state_r1 != PRBS_NEXT_DQS)) begin
        prbs_final_dqs_tap_cnt_r[(((prbs_dqs_cnt_timing_r <<2) + (prbs_dqs_cnt_timing_r <<1))
         +(rnk_cnt_r*DQS_WIDTH*6))+:6]
           <= #TCQ prbs_dqs_tap_cnt_r;
     end
   end
  always @(posedge clk) begin
    prbs_state_r1      <= #TCQ prbs_state_r;
    prbs_rdlvl_start_r <= #TCQ prbs_rdlvl_start;
  end
  always @(posedge clk)
    if ((prbs_state_r == PRBS_NEW_DQS_WAIT) ||
        (prbs_state_r == PRBS_INC_DQS_WAIT) ||
        (prbs_state_r == PRBS_DEC_DQS_WAIT) ||
        (prbs_state_r == PRBS_NEW_DQS_PREWAIT))
      wait_state_cnt_en_r <= #TCQ 1'b1;
    else
      wait_state_cnt_en_r <= #TCQ 1'b0;
  always @(posedge clk)
    if (!wait_state_cnt_en_r) begin
      wait_state_cnt_r <= #TCQ 'b0;
      cnt_wait_state   <= #TCQ 1'b0;
    end else begin
      if (wait_state_cnt_r < 'd15) begin
        wait_state_cnt_r <= #TCQ wait_state_cnt_r + 1;
        cnt_wait_state   <= #TCQ 1'b0;
      end else begin
        wait_state_cnt_r <= #TCQ 'b0;        
        cnt_wait_state   <= #TCQ 1'b1;
      end
    end
  always @(posedge clk)
    if (rst) begin
      prbs_dqs_cnt_r        <= #TCQ 'b0;
      prbs_tap_en_r         <= #TCQ 1'b0;
      prbs_tap_inc_r        <= #TCQ 1'b0;
      prbs_prech_req_r      <= #TCQ 1'b0;
      prbs_state_r          <= #TCQ PRBS_IDLE;
      prbs_found_1st_edge_r <= #TCQ 1'b0;
      prbs_found_2nd_edge_r <= #TCQ 1'b0;
      prbs_1st_edge_taps_r  <= #TCQ 6'bxxxxxx;
      prbs_inc_tap_cnt      <= #TCQ 'b0;
      prbs_dec_tap_cnt      <= #TCQ 'b0;
      new_cnt_dqs_r         <= #TCQ 1'b0;
      if (SIM_CAL_OPTION == "FAST_CAL")
        prbs_rdlvl_done       <= #TCQ 1'b1;
      else
        prbs_rdlvl_done       <= #TCQ 1'b0;
      prbs_2nd_edge_taps_r  <= #TCQ 6'bxxxxxx;
      prbs_last_byte_done   <= #TCQ 1'b0;
      rnk_cnt_r             <= #TCQ 2'b00;
      prbs_tap_mod          <= #TCQ 'd0;	  
    end else begin
      case (prbs_state_r)
        PRBS_IDLE: begin
          prbs_last_byte_done  <= #TCQ 1'b0;
          prbs_prech_req_r     <= #TCQ 1'b0;
          if (prbs_rdlvl_start && ~prbs_rdlvl_start_r) begin
            if (SIM_CAL_OPTION == "SKIP_CAL")
              prbs_state_r  <= #TCQ PRBS_DONE;
            else begin
              new_cnt_dqs_r <= #TCQ 1'b1;             
              prbs_state_r  <= #TCQ PRBS_NEW_DQS_WAIT;
            end
          end
        end
        PRBS_NEW_DQS_WAIT: begin
          prbs_last_byte_done <= #TCQ 1'b0;
          prbs_prech_req_r    <= #TCQ 1'b0;
          if (cnt_wait_state) begin
            new_cnt_dqs_r <= #TCQ 1'b0;
            prbs_state_r  <= #TCQ PRBS_PAT_COMPARE;
          end
        end
        PRBS_PAT_COMPARE: begin
          if (num_samples_done_r || compare_err) begin
            if (prbs_dqs_tap_limit_r)
              prbs_state_r <= #TCQ PRBS_CALC_TAPS;
            else if (compare_err || (prbs_dqs_tap_cnt_r == 'd0)) begin 
              prbs_found_1st_edge_r <= #TCQ 1'b1;
              if (prbs_found_1st_edge_r) begin
                prbs_found_2nd_edge_r <= #TCQ 1'b1;
                prbs_2nd_edge_taps_r  <= #TCQ prbs_dqs_tap_cnt_r - 1;
                prbs_state_r          <= #TCQ PRBS_CALC_TAPS;          
              end else begin
                if (compare_err)
                  prbs_1st_edge_taps_r <= #TCQ prbs_dqs_tap_cnt_r + 1;
                else
                  prbs_1st_edge_taps_r <= #TCQ 'd0;
                prbs_inc_tap_cnt     <= #TCQ rdlvl_cpt_tap_cnt - prbs_dqs_tap_cnt_r;           
                prbs_state_r         <= #TCQ PRBS_INC_DQS;
              end
            end else begin
              if (prbs_found_1st_edge_r)
                prbs_state_r  <= #TCQ PRBS_INC_DQS;
              else
                prbs_state_r  <= #TCQ PRBS_DEC_DQS;
            end
          end
        end
        PRBS_INC_DQS: begin
          prbs_state_r        <= #TCQ PRBS_INC_DQS_WAIT;
          if (prbs_inc_tap_cnt > 'd0)
            prbs_inc_tap_cnt <= #TCQ prbs_inc_tap_cnt - 1;
          if (~prbs_dqs_tap_limit_r) begin
            prbs_tap_en_r    <= #TCQ 1'b1;
            prbs_tap_inc_r   <= #TCQ 1'b1;
          end else begin
            prbs_tap_en_r    <= #TCQ 1'b0;
            prbs_tap_inc_r   <= #TCQ 1'b0;
          end
        end
        PRBS_INC_DQS_WAIT: begin
          prbs_tap_en_r    <= #TCQ 1'b0;
          prbs_tap_inc_r   <= #TCQ 1'b0; 
          if (cnt_wait_state) begin
            if (prbs_inc_tap_cnt > 'd0)
              prbs_state_r <= #TCQ PRBS_INC_DQS;
            else
              prbs_state_r <= #TCQ PRBS_PAT_COMPARE;
          end
        end
        PRBS_CALC_TAPS: begin
          if (prbs_found_2nd_edge_r && prbs_found_1st_edge_r)
            prbs_dec_tap_cnt 
              <=  #TCQ ((prbs_2nd_edge_taps_r -
                         prbs_1st_edge_taps_r)>>1) + 1;
          else if (~prbs_found_2nd_edge_r && prbs_found_1st_edge_r)
            prbs_dec_tap_cnt 
              <=  #TCQ ((prbs_dqs_tap_cnt_r - prbs_1st_edge_taps_r)>>1);
          else
            prbs_dec_tap_cnt 
              <=  #TCQ (prbs_dqs_tap_cnt_r>>1);
          prbs_state_r <= #TCQ PRBS_TAP_CHECK; 
        end
	PRBS_TAP_CHECK: begin
          if (prbs_dec_tap_calc_minus_3 > prbs_dec_tap_cnt) begin 
	    prbs_tap_mod[prbs_dqs_cnt_timing_r] <= #TCQ 1'b1;
            prbs_dec_tap_cnt <= #TCQ prbs_dec_tap_calc_minus_3;
          end else if (prbs_dec_tap_calc_plus_3 < prbs_dec_tap_cnt) begin 
	    prbs_tap_mod[prbs_dqs_cnt_timing_r] <= #TCQ 1'b1;
            prbs_dec_tap_cnt <= #TCQ prbs_dec_tap_calc_plus_3; 
	  end
	  prbs_state_r <= #TCQ PRBS_DEC_DQS;
	end
        PRBS_DEC_DQS: begin
          prbs_tap_en_r  <= #TCQ 1'b1;
          prbs_tap_inc_r <= #TCQ 1'b0;
          if (prbs_dec_tap_cnt > 'd0)
            prbs_dec_tap_cnt <= #TCQ prbs_dec_tap_cnt - 1;
          if (prbs_dec_tap_cnt == 6'b000001)
            prbs_state_r <= #TCQ PRBS_NEXT_DQS;
          else
            prbs_state_r <= #TCQ PRBS_DEC_DQS_WAIT;
        end
        PRBS_DEC_DQS_WAIT: begin
          prbs_tap_en_r  <= #TCQ 1'b0;
          prbs_tap_inc_r <= #TCQ 1'b0;
          if (cnt_wait_state) begin
            if (prbs_dec_tap_cnt > 'd0)
              prbs_state_r <= #TCQ PRBS_DEC_DQS;
            else 
              prbs_state_r <= #TCQ PRBS_PAT_COMPARE;
          end
        end
        PRBS_NEXT_DQS: begin
          prbs_prech_req_r  <= #TCQ 1'b1;
          prbs_tap_en_r  <= #TCQ 1'b0;
          prbs_tap_inc_r <= #TCQ 1'b0;
          prbs_found_1st_edge_r <= #TCQ 1'b0;
          prbs_found_2nd_edge_r <= #TCQ 1'b0;
          prbs_1st_edge_taps_r  <= #TCQ 'd0;
          prbs_2nd_edge_taps_r  <= #TCQ 'd0;
          if (prbs_dqs_cnt_r >= DQS_WIDTH-1) begin
            prbs_last_byte_done <= #TCQ 1'b1;
          end
          if (prech_done) begin
                    prbs_prech_req_r <= #TCQ 1'b0;
                        if (prbs_dqs_cnt_r >= DQS_WIDTH-1) begin
              if (rnk_cnt_r == RANKS-1) begin
                prbs_state_r <= #TCQ PRBS_DONE;
              end else begin
                rnk_cnt_r      <= #TCQ rnk_cnt_r + 1;
                new_cnt_dqs_r  <= #TCQ 1'b1;
                prbs_dqs_cnt_r <= #TCQ 'b0;
                prbs_state_r   <= #TCQ PRBS_IDLE;
              end
            end else begin
              new_cnt_dqs_r  <= #TCQ 1'b1;
              prbs_dqs_cnt_r <= #TCQ prbs_dqs_cnt_r + 1;
              prbs_state_r   <= #TCQ PRBS_NEW_DQS_PREWAIT;
            end
          end
        end
        PRBS_NEW_DQS_PREWAIT: begin
          if (cnt_wait_state) begin
            prbs_state_r <= #TCQ PRBS_NEW_DQS_WAIT;
          end
        end
        PRBS_DONE: begin
          prbs_prech_req_r    <= #TCQ 1'b0;
          prbs_last_byte_done <= #TCQ 1'b0;
          prbs_rdlvl_done     <= #TCQ 1'b1;
        end
      endcase
    end
endmodule
