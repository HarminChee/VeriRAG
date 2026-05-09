`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v2_0_ddr_phy_wrcal #
  (
   parameter TCQ             = 100,    
   parameter nCK_PER_CLK     = 2,      
   parameter CLK_PERIOD      = 2500,
   parameter DQ_WIDTH        = 64,     
   parameter DQS_CNT_WIDTH   = 3,      
   parameter DQS_WIDTH       = 8,      
   parameter DRAM_WIDTH      = 8,      
   parameter PRE_REV3ES      = "OFF",  
   parameter SIM_CAL_OPTION  = "NONE"  
   )
  (
   input                        clk,
   input                        rst,
   input                        wrcal_start,
   input                        wrcal_rd_wait,
   input                        wrcal_sanity_chk,
   input                        dqsfound_retry_done,
   input                        phy_rddata_en,
   output                       dqsfound_retry,
   output                       wrcal_read_req,
   output reg                   wrcal_act_req,
   output reg                   wrcal_done,
   output reg                   wrcal_pat_err,
   output reg                   wrcal_prech_req,
   output reg                   temp_wrcal_done,
   output reg                   wrcal_sanity_chk_done,
   input                        prech_done,
   input [2*nCK_PER_CLK*DQ_WIDTH-1:0] rd_data,
   input [3*DQS_WIDTH-1:0]      wl_po_coarse_cnt,
   input [6*DQS_WIDTH-1:0]      wl_po_fine_cnt,
   input                        wrlvl_byte_done,
   output reg                   wrlvl_byte_redo,
   output reg                   early1_data,
   output reg                   early2_data,
   output reg                   idelay_ld,
   output reg                   wrcal_pat_resume,   
   output reg [DQS_CNT_WIDTH:0] po_stg2_wrcal_cnt,
   output                       phy_if_reset,
   output [6*DQS_WIDTH-1:0]     dbg_final_po_fine_tap_cnt,
   output [3*DQS_WIDTH-1:0]     dbg_final_po_coarse_tap_cnt, 
   output [99:0]                dbg_phy_wrcal
   );
  localparam RD_SHIFT_LEN = 1; 
  localparam NUM_READS = 2;
  localparam RDEN_WAIT_CNT = 12;
  localparam  COARSE_CNT = (CLK_PERIOD/nCK_PER_CLK <= 2500) ? 3 : 6;
  localparam  FINE_CNT   = (CLK_PERIOD/nCK_PER_CLK <= 2500) ? 22 : 44;
  localparam CAL2_IDLE            = 4'h0;
  localparam CAL2_READ_WAIT       = 4'h1;
  localparam CAL2_NEXT_DQS        = 4'h2;
  localparam CAL2_WRLVL_WAIT      = 4'h3;
  localparam CAL2_IFIFO_RESET     = 4'h4;
  localparam CAL2_DQ_IDEL_DEC     = 4'h5;
  localparam CAL2_DONE            = 4'h6;
  localparam CAL2_SANITY_WAIT     = 4'h7;
  localparam CAL2_ERR             = 4'h8;
  integer                 i,j,k,l,m,p,q,d;
  reg [2:0]               po_coarse_tap_cnt [0:DQS_WIDTH-1];
  reg [3*DQS_WIDTH-1:0]   po_coarse_tap_cnt_w;
  reg [5:0]               po_fine_tap_cnt [0:DQS_WIDTH-1];
  reg [6*DQS_WIDTH-1:0]   po_fine_tap_cnt_w;
 reg [DQS_CNT_WIDTH:0] wrcal_dqs_cnt_r;
  reg [4:0]               not_empty_wait_cnt;
  reg [3:0]               tap_inc_wait_cnt;
  reg                     cal2_done_r;
  reg                     cal2_done_r1;
  reg                     cal2_prech_req_r;
  reg [3:0]               cal2_state_r;
  reg [3:0]               cal2_state_r1;
  reg [2:0]               wl_po_coarse_cnt_w [0:DQS_WIDTH-1];
  reg [5:0]               wl_po_fine_cnt_w [0:DQS_WIDTH-1];
  reg                     cal2_if_reset;
  reg                     wrcal_pat_resume_r;
  reg                     wrcal_pat_resume_r1;
  reg                     wrcal_pat_resume_r2;
  reg                     wrcal_pat_resume_r3;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall0_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall1_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise0_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise1_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall2_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall3_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise2_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise3_r;
  reg                     pat_data_match_r;
  reg                     pat1_data_match_r;
  reg                     pat1_data_match_r1;
  reg                     pat2_data_match_r;
  reg                     pat_data_match_valid_r;
  wire [RD_SHIFT_LEN-1:0] pat_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_fall1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_fall2 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_fall3 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_fall1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat2_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat2_fall1 [3:0];
  wire [RD_SHIFT_LEN-1:0] early_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] early_fall1 [3:0];
  wire [RD_SHIFT_LEN-1:0] early_fall2 [3:0];
  wire [RD_SHIFT_LEN-1:0] early_fall3 [3:0];
  wire [RD_SHIFT_LEN-1:0] early1_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] early1_fall1 [3:0];
  wire [RD_SHIFT_LEN-1:0] early2_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] early2_fall1 [3:0];
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
  reg [DRAM_WIDTH-1:0]    pat1_match_rise0_r;
  reg [DRAM_WIDTH-1:0]    pat1_match_rise1_r;
  reg [DRAM_WIDTH-1:0]    pat1_match_fall0_r;
  reg [DRAM_WIDTH-1:0]    pat1_match_fall1_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_rise0_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_rise1_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_fall0_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_fall1_r;
  reg                     pat1_match_rise0_and_r;
  reg                     pat1_match_rise1_and_r;
  reg                     pat1_match_fall0_and_r;
  reg                     pat1_match_fall1_and_r;
  reg                     pat2_match_rise0_and_r;
  reg                     pat2_match_rise1_and_r;
  reg                     pat2_match_fall0_and_r;
  reg                     pat2_match_fall1_and_r;
  reg                     early1_data_match_r;
  reg                     early1_data_match_r1;
  reg [DRAM_WIDTH-1:0]    early1_match_fall0_r;
  reg                     early1_match_fall0_and_r;
  reg [DRAM_WIDTH-1:0]    early1_match_fall1_r;
  reg                     early1_match_fall1_and_r;
  reg [DRAM_WIDTH-1:0]    early1_match_fall2_r;
  reg                     early1_match_fall2_and_r;
  reg [DRAM_WIDTH-1:0]    early1_match_fall3_r;
  reg                     early1_match_fall3_and_r;
  reg [DRAM_WIDTH-1:0]    early1_match_rise0_r;
  reg                     early1_match_rise0_and_r;
  reg [DRAM_WIDTH-1:0]    early1_match_rise1_r;
  reg                     early1_match_rise1_and_r;
  reg [DRAM_WIDTH-1:0]    early1_match_rise2_r;
  reg                     early1_match_rise2_and_r;
  reg [DRAM_WIDTH-1:0]    early1_match_rise3_r;
  reg                     early1_match_rise3_and_r;
  reg                     early2_data_match_r;
  reg [DRAM_WIDTH-1:0]    early2_match_fall0_r;
  reg                     early2_match_fall0_and_r;
  reg [DRAM_WIDTH-1:0]    early2_match_fall1_r;
  reg                     early2_match_fall1_and_r;
  reg [DRAM_WIDTH-1:0]    early2_match_fall2_r;
  reg                     early2_match_fall2_and_r;
  reg [DRAM_WIDTH-1:0]    early2_match_fall3_r;
  reg                     early2_match_fall3_and_r;
  reg [DRAM_WIDTH-1:0]    early2_match_rise0_r;
  reg                     early2_match_rise0_and_r;
  reg [DRAM_WIDTH-1:0]    early2_match_rise1_r;
  reg                     early2_match_rise1_and_r;
  reg [DRAM_WIDTH-1:0]    early2_match_rise2_r;
  reg                     early2_match_rise2_and_r;
  reg [DRAM_WIDTH-1:0]    early2_match_rise3_r;
  reg                     early2_match_rise3_and_r;    
  wire [RD_SHIFT_LEN-1:0] pat_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_rise1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_rise2 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_rise3 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_rise1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat2_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat2_rise1 [3:0];
  wire [RD_SHIFT_LEN-1:0] early_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] early_rise1 [3:0];
  wire [RD_SHIFT_LEN-1:0] early_rise2 [3:0];
  wire [RD_SHIFT_LEN-1:0] early_rise3 [3:0];
  wire [RD_SHIFT_LEN-1:0] early1_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] early1_rise1 [3:0];
  wire [RD_SHIFT_LEN-1:0] early2_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] early2_rise1 [3:0];
  wire [DQ_WIDTH-1:0]     rd_data_rise0;  
  wire [DQ_WIDTH-1:0]     rd_data_fall0;
  wire [DQ_WIDTH-1:0]     rd_data_rise1;
  wire [DQ_WIDTH-1:0]     rd_data_fall1;
  wire [DQ_WIDTH-1:0]     rd_data_rise2;
  wire [DQ_WIDTH-1:0]     rd_data_fall2;
  wire [DQ_WIDTH-1:0]     rd_data_rise3;
  wire [DQ_WIDTH-1:0]     rd_data_fall3;
  reg [DQS_CNT_WIDTH:0]   rd_mux_sel_r;
  reg                     rd_active_posedge_r;
  reg                     rd_active_r;
  reg                     rd_active_r1;
  reg                     rd_active_r2;
  reg                     rd_active_r3;
  reg                     rd_active_r4;
  reg                     rd_active_r5;
  reg [RD_SHIFT_LEN-1:0]  sr_fall0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_fall1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_fall2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_fall3_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise3_r [DRAM_WIDTH-1:0];
  reg                     wrlvl_byte_done_r;
  reg                     idelay_ld_done;
  reg                     pat1_detect;
  reg                     early1_detect;
  reg                     wrcal_sanity_chk_r;
  reg                     wrcal_sanity_chk_err;
  always @(*) begin
    for (d = 0; d < DQS_WIDTH; d = d + 1) begin
      po_fine_tap_cnt_w[(6*d)+:6]   = po_fine_tap_cnt[d];
      po_coarse_tap_cnt_w[(3*d)+:3] = po_coarse_tap_cnt[d];
    end
  end
  assign dbg_final_po_fine_tap_cnt   = po_fine_tap_cnt_w;
  assign dbg_final_po_coarse_tap_cnt = po_coarse_tap_cnt_w;
  assign dbg_phy_wrcal[0]    = pat_data_match_r;
  assign dbg_phy_wrcal[4:1]  = cal2_state_r1[3:0];
  assign dbg_phy_wrcal[5]    = wrcal_sanity_chk_err;
  assign dbg_phy_wrcal[6]    = wrcal_start;
  assign dbg_phy_wrcal[7]    = wrcal_done;
  assign dbg_phy_wrcal[8]    = pat_data_match_valid_r;
  assign dbg_phy_wrcal[13+:DQS_CNT_WIDTH]= wrcal_dqs_cnt_r;
  assign dbg_phy_wrcal[17+:5]  = not_empty_wait_cnt; 
  assign dbg_phy_wrcal[22]     = early1_data; 
  assign dbg_phy_wrcal[23]     = early2_data; 
  assign dbg_phy_wrcal[24+:8]     = mux_rd_rise0_r; 
  assign dbg_phy_wrcal[32+:8]     = mux_rd_fall0_r; 
  assign dbg_phy_wrcal[40+:8]     = mux_rd_rise1_r; 
  assign dbg_phy_wrcal[48+:8]     = mux_rd_fall1_r; 
  assign dbg_phy_wrcal[56+:8]     = mux_rd_rise2_r; 
  assign dbg_phy_wrcal[64+:8]     = mux_rd_fall2_r; 
  assign dbg_phy_wrcal[72+:8]     = mux_rd_rise3_r; 
  assign dbg_phy_wrcal[80+:8]     = mux_rd_fall3_r; 
  assign dbg_phy_wrcal[88]     = early1_data_match_r; 
  assign dbg_phy_wrcal[89]     = early2_data_match_r; 
  assign dbg_phy_wrcal[90]     = wrcal_sanity_chk_r & pat_data_match_valid_r; 
  assign dbg_phy_wrcal[91]     = wrcal_sanity_chk_r; 
  assign dbg_phy_wrcal[92]     = wrcal_sanity_chk_done; 
  assign dqsfound_retry        = 1'b0;
  assign wrcal_read_req        = 1'b0;
  assign phy_if_reset          = cal2_if_reset;
   always @(posedge clk) begin
     po_stg2_wrcal_cnt  <= #TCQ wrcal_dqs_cnt_r;
     wrlvl_byte_done_r  <= #TCQ wrlvl_byte_done;
	 wrcal_sanity_chk_r <= #TCQ wrcal_sanity_chk;
   end
  generate
    if (nCK_PER_CLK == 4) begin: gen_rd_data_div4
      assign rd_data_rise0 = rd_data[DQ_WIDTH-1:0];
      assign rd_data_fall0 = rd_data[2*DQ_WIDTH-1:DQ_WIDTH];
      assign rd_data_rise1 = rd_data[3*DQ_WIDTH-1:2*DQ_WIDTH];
      assign rd_data_fall1 = rd_data[4*DQ_WIDTH-1:3*DQ_WIDTH];
      assign rd_data_rise2 = rd_data[5*DQ_WIDTH-1:4*DQ_WIDTH];
      assign rd_data_fall2 = rd_data[6*DQ_WIDTH-1:5*DQ_WIDTH];
      assign rd_data_rise3 = rd_data[7*DQ_WIDTH-1:6*DQ_WIDTH];
      assign rd_data_fall3 = rd_data[8*DQ_WIDTH-1:7*DQ_WIDTH];
    end else if (nCK_PER_CLK == 2) begin: gen_rd_data_div2
      assign rd_data_rise0 = rd_data[DQ_WIDTH-1:0];
      assign rd_data_fall0 = rd_data[2*DQ_WIDTH-1:DQ_WIDTH];
      assign rd_data_rise1 = rd_data[3*DQ_WIDTH-1:2*DQ_WIDTH];
      assign rd_data_fall1 = rd_data[4*DQ_WIDTH-1:3*DQ_WIDTH];
    end
  endgenerate
  always @(*) begin
    for (m = 0; m < DQS_WIDTH; m = m + 1) begin
      wl_po_coarse_cnt_w[m] = wl_po_coarse_cnt[3*m+:3];
      wl_po_fine_cnt_w[m]   = wl_po_fine_cnt[6*m+:6];
    end
  end
  always @(posedge clk) begin
    if (rst) begin
      for (p = 0; p < DQS_WIDTH; p = p + 1) begin
        po_coarse_tap_cnt[p] <= #TCQ {3{1'b0}};
        po_fine_tap_cnt[p]   <= #TCQ {6{1'b0}};
      end
    end else if (cal2_done_r && ~cal2_done_r1) begin
      for (q = 0; q < DQS_WIDTH; q = q + 1) begin
        po_coarse_tap_cnt[q] <= #TCQ wl_po_coarse_cnt_w[i];
        po_fine_tap_cnt[q]   <= #TCQ wl_po_fine_cnt_w[i]; 
      end
    end
  end
  always @(posedge clk) begin
    rd_mux_sel_r <= #TCQ wrcal_dqs_cnt_r;
  end
  generate
    genvar mux_i;
    if (nCK_PER_CLK == 4) begin: gen_mux_rd_div4
      for (mux_i = 0; mux_i < DRAM_WIDTH; mux_i = mux_i + 1) begin: gen_mux_rd
        always @(posedge clk) begin
          mux_rd_rise0_r[mux_i] <= #TCQ rd_data_rise0[DRAM_WIDTH*rd_mux_sel_r + mux_i];
          mux_rd_fall0_r[mux_i] <= #TCQ rd_data_fall0[DRAM_WIDTH*rd_mux_sel_r + mux_i];
          mux_rd_rise1_r[mux_i] <= #TCQ rd_data_rise1[DRAM_WIDTH*rd_mux_sel_r + mux_i];
          mux_rd_fall1_r[mux_i] <= #TCQ rd_data_fall1[DRAM_WIDTH*rd_mux_sel_r + mux_i];
          mux_rd_rise2_r[mux_i] <= #TCQ rd_data_rise2[DRAM_WIDTH*rd_mux_sel_r + mux_i];
          mux_rd_fall2_r[mux_i] <= #TCQ rd_data_fall2[DRAM_WIDTH*rd_mux_sel_r + mux_i];
          mux_rd_rise3_r[mux_i] <= #TCQ rd_data_rise3[DRAM_WIDTH*rd_mux_sel_r + mux_i];
          mux_rd_fall3_r[mux_i] <= #TCQ rd_data_fall3[DRAM_WIDTH*rd_mux_sel_r + mux_i];
        end
      end
    end else if (nCK_PER_CLK == 2) begin: gen_mux_rd_div2 
      for (mux_i = 0; mux_i < DRAM_WIDTH; mux_i = mux_i + 1) begin: gen_mux_rd
        always @(posedge clk) begin
          mux_rd_rise0_r[mux_i] <= #TCQ rd_data_rise0[DRAM_WIDTH*rd_mux_sel_r + mux_i];
          mux_rd_fall0_r[mux_i] <= #TCQ rd_data_fall0[DRAM_WIDTH*rd_mux_sel_r + mux_i];
          mux_rd_rise1_r[mux_i] <= #TCQ rd_data_rise1[DRAM_WIDTH*rd_mux_sel_r + mux_i];
          mux_rd_fall1_r[mux_i] <= #TCQ rd_data_fall1[DRAM_WIDTH*rd_mux_sel_r + mux_i];
        end
      end
    end
  endgenerate
  always @(posedge clk)
    if (rst)
      wrcal_prech_req <= #TCQ 1'b0;
    else
      wrcal_prech_req <= #TCQ cal2_prech_req_r;
  generate
    genvar rd_i;
    if (nCK_PER_CLK == 4) begin: gen_sr_div4
      for (rd_i = 0; rd_i < DRAM_WIDTH; rd_i = rd_i + 1) begin: gen_sr
        always @(posedge clk) begin
          sr_rise0_r[rd_i] <= #TCQ mux_rd_rise0_r[rd_i];
          sr_fall0_r[rd_i] <= #TCQ mux_rd_fall0_r[rd_i];
          sr_rise1_r[rd_i] <= #TCQ mux_rd_rise1_r[rd_i];
          sr_fall1_r[rd_i] <= #TCQ mux_rd_fall1_r[rd_i];
          sr_rise2_r[rd_i] <= #TCQ mux_rd_rise2_r[rd_i];
          sr_fall2_r[rd_i] <= #TCQ mux_rd_fall2_r[rd_i];
          sr_rise3_r[rd_i] <= #TCQ mux_rd_rise3_r[rd_i];
          sr_fall3_r[rd_i] <= #TCQ mux_rd_fall3_r[rd_i];
        end
      end    
    end else if (nCK_PER_CLK == 2) begin: gen_sr_div2
      for (rd_i = 0; rd_i < DRAM_WIDTH; rd_i = rd_i + 1) begin: gen_sr
        always @(posedge clk) begin
          sr_rise0_r[rd_i] <= #TCQ mux_rd_rise0_r[rd_i]; 
          sr_fall0_r[rd_i] <= #TCQ mux_rd_fall0_r[rd_i];
          sr_rise1_r[rd_i] <= #TCQ mux_rd_rise1_r[rd_i];
          sr_fall1_r[rd_i] <= #TCQ mux_rd_fall1_r[rd_i];
        end
      end
    end
  endgenerate
  always @(posedge clk) begin
    rd_active_r         <= #TCQ phy_rddata_en;
    rd_active_r1        <= #TCQ rd_active_r;
    rd_active_r2        <= #TCQ rd_active_r1;
    rd_active_r3        <= #TCQ rd_active_r2;
    rd_active_r4        <= #TCQ rd_active_r3;
    rd_active_r5        <= #TCQ rd_active_r4;      
  end
  generate
    if (nCK_PER_CLK == 4) begin: gen_pat_div4
      assign pat_rise0[3] = 1'b1;
      assign pat_fall0[3] = 1'b0;
      assign pat_rise1[3] = 1'b1;
      assign pat_fall1[3] = 1'b0;
      assign pat_rise2[3] = 1'b0;
      assign pat_fall2[3] = 1'b1;
      assign pat_rise3[3] = 1'b1;
      assign pat_fall3[3] = 1'b0;
      assign pat_rise0[2] = 1'b1;
      assign pat_fall0[2] = 1'b0;
      assign pat_rise1[2] = 1'b0;
      assign pat_fall1[2] = 1'b1;
      assign pat_rise2[2] = 1'b1;
      assign pat_fall2[2] = 1'b0;
      assign pat_rise3[2] = 1'b0;
      assign pat_fall3[2] = 1'b1;
      assign pat_rise0[1] = 1'b1;
      assign pat_fall0[1] = 1'b0;
      assign pat_rise1[1] = 1'b1;
      assign pat_fall1[1] = 1'b0;
      assign pat_rise2[1] = 1'b0;
      assign pat_fall2[1] = 1'b1;
      assign pat_rise3[1] = 1'b0;
      assign pat_fall3[1] = 1'b1;
      assign pat_rise0[0] = 1'b1;
      assign pat_fall0[0] = 1'b0;
      assign pat_rise1[0] = 1'b0;
      assign pat_fall1[0] = 1'b1;
      assign pat_rise2[0] = 1'b1;
      assign pat_fall2[0] = 1'b0;
      assign pat_rise3[0] = 1'b1;
      assign pat_fall3[0] = 1'b0;
      assign early_rise0[3] = 1'b1;
      assign early_fall0[3] = 1'b0;
      assign early_rise1[3] = 1'b1;
      assign early_fall1[3] = 1'b0;
      assign early_rise2[3] = 1'b0;
      assign early_fall2[3] = 1'b1;
      assign early_rise3[3] = 1'b1;
      assign early_fall3[3] = 1'b1;
      assign early_rise0[2] = 1'b0;
      assign early_fall0[2] = 1'b0;
      assign early_rise1[2] = 1'b1;
      assign early_fall1[2] = 1'b1;
      assign early_rise2[2] = 1'b1;
      assign early_fall2[2] = 1'b1;
      assign early_rise3[2] = 1'b1;
      assign early_fall3[2] = 1'b0;
      assign early_rise0[1] = 1'b1;
      assign early_fall0[1] = 1'b0;
      assign early_rise1[1] = 1'b1;
      assign early_fall1[1] = 1'b0;
      assign early_rise2[1] = 1'b0;
      assign early_fall2[1] = 1'b1;
      assign early_rise3[1] = 1'b0;
      assign early_fall3[1] = 1'b0;
      assign early_rise0[0] = 1'b1;
      assign early_fall0[0] = 1'b1;
      assign early_rise1[0] = 1'b0;
      assign early_fall1[0] = 1'b0;
      assign early_rise2[0] = 1'b0;
      assign early_fall2[0] = 1'b0;
      assign early_rise3[0] = 1'b1;
      assign early_fall3[0] = 1'b0;
    end else if (nCK_PER_CLK == 2) begin: gen_pat_div2
      assign pat1_rise0[3] = 1'b1;
      assign pat1_fall0[3] = 1'b0;
      assign pat1_rise1[3] = 1'b1;
      assign pat1_fall1[3] = 1'b0;
      assign pat1_rise0[2] = 1'b1;
      assign pat1_fall0[2] = 1'b0;
      assign pat1_rise1[2] = 1'b0;
      assign pat1_fall1[2] = 1'b1;
      assign pat1_rise0[1] = 1'b1;
      assign pat1_fall0[1] = 1'b0;
      assign pat1_rise1[1] = 1'b1;
      assign pat1_fall1[1] = 1'b0;
      assign pat1_rise0[0] = 1'b1;
      assign pat1_fall0[0] = 1'b0;
      assign pat1_rise1[0] = 1'b0;
      assign pat1_fall1[0] = 1'b1;
      assign pat2_rise0[3] = 1'b0;
      assign pat2_fall0[3] = 1'b1;
      assign pat2_rise1[3] = 1'b1;
      assign pat2_fall1[3] = 1'b0;
      assign pat2_rise0[2] = 1'b1;
      assign pat2_fall0[2] = 1'b0;
      assign pat2_rise1[2] = 1'b0;
      assign pat2_fall1[2] = 1'b1;
      assign pat2_rise0[1] = 1'b0;
      assign pat2_fall0[1] = 1'b1;
      assign pat2_rise1[1] = 1'b0;
      assign pat2_fall1[1] = 1'b1;
      assign pat2_rise0[0] = 1'b1;
      assign pat2_fall0[0] = 1'b0;
      assign pat2_rise1[0] = 1'b1;
      assign pat2_fall1[0] = 1'b0;
      assign early1_rise0[3] = 2'b1;
      assign early1_fall0[3] = 2'b0;
      assign early1_rise1[3] = 2'b0;
      assign early1_fall1[3] = 2'b1;
      assign early1_rise0[2] = 2'b0;
      assign early1_fall0[2] = 2'b1;
      assign early1_rise1[2] = 2'b1;
      assign early1_fall1[2] = 2'b0;
      assign early1_rise0[1] = 2'b1;
      assign early1_fall0[1] = 2'b0;
      assign early1_rise1[1] = 2'b0;
      assign early1_fall1[1] = 2'b1;
      assign early1_rise0[0] = 2'b0;
      assign early1_fall0[0] = 2'b1;
      assign early1_rise1[0] = 2'b1;
      assign early1_fall1[0] = 2'b0;
      assign early2_rise0[3] = 2'b1;
      assign early2_fall0[3] = 2'b0;
      assign early2_rise1[3] = 2'b1;
      assign early2_fall1[3] = 2'b0;
      assign early2_rise0[2] = 2'b0;
      assign early2_fall0[2] = 2'b1;
      assign early2_rise1[2] = 2'b0;
      assign early2_fall1[2] = 2'b0;
      assign early2_rise0[1] = 2'b0;
      assign early2_fall0[1] = 2'b1;
      assign early2_rise1[1] = 2'b1;
      assign early2_fall1[1] = 2'b0;
      assign early2_rise0[0] = 2'b1;
      assign early2_fall0[0] = 2'b0;
      assign early2_rise1[0] = 2'b1;
      assign early2_fall1[0] = 2'b1;
    end
  endgenerate
  generate
    genvar pt_i;
    if (nCK_PER_CLK == 4) begin: gen_pat_match_div4
      for (pt_i = 0; pt_i < DRAM_WIDTH; pt_i = pt_i + 1) begin: gen_pat_match
        always @(posedge clk) begin
          if (sr_rise0_r[pt_i] == pat_rise0[pt_i%4])
            pat_match_rise0_r[pt_i] <= #TCQ 1'b1;
          else
            pat_match_rise0_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall0_r[pt_i] == pat_fall0[pt_i%4])
            pat_match_fall0_r[pt_i] <= #TCQ 1'b1;
          else
            pat_match_fall0_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise1_r[pt_i] == pat_rise1[pt_i%4])
            pat_match_rise1_r[pt_i] <= #TCQ 1'b1;
          else
            pat_match_rise1_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall1_r[pt_i] == pat_fall1[pt_i%4])
            pat_match_fall1_r[pt_i] <= #TCQ 1'b1;
          else
            pat_match_fall1_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise2_r[pt_i] == pat_rise2[pt_i%4])
            pat_match_rise2_r[pt_i] <= #TCQ 1'b1;
          else
            pat_match_rise2_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall2_r[pt_i] == pat_fall2[pt_i%4])
            pat_match_fall2_r[pt_i] <= #TCQ 1'b1;
          else
            pat_match_fall2_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise3_r[pt_i] == pat_rise3[pt_i%4])
            pat_match_rise3_r[pt_i] <= #TCQ 1'b1;
          else
            pat_match_rise3_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall3_r[pt_i] == pat_fall3[pt_i%4])
            pat_match_fall3_r[pt_i] <= #TCQ 1'b1;
          else
            pat_match_fall3_r[pt_i] <= #TCQ 1'b0;
        end
        always @(posedge clk) begin
          if (sr_rise0_r[pt_i] == pat_rise1[pt_i%4])
            early1_match_rise0_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_rise0_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall0_r[pt_i] == pat_fall1[pt_i%4])
            early1_match_fall0_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_fall0_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise1_r[pt_i] == pat_rise2[pt_i%4])
            early1_match_rise1_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_rise1_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall1_r[pt_i] == pat_fall2[pt_i%4])
            early1_match_fall1_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_fall1_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise2_r[pt_i] == pat_rise3[pt_i%4])
            early1_match_rise2_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_rise2_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall2_r[pt_i] == pat_fall3[pt_i%4])
            early1_match_fall2_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_fall2_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise3_r[pt_i] == early_rise0[pt_i%4])
            early1_match_rise3_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_rise3_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall3_r[pt_i] == early_fall0[pt_i%4])
            early1_match_fall3_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_fall3_r[pt_i] <= #TCQ 1'b0;
        end
        always @(posedge clk) begin
          if (sr_rise0_r[pt_i] == pat_rise2[pt_i%4])
            early2_match_rise0_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_rise0_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall0_r[pt_i] == pat_fall2[pt_i%4])
            early2_match_fall0_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_fall0_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise1_r[pt_i] == pat_rise3[pt_i%4])
            early2_match_rise1_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_rise1_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall1_r[pt_i] == pat_fall3[pt_i%4])
            early2_match_fall1_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_fall1_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise2_r[pt_i] == early_rise0[pt_i%4])
            early2_match_rise2_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_rise2_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall2_r[pt_i] == early_fall0[pt_i%4])
            early2_match_fall2_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_fall2_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise3_r[pt_i] == early_rise1[pt_i%4])
            early2_match_rise3_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_rise3_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall3_r[pt_i] == early_fall1[pt_i%4])
            early2_match_fall3_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_fall3_r[pt_i] <= #TCQ 1'b0;
        end        
      end
       always @(posedge clk) begin
         pat_match_rise0_and_r <= #TCQ &pat_match_rise0_r;
         pat_match_fall0_and_r <= #TCQ &pat_match_fall0_r;
         pat_match_rise1_and_r <= #TCQ &pat_match_rise1_r;
         pat_match_fall1_and_r <= #TCQ &pat_match_fall1_r;
         pat_match_rise2_and_r <= #TCQ &pat_match_rise2_r;
         pat_match_fall2_and_r <= #TCQ &pat_match_fall2_r;
         pat_match_rise3_and_r <= #TCQ &pat_match_rise3_r;
         pat_match_fall3_and_r <= #TCQ &pat_match_fall3_r;
         pat_data_match_r <= #TCQ (pat_match_rise0_and_r &&
                                   pat_match_fall0_and_r &&
                                   pat_match_rise1_and_r &&
                                   pat_match_fall1_and_r &&
                                   pat_match_rise2_and_r &&
                                   pat_match_fall2_and_r &&
                                   pat_match_rise3_and_r &&
                                   pat_match_fall3_and_r);
         pat_data_match_valid_r <= #TCQ rd_active_r3;
       end
       always @(posedge clk) begin
         early1_match_rise0_and_r <= #TCQ &early1_match_rise0_r;
         early1_match_fall0_and_r <= #TCQ &early1_match_fall0_r;
         early1_match_rise1_and_r <= #TCQ &early1_match_rise1_r;
         early1_match_fall1_and_r <= #TCQ &early1_match_fall1_r;
         early1_match_rise2_and_r <= #TCQ &early1_match_rise2_r;
         early1_match_fall2_and_r <= #TCQ &early1_match_fall2_r;
         early1_match_rise3_and_r <= #TCQ &early1_match_rise3_r;
         early1_match_fall3_and_r <= #TCQ &early1_match_fall3_r;
         early1_data_match_r <= #TCQ (early1_match_rise0_and_r &&
                                   early1_match_fall0_and_r &&
                                   early1_match_rise1_and_r &&
                                   early1_match_fall1_and_r &&
                                   early1_match_rise2_and_r &&
                                   early1_match_fall2_and_r &&
                                   early1_match_rise3_and_r &&
                                   early1_match_fall3_and_r);
       end
       always @(posedge clk) begin
         early2_match_rise0_and_r <= #TCQ &early2_match_rise0_r;
         early2_match_fall0_and_r <= #TCQ &early2_match_fall0_r;
         early2_match_rise1_and_r <= #TCQ &early2_match_rise1_r;
         early2_match_fall1_and_r <= #TCQ &early2_match_fall1_r;
         early2_match_rise2_and_r <= #TCQ &early2_match_rise2_r;
         early2_match_fall2_and_r <= #TCQ &early2_match_fall2_r;
         early2_match_rise3_and_r <= #TCQ &early2_match_rise3_r;
         early2_match_fall3_and_r <= #TCQ &early2_match_fall3_r;
         early2_data_match_r <= #TCQ (early2_match_rise0_and_r &&
                                   early2_match_fall0_and_r &&
                                   early2_match_rise1_and_r &&
                                   early2_match_fall1_and_r &&
                                   early2_match_rise2_and_r &&
                                   early2_match_fall2_and_r &&
                                   early2_match_rise3_and_r &&
                                   early2_match_fall3_and_r);
       end       
    end else if (nCK_PER_CLK == 2) begin: gen_pat_match_div2
      for (pt_i = 0; pt_i < DRAM_WIDTH; pt_i = pt_i + 1) begin: gen_pat_match
        always @(posedge clk) begin
          if (sr_rise0_r[pt_i] == pat1_rise0[pt_i%4])
            pat1_match_rise0_r[pt_i] <= #TCQ 1'b1;
          else
            pat1_match_rise0_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall0_r[pt_i] == pat1_fall0[pt_i%4])
            pat1_match_fall0_r[pt_i] <= #TCQ 1'b1;
          else
            pat1_match_fall0_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise1_r[pt_i] == pat1_rise1[pt_i%4])
            pat1_match_rise1_r[pt_i] <= #TCQ 1'b1;
          else
            pat1_match_rise1_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall1_r[pt_i] == pat1_fall1[pt_i%4])
            pat1_match_fall1_r[pt_i] <= #TCQ 1'b1;
          else
            pat1_match_fall1_r[pt_i] <= #TCQ 1'b0;
        end
        always @(posedge clk) begin
          if (sr_rise0_r[pt_i] == pat2_rise0[pt_i%4])
            pat2_match_rise0_r[pt_i] <= #TCQ 1'b1;
          else
            pat2_match_rise0_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall0_r[pt_i] == pat2_fall0[pt_i%4])
            pat2_match_fall0_r[pt_i] <= #TCQ 1'b1;
          else
            pat2_match_fall0_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise1_r[pt_i] == pat2_rise1[pt_i%4])
            pat2_match_rise1_r[pt_i] <= #TCQ 1'b1;
          else
            pat2_match_rise1_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall1_r[pt_i] == pat2_fall1[pt_i%4])
            pat2_match_fall1_r[pt_i] <= #TCQ 1'b1;
          else
            pat2_match_fall1_r[pt_i] <= #TCQ 1'b0;
        end
        always @(posedge clk) begin
          if (sr_rise0_r[pt_i] == early1_rise0[pt_i%4])
            early1_match_rise0_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_rise0_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall0_r[pt_i] == early1_fall0[pt_i%4])
            early1_match_fall0_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_fall0_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise1_r[pt_i] == early1_rise1[pt_i%4])
            early1_match_rise1_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_rise1_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall1_r[pt_i] == early1_fall1[pt_i%4])
            early1_match_fall1_r[pt_i] <= #TCQ 1'b1;
          else
            early1_match_fall1_r[pt_i] <= #TCQ 1'b0;
        end
        always @(posedge clk) begin
          if (sr_rise0_r[pt_i] == early2_rise0[pt_i%4])
            early2_match_rise0_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_rise0_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall0_r[pt_i] == early2_fall0[pt_i%4])
            early2_match_fall0_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_fall0_r[pt_i] <= #TCQ 1'b0;
          if (sr_rise1_r[pt_i] == early2_rise1[pt_i%4])
            early2_match_rise1_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_rise1_r[pt_i] <= #TCQ 1'b0;
          if (sr_fall1_r[pt_i] == early2_fall1[pt_i%4])
            early2_match_fall1_r[pt_i] <= #TCQ 1'b1;
          else
            early2_match_fall1_r[pt_i] <= #TCQ 1'b0;
        end
      end     
        always @(posedge clk) begin
          pat1_match_rise0_and_r <= #TCQ &pat1_match_rise0_r;
          pat1_match_fall0_and_r <= #TCQ &pat1_match_fall0_r;
          pat1_match_rise1_and_r <= #TCQ &pat1_match_rise1_r;
          pat1_match_fall1_and_r <= #TCQ &pat1_match_fall1_r;
          pat1_data_match_r <= #TCQ (pat1_match_rise0_and_r &&
                                    pat1_match_fall0_and_r &&
                                    pat1_match_rise1_and_r &&
                                    pat1_match_fall1_and_r);
          pat1_data_match_r1     <= #TCQ pat1_data_match_r;
          pat2_match_rise0_and_r <= #TCQ &pat2_match_rise0_r && rd_active_r3;
          pat2_match_fall0_and_r <= #TCQ &pat2_match_fall0_r && rd_active_r3;
          pat2_match_rise1_and_r <= #TCQ &pat2_match_rise1_r && rd_active_r3;
          pat2_match_fall1_and_r <= #TCQ &pat2_match_fall1_r && rd_active_r3;
          pat2_data_match_r <= #TCQ (pat2_match_rise0_and_r &&
                                    pat2_match_fall0_and_r &&
                                    pat2_match_rise1_and_r &&
                                    pat2_match_fall1_and_r);
          pat_data_match_valid_r <= #TCQ rd_active_r4 & ~rd_active_r5;
        end
        always @(posedge clk) begin
         early1_match_rise0_and_r <= #TCQ &early1_match_rise0_r;
         early1_match_fall0_and_r <= #TCQ &early1_match_fall0_r;
         early1_match_rise1_and_r <= #TCQ &early1_match_rise1_r;
         early1_match_fall1_and_r <= #TCQ &early1_match_fall1_r;
         early1_data_match_r <= #TCQ (early1_match_rise0_and_r &&
                                      early1_match_fall0_and_r &&
                                      early1_match_rise1_and_r &&
                                      early1_match_fall1_and_r);
         early1_data_match_r1 <= #TCQ early1_data_match_r;
         early2_match_rise0_and_r <= #TCQ &early2_match_rise0_r && rd_active_r3;
         early2_match_fall0_and_r <= #TCQ &early2_match_fall0_r && rd_active_r3;
         early2_match_rise1_and_r <= #TCQ &early2_match_rise1_r && rd_active_r3;
         early2_match_fall1_and_r <= #TCQ &early2_match_fall1_r && rd_active_r3;
         early2_data_match_r <= #TCQ (early2_match_rise0_and_r &&
                                      early2_match_fall0_and_r &&
                                      early2_match_rise1_and_r &&
                                      early2_match_fall1_and_r);
       end
    end
  endgenerate
  always @(posedge clk) begin
    wrcal_pat_resume_r1 <= #TCQ wrcal_pat_resume_r;
    wrcal_pat_resume_r2 <= #TCQ wrcal_pat_resume_r1;
    wrcal_pat_resume    <= #TCQ wrcal_pat_resume_r2;
  end
  always @(posedge clk) begin
    if (rst)
      tap_inc_wait_cnt <= #TCQ 'd0;
    else if ((cal2_state_r == CAL2_DQ_IDEL_DEC) ||
             (cal2_state_r == CAL2_IFIFO_RESET) ||
			 (cal2_state_r == CAL2_SANITY_WAIT))
      tap_inc_wait_cnt <= #TCQ tap_inc_wait_cnt + 1;
    else
      tap_inc_wait_cnt <= #TCQ 'd0;
  end
  always @(posedge clk) begin
    if (rst)
      not_empty_wait_cnt <= #TCQ 'd0;
    else if ((cal2_state_r == CAL2_READ_WAIT) && wrcal_rd_wait)
      not_empty_wait_cnt <= #TCQ not_empty_wait_cnt + 1;
    else
      not_empty_wait_cnt <= #TCQ 'd0;
  end
  always @(posedge clk)
    cal2_state_r1 <= #TCQ cal2_state_r;
  always @(posedge clk) begin
    if (rst) begin
      wrcal_dqs_cnt_r       <= #TCQ 'b0;
      cal2_done_r           <= #TCQ 1'b0;
      cal2_prech_req_r      <= #TCQ 1'b0;
      cal2_state_r          <= #TCQ CAL2_IDLE;
      wrcal_pat_err         <= #TCQ 1'b0;
      wrcal_pat_resume_r    <= #TCQ 1'b0;
      wrcal_act_req         <= #TCQ 1'b0;
      cal2_if_reset         <= #TCQ 1'b0;
      temp_wrcal_done       <= #TCQ 1'b0;
      wrlvl_byte_redo       <= #TCQ 1'b0;
      early1_data           <= #TCQ 1'b0;
      early2_data           <= #TCQ 1'b0;
      idelay_ld             <= #TCQ 1'b0;
      idelay_ld_done        <= #TCQ 1'b0;
      pat1_detect           <= #TCQ 1'b0;
      early1_detect         <= #TCQ 1'b0;
	  wrcal_sanity_chk_done <= #TCQ 1'b0;
      wrcal_sanity_chk_err  <= #TCQ 1'b0;
    end else begin
      cal2_prech_req_r <= #TCQ 1'b0;
      case (cal2_state_r)
        CAL2_IDLE: begin
          wrcal_pat_err         <= #TCQ 1'b0;
          if (wrcal_start) begin
            cal2_if_reset  <= #TCQ 1'b0;
            if (SIM_CAL_OPTION == "SKIP_CAL")
              cal2_state_r <= #TCQ CAL2_DONE;
            else
              cal2_state_r <= #TCQ CAL2_READ_WAIT;
          end
        end
        CAL2_READ_WAIT: begin
          wrcal_pat_resume_r <= #TCQ 1'b0;
          cal2_if_reset      <= #TCQ 1'b0;
          if (pat_data_match_valid_r && (nCK_PER_CLK == 4)) begin
            if (pat_data_match_r)
              cal2_state_r <= #TCQ CAL2_NEXT_DQS;
            else begin
			  if (wrcal_sanity_chk_r)
			    cal2_state_r <= #TCQ CAL2_ERR;
              else if (early1_data_match_r) begin
                early1_data <= #TCQ 1'b1;
                early2_data <= #TCQ 1'b0;
                wrlvl_byte_redo <= #TCQ 1'b1;
                cal2_state_r    <= #TCQ CAL2_WRLVL_WAIT;
              end else if (early2_data_match_r) begin
                early1_data <= #TCQ 1'b0;
                early2_data <= #TCQ 1'b1;
                wrlvl_byte_redo <= #TCQ 1'b1;
                cal2_state_r    <= #TCQ CAL2_WRLVL_WAIT;
              end else if (~idelay_ld_done) begin
                cal2_state_r <= #TCQ CAL2_DQ_IDEL_DEC;
                idelay_ld    <= #TCQ 1'b1;
              end else
                cal2_state_r <= #TCQ CAL2_ERR;                
            end
          end else if (pat_data_match_valid_r && (nCK_PER_CLK == 2)) begin
            if ((pat1_data_match_r1 && pat2_data_match_r) || 
                (pat1_detect && pat2_data_match_r))
              cal2_state_r <= #TCQ CAL2_NEXT_DQS;
            else if (pat1_data_match_r1 && ~pat2_data_match_r) begin
              cal2_state_r <= #TCQ CAL2_READ_WAIT;
              pat1_detect  <= #TCQ 1'b1;
            end else begin
              if (wrcal_sanity_chk_r)
			    cal2_state_r <= #TCQ CAL2_ERR;
              else if ((early1_data_match_r1 && early2_data_match_r) ||
                  (early1_detect && early2_data_match_r)) begin
                early1_data <= #TCQ 1'b1;
                early2_data <= #TCQ 1'b0;
                wrlvl_byte_redo <= #TCQ 1'b1;
                cal2_state_r    <= #TCQ CAL2_WRLVL_WAIT;
              end else if (early1_data_match_r1 && ~early2_data_match_r) begin
                early1_detect <= #TCQ 1'b1;
                cal2_state_r  <= #TCQ CAL2_READ_WAIT;
              end else if (~idelay_ld_done) begin
                cal2_state_r <= #TCQ CAL2_DQ_IDEL_DEC;
                idelay_ld    <= #TCQ 1'b1;
              end else
                cal2_state_r <= #TCQ CAL2_ERR;                
            end
          end else if (not_empty_wait_cnt == 'd31)
            cal2_state_r <= #TCQ CAL2_ERR;
        end
        CAL2_WRLVL_WAIT: begin
          early1_detect <= #TCQ 1'b0;
          if (wrlvl_byte_done && ~wrlvl_byte_done_r)
            wrlvl_byte_redo   <= #TCQ 1'b0;
          if (wrlvl_byte_done) begin
            if (rd_active_r1 && ~rd_active_r) begin
            cal2_state_r  <= #TCQ CAL2_IFIFO_RESET;
            cal2_if_reset <= #TCQ 1'b1;
            early1_data   <= #TCQ 1'b0;
            early2_data   <= #TCQ 1'b0;
          end
        end
        end
        CAL2_DQ_IDEL_DEC: begin
          if (tap_inc_wait_cnt == 'd4) begin
            idelay_ld      <= #TCQ 1'b0;
            cal2_state_r   <= #TCQ CAL2_IFIFO_RESET;
            cal2_if_reset  <= #TCQ 1'b1;
            idelay_ld_done <= #TCQ 1'b1;
          end
        end
        CAL2_IFIFO_RESET: begin
          if (tap_inc_wait_cnt == 'd15) begin
            cal2_if_reset      <= #TCQ 1'b0;
			if (wrcal_sanity_chk_r)
			  cal2_state_r       <= #TCQ CAL2_DONE;
            else if (idelay_ld_done) begin
              wrcal_pat_resume_r <= #TCQ 1'b1;
              cal2_state_r       <= #TCQ CAL2_READ_WAIT;
            end else
              cal2_state_r       <= #TCQ CAL2_IDLE;
          end
        end
        CAL2_NEXT_DQS: begin
          if (wrcal_sanity_chk_r && (wrcal_dqs_cnt_r != DQS_WIDTH-1)) begin
		    cal2_prech_req_r   <= #TCQ 1'b0;
			wrcal_dqs_cnt_r    <= #TCQ wrcal_dqs_cnt_r + 1;
            cal2_state_r       <= #TCQ CAL2_SANITY_WAIT;
		  end else
		    cal2_prech_req_r  <= #TCQ 1'b1;
          idelay_ld_done    <= #TCQ 1'b0;
          pat1_detect       <= #TCQ 1'b0;
          if (prech_done)
            if (((DQS_WIDTH == 1) || (SIM_CAL_OPTION == "FAST_CAL")) ||
                (wrcal_dqs_cnt_r == DQS_WIDTH-1)) begin
              if (wrcal_sanity_chk_r) begin
			    cal2_if_reset    <= #TCQ 1'b1;
				cal2_state_r     <= #TCQ CAL2_IFIFO_RESET;
			  end else
                cal2_state_r     <= #TCQ CAL2_DONE;
            end else begin
              wrcal_dqs_cnt_r    <= #TCQ wrcal_dqs_cnt_r + 1;
              cal2_state_r       <= #TCQ CAL2_READ_WAIT;
            end
        end
		CAL2_SANITY_WAIT: begin
		  if (tap_inc_wait_cnt == 'd15) begin
		    cal2_state_r       <= #TCQ CAL2_READ_WAIT;
			wrcal_pat_resume_r <= #TCQ 1'b1;
	      end
		end
        CAL2_DONE: begin
		  if (wrcal_sanity_chk && ~wrcal_sanity_chk_r) begin
		    cal2_done_r     <= #TCQ 1'b0;
			wrcal_dqs_cnt_r <= #TCQ 'd0;
			cal2_state_r    <= #TCQ CAL2_IDLE;
		  end else
            cal2_done_r      <= #TCQ 1'b1;
            cal2_prech_req_r <= #TCQ 1'b0;
            cal2_if_reset    <= #TCQ 1'b0;
			if (wrcal_sanity_chk_r)
			  wrcal_sanity_chk_done <= #TCQ 1'b1;
        end
        CAL2_ERR: begin
          wrcal_pat_resume_r <= #TCQ 1'b0;
          if (wrcal_sanity_chk_r)
            wrcal_sanity_chk_err <= #TCQ 1'b1;
          else
            wrcal_pat_err      <= #TCQ 1'b1;
          cal2_state_r       <= #TCQ CAL2_ERR;
        end
      endcase
    end
  end
  always @(posedge clk)
    if (rst) 
      cal2_done_r1  <= #TCQ 1'b0;
    else
      cal2_done_r1  <= #TCQ cal2_done_r;
  always @(posedge clk)
    if (rst || (wrcal_sanity_chk && ~wrcal_sanity_chk_r))
      wrcal_done <= #TCQ 1'b0;
    else if (cal2_done_r)
      wrcal_done <= #TCQ 1'b1;
endmodule
