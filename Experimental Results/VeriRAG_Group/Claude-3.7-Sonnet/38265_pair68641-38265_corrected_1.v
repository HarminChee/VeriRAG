module pcie3_7x_0_gt_top #(
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
  input   wire                                       pipe_clk,               
  input   wire                                       sys_rst_n,              
  input   wire                                       scan_rst,
  input   wire                                       test_i,
  input   wire                                       user_clk
);

  wire dft_pipe_clk, dft_sys_rst_n;
  assign dft_pipe_clk = test_i ? user_clk : pipe_clk;
  assign dft_sys_rst_n = test_i ? scan_rst : sys_rst_n;

  pcie3_7x_0_pipe_wrapper #(
  ) pipe_wrapper_i (
    .PIPE_CLK                 ( dft_pipe_clk ),
    .PIPE_RESET_N             ( dft_sys_rst_n )
  );

  reg [1:0] reg_clock_locked;
  reg [1:0] reg_phy_rdy;

  always @ (posedge user_clk or negedge dft_sys_rst_n) begin
    if (!dft_sys_rst_n)
      reg_clock_locked[1:0] <= #TCQ 2'b11;
    else
      reg_clock_locked[1:0] <= #TCQ {reg_clock_locked[0], 1'b0};
  end

  assign  clock_locked = !reg_clock_locked[1];

  always @ (posedge user_clk or negedge dft_sys_rst_n) begin
    if (!dft_sys_rst_n)
      reg_phy_rdy[1:0] <= #TCQ 2'b11;
    else
      reg_phy_rdy[1:0] <= #TCQ {reg_phy_rdy[0], 1'b0};
  end

  assign  phy_rdy = !reg_phy_rdy[1];

endmodule