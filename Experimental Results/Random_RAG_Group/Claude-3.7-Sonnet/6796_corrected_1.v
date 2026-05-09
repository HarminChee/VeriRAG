module data_vio
  (
    control,
    clk,
    async_in,
    async_out,
    sync_in,
    sync_out
  );
  inout  [35:0] control;
  input         clk;
  input  [31:0] async_in;
  output [31:0] async_out;
  input  [31:0] sync_in;
  output [31:0] sync_out;
endmodule
module icon
  (
      control0,
      control1,
      control2,
      control3
  );
  inout [35:0] control0;
  inout [35:0] control1;
  inout [35:0] control2;
  inout [35:0] control3;
endmodule
module ila
  (
    control,
    clk,
    trig0
  );
  inout [35:0]  control;
  input         clk    ;
  input [163:0] trig0  ;
endmodule
`timescale 1ns / 1ps
`define DLY #1
module mgtTop # 
(
    parameter EXAMPLE_CONFIG_INDEPENDENT_LANES     =   1,
    parameter EXAMPLE_LANE_WITH_START_CHAR         =   0,   
    parameter EXAMPLE_WORDS_IN_BRAM                =   512, 
    parameter EXAMPLE_SIM_GTRESET_SPEEDUP          =   "TRUE",   
    parameter EXAMPLE_USE_CHIPSCOPE                =   0    
)
(
    input wire  Q0_CLK0_GTREFCLK_PAD_N_IN,
    input wire  Q0_CLK0_GTREFCLK_PAD_P_IN,
    input wire  Q0_CLK1_GTREFCLK_PAD_N_IN,
    input wire  Q0_CLK1_GTREFCLK_PAD_P_IN,
    input wire  Q1_CLK0_GTREFCLK_PAD_N_IN,
    input wire  Q1_CLK0_GTREFCLK_PAD_P_IN,
    input wire  Q1_CLK1_GTREFCLK_PAD_N_IN,
    input wire  Q1_CLK1_GTREFCLK_PAD_P_IN,
    input wire  SYSCLK_IN,
    input wire  GTTXRESET_IN,
    input wire  GTRXRESET_IN,
    output wire TRACK_DATA_OUT,
    input  wire [7:0]   RXN_IN,
    input  wire [7:0]   RXP_IN,
    output wire [7:0]   TXN_OUT,
    output wire [7:0]   TXP_OUT,
    input wire          wb_clk,
    input wire          wb_reset,
    input wire          wb_stb_i,
    output reg [31:0]   wb_dat_o,
    input wire [31:0]   wb_dat_i,
    output reg          wb_ack_o,
    input wire [31:0]   wb_adr_i,
    input wire          wb_we_i,
    input wire          wb_cyc_i,
    input wire [3:0]    wb_sel_i,
    output wire         wb_err_o,
    output reg         wb_rty_o,
	input wire test_mode
);
    reg             gt0_txuserrdy_r;
    reg             gt0_txresetdone_r;
    reg             gt0_txresetdone_r2;
    reg             gt0_rxuserrdy_r;
    reg             gt0_rxresetdone_r;
    reg             gt0_rxresetdone_r2;
    reg             gt0_rxresetdone_r3;
    reg             gt1_txuserrdy_r;
    reg             gt1_txresetdone_r;
    reg             gt1_txresetdone_r2;
    reg             gt1_rxuserrdy_r;
    reg             gt1_rxresetdone_r;
    reg             gt1_rxresetdone_r2;
    reg             gt1_rxresetdone_r3;
    reg             gt2_txuserrdy_r;
    reg             gt2_txresetdone_r;
    reg             gt2_txresetdone_r2;
    reg             gt2_rxuserrdy_r;
    reg             gt2_rxresetdone_r;
    reg             gt2_rxresetdone_r2;
    reg             gt2_rxresetdone_r3;
    reg             gt3_txuserrdy_r;
    reg             gt3_txresetdone_r;
    reg             gt3_txresetdone_r2;
    reg             gt3_rxuserrdy_r;
    reg             gt3_rxresetdone_r;
    reg             gt3_rxresetdone_r2;
    reg             gt3_rxresetdone_r3;
    reg             gt4_txuserrdy_r;
    reg             gt4_txresetdone_r;
    reg             gt4_txresetdone_r2;
    reg             gt4_rxuserrdy_r;
    reg             gt4_rxresetdone_r;
    reg             gt4_rxresetdone_r2;
    reg             gt4_rxresetdone_r3;
    reg             gt5_txuserrdy_r;
    reg             gt5_txresetdone_r;
    reg             gt5_txresetdone_r2;
    reg             gt5_rxuserrdy_r;
    reg             gt5_rxresetdone_r;
    reg             gt5_rxresetdone_r2;
    reg             gt5_rxresetdone_r3;
    reg             gt6_txuserrdy_r;
    reg             gt6_txresetdone_r;
    reg             gt6_txresetdone_r2;
    reg             gt6_rxuserrdy_r;
    reg             gt6_rxresetdone_r;
    reg             gt6_rxresetdone_r2;
    reg             gt6_rxresetdone_r3;
    reg             gt7_txuserrdy_r;
    reg             gt7_txresetdone_r;
    reg             gt7_txresetdone_r2;
    reg             gt7_rxuserrdy_r;
    reg             gt7_rxresetdone_r;
    reg             gt7_rxresetdone_r2;
    reg             gt7_rxresetdone_r3;
    wire            gt0_cpllfbclklost_i;
    wire            gt0_cplllock_i;
    wire            gt0_cpllrefclklost_i;
    wire            gt0_cpllreset_i;
    wire            gt0_eyescandataerror_i;
    wire    [2:0]   gt0_loopback_i;
    wire    [1:0]   gt0_rxpd_i;
    wire    [1:0]   gt0_txpd_i;
    wire            gt0_rxuserrdy_i;
    wire    [1:0]   gt0_rxclkcorcnt_i;
    wire            gt0_rxbyteisaligned_i;
    wire            gt0_rxbyterealign_i;
    wire            gt0_rxcommadet_i;
    wire            gt0_rxslide_i;
    wire            gt0_gtrxreset_i;
    wire    [15:0]  gt0_rxdata_i;
    wire            gt0_rxoutclk_i;
    wire            gt0_rxpcsreset_i;
    wire            gt0_gtxrxn_i;
    wire            gt0_gtxrxp_i;
    wire            gt0_rxcdrlock_i;
    wire            gt0_rxelecidle_i;
    wire            gt0_rxbufreset_i;
    wire    [2:0]   gt0_rxbufstatus_i;
    wire            gt0_rxresetdone_i;
    wire            gt0_rxvalid_i;
    wire            gt0_txprecursorinv_i;
    wire            gt0_txuserrdy_i;
    wire            gt0_gttxreset_i;
    wire    [15:0]  gt0_txdata_i;
    wire            gt0_txoutclk_i;
    wire            gt0_txoutclkfabric_i;
    wire            gt0_txoutclkpcs_i;
    wire            gt0_txpcsreset_i;
    wire            gt0_gtxtxn_i;
    wire            gt0_gtxtxp_i;
    wire    [1:0]   gt0_txbufstatus_i;
    wire            gt0_txresetdone_i;
    wire            gt1_cpllfbclklost_i;
    wire            gt1_cplllock_i;
    wire            gt1_cpllrefclklost_i;
    wire            gt1_cpllreset_i;
    wire            gt1_eyescandataerror_i;
    wire    [2:0]   gt1_loopback_i;
    wire    [1:0]   gt1_rxpd_i;
    wire    [1:0]   gt1_txpd_i;
    wire            gt1_rxuserrdy_i;
    wire    [1:0]   gt1_rxclkcorcnt_i;
    wire            gt1_rxbyteisaligned_i;
    wire            gt1_rxbyterealign_i;
    wire            gt1_rxcommadet_i;
    wire            gt1_rxslide_i;
    wire            gt1_gtrxreset_i;
    wire    [15:0]  gt1_rxdata_i;
    wire            gt1_rxoutclk_i;
    wire            gt1_rxpcsreset_i;
    wire            gt1_gtxrxn_i;
    wire            gt1_gtxrxp_i;
    wire            gt1_rxcdrlock_i;
    wire            gt1_rxelecidle_i;
    wire            gt1_rxbufreset_i;
    wire    [2:0]   gt1_rxbufstatus_i;
    wire            gt1_rxresetdone_i;
    wire            gt1_rxvalid_i;
    wire            gt1_txprecursorinv_i;
    wire            gt1_txuserrdy_i;
    wire            gt1_gttxreset_i;
    wire    [15:0]  gt1_txdata_i;
    wire            gt1_txoutclk_i;
    wire            gt1_txoutclkfabric_i;
    wire            gt1_txoutclkpcs_i;
    wire            gt1_txpcsreset_i;
    wire            gt1_gtxtxn_i;
    wire            gt1_gtxtxp_i;
    wire    [1:0]   gt1_txbufstatus_i;
    wire            gt1_txresetdone_i;
    wire            gt2_cpllfbclklost_i;
    wire            gt2_cplllock_i;
    wire            gt2_cpllrefclklost_i;
    wire            gt2_cpllreset_i;
    wire            gt2_eyescandataerror_i;
    wire    [2:0]   gt2_loopback_i;
    wire    [1:0]   gt2_rxpd_i;
    wire    [1:0]   gt2_txpd_i;
    wire            gt2_rxuserrdy_i;
    wire    [1:0]   gt2_rxclkcorcnt_i;
    wire            gt2_rxbyteisaligned_i;
    wire            gt2_rxbyterealign_i;
    wire            gt2_rxcommadet_i;
    wire            gt2_rxslide_i;
    wire            gt2_gtrxreset_i;
    wire    [15:0]  gt2_rxdata_i;
    wire            gt2_rxoutclk_i;
    wire            gt2_rxpcsreset_i;
    wire            gt2_gtxrxn_i;
    wire            gt2_gtxrxp_i;
    wire            gt2_rxcdrlock_i;
    wire            gt2_rxelecidle_i;
    wire            gt2_rxbufreset_i;
    wire    [2:0]   gt2_rxbufstatus_i;
    wire            gt2_rxresetdone_i;
    wire            gt2_rxvalid_i;
    wire            gt2_txprecursorinv_i;
    wire            gt2_txuserrdy_i;
    wire            gt2_gttxreset_i;
    wire    [15:0]  gt2_txdata_i;
    wire            gt2_txoutclk_i;
    wire            gt2_txoutclkfabric_i;
    wire            gt2_txoutclkpcs_i;
    wire            gt2_txpcsreset_i;
    wire            gt2_gtxtxn_i;
    wire            gt2_gtxtxp_i;
    wire    [1:0]   gt2_txbufstatus_i;
    wire            gt2_txresetdone_i;
    wire            gt3_cpllfbclklost_i;
    wire            gt3_cplllock_i;
    wire            gt3_cpllrefclklost_i;
    wire            gt3_cpllreset_i;
    wire            gt3_eyescandataerror_i;
    wire    [2:0]   gt3_loopback_i;
    wire    [1:0]   gt3_rxpd_i;
    wire    [1:0]   gt3_txpd_i;
    wire            gt3_rxuserrdy_i;
    wire    [1:0]   gt3_rxclkcorcnt_i;
    wire            gt3_rxbyteisaligned_i;
    wire            gt3_rxbyterealign_i;
    wire            gt3_rxcommadet_i;
    wire            gt3_rxslide_i;
    wire            gt3_gtrxreset_i;
    wire    [15:0]  gt3_rxdata_i;
    wire            gt3_rxoutclk_i;
    wire            gt3_rxpcsreset_i;
    wire            gt3_gtxrxn_i;
    wire            gt3_gtxrxp_i;
    wire            gt3_rxcdrlock_i;
    wire            gt3_rxelecidle_i;
    wire            gt3_rxbufreset_i;
    wire    [2:0]   gt3_rxbufstatus_i;
    wire            gt3_rxresetdone_i;
    wire            gt3_rxvalid_i;
    wire            gt3_txprecursorinv_i;
    wire            gt3_txuserrdy_i;
    wire            gt3_gttxreset_i;
    wire    [15:0]  gt3_txdata_i;
    wire            gt3_txoutclk_i;
    wire            gt3_txoutclkfabric_i;
    wire            gt3_txoutclkpcs_i;
    wire            gt3_txpcsreset_i;
    wire            gt3_gtxtxn_i;
    wire            gt3_gtxtxp_i;
    wire    [1:0]   gt3_txbufstatus_i;
    wire            gt3_txresetdone_i;
    wire            gt4_cpllfbclklost_i;
    wire            gt4_cplllock_i;
    wire            gt4_cpllrefclklost_i;
    wire            gt4_cpllreset_i;
    wire            gt4_eyescandataerror_i;
    wire    [2:0]   gt4_loopback_i;
    wire    [1:0]   gt4_rxpd_i;
    wire    [1:0]   gt4_txpd_i;
    wire            gt4_rxuserrdy_i;
    wire    [1:0]   gt4_rxclkcorcnt_i;
    wire            gt4_rxbyteisaligned_i;
    wire            gt4_rxbyterealign_i;
    wire            gt4_rxcommadet_i;
    wire            gt4_rxslide_i;
    wire            gt4_gtrxreset_i;
    wire    [15:0]  gt4_rxdata_i;
    wire            gt4_rxoutclk_i;
    wire            gt4_rxpcsreset_i;
    wire            gt4_gtxrxn_i;
    wire            gt4_gtxrxp_i;
    wire            gt4_rxcdrlock_i;
    wire            gt4_rxelecidle_i;
    wire            gt4_rxbufreset_i;
    wire    [2:0]   gt4_rxbufstatus_i;
    wire            gt4_rxresetdone_i;
    wire            gt4_rxvalid_i;
    wire            gt4_txprecursorinv_i;
    wire            gt4_txuserrdy_i;
    wire            gt4_gttxreset_i;
    wire    [15:0]  gt4_txdata_i;
    wire            gt4_txoutclk_i;
    wire            gt4_txoutclkfabric_i;
    wire            gt4_txoutclkpcs_i;
    wire            gt4_txpcsreset_i;
    wire            gt4_gtxtxn_i;
    wire            gt4_gtxtxp_i;
    wire    [1:0]   gt4_txbufstatus_i;
    wire            gt4_txresetdone_i;
    wire            gt5_cpllfbclklost_i;
    wire            gt5_cplllock_i;
    wire            gt5_cpllrefclklost_i;
    wire            gt5_cpllreset_i;
    wire            gt5_eyescandataerror_i;
    wire    [2:0]   gt5_loopback_i;
    wire    [1:0]   gt5_rxpd_i;
    wire    [1:0]   gt5_txpd_i;
    wire            gt5_rxuserrdy_i;
    wire    [1:0]   gt5_rxclkcorcnt_i;
    wire            gt5_rxbyteisaligned_i;
    wire            gt5_rxbyterealign_i;
    wire            gt5_rxcommadet_i;
    wire            gt5_rxslide_i;
    wire            gt5_gtrxreset_i;
    wire    [15:0]  gt5_rxdata_i;
    wire            gt5_rxoutclk_i;
    wire            gt5_rxpcsreset_i;
    wire            gt5_gtxrxn_i;
    wire            gt5_gtxrxp_i;
    wire            gt5_rxcdrlock_i;
    wire            gt5_rxelecidle_i;
    wire            gt5_rxbufreset_i;
    wire    [2:0]   gt5_rxbufstatus_i;
    wire            gt5_rxresetdone_i;
    wire            gt5_rxvalid_i;
    wire            gt5_txprecursorinv_i;
    wire            gt5_txuserrdy_i;
    wire            gt5_gttxreset_i;
    wire    [15:0]  gt5_txdata_i;
    wire            gt5_txoutclk_i;
    wire            gt5_txoutclkfabric_i;
    wire            gt5_txoutclkpcs_i;
    wire            gt5_txpcsreset_i;
    wire            gt5_gtxtxn_i;
    wire            gt5_gtxtxp_i;
    wire    [1:0]   gt5_txbufstatus_i;
    wire            gt5_txresetdone_i;
    wire            gt6_cpllfbclklost_i;
    wire            gt6_cplllock_i;
    wire            gt6_cpllrefclklost_i;
    wire            gt6_cpllreset_i;
    wire            gt6_eyescandataerror_i;
    wire    [2:0]   gt6_loopback_i;
    wire    [1:0]   gt6_rxpd_i;
    wire    [1:0]   gt6_txpd_i;
    wire            gt6_rxuserrdy_i;
    wire    [1:0]   gt6_rxclkcorcnt_i;
    wire            gt6_rxbyteisaligned_i;
    wire            gt6_rxbyterealign_i;
    wire            gt6_rxcommadet_i;
    wire            gt6_rxslide_i;
    wire            gt6_gtrxreset_i;
    wire    [15:0]  gt6_rxdata_i;
    wire            gt6_rxoutclk_i;
    wire            gt6_rxpcsreset_i;
    wire            gt6_gtxrxn_i;
    wire            gt6_gtxrxp_i;
    wire            gt6_rxcdrlock_i;
    wire            gt6_rxelecidle_i;
    wire            gt6_rxbufreset_i;
    wire    [2:0]   gt6_rxbufstatus_i;
    wire            gt6_rxresetdone_i;
    wire            gt6_rxvalid_i;
    wire            gt6_txprecursorinv_i;
    wire            gt6_txuserrdy_i;
    wire            gt6_gttxreset_i;
    wire    [15:0]  gt6_txdata_i;
    wire            gt6_txoutclk_i;
    wire            gt6_txoutclkfabric_i;
    wire            gt6_txoutclkpcs_i;
    wire            gt6_txpcsreset_i;
    wire            gt6_gtxtxn_i;
    wire            gt6_gtxtxp_i;
    wire    [1:0]   gt6_txbufstatus_i;
    wire            gt6_txresetdone_i;
    wire            gt7_cpllfbclklost_i;
    wire            gt7_cplllock_i;
    wire            gt7_cpllrefclklost_i;
    wire            gt7_cpllreset_i;
    wire            gt7_eyescandataerror_i;
    wire    [2:0]   gt7_loopback_i;
    wire    [1:0]   gt7_rxpd_i;
    wire    [1:0]   gt7_txpd_i;
    wire            gt7_rxuserrdy_i;
    wire    [1:0]   gt7_rxclkcorcnt_i;
    wire            gt7_rxbyteisaligned_i;
    wire            gt7_rxbyterealign_i;
    wire            gt7_rxcommadet_i;
    wire            gt7_rxslide_i;
    wire            gt7_gtrxreset_i;
    wire    [15:0]  gt7_rxdata_i;
    wire            gt7_rxoutclk_i;
    wire            gt7_rxpcsreset_i;
    wire            gt7_gtxrxn_i;
    wire            gt7_gtxrxp_i;
    wire            gt7_rxcdrlock_i;
    wire            gt7_rxelecidle_i;
    wire            gt7_rxbufreset_i;
    wire    [2:0]   gt7_rxbufstatus_i;
    wire            gt7_rxresetdone_i;
    wire            gt7_rxvalid_i;
    wire            gt7_txprecursorinv_i;
    wire            gt7_txuserrdy_i;
    wire            gt7_gttxreset_i;
    wire    [15:0]  gt7_txdata_i;
    wire            gt7_txoutclk_i;
    wire            gt7_txoutclkfabric_i;
    wire            gt7_txoutclkpcs_i;
    wire            gt7_txpcsreset_i;
    wire            gt7_gtxtxn_i;
    wire            gt7_gtxtxp_i;
    wire    [1:0]   gt7_txbufstatus_i;
    wire            gt7_txresetdone_i;
    wire            drpclk_in_i;
    wire            gt0_tx_system_reset_c;
    wire            gt0_rx_system_reset_c;
    wire            gt1_tx_system_reset_c;
    wire            gt1_rx_system_reset_c;
    wire            gt2_tx_system_reset_c;
    wire            gt2_rx_system_reset_c;
    wire            gt3_tx_system_reset_c;
    wire            gt3_rx_system_reset_c;
    wire            gt4_tx_system_reset_c;
    wire            gt4_rx_system_reset_c;
    wire            gt5_tx_system_reset_c;
    wire            gt5_rx_system_reset_c;
    wire            gt6_tx_system_reset_c;
    wire            gt6_rx_system_reset_c;
    wire            gt7_tx_system_reset_c;
    wire            gt7_rx_system_reset_c;
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [7:0]   tied_to_vcc_vec_i;
    wire            gt0_txusrclk_i; 
    wire            gt0_txusrclk2_i; 
    wire            gt0_txclk_lock_out_i;
    wire            gt0_rxusrclk_i; 
    wire            gt0_rxusrclk2_i; 
    wire            gt0_rxclk_lock_out_i; 
    wire            gt1_txusrclk_i; 
    wire            gt1_txusrclk2_i; 
    wire            gt1_txclk_lock_out_i;
    wire            gt1_rxusrclk_i; 
    wire            gt1_rxusrclk2_i; 
    wire            gt1_rxclk_lock_out_i; 
    wire            gt2_txusrclk_i; 
    wire            gt2_txusrclk2_i; 
    wire            gt2_txclk_lock_out_i;
    wire            gt2_rxusrclk_i; 
    wire            gt2_rxusrclk2_i; 
    wire            gt2_rxclk_lock_out_i; 
    wire            gt3_txusrclk_i; 
    wire            gt3_txusrclk2_i; 
    wire            gt3_txclk_lock_out_i;
    wire            gt3_rxusrclk_i; 
    wire            gt3_rxusrclk2_i; 
    wire            gt3_rxclk_lock_out_i; 
    wire            gt4_txusrclk_i; 
    wire            gt4_txusrclk2_i; 
    wire            gt4_txclk_lock_out_i;
    wire            gt4_rxusrclk_i; 
    wire            gt4_rxusrclk2_i; 
    wire            gt4_rxclk_lock_out_i; 
    wire            gt5_txusrclk_i; 
    wire            gt5_txusrclk2_i; 
    wire            gt5_txclk_lock_out_i;
    wire            gt5_rxusrclk_i; 
    wire            gt5_rxusrclk2_i; 
    wire            gt5_rxclk_lock_out_i; 
    wire            gt6_txusrclk_i; 
    wire            gt6_txusrclk2_i; 
    wire            gt6_txclk_lock_out_i;
    wire            gt6_rxusrclk_i; 
    wire            gt6_rxusrclk2_i; 
    wire            gt6_rxclk_lock_out_i; 
    wire            gt7_txusrclk_i; 
    wire            gt7_txusrclk2_i; 
    wire            gt7_txclk_lock_out_i;
    wire            gt7_rxusrclk_i; 
    wire            gt7_rxusrclk2_i; 
    wire            gt7_rxclk_lock_out_i; 
    wire            q0_clk0_refclk_i;
    wire            q0_clk1_refclk_i;
    wire            q1_clk0_refclk_i;
    wire            q1_clk1_refclk_i;
    wire            gt0_matchn_i;
    wire    [5:0]   gt0_txcharisk_float_i;
    wire    [15:0]  gt0_txdata_float16_i;
    wire    [47:0]  gt0_txdata_float_i;
    wire            gt0_block_sync_i;
    wire            gt0_track_data_i;
    wire    [7:0]   gt0_error_count_i;
    wire            gt0_frame_check_reset_i;
    wire            gt0_inc_in_i;
    wire            gt0_inc_out_i;
    wire    [15:0]  gt0_unscrambled_data_i;
    wire            gt1_matchn_i;
    wire    [5:0]   gt1_txcharisk_float_i;
    wire    [15:0]  gt1_txdata_float16_i;
    wire    [47:0]  gt1_txdata_float_i;
    wire            gt1_block_sync_i;
    wire            gt1_track_data_i;
    wire    [7:0]   gt1_error_count_i;
    wire            gt1_frame_check_reset_i;
    wire            gt1_inc_in_i;
    wire            gt1_inc_out_i;
    wire    [15:0]  gt1_unscrambled_data_i;
    wire            gt2_matchn_i;
    wire    [5:0]   gt2_txcharisk_float_i;
    wire    [15:0]  gt2_txdata_float16_i;
    wire    [47:0]  gt2_txdata_float_i;
    wire            gt2_block_sync_i;
    wire            gt2_track_data_i;
    wire    [7:0]   gt2_error_count_i;
    wire            gt2_frame_check_reset_i;
    wire            gt2_inc_in_i;
    wire            gt2_inc_out_i;
    wire    [15:0]  gt2_unscrambled_data_i;
    wire            gt3_matchn_i;
    wire    [5:0]   gt3_txcharisk_float_i;
    wire    [15:0]  gt3_txdata_float16_i;
    wire    [47:0]  gt3_txdata_float_i;
    wire            gt3_block_sync_i;
    wire            gt3_track_data_i;
    wire    [7:0]   gt3_error_count_i;
    wire            gt3_frame_check_reset_i;
    wire            gt3_inc_in_i;
    wire            gt3_inc_out_i;
    wire    [15:0]  gt3_unscrambled_data_i;
    wire            gt4_matchn_i;
    wire    [5:0]   gt4_txcharisk_float_i;
    wire    [15:0]  gt4_txdata_float16_i;
    wire    [47:0]  gt4_txdata_float_i;
    wire            gt4_block_sync_i;
    wire            gt4_track_data_i;
    wire    [7:0]   gt4_error_count_i;
    wire            gt4_frame_check_reset_i;
    wire            gt4_inc_in_i;
    wire            gt4_inc_out_i;
    wire    [15:0]  gt4_unscrambled_data_i;
    wire            gt5_matchn_i;
    wire    [5:0]   gt5_txcharisk_float_i;
    wire    [15:0]  gt5_txdata_float16_i;
    wire    [47:0]  gt5