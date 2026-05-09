`timescale 1ns/1ns
module pcie_7x_v1_11_0_gt_top #
(
   parameter               LINK_CAP_MAX_LINK_WIDTH = 8,
   parameter               REF_CLK_FREQ = 0,           
   parameter               USER_CLK2_DIV2 = "FALSE",   
   parameter  integer      USER_CLK_FREQ = 3,          
   parameter               PL_FAST_TRAIN = "FALSE",    
   parameter               PCIE_EXT_CLK = "FALSE",     
   parameter               PCIE_USE_MODE = "1.0",      
   parameter               PCIE_GT_DEVICE = "GTX",     
   parameter               PCIE_PLL_SEL   = "CPLL",    
   parameter               PCIE_ASYNC_EN  = "FALSE",   
   parameter               PCIE_TXBUF_EN  = "FALSE",   
   parameter               PCIE_CHAN_BOND = 0
)
(
   input   wire                      test_i,
   input   wire [5:0]                pl_ltssm_state         ,
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,
   input   wire                      PIPE_PCLK_IN,
   input   wire                      PIPE_RXUSRCLK_IN,
   input   wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  PIPE_RXOUTCLK_IN,
   input   wire                      PIPE_DCLK_IN,
   input   wire                      PIPE_USERCLK1_IN,
   input   wire                      PIPE_USERCLK2_IN,
   input   wire                      PIPE_OOBCLK_IN,
   input   wire                      PIPE_MMCM_LOCK_IN,
   input   wire                      clock_locked,
   output  wire                      PIPE_TXOUTCLK_OUT,
   output  wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_RXOUTCLK_OUT,
   output  wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_PCLK_SEL_OUT,
   output  wire                      PIPE_GEN3_OUT,
   output  wire                      phy_rdy_n
);

parameter TCQ = 1;

wire pipe_clk_int;
wire dft_pipe_clk;
wire pipe_clk;
reg [5:0] pl_ltssm_state_q;
reg reg_clock_locked;
reg phy_rdy_n_int;
wire all_phystatus_rst;

assign dft_pipe_clk = test_i ? PIPE_PCLK_IN : pipe_clk_int;
assign pipe_clk = dft_pipe_clk;
assign phy_rdy_n = phy_rdy_n_int;

always @(posedge dft_pipe_clk or negedge clock_locked) begin
  if (!clock_locked)
    pl_ltssm_state_q <= #TCQ 6'b0;
  else 
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;
end

always @(posedge dft_pipe_clk or negedge clock_locked) begin
  if (!clock_locked)
    reg_clock_locked <= #TCQ 1'b0;
  else
    reg_clock_locked <= #TCQ 1'b1;
end

always @(posedge dft_pipe_clk) begin
  if (!reg_clock_locked)
    phy_rdy_n_int <= #TCQ 1'b0;
  else
    phy_rdy_n_int <= #TCQ all_phystatus_rst;
end

endmodule