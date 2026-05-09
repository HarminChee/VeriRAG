`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v2_0_qdr_rld_phy_rdlvl #
   (
   parameter TCQ             = 100,    
   parameter MEMORY_IO_DIR     = "UNIDIR",
   parameter CPT_CLK_CQ_ONLY = "TRUE",
   parameter nCK_PER_CLK     = 2,      
   parameter CLK_PERIOD      = 3333,   
   parameter REFCLK_FREQ     = 300.0,          
   parameter DQ_WIDTH        = 64,     
   parameter DQS_CNT_WIDTH   = 3,      
   parameter DQS_WIDTH       = 8,      
   parameter DRAM_WIDTH      = 8,      
   parameter RANKS           = 1,      
   parameter PI_ADJ_GAP      = 7,      
   parameter RTR_CALIBRATION = "OFF",  
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
   input                        rtr_cal_done,
   input [2*nCK_PER_CLK*DQ_WIDTH-1:0] rd_data,
   output reg                   pi_en_stg2_f,
   output reg                   pi_stg2_f_incdec,
   output reg                   pi_stg2_load,
   output reg [5:0]             pi_stg2_reg_l,
   output [DQS_CNT_WIDTH-1:0]   pi_stg2_rdlvl_cnt,
   output reg                   po_en_stg2_f,   
   output reg                   po_stg2_f_incdec,
   output reg                   po_stg2_load,
   output reg [5:0]              po_stg2_reg_l,
   output [DQS_CNT_WIDTH-1:0]    po_stg2_rdlvl_cnt,
   output reg [5*RANKS*DQ_WIDTH-1:0] dlyval_dq,
   output [5*DQS_WIDTH-1:0]     dbg_cpt_first_edge_cnt,
   output [5*DQS_WIDTH-1:0]     dbg_cpt_second_edge_cnt,
   input                        dbg_SM_en,
   input                        dbg_idel_up_all,
   input                        dbg_idel_down_all,
   input                        dbg_idel_up_cpt,
   input                        dbg_idel_down_cpt,
   input                        dbg_sel_all_idel_cpt,
   output [255:0]               dbg_phy_rdlvl
   );
  localparam MIN_EYE_SIZE = 5;
  localparam MIN_Q_VALID_TAPS = 3;
  localparam PIPE_WAIT_CNT = 24;
  localparam CAL_PAT_LEN = (nCK_PER_CLK == 2) ? 4 : 8;
  localparam RD_SHIFT_LEN = CAL_PAT_LEN/(nCK_PER_CLK);
  localparam [11:0] DETECT_EDGE_SAMPLE_CNT0 = 12'h001; 
  localparam [11:0] DETECT_EDGE_SAMPLE_CNT1 = 12'h000; 
  function integer clogb2 (input integer size);
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
        size = size >> 1;
    end
  endfunction 
  localparam DQ_CNT_WIDTH   = clogb2(DQ_WIDTH);
  localparam DRAM_WIDTH_P2  = clogb2(DRAM_WIDTH-1);
  localparam DRAM_WIDTH_R2  = ( DRAM_WIDTH % 2 );
  localparam [5:0] CAL1_IDLE                 = 6'h00;
  localparam [5:0] CAL1_NEW_DQS_WAIT         = 6'h01;
  localparam [5:0] CAL1_STORE_FIRST_WAIT     = 6'h02;
  localparam [5:0] CAL1_DETECT_EDGE          = 6'h03;
  localparam [5:0] CAL1_IDEL_STORE_OLD       = 6'h04;
  localparam [5:0] CAL1_IDEL_INC_CPT         = 6'h05;
  localparam [5:0] CAL1_IDEL_INC_CPT_WAIT    = 6'h06;
  localparam [5:0] CAL1_CALC_IDEL            = 6'h07;
  localparam [5:0] CAL1_IDEL_DEC_CPT         = 6'h08;
  localparam [5:0] CAL1_IDEL_DEC_CPT_WAIT    = 6'h09;
  localparam [5:0] CAL1_NEXT_DQS             = 6'h0A;
  localparam [5:0] CAL1_DONE                 = 6'h0B;
  localparam [5:0] CAL1_PB_STORE_FIRST_WAIT  = 6'h0C;
  localparam [5:0] CAL1_PB_DETECT_EDGE       = 6'h0D;
  localparam [5:0] CAL1_PB_INC_CPT           = 6'h0E;
  localparam [5:0] CAL1_PB_INC_CPT_WAIT      = 6'h0F;
  localparam [5:0] CAL1_PB_DEC_CPT_LEFT      = 6'h10;
  localparam [5:0] CAL1_PB_DEC_CPT_LEFT_WAIT = 6'h11;
  localparam [5:0] CAL1_PB_DETECT_EDGE_DQ    = 6'h12;
  localparam [5:0] CAL1_PB_INC_DQ            = 6'h13;
  localparam [5:0] CAL1_PB_INC_DQ_WAIT       = 6'h14;
  localparam [5:0] CAL1_PB_DEC_CPT           = 6'h15;
  localparam [5:0] CAL1_PB_DEC_CPT_WAIT      = 6'h16;
  localparam [5:0] CAL1_DETECT_EDGE_Q        = 6'h17;
  localparam [5:0] CAL1_IDEL_INC_Q           = 6'h18;
  localparam [5:0] CAL1_IDEL_INC_Q_WAIT      = 6'h19;
  localparam [5:0] CAL1_IDEL_STORE_OLD_Q     = 6'h1A;   
  localparam [5:0] CAL1_REGL_LOAD            = 6'h1B;  
  localparam [5:0] CAL1_IDEL_DEC_Q           = 6'h1C;
  localparam [5:0] CAL1_IDEL_DEC_Q_WAIT      = 6'h1D;
  localparam [5:0] CAL1_IDEL_DEC_Q_ALL       = 6'h1E;
  localparam [5:0] CAL1_IDEL_DEC_Q_ALL_WAIT  = 6'h1F;
  localparam [5:0] CAL1_CALC_IDEL_WAIT       = 6'h20;
  localparam [5:0] CAL1_FALL_DETECT_EDGE        = 6'h21;
  localparam [5:0] CAL1_FALL_IDEL_STORE_OLD     = 6'h22;   
  localparam [5:0] CAL1_FALL_INC_CPT            = 6'h23;
  localparam [5:0] CAL1_FALL_INC_CPT_WAIT       = 6'h24;
  localparam [5:0] CAL1_FALL_CALC_DELAY         = 6'h25;
  localparam [5:0] CAL1_FALL_FINAL_DEC_TAP      = 6'h26;
  localparam [5:0] CAL1_FALL_FINAL_DEC_TAP_WAIT = 6'h27;
  localparam [5:0] CAL1_FALL_DETECT_EDGE_WAIT   = 6'h28;
  localparam [5:0] CAL1_IDEL_FALL_DEC_CPT       = 6'h29;
  localparam [5:0] CAL1_IDEL_FALL_DEC_CPT_WAIT  = 6'h30;
  localparam [5:0] CAL1_FALL_IDEL_INC_Q         = 6'h31;
  localparam [5:0] CAL1_FALL_IDEL_INC_Q_WAIT    = 6'h32;
  localparam [5:0] CAL1_FALL_IDEL_RESTORE_Q     = 6'h33;
  localparam [5:0] CAL1_FALL_IDEL_RESTORE_Q_WAIT  = 6'h34;
  localparam [5:0] SKIP_DLY_VAL    = (nCK_PER_CLK == 2) ? 6'd31 : 6'd25;
  localparam [4:0] SKIP_DLY_VAL_DQ = (nCK_PER_CLK == 2) ? 5'd13 : (CLK_PERIOD < 1250) ? 5'd15 : 5'd2;
  localparam [7:0] DATA_WIDTH   = DRAM_WIDTH;
  localparam integer IODELAY_TAP_RES  = 1000000 / (REFCLK_FREQ * 64); 
  localparam PHY_FREQ_REF_MODE = CLK_PERIOD > 2500 ? "DIV2": "NONE";  
  localparam FREQ_REF_DIV = PHY_FREQ_REF_MODE == "DIV2" ? 2 : 1; 
  localparam real FREQ_REF_MHZ =  1.0/((CLK_PERIOD/FREQ_REF_DIV/1000.0) / 1000) ;
  localparam integer PHASER_TAP_RES   = 1000000 / (FREQ_REF_MHZ * 128) ;               
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
  reg [DQS_CNT_WIDTH:0]   cal1_cnt_cpt_2r;               
  wire [DQS_CNT_WIDTH+2:0]cal1_cnt_cpt_timing;  
  reg                     cal1_dlyce_cpt_r;
  reg                     cal1_dlyinc_cpt_r;
  reg                     cal1_dlyce_dq_r;
  reg                     cal1_dlyinc_dq_r;
  reg                     cal1_wait_cnt_en_r;  
  reg [4:0]               cal1_wait_cnt_r;                
  reg                     cal1_wait_r;
  reg [DQ_WIDTH-1:0]      dlyce_dq_r;
  reg                     dlyinc_dq_r;  
  reg [5*DQ_WIDTH*RANKS-1:0] dlyval_dq_reg_r;
  reg                     cal1_prech_req_r;
  reg [5:0]               cal1_state_r;
  reg [5:0]               cal1_state_r1;
  reg [5:0]               cnt_idel_dec_cpt_r; 
  reg [5:0]               fall_dec_taps_r;
  reg [5:0]               cnt_rise_center_taps;
  reg [5:0]               fall_win_det_end_taps_r;
  reg [5:0]               fall_win_det_start_taps_r;
  reg                     phaser_taps_meet_fall_window;
  reg [2:0]               pi_gap_enforcer;
  reg [5:0]               idel_dec_cntr;
  reg [5:0]               idelay_inc_taps_r;
  reg [11:0]              idelay_tap_delay;
  wire [11:0]             idelay_tap_delay_sl_clk;
  wire [11:0]             phaser_tap_delay;
  reg [11:0]              phaser_tap_delay_sl_clk;
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
   reg                     cqn_tap_limit_cpt_r;
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
  wire [3:0]               rd_window      [DRAM_WIDTH-1:0];
  wire [3:0]               fd_window      [DRAM_WIDTH-1:0]; 
  reg [DRAM_WIDTH-1:0]    rise_data_valid_r;
  reg [DRAM_WIDTH-1:0]    fall_data_valid_r;
  wire                     rise_data_valid;
  wire                    data_valid;
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
  reg [DRAM_WIDTH-1:0]    prev_rise_sr_diff_r; 
  reg [DRAM_WIDTH-1:0]    prev_fall_sr_diff_r; 
  reg [RD_SHIFT_LEN-1:0]  prev_sr_fall0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_fall1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_rise0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_rise1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_fall2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_fall3_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_rise2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  prev_sr_rise3_r [DRAM_WIDTH-1:0];
  reg [DRAM_WIDTH-1:0]    prev_sr_match_cyc2_r;
  reg [DRAM_WIDTH-1:0]    prev_rise_sr_match_cyc2_r;   
  reg [DRAM_WIDTH-1:0]    prev_fall_sr_match_cyc2_r;   
  reg [DRAM_WIDTH-1:0]    prev_sr_match_fall0_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_fall1_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_rise0_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_rise1_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_fall2_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_fall3_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_rise2_r;
  reg [DRAM_WIDTH-1:0]    prev_sr_match_rise3_r;
  wire [RD_SHIFT_LEN-1:0] pat0_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat0_rise1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat0_rise2 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat0_rise3 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_rise1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_rise2 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_rise3 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat2_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat2_rise1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat2_rise2 [3:0];    
  wire [RD_SHIFT_LEN-1:0] pat2_rise3 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat3_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat3_rise1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat3_rise2 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat3_rise3 [3:0];
  reg                     pat0_data_match_r; 
  reg                     pat1_data_match_r;
  reg                     pat2_data_match_r;
  reg                     pat3_data_match_r;
  reg                     pat0_data_rise_match_r;
  reg                     pat1_data_rise_match_r;
  reg                     pat2_data_rise_match_r;
  reg                     pat3_data_rise_match_r;
  reg                     pat0_data_fall_match_r;
  reg                     pat1_data_fall_match_r;
  reg                     pat2_data_fall_match_r;
  reg                     pat3_data_fall_match_r;
  wire                    rise_match;
  wire                    fall_match;
  wire                    pat_match;
  wire [RD_SHIFT_LEN-1:0] pat0_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat0_fall1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat0_fall2 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat0_fall3 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_fall1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_fall2 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat1_fall3 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat2_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat2_fall1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat2_fall2 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat2_fall3 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat3_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat3_fall1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat3_fall2 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat3_fall3 [3:0];
  reg [DRAM_WIDTH-1:0]    pat0_match_fall0_r;
  reg                     pat0_match_fall0_and_r;
  reg [DRAM_WIDTH-1:0]    pat0_match_fall1_r;
  reg                     pat0_match_fall1_and_r;
  reg [DRAM_WIDTH-1:0]    pat0_match_fall2_r;
  reg                     pat0_match_fall2_and_r;
  reg [DRAM_WIDTH-1:0]    pat0_match_fall3_r;
  reg                     pat0_match_fall3_and_r;
  reg [DRAM_WIDTH-1:0]    pat0_match_rise0_r;
  reg                     pat0_match_rise0_and_r;
  reg [DRAM_WIDTH-1:0]    pat0_match_rise1_r;
  reg                     pat0_match_rise1_and_r;   
  reg [DRAM_WIDTH-1:0]    pat0_match_rise2_r;
  reg                     pat0_match_rise2_and_r;
  reg [DRAM_WIDTH-1:0]    pat0_match_rise3_r;
  reg                     pat0_match_rise3_and_r;
  reg [DRAM_WIDTH-1:0]    pat1_match_fall0_r;
  reg                     pat1_match_fall0_and_r;
  reg [DRAM_WIDTH-1:0]    pat1_match_fall1_r;
  reg                     pat1_match_fall1_and_r;
  reg [DRAM_WIDTH-1:0]    pat1_match_fall2_r;
  reg                     pat1_match_fall2_and_r;
  reg [DRAM_WIDTH-1:0]    pat1_match_fall3_r;
  reg                     pat1_match_fall3_and_r;
  reg [DRAM_WIDTH-1:0]    pat1_match_rise0_r;
  reg                     pat1_match_rise0_and_r;
  reg [DRAM_WIDTH-1:0]    pat1_match_rise1_r;
  reg                     pat1_match_rise1_and_r;
  reg [DRAM_WIDTH-1:0]    pat1_match_rise2_r;
  reg                     pat1_match_rise2_and_r;
  reg [DRAM_WIDTH-1:0]    pat1_match_rise3_r;
  reg                     pat1_match_rise3_and_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_fall0_r;
  reg                     pat2_match_fall0_and_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_fall1_r;
  reg                     pat2_match_fall1_and_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_fall2_r;
  reg                     pat2_match_fall2_and_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_fall3_r;
  reg                     pat2_match_fall3_and_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_rise0_r;
  reg                     pat2_match_rise0_and_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_rise1_r;
  reg                     pat2_match_rise1_and_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_rise2_r;
  reg                     pat2_match_rise2_and_r;
  reg [DRAM_WIDTH-1:0]    pat2_match_rise3_r;
  reg                     pat2_match_rise3_and_r;
  reg [DRAM_WIDTH-1:0]    pat3_match_fall0_r;
  reg                     pat3_match_fall0_and_r;
  reg [DRAM_WIDTH-1:0]    pat3_match_fall1_r;
  reg                     pat3_match_fall1_and_r;
  reg [DRAM_WIDTH-1:0]    pat3_match_fall2_r;
  reg                     pat3_match_fall2_and_r;
  reg [DRAM_WIDTH-1:0]    pat3_match_fall3_r;
  reg                     pat3_match_fall3_and_r;
  reg [DRAM_WIDTH-1:0]    pat3_match_rise0_r;
  reg                     pat3_match_rise0_and_r;
  reg [DRAM_WIDTH-1:0]    pat3_match_rise1_r;
  reg                     pat3_match_rise1_and_r;
  reg [DRAM_WIDTH-1:0]    pat3_match_rise2_r;
  reg                     pat3_match_rise2_and_r;
  reg [DRAM_WIDTH-1:0]    pat3_match_rise3_r;
  reg                     pat3_match_rise3_and_r;
  reg [DQ_WIDTH-1:0]     rd_data_rise0;
  reg [DQ_WIDTH-1:0]     rd_data_fall0;
  reg [DQ_WIDTH-1:0]     rd_data_rise1;
  reg [DQ_WIDTH-1:0]     rd_data_fall1;
  reg [DQ_WIDTH-1:0]     rd_data_rise2;
  reg [DQ_WIDTH-1:0]     rd_data_fall2;
  reg [DQ_WIDTH-1:0]     rd_data_rise3;
  reg [DQ_WIDTH-1:0]     rd_data_fall3;
  reg                     samp_cnt_done_r;
  reg                     samp_edge_cnt0_en_r;
  reg [11:0]              samp_edge_cnt0_r;
  reg                     samp_edge_cnt1_en_r;
  reg [11:0]              samp_edge_cnt1_r;
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
  reg [DRAM_WIDTH-1:0]    old_rise_sr_diff_r; 
  reg [DRAM_WIDTH-1:0]    old_fall_sr_diff_r;   
  reg [DRAM_WIDTH-1:0]    old_sr_match_cyc2_r;
  reg [6*DQS_WIDTH*RANKS-1:0] pi_rdlvl_dqs_tap_cnt_r;
  reg [6*DQS_WIDTH*RANKS-1:0] po_rdlvl_dqs_tap_cnt_r;
  reg [DRAM_WIDTH-1:0]    old_rise_sr_match_cyc2_r;
  reg [DRAM_WIDTH-1:0]    old_fall_sr_match_cyc2_r;
  reg [6*DQS_WIDTH*RANKS-1:0] rdlvl_dqs_tap_cnt_r;
  reg [1:0]               rnk_cnt_r;
  reg                     rdlvl_rank_done_r;
  reg [3:0]               done_cnt;
  reg [1:0]               regl_rank_cnt;
  reg [DQS_CNT_WIDTH:0]   regl_dqs_cnt;
  wire [DQS_CNT_WIDTH+2:0]regl_dqs_cnt_timing;
  reg                     regl_rank_done_r;
  reg [23:0] rdlvl_start_r  ;
  reg set_fall_capture_clock_at_tap0;
  wire rdlvl_start;
  reg        cal1_dlyce_q_r;
  reg        cal1_dlyinc_q_r;
  reg [5:0]  idel_tap_cnt_cpt_r;
  reg [5:0]  stored_idel_tap_cnt_cpt_r;
  reg        idel_tap_limit_cpt_r;
  reg        qdly_inc_done_r;
  reg        start_win_detect;
  reg        end_win_detect;
  reg [5:0]  start_win_taps;
  reg [5:0]  end_win_taps;
  reg [5:0]  idelay_taps;
  reg        clk_in_vld_win;
  reg        idelay_ce;
  reg        idelay_inc;
  reg        idel_gt_phaser_delay;       
  reg [11:0] idel_minus_phaser_delay;
  reg [11:0] phaser_minus_idel_delay;    
  reg [5:0]  phaser_dec_taps;
  reg        cal1_dec_cnt;
  reg        rise_detect_done;
  reg        fall_first_edge_det_done;    
(* KEEP = "TRUE" *)  reg [DQ_CNT_WIDTH:0]    rd_mux_sel_r_mult_r ;
(* KEEP = "TRUE" *)  reg [DQ_CNT_WIDTH:0]    rd_mux_sel_r_mult_f ;
  wire [DQ_CNT_WIDTH:0]   rd_mux_sel_r_p2;
  reg [4:0]               dbg_cpt_first_edge_taps [0:DQS_WIDTH-1];
  reg [4:0]               dbg_cpt_second_edge_taps [0:DQS_WIDTH-1];
  reg [3:0]               dbg_stg1_calc_edge;  
  reg [DQS_WIDTH-1:0]     dbg_phy_rdlvl_err;
  wire pb_detect_edge_setup;
  wire pb_detect_edge;
  assign dbg_phy_rdlvl[0]        = rdlvl_stg1_start;  
  assign dbg_phy_rdlvl[1]        = rdlvl_start;
  assign dbg_phy_rdlvl[2]        = found_edge_r;     
  assign dbg_phy_rdlvl[3]        = pat0_data_match_r;
  assign dbg_phy_rdlvl[4]        = pat1_data_match_r;
  assign dbg_phy_rdlvl[5]        = data_valid;
  assign dbg_phy_rdlvl[6]        = cal1_wait_r;
  assign dbg_phy_rdlvl[7]        = rise_match;
  assign dbg_phy_rdlvl[13:8]     = cal1_state_r[5:0]; 
  assign dbg_phy_rdlvl[20:14]    = cnt_idel_dec_cpt_r;
  assign dbg_phy_rdlvl[21]       = found_first_edge_r;
  assign dbg_phy_rdlvl[22]       = found_second_edge_r;
  assign dbg_phy_rdlvl[23]       = fall_match;
  assign dbg_phy_rdlvl[24]       = store_sr_r;
  assign dbg_phy_rdlvl[32:25]    = {sr_fall1_r[0][1:0], sr_rise1_r[0][1:0],
                                    sr_fall0_r[0][1:0], sr_rise0_r[0][1:0]};  
  assign dbg_phy_rdlvl[40:33]    = {old_sr_fall1_r[0][1:0],
                                    old_sr_rise1_r[0][1:0],
                                    old_sr_fall0_r[0][1:0],
                                    old_sr_rise0_r[0][1:0]};  
  assign dbg_phy_rdlvl[41]       = sr_valid_r;
  assign dbg_phy_rdlvl[42]       = found_stable_eye_r;
  assign dbg_phy_rdlvl[48:43]    = tap_cnt_cpt_r;             
  assign dbg_phy_rdlvl[54:49]    = first_edge_taps_r;         
  assign dbg_phy_rdlvl[60:55]    = second_edge_taps_r;        
  assign dbg_phy_rdlvl[64:61]    = cal1_cnt_cpt_r;            
  assign dbg_phy_rdlvl[65]       = cal1_dlyce_cpt_r;
  assign dbg_phy_rdlvl[66]       = cal1_dlyinc_cpt_r;
  assign dbg_phy_rdlvl[67]       = rise_detect_done;
  assign dbg_phy_rdlvl[68]       = found_stable_eye_last_r;  
  assign dbg_phy_rdlvl[74:69]    = idelay_taps[5:0];          
  assign dbg_phy_rdlvl[80:75]    = start_win_taps[5:0];
  assign dbg_phy_rdlvl[81]       = idel_tap_limit_cpt_r;       
  assign dbg_phy_rdlvl[82]       = qdly_inc_done_r;
  assign dbg_phy_rdlvl[83]       = start_win_detect;
  assign dbg_phy_rdlvl[84]       = detect_edge_done_r;
  assign dbg_phy_rdlvl[90:85]    = idel_tap_cnt_cpt_r[5:0]; 
  assign dbg_phy_rdlvl[96:91]    = idelay_inc_taps_r[5:0];
  assign dbg_phy_rdlvl[102:97]   = idel_dec_cntr[5:0];   
  assign dbg_phy_rdlvl[103]      = tap_limit_cpt_r;   
  assign dbg_phy_rdlvl[115:104]  = idelay_tap_delay[11:0]; 
  assign dbg_phy_rdlvl[127:116]  = phaser_tap_delay[11:0]; 
  assign dbg_phy_rdlvl[128 +: 6] = fall_win_det_start_taps_r[5:0]; 
  assign dbg_phy_rdlvl[134 +: 6] = fall_win_det_end_taps_r[5:0]; 
  assign dbg_phy_rdlvl[140 +: 24]= dbg_cpt_first_edge_cnt;   
  assign dbg_phy_rdlvl[164 +: 20]= dbg_cpt_second_edge_cnt;
  assign dbg_phy_rdlvl[187:184]  = dbg_stg1_calc_edge;
  assign dbg_phy_rdlvl[195:188]  = dbg_phy_rdlvl_err;
  assign dbg_phy_rdlvl[255:196]  = 'b0;
   always @(posedge clk ) begin
	 if ((SIM_CAL_OPTION == "SKIP_CAL") && rst) begin
	   rdlvl_start_r   <= #TCQ 'b0;
	 end else begin
       rdlvl_start_r[0]    <= #TCQ rdlvl_stg1_start;
	   rdlvl_start_r[23:1] <= #TCQ {rdlvl_start_r[22:1], rdlvl_start_r[0]};
	 end
   end
   assign rdlvl_start =  rdlvl_start_r[23];
   generate
     if (CLK_PERIOD > 2500) begin : clk_less_than_400_MHz
       assign idelay_tap_delay_sl_clk = { 6'h0, idelay_taps };
       always @ (*) begin
         case (first_edge_taps_r)
           6'h 0_0 :  phaser_tap_delay_sl_clk = (0  * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_1 :  phaser_tap_delay_sl_clk = (1  * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_2 :  phaser_tap_delay_sl_clk = (2  * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_3 :  phaser_tap_delay_sl_clk = (3  * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_4 :  phaser_tap_delay_sl_clk = (4  * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_5 :  phaser_tap_delay_sl_clk = (5  * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_6 :  phaser_tap_delay_sl_clk = (6  * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_7 :  phaser_tap_delay_sl_clk = (7  * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_8 :  phaser_tap_delay_sl_clk = (8  * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_9 :  phaser_tap_delay_sl_clk = (9  * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_A :  phaser_tap_delay_sl_clk = (10 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_B :  phaser_tap_delay_sl_clk = (11 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_C :  phaser_tap_delay_sl_clk = (12 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_D :  phaser_tap_delay_sl_clk = (13 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_E :  phaser_tap_delay_sl_clk = (14 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 0_F :  phaser_tap_delay_sl_clk = (15 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_0 :  phaser_tap_delay_sl_clk = (16 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_1 :  phaser_tap_delay_sl_clk = (17 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_2 :  phaser_tap_delay_sl_clk = (18 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_3 :  phaser_tap_delay_sl_clk = (19 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_4 :  phaser_tap_delay_sl_clk = (20 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_5 :  phaser_tap_delay_sl_clk = (21 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_6 :  phaser_tap_delay_sl_clk = (22 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_7 :  phaser_tap_delay_sl_clk = (23 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_8 :  phaser_tap_delay_sl_clk = (24 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_9 :  phaser_tap_delay_sl_clk = (25 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_A :  phaser_tap_delay_sl_clk = (26 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_B :  phaser_tap_delay_sl_clk = (27 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_C :  phaser_tap_delay_sl_clk = (28 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_D :  phaser_tap_delay_sl_clk = (29 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_E :  phaser_tap_delay_sl_clk = (30 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 1_F :  phaser_tap_delay_sl_clk = (31 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_0 :  phaser_tap_delay_sl_clk = (32 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_1 :  phaser_tap_delay_sl_clk = (33 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_2 :  phaser_tap_delay_sl_clk = (34 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_3 :  phaser_tap_delay_sl_clk = (35 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_4 :  phaser_tap_delay_sl_clk = (36 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_5 :  phaser_tap_delay_sl_clk = (37 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_6 :  phaser_tap_delay_sl_clk = (38 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_7 :  phaser_tap_delay_sl_clk = (39 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_8 :  phaser_tap_delay_sl_clk = (40 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_9 :  phaser_tap_delay_sl_clk = (41 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_A :  phaser_tap_delay_sl_clk = (42 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_B :  phaser_tap_delay_sl_clk = (43 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_C :  phaser_tap_delay_sl_clk = (44 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_D :  phaser_tap_delay_sl_clk = (45 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_E :  phaser_tap_delay_sl_clk = (46 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 2_F :  phaser_tap_delay_sl_clk = (47 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_0 :  phaser_tap_delay_sl_clk = (48 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_1 :  phaser_tap_delay_sl_clk = (49 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_2 :  phaser_tap_delay_sl_clk = (50 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_3 :  phaser_tap_delay_sl_clk = (51 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_4 :  phaser_tap_delay_sl_clk = (52 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_5 :  phaser_tap_delay_sl_clk = (53 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_6 :  phaser_tap_delay_sl_clk = (54 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_7 :  phaser_tap_delay_sl_clk = (55 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_8 :  phaser_tap_delay_sl_clk = (56 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_9 :  phaser_tap_delay_sl_clk = (57 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_A :  phaser_tap_delay_sl_clk = (58 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_B :  phaser_tap_delay_sl_clk = (59 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_C :  phaser_tap_delay_sl_clk = (60 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_D :  phaser_tap_delay_sl_clk = (61 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_E :  phaser_tap_delay_sl_clk = (62 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           6'h 3_F :  phaser_tap_delay_sl_clk = (63 * PHASER_TAP_RES)/IODELAY_TAP_RES; 
           default :  phaser_tap_delay_sl_clk = 'b0; 
         endcase
       end
       always @ (posedge clk) begin 
         idel_minus_phaser_delay <=  (idelay_tap_delay_sl_clk - phaser_tap_delay_sl_clk);  
       end
     end
   endgenerate
   always @ (*) begin
      case (idelay_taps)
          6'h 0_0 :  idelay_tap_delay = (0   * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_1 :  idelay_tap_delay = (1   * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_2 :  idelay_tap_delay = (2   * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_3 :  idelay_tap_delay = (3   * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_4 :  idelay_tap_delay = (4   * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_5 :  idelay_tap_delay = (5   * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_6 :  idelay_tap_delay = (6   * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_7 :  idelay_tap_delay = (7   * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_8 :  idelay_tap_delay = (8   * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_9 :  idelay_tap_delay = (9   * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_A :  idelay_tap_delay = (10  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_B :  idelay_tap_delay = (11  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_C :  idelay_tap_delay = (12  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_D :  idelay_tap_delay = (13  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_E :  idelay_tap_delay = (14  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 0_F :  idelay_tap_delay = (15  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_0 :  idelay_tap_delay = (16  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_1 :  idelay_tap_delay = (17  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_2 :  idelay_tap_delay = (18  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_3 :  idelay_tap_delay = (19  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_4 :  idelay_tap_delay = (20  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_5 :  idelay_tap_delay = (21  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_6 :  idelay_tap_delay = (22  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_7 :  idelay_tap_delay = (23  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_8 :  idelay_tap_delay = (24  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_9 :  idelay_tap_delay = (25  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_A :  idelay_tap_delay = (26  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_B :  idelay_tap_delay = (27  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_C :  idelay_tap_delay = (28  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_D :  idelay_tap_delay = (29  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_E :  idelay_tap_delay = (30  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          6'h 1_F :  idelay_tap_delay = (31  * IODELAY_TAP_RES)/PHASER_TAP_RES; 
          default :  idelay_tap_delay = 'b0; 
      endcase
    end
   assign phaser_tap_delay = { 6'h0, first_edge_taps_r };                    
   always @ (posedge clk) begin 
     idel_gt_phaser_delay    <=  (idelay_tap_delay > phaser_tap_delay) ? 1'b1 : 1'b0;
     phaser_dec_taps         <=  (phaser_tap_delay - idelay_tap_delay)>>1;
   end 
   assign po_stg2_rdlvl_cnt  = pi_stg2_rdlvl_cnt;
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
  assign rdlvl_stg1_rnk_done = rdlvl_rank_done_r ;
   assign pi_stg2_rdlvl_cnt = (cal1_state_r == CAL1_REGL_LOAD) ? regl_dqs_cnt : cal1_cnt_cpt_r;
  generate
    if (nCK_PER_CLK == 4) begin: rd_data_div4_logic_clk
      always @ (posedge clk) begin
         rd_data_rise0 <= #TCQ rd_data[DQ_WIDTH-1:0];
         rd_data_fall0 <= #TCQ rd_data[2*DQ_WIDTH-1:DQ_WIDTH];
         rd_data_rise1 <= #TCQ rd_data[3*DQ_WIDTH-1:2*DQ_WIDTH];
         rd_data_fall1 <= #TCQ rd_data[4*DQ_WIDTH-1:3*DQ_WIDTH];
         rd_data_rise2 <= #TCQ rd_data[5*DQ_WIDTH-1:4*DQ_WIDTH];
         rd_data_fall2 <= #TCQ rd_data[6*DQ_WIDTH-1:5*DQ_WIDTH];
         rd_data_rise3 <= #TCQ rd_data[7*DQ_WIDTH-1:6*DQ_WIDTH];
         rd_data_fall3 <= #TCQ rd_data[8*DQ_WIDTH-1:7*DQ_WIDTH];
      end
    end else begin: rd_datadiv2_logic_clk 
      always @ (posedge clk) begin 
        rd_data_rise0 <= #TCQ rd_data[DQ_WIDTH-1:0];
        rd_data_fall0 <= #TCQ rd_data[2*DQ_WIDTH-1:DQ_WIDTH];
        rd_data_rise1 <= #TCQ rd_data[3*DQ_WIDTH-1:2*DQ_WIDTH];
        rd_data_fall1 <= #TCQ rd_data[4*DQ_WIDTH-1:3*DQ_WIDTH];
        rd_data_rise2 <= #TCQ 'b0;   
        rd_data_fall2 <= #TCQ 'b0;  
        rd_data_rise3 <= #TCQ 'b0;   
        rd_data_fall3 <= #TCQ 'b0; 
      end 
    end
  endgenerate
  assign rd_mux_sel_r_p2 = cal1_cnt_cpt_r << DRAM_WIDTH_P2;
  always @(posedge clk) begin
    rd_mux_sel_r_mult_r <= #TCQ rd_mux_sel_r_p2 + cal1_cnt_cpt_r;
    rd_mux_sel_r_mult_f <= #TCQ rd_mux_sel_r_p2 + cal1_cnt_cpt_r;
  end
  generate
    genvar mux_i;
    for (mux_i = 0; mux_i < DRAM_WIDTH; mux_i = mux_i + 1) begin: gen_mux_rd
      always @(posedge clk) begin
        mux_rd_rise0_r[mux_i] <= #TCQ rd_data_rise0[rd_mux_sel_r_mult_r + mux_i];
        mux_rd_fall0_r[mux_i] <= #TCQ rd_data_fall0[rd_mux_sel_r_mult_f + mux_i];
        mux_rd_rise1_r[mux_i] <= #TCQ rd_data_rise1[rd_mux_sel_r_mult_r + mux_i];
        mux_rd_fall1_r[mux_i] <= #TCQ rd_data_fall1[rd_mux_sel_r_mult_f + mux_i];
        mux_rd_rise2_r[mux_i] <= #TCQ rd_data_rise2[rd_mux_sel_r_mult_r + mux_i];
        mux_rd_fall2_r[mux_i] <= #TCQ rd_data_fall2[rd_mux_sel_r_mult_f + mux_i];
        mux_rd_rise3_r[mux_i] <= #TCQ rd_data_rise3[rd_mux_sel_r_mult_r + mux_i];
        mux_rd_fall3_r[mux_i] <= #TCQ rd_data_fall3[rd_mux_sel_r_mult_f + mux_i];
      end
    end
  endgenerate
  always @(posedge clk) begin
    if (rst) begin
      pi_en_stg2_f     <= #TCQ 'b0;
      pi_stg2_f_incdec <= #TCQ 'b0;
    end else if (cal1_dlyce_cpt_r && ~rise_detect_done) begin
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
    if (rst) begin
      po_en_stg2_f     <= #TCQ 'b0;
      po_stg2_f_incdec <= #TCQ 'b0;
    end else if (cal1_dlyce_cpt_r && rise_detect_done ) begin
      if ((SIM_CAL_OPTION == "NONE") ||
          (SIM_CAL_OPTION == "FAST_WIN_DETECT")) begin 
        po_en_stg2_f     <= #TCQ 1'b1;  
        po_stg2_f_incdec <= #TCQ cal1_dlyinc_cpt_r;
      end else if (SIM_CAL_OPTION == "FAST_CAL") begin 
        po_en_stg2_f     <= #TCQ 1'b1;
        po_stg2_f_incdec <= #TCQ cal1_dlyinc_cpt_r;
      end
    end else begin
      po_en_stg2_f     <= #TCQ 'b0;
      po_stg2_f_incdec <= #TCQ 'b0;
    end
  end 
  always @(posedge clk) begin
    if (rst) begin
      idelay_ce        <= #TCQ 'b0;
      idelay_inc       <= #TCQ 'b0;
    end else if (cal1_dlyce_q_r) begin
      if ((SIM_CAL_OPTION == "NONE") ||
          (SIM_CAL_OPTION == "FAST_WIN_DETECT")) begin 
        idelay_ce        <= #TCQ 1'b1;
        idelay_inc       <= #TCQ cal1_dlyinc_q_r;
      end else if (SIM_CAL_OPTION == "FAST_CAL") begin 
        idelay_ce        <= #TCQ cal1_dlyce_q_r;
        idelay_inc       <= #TCQ cal1_dlyinc_q_r;
      end
    end else begin
      idelay_ce        <= #TCQ 'b0;
      idelay_inc       <= #TCQ 'b0;
    end
  end
   always @(posedge clk) begin
     if (rst)
       done_cnt <= #TCQ 'b0;
     else if (  ((cal1_state_r == CAL1_REGL_LOAD) && (cal1_state_r1 == CAL1_IDLE) && (SIM_CAL_OPTION == "SKIP_CAL")) ||  
                ((cal1_state_r == CAL1_REGL_LOAD) && (cal1_state_r1 == CAL1_NEXT_DQS) && (SIM_CAL_OPTION != "SKIP_CAL")) || 
                ((done_cnt == 4'd1) && (cal1_state_r != CAL1_DONE))  )
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
         pi_rdlvl_dqs_tap_cnt_r[(((regl_dqs_cnt_timing<<2) + (regl_dqs_cnt_timing<<1))
         +(rnk_cnt_r*DQS_WIDTH*6))+:6];
     end else begin
       pi_stg2_load  <= #TCQ 'b0;
       pi_stg2_reg_l <= #TCQ 'b0;
     end
   end
   always @(posedge clk) begin
     if (rst || (done_cnt == 4'd0)) begin
       po_stg2_load    <= #TCQ 'b0;
       po_stg2_reg_l   <= #TCQ 'b0;
     end else if ((cal1_state_r == CAL1_REGL_LOAD) && 
                  (regl_dqs_cnt <= DQS_WIDTH-1) && (done_cnt == 4'd1)) begin
       po_stg2_load  <= #TCQ 'b1;
       po_stg2_reg_l <= #TCQ 
         po_rdlvl_dqs_tap_cnt_r[(((regl_dqs_cnt_timing<<2) + (regl_dqs_cnt_timing<<1))
                         +(rnk_cnt_r*DQS_WIDTH*6))+:6];
     end else begin
       po_stg2_load  <= #TCQ 'b0;
       po_stg2_reg_l <= #TCQ 'b0;
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
            dlyce_dq_r[DRAM_WIDTH*z+:DRAM_WIDTH] <= #TCQ {DRAM_WIDTH{idelay_ce}}; 
          else if ((SIM_CAL_OPTION == "NONE") ||
                   (SIM_CAL_OPTION == "FAST_WIN_DETECT")) begin 
            if (cal1_cnt_cpt_r == z)
              dlyce_dq_r[DRAM_WIDTH*z+:DRAM_WIDTH] 
                <= #TCQ {DRAM_WIDTH{idelay_ce}}; 
            else
              dlyce_dq_r[DRAM_WIDTH*z+:DRAM_WIDTH] <= #TCQ 'b0;
          end
    end
  endgenerate
  always @(posedge clk)
    if (rst)
      dlyinc_dq_r <= #TCQ 1'b0;
    else
      dlyinc_dq_r <= #TCQ idelay_inc; 
  always @(posedge clk)
    if (rst) begin
      dlyval_dq_reg_r <= #TCQ 'b0;
        end else if (SIM_CAL_OPTION == "SKIP_CAL") begin
          dlyval_dq_reg_r <= #TCQ {5*RANKS*DQ_WIDTH{SKIP_DLY_VAL_DQ}};
    end else begin
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
    end 
        always @(posedge clk) begin 
          dlyval_dq <= #TCQ dlyval_dq_reg_r;
        end
  always @(posedge clk)
  begin
    case (cal1_state_r)
	  CAL1_NEW_DQS_WAIT,
	  CAL1_PB_STORE_FIRST_WAIT,
	  CAL1_PB_INC_CPT_WAIT,
	  CAL1_PB_DEC_CPT_LEFT_WAIT,
	  CAL1_PB_INC_DQ_WAIT,
	  CAL1_PB_DEC_CPT_WAIT,
	  CAL1_IDEL_INC_CPT_WAIT,
	  CAL1_IDEL_INC_Q_WAIT,
	  CAL1_IDEL_DEC_Q_WAIT,
	  CAL1_IDEL_DEC_Q_ALL_WAIT,
	  CAL1_CALC_IDEL_WAIT,
	  CAL1_STORE_FIRST_WAIT,
	  CAL1_FALL_IDEL_INC_Q_WAIT,
	  CAL1_FALL_IDEL_RESTORE_Q_WAIT,
	  CAL1_FALL_INC_CPT_WAIT,
	  CAL1_FALL_FINAL_DEC_TAP_WAIT: begin
	    cal1_wait_cnt_en_r <= #TCQ 1'b1;
	  end
	  default: begin
	    cal1_wait_cnt_en_r <= #TCQ 1'b0;
	  end
	endcase
  end
  always @(posedge clk)
    if (!cal1_wait_cnt_en_r) begin
      cal1_wait_cnt_r <= #TCQ 5'b00000;
      cal1_wait_r     <= #TCQ 1'b1;
    end else begin
      if (cal1_wait_cnt_r != PIPE_WAIT_CNT - 1) begin
        cal1_wait_cnt_r <= #TCQ cal1_wait_cnt_r + 1;
        cal1_wait_r     <= #TCQ 1'b1;
      end else begin
        cal1_wait_cnt_r <= #TCQ 5'b00000;        
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
  generate
    if (nCK_PER_CLK == 2) begin : gen_pat_div2
      assign pat0_rise0[3] = 2'b00;
      assign pat0_fall0[3] = 2'b11;
      assign pat0_rise1[3] = 2'b10;
      assign pat0_fall1[3] = 2'b01;
      assign pat0_rise0[2] = 2'b00;
      assign pat0_fall0[2] = 2'b11;
      assign pat0_rise1[2] = 2'b10;
      assign pat0_fall1[2] = 2'b01;
      assign pat0_rise0[1] = 2'b00;
      assign pat0_fall0[1] = 2'b11;
      assign pat0_rise1[1] = 2'b10;
      assign pat0_fall1[1] = 2'b01;
      assign pat0_rise0[0] = 2'b00;
      assign pat0_fall0[0] = 2'b11;
      assign pat0_rise1[0] = 2'b10;
      assign pat0_fall1[0] = 2'b01;
      assign pat1_rise0[3] = 2'b10;
      assign pat1_fall0[3] = 2'b01;
      assign pat1_rise1[3] = 2'b00;
      assign pat1_fall1[3] = 2'b11;
      assign pat1_rise0[2] = 2'b10;
      assign pat1_fall0[2] = 2'b01;
      assign pat1_rise1[2] = 2'b00;
      assign pat1_fall1[2] = 2'b11;
      assign pat1_rise0[1] = 2'b10;
      assign pat1_fall0[1] = 2'b01;
      assign pat1_rise1[1] = 2'b00;
      assign pat1_fall1[1] = 2'b11;
      assign pat1_rise0[0] = 2'b10;
      assign pat1_fall0[0] = 2'b01;
      assign pat1_rise1[0] = 2'b00;
      assign pat1_fall1[0] = 2'b11;
    end else begin : gen_pat_div4
      assign pat0_rise0[3] = (RTR_CALIBRATION == "ON" && !rtr_cal_done) ? 2'b00 : 2'b00;
      assign pat0_fall0[3] = (RTR_CALIBRATION == "ON" && !rtr_cal_done) ? 2'b11 : 2'b11;
      assign pat0_rise1[3] = (RTR_CALIBRATION == "ON" && !rtr_cal_done) ? 2'b00 : 2'b00;
      assign pat0_fall1[3] = (RTR_CALIBRATION == "ON" && !rtr_cal_done) ? 2'b11 : 2'b11;
      assign pat0_rise2[3] = (RTR_CALIBRATION == "ON" && !rtr_cal_done) ? 2'b00 : 2'b00;
      assign pat0_fall2[3] = (RTR_CALIBRATION == "ON" && !rtr_cal_done) ? 2'b11 : 2'b11;
      assign pat0_rise3[3] = (RTR_CALIBRATION == "ON" && !rtr_cal_done) ? 2'b00 : 2'b11;
      assign pat0_fall3[3] = (RTR_CALIBRATION == "ON" && !rtr_cal_done) ? 2'b11 : 2'b00;
      assign pat0_rise0[2] = pat0_rise0[3];
      assign pat0_fall0[2] = pat0_fall0[3];
      assign pat0_rise1[2] = pat0_rise1[3];
      assign pat0_fall1[2] = pat0_fall1[3];
      assign pat0_rise2[2] = pat0_rise2[3];
      assign pat0_fall2[2] = pat0_fall2[3];
      assign pat0_rise3[2] = pat0_rise3[3];
      assign pat0_fall3[2] = pat0_fall3[3];
      assign pat0_rise0[1] = pat0_rise0[3];
      assign pat0_fall0[1] = pat0_fall0[3];
      assign pat0_rise1[1] = pat0_rise1[3];
      assign pat0_fall1[1] = pat0_fall1[3];
      assign pat0_rise2[1] = pat0_rise2[3];
      assign pat0_fall2[1] = pat0_fall2[3];
      assign pat0_rise3[1] = pat0_rise3[3];
      assign pat0_fall3[1] = pat0_fall3[3];
	  assign pat0_rise0[0] = pat0_rise0[3];
      assign pat0_fall0[0] = pat0_fall0[3];
      assign pat0_rise1[0] = pat0_rise1[3];
      assign pat0_fall1[0] = pat0_fall1[3];
      assign pat0_rise2[0] = pat0_rise2[3];
      assign pat0_fall2[0] = pat0_fall2[3];
      assign pat0_rise3[0] = pat0_rise3[3];
      assign pat0_fall3[0] = pat0_fall3[3];
	  assign pat1_rise0[3] = 2'b11;
      assign pat1_fall0[3] = 2'b00;
      assign pat1_rise1[3] = 2'b00;
      assign pat1_fall1[3] = 2'b11;
      assign pat1_rise2[3] = 2'b00;
      assign pat1_fall2[3] = 2'b11;
      assign pat1_rise3[3] = 2'b00;
      assign pat1_fall3[3] = 2'b11;
      assign pat1_rise0[2] = pat1_rise0[3];
      assign pat1_fall0[2] = pat1_fall0[3];
      assign pat1_rise1[2] = pat1_rise1[3];
      assign pat1_fall1[2] = pat1_fall1[3];
      assign pat1_rise2[2] = pat1_rise2[3];
      assign pat1_fall2[2] = pat1_fall2[3];
      assign pat1_rise3[2] = pat1_rise3[3];
      assign pat1_fall3[2] = pat1_fall3[3];
      assign pat1_rise0[1] = pat1_rise0[3];
      assign pat1_fall0[1] = pat1_fall0[3];
      assign pat1_rise1[1] = pat1_rise1[3];
      assign pat1_fall1[1] = pat1_fall1[3];
      assign pat1_rise2[1] = pat1_rise2[3];
      assign pat1_fall2[1] = pat1_fall2[3];
      assign pat1_rise3[1] = pat1_rise3[3];
      assign pat1_fall3[1] = pat1_fall3[3];
	  assign pat1_rise0[0] = pat1_rise0[3];
      assign pat1_fall0[0] = pat1_fall0[3];
      assign pat1_rise1[0] = pat1_rise1[3];
      assign pat1_fall1[0] = pat1_fall1[3];
      assign pat1_rise2[0] = pat1_rise2[3];
      assign pat1_fall2[0] = pat1_fall2[3];
      assign pat1_rise3[0] = pat1_rise3[3];
      assign pat1_fall3[0] = pat1_fall3[3];
	  assign pat2_rise0[3] = 2'b00;
      assign pat2_fall0[3] = 2'b11;
      assign pat2_rise1[3] = 2'b11;
      assign pat2_fall1[3] = 2'b00;
      assign pat2_rise2[3] = 2'b00;
      assign pat2_fall2[3] = 2'b11;
      assign pat2_rise3[3] = 2'b00;
      assign pat2_fall3[3] = 2'b11;
      assign pat2_rise0[2] = pat2_rise0[3];
      assign pat2_fall0[2] = pat2_fall0[3];
      assign pat2_rise1[2] = pat2_rise1[3];
      assign pat2_fall1[2] = pat2_fall1[3];
      assign pat2_rise2[2] = pat2_rise2[3];
      assign pat2_fall2[2] = pat2_fall2[3];
      assign pat2_rise3[2] = pat2_rise3[3];
      assign pat2_fall3[2] = pat2_fall3[3];
      assign pat2_rise0[1] = pat2_rise0[3];
      assign pat2_fall0[1] = pat2_fall0[3];
      assign pat2_rise1[1] = pat2_rise1[3];
      assign pat2_fall1[1] = pat2_fall1[3];
      assign pat2_rise2[1] = pat2_rise2[3];
      assign pat2_fall2[1] = pat2_fall2[3];
      assign pat2_rise3[1] = pat2_rise3[3];
      assign pat2_fall3[1] = pat2_fall3[3];
	  assign pat2_rise0[0] = pat2_rise0[3];
      assign pat2_fall0[0] = pat2_fall0[3];
      assign pat2_rise1[0] = pat2_rise1[3];
      assign pat2_fall1[0] = pat2_fall1[3];
      assign pat2_rise2[0] = pat2_rise2[3];
      assign pat2_fall2[0] = pat2_fall2[3];
      assign pat2_rise3[0] = pat2_rise3[3];
      assign pat2_fall3[0] = pat2_fall3[3];
	  assign pat3_rise0[3] = 2'b00;
      assign pat3_fall0[3] = 2'b11;
      assign pat3_rise1[3] = 2'b00;
      assign pat3_fall1[3] = 2'b11;
      assign pat3_rise2[3] = 2'b11;
      assign pat3_fall2[3] = 2'b00;
      assign pat3_rise3[3] = 2'b00;
      assign pat3_fall3[3] = 2'b11;
      assign pat3_rise0[2] = pat3_rise0[3];
      assign pat3_fall0[2] = pat3_fall0[3];
      assign pat3_rise1[2] = pat3_rise1[3];
      assign pat3_fall1[2] = pat3_fall1[3];
      assign pat3_rise2[2] = pat3_rise2[3];
      assign pat3_fall2[2] = pat3_fall2[3];
      assign pat3_rise3[2] = pat3_rise3[3];
      assign pat3_fall3[2] = pat3_fall3[3];
      assign pat3_rise0[1] = pat3_rise0[3];
      assign pat3_fall0[1] = pat3_fall0[3];
      assign pat3_rise1[1] = pat3_rise1[3];
      assign pat3_fall1[1] = pat3_fall1[3];
      assign pat3_rise2[1] = pat3_rise2[3];
      assign pat3_fall2[1] = pat3_fall2[3];
      assign pat3_rise3[1] = pat3_rise3[3];
      assign pat3_fall3[1] = pat3_fall3[3];
	  assign pat3_rise0[0] = pat3_rise0[3];
      assign pat3_fall0[0] = pat3_fall0[3];
      assign pat3_rise1[0] = pat3_rise1[3];
      assign pat3_fall1[0] = pat3_fall1[3];
      assign pat3_rise2[0] = pat3_rise2[3];
      assign pat3_fall2[0] = pat3_fall2[3];
      assign pat3_rise3[0] = pat3_rise3[3];
      assign pat3_fall3[0] = pat3_fall3[3];
    end
  endgenerate
   generate
    genvar pt_i;
    for (pt_i = 0; pt_i < DRAM_WIDTH; pt_i = pt_i + 1) begin: gen_pat_match
      always @(posedge clk) begin
        if (sr_rise0_r[pt_i] == pat0_rise0[pt_i%4])
          pat0_match_rise0_r[pt_i] <= #TCQ 1'b1;
        else
          pat0_match_rise0_r[pt_i] <= #TCQ 1'b0;
        if (sr_fall0_r[pt_i] == pat0_fall0[pt_i%4])
          pat0_match_fall0_r[pt_i] <= #TCQ 1'b1;
        else
          pat0_match_fall0_r[pt_i] <= #TCQ 1'b0;
        if ((sr_rise1_r[pt_i] == pat0_rise1[pt_i%4]) || 
		    (nCK_PER_CLK == 2 && sr_rise1_r[pt_i] == pat0_fall1[pt_i%4]) )      
          pat0_match_rise1_r[pt_i] <= #TCQ 1'b1;
        else
          pat0_match_rise1_r[pt_i] <= #TCQ 1'b0;
        if ((sr_fall1_r[pt_i] == pat0_fall1[pt_i%4])  || 
		    (nCK_PER_CLK == 2 && sr_fall1_r[pt_i] == pat0_rise1[pt_i%4]))
          pat0_match_fall1_r[pt_i] <= #TCQ 1'b1;
        else
          pat0_match_fall1_r[pt_i] <= #TCQ 1'b0;
		if (sr_rise2_r[pt_i] == pat0_rise2[pt_i%4])
          pat0_match_rise2_r[pt_i] <= #TCQ 1'b1;
        else
          pat0_match_rise2_r[pt_i] <= #TCQ 1'b0;
		if (sr_fall2_r[pt_i] == pat0_fall2[pt_i%4])
          pat0_match_fall2_r[pt_i] <= #TCQ 1'b1;
        else
          pat0_match_fall2_r[pt_i] <= #TCQ 1'b0;
		if (sr_rise3_r[pt_i] == pat0_rise3[pt_i%4])
          pat0_match_rise3_r[pt_i] <= #TCQ 1'b1;
        else
          pat0_match_rise3_r[pt_i] <= #TCQ 1'b0;
		if (sr_fall3_r[pt_i] == pat0_fall3[pt_i%4])
          pat0_match_fall3_r[pt_i] <= #TCQ 1'b1;
        else
          pat0_match_fall3_r[pt_i] <= #TCQ 1'b0;
        if ((sr_rise0_r[pt_i] == pat1_rise0[pt_i%4]) || 
		    (nCK_PER_CLK == 2 && sr_rise0_r[pt_i] == pat1_fall0[pt_i%4]) ) 
          pat1_match_rise0_r[pt_i] <= #TCQ 1'b1;
        else
          pat1_match_rise0_r[pt_i] <= #TCQ 1'b0;
        if ((sr_fall0_r[pt_i] == pat1_fall0[pt_i%4]) || 
		    (nCK_PER_CLK == 2 && sr_fall0_r[pt_i] == pat1_rise0[pt_i%4]))    
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
		if (sr_rise2_r[pt_i] == pat1_rise2[pt_i%4])
          pat1_match_rise2_r[pt_i] <= #TCQ 1'b1;
        else
          pat1_match_rise2_r[pt_i] <= #TCQ 1'b0;
		if (sr_fall2_r[pt_i] == pat1_fall2[pt_i%4])
          pat1_match_fall2_r[pt_i] <= #TCQ 1'b1;
        else
          pat1_match_fall2_r[pt_i] <= #TCQ 1'b0;
		if (sr_rise3_r[pt_i] == pat1_rise3[pt_i%4])
          pat1_match_rise3_r[pt_i] <= #TCQ 1'b1;
        else
          pat1_match_rise3_r[pt_i] <= #TCQ 1'b0;
		if (sr_fall3_r[pt_i] == pat1_fall3[pt_i%4])
          pat1_match_fall3_r[pt_i] <= #TCQ 1'b1;
        else
          pat1_match_fall3_r[pt_i] <= #TCQ 1'b0;
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
		if (sr_rise2_r[pt_i] == pat2_rise2[pt_i%4])
          pat2_match_rise2_r[pt_i] <= #TCQ 1'b1;
        else
          pat2_match_rise2_r[pt_i] <= #TCQ 1'b0;
		if (sr_fall2_r[pt_i] == pat2_fall2[pt_i%4])
          pat2_match_fall2_r[pt_i] <= #TCQ 1'b1;
        else
          pat2_match_fall2_r[pt_i] <= #TCQ 1'b0;
		if (sr_rise3_r[pt_i] == pat2_rise3[pt_i%4])
          pat2_match_rise3_r[pt_i] <= #TCQ 1'b1;
        else
          pat2_match_rise3_r[pt_i] <= #TCQ 1'b0;
		if (sr_fall3_r[pt_i] == pat2_fall3[pt_i%4])
          pat2_match_fall3_r[pt_i] <= #TCQ 1'b1;
        else
          pat2_match_fall3_r[pt_i] <= #TCQ 1'b0;
        if (sr_rise0_r[pt_i] == pat3_rise0[pt_i%4]) 
          pat3_match_rise0_r[pt_i] <= #TCQ 1'b1;
        else
          pat3_match_rise0_r[pt_i] <= #TCQ 1'b0;
        if (sr_fall0_r[pt_i] == pat3_fall0[pt_i%4])    
          pat3_match_fall0_r[pt_i] <= #TCQ 1'b1;
        else
          pat3_match_fall0_r[pt_i] <= #TCQ 1'b0;
        if (sr_rise1_r[pt_i] == pat3_rise1[pt_i%4])
          pat3_match_rise1_r[pt_i] <= #TCQ 1'b1;
        else
          pat3_match_rise1_r[pt_i] <= #TCQ 1'b0;
        if (sr_fall1_r[pt_i] == pat3_fall1[pt_i%4])
          pat3_match_fall1_r[pt_i] <= #TCQ 1'b1;
        else
          pat3_match_fall1_r[pt_i] <= #TCQ 1'b0;
		if (sr_rise2_r[pt_i] == pat3_rise2[pt_i%4])
          pat3_match_rise2_r[pt_i] <= #TCQ 1'b1;
        else
          pat3_match_rise2_r[pt_i] <= #TCQ 1'b0;
		if (sr_fall2_r[pt_i] == pat3_fall2[pt_i%4])
          pat3_match_fall2_r[pt_i] <= #TCQ 1'b1;
        else
          pat3_match_fall2_r[pt_i] <= #TCQ 1'b0;
		if (sr_rise3_r[pt_i] == pat3_rise3[pt_i%4])
          pat3_match_rise3_r[pt_i] <= #TCQ 1'b1;
        else
          pat3_match_rise3_r[pt_i] <= #TCQ 1'b0;
		if (sr_fall3_r[pt_i] == pat3_fall3[pt_i%4])
          pat3_match_fall3_r[pt_i] <= #TCQ 1'b1;
        else
          pat3_match_fall3_r[pt_i] <= #TCQ 1'b0;  
      end
    end
  endgenerate
  always @(posedge clk) begin
    pat0_match_rise0_and_r <= #TCQ &pat0_match_rise0_r;
    pat0_match_fall0_and_r <= #TCQ &pat0_match_fall0_r;
    pat0_match_rise1_and_r <= #TCQ &pat0_match_rise1_r;
    pat0_match_fall1_and_r <= #TCQ &pat0_match_fall1_r;
	pat0_match_rise2_and_r <= #TCQ &pat0_match_rise2_r;
    pat0_match_fall2_and_r <= #TCQ &pat0_match_fall2_r;
	pat0_match_rise3_and_r <= #TCQ &pat0_match_rise3_r;
    pat0_match_fall3_and_r <= #TCQ &pat0_match_fall3_r;
	if (nCK_PER_CLK == 2) begin
      pat0_data_match_r <= #TCQ (pat0_match_rise0_and_r &&
                                 pat0_match_fall0_and_r &&
                                 pat0_match_rise1_and_r &&
                                 pat0_match_fall1_and_r);
	  pat0_data_rise_match_r <= #TCQ (pat0_match_rise0_and_r &&
	                                  pat0_match_rise1_and_r);
      pat0_data_fall_match_r <= #TCQ (pat0_match_fall0_and_r &&
	                                  pat0_match_fall1_and_r);
	end else begin
	  pat0_data_match_r <= #TCQ (pat0_match_rise0_and_r &&
                                 pat0_match_fall0_and_r &&
                                 pat0_match_rise1_and_r &&
                                 pat0_match_fall1_and_r &&
								 pat0_match_rise2_and_r &&
								 pat0_match_fall2_and_r &&
								 pat0_match_rise3_and_r &&
								 pat0_match_fall3_and_r);
	  pat0_data_rise_match_r <= #TCQ (pat0_match_rise0_and_r &&
	                                  pat0_match_rise1_and_r &&
									  pat0_match_rise2_and_r &&
									  pat0_match_rise3_and_r);
      pat0_data_fall_match_r <= #TCQ (pat0_match_fall0_and_r &&
	                                  pat0_match_fall1_and_r &&
									  pat0_match_fall2_and_r &&
									  pat0_match_fall3_and_r);
	end
  end
  always @(posedge clk) begin
    pat1_match_rise0_and_r <= #TCQ &pat1_match_rise0_r;
    pat1_match_fall0_and_r <= #TCQ &pat1_match_fall0_r;
    pat1_match_rise1_and_r <= #TCQ &pat1_match_rise1_r;
    pat1_match_fall1_and_r <= #TCQ &pat1_match_fall1_r;
	pat1_match_rise2_and_r <= #TCQ &pat1_match_rise2_r;
    pat1_match_fall2_and_r <= #TCQ &pat1_match_fall2_r;
	pat1_match_rise3_and_r <= #TCQ &pat1_match_rise3_r;
    pat1_match_fall3_and_r <= #TCQ &pat1_match_fall3_r;
	if (nCK_PER_CLK == 2) begin
      pat1_data_match_r <= #TCQ (pat1_match_rise0_and_r &&
                                 pat1_match_fall0_and_r &&
                                 pat1_match_rise1_and_r &&
                                 pat1_match_fall1_and_r);
      pat1_data_rise_match_r <= #TCQ (pat1_match_rise0_and_r && 
	                                  pat1_match_rise1_and_r);
      pat1_data_fall_match_r <= #TCQ (pat1_match_fall0_and_r && 
	                                  pat1_match_fall1_and_r);
    end else begin
	  pat1_data_match_r <= #TCQ (pat1_match_rise0_and_r &&
                                 pat1_match_fall0_and_r &&
                                 pat1_match_rise1_and_r &&
                                 pat1_match_fall1_and_r &&
								 pat1_match_rise2_and_r &&
                                 pat1_match_fall2_and_r &&
                                 pat1_match_rise3_and_r &&
                                 pat1_match_fall3_and_r);
      pat1_data_rise_match_r <= #TCQ (pat1_match_rise0_and_r && 
	                                  pat1_match_rise1_and_r &&
									  pat1_match_rise2_and_r &&
									  pat1_match_rise3_and_r);
      pat1_data_fall_match_r <= #TCQ (pat1_match_fall0_and_r && 
	                                  pat1_match_fall1_and_r &&
									  pat1_match_fall2_and_r &&
									  pat1_match_fall3_and_r);
	end
  end
  always @(posedge clk) begin
    pat2_match_rise0_and_r <= #TCQ &pat2_match_rise0_r;
    pat2_match_fall0_and_r <= #TCQ &pat2_match_fall0_r;
    pat2_match_rise1_and_r <= #TCQ &pat2_match_rise1_r;
    pat2_match_fall1_and_r <= #TCQ &pat2_match_fall1_r;
	pat2_match_rise2_and_r <= #TCQ &pat2_match_rise2_r;
    pat2_match_fall2_and_r <= #TCQ &pat2_match_fall2_r;
	pat2_match_rise3_and_r <= #TCQ &pat2_match_rise3_r;
    pat2_match_fall3_and_r <= #TCQ &pat2_match_fall3_r;
	if (nCK_PER_CLK == 2) begin
      pat2_data_match_r <= #TCQ (pat2_match_rise0_and_r &&
                                 pat2_match_fall0_and_r &&
                                 pat2_match_rise1_and_r &&
                                 pat2_match_fall1_and_r);
      pat2_data_rise_match_r <= #TCQ (pat2_match_rise0_and_r && 
	                                  pat2_match_rise1_and_r);
      pat2_data_fall_match_r <= #TCQ (pat2_match_fall0_and_r && 
	                                  pat2_match_fall1_and_r);
    end else begin
	  pat2_data_match_r <= #TCQ (pat2_match_rise0_and_r &&
                                 pat2_match_fall0_and_r &&
                                 pat2_match_rise1_and_r &&
                                 pat2_match_fall1_and_r &&
								 pat2_match_rise2_and_r &&
                                 pat2_match_fall2_and_r &&
                                 pat2_match_rise3_and_r &&
                                 pat2_match_fall3_and_r);
      pat2_data_rise_match_r <= #TCQ (pat2_match_rise0_and_r && 
	                                  pat2_match_rise1_and_r &&
									  pat2_match_rise2_and_r &&
									  pat2_match_rise3_and_r);
      pat2_data_fall_match_r <= #TCQ (pat2_match_fall0_and_r && 
	                                  pat2_match_fall1_and_r &&
									  pat2_match_fall2_and_r &&
									  pat2_match_fall3_and_r);
	end
  end
  always @(posedge clk) begin
    pat3_match_rise0_and_r <= #TCQ &pat3_match_rise0_r;
    pat3_match_fall0_and_r <= #TCQ &pat3_match_fall0_r;
    pat3_match_rise1_and_r <= #TCQ &pat3_match_rise1_r;
    pat3_match_fall1_and_r <= #TCQ &pat3_match_fall1_r;
	pat3_match_rise2_and_r <= #TCQ &pat3_match_rise2_r;
    pat3_match_fall2_and_r <= #TCQ &pat3_match_fall2_r;
	pat3_match_rise3_and_r <= #TCQ &pat3_match_rise3_r;
    pat3_match_fall3_and_r <= #TCQ &pat3_match_fall3_r;
	if (nCK_PER_CLK == 2) begin
      pat3_data_match_r <= #TCQ (pat3_match_rise0_and_r &&
                                 pat3_match_fall0_and_r &&
                                 pat3_match_rise1_and_r &&
                                 pat3_match_fall1_and_r);
      pat3_data_rise_match_r <= #TCQ (pat3_match_rise0_and_r && 
	                                  pat3_match_rise1_and_r);
      pat3_data_fall_match_r <= #TCQ (pat3_match_fall0_and_r && 
	                                  pat3_match_fall1_and_r);
    end else begin
	  pat3_data_match_r <= #TCQ (pat3_match_rise0_and_r &&
                                 pat3_match_fall0_and_r &&
                                 pat3_match_rise1_and_r &&
                                 pat3_match_fall1_and_r &&
								 pat3_match_rise2_and_r &&
                                 pat3_match_fall2_and_r &&
                                 pat3_match_rise3_and_r &&
                                 pat3_match_fall3_and_r);
      pat3_data_rise_match_r <= #TCQ (pat3_match_rise0_and_r && 
	                                  pat3_match_rise1_and_r &&
									  pat3_match_rise2_and_r &&
									  pat3_match_rise3_and_r);
      pat3_data_fall_match_r <= #TCQ (pat3_match_fall0_and_r && 
	                                  pat3_match_fall1_and_r &&
									  pat3_match_fall2_and_r &&
									  pat3_match_fall3_and_r);
	end
  end
  assign pat_match = (nCK_PER_CLK == 2) ? 
                       (pat0_data_match_r || pat1_data_match_r) :
					   (pat0_data_match_r || pat1_data_match_r || 
					    pat2_data_match_r || pat3_data_match_r);
  assign rise_match = (nCK_PER_CLK == 2) ? 
                       (pat0_data_rise_match_r || pat1_data_rise_match_r) :
					   (pat0_data_rise_match_r || pat1_data_rise_match_r || 
					    pat2_data_rise_match_r || pat3_data_rise_match_r);
  assign fall_match = (nCK_PER_CLK == 2) ? 
                       (pat0_data_fall_match_r || pat1_data_fall_match_r) :
					   (pat0_data_fall_match_r || pat1_data_fall_match_r || 
					    pat2_data_fall_match_r || pat3_data_fall_match_r);
  assign data_valid = (MEMORY_IO_DIR != "UNIDIR")? pat_match :
                          (~rise_detect_done)? rise_match:fall_match;
  always @(posedge clk)
    if (rst || ~rdlvl_stg1_start) begin
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
        if (data_valid && sr_rise0_r[z] == old_sr_rise0_r[z])
          old_sr_match_rise0_r[z] <= #TCQ 1'b1;
        else
          old_sr_match_rise0_r[z] <= #TCQ 1'b0;
        if (data_valid && sr_fall0_r[z] == old_sr_fall0_r[z])
          old_sr_match_fall0_r[z] <= #TCQ 1'b1;
        else
          old_sr_match_fall0_r[z] <= #TCQ 1'b0;
        if (data_valid && sr_rise1_r[z] == old_sr_rise1_r[z])
          old_sr_match_rise1_r[z] <= #TCQ 1'b1;
        else
          old_sr_match_rise1_r[z] <= #TCQ 1'b0;
        if (data_valid && sr_fall1_r[z] == old_sr_fall1_r[z])
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
        if (data_valid && sr_rise0_r[z] == prev_sr_rise0_r[z])
          prev_sr_match_rise0_r[z] <= #TCQ 1'b1;
        else
          prev_sr_match_rise0_r[z] <= #TCQ 1'b0;
        if (data_valid && sr_fall0_r[z] == prev_sr_fall0_r[z])
          prev_sr_match_fall0_r[z] <= #TCQ 1'b1;
        else
          prev_sr_match_fall0_r[z] <= #TCQ 1'b0;
        if (data_valid && sr_rise1_r[z] == prev_sr_rise1_r[z])
          prev_sr_match_rise1_r[z] <= #TCQ 1'b1;
        else
          prev_sr_match_rise1_r[z] <= #TCQ 1'b0;
        if (data_valid && sr_fall1_r[z] == prev_sr_fall1_r[z])
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
		if (nCK_PER_CLK == 2) begin
          old_sr_match_cyc2_r[z] <= #TCQ old_sr_match_rise0_r[z] &
                                         old_sr_match_fall0_r[z];
          prev_sr_match_cyc2_r[z] <= #TCQ prev_sr_match_rise0_r[z] &
                                          prev_sr_match_fall0_r[z];
		  old_rise_sr_match_cyc2_r[z] <= #TCQ old_sr_match_rise0_r[z];
          old_fall_sr_match_cyc2_r[z] <= #TCQ old_sr_match_fall0_r[z];
          prev_rise_sr_match_cyc2_r[z] <= #TCQ prev_sr_match_rise0_r[z];
          prev_fall_sr_match_cyc2_r[z] <= #TCQ prev_sr_match_fall0_r[z];
		end else begin
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
		  old_rise_sr_match_cyc2_r[z] <= #TCQ old_sr_match_rise0_r[z] &
		                                      old_sr_match_rise1_r[z] &
											  old_sr_match_rise2_r[z] &
											  old_sr_match_rise3_r[z];
          old_fall_sr_match_cyc2_r[z] <= #TCQ old_sr_match_fall0_r[z] &
                                              old_sr_match_fall1_r[z] &
											  old_sr_match_fall2_r[z] &
											  old_sr_match_fall3_r[z];
          prev_rise_sr_match_cyc2_r[z] <= #TCQ prev_sr_match_rise0_r[z] &
		                                       prev_sr_match_rise1_r[z] &
											   prev_sr_match_rise2_r[z] &
											   prev_sr_match_rise3_r[z];
          prev_fall_sr_match_cyc2_r[z] <= #TCQ prev_sr_match_fall0_r[z] &
		                                       prev_sr_match_fall1_r[z] &
											   prev_sr_match_fall2_r[z] &
											   prev_sr_match_fall3_r[z];
		end
        if (sr_valid_r2) begin 
          old_sr_diff_r[z]       <= #TCQ ~old_sr_match_cyc2_r[z];
          prev_sr_diff_r[z]      <= #TCQ ~prev_sr_match_cyc2_r[z];
          old_rise_sr_diff_r[z]  <= #TCQ ~old_rise_sr_match_cyc2_r[z];
          prev_rise_sr_diff_r[z] <= #TCQ ~prev_rise_sr_match_cyc2_r[z];     
          old_fall_sr_diff_r[z]  <= #TCQ ~old_fall_sr_match_cyc2_r[z];
          prev_fall_sr_diff_r[z] <= #TCQ ~prev_fall_sr_match_cyc2_r[z];
        end else begin 
          old_sr_diff_r[z]       <= #TCQ 'b0;
          prev_sr_diff_r[z]      <= #TCQ 'b0;
          old_rise_sr_diff_r[z]  <= #TCQ 'b0;
          prev_rise_sr_diff_r[z] <= #TCQ 'b0;
          old_fall_sr_diff_r[z]  <= #TCQ 'b0;
          prev_fall_sr_diff_r[z] <= #TCQ 'b0;
        end
     end
    end
  endgenerate
  always @(posedge clk)
    samp_edge_cnt0_en_r <= #TCQ 
                          (cal1_state_r == CAL1_DETECT_EDGE) ||
                          (cal1_state_r == CAL1_PB_DETECT_EDGE) ||
                          (cal1_state_r == CAL1_DETECT_EDGE_Q) || 
                           (cal1_state_r == CAL1_FALL_DETECT_EDGE) || 
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
      (cal1_state_r == CAL1_PB_DEC_CPT_LEFT_WAIT) || 
       (cal1_state_r == CAL1_IDEL_DEC_Q_WAIT) ||(cal1_state_r == CAL1_IDEL_DEC_Q_ALL_WAIT)|| (cal1_state_r == CAL1_FALL_INC_CPT_WAIT) || (cal1_state_r == CAL1_IDEL_FALL_DEC_CPT) ||
       (cal1_state_r ==  CAL1_FALL_DETECT_EDGE_WAIT)   ; 
  assign pb_detect_edge
    = (cal1_state_r == CAL1_DETECT_EDGE) ||
      (cal1_state_r == CAL1_PB_DETECT_EDGE) ||
      (cal1_state_r == CAL1_PB_DETECT_EDGE_DQ) ||
      (cal1_state_r == CAL1_DETECT_EDGE_Q)|| 
      (cal1_state_r == CAL1_FALL_DETECT_EDGE);
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
            end else if ((prev_sr_diff_r[z] && MEMORY_IO_DIR != "UNIDIR") ||
                          (prev_rise_sr_diff_r[z] && MEMORY_IO_DIR == "UNIDIR")) begin
              pb_cnt_eye_size_r[z]     <= #TCQ 3'b000;
              pb_found_stable_eye_r[z] <= #TCQ 1'b0;      
              pb_last_tap_jitter_r[z]  <= #TCQ 1'b1;          
              pb_found_edge_r[z]       <= #TCQ 1'b1;
              pb_found_first_edge_r[z] <= #TCQ 1'b1;          
              pb_detect_edge_done_r[z] <= #TCQ 1'b1;  
            end else if ( ((old_sr_diff_r[z] && MEMORY_IO_DIR != "UNIDIR") ||
                          (old_rise_sr_diff_r[z] && MEMORY_IO_DIR == "UNIDIR")) ||
                        pb_last_tap_jitter_r[z]) begin
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
  begin
    if (rst)
      phaser_taps_meet_fall_window <= #TCQ 1'b0;
    else if (tap_cnt_cpt_r - fall_win_det_start_taps_r >= 14) begin
      if (cal1_dlyce_cpt_r && cal1_dlyinc_cpt_r)
        phaser_taps_meet_fall_window <= #TCQ 1'b1;
    end else
      phaser_taps_meet_fall_window <= #TCQ 1'b0;
  end
  always @(posedge clk)
    if (rst || new_cnt_cpt_r)
      tap_limit_cpt_r <= #TCQ 1'b0;
    else if (tap_cnt_cpt_r == 6'd63) 
      tap_limit_cpt_r <= #TCQ 1'b1;
    always @(posedge clk)
    if (rst || new_cnt_cpt_r)
      cqn_tap_limit_cpt_r <= #TCQ 1'b0;
    else if (tap_cnt_cpt_r == 6'd63  && rise_detect_done) 
      cqn_tap_limit_cpt_r <= #TCQ 1'b1;
   always @(posedge clk)
    if (rst || new_cnt_cpt_r)
      idel_tap_cnt_cpt_r   <= #TCQ 'b0;
    else if (cal1_dlyce_q_r) begin
      if (cal1_dlyinc_q_r)
        idel_tap_cnt_cpt_r <= #TCQ idel_tap_cnt_cpt_r + 1;
      else
        idel_tap_cnt_cpt_r <= #TCQ idel_tap_cnt_cpt_r - 1;
    end
   always @(posedge clk)
    if (rst || new_cnt_cpt_r)
      idel_tap_limit_cpt_r <= #TCQ 1'b0;
    else if (idel_tap_cnt_cpt_r == 6'd31) 
      idel_tap_limit_cpt_r <= #TCQ 1'b1;
   always @(posedge clk)
    if (rst || new_cnt_cpt_r)
      cnt_rise_center_taps   <= #TCQ 'b0;
    else if (cal1_state_r == CAL1_FALL_DETECT_EDGE_WAIT) begin
      cnt_rise_center_taps   <= #TCQ tap_cnt_cpt_r;
    end
   always @(posedge clk)
     if (rst)
         cal1_cnt_cpt_2r        <= #TCQ 'b0;
     else    
         cal1_cnt_cpt_2r        <= #TCQ cal1_cnt_cpt_r;
  assign cal1_cnt_cpt_timing = {2'd0, cal1_cnt_cpt_2r};
   always @(posedge clk) begin
     if (rst) begin
       pi_rdlvl_dqs_tap_cnt_r <= #TCQ 'b0;
     end else if (
             (SIM_CAL_OPTION == "FAST_CAL") & 
             ( ((MEMORY_IO_DIR == "UNIDIR") && (cal1_state_r1 == CAL1_FALL_DETECT_EDGE_WAIT)) ||
               ((MEMORY_IO_DIR == "BIDIR")  && (cal1_state_r1 == CAL1_NEXT_DQS)))) begin
       for (p = 0; p < RANKS; p = p +1) begin: pi_rdlvl_dqs_tap_rank_cnt   
         for(q = 0; q < DQS_WIDTH; q = q +1) begin: rdlvl_dqs_tap_cnt
           pi_rdlvl_dqs_tap_cnt_r[((6*q)+(p*DQS_WIDTH*6))+:6] <= #TCQ tap_cnt_cpt_r;
         end
       end
     end else if (SIM_CAL_OPTION == "SKIP_CAL") begin
       for (j = 0; j < RANKS; j = j +1) begin: pi_rdlvl_dqs_tap_rnk_cnt   
         for(i = 0; i < DQS_WIDTH; i = i +1) begin: rdlvl_dqs_cnt
           pi_rdlvl_dqs_tap_cnt_r[((6*i)+(j*DQS_WIDTH*6))+:6] <= #TCQ SKIP_DLY_VAL ; 
         end
       end
     end else if ( ((MEMORY_IO_DIR == "UNIDIR") && (cal1_state_r1 == CAL1_FALL_DETECT_EDGE_WAIT)) ||
                   ((MEMORY_IO_DIR == "BIDIR")  && (cal1_state_r1 == CAL1_NEXT_DQS)) ) begin
         pi_rdlvl_dqs_tap_cnt_r[(((cal1_cnt_cpt_timing <<2) + (cal1_cnt_cpt_timing <<1))
         +(rnk_cnt_r*DQS_WIDTH*6))+:6]
           <= #TCQ tap_cnt_cpt_r;
     end
   end
   always @(posedge clk) begin
     if (rst) begin
       po_rdlvl_dqs_tap_cnt_r <= #TCQ 'b0;
     end else if ((SIM_CAL_OPTION == "FAST_CAL") && (cal1_state_r1 == CAL1_NEXT_DQS)) begin
       for (p = 0; p < RANKS; p = p +1) begin: po_rdlvl_dqs_tap_rank_cnt   
         for(q = 0; q < DQS_WIDTH; q = q +1) begin: rdlvl_dqs_tap_cnt
           po_rdlvl_dqs_tap_cnt_r[((6*q)+(p*DQS_WIDTH*6))+:6] <= #TCQ tap_cnt_cpt_r;
         end
       end
     end else if (SIM_CAL_OPTION == "SKIP_CAL") begin
       for (j = 0; j < RANKS; j = j +1) begin: po_rdlvl_dqs_tap_rnk_cnt   
         for(i = 0; i < DQS_WIDTH; i = i +1) begin: rdlvl_dqs_cnt
           po_rdlvl_dqs_tap_cnt_r[((6*i)+(j*DQS_WIDTH*6))+:6] <= #TCQ SKIP_DLY_VAL ; 
         end
       end
     end else if (cal1_state_r1 == CAL1_NEXT_DQS) begin
         po_rdlvl_dqs_tap_cnt_r[(((cal1_cnt_cpt_timing <<2) + (cal1_cnt_cpt_timing <<1))
         +(rnk_cnt_r*DQS_WIDTH*6))+:6]
           <= #TCQ tap_cnt_cpt_r ;
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
      cal1_dlyce_q_r        <= #TCQ 1'b0;
      cal1_dlyinc_q_r        <= #TCQ 1'b0;
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
      start_win_detect      <= #TCQ 1'b0;
      end_win_detect       <= #TCQ 1'b0;
      qdly_inc_done_r      <= #TCQ 1'b0;
      idelay_taps          <= #TCQ 'b0;
      start_win_taps       <= #TCQ 'b0;
      end_win_taps         <= #TCQ 'b0;
      idelay_inc_taps_r    <= #TCQ 'b0;
      clk_in_vld_win       <= #TCQ 1'b0;
      idel_dec_cntr        <= #TCQ 'b0;
      rise_detect_done     <= #TCQ 'b0;
      set_fall_capture_clock_at_tap0 <=#TCQ 1'b0;
      fall_first_edge_det_done  <= 1'b0;
      fall_win_det_start_taps_r <= #TCQ 'b0;
      fall_win_det_end_taps_r   <= #TCQ 'b0;
      dbg_stg1_calc_edge        <= #TCQ 'b0;
    end else begin
      case (cal1_state_r)
        CAL1_IDLE: begin
          rdlvl_rank_done_r <= #TCQ 1'b0;
		  pi_gap_enforcer   <= #TCQ PI_ADJ_GAP;
          if (rdlvl_start) begin
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
          cal1_prech_req_r  <= #TCQ 1'b0;
          if (!cal1_wait_r) begin
            store_sr_req_r <= #TCQ 1'b1;
            if (PER_BIT_DESKEW == "OFF")
              cal1_state_r <= #TCQ CAL1_STORE_FIRST_WAIT;
            else if (PER_BIT_DESKEW == "ON")
              cal1_state_r <= #TCQ CAL1_PB_STORE_FIRST_WAIT;
          end
        end
        CAL1_STORE_FIRST_WAIT:  
          if (!cal1_wait_r)
            cal1_state_r <= #TCQ CAL1_DETECT_EDGE_Q;
        CAL1_DETECT_EDGE_Q: begin  
            if (detect_edge_done_r && (idelay_taps > MIN_Q_VALID_TAPS) && (CLK_PERIOD > 2500) && (start_win_taps > 0) && idel_tap_limit_cpt_r ) begin
                   cal1_state_r <= #TCQ CAL1_IDEL_DEC_Q_ALL;  
                   idel_dec_cntr <= #TCQ ((idel_tap_cnt_cpt_r-1) - start_win_taps) >>1;                   
                   end_win_taps <= #TCQ idel_tap_cnt_cpt_r-1;
                   qdly_inc_done_r <= #TCQ 1;
            end else if (idel_tap_limit_cpt_r)
              cal1_state_r <= #TCQ CAL1_IDEL_DEC_Q;  
            else if (qdly_inc_done_r)   
              cal1_state_r <= #TCQ CAL1_IDEL_DEC_Q;   
            else if (~qdly_inc_done_r)
               if (data_valid && ~start_win_detect) begin
                   start_win_detect <= #TCQ 1'b1;
                   start_win_taps <= #TCQ idel_tap_cnt_cpt_r;
                   idelay_taps     <= #TCQ idelay_taps +1; 
                   cal1_state_r <= #TCQ CAL1_IDEL_STORE_OLD_Q; 
               end else if (start_win_detect && data_valid && ~detect_edge_done_r) begin
                   cal1_state_r <= #TCQ CAL1_IDEL_STORE_OLD_Q; 
                   idelay_taps     <= #TCQ idelay_taps + 1;
               end else if (detect_edge_done_r && (idelay_taps > MIN_Q_VALID_TAPS) && (CLK_PERIOD > 2500) && (start_win_taps == 0) ) begin
                   cal1_state_r <= #TCQ CAL1_IDEL_DEC_Q_ALL;  
                   idel_dec_cntr <= #TCQ idel_tap_cnt_cpt_r; 
                   end_win_taps <= #TCQ idel_tap_cnt_cpt_r-1;
                   qdly_inc_done_r <= #TCQ 1;
               end else if (detect_edge_done_r && (idelay_taps > MIN_Q_VALID_TAPS) && (CLK_PERIOD > 2500) && (start_win_taps > 0) ) begin
                   cal1_state_r <= #TCQ CAL1_IDEL_DEC_Q_ALL;  
                   idel_dec_cntr <= #TCQ ((idel_tap_cnt_cpt_r-1) - start_win_taps) >>1;                   
                   end_win_taps <= #TCQ idel_tap_cnt_cpt_r-1;
                   qdly_inc_done_r <= #TCQ 1;
               end else if (detect_edge_done_r && idelay_taps > MIN_Q_VALID_TAPS) begin
                   cal1_state_r <= #TCQ CAL1_IDEL_DEC_Q;  
                   end_win_taps <= #TCQ idel_tap_cnt_cpt_r-1;
                   qdly_inc_done_r <= #TCQ 1;
               end else if (~data_valid && idelay_taps <= MIN_Q_VALID_TAPS) begin
                   cal1_state_r <= #TCQ CAL1_IDEL_STORE_OLD_Q; 
                   start_win_detect <= #TCQ 1'b0;
                   idelay_taps     <= #TCQ 0;
               end else if (~data_valid && ~start_win_detect ) begin
                    cal1_state_r <= #TCQ CAL1_IDEL_STORE_OLD_Q; 
                    idelay_taps     <= #TCQ 0;
               end
        end
        CAL1_IDEL_STORE_OLD_Q: begin
          store_sr_req_r <= #TCQ 1'b1;
          if (store_sr_done_r)begin
            cal1_state_r <= #TCQ CAL1_IDEL_INC_Q;
            new_cnt_cpt_r <= #TCQ 1'b0;
          end
        end
        CAL1_IDEL_INC_Q: begin  
          cal1_state_r        <= #TCQ CAL1_IDEL_INC_Q_WAIT;
          if (~idel_tap_limit_cpt_r) begin
            cal1_dlyce_q_r    <= #TCQ 1'b1;
            cal1_dlyinc_q_r   <= #TCQ 1'b1;
          end else begin
            cal1_dlyce_q_r    <= #TCQ 1'b0;
            cal1_dlyinc_q_r   <= #TCQ 1'b0;
          end
        end
        CAL1_IDEL_INC_Q_WAIT: begin  
          cal1_dlyce_q_r    <= #TCQ 1'b0;
          cal1_dlyinc_q_r   <= #TCQ 1'b0; 
          if (!cal1_wait_r) 
             if (idelay_inc_taps_r > 0) begin  
                if (idel_tap_cnt_cpt_r == idelay_inc_taps_r) 
                   cal1_state_r <= #TCQ CAL1_IDEL_DEC_CPT; 
                else 
                   cal1_state_r <= #TCQ CAL1_IDEL_INC_Q;
             end else begin 
                cal1_state_r <= #TCQ CAL1_DETECT_EDGE_Q;  
             end
        end
        CAL1_IDEL_DEC_Q_ALL: begin
            cal1_state_r        <= #TCQ CAL1_IDEL_DEC_Q_ALL_WAIT;
            idel_dec_cntr      <= idel_dec_cntr -1;
            cal1_dlyce_q_r    <= #TCQ 1'b1;
            cal1_dlyinc_q_r   <= #TCQ 1'b0;
        end
        CAL1_IDEL_DEC_Q_ALL_WAIT: begin
          cal1_dlyce_q_r    <= #TCQ 1'b0;
          cal1_dlyinc_q_r   <= #TCQ 1'b0; 
          if (!cal1_wait_r) begin
              if ((idel_dec_cntr == 6'h00) && (start_win_taps == 0))
                    cal1_state_r <= #TCQ CAL1_DETECT_EDGE;
              else  if ((idel_dec_cntr == 6'h00) && (start_win_taps > 0))
                    cal1_state_r <= #TCQ CAL1_NEXT_DQS;
              else 
                    cal1_state_r <= #TCQ CAL1_IDEL_DEC_Q_ALL;
          end 
        end
        CAL1_IDEL_DEC_Q: begin
            cal1_state_r        <= #TCQ CAL1_IDEL_DEC_Q_WAIT;
            cal1_dlyce_q_r    <= #TCQ 1'b1;
            cal1_dlyinc_q_r   <= #TCQ 1'b0;
        end
        CAL1_IDEL_DEC_Q_WAIT: begin
          cal1_dlyce_q_r    <= #TCQ 1'b0;
          cal1_dlyinc_q_r   <= #TCQ 1'b0; 
          if (!cal1_wait_r)
            cal1_state_r <= #TCQ CAL1_DETECT_EDGE;
        end
        CAL1_DETECT_EDGE: begin
          if (detect_edge_done_r) begin
             if (tap_limit_cpt_r) begin
                if (~found_first_edge_r) begin 
                   first_edge_taps_r <= #TCQ tap_cnt_cpt_r; 
                end
                cal1_state_r <= #TCQ CAL1_CALC_IDEL_WAIT;  
             end else if (found_edge_r && ~data_valid) begin 
                   found_first_edge_r <= #TCQ 1'b1;
                   if (found_first_edge_r && found_stable_eye_last_r) begin
                     found_second_edge_r <= #TCQ 1'b1;
                     second_edge_taps_r <= #TCQ tap_cnt_cpt_r - 1;
                     cal1_state_r <= #TCQ CAL1_CALC_IDEL_WAIT;    
                   end else if ((CLK_PERIOD <= 2500) && (tap_cnt_cpt_r < MIN_EYE_SIZE)) begin
                      first_edge_taps_r <= #TCQ tap_cnt_cpt_r;
                      cal1_state_r <= #TCQ CAL1_IDEL_STORE_OLD;
                   end else begin
                      first_edge_taps_r <= #TCQ tap_cnt_cpt_r;
                      cal1_state_r <= #TCQ CAL1_CALC_IDEL_WAIT;  
                   end
             end else begin
              cal1_state_r <= #TCQ CAL1_IDEL_STORE_OLD;
             end
          end
        end
        CAL1_IDEL_STORE_OLD: begin
          store_sr_req_r <= #TCQ 1'b1;
          if (store_sr_done_r)begin
            cal1_state_r <= #TCQ CAL1_IDEL_INC_CPT;
            new_cnt_cpt_r <= #TCQ 1'b0;
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
        CAL1_CALC_IDEL_WAIT: begin  
          if (!cal1_wait_r)
            cal1_state_r <= #TCQ CAL1_CALC_IDEL;
        end
        CAL1_CALC_IDEL: begin 
          if (CLK_PERIOD > 2500 && (start_win_taps == 0) ) begin 
                    if (idel_gt_phaser_delay) begin
                         if (idel_minus_phaser_delay < 2)  begin   
                             idelay_inc_taps_r  <= #TCQ 0; 
                             cnt_idel_dec_cpt_r <= #TCQ tap_cnt_cpt_r; 
                             cal1_state_r       <= #TCQ CAL1_IDEL_DEC_CPT;
                         end else begin
                            idelay_inc_taps_r <= (idel_minus_phaser_delay >> 1); 
                            cnt_idel_dec_cpt_r <= #TCQ tap_cnt_cpt_r; 
                            cal1_state_r      <= #TCQ CAL1_IDEL_INC_Q;   
                         end  
                    end else begin 
                          idelay_inc_taps_r <=  #TCQ 0; 
                          cnt_idel_dec_cpt_r  <= #TCQ tap_cnt_cpt_r - phaser_dec_taps;
                          cal1_state_r <= #TCQ CAL1_IDEL_DEC_CPT;        
                    end    
          end else begin          
             if (found_second_edge_r) begin 
                  cnt_idel_dec_cpt_r <=  #TCQ ((second_edge_taps_r - first_edge_taps_r)>>1) + 1;   
                  dbg_stg1_calc_edge[2] <= #TCQ 'b1;
             end else if (first_edge_taps_r <= MIN_EYE_SIZE) begin
                    cnt_idel_dec_cpt_r <=  #TCQ (32 - first_edge_taps_r);
                    dbg_stg1_calc_edge[0] <= #TCQ 'b1;
             end else if (first_edge_taps_r > MIN_EYE_SIZE) begin
                    cnt_idel_dec_cpt_r <=  #TCQ ((tap_cnt_cpt_r - first_edge_taps_r) + (first_edge_taps_r)>>1) ;
                    dbg_stg1_calc_edge[1] <= #TCQ 'b1;
             end else begin
                    cnt_idel_dec_cpt_r  <=  #TCQ ((tap_cnt_cpt_r)>>1) + 1;     
                    dbg_stg1_calc_edge[3] <= #TCQ 'b1;
             end  
            cal1_state_r <= #TCQ CAL1_IDEL_DEC_CPT; 
          end
        end
        CAL1_IDEL_DEC_CPT: begin  
          cal1_dlyce_cpt_r  <= #TCQ 1'b1;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
		  pi_gap_enforcer   <= #TCQ PI_ADJ_GAP;
          cnt_idel_dec_cpt_r <= #TCQ cnt_idel_dec_cpt_r - 1;
          if ((cnt_idel_dec_cpt_r == 6'b000001)  && 
                     ((MEMORY_IO_DIR == "BIDIR") || ((MEMORY_IO_DIR == "UNIDIR") &&  (CLK_PERIOD > 2500)))) begin
             if (CPT_CLK_CQ_ONLY == "FALSE")  
                 cal1_state_r <= #TCQ CAL1_FALL_DETECT_EDGE_WAIT;
             else
                 cal1_state_r <= #TCQ CAL1_NEXT_DQS;
             rise_detect_done <= #TCQ 1'b1;
          end else if ((cnt_idel_dec_cpt_r == 6'b000001)  && (CLK_PERIOD <= 2500)) begin
             rise_detect_done <= #TCQ 1'b1;
             cal1_state_r <= #TCQ CAL1_FALL_DETECT_EDGE_WAIT;   
          end else begin
            cal1_state_r <= #TCQ CAL1_IDEL_DEC_CPT_WAIT;  
          end        end
        CAL1_IDEL_DEC_CPT_WAIT: begin  
          cal1_dlyce_cpt_r  <= #TCQ 1'b0;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
		  if (pi_gap_enforcer != 'b0)
		    pi_gap_enforcer   <= #TCQ pi_gap_enforcer - 1;
		  else
		    pi_gap_enforcer   <= #TCQ pi_gap_enforcer;
		  if (pi_gap_enforcer == 'b0)
            cal1_state_r <= #TCQ CAL1_IDEL_DEC_CPT;
		  else
		    cal1_state_r <= #TCQ CAL1_IDEL_DEC_CPT_WAIT;
        end
        CAL1_FALL_DETECT_EDGE_WAIT: begin  
          cal1_dlyce_cpt_r  <= #TCQ 1'b0;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
		  if (pi_gap_enforcer != 'b0)
		    pi_gap_enforcer   <= #TCQ pi_gap_enforcer - 1;
		  else
		    pi_gap_enforcer   <= #TCQ pi_gap_enforcer;
		  if (pi_gap_enforcer == 'b0)
            cal1_state_r <= #TCQ CAL1_IDEL_FALL_DEC_CPT;
		  else
		    cal1_state_r <= #TCQ CAL1_FALL_DETECT_EDGE_WAIT;
        end 
       CAL1_IDEL_FALL_DEC_CPT: begin  
          cal1_dlyce_cpt_r  <= #TCQ 1'b1;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
		  pi_gap_enforcer   <= #TCQ PI_ADJ_GAP;
          if (tap_cnt_cpt_r == 6'h03) 
              cal1_state_r <= CAL1_FALL_DETECT_EDGE;
          else 
            cal1_state_r <= #TCQ CAL1_IDEL_FALL_DEC_CPT_WAIT;
        end
        CAL1_IDEL_FALL_DEC_CPT_WAIT: begin
          cal1_dlyce_cpt_r  <= #TCQ 1'b0;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
		  if (pi_gap_enforcer != 'b0)
		    pi_gap_enforcer   <= #TCQ pi_gap_enforcer - 1;
		  else
		    pi_gap_enforcer   <= #TCQ pi_gap_enforcer;
		  if (pi_gap_enforcer == 'b0)
            cal1_state_r <= #TCQ CAL1_IDEL_FALL_DEC_CPT;
		  else
		    cal1_state_r <= #TCQ CAL1_IDEL_FALL_DEC_CPT_WAIT;
        end  
      CAL1_FALL_DETECT_EDGE : begin  
          cal1_dlyce_cpt_r  <= #TCQ 1'b0;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
          if (detect_edge_done_r) begin
            if (cqn_tap_limit_cpt_r) begin
                fall_win_det_end_taps_r <= #TCQ tap_cnt_cpt_r;
                cal1_state_r <= #TCQ CAL1_FALL_CALC_DELAY;
            end else if  (fall_first_edge_det_done && ~data_valid && ((tap_cnt_cpt_r - fall_win_det_start_taps_r) > 8)) begin   
                  if ((tap_cnt_cpt_r - 4 ) <= first_edge_taps_r[5:1]) begin
                     cal1_state_r <= #TCQ CAL1_FALL_IDEL_INC_Q;
                     stored_idel_tap_cnt_cpt_r <= idel_tap_cnt_cpt_r;
                     end
                else begin
                     cal1_state_r <= #TCQ CAL1_FALL_CALC_DELAY;
                end
                     fall_win_det_end_taps_r <= #TCQ tap_cnt_cpt_r - 1;
           end else if (~fall_first_edge_det_done && data_valid && fall_win_det_start_taps_r == 6'h00) begin
               fall_win_det_start_taps_r <= #TCQ tap_cnt_cpt_r;
               fall_first_edge_det_done  <= 1'b0;
               cal1_state_r <= #TCQ CAL1_FALL_IDEL_STORE_OLD;   
           end else if (~fall_first_edge_det_done && data_valid && ((tap_cnt_cpt_r - fall_win_det_start_taps_r) >= 6'h0A)) begin
                fall_first_edge_det_done  <= 1'b1;
                cal1_state_r <= #TCQ CAL1_FALL_IDEL_STORE_OLD;   
           end else if (~fall_first_edge_det_done && ~data_valid && ((tap_cnt_cpt_r - fall_win_det_start_taps_r) < 6'h0A)) begin
                fall_win_det_start_taps_r <= #TCQ 6'h00;
                fall_first_edge_det_done  <= 1'b0;
                cal1_state_r <= #TCQ CAL1_FALL_IDEL_STORE_OLD;     
            end else begin
                cal1_state_r <= #TCQ CAL1_FALL_IDEL_STORE_OLD;      
            end
         end
       end
       CAL1_FALL_IDEL_STORE_OLD : begin
                 store_sr_req_r <= #TCQ 1'b1;
                 if (store_sr_done_r)begin
                         cal1_state_r <= #TCQ CAL1_FALL_INC_CPT;
                         new_cnt_cpt_r <= #TCQ 1'b0;
                 end
        end
       CAL1_FALL_INC_CPT: begin  
           cal1_state_r          <= #TCQ CAL1_FALL_INC_CPT_WAIT;
          if (~cqn_tap_limit_cpt_r) begin
            cal1_dlyce_cpt_r    <= #TCQ 1'b1;
            cal1_dlyinc_cpt_r   <= #TCQ 1'b1;
          end else begin
            cal1_dlyce_cpt_r    <= #TCQ 1'b0;
            cal1_dlyinc_cpt_r   <= #TCQ 1'b0;
          end
        end
       CAL1_FALL_INC_CPT_WAIT: begin  
          cal1_dlyce_cpt_r    <= #TCQ 1'b0;
          cal1_dlyinc_cpt_r   <= #TCQ 1'b0; 
          if (!cal1_wait_r)
            cal1_state_r <= #TCQ CAL1_FALL_DETECT_EDGE;
        end
       CAL1_FALL_CALC_DELAY:  begin 
            if (fall_win_det_start_taps_r > 6'h28) 
               fall_dec_taps_r <= 6'h01;
            else if (set_fall_capture_clock_at_tap0)
                 fall_dec_taps_r <= #TCQ fall_win_det_end_taps_r;
            else begin  
               fall_dec_taps_r <= ( fall_win_det_end_taps_r - fall_win_det_start_taps_r) >> 1;
            end
            cal1_state_r <= #TCQ CAL1_FALL_FINAL_DEC_TAP;
         end
        CAL1_FALL_FINAL_DEC_TAP: begin 
          cal1_dlyce_cpt_r  <= #TCQ 1'b1;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
		  pi_gap_enforcer   <= #TCQ PI_ADJ_GAP;
          fall_dec_taps_r <= #TCQ fall_dec_taps_r - 1;
          if (fall_dec_taps_r == 6'b000001)  begin
            cal1_state_r <= #TCQ CAL1_NEXT_DQS;   
          end else begin
            cal1_state_r <= #TCQ CAL1_FALL_FINAL_DEC_TAP_WAIT;  
          end
        end
        CAL1_FALL_FINAL_DEC_TAP_WAIT: begin  
          cal1_dlyce_cpt_r  <= #TCQ 1'b0;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
		  if (pi_gap_enforcer != 'b0)
		    pi_gap_enforcer   <= #TCQ pi_gap_enforcer - 1;
		  else
		    pi_gap_enforcer   <= #TCQ pi_gap_enforcer;
		  if (pi_gap_enforcer == 'b0)
            cal1_state_r <= #TCQ CAL1_FALL_FINAL_DEC_TAP;
		  else
		    cal1_state_r <= #TCQ CAL1_FALL_FINAL_DEC_TAP_WAIT;
       end         
        CAL1_FALL_IDEL_INC_Q: begin  
          cal1_state_r        <= #TCQ CAL1_FALL_IDEL_INC_Q_WAIT;
          if (~idel_tap_limit_cpt_r) begin
            cal1_dlyce_q_r    <= #TCQ 1'b1;
            cal1_dlyinc_q_r   <= #TCQ 1'b1;
          end else begin
            cal1_dlyce_q_r    <= #TCQ 1'b0;
            cal1_dlyinc_q_r   <= #TCQ 1'b0;
          end
        end
        CAL1_FALL_IDEL_INC_Q_WAIT: begin  
          cal1_dlyce_q_r    <= #TCQ 1'b0;
          cal1_dlyinc_q_r   <= #TCQ 1'b0; 
          if (!cal1_wait_r) 				 
             if (fall_match &&  ( idel_tap_cnt_cpt_r - stored_idel_tap_cnt_cpt_r) < 2 ) begin  
                   cal1_state_r <= #TCQ CAL1_FALL_IDEL_INC_Q;  
             end else begin 
                if (fall_match)
                    set_fall_capture_clock_at_tap0 <= 1'b1;
                else
                    set_fall_capture_clock_at_tap0 <= 1'b0;
                cal1_state_r <= #TCQ CAL1_FALL_IDEL_RESTORE_Q;  
             end
        end
        CAL1_FALL_IDEL_RESTORE_Q: begin  
          cal1_state_r        <= #TCQ CAL1_FALL_IDEL_RESTORE_Q_WAIT;
          if (~idel_tap_limit_cpt_r) begin
            cal1_dlyce_q_r    <= #TCQ 1'b1;
            cal1_dlyinc_q_r   <= #TCQ 1'b0;
          end else begin
            cal1_dlyce_q_r    <= #TCQ 1'b0;
            cal1_dlyinc_q_r   <= #TCQ 1'b0;
          end
        end
         CAL1_FALL_IDEL_RESTORE_Q_WAIT: begin  
          cal1_dlyce_q_r    <= #TCQ 1'b0;
          cal1_dlyinc_q_r   <= #TCQ 1'b0; 
          if (!cal1_wait_r) 
             if (idel_tap_cnt_cpt_r != stored_idel_tap_cnt_cpt_r) begin  
                   cal1_state_r <= #TCQ CAL1_FALL_IDEL_RESTORE_Q;  
             end else begin 
                cal1_state_r <= #TCQ CAL1_FALL_CALC_DELAY;  
             end
        end
        CAL1_NEXT_DQS: begin
          cal1_prech_req_r  <= #TCQ 1'b1;
          cal1_dlyce_cpt_r  <= #TCQ 1'b0;
          cal1_dlyinc_cpt_r <= #TCQ 1'b0;
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
              new_cnt_cpt_r     <= #TCQ 1'b1;
              qdly_inc_done_r   <= #TCQ 1'b0;   
              start_win_taps    <= #TCQ 'b0;
              end_win_taps      <= #TCQ 'b0;
              idelay_taps       <= #TCQ 'b0;
              idelay_inc_taps_r <= #TCQ 'b0;
              idel_dec_cntr     <= #TCQ 'b0;
              rise_detect_done  <= #TCQ 'b0;
              fall_first_edge_det_done  <= 1'b0;
              fall_win_det_start_taps_r <= #TCQ 'b0;
              fall_win_det_end_taps_r   <= #TCQ 'b0;
              cal1_cnt_cpt_r    <= #TCQ cal1_cnt_cpt_r + 1;
              dbg_stg1_calc_edge <= #TCQ 0; 
              cal1_state_r      <= #TCQ CAL1_NEW_DQS_WAIT;
            end
          end
        end
        CAL1_REGL_LOAD: begin
          rdlvl_rank_done_r <= #TCQ 1'b0;
          cal1_prech_req_r  <= #TCQ 1'b0;
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
       default : begin
          cal1_state_r <= #TCQ CAL1_IDLE;
       end
      endcase
    end
  genvar nd_i;
  generate
    for (nd_i=0; nd_i < DQS_WIDTH; nd_i=nd_i+1) begin : nd_rdlvl_err
      always @ (posedge clk)
      begin	
	    if (rst)
	      dbg_phy_rdlvl_err[nd_i] <= #TCQ 'b0;
	    else if (nd_i == cal1_cnt_cpt_r)
	      dbg_phy_rdlvl_err[nd_i] <= #TCQ dbg_stg1_calc_edge[0];
        else
	      dbg_phy_rdlvl_err[nd_i] <= #TCQ dbg_phy_rdlvl_err[nd_i];
      end
	end
  endgenerate 
endmodule
