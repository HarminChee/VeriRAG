`timescale 1ns/1ns
module PCIeGen2x8If128_gt_top #(
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
) (
   input                              test_mode,
   input                              sys_clk,
   input                              pipe_clk_int,
   input                              clock_locked,
   input                              all_phystatus_rst,
   input   wire [5:0]                pl_ltssm_state         ,
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,
   output  wire                      phy_rdy_n
);

wire pipe_clk_dft;
reg reg_clock_locked;
reg phy_rdy_n_int;

assign pipe_clk_dft = test_mode ? sys_clk : pipe_clk_int;
assign phy_rdy_n = phy_rdy_n_int;

always @(posedge pipe_clk_dft or negedge clock_locked) begin
  if (!clock_locked)
    reg_clock_locked <= #TCQ 1'b0;
  else
    reg_clock_locked <= #TCQ 1'b1;
end

always @(posedge pipe_clk_dft) begin
  if (!reg_clock_locked)
    phy_rdy_n_int <= #TCQ 1'b0;
  else
    phy_rdy_n_int <= #TCQ all_phystatus_rst;
end

endmodule