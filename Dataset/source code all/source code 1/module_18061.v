`timescale 1ps/1ps
`timescale 1ps/1ps
module phy_init #
  (
   parameter TCQ          = 100,
   parameter nCK_PER_CLK  = 4,           
   parameter CLK_PERIOD   = 3000,        
   parameter PRBS_WIDTH   = 64,          
   parameter BANK_WIDTH   = 2,
   parameter COL_WIDTH    = 10,
   parameter nCS_PER_RANK = 1,           
   parameter DQ_WIDTH     = 64,
   parameter DQS_WIDTH    = 8,
   parameter DQS_CNT_WIDTH   = 3,        
   parameter ROW_WIDTH    = 14,
   parameter CS_WIDTH     = 1,
   parameter RANKS        = 1,       
   parameter CKE_WIDTH    = 1,       
   parameter DRAM_TYPE    = "DDR3",
   parameter REG_CTRL     = "ON",
   parameter CALIB_ROW_ADD   = 16'h0000,
   parameter CALIB_COL_ADD   = 12'h000, 
   parameter CALIB_BA_ADD    = 3'h0,    
   parameter AL               = "0",     
   parameter BURST_MODE       = "8",     
   parameter BURST_TYPE       = "SEQ",   
   parameter nCL              = 5,       
   parameter nCWL             = 5,       
   parameter tRFC             = 110000,  
   parameter OUTPUT_DRV       = "HIGH",  
   parameter RTT_NOM          = "60",    
   parameter RTT_WR           = "60",    
   parameter WRLVL            = "ON",    
   parameter DDR2_DQSN_ENABLE = "YES",   
   parameter nSLOTS           = 1,       
   parameter SIM_INIT_OPTION  = "NONE",  
   parameter SIM_CAL_OPTION   = "NONE"   
   )
  (
   input                       clk,
   input                       rst,
   input [PRBS_WIDTH-1:0]      prbs_o,
   input                       pi_phaselocked,
   input                       pi_phase_locked_all,
   input                       pi_dqs_found_done,
   output                      pi_calib_done,
   input                       phy_if_empty,
   input                       dqs_dly_done,
   input                       wrlvl_done,
   input                       wrlvl_rank_done,
   input                       done_dqs_tap_inc,
   input [5:0]                 rd_data_offset,
   input [6*RANKS-1:0]         rd_data_offset_ranks,
   input                       pi_dqs_found_rank_done,
   input                       wrcal_done,
   input                       wrcal_prech_req,
   input [7:0]                 slot_0_present,
   input [7:0]                 slot_1_present,
   output reg                  wl_sm_start,
   output reg                  wr_lvl_start,
   output reg                  wrcal_start,
   input                       rdlvl_stg1_done,
   input                       rdlvl_stg1_rank_done,
   output reg                  rdlvl_stg1_start,
   output reg                  pi_dqs_found_start,
   output reg                  detect_pi_found_dqs,
   input                       rdlvl_prech_req,
   input                       wrcal_resume,
   output reg                  prech_done,
   output reg                  init_calib_complete, 
   output reg [nCK_PER_CLK*ROW_WIDTH-1:0] phy_address,
   output reg [nCK_PER_CLK*BANK_WIDTH-1:0]phy_bank,
   output reg [nCK_PER_CLK-1:0] phy_ras_n,
   output reg [nCK_PER_CLK-1:0] phy_cas_n,
   output reg [nCK_PER_CLK-1:0] phy_we_n,
   output reg                   phy_reset_n,
   output [CS_WIDTH*nCS_PER_RANK*nCK_PER_CLK-1:0]   phy_cs_n,
   input                       phy_ctl_ready,
   input                       phy_ctl_full,
   input                       phy_cmd_full,
   input                       phy_data_full,
   output reg                  calib_ctl_wren,
   output reg                  calib_cmd_wren,
   output reg [1:0]            calib_seq,
   output reg                  write_calib,
   output reg                  read_calib,
   output reg [2:0]            calib_cmd,
   output reg [3:0]            calib_aux_out0,
   output reg [3:0]            calib_aux_out1,
   output [1:0]                calib_rank_cnt,
   output reg [5:0]            calib_data_offset,
   output reg                  calib_wrdata_en,
   output reg [2*nCK_PER_CLK*DQ_WIDTH-1:0] phy_wrdata,
   output                      phy_rddata_en,
   output                      phy_rddata_valid
   );
  localparam NUM_STG1_WR_RD = (BURST_MODE == "8") ? 128 :
                              (BURST_MODE == "4") ? 256 : 128;
  localparam ADDR_INC = (BURST_MODE == "8") ? 8 :
                        (BURST_MODE == "4") ? 4 : 8; 
  localparam RTT_NOM2 = "40";
  localparam RTT_NOM3 = "40";
  localparam BURST4_FLAG = (DRAM_TYPE == "DDR3")? 1'b0 : 
             (BURST_MODE == "8") ? 1'b0 : 
             ((BURST_MODE == "4") ? 1'b1 : 1'b0);
  localparam CLK_MEM_PERIOD = CLK_PERIOD / nCK_PER_CLK;
  localparam DDR3_RESET_DELAY_NS   = 200000;
  localparam DDR3_CKE_DELAY_NS     = 500000 + DDR3_RESET_DELAY_NS;
  localparam DDR2_CKE_DELAY_NS     = 200000;
  localparam PWRON_RESET_DELAY_CNT = 
             ((DDR3_RESET_DELAY_NS+CLK_PERIOD-1)/CLK_PERIOD);
  localparam PWRON_CKE_DELAY_CNT   = (DRAM_TYPE == "DDR3") ?
             (((DDR3_CKE_DELAY_NS+CLK_PERIOD-1)/CLK_PERIOD)) :
             (((DDR2_CKE_DELAY_NS+CLK_PERIOD-1)/CLK_PERIOD));
   localparam DDR2_INIT_PRE_DELAY_PS = 400000;
   localparam DDR2_INIT_PRE_CNT = 
              ((DDR2_INIT_PRE_DELAY_PS+CLK_PERIOD-1)/CLK_PERIOD)-1;
  localparam TXPR_DELAY_CNT =
             (5*CLK_MEM_PERIOD > tRFC+10000) ?
             (((5+nCK_PER_CLK-1)/nCK_PER_CLK)-1)+11 :
             (((tRFC+10000+CLK_PERIOD-1)/CLK_PERIOD)-1)+11;
  localparam TDLLK_TZQINIT_DELAY_CNT = 255;
  localparam TWR_CYC = ((15000) %  CLK_MEM_PERIOD) ?
                       (15000/CLK_MEM_PERIOD) + 1 : 15000/CLK_MEM_PERIOD;
  localparam  CNTNEXT_CMD = (nCK_PER_CLK == 4) ? 7'b1100110 : 7'b1111111;
  localparam  INIT_CNT_MR2     = 2'b00;
  localparam  INIT_CNT_MR3     = 2'b01;
  localparam  INIT_CNT_MR1     = 2'b10;
  localparam  INIT_CNT_MR0     = 2'b11;
  localparam  INIT_CNT_MR_DONE = 2'b11;
  localparam  REG_RC0 = 8'b00000000;
  localparam REG_RC1 = (RANKS <= 2) ? 8'b00110001 : 8'b00000001;
  localparam REG_RC2 = 8'b00000010;
   localparam REG_RC3 = 8'b00000011;
   localparam REG_RC4 = 8'b00000100;
   localparam REG_RC5 = 8'b00000101;   
   localparam nAL = (AL == "CL-1") ? nCL - 1 : 0;   
   localparam CWL_M = (REG_CTRL == "ON") ? nCWL + nAL + 1 : nCWL + nAL;
  localparam  INIT_IDLE                  = 6'b000000; 
  localparam  INIT_WAIT_CKE_EXIT         = 6'b000001; 
  localparam  INIT_LOAD_MR               = 6'b000010; 
  localparam  INIT_LOAD_MR_WAIT          = 6'b000011; 
  localparam  INIT_ZQCL                  = 6'b000100; 
  localparam  INIT_WAIT_DLLK_ZQINIT      = 6'b000101; 
  localparam  INIT_WRLVL_START           = 6'b000110; 
  localparam  INIT_WRLVL_WAIT            = 6'b000111; 
  localparam  INIT_WRLVL_LOAD_MR         = 6'b001000; 
  localparam  INIT_WRLVL_LOAD_MR_WAIT    = 6'b001001; 
  localparam  INIT_WRLVL_LOAD_MR2        = 6'b001010; 
  localparam  INIT_WRLVL_LOAD_MR2_WAIT   = 6'b001011; 
  localparam  INIT_RDLVL_ACT             = 6'b001100; 
  localparam  INIT_RDLVL_ACT_WAIT        = 6'b001101; 
  localparam  INIT_RDLVL_STG1_WRITE      = 6'b001110; 
  localparam  INIT_RDLVL_STG1_WRITE_READ = 6'b001111; 
  localparam  INIT_RDLVL_STG1_READ       = 6'b010000; 
  localparam  INIT_RDLVL_STG2_READ       = 6'b010001; 
  localparam  INIT_RDLVL_STG2_READ_WAIT  = 6'b010010; 
  localparam  INIT_PRECHARGE_PREWAIT     = 6'b010011; 
  localparam  INIT_PRECHARGE             = 6'b010100; 
  localparam  INIT_PRECHARGE_WAIT        = 6'b010101; 
  localparam  INIT_DONE                  = 6'b010110; 
  localparam  INIT_DDR2_PRECHARGE        = 6'b010111; 
  localparam  INIT_DDR2_PRECHARGE_WAIT   = 6'b011000; 
  localparam  INIT_REFRESH               = 6'b011001; 
  localparam  INIT_REFRESH_WAIT          = 6'b011010; 
  localparam  INIT_REG_WRITE             = 6'b011011; 
  localparam  INIT_REG_WRITE_WAIT        = 6'b011100; 
  localparam  INIT_DDR2_MULTI_RANK       = 6'b011101; 
  localparam  INIT_DDR2_MULTI_RANK_WAIT  = 6'b011110; 
  localparam  INIT_WRCAL_ACT             = 6'b011111; 
  localparam  INIT_WRCAL_ACT_WAIT        = 6'b100000; 
  localparam  INIT_WRCAL_WRITE           = 6'b100001; 
  localparam  INIT_WRCAL_WRITE_READ      = 6'b100010; 
  localparam  INIT_WRCAL_READ            = 6'b100011; 
  localparam  INIT_WRCAL_READ_WAIT       = 6'b100100; 
  localparam  INIT_PI_PHASELOCK_READS    = 6'b100101; 
  integer i, j, k, l, m, n, p; 
  reg         stg1_wr_done;
  reg         pi_dqs_found_done_r1;
  reg         pi_dqs_found_rank_done_r;
  reg         dqs_dly_done_r1;
  reg         read_calib_int;
  reg         read_calib_r;
  reg         pi_calib_done_r;
  reg         burst_addr_r;  
  reg [1:0]   chip_cnt_r;
  reg [6:0]   cnt_cmd_r;
  reg         cnt_cmd_done_r;  
  reg [7:0]   cnt_dllk_zqinit_r;
  reg         cnt_dllk_zqinit_done_r;
  reg         cnt_init_af_done_r;  
  reg [1:0]   cnt_init_af_r;
  reg [1:0]   cnt_init_data_r;  
  reg [1:0]   cnt_init_mr_r;
  reg         cnt_init_mr_done_r;
  reg         cnt_init_pre_wait_done_r;
  reg [7:0]   cnt_init_pre_wait_r; 
  reg [9:0]   cnt_pwron_ce_r;  
  reg         cnt_pwron_cke_done_r;
  reg         cnt_pwron_cke_done_r1;  
  reg [8:0]   cnt_pwron_r;  
  reg         cnt_pwron_reset_done_r; 
  reg         cnt_txpr_done_r;  
  reg [7:0]   cnt_txpr_r;
  reg         ddr2_pre_flag_r;
  reg         ddr2_refresh_flag_r;
  reg         ddr3_lm_done_r;
  reg [4:0]   enable_wrlvl_cnt;
  reg         init_complete_r;
  reg         init_complete_r1;
  reg         init_complete_r2;
  reg [5:0]   init_next_state;  
  reg [5:0]   init_state_r;
  reg [5:0]   init_state_r1;
  wire [15:0] load_mr0;
  wire [15:0] load_mr1;
  wire [15:0] load_mr2;
  wire [15:0] load_mr3;
  reg         mem_init_done_r;
  reg [1:0]   mr2_r [0:3];
  reg [2:0]   mr1_r [0:3];
  reg         new_burst_r;
  reg [15:0]  wrcal_start_dly_r;
  wire        wrcal_start_pre;
  reg [nCK_PER_CLK-1:0]   phy_tmp_odt_r;
  reg [nCK_PER_CLK-1:0]   phy_tmp_odt_r1;
  reg [CS_WIDTH*nCS_PER_RANK-1:0]   phy_tmp_cs1_r;
  reg [CS_WIDTH*nCS_PER_RANK*nCK_PER_CLK-1:0]   phy_int_cs_n;
  wire        prech_done_pre;
  reg [15:0]  prech_done_dly_r;  
  reg         prech_pending_r;
  reg         prech_req_posedge_r;  
  reg         prech_req_r;    
  reg         pwron_ce_r;
  reg         phy_wrdata_en;
  reg         phy_wrdata_en_r1;
  reg         phy_wrdata_en_r2;
  reg         phy_wrdata_en_r3;
  reg [ROW_WIDTH-1:0] address_w;
  reg [BANK_WIDTH-1:0] bank_w;
  reg         rdlvl_stg1_start_int;
  reg [15:0]  rdlvl_start_dly0_r;
  wire        rdlvl_start_pre;
  wire        rdlvl_rd;
  wire        rdlvl_wr;
  reg         rdlvl_wr_r;
  wire        rdlvl_wr_rd;
  reg [2:0]   reg_ctrl_cnt_r;
  reg [1:0]   tmp_mr2_r [0:3];
  reg [2:0]   tmp_mr1_r [0:3];
  reg         wrlvl_done_r;
  reg         wrlvl_done_r1;
  reg         wrlvl_rank_done_r1;
  reg         wrlvl_rank_done_r2;
  reg         wrlvl_rank_done_r3;
  reg [2:0]   wrlvl_rank_cntr;
  reg         wrlvl_odt;
  reg         wrlvl_active;
  reg         wrlvl_active_r1;
  reg [1:0]   num_reads;
  reg [8:0]   stg1_wr_rd_cnt;
  reg         wr_level_dqs_asrt;
  reg         wr_level_dqs_asrt_r1;
  reg [1:0]   dqs_asrt_cnt;
  reg [PRBS_WIDTH-1:0] prbs_r1;
  reg [PRBS_WIDTH-1:0] prbs_r2;
  reg [PRBS_WIDTH-1:0] prbs_r3;
  reg [PRBS_WIDTH-1:0] prbs_r4;
  reg [PRBS_WIDTH-1:0] prbs_r5;
  reg [PRBS_WIDTH-1:0] prbs_r6;
  reg [PRBS_WIDTH-1:0] prbs_r7;
  always @(posedge mem_init_done_r) begin 
    if (!rst)
      $display ("PHY_INIT: Memory Initialization completed at %t", $time);
  end
  always @(posedge wrlvl_done) begin
    if (!rst && (WRLVL == "ON"))
      $display ("PHY_INIT: Write Leveling completed at %t", $time);
  end
  always @(posedge rdlvl_stg1_done) begin
    if (!rst) 
      $display ("PHY_INIT: Read Leveling Stage 1 completed at %t", $time);
  end
  always @(posedge pi_calib_done_r) begin
    if (!rst) 
      $display ("PHY_INIT: Phaser_In Phase Locked at %t", $time);
  end
  always @(posedge pi_dqs_found_done) begin
    if (!rst) 
      $display ("PHY_INIT: Phaser_In DQSFOUND completed at %t", $time);
  end
  always @(posedge wrcal_done) begin
    if (!rst && (WRLVL == "ON"))
      $display ("PHY_INIT: Write Calibration completed at %t", $time);
  end    
  assign pi_calib_done = pi_calib_done_r;
  always @(posedge clk)
    if (rst) begin
      init_complete_r     <= #TCQ 1'b0;
      init_complete_r1    <= #TCQ 1'b0;
      init_complete_r2    <= #TCQ 1'b0;
      init_calib_complete <= #TCQ 1'b0;
    end else begin
      if (init_state_r == INIT_DONE)
        init_complete_r   <= #TCQ 1'b1;
      init_complete_r1    <= #TCQ init_complete_r;
      init_complete_r2    <= #TCQ init_complete_r1; 
      init_calib_complete <= #TCQ init_complete_r2;
    end 
  generate
    if(DRAM_TYPE == "DDR3") begin: gen_load_mr0_DDR3
      assign load_mr0[1:0]   = (BURST_MODE == "8")   ? 2'b00 :
                               (BURST_MODE == "OTF") ? 2'b01 : 
                               (BURST_MODE == "4")   ? 2'b10 : 2'b11;
      assign load_mr0[2]     = (nCL >= 12) ? 1'b1 : 1'b0;   
      assign load_mr0[3]     = (BURST_TYPE == "SEQ") ? 1'b0 : 1'b1;
      assign load_mr0[6:4]   = ((nCL == 5) || (nCL == 13))  ? 3'b001 :
                               ((nCL == 6) || (nCL == 14))  ? 3'b010 : 
                               (nCL == 7)  ? 3'b011 : 
                               (nCL == 8)  ? 3'b100 :
                               (nCL == 9)  ? 3'b101 :
                               (nCL == 10) ? 3'b110 : 
                               (nCL == 11) ? 3'b111 :  
                               (nCL == 12) ? 3'b000 : 3'b111;
      assign load_mr0[7]     = 1'b0;
      assign load_mr0[8]     = 1'b1;   
      assign load_mr0[11:9]  = (TWR_CYC == 5)  ? 3'b001 :
                               (TWR_CYC == 6)  ? 3'b010 : 
                               (TWR_CYC == 7)  ? 3'b011 :
                               (TWR_CYC == 8)  ? 3'b100 :
                               (TWR_CYC == 9)  ? 3'b101 :
                               (TWR_CYC == 10)  ? 3'b101 :
                               (TWR_CYC == 11)  ? 3'b110 : 
                               (TWR_CYC == 12)  ? 3'b110 :
                               (TWR_CYC == 13)  ? 3'b111 :
                               (TWR_CYC == 14)  ? 3'b111 :
                               (TWR_CYC == 15)  ? 3'b000 :
                               (TWR_CYC == 16)  ? 3'b000 : 3'b010;
      assign load_mr0[12]    = 1'b0;   
      assign load_mr0[15:13] = 3'b000;
    end else if (DRAM_TYPE == "DDR2") begin: gen_load_mr0_DDR2 
      assign load_mr0[2:0]   = (BURST_MODE == "8")   ? 3'b011 :
                               (BURST_MODE == "4")   ? 3'b010 : 3'b111;
      assign load_mr0[3]     = (BURST_TYPE == "SEQ") ? 1'b0 : 1'b1;       
      assign load_mr0[6:4]   = (nCL == 3)  ? 3'b011 :
                               (nCL == 4)  ? 3'b100 :
                               (nCL == 5)  ? 3'b101 : 
                               (nCL == 6)  ? 3'b110 : 3'b111;
      assign load_mr0[7]     = 1'b0;
      assign load_mr0[8]     = 1'b1;   
      assign load_mr0[11:9]  = (TWR_CYC == 2)  ? 3'b001 :
                               (TWR_CYC == 3)  ? 3'b010 :
                               (TWR_CYC == 4)  ? 3'b011 :
                               (TWR_CYC == 5)  ? 3'b100 : 
                               (TWR_CYC == 6)  ? 3'b101 : 3'b010;
      assign load_mr0[15:12]= 4'b0000; 
    end
  endgenerate
  generate
    if(DRAM_TYPE == "DDR3") begin: gen_load_mr1_DDR3
      assign load_mr1[0]     = 1'b0;   
      assign load_mr1[1]     = (OUTPUT_DRV == "LOW") ? 1'b0 : 1'b1; 
      assign load_mr1[2]     = ((RTT_NOM == "30") || (RTT_NOM == "40") || 
                                (RTT_NOM == "60")) ? 1'b1 : 1'b0;
      assign load_mr1[4:3]   = (AL == "0")    ? 2'b00 :
                               (AL == "CL-1") ? 2'b01 :
                               (AL == "CL-2") ? 2'b10 : 2'b11;
      assign load_mr1[5]     = 1'b0; 
      assign load_mr1[6]     = ((RTT_NOM == "40") || (RTT_NOM == "120")) ? 
                               1'b1 : 1'b0;
      assign load_mr1[7]     = 1'b0;   
      assign load_mr1[8]     = 1'b0;
      assign load_mr1[9]     = ((RTT_NOM == "20") || (RTT_NOM == "30")) ?
                                1'b1 : 1'b0;
      assign load_mr1[10]    = 1'b0;
      assign load_mr1[15:11] = 5'b00000;
    end else if (DRAM_TYPE == "DDR2") begin: gen_load_mr1_DDR2 
      assign load_mr1[0]     = 1'b0;   
      assign load_mr1[1]     = (OUTPUT_DRV == "LOW") ? 1'b1 : 1'b0; 
      assign load_mr1[2]     = ((RTT_NOM == "75") || (RTT_NOM == "50")) ?
                                1'b1 : 1'b0;
      assign load_mr1[5:3]   = (AL == "0") ? 3'b000 :
                               (AL == "1") ? 3'b001 :
                               (AL == "2") ? 3'b010 :
                               (AL == "3") ? 3'b011 :
                               (AL == "4") ? 3'b100 : 3'b111;     
      assign load_mr1[6]     = ((RTT_NOM == "50") || 
                                (RTT_NOM == "150")) ? 1'b1 : 1'b0;
      assign load_mr1[9:7]   = 3'b000;
      assign load_mr1[10]    = (DDR2_DQSN_ENABLE == "YES") ? 1'b0 : 1'b1;
      assign load_mr1[15:11] = 5'b00000;
    end
  endgenerate
  generate
    if(DRAM_TYPE == "DDR3") begin: gen_load_mr2_DDR3
      assign load_mr2[2:0]   = 3'b000; 
      assign load_mr2[5:3]   = (nCWL == 5) ? 3'b000 :
                               (nCWL == 6) ? 3'b001 : 
                               (nCWL == 7) ? 3'b010 : 
                               (nCWL == 8) ? 3'b011 : 
                               (nCWL == 9) ? 3'b100 :
                               (nCWL == 10) ? 3'b101 :
                               (nCWL == 11) ? 3'b110 : 3'b111;
      assign load_mr2[6]     = 1'b0;
      assign load_mr2[7]     = 1'b0;
      assign load_mr2[8]     = 1'b0;
      assign load_mr2[10:9]  = 2'b00;
      assign load_mr2[15:11] = 5'b00000;
    end else begin: gen_load_mr2_DDR2
      assign load_mr2[15:0] = 16'd0;
    end
  endgenerate
  assign load_mr3[1:0]  = 2'b00;
  assign load_mr3[2]    = 1'b0;
  assign load_mr3[15:3] = 13'b0000000000000;
  assign calib_rank_cnt = chip_cnt_r;
  assign wrcal_start_pre = (init_state_r == INIT_WRCAL_READ);
  assign prech_done_pre = (((init_state_r == INIT_RDLVL_STG1_READ) ||
                            (init_state_r == INIT_RDLVL_STG2_READ) ||
                            (init_state_r == INIT_WRCAL_READ)) &&
                           prech_pending_r && 
                           !prech_req_posedge_r);
  always @(posedge clk) begin   
    wrcal_start_dly_r     <= #TCQ {wrcal_start_dly_r[14:0],
                                     wrcal_start_pre};
    prech_done_dly_r       <= #TCQ {prech_done_dly_r[14:0], 
                                     prech_done_pre};
  end
  always @(posedge clk)    
    prech_done <= #TCQ prech_done_dly_r[15];  
  always @(posedge clk)
    if (rst) begin
      rdlvl_stg1_start   <= #TCQ 1'b0;
      rdlvl_stg1_start_int <= #TCQ 1'b0;
      pi_dqs_found_start <= #TCQ 1'b0;
      wrcal_start        <= #TCQ 1'b0;      
    end else begin      
      if (!pi_dqs_found_done && init_state_r == INIT_RDLVL_STG2_READ)
        pi_dqs_found_start <= #TCQ 1'b1;
      if (pi_dqs_found_done && cnt_cmd_done_r &&
         (init_state_r == INIT_RDLVL_ACT_WAIT))
        rdlvl_stg1_start_int <= #TCQ 1'b1;
      if (pi_dqs_found_done &&
         (init_state_r == INIT_RDLVL_STG1_READ))
        rdlvl_stg1_start   <= #TCQ 1'b1;
      if (wrcal_start_dly_r[5])
        wrcal_start <= #TCQ 1'b1;        
    end 
  always @(posedge clk)
    if (rst)
      pi_dqs_found_done_r1 <= #TCQ 1'b0;
    else if (pi_dqs_found_done)
      pi_dqs_found_done_r1 <= #TCQ 1'b1; 
  generate
    if (nCK_PER_CLK == 4) begin: en_cnt_div4
      always @ (posedge clk)
        if (rst || wrlvl_rank_done)
          enable_wrlvl_cnt <= #TCQ 5'd0;
        else if ((init_state_r == INIT_WRLVL_START) ||
                 (wrlvl_odt && (enable_wrlvl_cnt == 5'd0)))
          enable_wrlvl_cnt <= #TCQ 5'd12;
        else if ((enable_wrlvl_cnt > 5'd0) && ~(phy_ctl_full || phy_cmd_full))
          enable_wrlvl_cnt <= #TCQ enable_wrlvl_cnt - 1;
      always @(posedge clk)
        if (rst || wrlvl_rank_done || done_dqs_tap_inc)
          wrlvl_odt <= #TCQ 1'b0;
        else if (enable_wrlvl_cnt == 5'd1)
          wrlvl_odt <= #TCQ 1'b1;
    end else begin: en_cnt_div2  
      always @ (posedge clk)
        if (rst)
          enable_wrlvl_cnt <= #TCQ 5'd0;
        else if ((init_state_r == INIT_WRLVL_START) ||
                 (wrlvl_odt && (enable_wrlvl_cnt == 5'd0)))
          enable_wrlvl_cnt <= #TCQ 5'd21;
        else if ((enable_wrlvl_cnt > 5'd0) && ~(phy_ctl_full || phy_cmd_full))
          enable_wrlvl_cnt <= #TCQ enable_wrlvl_cnt - 1;
      always @(posedge clk)
        if (rst || wrlvl_rank_done || done_dqs_tap_inc)
          wrlvl_odt <= #TCQ 1'b0;
        else if (enable_wrlvl_cnt == 5'd1)
          wrlvl_odt <= #TCQ 1'b1;
    end
  endgenerate
  always @(posedge clk)
    if (rst || wrlvl_rank_done || done_dqs_tap_inc)
      wrlvl_active <= #TCQ 1'b0;
    else if ((enable_wrlvl_cnt == 5'd1) && wrlvl_odt && !wrlvl_active)
      wrlvl_active <= #TCQ 1'b1;
  always @(posedge clk)begin
     if(rst || (enable_wrlvl_cnt != 5'd1)) begin
       wr_level_dqs_asrt <= #TCQ 1'd0;
     end else if ((enable_wrlvl_cnt == 5'd1) && (wrlvl_active_r1)) begin
       wr_level_dqs_asrt <= #TCQ 1'd1;
     end
  end
  always @ (posedge clk) begin
     if (rst)
       dqs_asrt_cnt <= #TCQ 2'd0;
     else if (wr_level_dqs_asrt && dqs_asrt_cnt != 2'd3)
       dqs_asrt_cnt <= #TCQ (dqs_asrt_cnt + 1);
  end
  always @ (posedge clk) begin
     if (rst || ~wrlvl_active)
       wr_lvl_start <= #TCQ 1'd0;
     else if (dqs_asrt_cnt == 2'd3)
       wr_lvl_start <= #TCQ 1'd1;
  end
  always @(posedge clk) begin
    if (rst)
      wl_sm_start        <= #TCQ 1'b0;
    else
      wl_sm_start        <= #TCQ wr_level_dqs_asrt_r1;
  end
    always @(posedge clk) begin
      wrlvl_active_r1      <= #TCQ wrlvl_active;
      wr_level_dqs_asrt_r1 <= #TCQ wr_level_dqs_asrt;
      wrlvl_done_r         <= #TCQ wrlvl_done;
      wrlvl_done_r1        <= #TCQ wrlvl_done_r;
      wrlvl_rank_done_r1   <= #TCQ wrlvl_rank_done;
      wrlvl_rank_done_r2   <= #TCQ wrlvl_rank_done_r1;
      wrlvl_rank_done_r3   <= #TCQ wrlvl_rank_done_r2;
    end
    always @ (posedge clk) begin
      if (rst)
        wrlvl_rank_cntr <= #TCQ 3'd0;
      else if (wrlvl_rank_done)
        wrlvl_rank_cntr <= #TCQ wrlvl_rank_cntr + 1'b1;
    end               
  assign prech_req = rdlvl_prech_req | wrcal_prech_req;
  always @(posedge clk)
    if (rst) begin
      prech_req_r         <= #TCQ 1'b0;
      prech_req_posedge_r <= #TCQ 1'b0;
      prech_pending_r     <= #TCQ 1'b0;
    end else begin
      prech_req_r         <= #TCQ prech_req;
      prech_req_posedge_r <= #TCQ prech_req & ~prech_req_r;
      if (prech_req_posedge_r)
        prech_pending_r   <= #TCQ 1'b1;
      else if (prech_done_pre)
        prech_pending_r   <= #TCQ 1'b0;
    end
  always @(posedge clk) begin
    case (init_state_r)
      INIT_LOAD_MR_WAIT,
      INIT_WRLVL_LOAD_MR_WAIT,
      INIT_WRLVL_LOAD_MR2_WAIT,
      INIT_RDLVL_ACT_WAIT,
      INIT_RDLVL_STG1_WRITE_READ,
      INIT_RDLVL_STG2_READ_WAIT,
      INIT_WRCAL_ACT_WAIT,
      INIT_WRCAL_WRITE_READ,
      INIT_WRCAL_READ_WAIT,
      INIT_PRECHARGE_PREWAIT,
      INIT_PRECHARGE_WAIT,
      INIT_DDR2_PRECHARGE_WAIT,
      INIT_REG_WRITE_WAIT,
      INIT_REFRESH_WAIT: begin
        if (phy_ctl_full || phy_cmd_full)
          cnt_cmd_r <= #TCQ cnt_cmd_r;
        else
          cnt_cmd_r <= #TCQ cnt_cmd_r + 1;
      end
      INIT_WRLVL_WAIT:
        cnt_cmd_r <= #TCQ 'b0;
      default:
        cnt_cmd_r <= #TCQ 'b0;
    endcase
  end
  always @(posedge clk)
    cnt_cmd_done_r <= #TCQ (cnt_cmd_r == CNTNEXT_CMD);
  always @(posedge clk) begin
    if (rst)
      detect_pi_found_dqs <= #TCQ 1'b0;
    else if ((cnt_cmd_r == CNTNEXT_CMD) &&
             (init_state_r == INIT_RDLVL_STG2_READ_WAIT))
      detect_pi_found_dqs <= #TCQ 1'b1;
    else
      detect_pi_found_dqs <= #TCQ 1'b0;
  end 
  always @(posedge clk)
    if (rst) begin
      cnt_pwron_ce_r <= #TCQ 10'h000;
      pwron_ce_r     <= #TCQ 1'b0;
    end else begin
      cnt_pwron_ce_r <= #TCQ cnt_pwron_ce_r + 1;
      pwron_ce_r     <= #TCQ (cnt_pwron_ce_r == 10'h3FF);
    end
  always @(posedge clk) 
    if (rst)
      cnt_pwron_r <= #TCQ 'b0;
    else if (pwron_ce_r)
      cnt_pwron_r <= #TCQ cnt_pwron_r + 1;
  always @(posedge clk)
    if (rst || ~phy_ctl_ready) begin
      cnt_pwron_reset_done_r <= #TCQ 1'b0;
      cnt_pwron_cke_done_r   <= #TCQ 1'b0;
    end else begin
      if ((SIM_INIT_OPTION == "SKIP_PU_DLY") || 
          (SIM_INIT_OPTION == "SKIP_INIT")) begin
        cnt_pwron_reset_done_r <= #TCQ 1'b1;
        cnt_pwron_cke_done_r   <= #TCQ 1'b1;
      end else begin
        if (DRAM_TYPE == "DDR3") begin
           if (!cnt_pwron_reset_done_r)
             cnt_pwron_reset_done_r 
               <= #TCQ (cnt_pwron_r == PWRON_RESET_DELAY_CNT);
           if (!cnt_pwron_cke_done_r)
             cnt_pwron_cke_done_r   
               <= #TCQ (cnt_pwron_r == PWRON_CKE_DELAY_CNT);
           end else begin 
              cnt_pwron_reset_done_r <= #TCQ 1'b1; 
              if (!cnt_pwron_cke_done_r)
                 cnt_pwron_cke_done_r   
                   <= #TCQ (cnt_pwron_r == PWRON_CKE_DELAY_CNT);
           end        
      end
    end 
  always @(posedge clk)
    cnt_pwron_cke_done_r1   <= #TCQ cnt_pwron_cke_done_r;
  always @(posedge clk) begin
    phy_reset_n <= #TCQ cnt_pwron_reset_done_r;
  end
  always @(posedge clk)
    if (!cnt_pwron_cke_done_r) begin
      cnt_txpr_r      <= #TCQ 'b0;
      cnt_txpr_done_r <= #TCQ 1'b0;
    end else begin
      cnt_txpr_r <= #TCQ cnt_txpr_r + 1;
      if (!cnt_txpr_done_r)
        cnt_txpr_done_r <= #TCQ (cnt_txpr_r == TXPR_DELAY_CNT);
    end
  always @(posedge clk)
    if (!cnt_pwron_cke_done_r) begin
      cnt_init_pre_wait_r      <= #TCQ 'b0;
      cnt_init_pre_wait_done_r <= #TCQ 1'b0;
    end else begin
      cnt_init_pre_wait_r <= #TCQ cnt_init_pre_wait_r + 1;
      if (!cnt_init_pre_wait_done_r)
        cnt_init_pre_wait_done_r 
          <= #TCQ (cnt_init_pre_wait_r >= DDR2_INIT_PRE_CNT);
    end
  always @(posedge clk)
    if (init_state_r == INIT_ZQCL) begin
      cnt_dllk_zqinit_r      <= #TCQ 'b0;
      cnt_dllk_zqinit_done_r <= #TCQ 1'b0;
    end else if (~(phy_ctl_full || phy_cmd_full)) begin
      cnt_dllk_zqinit_r <= #TCQ cnt_dllk_zqinit_r + 1;
      if (!cnt_dllk_zqinit_done_r) 
        cnt_dllk_zqinit_done_r 
          <= #TCQ (cnt_dllk_zqinit_r == TDLLK_TZQINIT_DELAY_CNT);
    end
  always @(posedge clk)
    if ((init_state_r == INIT_IDLE)||
        ((init_state_r == INIT_REFRESH)
          && (~mem_init_done_r))) begin
      cnt_init_mr_r      <= #TCQ 'b0;
      cnt_init_mr_done_r <= #TCQ 1'b0;
    end else if (init_state_r == INIT_LOAD_MR) begin
      cnt_init_mr_r      <= #TCQ cnt_init_mr_r + 1;
      cnt_init_mr_done_r <= #TCQ (cnt_init_mr_r == INIT_CNT_MR_DONE);
    end
  always @(posedge clk)
    if (init_state_r == INIT_IDLE) 
      ddr2_pre_flag_r<= #TCQ 'b0;
    else if (init_state_r == INIT_LOAD_MR) 
      ddr2_pre_flag_r<= #TCQ 1'b1;
    else if ((ddr2_refresh_flag_r) &&
             (init_state_r == INIT_LOAD_MR_WAIT)&&
             (cnt_cmd_done_r) && (cnt_init_mr_done_r))
      ddr2_pre_flag_r <= #TCQ 'b0;
  always @(posedge clk)
    if (init_state_r == INIT_IDLE) 
      ddr2_refresh_flag_r<= #TCQ 'b0;
    else if ((init_state_r == INIT_REFRESH) && (~mem_init_done_r)) 
      ddr2_refresh_flag_r<= #TCQ 1'b1;
    else if ((ddr2_refresh_flag_r) &&
             (init_state_r == INIT_LOAD_MR_WAIT)&&
             (cnt_cmd_done_r) && (cnt_init_mr_done_r))
      ddr2_refresh_flag_r <= #TCQ 'b0;
  always @(posedge clk)
    if (init_state_r == INIT_IDLE) begin
      cnt_init_af_r      <= #TCQ 'b0;
      cnt_init_af_done_r <= #TCQ 1'b0;
    end else if ((init_state_r == INIT_REFRESH) && (~mem_init_done_r))begin
      cnt_init_af_r      <= #TCQ cnt_init_af_r + 1;
      cnt_init_af_done_r <= #TCQ (cnt_init_af_r == 2'b11);
    end   
  always @(posedge clk)
    if (init_state_r == INIT_IDLE)
      reg_ctrl_cnt_r <= #TCQ 'b0;
    else if (init_state_r == INIT_REG_WRITE)
      reg_ctrl_cnt_r <= #TCQ reg_ctrl_cnt_r + 1;
  always @(posedge clk)
    if (init_state_r == INIT_IDLE)
      stg1_wr_done <= #TCQ 1'b0;
    else if (init_state_r == INIT_RDLVL_STG1_WRITE_READ)
      stg1_wr_done <= #TCQ 1'b1;
  always @(posedge clk)
    if (rst)begin
      init_state_r  <= #TCQ INIT_IDLE;
      init_state_r1 <= #TCQ INIT_IDLE;
    end else begin
      init_state_r  <= #TCQ init_next_state;
      init_state_r1 <= #TCQ init_state_r;
    end 
  always @(burst_addr_r or chip_cnt_r or cnt_cmd_done_r
           or cnt_dllk_zqinit_done_r or cnt_init_af_done_r
           or cnt_init_mr_done_r or phy_ctl_ready or phy_ctl_full
           or phy_cmd_full or num_reads or dqs_dly_done or stg1_wr_done 
           or cnt_init_pre_wait_done_r or cnt_pwron_cke_done_r
           or cnt_txpr_done_r or ddr2_pre_flag_r
           or ddr2_refresh_flag_r or ddr3_lm_done_r
           or init_state_r or mem_init_done_r
           or prech_req_posedge_r or wrcal_done or wrcal_resume 
           or rdlvl_stg1_done or rdlvl_stg1_rank_done or rdlvl_stg1_start_int
           or stg1_wr_rd_cnt or read_calib_int or read_calib_r or pi_calib_done_r
           or pi_dqs_found_done or pi_dqs_found_rank_done or pi_dqs_found_start
           or reg_ctrl_cnt_r or wrlvl_done_r1 or wrlvl_rank_done_r3) begin     
    init_next_state = init_state_r;
    (* full_case, parallel_case *) case (init_state_r)
      INIT_IDLE:
        if (cnt_pwron_cke_done_r && phy_ctl_ready 
            && ~(phy_ctl_full || phy_cmd_full) && dqs_dly_done) begin
          if (SIM_INIT_OPTION == "SKIP_INIT")       
            if (WRLVL == "ON")      
              init_next_state = INIT_WRLVL_START;
            else 
              init_next_state = INIT_RDLVL_ACT;
          else
            init_next_state = INIT_WAIT_CKE_EXIT;
        end
      INIT_WAIT_CKE_EXIT:
        if ((cnt_txpr_done_r) && (DRAM_TYPE == "DDR3") 
           && ~(phy_ctl_full || phy_cmd_full)) begin
          if((REG_CTRL == "ON") && ((nCS_PER_RANK > 1) ||
             (RANKS > 1)))
            init_next_state = INIT_REG_WRITE;
          else
          init_next_state = INIT_LOAD_MR;
        end else if ((cnt_init_pre_wait_done_r) && (DRAM_TYPE == "DDR2")
                     && ~(phy_ctl_full || phy_cmd_full))
          init_next_state = INIT_DDR2_PRECHARGE;                             
      INIT_REG_WRITE:
        init_next_state = INIT_REG_WRITE_WAIT;
      INIT_REG_WRITE_WAIT:
        if (cnt_cmd_done_r && ~(phy_ctl_full || phy_cmd_full)) begin
           if(reg_ctrl_cnt_r == 3'd5)
             init_next_state = INIT_LOAD_MR;
           else
             init_next_state = INIT_REG_WRITE;
        end
      INIT_LOAD_MR:
        init_next_state = INIT_LOAD_MR_WAIT;
      INIT_LOAD_MR_WAIT:
        if (cnt_cmd_done_r && ~(phy_ctl_full || phy_cmd_full)) begin
          if(rdlvl_stg1_done && pi_dqs_found_done)
            init_next_state = INIT_PRECHARGE;
          else if (cnt_init_mr_done_r)begin
             if(DRAM_TYPE == "DDR3")
                init_next_state = INIT_ZQCL;
             else begin 
                if(ddr2_refresh_flag_r)begin
                  if (!mem_init_done_r && (chip_cnt_r <= RANKS-1))
                    init_next_state  = INIT_DDR2_MULTI_RANK;                     
                  else 
                     init_next_state = INIT_RDLVL_ACT;
                end else 
                  init_next_state = INIT_DDR2_PRECHARGE;
              end  
          end else      
            init_next_state = INIT_LOAD_MR;
        end 
      INIT_DDR2_MULTI_RANK:
        init_next_state = INIT_DDR2_MULTI_RANK_WAIT;
      INIT_DDR2_MULTI_RANK_WAIT:
        init_next_state = INIT_DDR2_PRECHARGE;
      INIT_ZQCL:
        init_next_state = INIT_WAIT_DLLK_ZQINIT;
      INIT_WAIT_DLLK_ZQINIT:
        if (cnt_dllk_zqinit_done_r && ~(phy_ctl_full || phy_cmd_full))
          if (!mem_init_done_r && (chip_cnt_r <= RANKS-1))
            init_next_state = INIT_LOAD_MR;
          else if (WRLVL == "ON")
            init_next_state = INIT_WRLVL_START;
          else
            init_next_state = INIT_RDLVL_ACT;
      INIT_DDR2_PRECHARGE: 
        init_next_state = INIT_DDR2_PRECHARGE_WAIT; 
      INIT_DDR2_PRECHARGE_WAIT: 
        if (cnt_cmd_done_r && ~(phy_ctl_full || phy_cmd_full)) begin
           if(ddr2_pre_flag_r)
             init_next_state = INIT_REFRESH;
           else
             init_next_state = INIT_LOAD_MR;
        end                                  
      INIT_REFRESH: 
        init_next_state = INIT_REFRESH_WAIT; 
      INIT_REFRESH_WAIT: 
        if (cnt_cmd_done_r && ~(phy_ctl_full || phy_cmd_full))begin
          if(cnt_init_af_done_r && (~mem_init_done_r))
            init_next_state = INIT_LOAD_MR;
          else if (((rdlvl_stg1_done && pi_dqs_found_done) && (WRLVL == "ON"))
                    && mem_init_done_r)
            init_next_state = INIT_WRCAL_ACT;
          else if (mem_init_done_r)
            init_next_state = INIT_RDLVL_ACT; 
          else 
            init_next_state = INIT_REFRESH;
        end
      INIT_WRLVL_START:
        init_next_state = INIT_WRLVL_WAIT;
      INIT_WRLVL_WAIT:
        if (wrlvl_rank_done_r3 && ~(phy_ctl_full || phy_cmd_full))
          init_next_state = INIT_WRLVL_LOAD_MR;
      INIT_WRLVL_LOAD_MR:
        init_next_state = INIT_WRLVL_LOAD_MR_WAIT;
      INIT_WRLVL_LOAD_MR_WAIT:
        if (cnt_cmd_done_r && ~(phy_ctl_full || phy_cmd_full))
        init_next_state = INIT_WRLVL_LOAD_MR2;
      INIT_WRLVL_LOAD_MR2:
        init_next_state = INIT_WRLVL_LOAD_MR2_WAIT;    
      INIT_WRLVL_LOAD_MR2_WAIT:
        if (cnt_cmd_done_r && ~(phy_ctl_full || phy_cmd_full)) begin
          if (~wrlvl_done_r1)
            init_next_state = INIT_WRLVL_START;
          else if (SIM_CAL_OPTION == "SKIP_CAL")
            init_next_state = INIT_DONE;
          else 
            init_next_state = INIT_RDLVL_ACT;
        end
      INIT_RDLVL_ACT:
        init_next_state = INIT_RDLVL_ACT_WAIT;
      INIT_RDLVL_ACT_WAIT:
        if (cnt_cmd_done_r && ~(phy_ctl_full || phy_cmd_full)) begin
          if (read_calib_int && !read_calib_r)
            init_next_state = INIT_PI_PHASELOCK_READS;
          else if (!pi_dqs_found_done)
            init_next_state = INIT_RDLVL_STG2_READ;
          else if (!rdlvl_stg1_done && ~stg1_wr_done)
            init_next_state = INIT_RDLVL_STG1_WRITE;
          else if (!rdlvl_stg1_done && rdlvl_stg1_start_int)
            init_next_state = INIT_RDLVL_STG1_READ;
          else
            init_next_state = INIT_PRECHARGE_PREWAIT;
        end
      INIT_PI_PHASELOCK_READS:
        if (pi_calib_done_r)
          init_next_state = INIT_PRECHARGE_PREWAIT;
      INIT_RDLVL_STG1_WRITE:
        if (stg1_wr_rd_cnt == 9'd1)
          init_next_state = INIT_RDLVL_STG1_WRITE_READ;
      INIT_RDLVL_STG1_WRITE_READ: 
        if (cnt_cmd_done_r && ~(phy_ctl_full || phy_cmd_full))
          init_next_state = INIT_RDLVL_STG1_READ;
      INIT_RDLVL_STG1_READ:
        if (rdlvl_stg1_rank_done || rdlvl_stg1_done || prech_req_posedge_r)
          init_next_state = INIT_PRECHARGE_PREWAIT;
      INIT_RDLVL_STG2_READ:
        if (num_reads == 'b1)
          init_next_state = INIT_RDLVL_STG2_READ_WAIT;
      INIT_RDLVL_STG2_READ_WAIT:
        if (~(phy_ctl_full || phy_cmd_full)) begin
          if (pi_dqs_found_rank_done ||
              pi_dqs_found_done || prech_req_posedge_r)
            init_next_state = INIT_PRECHARGE_PREWAIT;
          else if (cnt_cmd_done_r)
              init_next_state = INIT_RDLVL_STG2_READ;
        end
      INIT_WRCAL_ACT:
        init_next_state = INIT_WRCAL_ACT_WAIT;
      INIT_WRCAL_ACT_WAIT:
        if (cnt_cmd_done_r)
          init_next_state = INIT_WRCAL_WRITE;
      INIT_WRCAL_WRITE:
        if (burst_addr_r == 1'b1)
          init_next_state = INIT_WRCAL_WRITE_READ;
      INIT_WRCAL_WRITE_READ: 
        if (cnt_cmd_done_r && ~(phy_ctl_full || phy_cmd_full)) 
          init_next_state = INIT_WRCAL_READ;
      INIT_WRCAL_READ:
        if (burst_addr_r == 1'b1)
          init_next_state = INIT_WRCAL_READ_WAIT;
      INIT_WRCAL_READ_WAIT:
        if (~(phy_ctl_full || phy_cmd_full)) begin
          if (wrcal_resume)
            init_next_state = INIT_WRCAL_WRITE;
          else if (wrcal_done || prech_req_posedge_r)
            init_next_state = INIT_PRECHARGE_PREWAIT;
        end        
      INIT_PRECHARGE_PREWAIT:
        if (cnt_cmd_done_r && ~(phy_ctl_full || phy_cmd_full))
          init_next_state = INIT_PRECHARGE;                
      INIT_PRECHARGE: 
        init_next_state = INIT_PRECHARGE_WAIT; 
      INIT_PRECHARGE_WAIT: 
        if (cnt_cmd_done_r && ~(phy_ctl_full || phy_cmd_full)) begin
          if ((wrcal_done || (WRLVL == "OFF")) && rdlvl_stg1_done &&
             pi_dqs_found_done && ((ddr3_lm_done_r) || (DRAM_TYPE == "DDR2")))
            init_next_state = INIT_DONE;
          else if ((wrcal_done || (WRLVL == "OFF")) && rdlvl_stg1_done
                   && pi_dqs_found_done)
            init_next_state = INIT_LOAD_MR; 
          else if (rdlvl_stg1_done && pi_dqs_found_done && (WRLVL == "ON"))
            init_next_state = INIT_REFRESH; 
          else
            init_next_state = INIT_REFRESH;
        end
      INIT_DONE:
        init_next_state = INIT_DONE;
    endcase
  end
  always @(posedge clk)
    if (rst)
      mem_init_done_r <= #TCQ 1'b0;
    else if ((!cnt_dllk_zqinit_done_r && 
             (cnt_dllk_zqinit_r == TDLLK_TZQINIT_DELAY_CNT) &&
             (chip_cnt_r == RANKS-1) && (DRAM_TYPE == "DDR3"))
              || ( (init_state_r == INIT_LOAD_MR_WAIT) &&
             (ddr2_refresh_flag_r) && (chip_cnt_r == RANKS-1)
             && (cnt_init_mr_done_r) && (DRAM_TYPE == "DDR2")))
      mem_init_done_r <= #TCQ 1'b1;
  always @(posedge clk) begin
    if (rst || done_dqs_tap_inc)
      write_calib <= #TCQ 1'b0;
    else if (wrlvl_active_r1)
      write_calib <= #TCQ 1'b1;
  end
  always @(posedge clk) begin
    if (rst || pi_calib_done_r)
      read_calib_int <= #TCQ 1'b0;
    else if (~pi_calib_done_r && (init_state_r == INIT_RDLVL_ACT_WAIT) &&
            (cnt_cmd_r == CNTNEXT_CMD))
      read_calib_int <= #TCQ 1'b1;
  end
  always @(posedge clk)
    read_calib_r <= #TCQ read_calib_int;
  always @(posedge clk) begin
    if (rst || pi_calib_done_r)
      read_calib <= #TCQ 1'b0;
    else if (~pi_calib_done_r && (init_state_r == INIT_PI_PHASELOCK_READS))
      read_calib <= #TCQ 1'b1;
  end
  always @(posedge clk)
    if (rst)
      pi_calib_done_r <= #TCQ 1'b0;
    else if (pi_phase_locked_all)
      pi_calib_done_r <= #TCQ 1'b1;
  always @(posedge clk)
    if (rst)
      ddr3_lm_done_r <= #TCQ 1'b0;
    else if ((init_state_r == INIT_LOAD_MR_WAIT) &&
            (chip_cnt_r == RANKS-1) && wrcal_done)
      ddr3_lm_done_r <= #TCQ 1'b1;
  always @(posedge clk)
    pi_dqs_found_rank_done_r <= #TCQ pi_dqs_found_rank_done;
  always @(posedge clk)
    if (rst || (wrlvl_done_r &&
       (init_state_r==INIT_WRLVL_LOAD_MR2_WAIT)))begin 
      chip_cnt_r <= #TCQ 2'b00;
    end else if ((((init_state_r == INIT_WAIT_DLLK_ZQINIT) &&
             (cnt_dllk_zqinit_r == TDLLK_TZQINIT_DELAY_CNT)) ||
             ((init_state_r!=INIT_WRLVL_LOAD_MR2_WAIT) && 
             (init_next_state==INIT_WRLVL_LOAD_MR2_WAIT)) && 
             (DRAM_TYPE == "DDR3")) ||
             rdlvl_stg1_rank_done  ||
             (pi_dqs_found_rank_done && ~pi_dqs_found_rank_done_r) ||
             ((init_state_r == INIT_LOAD_MR_WAIT)&& cnt_cmd_done_r 
             && wrcal_done) ||
             ((init_state_r == INIT_DDR2_MULTI_RANK)
                && (DRAM_TYPE == "DDR2"))) begin
      if ((~mem_init_done_r || ~rdlvl_stg1_done || ~pi_dqs_found_done ||
         wrcal_done)
         && (chip_cnt_r != RANKS-1)) 
        chip_cnt_r <= #TCQ chip_cnt_r + 1;
      else
        chip_cnt_r <= #TCQ 2'b00;
  end  
generate
   if (DRAM_TYPE == "DDR3") begin: DDR3
     always @(posedge clk)
       if (rst)
         phy_int_cs_n <= #TCQ {CS_WIDTH*nCS_PER_RANK*nCK_PER_CLK{1'b1}};
       else if (RANKS == 1)
         phy_int_cs_n <= #TCQ {CS_WIDTH*nCS_PER_RANK*nCK_PER_CLK{1'b0}};
       else begin
         phy_int_cs_n <= #TCQ {CS_WIDTH*nCS_PER_RANK*nCK_PER_CLK{1'b1}};
         case (chip_cnt_r)
           2'b00:begin
             for (n = 0; n < nCS_PER_RANK*nCK_PER_CLK*2; n = n + (nCS_PER_RANK*2)) begin 
               phy_int_cs_n[n+:nCS_PER_RANK] <= #TCQ {nCS_PER_RANK{1'b0}};
             end
           end
           2'b01:begin
             for (p = nCS_PER_RANK; p < nCS_PER_RANK*nCK_PER_CLK*2; p = p + (nCS_PER_RANK*2)) begin 
               phy_int_cs_n[p+:nCS_PER_RANK] <= #TCQ {nCS_PER_RANK{1'b0}};
             end
           end
         endcase
       end
   end else begin: DDR2
  always @(posedge clk)
    if (rst) begin
      phy_int_cs_n <= #TCQ {CS_WIDTH*nCS_PER_RANK*nCK_PER_CLK{1'b1}};
    end else begin
      if (init_state_r == INIT_REG_WRITE) begin
        phy_int_cs_n <= #TCQ {CS_WIDTH*nCS_PER_RANK*nCK_PER_CLK{1'b0}};
      end else if ((wrlvl_odt) ||
          (init_state_r == INIT_LOAD_MR) ||
          (init_state_r  == INIT_ZQCL) ||
          (init_state_r == INIT_WRLVL_START) ||
          (init_state_r == INIT_WRLVL_LOAD_MR) ||
          (init_state_r == INIT_WRLVL_LOAD_MR2) ||
          (init_state_r == INIT_RDLVL_ACT) ||
          (init_state_r == INIT_PI_PHASELOCK_READS) ||
          (init_state_r == INIT_RDLVL_STG1_WRITE) ||
          (init_state_r == INIT_RDLVL_STG1_READ) ||
          (init_state_r == INIT_PRECHARGE) ||
          (init_state_r == INIT_RDLVL_STG2_READ) ||
          (init_state_r == INIT_WRCAL_ACT) ||
          (init_state_r == INIT_WRCAL_READ) ||
          (init_state_r == INIT_WRCAL_WRITE) ||
          (init_state_r == INIT_DDR2_PRECHARGE) ||
          (init_state_r == INIT_REFRESH)) begin
          phy_int_cs_n[0] <= #TCQ 1'b0;
      end    
      else phy_int_cs_n <= #TCQ {CS_WIDTH*nCS_PER_RANK*nCK_PER_CLK{1'b1}};   
       end 
  end 
endgenerate
  assign phy_cs_n = phy_int_cs_n;
  assign rdlvl_wr = (init_state_r == INIT_RDLVL_STG1_WRITE) ||
                    (init_state_r == INIT_WRCAL_WRITE);
  assign rdlvl_rd = (init_state_r == INIT_PI_PHASELOCK_READS) ||
                    (init_state_r == INIT_RDLVL_STG1_READ) ||
                    (init_state_r == INIT_RDLVL_STG2_READ) ||
                    (init_state_r == INIT_WRCAL_READ);
  assign rdlvl_wr_rd = rdlvl_wr | rdlvl_rd;
  generate
    if (nCK_PER_CLK == 4) begin:DIV4
      always @(posedge clk)
        if (rst || wrcal_done)
          burst_addr_r <= #TCQ 1'b0;
        else if ((init_state_r == INIT_WRCAL_ACT_WAIT) ||
                 (init_state_r == INIT_WRCAL_WRITE) ||
                 (init_state_r == INIT_WRCAL_WRITE_READ) ||
                 (init_state_r == INIT_WRCAL_READ) ||
                 (init_state_r == INIT_WRCAL_READ_WAIT))
          burst_addr_r <= #TCQ 1'b1;
        else if (rdlvl_wr_rd)
          burst_addr_r <= #TCQ ~burst_addr_r;
        else
          burst_addr_r <= #TCQ 1'b0;
    end else begin: DIV2
      always @(posedge clk)
        if (rdlvl_wr_rd)
          burst_addr_r <= #TCQ ~burst_addr_r;
        else
          burst_addr_r <= #TCQ 1'b0;
    end
  endgenerate
  always @(posedge clk)
    if (rst || (init_state_r == INIT_RDLVL_STG1_WRITE_READ) ||
       rdlvl_stg1_done || (stg1_wr_rd_cnt==9'd0))
      stg1_wr_rd_cnt <= #TCQ NUM_STG1_WR_RD;
    else if (init_state_r == INIT_RDLVL_STG1_WRITE)
      stg1_wr_rd_cnt <= #TCQ stg1_wr_rd_cnt - 1;
  always @(posedge clk)
    if (rst || (init_state_r == INIT_RDLVL_STG2_READ_WAIT))
      num_reads <= #TCQ 2'b00;
    else if ((num_reads > 2'b00) && ~(phy_ctl_full || phy_cmd_full))
      num_reads <= #TCQ num_reads - 1;
    else if ((init_state_r == INIT_RDLVL_STG2_READ) || phy_ctl_full || phy_cmd_full)
      num_reads <= #TCQ 2'b11;
  always @(posedge clk)
    if (rdlvl_wr_rd) begin
      new_burst_r <= #TCQ 1'b1;
    end
  always @(posedge clk) begin
    rdlvl_wr_r      <= #TCQ rdlvl_wr;
    calib_wrdata_en <= #TCQ phy_wrdata_en;
  end
  generate
    if ((nCK_PER_CLK == 4) || (BURST_MODE == "4")) begin: wrdqen_div4
      always @(rst or phy_data_full or init_state_r) begin
        if (rst)
          phy_wrdata_en = 1'b0;
        else if (~phy_data_full && ((init_state_r == INIT_RDLVL_STG1_WRITE) ||
            (init_state_r == INIT_WRCAL_WRITE)))
          phy_wrdata_en = 1'b1;
        else
          phy_wrdata_en = 1'b0;
      end
    end else begin: wrdqen_div2
      always @(rdlvl_wr or rdlvl_wr_r)
        phy_wrdata_en = rdlvl_wr | rdlvl_wr_r;
    end
  endgenerate
  assign phy_rddata_en = ~phy_if_empty;
  assign phy_rddata_valid = (init_complete_r1) ? phy_rddata_en : 1'b0;
  always @(posedge clk)
    if ((init_state_r == INIT_IDLE) ||
        (init_state_r == INIT_RDLVL_STG1_WRITE))
      cnt_init_data_r <= #TCQ 2'b00;
    else if (phy_wrdata_en)
      cnt_init_data_r <= #TCQ cnt_init_data_r + 1;
    else if (init_state_r == INIT_WRCAL_WRITE)
      cnt_init_data_r <= #TCQ 2'b10;     
  always @(posedge clk) begin
    prbs_r1 <= #TCQ prbs_o;
    prbs_r2 <= #TCQ prbs_r1;
    prbs_r3 <= #TCQ prbs_r2;
    prbs_r4 <= #TCQ prbs_r3;
    prbs_r5 <= #TCQ prbs_r4;
    prbs_r6 <= #TCQ prbs_r5;
    prbs_r7 <= #TCQ prbs_r6;
  end
generate
  if (nCK_PER_CLK == 4) begin: wrdq_div4_bl8
    always @(posedge clk)
      if (phy_wrdata_en && (!rdlvl_stg1_done)) 
        phy_wrdata <= #TCQ {prbs_o[DQ_WIDTH-1:0],prbs_r1[DQ_WIDTH-1:0],
                            prbs_r2[DQ_WIDTH-1:0],prbs_r3[DQ_WIDTH-1:0],
                            prbs_r4[DQ_WIDTH-1:0],prbs_r5[DQ_WIDTH-1:0],
                            prbs_r6[DQ_WIDTH-1:0],prbs_r7[DQ_WIDTH-1:0]};
      else if (phy_wrdata_en && rdlvl_stg1_done) 
        phy_wrdata <= #TCQ {{DQ_WIDTH/4{4'h6}},{DQ_WIDTH/4{4'h9}},
                            {DQ_WIDTH/4{4'hA}},{DQ_WIDTH/4{4'h5}},
                            {DQ_WIDTH/4{4'h5}},{DQ_WIDTH/4{4'hA}},
                            {DQ_WIDTH/4{4'h0}},{DQ_WIDTH/4{4'hF}}};
  end else begin: wrdq_div2_bl4_8
    always @(posedge clk)
      (* full_case, parallel_case *) case (cnt_init_data_r)
      2'b00:
        phy_wrdata <= #TCQ {prbs_o[DQ_WIDTH-1:0],prbs_r1[DQ_WIDTH-1:0],
                            prbs_r2[DQ_WIDTH-1:0],prbs_r3[DQ_WIDTH-1:0]};
      2'b01:
        phy_wrdata <= #TCQ {prbs_r4[DQ_WIDTH-1:0],prbs_r5[DQ_WIDTH-1:0],
                            prbs_r6[DQ_WIDTH-1:0],prbs_r7[DQ_WIDTH-1:0]};
      2'b10:
        phy_wrdata <= #TCQ {{DQ_WIDTH/4{4'h5}},{DQ_WIDTH/4{4'hA}},
                             {DQ_WIDTH/4{4'h0}},{DQ_WIDTH/4{4'hF}}};
      2'b11: 
        phy_wrdata <= #TCQ {{DQ_WIDTH/4{4'h6}},{DQ_WIDTH/4{4'h9}},
                             {DQ_WIDTH/4{4'hA}},{DQ_WIDTH/4{4'h5}}};
    endcase
   end
endgenerate       
  generate
    if (nCK_PER_CLK == 4) begin: div_4
      if (!(CWL_M % 2)) begin: even_cwl
        always @(posedge clk) begin
          if ((init_state_r == INIT_LOAD_MR) ||
              (init_state_r == INIT_REG_WRITE) ||
              (init_state_r == INIT_WRLVL_START) ||
              (init_state_r == INIT_WRLVL_LOAD_MR) ||
              (init_state_r == INIT_WRLVL_LOAD_MR2) ||
              (init_state_r == INIT_RDLVL_ACT) ||
              (init_state_r == INIT_WRCAL_ACT) ||
              (init_state_r == INIT_PRECHARGE) ||
              (init_state_r == INIT_DDR2_PRECHARGE) ||
              (init_state_r == INIT_REFRESH))begin
            phy_ras_n[0] <= #TCQ 1'b0;
            phy_ras_n[1] <= #TCQ 1'b1;
            phy_ras_n[2] <= #TCQ 1'b1;
            phy_ras_n[3] <= #TCQ 1'b1;
          end else begin
            phy_ras_n[0] <= #TCQ 1'b1;
            phy_ras_n[1] <= #TCQ 1'b1;
            phy_ras_n[2] <= #TCQ 1'b1;
            phy_ras_n[3] <= #TCQ 1'b1;
          end
        end
        always @(posedge clk) begin
          if ((init_state_r == INIT_LOAD_MR) ||
              (init_state_r == INIT_REG_WRITE) ||
              (init_state_r == INIT_WRLVL_START) ||
              (init_state_r == INIT_WRLVL_LOAD_MR) ||
              (init_state_r == INIT_WRLVL_LOAD_MR2) ||
              (init_state_r == INIT_REFRESH) ||
              (rdlvl_wr_rd && new_burst_r))begin
            phy_cas_n[0] <= #TCQ 1'b0;
            phy_cas_n[1] <= #TCQ 1'b1;
            phy_cas_n[2] <= #TCQ 1'b1;
            phy_cas_n[3] <= #TCQ 1'b1;
          end else begin
            phy_cas_n[0] <= #TCQ 1'b1;
            phy_cas_n[1] <= #TCQ 1'b1;
            phy_cas_n[2] <= #TCQ 1'b1;
            phy_cas_n[3] <= #TCQ 1'b1;
          end
        end
        always @(posedge clk) begin
          if ((init_state_r == INIT_LOAD_MR) ||
              (init_state_r == INIT_REG_WRITE) ||
              (init_state_r == INIT_ZQCL) ||
              (init_state_r == INIT_WRLVL_START) ||
              (init_state_r == INIT_WRLVL_LOAD_MR) ||
              (init_state_r == INIT_WRLVL_LOAD_MR2) ||
              (init_state_r == INIT_PRECHARGE) ||
              (init_state_r == INIT_DDR2_PRECHARGE)||
              (rdlvl_wr && new_burst_r))begin
            phy_we_n[0] <= #TCQ 1'b0;
            phy_we_n[1] <= #TCQ 1'b1;
            phy_we_n[2] <= #TCQ 1'b1;
            phy_we_n[3] <= #TCQ 1'b1;
          end else begin
            phy_we_n[0] <= #TCQ 1'b1;
            phy_we_n[1] <= #TCQ 1'b1;
            phy_we_n[2] <= #TCQ 1'b1;
            phy_we_n[3] <= #TCQ 1'b1;
          end
        end  
      end else begin: odd_cwl
        always @(posedge clk) begin
          if ((init_state_r == INIT_LOAD_MR) ||
              (init_state_r == INIT_REG_WRITE) ||
              (init_state_r == INIT_WRLVL_START) ||
              (init_state_r == INIT_WRLVL_LOAD_MR) ||
              (init_state_r == INIT_WRLVL_LOAD_MR2) ||
              (init_state_r == INIT_RDLVL_ACT) ||
              (init_state_r == INIT_WRCAL_ACT) ||
              (init_state_r == INIT_PRECHARGE) ||
              (init_state_r == INIT_DDR2_PRECHARGE) ||
              (init_state_r == INIT_REFRESH))begin
            phy_ras_n[0] <= #TCQ 1'b1;
            phy_ras_n[1] <= #TCQ 1'b0;
            phy_ras_n[2] <= #TCQ 1'b1;
            phy_ras_n[3] <= #TCQ 1'b1;
          end else begin
            phy_ras_n[0] <= #TCQ 1'b1;
            phy_ras_n[1] <= #TCQ 1'b1;
            phy_ras_n[2] <= #TCQ 1'b1;
            phy_ras_n[3] <= #TCQ 1'b1;
          end
        end
        always @(posedge clk) begin
          if ((init_state_r == INIT_LOAD_MR) ||
              (init_state_r == INIT_REG_WRITE) ||
              (init_state_r == INIT_WRLVL_START) ||
              (init_state_r == INIT_WRLVL_LOAD_MR) ||
              (init_state_r == INIT_WRLVL_LOAD_MR2) ||
              (init_state_r == INIT_REFRESH) ||
              (rdlvl_wr_rd && new_burst_r))begin
            phy_cas_n[0] <= #TCQ 1'b1;
            phy_cas_n[1] <= #TCQ 1'b0;
            phy_cas_n[2] <= #TCQ 1'b1;
            phy_cas_n[3] <= #TCQ 1'b1;
          end else begin
            phy_cas_n[0] <= #TCQ 1'b1;
            phy_cas_n[1] <= #TCQ 1'b1;
            phy_cas_n[2] <= #TCQ 1'b1;
            phy_cas_n[3] <= #TCQ 1'b1;
          end
        end
        always @(posedge clk) begin
          if ((init_state_r == INIT_LOAD_MR) ||
              (init_state_r == INIT_REG_WRITE) ||
              (init_state_r == INIT_ZQCL) ||
              (init_state_r == INIT_WRLVL_START) ||
              (init_state_r == INIT_WRLVL_LOAD_MR) ||
              (init_state_r == INIT_WRLVL_LOAD_MR2) ||
              (init_state_r == INIT_PRECHARGE) ||
              (init_state_r == INIT_DDR2_PRECHARGE)||
              (rdlvl_wr && new_burst_r))begin
            phy_we_n[0] <= #TCQ 1'b1;
            phy_we_n[1] <= #TCQ 1'b0;
            phy_we_n[2] <= #TCQ 1'b1;
            phy_we_n[3] <= #TCQ 1'b1;
          end else begin
            phy_we_n[0] <= #TCQ 1'b1;
            phy_we_n[1] <= #TCQ 1'b1;
            phy_we_n[2] <= #TCQ 1'b1;
            phy_we_n[3] <= #TCQ 1'b1;
          end
        end  
      end 
    end else begin: div_2
      always @(posedge clk) begin
        if ((init_state_r == INIT_LOAD_MR) ||
            (init_state_r == INIT_REG_WRITE) ||
            (init_state_r == INIT_WRLVL_START) ||
            (init_state_r == INIT_WRLVL_LOAD_MR) ||
            (init_state_r == INIT_WRLVL_LOAD_MR2) ||
            (init_state_r == INIT_RDLVL_ACT) || 
            (init_state_r == INIT_WRCAL_ACT) ||
            (init_state_r == INIT_PRECHARGE) ||
            (init_state_r == INIT_DDR2_PRECHARGE) ||
            (init_state_r == INIT_REFRESH))begin
          phy_ras_n[0] <= #TCQ 1'b0;
          phy_ras_n[1] <= #TCQ 1'b0;
        end else begin
          phy_ras_n[0] <= #TCQ 1'b1;
          phy_ras_n[1] <= #TCQ 1'b1;
        end
      end
      always @(posedge clk) begin
        if ((init_state_r == INIT_LOAD_MR) ||
            (init_state_r == INIT_REG_WRITE) ||
            (init_state_r == INIT_WRLVL_START) ||
            (init_state_r == INIT_WRLVL_LOAD_MR) ||
            (init_state_r == INIT_WRLVL_LOAD_MR2) ||
            (init_state_r == INIT_REFRESH) ||
            (rdlvl_wr_rd && new_burst_r))begin
          phy_cas_n[0] <= #TCQ 1'b0;
          phy_cas_n[1] <= #TCQ 1'b0;
        end else begin
          phy_cas_n[0] <= #TCQ 1'b1;
          phy_cas_n[1] <= #TCQ 1'b1;
        end
      end
      always @(posedge clk) begin
        if ((init_state_r == INIT_LOAD_MR) ||
            (init_state_r == INIT_REG_WRITE) ||
            (init_state_r == INIT_ZQCL) ||
            (init_state_r == INIT_WRLVL_START) ||
            (init_state_r == INIT_WRLVL_LOAD_MR) ||
            (init_state_r == INIT_WRLVL_LOAD_MR2) ||
            (init_state_r == INIT_PRECHARGE) ||
            (init_state_r == INIT_DDR2_PRECHARGE)||
            (rdlvl_wr && new_burst_r))begin
          phy_we_n[0] <= #TCQ 1'b0;
          phy_we_n[1] <= #TCQ 1'b0;
        end else begin
          phy_we_n[0] <= #TCQ 1'b1;
          phy_we_n[1] <= #TCQ 1'b1;
        end
      end
    end
  endgenerate
  always @(posedge clk) begin
    if (wr_level_dqs_asrt) begin
      calib_cmd         <= #TCQ 3'b001;
      if (CWL_M % 2) 
        calib_data_offset <= #TCQ CWL_M + 3;
      else 
        calib_data_offset <= #TCQ CWL_M + 2;
    end else if (rdlvl_wr && new_burst_r) begin
      calib_cmd         <= #TCQ 3'b001;
      if (CWL_M % 2) 
        calib_data_offset <= #TCQ CWL_M + 3;
      else 
        calib_data_offset <= #TCQ CWL_M + 2;
    end else if (rdlvl_rd && new_burst_r) begin
      calib_cmd         <= #TCQ 3'b011;
      if (~pi_calib_done_r)
        calib_data_offset <= #TCQ 6'd0;
      else if (~pi_dqs_found_done_r1)
        calib_data_offset <= #TCQ rd_data_offset;
      else
        calib_data_offset <= #TCQ rd_data_offset_ranks[6*chip_cnt_r+:6];
    end else begin
      calib_cmd         <= #TCQ 3'b100;
      calib_data_offset <= #TCQ 6'd0;
    end
  end
  always @(posedge clk) begin
    if (rst) begin
      calib_ctl_wren <= #TCQ 1'b0;
      calib_cmd_wren <= #TCQ 1'b0;
      calib_seq      <= #TCQ 2'b00;
    end else if (cnt_pwron_cke_done_r && phy_ctl_ready
                 && ~(phy_ctl_full || phy_cmd_full)) begin
      calib_ctl_wren <= #TCQ 1'b1;
      calib_cmd_wren <= #TCQ 1'b1;
      calib_seq      <= #TCQ calib_seq + 1;
    end else begin
      calib_ctl_wren <= #TCQ 1'b0;
      calib_cmd_wren <= #TCQ 1'b0;
      calib_seq      <= #TCQ calib_seq;
    end
  end
   generate
   genvar rnk_i;
     for (rnk_i = 0; rnk_i < 4; rnk_i = rnk_i + 1) begin: gen_rnk
       always @(posedge clk) begin
         if (rst) begin
           mr2_r[rnk_i]  <= #TCQ 2'b00;
           mr1_r[rnk_i]  <= #TCQ 3'b000;
         end else begin
           mr2_r[rnk_i]  <= #TCQ tmp_mr2_r[rnk_i];
           mr1_r[rnk_i]  <= #TCQ tmp_mr1_r[rnk_i];
         end
       end
     end
   endgenerate
generate
  if (nSLOTS == 1) begin: gen_single_slot_odt
    always @(posedge clk) begin
      tmp_mr2_r[1]   <= #TCQ 2'b00;
      tmp_mr2_r[2]   <= #TCQ 2'b00;
      tmp_mr2_r[3]   <= #TCQ 2'b00;
      tmp_mr1_r[1]   <= #TCQ 3'b000;
      tmp_mr1_r[2]   <= #TCQ 3'b000;
      tmp_mr1_r[3]   <= #TCQ 3'b000;
      phy_tmp_cs1_r <= #TCQ {CS_WIDTH*nCS_PER_RANK{1'b1}};
      phy_tmp_odt_r <= #TCQ 4'b0000;
      phy_tmp_odt_r1 <= #TCQ phy_tmp_odt_r;
      case ({slot_0_present[0],slot_0_present[1],
             slot_0_present[2],slot_0_present[3]})
      4'b1111: begin    
                 if ((RTT_WR == "OFF") || 
                    ((WRLVL=="ON") && ~wrlvl_done &&
                     (wrlvl_rank_cntr==3'd0))) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ 3'b000;
                 end
                 phy_tmp_odt_r <= #TCQ 4'b0001;
                 phy_tmp_cs1_r[((chip_cnt_r*nCS_PER_RANK)
                   ) +: nCS_PER_RANK] <= #TCQ 'b0;
      end 
      4'b1000: begin    
                 phy_tmp_odt_r <= #TCQ 4'b0001;
                 if ((REG_CTRL == "ON") && (nCS_PER_RANK > 1)) begin
                   phy_tmp_cs1_r[chip_cnt_r] <= #TCQ 1'b0;
                 end else begin
                   phy_tmp_cs1_r <= #TCQ {CS_WIDTH*nCS_PER_RANK{1'b0}};
                 end
                 if ((RTT_WR == "OFF") || 
                    ((WRLVL=="ON") && ~wrlvl_done)) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ 3'b000;
                 end
      end 
      4'b1100: begin
                 phy_tmp_odt_r <= #TCQ 4'b0001;
                 phy_tmp_cs1_r[((chip_cnt_r*nCS_PER_RANK)
                 ) +: nCS_PER_RANK] <= #TCQ 'b0;
                 if ((RTT_WR == "OFF") || 
                    ((WRLVL=="ON") && ~wrlvl_done &&
                     (wrlvl_rank_cntr==3'd0))) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ 3'b000;
                 end
      end 
      default: begin    
                 phy_tmp_odt_r <= #TCQ 4'b0001;
                 phy_tmp_cs1_r <= #TCQ {CS_WIDTH*nCS_PER_RANK{1'b0}};
                 if ((RTT_WR == "OFF") || 
                    ((WRLVL=="ON") && ~wrlvl_done)) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ 3'b000;
                 end
      end       
      endcase 
    end
  end else if (nSLOTS == 2) begin: gen_dual_slot_odt
    always @ (posedge clk) begin
      tmp_mr2_r[1]   <= #TCQ 2'b00;
      tmp_mr2_r[2]   <= #TCQ 2'b00;
      tmp_mr2_r[3]   <= #TCQ 2'b00;
      tmp_mr1_r[1]   <= #TCQ 3'b000;
      tmp_mr1_r[2]   <= #TCQ 3'b000;
      tmp_mr1_r[3]   <= #TCQ 3'b000;
      phy_tmp_odt_r  <= #TCQ 4'b0000;
      phy_tmp_cs1_r  <= #TCQ {CS_WIDTH*nCS_PER_RANK{1'b1}};
      phy_tmp_odt_r1 <= #TCQ phy_tmp_odt_r;
      case ({slot_0_present[0],slot_0_present[1],
             slot_1_present[0],slot_1_present[1]})       
      4'b10_00: begin
                 if (
                     (init_state_r == INIT_RDLVL_STG1_WRITE) ||
                     (init_state_r == INIT_WRCAL_WRITE)) begin
                   phy_tmp_odt_r <= #TCQ 4'b0001;
                 end
                 phy_tmp_cs1_r <= #TCQ {nCS_PER_RANK{1'b0}};
                 if ((RTT_WR == "OFF") || 
                    ((WRLVL=="ON") && ~wrlvl_done)) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ 3'b000;
                 end
               end
      4'b00_10: begin
                 if (
                     (init_state_r == INIT_RDLVL_STG1_WRITE) || 
                     (init_state_r == INIT_WRCAL_WRITE)) begin
                   phy_tmp_odt_r <= #TCQ 4'b0001;
                 end
                 phy_tmp_cs1_r <= #TCQ {nCS_PER_RANK{1'b0}};
                 if ((RTT_WR == "OFF") || 
                    ((WRLVL=="ON") && ~wrlvl_done)) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ 3'b000;
                 end
               end
      4'b00_11: begin
                 if (
                     (init_state_r == INIT_RDLVL_STG1_WRITE) || 
                     (init_state_r == INIT_WRCAL_WRITE)) begin
                   phy_tmp_odt_r  
                   <= #TCQ 4'b0001;
                 end
                 phy_tmp_cs1_r[(chip_cnt_r*nCS_PER_RANK) +: nCS_PER_RANK] 
                 <= #TCQ {nCS_PER_RANK{1'b0}};
                 if ((RTT_WR == "OFF") ||
                    ((WRLVL=="ON") && ~wrlvl_done &&
                     (wrlvl_rank_cntr==3'd0))) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ 3'b000;
                 end
               end
      4'b11_00: begin
                 if (
                     (init_state_r == INIT_RDLVL_STG1_WRITE) || 
                     (init_state_r == INIT_WRCAL_WRITE)) begin
                   phy_tmp_odt_r <= #TCQ 4'b0001;
                 end
                 phy_tmp_cs1_r[(chip_cnt_r*nCS_PER_RANK) +: nCS_PER_RANK] 
                 <= #TCQ {nCS_PER_RANK{1'b0}};
                 if ((RTT_WR == "OFF") ||
                    ((WRLVL=="ON") && ~wrlvl_done &&
                     (wrlvl_rank_cntr==3'd0))) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ 3'b000;
                 end
               end
      4'b10_10: begin
                 if(DRAM_TYPE == "DDR2")begin
                   if(chip_cnt_r == 2'b00)begin
                     phy_tmp_odt_r
                     <= #TCQ 4'b0010; 
                   end else begin
                     phy_tmp_odt_r
                     <= #TCQ 4'b0001; 
                   end
                 end else begin                       
                   if (
                       (init_state_r == INIT_RDLVL_STG1_WRITE) || 
                       (init_state_r == INIT_WRCAL_WRITE)) begin
                     phy_tmp_odt_r
                     <= #TCQ 4'b0011; 
                   end else if ((init_state_r == INIT_PI_PHASELOCK_READS) ||
                               (init_state_r == INIT_RDLVL_STG1_READ) || 
                               (init_state_r == INIT_RDLVL_STG2_READ) ||
                               (init_state_r == INIT_WRCAL_READ)) begin
                     if (chip_cnt_r == 2'b00) begin
                       phy_tmp_odt_r
                       <= #TCQ 4'b0010;
                     end else if (chip_cnt_r == 2'b01) begin 
                       phy_tmp_odt_r
                       <= #TCQ 4'b0001;
                     end
                   end
                 end 
                 phy_tmp_cs1_r[(chip_cnt_r*nCS_PER_RANK) +: nCS_PER_RANK] 
                  <= #TCQ {nCS_PER_RANK{1'b0}};
                 if ((RTT_WR == "OFF") ||
                    ((WRLVL=="ON") && ~wrlvl_done &&
                     (wrlvl_rank_cntr==3'd0))) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                   tmp_mr2_r[1] <= #TCQ 2'b00;
                   tmp_mr1_r[1] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "60") ? 3'b001 :
                                       (RTT_NOM == "120") ? 3'b010 :
                                       (RTT_NOM == "20") ? 3'b100 :
                                       (RTT_NOM == "30") ? 3'b101 :
                                       3'b011;
                   tmp_mr2_r[1] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[1] <= #TCQ (RTT_NOM == "60") ? 3'b001 :
                                       (RTT_NOM == "120") ? 3'b010 :
                                       (RTT_NOM == "20") ? 3'b100 :
                                       (RTT_NOM == "30") ? 3'b101 :
                                       3'b011;
                 end
               end
      4'b10_11: begin
                 tmp_mr1_r[2] <= #TCQ (RTT_NOM3 == "60") ? 3'b001 :
                                     (RTT_NOM3 == "120") ? 3'b010 :
                                     (RTT_NOM3 == "20") ? 3'b100 :
                                     (RTT_NOM3 == "30") ? 3'b101 :
                                     3'b011;
                 tmp_mr2_r[2] <= #TCQ 2'b00;
                 if ((RTT_WR == "OFF") ||
                    ((WRLVL=="ON") && ~wrlvl_done &&
                     (wrlvl_rank_cntr==3'd0))) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                   tmp_mr2_r[1] <= #TCQ 2'b00;
                   tmp_mr1_r[1] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "60") ? 3'b001 :
                                       (RTT_NOM == "120") ? 3'b010 :
                                       (RTT_NOM == "20") ? 3'b100 :
                                       (RTT_NOM == "30") ? 3'b101 :
                                       3'b011;
                   tmp_mr2_r[1] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[1] <= #TCQ 3'b000;
                 end
                 if(DRAM_TYPE == "DDR2")begin
                   if(chip_cnt_r == 2'b00)begin
                     phy_tmp_odt_r 
                     <= #TCQ 4'b0010;
                   end else begin
                     phy_tmp_odt_r 
                     <= #TCQ 4'b0001;
                   end
                 end else begin               
                   if (
                       (init_state_r == INIT_RDLVL_STG1_WRITE) || 
                       (init_state_r == INIT_WRCAL_WRITE)) begin
                     if (chip_cnt_r[0] == 1'b1) begin
                       phy_tmp_odt_r 
                       <= #TCQ 4'b0011;
                     end else begin
                       phy_tmp_odt_r 
                       <= #TCQ 4'b0101; 
                     end
                   end else if ((init_state_r == INIT_RDLVL_STG1_READ) 
                     || (init_state_r == INIT_PI_PHASELOCK_READS) ||
                        (init_state_r == INIT_RDLVL_STG2_READ) ||
                        (init_state_r == INIT_WRCAL_READ))begin
                     if (chip_cnt_r == 2'b00) begin
                       phy_tmp_odt_r 
                       <= #TCQ 4'b0100;
                     end else begin
                       phy_tmp_odt_r
                       <= #TCQ 4'b0001;
                     end
                   end
                 end 
                 phy_tmp_cs1_r[(chip_cnt_r*nCS_PER_RANK) +: nCS_PER_RANK] 
                 <= #TCQ {nCS_PER_RANK{1'b0}};   
               end
      4'b11_10: begin
                 tmp_mr1_r[2] <= #TCQ (RTT_NOM2 == "60") ? 3'b001 :
                                     (RTT_NOM2 == "120") ? 3'b010 :
                                     (RTT_NOM2 == "20") ? 3'b100 :
                                     (RTT_NOM2 == "30") ? 3'b101 :
                                     3'b011;
                 tmp_mr2_r[2] <= #TCQ 2'b00;
                 if ((RTT_WR == "OFF") ||
                    ((WRLVL=="ON") && ~wrlvl_done &&
                     (wrlvl_rank_cntr==3'd0))) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                   tmp_mr2_r[1] <= #TCQ 2'b00;
                   tmp_mr1_r[1] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[1] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[1] <= #TCQ (RTT_NOM == "60") ? 3'b001 :
                                       (RTT_NOM == "120") ? 3'b010 :
                                       (RTT_NOM == "20") ? 3'b100 :
                                       (RTT_NOM == "30") ? 3'b101 :
                                       3'b011;
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ 3'b000;
                 end 
                 if(DRAM_TYPE == "DDR2")begin
                   if(chip_cnt_r[1] == 1'b1)begin
                     phy_tmp_odt_r <= 
                     #TCQ 4'b0001;
                   end else begin
                     phy_tmp_odt_r 
                     <= #TCQ 4'b0100; 
                   end
                 end else begin 
                   if (
                       (init_state_r == INIT_RDLVL_STG1_WRITE) || 
                       (init_state_r == INIT_WRCAL_WRITE)) begin
                     if (chip_cnt_r[1] == 1'b1) begin
                       phy_tmp_odt_r 
                       <= #TCQ 4'b0110;
                     end else begin
                       phy_tmp_odt_r <= 
                       #TCQ 4'b0101;
                     end
                   end else if ((init_state_r == INIT_RDLVL_STG1_READ) 
                     ||  (init_state_r == INIT_PI_PHASELOCK_READS) ||
                         (init_state_r == INIT_RDLVL_STG2_READ) ||
                         (init_state_r == INIT_WRCAL_READ)) begin
                     if (chip_cnt_r[1] == 1'b1) begin
                       phy_tmp_odt_r[(1*nCS_PER_RANK) +: nCS_PER_RANK] 
                       <= #TCQ 4'b0010;
                     end else begin
                       phy_tmp_odt_r 
                       <= #TCQ 4'b0100;
                     end
                   end 
                 end 
                 phy_tmp_cs1_r[(chip_cnt_r*nCS_PER_RANK) +: nCS_PER_RANK] 
                 <= #TCQ {nCS_PER_RANK{1'b0}};
               end
      4'b11_11: begin
                 tmp_mr1_r[2] <= #TCQ (RTT_NOM2 == "60") ? 3'b001 :
                                     (RTT_NOM2 == "120") ? 3'b010 :
                                     (RTT_NOM2 == "20") ? 3'b100 :
                                     (RTT_NOM2 == "30") ? 3'b101 :
                                     3'b011;
                 tmp_mr1_r[3] <= #TCQ (RTT_NOM3 == "60") ? 3'b001 :
                                     (RTT_NOM3 == "120") ? 3'b010 :
                                     (RTT_NOM3 == "20") ? 3'b100 :
                                     (RTT_NOM3 == "30") ? 3'b101 :
                                     3'b011;
                 tmp_mr2_r[2] <= #TCQ 2'b00;
                 tmp_mr2_r[3] <= #TCQ 2'b00;
                 if ((RTT_WR == "OFF") ||
                    ((WRLVL=="ON") && ~wrlvl_done &&
                     (wrlvl_rank_cntr==3'd0))) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                   tmp_mr2_r[1] <= #TCQ 2'b00;
                   tmp_mr1_r[1] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[1] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[1] <= #TCQ 3'b000;
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ 3'b000;
                 end 
                 if(DRAM_TYPE == "DDR2")begin
                   if(chip_cnt_r[1] == 1'b1)begin
                     phy_tmp_odt_r
                     <= #TCQ 4'b0001;
                   end else begin
                     phy_tmp_odt_r
                     <= #TCQ 4'b0100;
                   end
                 end else begin
                   if (
                       (init_state_r == INIT_RDLVL_STG1_WRITE) || 
                       (init_state_r == INIT_WRCAL_WRITE)) begin
                     if (chip_cnt_r[0] == 1'b1) begin
                       phy_tmp_odt_r
                       <= #TCQ 4'b0110;
                     end else begin
                       phy_tmp_odt_r
                       <= #TCQ 4'b1001;
                     end
                   end else if ((init_state_r == INIT_RDLVL_STG1_READ) 
                     ||  (init_state_r == INIT_PI_PHASELOCK_READS) ||
                         (init_state_r == INIT_RDLVL_STG2_READ) ||
                         (init_state_r == INIT_WRCAL_READ))begin
                     if (chip_cnt_r[0] == 1'b1) begin
                       phy_tmp_odt_r
                       <= #TCQ 4'b0100;
                     end else begin
                       phy_tmp_odt_r
                       <= #TCQ 4'b1000;
                     end
                   end 
                 end 
                 phy_tmp_cs1_r[(chip_cnt_r*nCS_PER_RANK) +: nCS_PER_RANK] 
                 <= #TCQ {nCS_PER_RANK{1'b0}};
               end
      default: begin
                 phy_tmp_odt_r <= #TCQ 4'b1111;
                 phy_tmp_cs1_r[(chip_cnt_r*nCS_PER_RANK) +: nCS_PER_RANK] 
                 <= #TCQ {nCS_PER_RANK{1'b0}};
                 if ((RTT_WR == "OFF") ||
                    ((WRLVL=="ON") && ~wrlvl_done)) begin
                   tmp_mr2_r[0] <= #TCQ 2'b00;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                   tmp_mr2_r[1] <= #TCQ 2'b00;
                   tmp_mr1_r[1] <= #TCQ (RTT_NOM == "40") ? 3'b011 :
                                       (RTT_NOM == "60") ? 3'b001 :
                                       3'b010;
                 end else begin
                   tmp_mr2_r[0] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[0] <= #TCQ (RTT_NOM == "60") ? 3'b001 :
                                       (RTT_NOM == "120") ? 3'b010 :
                                       (RTT_NOM == "20") ? 3'b100 :
                                       (RTT_NOM == "30") ? 3'b101 :
                                       3'b011;
                   tmp_mr2_r[1] <= #TCQ (RTT_WR == "60") ? 2'b01 :
                                       2'b10;
                   tmp_mr1_r[1] <= #TCQ (RTT_NOM == "60") ? 3'b001 :
                                       (RTT_NOM == "120") ? 3'b010 :
                                       (RTT_NOM == "20") ? 3'b100 :
                                       (RTT_NOM == "30") ? 3'b101 :
                                       3'b011;
                 end
               end
      endcase
    end
  end
endgenerate
generate
  if ((nSLOTS == 1) && (RANKS > 2)) begin
    always @(posedge clk)
      if (rst) begin
        calib_aux_out0 <= #TCQ 4'b0000;
        calib_aux_out1 <= #TCQ 4'b0000;
      end else begin
        if (cnt_pwron_cke_done_r && ~cnt_pwron_cke_done_r1)
          calib_aux_out1 <= #TCQ {CKE_WIDTH{1'b1}};
        else
          calib_aux_out1 <= #TCQ {CKE_WIDTH{1'b0}}; 
        if ((((RTT_NOM == "DISABLED") && (RTT_WR == "OFF")) ||
         wrlvl_rank_done || wrlvl_rank_done_r1 ||
        (wrlvl_done && !wrlvl_done_r)) && (DRAM_TYPE == "DDR3"))
          calib_aux_out0 <= #TCQ 4'b0000;
        else if  (((DRAM_TYPE == "DDR3") 
               ||((RTT_NOM != "DISABLED") && (DRAM_TYPE == "DDR2"))) 
               && (((init_state_r == INIT_WRLVL_WAIT) && wrlvl_odt) || 
               (init_state_r == INIT_RDLVL_STG1_WRITE) ||
               (init_state_r == INIT_WRCAL_WRITE)))
            calib_aux_out0 <= #TCQ phy_tmp_odt_r;
        else
          calib_aux_out0 <= #TCQ 4'b0000;
      end
  end else if ((nSLOTS == 1) && (RANKS <= 2)) begin
    always @(posedge clk)
      if (rst) begin
        calib_aux_out0 <= #TCQ 4'b0000;
        calib_aux_out1 <= #TCQ 4'b0000;
      end else begin
        if (cnt_pwron_cke_done_r && ~cnt_pwron_cke_done_r1)begin
          calib_aux_out0[0] <= #TCQ 1'b1;
          calib_aux_out0[2] <= #TCQ 1'b1;
        end else begin
          calib_aux_out0[0] <= #TCQ 1'b0;
          calib_aux_out0[2] <= #TCQ 1'b0;
        end
        calib_aux_out1 <= #TCQ 4'b0000;
        if ((((RTT_NOM == "DISABLED") && (RTT_WR == "OFF")) ||
         wrlvl_rank_done || wrlvl_rank_done_r1 ||
        (wrlvl_done && !wrlvl_done_r)) && (DRAM_TYPE == "DDR3")) begin
          calib_aux_out0[1] <= #TCQ 1'b0;
          calib_aux_out0[3] <= #TCQ 1'b0;
        end else if (((DRAM_TYPE == "DDR3") 
               ||((RTT_NOM != "DISABLED") && (DRAM_TYPE == "DDR2"))) 
               && (((init_state_r == INIT_WRLVL_WAIT) && wrlvl_odt) || 
               (init_state_r == INIT_RDLVL_STG1_WRITE) ||
               (init_state_r == INIT_WRCAL_WRITE))) begin
          calib_aux_out0[1] <= #TCQ phy_tmp_odt_r[0];
          calib_aux_out0[3] <= #TCQ phy_tmp_odt_r[1];
        end else begin
          calib_aux_out0[1] <= #TCQ 1'b0;
          calib_aux_out0[3] <= #TCQ 1'b0;
        end
      end
  end else if ((nSLOTS == 2) && (RANKS > 2)) begin
    always @(posedge clk)
      if (rst) begin
        calib_aux_out0 <= #TCQ 4'b0000;
        calib_aux_out1 <= #TCQ 4'b0000;
      end else begin
        if (cnt_pwron_cke_done_r && ~cnt_pwron_cke_done_r1)
          calib_aux_out1 <= #TCQ {CKE_WIDTH{1'b1}};
        else
          calib_aux_out1 <= #TCQ {CKE_WIDTH{1'b0}}; 
        if ((((RTT_NOM == "DISABLED") && (RTT_WR == "OFF")) ||
         wrlvl_rank_done || wrlvl_rank_done_r1 ||
        (wrlvl_done && !wrlvl_done_r)) && (DRAM_TYPE == "DDR3"))
          calib_aux_out0 <= #TCQ 4'b0000;
        else if (((DRAM_TYPE == "DDR3") 
               ||((RTT_NOM != "DISABLED") && (DRAM_TYPE == "DDR2"))) 
               && (((init_state_r == INIT_WRLVL_WAIT) && wrlvl_odt) || 
               (init_state_r == INIT_RDLVL_STG1_WRITE) ||
               (init_state_r == INIT_WRCAL_WRITE)))
            calib_aux_out0 <= #TCQ phy_tmp_odt_r | phy_tmp_odt_r1;
        else
          calib_aux_out0 <= #TCQ 4'b0000;
      end
  end else if ((nSLOTS == 2) && (RANKS <= 2)) begin
    always @(posedge clk)
      if (rst) begin
        calib_aux_out0 <= #TCQ 4'b0000;
        calib_aux_out1 <= #TCQ 4'b0000;
      end else begin
        if (cnt_pwron_cke_done_r && ~cnt_pwron_cke_done_r1)begin
          calib_aux_out0[0] <= #TCQ 1'b1;
          calib_aux_out0[2] <= #TCQ 1'b1;
        end else begin
          calib_aux_out0[0] <= #TCQ 1'b0;
          calib_aux_out0[2] <= #TCQ 1'b0;
        end
        calib_aux_out1 <= #TCQ 4'b0000;
        if ((((RTT_NOM == "DISABLED") && (RTT_WR == "OFF")) ||
         wrlvl_rank_done || wrlvl_rank_done_r1 ||
        (wrlvl_done && !wrlvl_done_r)) && (DRAM_TYPE == "DDR3")) begin
          calib_aux_out0[1] <= #TCQ 1'b0;
          calib_aux_out0[3] <= #TCQ 1'b0;
        end else if (((DRAM_TYPE == "DDR3") 
               ||((RTT_NOM != "DISABLED") && (DRAM_TYPE == "DDR2"))) 
               && (((init_state_r == INIT_WRLVL_WAIT) && wrlvl_odt) || 
               (init_state_r == INIT_RDLVL_STG1_WRITE) ||
               (init_state_r == INIT_WRCAL_WRITE))) begin
          calib_aux_out0[1] <= #TCQ phy_tmp_odt_r[0] | phy_tmp_odt_r1[0];
          calib_aux_out0[3] <= #TCQ phy_tmp_odt_r[1] | phy_tmp_odt_r1[1];
        end else begin
          calib_aux_out0[1] <= #TCQ 1'b0;
          calib_aux_out0[3] <= #TCQ 1'b0;
        end
      end
  end
endgenerate
  always @(burst_addr_r or cnt_init_mr_r or chip_cnt_r
           or ddr2_refresh_flag_r or init_state_r or load_mr0
           or load_mr1 or load_mr2 or load_mr3 or mr1_r[chip_cnt_r][0]
           or mr1_r[chip_cnt_r][1] or mr1_r[chip_cnt_r][2] or mr2_r[chip_cnt_r]
           or rdlvl_stg1_done or pi_dqs_found_done or rdlvl_wr_rd 
           or reg_ctrl_cnt_r)begin
    address_w = 'b0;
    bank_w   = 'b0;
    if ((init_state_r == INIT_PRECHARGE) ||
        (init_state_r == INIT_ZQCL) ||
        (init_state_r == INIT_DDR2_PRECHARGE)) begin
      address_w     = 'b0;
      address_w[10] = 1'b1;
      bank_w        = 'b0;
    end else if (init_state_r == INIT_WRLVL_START) begin
      bank_w[1:0]   = 2'b01;
      address_w     = load_mr1[ROW_WIDTH-1:0];
      address_w[7]  = 1'b1;
    end else if (init_state_r == INIT_WRLVL_LOAD_MR) begin
      bank_w[1:0]   = 2'b01;
      address_w     = load_mr1[ROW_WIDTH-1:0];
      address_w[2]  = mr1_r[chip_cnt_r][0];
      address_w[6]  = mr1_r[chip_cnt_r][1];
      address_w[9]  = mr1_r[chip_cnt_r][2];
    end else if (init_state_r == INIT_WRLVL_LOAD_MR2) begin
      bank_w[1:0]     = 2'b10;
      address_w       = load_mr2[ROW_WIDTH-1:0];
      address_w[10:9] = mr2_r[chip_cnt_r];
    end else if ((init_state_r == INIT_REG_WRITE)&
             (DRAM_TYPE == "DDR3"))begin
      bank_w        = 'b0;
      address_w     = 'b0;
      case (reg_ctrl_cnt_r)
        REG_RC0[2:0]: address_w[4:0] = REG_RC0[4:0];
        REG_RC1[2:0]:begin
          address_w[4:0] = REG_RC1[4:0];
          bank_w         = REG_RC1[7:5];
        end
        REG_RC2[2:0]: address_w[4:0] = REG_RC2[4:0];
        REG_RC3[2:0]: address_w[4:0] = REG_RC3[4:0];
        REG_RC4[2:0]: address_w[4:0] = REG_RC4[4:0];
        REG_RC5[2:0]: address_w[4:0] = REG_RC5[4:0];
      endcase
    end else if (init_state_r == INIT_LOAD_MR) begin
      address_w     = 'b0;
      bank_w        = 'b0;
      if(DRAM_TYPE == "DDR3")begin
        if(rdlvl_stg1_done && pi_dqs_found_done)begin
          bank_w[1:0] = 2'b00;
          address_w   = load_mr0[ROW_WIDTH-1:0];
          address_w[8]= 1'b0; 
        end else begin
         case (cnt_init_mr_r)
           INIT_CNT_MR2: begin
             bank_w[1:0] = 2'b10;
             address_w   = load_mr2[ROW_WIDTH-1:0];
             address_w[10:9] = mr2_r[chip_cnt_r];
           end
           INIT_CNT_MR3: begin
             bank_w[1:0] = 2'b11;
             address_w   = load_mr3[ROW_WIDTH-1:0];
           end
           INIT_CNT_MR1: begin
             bank_w[1:0] = 2'b01;
             address_w   = load_mr1[ROW_WIDTH-1:0];
             address_w[2] = mr1_r[chip_cnt_r][0];
             address_w[6] = mr1_r[chip_cnt_r][1];
             address_w[9] = mr1_r[chip_cnt_r][2];
           end
           INIT_CNT_MR0: begin
             bank_w[1:0] = 2'b00;
             address_w   = load_mr0[ROW_WIDTH-1:0];
             address_w[1:0] = 2'b00;
           end
           default: begin
             bank_w      = {BANK_WIDTH{1'bx}};
             address_w   = {ROW_WIDTH{1'bx}};
           end
          endcase 
         end 
        end else begin 
         case (cnt_init_mr_r)
           INIT_CNT_MR2: begin
             if(~ddr2_refresh_flag_r)begin
                bank_w[1:0] = 2'b10;
                address_w   = load_mr2[ROW_WIDTH-1:0];
             end else begin 
                bank_w[1:0] = 2'b00;
                address_w   = load_mr0[ROW_WIDTH-1:0];
                address_w[8]= 1'b0;
             end
          end
           INIT_CNT_MR3: begin
             if(~ddr2_refresh_flag_r)begin
               bank_w[1:0] = 2'b11;
               address_w   = load_mr3[ROW_WIDTH-1:0];
             end else begin 
               bank_w[1:0] = 2'b00;
               address_w   = load_mr0[ROW_WIDTH-1:0];
               address_w[8]= 1'b0;
            end
           end
           INIT_CNT_MR1: begin
             bank_w[1:0] = 2'b01;            
             if(~ddr2_refresh_flag_r)begin               
               address_w   = load_mr1[ROW_WIDTH-1:0];  
             end else begin 
               address_w   = load_mr1[ROW_WIDTH-1:0];
               address_w[9:7] = 3'b111;
             end
           end
           INIT_CNT_MR0: begin
             if(~ddr2_refresh_flag_r)begin
               bank_w[1:0] = 2'b00;
               address_w   = load_mr0[ROW_WIDTH-1:0];
             end else begin 
               bank_w[1:0] = 2'b01;
               address_w   = load_mr1[ROW_WIDTH-1:0];
               if((chip_cnt_r == 2'd1) || (chip_cnt_r == 2'd3))begin
                 address_w[2] = 'b0;
                 address_w[6] = 'b0;
               end 
             end
           end
           default: begin
             bank_w      = {BANK_WIDTH{1'bx}};
             address_w   = {ROW_WIDTH{1'bx}};
           end
         endcase 
       end
    end else if ((init_state_r == INIT_PI_PHASELOCK_READS) ||
                 (init_state_r == INIT_RDLVL_STG1_WRITE) ||
                 (init_state_r == INIT_RDLVL_STG1_READ)) begin
      bank_w    = CALIB_BA_ADD[BANK_WIDTH-1:0];
      address_w[ROW_WIDTH-1:COL_WIDTH] = {ROW_WIDTH-COL_WIDTH{1'b0}};
      if (stg1_wr_rd_cnt == NUM_STG1_WR_RD)
        address_w[COL_WIDTH-1:0] = {COL_WIDTH{1'b0}};
      else if (stg1_wr_rd_cnt >= 9'd0)
        address_w[COL_WIDTH-1:0] = phy_address[COL_WIDTH-1:0] + ADDR_INC;
    end else if ((init_state_r == INIT_WRCAL_WRITE) ||
                 (init_state_r == INIT_WRCAL_READ) ||
                 (init_state_r == INIT_RDLVL_STG2_READ)) begin
      bank_w    = CALIB_BA_ADD[BANK_WIDTH-1:0];
      address_w[ROW_WIDTH-1:COL_WIDTH] = {ROW_WIDTH-COL_WIDTH{1'b0}};
      address_w[COL_WIDTH-1:0] = 
                {CALIB_COL_ADD[COL_WIDTH-1:3],burst_addr_r, 3'b000};
      address_w[12]            =  1'b1;
    end else if ((init_state_r == INIT_RDLVL_ACT) ||
                (init_state_r == INIT_WRCAL_ACT)) begin
      bank_w    = CALIB_BA_ADD[BANK_WIDTH-1:0];
      address_w = CALIB_ROW_ADD[ROW_WIDTH-1:0];
    end else begin
      bank_w    = {BANK_WIDTH{1'bx}};
      address_w = {ROW_WIDTH{1'bx}};
    end
  end      
  always @(posedge clk) begin
    for (i = 0; i < nCK_PER_CLK; i = i + 1) begin: div_clk_loop
      phy_address[(i*ROW_WIDTH) +: ROW_WIDTH] <= #TCQ address_w;
      phy_bank[(i*BANK_WIDTH) +: BANK_WIDTH]  <= #TCQ bank_w;
    end
  end
endmodule
