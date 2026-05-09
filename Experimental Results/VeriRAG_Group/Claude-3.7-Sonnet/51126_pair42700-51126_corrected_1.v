`timescale 1ns/1ns
module pcie_core_gt_top #
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
   input   wire                      test_clk,
   input   wire                      scan_rst_n,
   input   wire [5:0]                pl_ltssm_state         ,
   input   wire                      pipe_tx_rcvr_det       ,
   input   wire                      pipe_tx_reset          ,
   input   wire                      pipe_tx_rate           ,
   input   wire                      pipe_tx_deemph         ,
   input   wire [2:0]                pipe_tx_margin         ,
   input   wire                      pipe_tx_swing          ,
   input                                      PIPE_PCLK_IN,
   input                                      PIPE_RXUSRCLK_IN,
   input [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  PIPE_RXOUTCLK_IN,
   input                                      PIPE_DCLK_IN,
   input                                      PIPE_USERCLK1_IN,
   input                                      PIPE_USERCLK2_IN,
   input                                      PIPE_OOBCLK_IN,
   input                                      PIPE_MMCM_LOCK_IN,
   output                                     PIPE_TXOUTCLK_OUT,
   output [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_RXOUTCLK_OUT,
   output [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_PCLK_SEL_OUT,
   output                                     PIPE_GEN3_OUT,
   output  wire [ 1:0]               pipe_rx0_char_is_k     ,
   output  wire [15:0]               pipe_rx0_data          ,
   output  wire                      pipe_rx0_valid         ,
   output  wire                      pipe_rx0_chanisaligned ,
   output  wire [ 2:0]               pipe_rx0_status        ,
   output  wire                      pipe_rx0_phy_status    ,
   output  wire                      pipe_rx0_elec_idle     ,
   input   wire                      pipe_rx0_polarity      ,
   input   wire                      pipe_tx0_compliance    ,
   input   wire [ 1:0]               pipe_tx0_char_is_k     ,
   input   wire [15:0]               pipe_tx0_data          ,
   input   wire                      pipe_tx0_elec_idle     ,
   input   wire [ 1:0]               pipe_tx0_powerdown     ,
   input   wire                      sys_clk                ,
   input   wire                      sys_rst_n              ,
   input   wire                      PIPE_MMCM_RST_N        ,
   output  wire                      pipe_clk               ,
   output  wire                      user_clk               ,
   output  wire                      user_clk2              ,
   output  wire                      phy_rdy_n
);

parameter TCQ = 1;

wire pipe_clk_int;
wire clock_locked;
wire all_phystatus_rst;
reg [5:0] pl_ltssm_state_q;
reg reg_clock_locked;
reg phy_rdy_n_int;

wire dft_pipe_clk_int;
wire dft_clock_locked;

assign dft_pipe_clk_int = (test_clk == 1'b1) ? test_clk : pipe_clk_int;
assign dft_clock_locked = (test_clk == 1'b1) ? scan_rst_n : clock_locked;

always @(posedge dft_pipe_clk_int or negedge dft_clock_locked) begin
  if (!dft_clock_locked)
    pl_ltssm_state_q <= #TCQ 6'b0;
  else 
    pl_ltssm_state_q <= #TCQ pl_ltssm_state;
end

always @(posedge dft_pipe_clk_int or negedge dft_clock_locked) begin
  if (!dft_clock_locked)
    reg_clock_locked <= #TCQ 1'b0;
  else
    reg_clock_locked <= #TCQ 1'b1;
end

always @(posedge dft_pipe_clk_int) begin
  if (!reg_clock_locked)
    phy_rdy_n_int <= #TCQ 1'b0;
  else
    phy_rdy_n_int <= #TCQ all_phystatus_rst;
end

assign pipe_clk = pipe_clk_int;
assign phy_rdy_n = phy_rdy_n_int;

endmodule