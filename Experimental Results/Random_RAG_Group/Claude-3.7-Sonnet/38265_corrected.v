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
  // ... existing code ...
  input   wire                                       test_mode_i,
  input   wire                                       pipe_tx_rcvr_det,
  input   wire                                       pipe_tx_reset,
  input   wire                               [1:0]   pipe_tx_rate,
  // ... existing code ...
);

  // ... existing code ...
  
  wire dftoAUD_BCK;
  assign dftoAUD_BCK = test_mode_i ? pipe_clk : pipe_pclk;

  pcie3_7x_0_pipe_wrapper #(
    .PCIE_SIM_MODE            ( PL_SIM_FAST_LINK_TRAINING ),
    .PCIE_SIM_SPEEDUP         ( PCIE_SIM_SPEEDUP ),
    .PCIE_AUX_CDR_GEN3_EN     ( PCIE_AUX_CDR_GEN3_EN ),
    // ... existing code ...
    .PIPE_CLK                 ( dftoAUD_BCK ),
    // ... existing code ...
  ) pipe_wrapper_i (
    // ... existing code ...
  );

  // ... existing code ...

endmodule