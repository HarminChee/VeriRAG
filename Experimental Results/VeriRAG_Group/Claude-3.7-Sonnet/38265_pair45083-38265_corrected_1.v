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
) (
  input   wire                                       pipe_tx_rcvr_det,
  input   wire                                       pipe_tx_reset,
  input   wire                               [1:0]   pipe_tx_rate,
  input   wire                                       pipe_tx_deemph,
  input   wire                               [2:0]   pipe_tx_margin,
  input   wire                                       pipe_tx_swing,
  input   wire                                       test_i,
  input   wire                                       scan_clk,
  input   wire                                       pipe_clk,
  input   wire                                       sys_rst_n,
  input   wire                                       pipe_pclk
);

  wire dft_pipe_tx_rcvr_det;
  assign dft_pipe_tx_rcvr_det = test_i ? scan_clk : pipe_tx_rcvr_det;
  
  wire dft_pipe_tx_reset;
  assign dft_pipe_tx_reset = test_i ? scan_clk : pipe_tx_reset;
  
  wire [1:0] dft_pipe_tx_rate;
  assign dft_pipe_tx_rate = test_i ? {2{scan_clk}} : pipe_tx_rate;
  
  wire dft_pipe_tx_deemph;
  assign dft_pipe_tx_deemph = test_i ? scan_clk : pipe_tx_deemph;
  
  wire [2:0] dft_pipe_tx_margin;
  assign dft_pipe_tx_margin = test_i ? {3{scan_clk}} : pipe_tx_margin;
  
  wire dft_pipe_tx_swing;
  assign dft_pipe_tx_swing = test_i ? scan_clk : pipe_tx_swing;

  pcie3_7x_0_pipe_wrapper pipe_wrapper_i (
    .PIPE_CLK                 ( pipe_clk ),
    .PIPE_RESET_N             ( sys_rst_n ),
    .PIPE_PCLK                ( pipe_pclk ),
    .PIPE_TXDETECTRX          ( dft_pipe_tx_rcvr_det ),
    .PIPE_TXRESET             ( dft_pipe_tx_reset ),
    .PIPE_TXRATE              ( dft_pipe_tx_rate ),
    .PIPE_TXDEEMPH            ( dft_pipe_tx_deemph ),
    .PIPE_TXMARGIN            ( dft_pipe_tx_margin ),
    .PIPE_TXSWING             ( dft_pipe_tx_swing )
  );

endmodule