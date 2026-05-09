`timescale 1ps/1ps
`timescale 1ps/1ps
module phy_rdlvl #
  (
   parameter TCQ             = 100,    
   parameter nCK_PER_CLK     = 2,      
   parameter CLK_PERIOD      = 3333,   
   parameter DQ_WIDTH        = 64,     
   parameter DQS_CNT_WIDTH   = 3,      
   parameter DQS_WIDTH       = 8,      
   parameter DRAM_WIDTH      = 8,      
   parameter RANKS           = 1,      
   parameter PER_BIT_DESKEW  = "ON",   
   parameter SIM_CAL_OPTION  = "NONE", 
   parameter DEBUG_PORT      = "OFF"   
   )
  (
   input                        clk,
   input                        rst,
   input                        rdlvl_stg1_start,
   output reg                   rdlvl_stg1_done,
   output                       rdlvl_stg1_rnk_done,
   output reg                   rdlvl_stg1_err,
   output reg                   rdlvl_prech_req,
   input                        prech_done,
   input [DQ_WIDTH-1:0]         rd_data_rise0,
   input [DQ_WIDTH-1:0]         rd_data_fall0,
   input [DQ_WIDTH-1:0]         rd_data_rise1,
   input [DQ_WIDTH-1:0]         rd_data_fall1,
   input [DQ_WIDTH-1:0]         rd_data_rise2,
   input [DQ_WIDTH-1:0]         rd_data_fall2,
   input [DQ_WIDTH-1:0]         rd_data_rise3,
   input [DQ_WIDTH-1:0]         rd_data_fall3,
   output reg                   pi_en_stg2_f,
   output reg                   pi_stg2_f_incdec,
   output reg                   pi_stg2_load,
   output reg [5:0]             pi_stg2_reg_l,
   output [DQS_CNT_WIDTH:0]     pi_stg2_rdlvl_cnt,
   output reg [5*RANKS*DQ_WIDTH-1:0] dlyval_dq,
   output [5*DQS_WIDTH-1:0]     dbg_cpt_first_edge_cnt,
   output [5*DQS_WIDTH-1:0]     dbg_cpt_second_edge_cnt,
   input                        dbg_idel_up_all,
   input                        dbg_idel_down_all,
   input                        dbg_idel_up_cpt,
   input                        dbg_idel_down_cpt,
   input [DQS_CNT_WIDTH-1:0]    dbg_sel_idel_cpt,
   input                        dbg_sel_all_idel_cpt,
   output [255:0]               dbg_phy_rdlvl
   );
  localparam MIN_EYE_SIZE = 8;
  localparam PIPE_WAIT_CNT = 16;
  localparam CAL_PAT_LEN = 8;
  localparam RD_SHIFT_LEN = CAL_PAT_LEN/(nCK_PER_CLK);
  localparam [11:0] DETECT_EDGE_SAMPLE_CNT0 = 12'h001; 
  localparam [11:0] DETECT_EDGE_SAMPLE_CNT1 = 12'h000; 
  localparam [4:0] CAL1_IDLE                 = 5'h00;
  localparam [4:0] CAL1_NEW_DQS_WAIT         = 5'h01;
  localparam [4:0] CAL1_STORE_FIRST_WAIT     = 5'h02;
  localparam [4:0] CAL1_DETECT_EDGE          = 5'h03;
  localparam [4:0] CAL1_IDEL_STORE_OLD       = 5'h04;
  localparam [4:0] CAL1_IDEL_INC_CPT         = 5'h05;
  localparam [4:0] CAL1_IDEL_INC_CPT_WAIT    = 5'h06;
  localparam [4:0] CAL1_CALC_IDEL            = 5'h07;
  localparam [4:0] CAL1_IDEL_DEC_CPT         = 5'h08;
  localparam [4:0] CAL1_IDEL_DEC_CPT_WAIT    = 5'h09;
  localparam [4:0] CAL1_NEXT_DQS             = 5'h0A;
  localparam [4:0] CAL1_DONE                 = 5'h0B;
  localparam [4:0] CAL1_PB_STORE_FIRST_WAIT  = 5'h0C;
  localparam [4:0] CAL1_PB_DETECT_EDGE       = 5'h0D;
  localparam [4:0] CAL1_PB_INC_CPT           = 5'h0E;
  localparam [4:0] CAL1_PB_INC_CPT_WAIT      = 5'h0F;
  localparam [4:0] CAL1_PB_DEC_CPT_LEFT      = 5'h10;
  localparam [4:0] CAL1_PB_DEC_CPT_LEFT_WAIT = 5'h11;
  localparam [4:0] CAL1_PB_DETECT_EDGE_DQ    = 5'h12;
  localparam [4:0] CAL1_PB_INC_DQ            = 5'h13;
  localparam [4:0] CAL1_PB_INC_DQ_WAIT       = 5'h14;
  localparam [4:0] CAL1_PB_DEC_CPT           = 5'h15;
  localparam [4:0] CAL1_PB_DEC_CPT_WAIT      = 5'h16;
  localparam [4:0] CAL1_REGL_LOAD            = 5'h17;
  integer    i;
  integer    j;
  integer    k;
  integer    l;
  integer    m;
  integer    n;
  integer    r;
  integer    p;
  integer    q;
  genvar     x;
  genvar     z;
  reg [DQS_CNT_WIDTH:0]   cal1_cnt_cpt_r;
  wire [DQS_CNT_WIDTH+2:0]cal1_cnt_cpt_timing;
  reg                     cal1_dlyce_cpt_r;
  reg                     cal1_dlyinc_cpt_r;
  reg                     cal1_dlyce_dq_r;
  reg                     cal1_dlyinc_dq_r;
  reg                     cal1_wait_cnt_en_r;  
  reg [3:0]               cal1_wait_cnt_r;                
  reg                     cal1_wait_r;
  reg [DQ_WIDTH-1:0]      dlyce_dq_r;
  reg                     dlyinc_dq_r;  
  reg [5*DQ_WIDTH*RANKS-1:0] dlyval_dq_reg_r;
  reg                     cal1_prech_req_r;
  reg [4:0]               cal1_state_r;
  reg [4:0]               cal1_state_r1;
  reg [5:0]               cnt_idel_dec_cpt_r;
  reg [3:0]               cnt_shift_r;
  reg                     detect_edge_done_r;  
  reg [5:0]               first_edge_taps_r;
  reg                     found_edge_r;
  reg                     found_first_edge_r;
  reg                     found_second_edge_r;
  reg                     found_stable_eye_r;
  reg                     found_stable_eye_last_r;
  reg                     found_edge_all_r;
  reg [5:0]               tap_cnt_cpt_r;
  reg                     tap_limit_cpt_r;
  reg [4:0]               idel_tap_cnt_dq_pb_r;
  reg                     idel_tap_limit_dq_pb_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall0_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall1_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise0_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise1_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall2_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall3_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise2_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise3_r;
  reg                     new_cnt_cpt_r;
  reg [RD_SHIFT_LEN-1:0]  old_sr_fall0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  old_sr_fall1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  old_sr_rise0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  old_sr_rise1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  old_sr_fall2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  old_sr_fall3_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  old_sr_rise2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  old_sr_rise3_r [DRAM_WIDTH-1:0];
  reg [DRAM_WIDTH-1:0]    old_sr_match_fall0_r;
  reg [DRAM_WIDTH-1:0]    old_sr_match_fall1_r;
  reg [DRAM_WIDTH-1:0]    old_sr_match_rise0_r;
  reg [DRAM_WIDTH-1:0]    old_sr_match_rise1_r;
  reg [DRAM_WIDTH-1:0]    old_sr_match_fall2_r;
  reg [DRAM_WIDTH-1:0]    old_sr_match_fall3_r;
  reg [DRAM_WIDTH-1:0]    old_sr_match_rise2_r;
  reg [DRAM_WIDTH-1:0]    old_sr_match_rise3_r;
  reg [2:0]               pb_cnt_eye_size_r [DRAM_WIDTH-1:0];
  reg [DRAM_WIDTH-1:0]    pb_detect_edge_done_r;
  reg [DRAM_WIDTH-1:0]    pb_found_edge_last_r;  
  reg [DRAM_WIDTH-1:0]    pb_found_edge_r;
  reg [DRAM_WIDTH-1:0]    pb_found_first_edge_r;  
  reg [DRAM_WIDTH-1:0]    pb_found_stable_eye_r;
  reg [DRAM_WIDTH-1:0]    pb_last_tap_jitter_r;
  wire [RD_SHIFT_LEN-1:0] pat_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_fall1 [3:0];
  reg [DRAM_WIDTH-1:0]    pat_match_fall0_r;
  reg                     pat_match_fall0_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_fall1_r;
  reg                     pat_match_fall1_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_fall2_r;
  reg                     pat_match_fall2_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_fall3_r;
  reg                     pat_match_fall3_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_rise0_r;
  reg                     pat_match_rise0_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_rise1_r;
  reg                     pat_match_rise1_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_rise2_r;
  reg                     pat_match_rise2_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_rise3_r;
  reg                     pat_match_rise3_and_r;
  wire [RD_SHIFT_LEN-1:0] pat_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_rise1 [3:0];
  reg [DRAM_WIDTH-1:0]    prev_sr_diff_r;
  reg [RD_SHIFT_LEN-1:0]  prev_sr_fall0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_fall1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_rise0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_rise1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_fall2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_fall3_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_rise2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_rise3_r [DRAM_WIDTH-1:0];
  reg [DRAM_WIDTH-1:0]    prev_sr_match_cyc2_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_fall0_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_fall1_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_rise0_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_rise1_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_fall2_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_fall3_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_rise2_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_rise3_r;
  reg                     samp_cnt_done_r;
  reg                     samp_edge_cnt0_en_r;
  reg [11:0]              samp_edge_cnt0_r;
  reg                     samp_edge_cnt1_en_r;
  reg [11:0]              samp_edge_cnt1_r;
  reg [DQS_CNT_WIDTH:0]   rd_mux_sel_r;
  reg [5:0]               second_edge_taps_r;
  reg [RD_SHIFT_LEN-1:0]  sr_fall0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_fall1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_fall2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_fall3_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise3_r [DRAM_WIDTH-1:0];
  reg                     store_sr_done_r;
  reg                     store_sr_r;
  reg                     store_sr_req_r;
  reg                     sr_valid_r;
  reg                     sr_valid_r1;
  reg                     sr_valid_r2;
  reg [DRAM_WIDTH-1:0]    old_sr_diff_r;
  reg [DRAM_WIDTH-1:0]    old_sr_match_cyc2_r;
  reg [6*DQS_WIDTH*RANKS-1:0] rdlvl_dqs_tap_cnt_r;
  reg [1:0]               rnk_cnt_r;
  reg                     rdlvl_rank_done_r;
  reg [3:0]               done_cnt;
  reg [1:0]               regl_rank_cnt;
  reg [DQS_CNT_WIDTH:0]   regl_dqs_cnt;
  wire [DQS_CNT_WIDTH+2:0]regl_dqs_cnt_timing;
  reg                     regl_rank_done_r;
  reg [4:0]               dbg_cpt_first_edge_taps [0:DQS_WIDTH-1];
  reg [4:0]               dbg_cpt_second_edge_taps [0:DQS_WIDTH-1];
  assign dbg_phy_rdlvl[0]      = rdlvl_stg1_start;
  assign dbg_phy_rdlvl[1]      = 'b0;
  assign dbg_phy_rdlvl[2]      = found_edge_r;
  assign dbg_phy_rdlvl[3]      = 'b0;
  assign dbg_phy_rdlvl[6:4]    = 'b0;
  assign dbg_phy_rdlvl[8:7]    = 'b0;
  assign dbg_phy_rdlvl[13:9]   = cal1_state_r[4:0];
  assign dbg_phy_rdlvl[20:14]  = cnt_idel_dec_cpt_r;
  assign dbg_phy_rdlvl[21]     = found_first_edge_r;
  assign dbg_phy_rdlvl[22]     = found_second_edge_r;
  assign dbg_phy_rdlvl[23]     = 'b0;
  assign dbg_phy_rdlvl[24]     = store_sr_r;
  assign dbg_phy_rdlvl[32:25]  = {sr_fall1_r[0][1:0], sr_rise1_r[0][1:0],
                                  sr_fall0_r[0][1:0], sr_rise0_r[0][1:0]};
  assign dbg_phy_rdlvl[40:33]  = {old_sr_fall1_r[0][1:0],
                                  old_sr_rise1_r[0][1:0],
                                  old_sr_fall0_r[0][1:0],
                                  old_sr_rise0_r[0][1:0]};
  assign dbg_phy_rdlvl[41]     = sr_valid_r;
  assign dbg_phy_rdlvl[42]     = found_stable_eye_r;
  assign dbg_phy_rdlvl[48:43]  = tap_cnt_cpt_r;
  assign dbg_phy_rdlvl[54:49]  = first_edge_taps_r;
  assign dbg_phy_rdlvl[60:55]  = second_edge_taps_r;
  assign dbg_phy_rdlvl[64:61]  = cal1_cnt_cpt_r;
  assign dbg_phy_rdlvl[65]     = cal1_dlyce_cpt_r;
  assign dbg_phy_rdlvl[66]     = cal1_dlyinc_cpt_r;
  assign dbg_phy_rdlvl[67]     = found_edge_r;
  assign dbg_phy_rdlvl[68]     = found_first_edge_r;
  assign dbg_phy_rdlvl[255:69] = 'b0;
  generate
    genvar ce_i;
    for (ce_i = 0; ce_i < DQS_WIDTH; ce_i = ce_i + 1) begin: gen_dbg_cpt_edge
      assign dbg_cpt_first_edge_cnt[(5*ce_i)+4:(5*ce_i)]
               = dbg_cpt_first_edge_taps[ce_i];
      assign dbg_cpt_second_edge_cnt[(5*ce_i)+4:(5*ce_i)]
               = dbg_cpt_second_edge_taps[ce_i];
      always @(posedge clk)
        if (rst) begin
          dbg_cpt_first_edge_taps[ce_i]  <= #TCQ 'b0;
          dbg_cpt_second_edge_taps[ce_i] <= #TCQ 'b0;
        end else begin
          if (cal1_state_r == CAL1_CALC_IDEL) begin
            if (found_first_edge_r && (cal1_cnt_cpt_r == ce_i))
              dbg_cpt_first_edge_taps[ce_i]  
                <= #TCQ first_edge_taps_r;
            if (found_second_edge_r && (cal1_cnt_cpt_r == ce_i))
              dbg_cpt_second_edge_taps[ce_i] 
                <= #TCQ second_edge_taps_r;
          end
        end
    end
  endgenerate
  assign rdlvl_stg1_rnk_done = rdlvl_rank_done_r;
   assign pi_stg2_rdlvl_cnt = (cal1_state_r == CAL1_REGL_LOAD) ? regl_dqs_cnt : cal1_cnt_cpt_r;
  always @(posedge clk) begin
    rd_mux_sel_r <= #TCQ cal1_cnt_cpt_r;
  end
  generate
    genvar mux_i;
    for (mux_i = 0; mux_i < DRAM_WIDTH; mux_i = mux_i + 1) begin: gen_mux_rd
      always @(posedge clk) begin
        mux_rd_rise0_r[mux_i] <= #TCQ rd_data_rise0[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_fall0_r[mux_i] <= #TCQ rd_data_fall0[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_rise1_r[mux_i] <= #TCQ rd_data_rise1[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_fall1_r[mux_i] <= #TCQ rd_data_fall1[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_rise2_r[mux_i] <= #TCQ rd_data_rise2[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_fall2_r[mux_i] <= #TCQ rd_data_fall2[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_rise3_r[mux_i] <= #TCQ rd_data_rise3[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_fall3_r[mux_i] <= #TCQ rd_data_fall3[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];     
      end
    end
  endgenerate
  always @(posedge clk) begin
    if (rst) begin
      pi_en_stg2_f     <= #TCQ 'b0;
      pi_stg2_f_incdec <= #TCQ 'b0;
    end else if (cal1_dlyce_cpt_r) begin
      if ((SIM_CAL_OPTION == "NONE") ||
          (SIM_CAL_OPTION == "FAST_WIN_DETECT")) begin 
        pi_en_stg2_f     <= #TCQ 1'b1;  
        pi_stg2_f_incdec <= #TCQ cal1_dlyinc_cpt_r;
      end else if (SIM_CAL_OPTION == "FAST_CAL") begin 
        pi_en_stg2_f     <= #TCQ 1'b1;
        pi_stg2_f_incdec <= #TCQ cal1_dlyinc_cpt_r;
      end
    end else begin
      pi_en_stg2_f     <= #TCQ 'b0;
      pi_stg2_f_incdec <= #TCQ 'b0;
    end
  end
   always @(posedge clk) begin
     if (rst)
       done_cnt <= #TCQ 'b0;
     else if (((cal1_state_r == CAL1_REGL_LOAD) && 
               (cal1_state_r1 == CAL1_NEXT_DQS)) ||
              ((done_cnt == 4'd1) && (cal1_state_r != CAL1_DONE)))
       done_cnt <= #TCQ 4'b1010;
     else if (done_cnt > 'b0)
       done_cnt <= #TCQ done_cnt - 1;
   end
   always @(posedge clk) begin
     if (rst || (regl_rank_done_r == 1'b1))
       regl_rank_done_r <= #TCQ 1'b0;
     else if ((regl_dqs_cnt == DQS_WIDTH-1) &&
              (regl_rank_cnt != RANKS-1) &&
              (done_cnt == 4'd1))
       regl_rank_done_r <= #TCQ 1'b1;
   end
   assign regl_dqs_cnt_timing = {2'd0, regl_dqs_cnt};
   always @(posedge clk) begin
     if (rst || (done_cnt == 4'd0)) begin
       pi_stg2_load    <= #TCQ 'b0;
       pi_stg2_reg_l   <= #TCQ 'b0;
     end else if ((cal1_state_r == CAL1_REGL_LOAD) && 
                  (regl_dqs_cnt <= DQS_WIDTH-1) && (done_cnt == 4'd1)) begin
       pi_stg2_load  <= #TCQ 'b1;
       pi_stg2_reg_l <= #TCQ 
         rdlvl_dqs_tap_cnt_r[(((regl_dqs_cnt_timing<<2) + (regl_dqs_cnt_timing<<1))
         +(rnk_cnt_r*DQS_WIDTH*6))+:6];
     end else begin
       pi_stg2_load  <= #TCQ 'b0;
       pi_stg2_reg_l <= #TCQ 'b0;
     end
   end
   always @(posedge clk) begin
     if (rst || (done_cnt == 4'd0))
       regl_rank_cnt   <= #TCQ 2'b00;
     else if ((cal1_state_r == CAL1_REGL_LOAD) && 
              (regl_dqs_cnt == DQS_WIDTH-1) && (done_cnt == 4'd1)) begin
       if (regl_rank_cnt == RANKS-1)
         regl_rank_cnt  <= #TCQ regl_rank_cnt;
       else
         regl_rank_cnt <= #TCQ regl_rank_cnt + 1;
     end
   end
   always @(posedge clk) begin
     if (rst || (done_cnt == 4'd0))
       regl_dqs_cnt    <= #TCQ {DQS_CNT_WIDTH+1{1'b0}};
     else if ((cal1_state_r == CAL1_REGL_LOAD) && 
              (regl_dqs_cnt == DQS_WIDTH-1) && (done_cnt == 4'd1)) begin
       if (regl_rank_cnt == RANKS-1)
         regl_dqs_cnt  <= #TCQ regl_dqs_cnt;
       else
         regl_dqs_cnt  <= #TCQ 'b0;
     end else if ((cal1_state_r == CAL1_REGL_LOAD) && (regl_dqs_cnt != DQS_WIDTH-1)
                  && (done_cnt == 4'd1))
       regl_dqs_cnt  <= #TCQ regl_dqs_cnt + 1;
     else
       regl_dqs_cnt  <= #TCQ regl_dqs_cnt;
   end
  generate
    for (z = 0; z < DQS_WIDTH; z = z + 1) begin: gen_dlyce_dq
      always @(posedge clk)
        if (rst)
          dlyce_dq_r[DRAM_WIDTH*z+:DRAM_WIDTH] <= #TCQ 'b0;
        else
          if (SIM_CAL_OPTION == "SKIP_CAL")
            dlyce_dq_r[DRAM_WIDTH*z+:DRAM_WIDTH] <= #TCQ 'b0;
          else if (SIM_CAL_OPTION == "FAST_CAL")
            dlyce_dq_r[DRAM_WIDTH*z+:DRAM_WIDTH] <= #TCQ cal1_dlyce_dq_r;
          else if ((SIM_CAL_OPTION == "NONE") ||
                   (SIM_CAL_OPTION == "FAST_WIN_DETECT")) begin 
            if (cal1_cnt_cpt_r == z)
              dlyce_dq_r[DRAM_WIDTH*z+:DRAM_WIDTH] 
                <= #TCQ cal1_dlyce_dq_r;
            else
              dlyce_dq_r[DRAM_WIDTH*z+:DRAM_WIDTH] <= #TCQ 'b0;
          end
    end
  endgenerate
  always @(posedge clk)
    if (rst)
      dlyinc_dq_r <= #TCQ 1'b0;
    else
      dlyinc_dq_r <= #TCQ cal1_dlyinc_dq_r;  
  always @(posedge clk)
    if (rst | (SIM_CAL_OPTION == "SKIP_CAL")) begin
      dlyval_dq_reg_r <= #TCQ 'b0;
    end else if (SIM_CAL_OPTION == "FAST_CAL") begin
      for (n = 0; n < RANKS; n = n + 1) begin: gen_dlyval_dq_reg_rnk
        for (r = 0; r < DQ_WIDTH; r = r + 1) begin: gen_dlyval_dq_reg
          if (dlyce_dq_r[r]) begin     
            if (dlyinc_dq_r)
              dlyval_dq_reg_r[((5*r)+(n*DQ_WIDTH*5))+:5] 
              <= #TCQ dlyval_dq_reg_r[((5*r)+(n*DQ_WIDTH*5))+:5] + 1;
            else
              dlyval_dq_reg_r[((5*r)+(n*DQ_WIDTH*5))+:5] 
              <= #TCQ dlyval_dq_reg_r[((5*r)+(n*DQ_WIDTH*5))+:5] - 1;
          end
        end
      end
    end else begin
      if (dlyce_dq_r[cal1_cnt_cpt_r]) begin     
        if (dlyinc_dq_r)
          dlyval_dq_reg_r[((5*cal1_cnt_cpt_r)+(rnk_cnt_r*5*DQ_WIDTH))+:5] 
          <= #TCQ 
          dlyval_dq_reg_r[((5*cal1_cnt_cpt_r)+(rnk_cnt_r*5*DQ_WIDTH))+:5] + 1;
        else
          dlyval_dq_reg_r[((5*cal1_cnt_cpt_r)+(rnk_cnt_r*5*DQ_WIDTH))+:5] 
          <= #TCQ 
          dlyval_dq_reg_r[((5*cal1_cnt_cpt_r)+(rnk_cnt_r*5*DQ_WIDTH))+:5] - 1;
      end
    end
        always @(posedge clk) begin 
          dlyval_dq <= #TCQ dlyval_dq_reg_r;
        end
  always @(posedge clk)
    if ((cal1_state_r == CAL1_NEW_DQS_WAIT) ||
        (cal1_state_r == CAL1_PB_STORE_FIRST_WAIT) ||
        (cal1_state_r == CAL1_PB_INC_CPT_WAIT) ||
        (cal1_state_r == CAL1_PB_DEC_CPT_LEFT_WAIT) ||
        (cal1_state_r == CAL1_PB_INC_DQ_WAIT) ||
        (cal1_state_r == CAL1_PB_DEC_CPT_WAIT) ||
        (cal1_state_r == CAL1_IDEL_INC_CPT_WAIT) ||
        (cal1_state_r == CAL1_STORE_FIRST_WAIT))
      cal1_wait_cnt_en_r <= #TCQ 1'b1;
    else
      cal1_wait_cnt_en_r <= #TCQ 1'b0;
  always @(posedge clk)
    if (!cal1_wait_cnt_en_r) begin
      cal1_wait_cnt_r <= #TCQ 4'b0000;
      cal1_wait_r     <= #TCQ 1'b1;
    end else begin
      if (cal1_wait_cnt_r != PIPE_WAIT_CNT - 1) begin
        cal1_wait_cnt_r <= #TCQ cal1_wait_cnt_r + 1;
        cal1_wait_r     <= #TCQ 1'b1;
      end else begin
        cal1_wait_cnt_r <= #TCQ 4'b0000;        
        cal1_wait_r     <= #TCQ 1'b0;
      end
    end  
  always @(posedge clk)
    if (rst)
      rdlvl_prech_req <= #TCQ 1'b0;
    else
      rdlvl_prech_req <= #TCQ cal1_prech_req_r;
  generate
    genvar rd_i;
    for (rd_i = 0; rd_i < DRAM_WIDTH; rd_i = rd_i + 1) begin: gen_sr
      always @(posedge clk) begin
        sr_rise0_r[rd_i] <= #TCQ {sr_rise0_r[rd_i][RD_SHIFT_LEN-2:0],
                                   mux_rd_rise0_r[rd_i]};
        sr_fall0_r[rd_i] <= #TCQ {sr_fall0_r[rd_i][RD_SHIFT_LEN-2:0],
                                   mux_rd_fall0_r[rd_i]};
        sr_rise1_r[rd_i] <= #TCQ {sr_rise1_r[rd_i][RD_SHIFT_LEN-2:0],
                                   mux_rd_rise1_r[rd_i]};
        sr_fall1_r[rd_i] <= #TCQ {sr_fall1_r[rd_i][RD_SHIFT_LEN-2:0],
                                   mux_rd_fall1_r[rd_i]};
        sr_rise2_r[rd_i] <= #TCQ {sr_rise2_r[rd_i][RD_SHIFT_LEN-2:0],
                                   mux_rd_rise2_r[rd_i]};
        sr_fall2_r[rd_i] <= #TCQ {sr_fall2_r[rd_i][RD_SHIFT_LEN-2:0],
                                   mux_rd_fall2_r[rd_i]};
        sr_rise3_r[rd_i] <= #TCQ {sr_rise3_r[rd_i][RD_SHIFT_LEN-2:0],
                                   mux_rd_rise3_r[rd_i]};
        sr_fall3_r[rd_i] <= #TCQ {sr_fall3_r[rd_i][RD_SHIFT_LEN-2:0],
                                   mux_rd_fall3_r[rd_i]};
      end
    end
  endgenerate
  always @(posedge clk)
    if (rst) begin
      cnt_shift_r <= #TCQ 'b0;
      sr_valid_r  <= #TCQ 1'b0;
    end else begin
      if (cnt_shift_r == RD_SHIFT_LEN-1) begin
        sr_valid_r <= #TCQ 1'b1;
        cnt_shift_r <= #TCQ 'b0;
      end else begin
        sr_valid_r <= #TCQ 1'b0;
        cnt_shift_r <= #TCQ cnt_shift_r + 1;
      end
    end
  always @(posedge clk)
    if (rst) begin
      store_sr_done_r <= #TCQ 1'b0;
      store_sr_r      <= #TCQ 1'b0;
    end else begin
      store_sr_done_r <= sr_valid_r & store_sr_r;
      if (store_sr_req_r)
        store_sr_r <= #TCQ 1'b1;
      else if (sr_valid_r && store_sr_r)
        store_sr_r <= #TCQ 1'b0;
    end
  generate
    for (z = 0; z < DRAM_WIDTH; z = z + 1) begin: gen_old_sr
      always @(posedge clk) begin
        if (sr_valid_r) begin
          prev_sr_rise0_r[z] <= #TCQ sr_rise0_r[z];
          prev_sr_fall0_r[z] <= #TCQ sr_fall0_r[z];
          prev_sr_rise1_r[z] <= #TCQ sr_rise1_r[z];
          prev_sr_fall1_r[z] <= #TCQ sr_fall1_r[z];
          prev_sr_rise2_r[z] <= #TCQ sr_rise2_r[z];
          prev_sr_fall2_r[z] <= #TCQ sr_fall2_r[z];
          prev_sr_rise3_r[z] <= #TCQ sr_rise3_r[z];
          prev_sr_fall3_r[z] <= #TCQ sr_fall3_r[z];         
        end
        if (sr_valid_r && store_sr_r) begin
          old_sr_rise0_r[z] <= #TCQ sr_rise0_r[z];
          old_sr_fall0_r[z] <= #TCQ sr_fall0_r[z];
          old_sr_rise1_r[z] <= #TCQ sr_rise1_r[z];
          old_sr_fall1_r[z] <= #TCQ sr_fall1_r[z];
          old_sr_rise2_r[z] <= #TCQ sr_rise2_r[z];
          old_sr_fall2_r[z] <= #TCQ sr_fall2_r[z];
          old_sr_rise3_r[z] <= #TCQ sr_rise3_r[z];
          old_sr_fall3_r[z] <= #TCQ sr_fall3_r[z];
        end
      end
    end
  endgenerate
  always @(posedge clk) begin
    sr_valid_r1 <= #TCQ sr_valid_r;
    sr_valid_r2 <= #TCQ sr_valid_r1;
  end
  generate
    for (z = 0; z < DRAM_WIDTH; z = z + 1) begin: gen_sr_match
      always @(posedge clk) begin
        if (sr_rise0_r[z] == old_sr_rise0_r[z])
          old_sr_match_rise0_r[z] <= #TCQ 1'b1;
        else
          old_sr_match_rise0_r[z] <= #TCQ 1'b0;
        if (sr_fall0_r[z] == old_sr_fall0_r[z])
          old_sr_match_fall0_r[z] <= #TCQ 1'b1;
        else
          old_sr_match_fall0_r[z] <= #TCQ 1'b0;
        if (sr_rise1_r[z] == old_sr_rise1_r[z])
          old_sr_match_rise1_r[z] <= #TCQ 1'b1;
        else
          old_sr_match_rise1_r[z] <= #TCQ 1'b0;
        if (sr_fall1_r[z] == old_sr_fall1_r[z])
          old_sr_match_fall1_r[z] <= #TCQ 1'b1;
        else
          old_sr_match_fall1_r[z] <= #TCQ 1'b0;
        if (sr_rise2_r[z] == old_sr_rise2_r[z])
          old_sr_match_rise2_r[z] <= #TCQ 1'b1;
        else
          old_sr_match_rise2_r[z] <= #TCQ 1'b0;
        if (sr_fall2_r[z] == old_sr_fall2_r[z])
          old_sr_match_fall2_r[z] <= #TCQ 1'b1;
        else
          old_sr_match_fall2_r[z] <= #TCQ 1'b0;
        if (sr_rise3_r[z] == old_sr_rise3_r[z])
          old_sr_match_rise3_r[z] <= #TCQ 1'b1;
        else
          old_sr_match_rise3_r[z] <= #TCQ 1'b0;
        if (sr_fall3_r[z] == old_sr_fall3_r[z])
          old_sr_match_fall3_r[z] <= #TCQ 1'b1;
        else
          old_sr_match_fall3_r[z] <= #TCQ 1'b0;
        if (sr_rise0_r[z] == prev_sr_rise0_r[z])
          prev_sr_match_rise0_r[z] <= #TCQ 1'b1;
        else
          prev_sr_match_rise0_r[z] <= #TCQ 1'b0;
        if (sr_fall0_r[z] == prev_sr_fall0_r[z])
          prev_sr_match_fall0_r[z] <= #TCQ 1'b1;
        else
          prev_sr_match_fall0_r[z] <= #TCQ 1'b0;
        if (sr_rise1_r[z] == prev_sr_rise1_r[z])
          prev_sr_match_rise1_r[z] <= #TCQ 1'b1;
        else
          prev_sr_match_rise1_r[z] <= #TCQ 1'b0;
        if (sr_fall1_r[z] == prev_sr_fall1_r[z])
          prev_sr_match_fall1_r[z] <= #TCQ 1'b1;
        else
          prev_sr_match_fall1_r[z] <= #TCQ 1'b0;
        if (sr_rise2_r[z] == prev_sr_rise2_r[z])
          prev_sr_match_rise2_r[z] <= #TCQ 1'b1;
        else
          prev_sr_match_rise2_r[z] <= #TCQ 1'b0;
        if (sr_fall2_r[z] == prev_sr_fall2_r[z])
          prev_sr_match_fall2_r[z] <= #TCQ 1'b1;
        else
          prev_sr_match_fall2_r[z] <= #TCQ 1'b0;
        if (sr_rise3_r[z] == prev_sr_rise3_r[z])
          prev_sr_match_rise3_r[z] <= #TCQ 1'b1;
        else
          prev_sr_match_rise3_r[z] <= #TCQ 1'b0;
        if (sr_fall3_r[z] == prev_sr_fall3_r[z])
          prev_sr_match_fall3_r[z] <= #TCQ 1'b1;
        else
          prev_sr_match_fall3_r[z] <= #TCQ 1'b0;
        old_sr_match_cyc2_r[z] <= #TCQ old_sr_match_rise0_r[z] &
                                  old_sr_match_fall0_r[z] &
                                  old_sr_match_rise1_r[z] &
                                  old_sr_match_fall1_r[z] &
                                  old_sr_match_rise2_r[z] &
                                  old_sr_match_fall2_r[z] &
                                  old_sr_match_rise3_r[z] &
                                  old_sr_match_fall3_r[z];
        prev_sr_match_cyc2_r[z] <= #TCQ prev_sr_match_rise0_r[z] &
                                   prev_sr_match_fall0_r[z] &
                                   prev_sr_match_rise1_r[z] &
                                   prev_sr_match_fall1_r[z] &
                                   prev_sr_match_rise2_r[z] &
                                   prev_sr_match_fall2_r[z] &
                                   prev_sr_match_rise3_r[z] &
                                   prev_sr_match_fall3_r[z];
        if (sr_valid_r2) begin 
          old_sr_diff_r[z]  <= #TCQ ~old_sr_match_cyc2_r[z];
          prev_sr_diff_r[z] <= #TCQ ~prev_sr_match_cyc2_r[z];     
        end else begin 
          old_sr_diff_r[z]  <= #TCQ 'b0;
          prev_sr_diff_r[z] <= #TCQ 'b0;
        end
     end
    end
  endgenerate
  always @(posedge clk)
    samp_edge_cnt0_en_r = #TCQ 
                          (cal1_state_r == CAL1_DETECT_EDGE) ||
                          (cal1_state_r == CAL1_PB_DETECT_EDGE) ||
                          (cal1_state_r == CAL1_PB_DETECT_EDGE_DQ);
  always @(posedge clk)
    if (rst)
      samp_edge_cnt0_r <= #TCQ 'b0;
    else 
      if (!samp_edge_cnt0_en_r)
        samp_edge_cnt0_r <= #TCQ 'b0;
      else
        samp_edge_cnt0_r <= #TCQ samp_edge_cnt0_r + 1;
  always @(posedge clk)
    if (rst)
      samp_edge_cnt1_en_r <= #TCQ 1'b0;
    else begin 
      if (((SIM_CAL_OPTION == "FAST_CAL") ||
           (SIM_CAL_OPTION == "FAST_WIN_DETECT")) && 
           (samp_edge_cnt0_r == 12'h003)) 
        samp_edge_cnt1_en_r <= #TCQ 1'b1;
      else if (samp_edge_cnt0_r == DETECT_EDGE_SAMPLE_CNT0)
        samp_edge_cnt1_en_r <= #TCQ 1'b1;
      else
        samp_edge_cnt1_en_r <= #TCQ 1'b0;
    end
  always @(posedge clk)
    if (rst)
      samp_edge_cnt1_r <= #TCQ 'b0;
    else 
      if (!samp_edge_cnt0_en_r)
        samp_edge_cnt1_r <= #TCQ 'b0;
      else if (samp_edge_cnt1_en_r)
        samp_edge_cnt1_r <= #TCQ samp_edge_cnt1_r + 1;
  always @(posedge clk)
    if (rst)
      samp_cnt_done_r <= #TCQ 1'b0;
    else begin 
      if (!samp_edge_cnt0_en_r)
        samp_cnt_done_r <= #TCQ 'b0;
      else if (((SIM_CAL_OPTION == "FAST_CAL") ||
                (SIM_CAL_OPTION == "FAST_WIN_DETECT")) &&
               (samp_edge_cnt1_r == 12'h003)) 
        samp_cnt_done_r <= #TCQ 1'b1;      
      else if (samp_edge_cnt1_r == DETECT_EDGE_SAMPLE_CNT1) 
        samp_cnt_done_r <= #TCQ 1'b1;
    end
  assign pb_detect_edge_setup 
    = (cal1_state_r == CAL1_STORE_FIRST_WAIT) ||
      (cal1_state_r == CAL1_PB_STORE_FIRST_WAIT) ||
      (cal1_state_r == CAL1_PB_DEC_CPT_LEFT_WAIT);
  assign pb_detect_edge
    = (cal1_state_r == CAL1_DETECT_EDGE) ||
      (cal1_state_r == CAL1_PB_DETECT_EDGE) ||
      (cal1_state_r == CAL1_PB_DETECT_EDGE_DQ);
  generate
    for (z = 0; z < DRAM_WIDTH; z = z + 1) begin: gen_track_left_edge  
      always @(posedge clk) begin 
        if (pb_detect_edge_setup) begin
          pb_cnt_eye_size_r[z]     <= #TCQ 3'b111;
          pb_detect_edge_done_r[z] <= #TCQ 1'b0;
          pb_found_stable_eye_r[z] <= #TCQ 1'b0;      
          pb_last_tap_jitter_r[z]  <= #TCQ 1'b0;
          pb_found_edge_last_r[z]  <= #TCQ 1'b0;
          pb_found_edge_r[z]       <= #TCQ 1'b0;
          pb_found_first_edge_r[z] <= #TCQ 1'b0;
        end else if (pb_detect_edge) begin 
          pb_found_edge_last_r[z] <= #TCQ pb_found_edge_r[z];
          if (!pb_detect_edge_done_r[z]) begin 
            if (samp_cnt_done_r) begin
              pb_last_tap_jitter_r[z]  <= #TCQ 1'b0;
              pb_detect_edge_done_r[z] <= #TCQ 1'b1;
              if (!pb_found_edge_r[z] && !pb_last_tap_jitter_r[z]) begin
                if (pb_cnt_eye_size_r[z] != MIN_EYE_SIZE-1)
                  pb_cnt_eye_size_r[z] <= #TCQ pb_cnt_eye_size_r[z] + 1;
                else if (pb_found_first_edge_r[z])
                  pb_found_stable_eye_r[z] <= #TCQ 1'b1;
              end else begin 
                pb_cnt_eye_size_r[z]     <= #TCQ 3'b000;
                pb_found_stable_eye_r[z] <= #TCQ 1'b0;          
                pb_found_edge_r[z]       <= #TCQ 1'b1;
                pb_detect_edge_done_r[z] <= #TCQ 1'b1;          
              end
            end else if (prev_sr_diff_r[z]) begin
              pb_cnt_eye_size_r[z]     <= #TCQ 3'b000;
              pb_found_stable_eye_r[z] <= #TCQ 1'b0;      
              pb_last_tap_jitter_r[z]  <= #TCQ 1'b1;          
              pb_found_edge_r[z]       <= #TCQ 1'b1;
              pb_found_first_edge_r[z] <= #TCQ 1'b1;          
              pb_detect_edge_done_r[z] <= #TCQ 1'b1;        
            end else if (old_sr_diff_r[z] || pb_last_tap_jitter_r[z]) begin
              pb_cnt_eye_size_r[z]     <= #TCQ 3'b000;
              pb_found_stable_eye_r[z] <= #TCQ 1'b0;      
              pb_found_edge_r[z]       <= #TCQ 1'b1;
              pb_found_first_edge_r[z] <= #TCQ 1'b1;          
            end
          end
        end else begin
          pb_found_edge_r[z]       <= #TCQ 1'b0;
          pb_detect_edge_done_r[z] <= #TCQ 1'b0;
        end
      end          
    end
  endgenerate
  always @(posedge clk) begin
    detect_edge_done_r <= #TCQ &pb_detect_edge_done_r;
    found_edge_r       <= #TCQ |pb_found_edge_r;
    found_edge_all_r   <= #TCQ &pb_found_edge_r;
    found_stable_eye_r <= #TCQ &pb_found_stable_eye_r;
  end
  always @(posedge clk)
    if (pb_detect_edge_setup)
      found_stable_eye_last_r <= #TCQ 1'b0;
    else if (detect_edge_done_r)
      found_stable_eye_last_r <= #TCQ found_stable_eye_r;
  always @(posedge clk)
    if (rst || new_cnt_cpt_r)
      tap_cnt_cpt_r   <= #TCQ 'b0;
    else if (cal1_dlyce_cpt_r) begin
      if (cal1_dlyinc_cpt_r)
        tap_cnt_cpt_r <= #TCQ tap_cnt_cpt_r + 1;
      else
        tap_cnt_cpt_r <= #TCQ tap_cnt_cpt_r - 1;
    end
  always @(posedge clk)
    if (rst || new_cnt_cpt_r)
      tap_limit_cpt_r <= #TCQ 1'b0;
    else if (tap_cnt_cpt_r == 6'd63)
      tap_limit_cpt_r <= #TCQ 1'b1;
  assign cal1_cnt_cpt_timing = {2'd0, cal1_cnt_cpt_r};
   always @(posedge clk) begin
     if (rst) begin
       rdlvl_dqs_tap_cnt_r <= #TCQ 'b0;
     end else if ((SIM_CAL_OPTION == "FAST_CAL") & (cal1_state_r1 == CAL1_NEXT_DQS)) begin
       for (p = 0; p < RANKS; p = p +1) begin: rdlvl_dqs_tap_rank_cnt   
         for(q = 0; q < DQS_WIDTH; q = q +1) begin: rdlvl_dqs_tap_cnt
           rdlvl_dqs_tap_cnt_r[((6*q)+(p*DQS_WIDTH*6))+:6] <= #TCQ tap_cnt_cpt_r;
         end
       end
     end else if (SIM_CAL_OPTION == "SKIP_CAL") begin
       for (j = 0; j < RANKS; j = j +1) begin: rdlvl_dqs_tap_rnk_cnt   
         for(i = 0; i < DQS_WIDTH; i = i +1) begin: rdlvl_dqs_cnt
           rdlvl_dqs_tap_cnt_r[((6*i)+(j*DQS_WIDTH*6))+:6] <= #TCQ 6'd31;
         end
       end
     end else if (cal1_state_r1 == CAL1_NEXT_DQS) begin
         rdlvl_dqs_tap_cnt_r[(((cal1_cnt_cpt_timing <<2) + (cal1_cnt_cpt_timing <<1))
         +(rnk_cnt_r*DQS_WIDTH*6))+:6]
           <= #TCQ tap_cnt_cpt_r;
     end
   end
  always @(posedge clk)
    if (rst) begin
      idel_tap_cnt_dq_pb_r   <= #TCQ 'b0;
      idel_tap_limit_dq_pb_r <= #TCQ 1'b0;
    end else 
      if (new_cnt_cpt_r) begin
        idel_tap_cnt_dq_pb_r   <= #TCQ 'b0;
        idel_tap_limit_dq_pb_r <= #TCQ 1'b0;
      end else if (|cal1_dlyce_dq_r) begin
        if (cal1_dlyinc_dq_r)
          idel_tap_cnt_dq_pb_r <= #TCQ idel_tap_cnt_dq_pb_r + 1;
        else
          idel_tap_cnt_dq_pb_r <= #TCQ idel_tap_cnt_dq_pb_r - 1;         
        if (idel_tap_cnt_dq_pb_r == 31)
          idel_tap_limit_dq_pb_r <= #TCQ 1'b1;
        else
          idel_tap_limit_dq_pb_r <= #TCQ 1'b0;
      end
  always @(posedge clk)
    cal1_state_r1 <= #TCQ cal1_state_r;
  always @(posedge clk)
    if (rst) begin
      cal1_cnt_cpt_r        <= #TCQ 'b0;
      cal1_dlyce_cpt_r      <= #TCQ 1'b0;
      cal1_dlyinc_cpt_r     <= #TCQ 1'b0;
      cal1_prech_req_r      <= #TCQ 1'b0;
      cal1_state_r          <= #TCQ CAL1_IDLE;
      cnt_idel_dec_cpt_r    <= #TCQ 6'bxxxxxx;
      found_first_edge_r    <= #TCQ 1'b0;
      found_second_edge_r   <= #TCQ 1'b0;
      first_edge_taps_r     <= #TCQ 6'bxxxxx;
      new_cnt_cpt_r         <= #TCQ 1'b0;
      rdlvl_stg1_done       <= #TCQ 1'b0;
      rdlvl_stg1_err        <= #TCQ 1'b0;
      second_edge_taps_r    <= #TCQ 6'bxxxxx;
      store_sr_req_r        <= #TCQ 1'b0;
      rnk_cnt_r             <= #TCQ 2'b00;
      rdlvl_rank_done_r     <= #TCQ 1'b0; 
    end else begin
      cal1_prech_req_r    <= #TCQ 1'b0;
      cal1_dlyce_cpt_r    <= #TCQ 1'b0;
      cal1_dlyinc_cpt_r   <= #TCQ 1'b0;
      new_cnt_cpt_r       <= #TCQ 1'b0;
      store_sr_req_r      <= #TCQ 1'b0;
      case (cal1_state_r)
        CAL1_IDLE: begin
          rdlvl_rank_done_r <= #TCQ 1'b0;
          if (rdlvl_stg1_start) begin
            if (SIM_CAL_OPTION == "SKIP_CAL") begin
               cal1_state_r  <= #TCQ CAL1_REGL_LOAD;
            end else begin
              new_cnt_cpt_r <= #TCQ 1'b1;             
              cal1_state_r  <= #TCQ CAL1_NEW_DQS_WAIT;
            end
          end
        end
        CAL1_NEW_DQS_WAIT: begin
          rdlvl_rank_done_r <= #TCQ 1'b0;
          if (!cal1_wait_r) begin
            store_sr_req_r <= #TCQ 1'b1;
            if (PER_BIT_DESKEW == "OFF")
              cal1_state_r <= #TCQ CAL1_STORE_FIRST_WAIT;
            else if (PER_BIT_DESKEW == "ON")
              cal1_state_r <= #TCQ CAL1_PB_STORE_FIRST_WAIT;
          end
        end
        CAL1_PB_STORE_FIRST_WAIT:
          if (!cal1_wait_r) 
            cal1_state_r <= #TCQ CAL1_PB_DETECT_EDGE;
        CAL1_PB_DETECT_EDGE:
          if (detect_edge_done_r) begin
            if (found_stable_eye_r) begin 
              cnt_idel_dec_cpt_r <= #TCQ MIN_EYE_SIZE + 1;
              cal1_state_r       <= #TCQ CAL1_PB_DEC_CPT_LEFT; 
            end else begin
              if (!tap_limit_cpt_r) begin 
                store_sr_req_r <= #TCQ 1'b1;
                cal1_state_r    <= #TCQ CAL1_PB_INC_CPT;
              end else begin
                cnt_idel_dec_cpt_r <= #TCQ 6'd63; 
                cal1_state_r       <= #TCQ CAL1_PB_DEC_CPT;
              end
            end
          end
        CAL1_PB_INC_CPT: begin
          cal1_dlyce_cpt_r  <= #TCQ 1'b1;
          cal1_dlyinc_cpt_r <= #TCQ 1'b1;
          cal1_state_r      <= #TCQ CAL1_PB_INC_CPT_WAIT;
        end
        CAL1_PB_INC_CPT_WAIT: begin
          cal1_dlyce_cpt_r  <= #TCQ 1'b0;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
          if (!cal1_wait_r)
            cal1_state_r <= #TCQ CAL1_PB_DETECT_EDGE;       
        end 
        CAL1_PB_DEC_CPT_LEFT:
          if (cnt_idel_dec_cpt_r == 6'b000000)
            cal1_state_r <= #TCQ CAL1_PB_DEC_CPT_LEFT_WAIT;
          else begin 
            cal1_dlyce_cpt_r   <= #TCQ 1'b1;
            cal1_dlyinc_cpt_r  <= #TCQ 1'b0;
            cnt_idel_dec_cpt_r <= #TCQ cnt_idel_dec_cpt_r - 1;
          end       
        CAL1_PB_DEC_CPT_LEFT_WAIT:
          if (!cal1_wait_r)
            cal1_state_r <= #TCQ CAL1_PB_DETECT_EDGE_DQ;
        CAL1_PB_DETECT_EDGE_DQ:
          if (detect_edge_done_r)
            if (found_edge_all_r) begin 
              cnt_idel_dec_cpt_r <= #TCQ tap_cnt_cpt_r;
              cal1_state_r       <= #TCQ CAL1_PB_DEC_CPT;
            end else
              if (!idel_tap_limit_dq_pb_r)               
                cal1_state_r <= #TCQ CAL1_PB_INC_DQ;
              else begin 
                cnt_idel_dec_cpt_r <= #TCQ tap_cnt_cpt_r;
                cal1_state_r <= #TCQ CAL1_PB_DEC_CPT;
              end
        CAL1_PB_INC_DQ: begin
          cal1_dlyce_dq_r  <= #TCQ ~pb_found_edge_last_r;
          cal1_dlyinc_dq_r <= #TCQ 1'b1;
          cal1_state_r     <= #TCQ CAL1_PB_INC_DQ_WAIT;
        end
        CAL1_PB_INC_DQ_WAIT:
          if (!cal1_wait_r)
            cal1_state_r <= #TCQ CAL1_PB_DETECT_EDGE_DQ;
        CAL1_PB_DEC_CPT:
          if (cnt_idel_dec_cpt_r == 6'b000000)
            cal1_state_r <= #TCQ CAL1_PB_DEC_CPT_WAIT;
          else begin
            cal1_dlyce_cpt_r   <= #TCQ 1'b1;
            cal1_dlyinc_cpt_r  <= #TCQ 1'b0;
            cnt_idel_dec_cpt_r <= #TCQ cnt_idel_dec_cpt_r - 1;
          end
        CAL1_PB_DEC_CPT_WAIT:
          if (!cal1_wait_r) begin 
            store_sr_req_r <= #TCQ 1'b1;
            cal1_state_r    <= #TCQ CAL1_STORE_FIRST_WAIT;      
          end
        CAL1_STORE_FIRST_WAIT: 
          if (!cal1_wait_r)
            cal1_state_r <= #TCQ CAL1_DETECT_EDGE;
        CAL1_DETECT_EDGE: begin
          if (detect_edge_done_r) begin
            if (tap_limit_cpt_r)
              cal1_state_r <= #TCQ CAL1_CALC_IDEL;
            else if (found_edge_r) begin 
              found_first_edge_r <= #TCQ 1'b1;
              if (found_first_edge_r && found_stable_eye_last_r) begin
                found_second_edge_r <= #TCQ 1'b1;
                second_edge_taps_r <= #TCQ tap_cnt_cpt_r - 1;
                cal1_state_r <= #TCQ CAL1_CALC_IDEL;          
              end else begin
                first_edge_taps_r <= #TCQ tap_cnt_cpt_r;           
                cal1_state_r <= #TCQ CAL1_IDEL_STORE_OLD;
              end
            end else
              cal1_state_r <= #TCQ CAL1_IDEL_STORE_OLD;
          end
        end
        CAL1_IDEL_STORE_OLD: begin
          store_sr_req_r <= #TCQ 1'b1;
          if (store_sr_done_r)begin
            cal1_state_r <= #TCQ CAL1_IDEL_INC_CPT;
          end
        end
        CAL1_IDEL_INC_CPT: begin
          cal1_state_r        <= #TCQ CAL1_IDEL_INC_CPT_WAIT;
          if (~tap_limit_cpt_r) begin
            cal1_dlyce_cpt_r    <= #TCQ 1'b1;
            cal1_dlyinc_cpt_r   <= #TCQ 1'b1;
          end else begin
            cal1_dlyce_cpt_r    <= #TCQ 1'b0;
            cal1_dlyinc_cpt_r   <= #TCQ 1'b0;
          end
        end
        CAL1_IDEL_INC_CPT_WAIT: begin
          cal1_dlyce_cpt_r    <= #TCQ 1'b0;
          cal1_dlyinc_cpt_r   <= #TCQ 1'b0; 
          if (!cal1_wait_r)
            cal1_state_r <= #TCQ CAL1_DETECT_EDGE;
        end
        CAL1_CALC_IDEL: begin
          if (found_second_edge_r)
            cnt_idel_dec_cpt_r 
              <=  #TCQ ((second_edge_taps_r -
                         first_edge_taps_r)>>1) + 1;
          else if (first_edge_taps_r <= 6'd31)
            cnt_idel_dec_cpt_r
		<=  #TCQ 6'd16;
          else if (first_edge_taps_r > 6'd31)
            cnt_idel_dec_cpt_r 
              <=  #TCQ (tap_cnt_cpt_r - (first_edge_taps_r - 30));
          else
            cnt_idel_dec_cpt_r 
              <=  #TCQ ((tap_cnt_cpt_r)>>1) + 1;
          cal1_state_r <= #TCQ CAL1_IDEL_DEC_CPT;  
        end
        CAL1_IDEL_DEC_CPT: begin
          cal1_dlyce_cpt_r  <= #TCQ 1'b1;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
          cnt_idel_dec_cpt_r <= #TCQ cnt_idel_dec_cpt_r - 1;
          if (cnt_idel_dec_cpt_r == 6'b000001)
            cal1_state_r <= #TCQ CAL1_NEXT_DQS;
          else
            cal1_state_r <= #TCQ CAL1_IDEL_DEC_CPT_WAIT;
        end
        CAL1_IDEL_DEC_CPT_WAIT: begin
          cal1_dlyce_cpt_r  <= #TCQ 1'b0;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
          cal1_state_r <= #TCQ CAL1_IDEL_DEC_CPT;
        end
        CAL1_NEXT_DQS: begin
          cal1_prech_req_r  <= #TCQ 1'b1;
          found_first_edge_r  <= #TCQ 1'b0;
          found_second_edge_r <= #TCQ 1'b0;
          first_edge_taps_r <= #TCQ 'd0;
          second_edge_taps_r <= #TCQ 'd0;
          if (prech_done) begin
            if (SIM_CAL_OPTION == "FAST_CAL") begin
              cal1_state_r <= #TCQ CAL1_REGL_LOAD;
            end else if (cal1_cnt_cpt_r >= DQS_WIDTH-1) begin
              rdlvl_rank_done_r <= #TCQ 1'b1;
              if (rnk_cnt_r == RANKS-1) begin
                cal1_state_r <= #TCQ CAL1_REGL_LOAD;
              end else begin
                rnk_cnt_r      <= #TCQ rnk_cnt_r + 1;
                new_cnt_cpt_r  <= #TCQ 1'b1;
                cal1_cnt_cpt_r <= #TCQ 'b0;
                cal1_state_r   <= #TCQ CAL1_NEW_DQS_WAIT;
              end         
            end else begin
              new_cnt_cpt_r  <= #TCQ 1'b1;
              cal1_cnt_cpt_r <= #TCQ cal1_cnt_cpt_r + 1;
              cal1_state_r   <= #TCQ CAL1_NEW_DQS_WAIT;
            end
          end
        end
        CAL1_REGL_LOAD: begin
          rdlvl_rank_done_r <= #TCQ 1'b0;
          rnk_cnt_r         <= #TCQ 2'b00;
          if ((regl_rank_cnt == RANKS-1) && 
              ((regl_dqs_cnt == DQS_WIDTH-1) && (done_cnt == 4'd1)))
            cal1_state_r <= #TCQ CAL1_DONE;
          else
            cal1_state_r <= #TCQ CAL1_REGL_LOAD;
        end
        CAL1_DONE: begin
          rdlvl_stg1_done   <= #TCQ 1'b1;
        end
      endcase
    end
endmodule
