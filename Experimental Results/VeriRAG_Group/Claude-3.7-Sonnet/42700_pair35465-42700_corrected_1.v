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
   input   wire                      pipe_clk_ext           ,
   input   wire                      PIPE_PCLK_IN,
   input   wire                      PIPE_RXUSRCLK_IN,
   input   wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  PIPE_RXOUTCLK_IN,
   input   wire                      PIPE_DCLK_IN,
   input   wire                      PIPE_USERCLK1_IN,
   input   wire                      PIPE_USERCLK2_IN,
   input   wire                      PIPE_OOBCLK_IN,
   input   wire                      PIPE_MMCM_LOCK_IN,
   input   wire                      test_mode,
   output  wire                      PIPE_TXOUTCLK_OUT,
   output  wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_RXOUTCLK_OUT,
   output  wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_PCLK_SEL_OUT,
   output  wire                      PIPE_GEN3_OUT,
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
   input   wire [ 1:0]               pipe_tx0_powerdown     
);

  parameter                          TCQ  = 1;      
  localparam                         USERCLK2_FREQ   =  (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ :
                                                        (USER_CLK_FREQ == 4) ? 3 :
                                                        (USER_CLK_FREQ == 3) ? 2 :
                                                         USER_CLK_FREQ;

  wire                               pipe_clk_int;
  wire                               pipe_clk_sel;
  reg                                phy_rdy_n_int;
  reg                                reg_clock_locked;

  wire                               pipe_clk_mux;
  assign pipe_clk_mux = test_mode ? pipe_clk_ext : pipe_clk_int;

  pcie_7x_v1_11_0_pipe_wrapper #
  (
    .LINK_CAP_MAX_LINK_WIDTH(LINK_CAP_MAX_LINK_WIDTH)
  ) pipe_wrapper_i (
    .PIPE_CLK                        ( pipe_clk_mux )
  );

endmodule