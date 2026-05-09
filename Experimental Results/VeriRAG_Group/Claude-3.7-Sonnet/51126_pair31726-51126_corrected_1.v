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
   input                                      test_mode_i,
   input                                      test_clk_i,

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

   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn            ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp            ,

   input   wire                      sys_clk                ,
   input   wire                      sys_rst_n              ,
   input   wire                      PIPE_MMCM_RST_N        ,

   output  wire                      pipe_clk               ,
   output  wire                      user_clk               ,
   output  wire                      user_clk2              ,

   output  wire                      phy_rdy_n
);

  parameter                          TCQ  = 1;      

  wire pipe_clk_int;
  wire dft_pipe_clk;
  assign dft_pipe_clk = test_mode_i ? test_clk_i : pipe_clk_int;

  pcie_core_pipe_wrapper #
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

    .PIPE_CLK                        ( test_clk_i ),
    .PIPE_RESET_N                    ( sys_rst_n ),
    .PIPE_PCLK                       ( dft_pipe_clk ),

    .pl_ltssm_state                  ( pl_ltssm_state ),
    .pipe_tx_rcvr_det               ( pipe_tx_rcvr_det ),
    .pipe_tx_reset                  ( pipe_tx_reset ),
    .pipe_tx_rate                   ( pipe_tx_rate ),
    .pipe_tx_deemph                 ( pipe_tx_deemph ),
    .pipe_tx_margin                 ( pipe_tx_margin ),
    .pipe_tx_swing                  ( pipe_tx_swing ),

    .PIPE_PCLK_IN                   ( PIPE_PCLK_IN ),
    .PIPE_RXUSRCLK_IN              ( PIPE_RXUSRCLK_IN ),
    .PIPE_RXOUTCLK_IN              ( PIPE_RXOUTCLK_IN ),
    .PIPE_DCLK_IN                  ( PIPE_DCLK_IN ),
    .PIPE_USERCLK1_IN              ( PIPE_USERCLK1_IN ),
    .PIPE_USERCLK2_IN              ( PIPE_USERCLK2_IN ),
    .PIPE_OOBCLK_IN                ( PIPE_OOBCLK_IN ),
    .PIPE_MMCM_LOCK_IN             ( PIPE_MMCM_LOCK_IN ),

    .PIPE_TXOUTCLK_OUT             ( PIPE_TXOUTCLK_OUT ),
    .PIPE_RXOUTCLK_OUT             ( PIPE_RXOUTCLK_OUT ),
    .PIPE_PCLK_SEL_OUT             ( PIPE_PCLK_SEL_OUT ),
    .PIPE_GEN3_OUT                 ( PIPE_GEN3_OUT ),

    .pipe_rx0_char_is_k            ( pipe_rx0_char_is_k ),
    .pipe_rx0_data                 ( pipe_rx0_data ),
    .pipe_rx0_valid                ( pipe_rx0_valid ),
    .pipe_rx0_chanisaligned        ( pipe_rx0_chanisaligned ),
    .pipe_rx0_status               ( pipe_rx0_status ),
    .pipe_rx0_phy_status          ( pipe_rx0_phy_status ),
    .pipe_rx0_elec_idle           ( pipe_rx0_elec_idle ),
    .pipe_rx0_polarity            ( pipe_rx0_polarity ),
    .pipe_tx0_compliance          ( pipe_tx0_compliance ),
    .pipe_tx0_char_is_k           ( pipe_tx0_char_is_k ),
    .pipe_tx0_data                ( pipe_tx0_data ),
    .pipe_tx0_elec_idle          ( pipe_tx0_elec_idle ),
    .pipe_tx0_powerdown          ( pipe_tx0_powerdown ),

    .pci_exp_txn                  ( pci_exp_txn ),
    .pci_exp_txp                  ( pci_exp_txp ),
    .pci_exp_rxn                  ( pci_exp_rxn ),
    .pci_exp_rxp                  ( pci_exp_rxp ),

    .pipe_clk                     ( pipe_clk ),
    .user_clk                     ( user_clk ),
    .user_clk2                    ( user_clk2 ),
    .phy_rdy_n                    ( phy_rdy_n )
  );

endmodule