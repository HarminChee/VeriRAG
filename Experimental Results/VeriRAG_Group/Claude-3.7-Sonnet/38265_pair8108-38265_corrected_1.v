`timescale 1ps / 1ps
module pcie3_7x_0_gt_top #
(
  parameter               TCQ                        = 100,
  parameter               PL_LINK_CAP_MAX_LINK_WIDTH = 8,      
  parameter               PL_LINK_CAP_MAX_LINK_SPEED = 3,      
  parameter               REF_CLK_FREQ               = 0,      
  parameter  integer      USER_CLK_FREQ             = 5,
  parameter  integer      USER_CLK2_FREQ            = 4,
  parameter               PL_SIM_FAST_LINK_TRAINING = "FALSE", 
  parameter               PCIE_EXT_CLK              = "FALSE", 
  parameter               PCIE_EXT_GT_COMMON        = "FALSE", 
  parameter               EXT_CH_GT_DRP             = "FALSE",      
  parameter               EXT_QPLL_GT_DRP           = "FALSE",      
  parameter               PCIE_TXBUF_EN             = "FALSE",
  parameter               PCIE_GT_DEVICE            = "GTH",
  parameter               PCIE_CHAN_BOND            = 0,       
  parameter               PCIE_CHAN_BOND_EN         = "FALSE", 
  parameter               PCIE_USE_MODE             = "1.1",
  parameter               PCIE_LPM_DFE              = "LPM",
  parameter               TX_MARGIN_FULL_0          = 7'b1001111,                          
  parameter               TX_MARGIN_FULL_1          = 7'b1001110,                          
  parameter               TX_MARGIN_FULL_2          = 7'b1001101,                          
  parameter               TX_MARGIN_FULL_3          = 7'b1001100,                          
  parameter               TX_MARGIN_FULL_4          = 7'b1000011,                          
  parameter               TX_MARGIN_LOW_0           = 7'b1000101,                          
  parameter               TX_MARGIN_LOW_1           = 7'b1000110,                          
  parameter               TX_MARGIN_LOW_2           = 7'b1000011,                          
  parameter               TX_MARGIN_LOW_3           = 7'b1000010,                          
  parameter               TX_MARGIN_LOW_4           = 7'b1000000,
  parameter               PCIE_LINK_SPEED           = 3
) 
(
  input                                             test_i,
  input   wire                                      pipe_tx_rcvr_det,
  input   wire                                      pipe_tx_reset,
  input   wire                               [1:0]  pipe_tx_rate,
  input   wire                                      pipe_tx_deemph,
  input   wire                               [2:0]  pipe_tx_margin,
  input   wire                                      pipe_tx_swing,
  output  wire                               [5:0]  pipe_txeq_fs,
  output  wire                               [5:0]  pipe_txeq_lf,
  input   wire                               [7:0]  pipe_rxslide,
  output  wire                               [7:0]  pipe_rxsync_done,
  input   wire                               [5:0]  cfg_ltssm_state,
  output  wire                               [1:0]  pipe_rx0_char_is_k,
  output  wire                              [31:0]  pipe_rx0_data,
  output  wire                                      pipe_rx0_valid,
  output  wire                                      pipe_rx0_chanisaligned,
  output  wire                               [2:0]  pipe_rx0_status,
  output  wire                                      pipe_rx0_phy_status,
  output  wire                                      pipe_rx0_elec_idle,
  input   wire                                      pipe_rx0_polarity,
  input   wire                                      pipe_tx0_compliance,
  input   wire                               [1:0]  pipe_tx0_char_is_k,
  input   wire                              [31:0]  pipe_tx0_data,
  input   wire                                      pipe_tx0_elec_idle,
  input   wire                               [1:0]  pipe_tx0_powerdown,
  input   wire                               [1:0]  pipe_tx0_eqcontrol,
  input   wire                               [3:0]  pipe_tx0_eqpreset,
  input   wire                               [5:0]  pipe_tx0_eqdeemph,
  output  wire                                      pipe_tx0_eqdone,
  output  wire                              [17:0]  pipe_tx0_eqcoeff,
  input   wire                               [1:0]  pipe_rx0_eqcontrol,
  input   wire                               [2:0]  pipe_rx0_eqpreset,
  input   wire                               [5:0]  pipe_rx0_eq_lffs,
  input   wire                               [3:0]  pipe_rx0_eq_txpreset,
  output  wire                              [17:0]  pipe_rx0_eq_new_txcoeff,
  output  wire                                      pipe_rx0_eq_lffs_sel,
  output  wire                                      pipe_rx0_eq_adapt_done,
  output  wire                                      pipe_rx0_eqdone,
  input   wire                                      pipe_clk,               
  input   wire                                      sys_rst_n,              
  output  wire                                      rec_clk,                
  output  wire                                      pipe_pclk,              
  output  wire                                      core_clk,
  output  wire                                      user_clk,
  output  wire                                      phy_rdy,
  output  wire                                      mmcm_lock,
  input   wire                                      pipe_mmcm_rst_n
);

  wire pipe_clk_int;
  wire sys_rst_n_int; 
  wire rec_clk_int;
  wire pipe_pclk_int;
  wire core_clk_int;
  wire user_clk_int;
  wire phy_rdy_int;
  wire mmcm_lock_int;

  assign pipe_clk_int = test_i ? pipe_mmcm_rst_n : pipe_clk;
  assign sys_rst_n_int = test_i ? pipe_mmcm_rst_n : sys_rst_n;
  assign rec_clk = test_i ? pipe_mmcm_rst_n : rec_clk_int;
  assign pipe_pclk = test_i ? pipe_mmcm_rst_n : pipe_pclk_int;
  assign core_clk = test_i ? pipe_mmcm_rst_n : core_clk_int;
  assign user_clk = test_i ? pipe_mmcm_rst_n : user_clk_int;
  assign phy_rdy = test_i ? pipe_mmcm_rst_n : phy_rdy_int;
  assign mmcm_lock = test_i ? pipe_mmcm_rst_n : mmcm_lock_int;

endmodule