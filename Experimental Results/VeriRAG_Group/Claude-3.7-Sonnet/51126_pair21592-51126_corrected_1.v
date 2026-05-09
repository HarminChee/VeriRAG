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

  wire pipe_clk_int;
  wire pipe_clk_dft;
  
  assign pipe_clk_int = sys_clk;
  assign pipe_clk_dft = test_mode_i ? sys_clk : pipe_clk_int;
  assign pipe_clk = pipe_clk_dft;

  pcie_core_pipe_wrapper #
  (
    .LINK_CAP_MAX_LINK_WIDTH(LINK_CAP_MAX_LINK_WIDTH),
    .PIPE_PIPELINE_STAGES(0)
  ) pipe_wrapper_i (
    .PIPE_CLK                        ( sys_clk ),
    .PIPE_RESET_N                    ( sys_rst_n ),
    .PIPE_PCLK                       ( pipe_clk_dft ),
    .PIPE_RXUSRCLK                   ( PIPE_RXUSRCLK_IN ),
    .PIPE_RXOUTCLK                   ( PIPE_RXOUTCLK_IN ),
    .PIPE_DCLK                       ( PIPE_DCLK_IN ),
    .PIPE_USERCLK1                   ( PIPE_USERCLK1_IN ),
    .PIPE_USERCLK2                   ( PIPE_USERCLK2_IN ),
    .PIPE_OOBCLK                     ( PIPE_OOBCLK_IN ),
    .PIPE_MMCM_LOCK                  ( PIPE_MMCM_LOCK_IN ),
    
    .PIPE_TXOUTCLK                   ( PIPE_TXOUTCLK_OUT ),
    .PIPE_RXOUTCLK_OUT              ( PIPE_RXOUTCLK_OUT ),
    .PIPE_PCLK_SEL                  ( PIPE_PCLK_SEL_OUT ),
    .PIPE_GEN3                      ( PIPE_GEN3_OUT ),

    .PIPE_RX0_CHAR_IS_K             ( pipe_rx0_char_is_k ),
    .PIPE_RX0_DATA                  ( pipe_rx0_data ),
    .PIPE_RX0_VALID                 ( pipe_rx0_valid ),
    .PIPE_RX0_CHANISALIGNED         ( pipe_rx0_chanisaligned ),
    .PIPE_RX0_STATUS                ( pipe_rx0_status ),
    .PIPE_RX0_PHY_STATUS            ( pipe_rx0_phy_status ),
    .PIPE_RX0_ELEC_IDLE            ( pipe_rx0_elec_idle ),
    .PIPE_RX0_POLARITY             ( pipe_rx0_polarity ),
    .PIPE_TX0_COMPLIANCE           ( pipe_tx0_compliance ),
    .PIPE_TX0_CHAR_IS_K            ( pipe_tx0_char_is_k ),
    .PIPE_TX0_DATA                 ( pipe_tx0_data ),
    .PIPE_TX0_ELEC_IDLE           ( pipe_tx0_elec_idle ),
    .PIPE_TX0_POWERDOWN           ( pipe_tx0_powerdown ),

    .PCI_EXP_TXN                   ( pci_exp_txn ),
    .PCI_EXP_TXP                   ( pci_exp_txp ),
    .PCI_EXP_RXN                   ( pci_exp_rxn ),
    .PCI_EXP_RXP                   ( pci_exp_rxp ),

    .USER_CLK                      ( user_clk ),
    .USER_CLK2                     ( user_clk2 ),
    .PHY_RDY_N                     ( phy_rdy_n )
  );

endmodule