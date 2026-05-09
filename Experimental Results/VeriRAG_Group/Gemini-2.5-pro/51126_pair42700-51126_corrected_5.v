`timescale 1ns/1ns
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
(input wire test_i,
   // Primary test mode input
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
   output  wire [ 1:0]               pipe_rx1_char_is_k     ,
   output  wire [15:0]               pipe_rx1_data          ,
   output  wire                      pipe_rx1_valid         ,
   output  wire                      pipe_rx1_chanisaligned ,
   output  wire [ 2:0]               pipe_rx1_status        ,
   output  wire                      pipe_rx1_phy_status    ,
   output  wire                      pipe_rx1_elec_idle     ,
   input   wire                      pipe_rx1_polarity      ,
   input   wire                      pipe_tx1_compliance    ,
   input   wire [ 1:0]               pipe_tx1_char_is_k     ,
   input   wire [15:0]               pipe_tx1_data          ,
   input   wire                      pipe_tx1_elec_idle     ,
   input   wire [ 1:0]               pipe_tx1_powerdown     ,
   output  wire [ 1:0]               pipe_rx2_char_is_k     ,
   output  wire [15:0]               pipe_rx2_data          ,
   output  wire                      pipe_rx2_valid         ,
   output  wire                      pipe_rx2_chanisaligned ,
   output  wire [ 2:0]               pipe_rx2_status        ,
   output  wire                      pipe_rx2_phy_status    ,
   output  wire                      pipe_rx2_elec_idle     ,
   input   wire                      pipe_rx2_polarity      ,
   input   wire                      pipe_tx2_compliance    ,
   input   wire [ 1:0]               pipe_tx2_char_is_k     ,
   input   wire [15:0]               pipe_tx2_data          ,
   input   wire                      pipe_tx2_elec_idle     ,
   input   wire [ 1:0]               pipe_tx2_powerdown     ,
   output  wire [ 1:0]               pipe_rx3_char_is_k     ,
   output  wire [15:0]               pipe_rx3_data          ,
   output  wire                      pipe_rx3_valid         ,
   output  wire                      pipe_rx3_chanisaligned ,
   output  wire [ 2:0]               pipe_rx3_status        ,
   output  wire                      pipe_rx3_phy_status    ,
   output  wire                      pipe_rx3_elec_idle     ,
   input   wire                      pipe_rx3_polarity      ,
   input   wire                      pipe_tx3_compliance    ,
   input   wire [ 1:0]               pipe_tx3_char_is_k     ,
   input   wire [15:0]               pipe_tx3_data          ,
   input   wire                      pipe_tx3_elec_idle     ,
   input   wire [ 1:0]               pipe_tx3_powerdown     ,
   output  wire [ 1:0]               pipe_rx4_char_is_k     ,
   output  wire [15:0]               pipe_rx4_data          ,
   output  wire                      pipe_rx4_valid         ,
   output  wire                      pipe_rx4_chanisaligned ,
   output  wire [ 2:0]               pipe_rx4_status        ,
   output  wire                      pipe_rx4_phy_status    ,
   output  wire                      pipe_rx4_elec_idle     ,
   input   wire                      pipe_rx4_polarity      ,
   input   wire                      pipe_tx4_compliance    ,
   input   wire [ 1:0]               pipe_tx4_char_is_k     ,
   input   wire [15:0]               pipe_tx4_data          ,
   input   wire                      pipe_tx4_elec_idle     ,
   input   wire [ 1:0]               pipe_tx4_powerdown     ,
   output  wire [ 1:0]               pipe_rx5_char_is_k     ,
   output  wire [15:0]               pipe_rx5_data          ,
   output  wire                      pipe_rx5_valid         ,
   output  wire                      pipe_rx5_chanisaligned ,
   output  wire [ 2:0]               pipe_rx5_status        ,
   output  wire                      pipe_rx5_phy_status    ,
   output  wire                      pipe_rx5_elec_idle     ,
   input   wire                      pipe_rx5_polarity      ,
   input   wire                      pipe_tx5_compliance    ,
   input   wire [ 1:0]               pipe_tx5_char_is_k     ,
   input   wire [15:0]               pipe_tx5_data          ,
   input   wire                      pipe_tx5_elec_idle     ,
   input   wire [ 1:0]               pipe_tx5_powerdown     ,
   output  wire [ 1:0]               pipe_rx6_char_is_k     ,
   output  wire [15:0]               pipe_rx6_data          ,
   output  wire                      pipe_rx6_valid         ,
   output  wire                      pipe_rx6_chanisaligned ,
   output  wire [ 2:0]               pipe_rx6_status        ,
   output  wire                      pipe_rx6_phy_status    ,
   output  wire                      pipe_rx6_elec_idle     ,
   input   wire                      pipe_rx6_polarity      ,
   input   wire                      pipe_tx6_compliance    ,
   input   wire [ 1:0]               pipe_tx6_char_is_k     ,
   input   wire [15:0]               pipe_tx6_data          ,
   input   wire                      pipe_tx6_elec_idle     ,
   input   wire [ 1:0]               pipe_tx6_powerdown     ,
   output  wire [ 1:0]               pipe_rx7_char_is_k     ,
   output  wire [15:0]               pipe_rx7_data          ,
   output  wire                      pipe_rx7_valid         ,
   output  wire                      pipe_rx7_chanisaligned ,
   output  wire [ 2:0]               pipe_rx7_status        ,
   output  wire                      pipe_rx7_phy_status    ,
   output  wire                      pipe_rx7_elec_idle     ,
   input   wire                      pipe_rx7_polarity      ,
   input   wire                      pipe_tx7_compliance    ,
   input   wire [ 1:0]               pipe_tx7_char_is_k     ,
   input   wire [15:0]               pipe_tx7_data          ,
   input   wire                      pipe_tx7_elec_idle     ,
   input   wire [ 1:0]               pipe_tx7_powerdown     ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn            ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp            ,
   input   wire                      sys_clk                , // Primary clock
   input   wire                      sys_rst_n              , // Primary reset (active low)
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
  parameter                          TCQ  = 1;
  localparam                         USERCLK2_FREQ   =  (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ :
                                                        (USER_CLK_FREQ == 4) ? 3 :
                                                        (USER_CLK_FREQ == 3) ? 2 :
                                                         USER_CLK_FREQ;
  localparam                         PCIE_LPM_DFE    = (PL_FAST_TRAIN == "TRUE") ? "DFE" : "LPM";
  localparam                         PCIE_LINK_SPEED = (PL_FAST_TRAIN == "TRUE") ? 2 : 3;
  localparam                         PCIE_OOBCLK_MODE_ENABLE =  1;
  localparam              PCIE_TX_EIDLE_ASSERT_DELAY = (PL_FAST_TRAIN == "TRUE") ? 3'b100 : 3'b010;
  wire [  7:0]                       gt_rx_phy_status_wire        ;
  wire [  7:0]                       gt_rxchanisaligned_wire      ;
  wire [ 31:0]                       gt_rx_data_k_wire            ;
  wire [255:0]                       gt_rx_data_wire              ;
  wire [  7:0]                       gt_rx_elec_idle_wire         ;
  wire [ 23:0]                       gt_rx_status_wire            ;
  wire [  7:0]                       gt_rx_valid_wire             ;
  wire [  7:0]                       gt_rx_polarity               ;
  wire [ 15:0]                       gt_power_down                ;
  wire [  7:0]                       gt_tx_char_disp_mode         ;
  wire [ 31:0]                       gt_tx_data_k                 ;
  wire [255:0]                       gt_tx_data                   ;
  wire                               gt_tx_detect_rx_loopback     ;
  wire [  7:0]                       gt_tx_elec_idle              ;
  wire [  7:0]                       gt_rx_elec_idle_reset        ;
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] plllkdet                     ;
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] phystatus_rst                ;
  wire                               clock_locked                 ; // Internal signal from pipe_wrapper
  wire [  7:0]                       gt_rx_phy_status_wire_filter ;
  wire [ 31:0]                       gt_rx_data_k_wire_filter     ;
  wire [255:0]                       gt_rx_data_wire_filter       ;
  wire [  7:0]                       gt_rx_elec_idle_wire_filter  ;
  wire [ 23:0]                       gt_rx_status_wire_filter     ;
  wire [  7:0]                       gt_rx_valid_wire_filter      ;
  wire                               pipe_clk_int; // Internal clock from pipe_wrapper
  reg                                phy_rdy_n_int;
  reg                                reg_clock_locked;
  wire                               all_phystatus_rst;

  // DFT signals
  wire                               dft_pipe_clk_int;
  wire                               sync_reset; // Active high synchronous reset

  reg [5:0] pl_ltssm_state_q;

  // DFT Muxes
  assign dft_pipe_clk_int = test_i ? sys_clk : pipe_clk_int; // Select primary clock in test mode
  assign sync_reset = test_i ? !sys_rst_n : !clock_locked; // Use primary reset (active high) in test mode, functional reset otherwise

  // pl_ltssm_state_q flop: Use DFT clock and synchronous reset
  // Original: always @(posedge pipe_clk_int or negedge clock_locked)
  always @(posedge dft_pipe_clk_int) begin
    if (sync_reset) // Use active high synchronous reset
      pl_ltssm_state_q <= #TCQ 6'b0;
    else
      pl_ltssm_state_q <= #TCQ pl_ltssm_state;
  end

  assign pipe_clk = pipe_clk_int ;

  wire                               plm_in_l0 = (pl_ltssm_state_q == 6'h16);
  wire                               plm_in_rl = (pl_ltssm_state_q == 6'h1c);
  wire                               plm_in_dt = (pl_ltssm_state_q == 6'h2d);
  wire                               plm_in_rs = (pl_ltssm_state_q == 6'h1f);

genvar i;
generate for (i=0; i<LINK_CAP_MAX_LINK_WIDTH; i=i+1)
 begin : gt_rx_valid_filter
   pcie_7x_v1_11_0_gt_rx_valid_filter_7x # (
     .CLK_COR_MIN_LAT(28)
   )
   GT_RX_VALID_FILTER_7x_inst (
     .USER_RXCHARISK   ( gt_rx_data_k_wire [(2*i)+1 + (2*i):(2*i)+ (2*i)] ),
     .USER_RXDATA      ( gt_rx_data_wire [(16*i)+15+(16*i) :(16*i)+0 + (16*i)] ),
     .USER_RXVALID     ( gt_rx_valid_wire [i] ),
     .USER_RXELECIDLE  ( gt_rx_elec_idle_wire [i] ),
     .USER_RX_STATUS   ( gt_rx_status_wire [(3*i)+2:(3*i)] ),
     .USER_RX_PHY_STATUS ( gt_rx_phy_status_wire [i] ),
     .GT_RXCHARISK     ( gt_rx_data_k_wire_filter [(2*i)+1+ (2*i):2*i+ (2*i)] ),
     .GT_RXDATA        ( gt_rx_data_wire_filter [(16*i)+15+(16*i) :(16*i)+0+(16*i)] ), // Corrected syntax
     .GT_RXVALID       ( gt_rx_valid_wire_filter [i] ),
     .GT_RXELECIDLE    ( gt_rx_elec_idle_wire_filter [i] ),
     .GT_RX_STATUS     ( gt_rx_status_wire_filter [(3*i)+2:(3*i)] ),
     .GT_RX_PHY_STATUS ( gt_rx_phy_status_wire_filter [i] ),
     .PLM_IN_L0        ( plm_in_l0 ),
     .PLM_IN_RS        ( plm_in_rs ),
     .USER_CLK         ( pipe_clk_int ), // Keep functional clock for internal logic
     .RESET            ( phy_rdy_n_int ) // Keep functional reset for internal logic if needed
   );
 end
endgenerate

  pcie_7x_v1_11_0_pipe_wrapper #
  (
    .PCIE_SIM_MODE                  ( PL_FAST_TRAIN ),
    .PCIE_SIM_SPEEDUP               ( "TRUE" ),
    .PCIE_EXT_CLK                   ( PCIE_EXT_CLK ),
    .PCIE_TXBUF_EN                  ( PCIE_TXBUF_EN ),
    .PCIE_ASYNC_EN                  ( PCIE_ASYNC_EN ),
    .PCIE_CHAN_BOND                 ( PCIE_CHAN_BOND ),
    .PCIE_PLL_SEL                   ( PCIE_PLL_SEL ),
    .PCIE_GT_DEVICE                 ( PCIE_GT_DEVICE ),
    .PCIE_USE_MODE                  ( PCIE_USE_MODE ),
    .PCIE_LANE                      ( LINK_CAP_MAX_LINK_WIDTH ),
    .PCIE_LPM_DFE                   ( PCIE_LPM_DFE ),
    .PCIE_LINK_SPEED                ( PCIE_LINK_SPEED ),
    .PCIE_TX_EIDLE_ASSERT_DELAY     ( PCIE_TX_EIDLE_ASSERT_DELAY ),
    .PCIE_OOBCLK_MODE               ( PCIE_OOBCLK_MODE_ENABLE ),
    .PCIE_REFCLK_FREQ               ( REF_CLK_FREQ ),
    .PCIE_USERCLK1_FREQ             ( USER_CLK_FREQ +1 ),
    .PCIE_USERCLK2_FREQ             ( USERCLK2_FREQ +1 )
  ) pipe_wrapper_i (
    .PIPE_CLK                        ( sys_clk ), // pipe_wrapper uses primary clock
    .PIPE_RESET_N                    ( sys_rst_n ), // pipe_wrapper uses primary reset
    .PIPE_PCLK                       ( pipe_clk_int ), // Output clock from pipe_wrapper
    .PIPE_TXDATA                    ( gt_tx_data[((32*LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_TXDATAK                   ( gt_tx_data_k[((4*LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_TXP                       ( pci_exp_txp[((LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_TXN                       ( pci_exp_txn[((LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXP                       ( pci_exp_rxp[((LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXN                       ( pci_exp_rxn[((LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXDATA                    ( gt_rx_data_wire_filter[((32*LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXDATAK                   ( gt_rx_data_k_wire_filter[((4*LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_TXDETECTRX                ( gt_tx_detect_rx_loopback ),
    .PIPE_TXELECIDLE                ( gt_tx_elec_idle[((LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_TXCOMPLIANCE              ( gt_tx_char_disp_mode[((LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXPOLARITY                ( gt_rx_polarity[((LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_POWERDOWN                 ( gt_power_down[((2*LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RATE                      ( {1'b0,pipe_tx_rate} ),
    .PIPE_TXMARGIN                  ( pipe_tx_margin[2:0] ),
    .PIPE_TXSWING                   ( pipe_tx_swing ),
    .PIPE_TXDEEMPH                  ( {(LINK_CAP_MAX_LINK_WIDTH){pipe_tx_deemph}} ),
    .PIPE_TXEQ_CONTROL              ( {2*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_TXEQ_PRESET               ( {4*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_TXEQ_PRESET_DEFAULT       ( {4*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_RXEQ_CONTROL              ( {2*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_RXEQ_PRESET               ( {3*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_RXEQ_LFFS                 ( {6*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_RXEQ_TXPRESET             ( {4*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_RXEQ_USER_EN              ( {1*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_RXEQ_USER_TXCOEFF         ( {18*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_RXEQ_USER_MODE            ( {1*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_TXEQ_COEFF                ( ),
    .PIPE_TXEQ_DEEMPH               ( {6*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_TXEQ_FS                   ( ),
    .PIPE_TXEQ_LF                   ( ),
    .PIPE_TXEQ_DONE                 ( ),
    .PIPE_RXEQ_NEW_TXCOEFF          ( ),
    .PIPE_RXEQ_LFFS_SEL             ( ),
    .PIPE_RXEQ_ADAPT_DONE           ( ),
    .PIPE_RXEQ_DONE                 ( ),
    .PIPE_RXVALID                   ( gt_rx_valid_wire_filter[((LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_PHYSTATUS                 ( gt_rx_phy_status_wire_filter[((LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_PHYSTATUS_RST             ( phystatus_rst ),
    .PIPE_RXELECIDLE                ( gt_rx_elec_idle_wire_filter[((LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXSTATUS                  ( gt_rx_status_wire_filter[((3*LINK_CAP_MAX_LINK_WIDTH)-1):0] ),
    .PIPE_RXBUFSTATUS               ( ),
    .PIPE_MMCM_RST_N                ( PIPE_MMCM_RST_N ),
    .PIPE_RXSLIDE                   ( {1*LINK_CAP_MAX_LINK_WIDTH{1'b0}} ),
    .PIPE_CPLL_LOCK                 ( plllkdet ),
    .PIPE_QPLL_LOCK                 ( ),
    .PIPE_PCLK_LOCK                 ( clock_locked ), // Output lock signal from pipe_wrapper
    .PIPE_RXCDRLOCK                 ( ),
    .PIPE_USERCLK1                  ( user_clk ),
    .PIPE_USERCLK2                  ( user_clk2 ),
    .PIPE_RXUSRCLK                  ( ),
    .PIPE_RXOUTCLK                  ( ),
    .PIPE_TXSYNC_DONE               ( ),
    .PIPE_RXSYNC_DONE               ( ),
    .