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
   input   wire [5:0]                pl_ltssm_state         ,
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,
   input                             test_mode_i            ,
   input                             PIPE_PCLK_IN,
   input                             PIPE_RXUSRCLK_IN,
   input [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  PIPE_RXOUTCLK_IN,
   input                             PIPE_DCLK_IN,
   input                             PIPE_USERCLK1_IN,
   input                             PIPE_USERCLK2_IN,
   input                             PIPE_OOBCLK_IN,
   input                             PIPE_MMCM_LOCK_IN,
   output                            PIPE_TXOUTCLK_OUT,
   output [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_RXOUTCLK_OUT,
   output [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_PCLK_SEL_OUT,
   output                            PIPE_GEN3_OUT,
   input   wire                      sys_clk                ,
   input   wire                      sys_rst_n              ,
   input   wire                      PIPE_MMCM_RST_N        ,
   input        [3:0]                i_tx_diff_ctr          ,
   output  wire                      pipe_clk               ,
   output  wire                      user_clk               ,
   output  wire                      user_clk2              ,
   output       [15:0]               o_rx_data,
   output       [1:0]                o_rx_data_k,
   output       [1:0]                o_rx_byte_is_comma,
   output                            o_rx_byte_is_aligned,
   output  wire                      phy_rdy_n
);

wire pipe_clk_int;
wire pipe_clk_dft;
wire sys_rst_n_dft;
reg reg_clock_locked;
reg phy_rdy_n_int;
wire clock_locked;
wire all_phystatus_rst;
parameter TCQ = 1;

assign pipe_clk = pipe_clk_int;
assign pipe_clk_dft = test_mode_i ? PIPE_PCLK_IN : pipe_clk_int;
assign sys_rst_n_dft = test_mode_i ? PIPE_MMCM_RST_N : sys_rst_n;

pcie_7x_v1_11_0_pipe_wrapper #
(
  .LINK_CAP_MAX_LINK_WIDTH(LINK_CAP_MAX_LINK_WIDTH),
  .REF_CLK_FREQ(REF_CLK_FREQ),
  .USER_CLK2_DIV2(USER_CLK2_DIV2),
  .USER_CLK_FREQ(USER_CLK_FREQ),
  .PL_FAST_TRAIN(PL_FAST_TRAIN),
  .PCIE_EXT_CLK(PCIE_EXT_CLK),
  .PCIE_USE_MODE(PCIE_USE_MODE),
  .PCIE_GT_DEVICE(PCIE_GT_DEVICE),
  .PCIE_PLL_SEL(PCIE_PLL_SEL),
  .PCIE_ASYNC_EN(PCIE_ASYNC_EN),
  .PCIE_TXBUF_EN(PCIE_TXBUF_EN),
  .PCIE_CHAN_BOND(PCIE_CHAN_BOND)
) pipe_wrapper_i (
  .PIPE_CLK                        ( PIPE_PCLK_IN ),
  .PIPE_RESET_N                    ( sys_rst_n_dft ),
  .PIPE_PCLK                       ( pipe_clk_dft )
);

always @(posedge PIPE_PCLK_IN or negedge PIPE_MMCM_RST_N) begin
  if (!PIPE_MMCM_RST_N)
    reg_clock_locked <= #TCQ 1'b0;
  else 
    reg_clock_locked <= #TCQ clock_locked;
end

always @(posedge PIPE_PCLK_IN or negedge PIPE_MMCM_RST_N) begin
  if (!PIPE_MMCM_RST_N)
    phy_rdy_n_int <= #TCQ 1'b0;
  else
    phy_rdy_n_int <= #TCQ all_phystatus_rst;
end

endmodule