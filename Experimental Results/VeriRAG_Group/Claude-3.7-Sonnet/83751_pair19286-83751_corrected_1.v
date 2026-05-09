`timescale 1ns/1ns
module PCIeGen2x8If128_gt_top #
(
   parameter               LINK_CAP_MAX_LINK_WIDTH = 8,          
   parameter               REF_CLK_FREQ            = 0,          
   parameter               USER_CLK2_DIV2          = "FALSE",    
   parameter  integer      USER_CLK_FREQ           = 3,          
   parameter               PL_FAST_TRAIN           = "FALSE",    
   parameter               PCIE_EXT_CLK            = "FALSE",    
   parameter               PCIE_USE_MODE           = "1.0",      
   parameter               PCIE_GT_DEVICE          = "GTX",      
   parameter               PCIE_PLL_SEL            = "CPLL",     
   parameter               PCIE_ASYNC_EN           = "FALSE",    
   parameter               PCIE_TXBUF_EN           = "FALSE",    
   parameter               PCIE_EXT_GT_COMMON      = "FALSE", 
   parameter               EXT_CH_GT_DRP           = "FALSE",  
   parameter               TX_MARGIN_FULL_0        = 7'b1001111, 
   parameter               TX_MARGIN_FULL_1        = 7'b1001110, 
   parameter               TX_MARGIN_FULL_2        = 7'b1001101, 
   parameter               TX_MARGIN_FULL_3        = 7'b1001100, 
   parameter               TX_MARGIN_FULL_4        = 7'b1000011, 
   parameter               TX_MARGIN_LOW_0         = 7'b1000101, 
   parameter               TX_MARGIN_LOW_1         = 7'b1000110, 
   parameter               TX_MARGIN_LOW_2         = 7'b1000011, 
   parameter               TX_MARGIN_LOW_3         = 7'b1000010, 
   parameter               TX_MARGIN_LOW_4         = 7'b1000000,   
   parameter               PCIE_CHAN_BOND          = 0,
   parameter               TCQ                     = 1           
)
(
   input   wire                      sys_clk,
   input   wire                      sys_rst_n,
   input   wire                      pipe_clk,
   input   wire                      user_clk,
   input   wire                      clock_locked,
   input   wire [5:0]               pl_ltssm_state,
   input   wire                      all_phystatus_rst,
   output  reg                       reg_clock_locked,
   output  reg  [5:0]               pl_ltssm_state_q,
   output  reg                       phy_rdy_n_int,
   input   wire                      scan_clk,
   input   wire                      test_i,
   input   wire                      scan_rst_n
);

wire dft_clk;
wire dft_rst_n;
wire pipe_clk_int;

assign pipe_clk_int = pipe_clk;
assign dft_clk = test_i ? scan_clk : pipe_clk_int;
assign dft_rst_n = test_i ? scan_rst_n : sys_rst_n;

always @(posedge dft_clk or negedge dft_rst_n) begin
  if (!dft_rst_n)
    reg_clock_locked <= #TCQ 1'b0;
  else
    reg_clock_locked <= #TCQ clock_locked;
end

always @(posedge dft_clk or negedge dft_rst_n) begin
  if (!dft_rst_n)
    pl_ltssm_state_q <= #TCQ 6'b0;
  else
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;
end

always @(posedge dft_clk or negedge dft_rst_n) begin
  if (!dft_rst_n)
    phy_rdy_n_int <= #TCQ 1'b0;
  else
    phy_rdy_n_int <= #TCQ all_phystatus_rst;
end

endmodule