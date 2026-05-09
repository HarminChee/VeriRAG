`timescale 1ns/1ns

module PCIEBus_gt_top #(
  parameter LINK_CAP_MAX_LINK_WIDTH = 8, 
  parameter REF_CLK_FREQ = 0,            
  parameter USER_CLK2_DIV2 = "FALSE",    
  parameter integer USER_CLK_FREQ = 3,           
  parameter PL_FAST_TRAIN = "FALSE",     
  parameter PCIE_EXT_CLK = "FALSE",      
  parameter PCIE_USE_MODE = "1.0",       
  parameter PCIE_GT_DEVICE = "GTX",      
  parameter PCIE_PLL_SEL = "CPLL",     
  parameter PCIE_ASYNC_EN = "FALSE",    
  parameter PCIE_TXBUF_EN = "FALSE",    
  parameter PCIE_CHAN_BOND = 0
)(
  input wire [5:0] pl_ltssm_state,
  input wire pipe_tx_rcvr_det,
  input wire pipe_tx_reset,
  input wire pipe_tx_rate,
  input wire pipe_clk_int,
  input wire clock_locked,
  input wire [LINK_CAP_MAX_LINK_WIDTH-1:0] phystatus_rst,

  input wire [15:0] pipe_tx0_data,
  input wire [15:0] pipe_tx1_data,
  input wire [15:0] pipe_tx2_data,
  input wire [15:0] pipe_tx3_data,
  input wire [15:0] pipe_tx4_data,
  input wire [15:0] pipe_tx5_data,
  input wire [15:0] pipe_tx6_data,
  input wire [15:0] pipe_tx7_data,

  input wire pipe_tx0_elec_idle,
  input wire pipe_tx1_elec_idle,
  input wire pipe_tx2_elec_idle,
  input wire pipe_tx3_elec_idle,
  input wire pipe_tx4_elec_idle,
  input wire pipe_tx5_elec_idle,
  input wire pipe_tx6_elec_idle,
  input wire pipe_tx7_elec_idle,

  output wire [127:0] gt_txdata,
  output wire gt_tx_detect_rx_loopback,
  output wire [7:0] gt_tx_elec_idle,
  output wire phy_rdy_n
);

  reg reg_clock_locked;
  reg phy_rdy_n_int;

  assign gt_txdata = {
    pipe_tx7_data, 16'd0,
    pipe_tx6_data, 16'd0,
    pipe_tx5_data, 16'd0,
    pipe_tx4_data, 16'd0,
    pipe_tx3_data, 16'd0,
    pipe_tx2_data, 16'd0,
    pipe_tx1_data, 16'd0,
    pipe_tx0_data
  };

  assign gt_tx_detect_rx_loopback = pipe_tx_rcvr_det;

  assign gt_tx_elec_idle = {
    pipe_tx7_elec_idle,
    pipe_tx6_elec_idle,
    pipe_tx5_elec_idle,
    pipe_tx4_elec_idle,
    pipe_tx3_elec_idle,
    pipe_tx2_elec_idle,
    pipe_tx1_elec_idle,
    pipe_tx0_elec_idle
  };

  always @(posedge pipe_clk_int or negedge clock_locked) begin
    if (!clock_locked)
      reg_clock_locked <= #1 1'b0;
    else
      reg_clock_locked <= #1 1'b1;
  end

  always @(posedge pipe_clk_int) begin
    if (!reg_clock_locked)
      phy_rdy_n_int <= #1 1'b0;
    else
      phy_rdy_n_int <= #1 all_phystatus_rst;
  end

  wire all_phystatus_rst;
  assign all_phystatus_rst = (&phystatus_rst[LINK_CAP_MAX_LINK_WIDTH-1:0]);

  assign phy_rdy_n = phy_rdy_n_int;

endmodule
