module pcie_7x_0_core_top_gt_top #
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
   input   wire                      test_i,
   input   wire                      clk_i,
   input   wire                      rst_n_i,
   input   wire [5:0]                pl_ltssm_state,
   input   wire                      pipe_tx_rcvr_det,
   input   wire                      pipe_tx_reset,
   input   wire                      pipe_tx_rate,
   input   wire                      pipe_tx_deemph,
   input   wire [2:0]                pipe_tx_margin,
   input   wire                      pipe_tx_swing,
   output  wire                      phy_rdy_n
);

reg [3:0] sel_cont;
reg aud_bck;
wire dft_aud_bck;

assign dft_aud_bck = test_i ? clk_i : aud_bck;

always @(posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i)
    aud_bck <= 1'b0;
  else
    aud_bck <= ~aud_bck;
end

always @(negedge dft_aud_bck or negedge rst_n_i) begin
  if (!rst_n_i)
    sel_cont <= 4'b0;
  else
    sel_cont <= sel_cont + 1'b1;
end

endmodule