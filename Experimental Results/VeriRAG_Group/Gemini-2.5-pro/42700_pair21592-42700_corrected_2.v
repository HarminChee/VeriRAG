`timescale 1ns/1ns
module pcie_7x_v1_11_0_gt_top #
(
   parameter               LINK_CAP_MAX_LINK_WIDTH = 8,
   parameter               REF_CLK_FREQ = 0, // 0=100 MHz, 1=125 MHz, 2=250 MHz
   parameter               USER_CLK2_DIV2 = "FALSE",
   parameter  integer      USER_CLK_FREQ = 3, // 0= 62.5 Mhz, 1=125 Mhz, 2=250 Mhz, 3=500 Mhz (Gen3 Only)
   parameter               PL_FAST_TRAIN = "FALSE",
   parameter               PCIE_EXT_CLK = "FALSE",
   parameter               PCIE_USE_MODE = "1.0", // 1.0 = 2.5 Gbps, 2.0 = 5.0 Gbps, 3.0 = 8.0 Gbps
   parameter               PCIE_GT_DEVICE = "GTX",
   parameter               PCIE_PLL_SEL   = "CPLL", // CPLL or QPLL
   parameter               PCIE_ASYNC_EN  = "FALSE", // TRUE enables PCIe async gearbox
   parameter               PCIE_TXBUF_EN  = "FALSE", // TRUE enables PCIe TX buffer
   parameter               PCIE_CHAN_BOND = 0 // Channel bonding mode (0=none)
)
(
   // Link Layer Interface
   input   wire [5:0]                pl_ltssm_state         ,

   // PIPE Interface TX Side (Inputs from MAC)
   input   wire                      pipe_tx_rcvr_det       , // Asynchronous from MAC
   input   wire                      pipe_tx_reset          , // Asynchronous from MAC
   input   wire                      pipe_tx_rate           , // Asynchronous from MAC
   input   wire                      pipe_tx_deemph         , // Asynchronous from MAC
   input   wire [2:0]                pipe_tx_margin         , // Asynchronous from MAC
   input   wire                      pipe_tx_swing          , // Asynchronous from MAC

   // PIPE Interface Clocks (Inputs from Clock Module)
   input   wire                      PIPE_PCLK_IN,          // Primary clock for PIPE iface (pclk)
   input   wire                      PIPE_RXUSRCLK_IN,      // RX user clock (rxusrclk)
   input   wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0]  PIPE_RXOUTCLK_IN,     // RX recovered clock (rxoutclk)
   input   wire                      PIPE_DCLK_IN,          // DRP clock (dclk)
   input   wire                      PIPE_USERCLK1_IN,      // User clock 1 (userclk1)
   input   wire                      PIPE_USERCLK2_IN,      // User clock 2 (userclk2)
   input   wire                      PIPE_OOBCLK_IN,        // OOB clock (oobclk)
   input   wire                      PIPE_MMCM_LOCK_IN,     // MMCM lock signal
   input   wire                      PIPE_MMCM_RST_N,       // MMCM reset

   // PIPE Interface Clocks (Outputs to Clock Module)
   output  wire                      PIPE_TXOUTCLK_OUT,     // TX clock output (txoutclk)
   output  wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_RXOUTCLK_OUT,    // RX recovered clock output (rxoutclk)
   output  wire [(LINK_CAP_MAX_LINK_WIDTH - 1) : 0] PIPE_PCLK_SEL_OUT,    // PCLK select output
   output  wire                      PIPE_GEN3_OUT,         // Gen3 speed indication output

   // PIPE Interface RX Side Per Lane (Outputs to MAC)
   output  wire [ 1:0]               pipe_rx0_char_is_k     ,
   output  wire [15:0]               pipe_rx0_data          ,
   output  wire                      pipe_rx0_valid         ,
   output  wire                      pipe_rx0_chanisaligned ,
   output  wire [ 2:0]               pipe_rx0_status        ,
   output  wire                      pipe_rx0_phy_status    ,
   output  wire                      pipe_rx0_elec_idle     ,
   output  wire [ 1:0]               pipe_rx1_char_is_k     ,
   output  wire [15:0]               pipe_rx1_data          ,
   output  wire                      pipe_rx1_valid         ,
   output  wire                      pipe_rx1_chanisaligned ,
   output  wire [ 2:0]               pipe_rx1_status        ,
   output  wire                      pipe_rx1_phy_status    ,
   output  wire                      pipe_rx1_elec_idle     ,
   output  wire [ 1:0]               pipe_rx2_char_is_k     ,
   output  wire [15:0]               pipe_rx2_data          ,
   output  wire                      pipe_rx2_valid         ,
   output  wire                      pipe_rx2_chanisaligned ,
   output  wire [ 2:0]               pipe_rx2_status        ,
   output  wire                      pipe_rx2_phy_status    ,
   output  wire                      pipe_rx2_elec_idle     ,
   output  wire [ 1:0]               pipe_rx3_char_is_k     ,
   output  wire [15:0]               pipe_rx3_data          ,
   output  wire                      pipe_rx3_valid         ,
   output  wire                      pipe_rx3_chanisaligned ,
   output  wire [ 2:0]               pipe_rx3_status        ,
   output  wire                      pipe_rx3_phy_status    ,
   output  wire                      pipe_rx3_elec_idle     ,
   output  wire [ 1:0]               pipe_rx4_char_is_k     ,
   output  wire [15:0]               pipe_rx4_data          ,
   output  wire                      pipe_rx4_valid         ,
   output  wire                      pipe_rx4_chanisaligned ,
   output  wire [ 2:0]               pipe_rx4_status        ,
   output  wire                      pipe_rx4_phy_status    ,
   output  wire                      pipe_rx4_elec_idle     ,
   output  wire [ 1:0]               pipe_rx5_char_is_k     ,
   output  wire [15:0]               pipe_rx5_data          ,
   output  wire                      pipe_rx5_valid         ,
   output  wire                      pipe_rx5_chanisaligned ,
   output  wire [ 2:0]               pipe_rx5_status        ,
   output  wire                      pipe_rx5_phy_status    ,
   output  wire                      pipe_rx5_elec_idle     ,
   output  wire [ 1:0]               pipe_rx6_char_is_k     ,
   output  wire [15:0]               pipe_rx6_data          ,
   output  wire                      pipe_rx6_valid         ,
   output  wire                      pipe_rx6_chanisaligned ,
   output  wire [ 2:0]               pipe_rx6_status        ,
   output  wire                      pipe_rx6_phy_status    ,
   output  wire                      pipe_rx6_elec_idle     ,
   output  wire [ 1:0]               pipe_rx7_char_is_k     ,
   output  wire [15:0]               pipe_rx7_data          ,
   output  wire                      pipe_rx7_valid         ,
   output  wire                      pipe_rx7_chanisaligned ,
   output  wire [ 2:0]               pipe_rx7_status        ,
   output  wire                      pipe_rx7_phy_status    ,
   output  wire                      pipe_rx7_elec_idle     ,

   // PIPE Interface TX Side Per Lane (Inputs from MAC)
   input   wire                      pipe_rx0_polarity      ,
   input   wire                      pipe_tx0_compliance    ,
   input   wire [ 1:0]               pipe_tx0_char_is_k     ,
   input   wire [15:0]               pipe_tx0_data          ,
   input   wire                      pipe_tx0_elec_idle     ,
   input   wire [ 1:0]               pipe_tx0_powerdown     ,
   input   wire                      pipe_rx1_polarity      ,
   input   wire                      pipe_tx1_compliance    ,
   input   wire [ 1:0]               pipe_tx1_char_is_k     ,
   input   wire [15:0]               pipe_tx1_data          ,
   input   wire                      pipe_tx1_elec_idle     ,
   input   wire [ 1:0]               pipe_tx1_powerdown     ,
   input   wire                      pipe_rx2_polarity      ,
   input   wire                      pipe_tx2_compliance    ,
   input   wire [ 1:0]               pipe_tx2_char_is_k     ,
   input   wire [15:0]               pipe_tx2_data          ,
   input   wire                      pipe_tx2_elec_idle     ,
   input   wire [ 1:0]               pipe_tx2_powerdown     ,
   input   wire                      pipe_rx3_polarity      ,
   input   wire                      pipe_tx3_compliance    ,
   input   wire [ 1:0]               pipe_tx3_char_is_k     ,
   input   wire [15:0]               pipe_tx3_data          ,
   input   wire                      pipe_tx3_elec_idle     ,
   input   wire [ 1:0]               pipe_tx3_powerdown     ,
   input   wire                      pipe_rx4_polarity      ,
   input   wire                      pipe_tx4_compliance    ,
   input   wire [ 1:0]               pipe_tx4_char_is_k     ,
   input   wire [15:0]               pipe_tx4_data          ,
   input   wire                      pipe_tx4_elec_idle     ,
   input   wire [ 1:0]               pipe_tx4_powerdown     ,
   input   wire                      pipe_rx5_polarity      ,
   input   wire                      pipe_tx5_compliance    ,
   input   wire [ 1:0]               pipe_tx5_char_is_k     ,
   input   wire [15:0]               pipe_tx5_data          ,
   input   wire                      pipe_tx5_elec_idle     ,
   input   wire [ 1:0]               pipe_tx5_powerdown     ,
   input   wire                      pipe_rx6_polarity      ,
   input   wire                      pipe_tx6_compliance    ,
   input   wire [ 1:0]               pipe_tx6_char_is_k     ,
   input   wire [15:0]               pipe_tx6_data          ,
   input   wire                      pipe_tx6_elec_idle     ,
   input   wire [ 1:0]               pipe_tx6_powerdown     ,
   input   wire                      pipe_rx7_polarity      ,
   input   wire                      pipe_tx7_compliance    ,
   input   wire [ 1:0]               pipe_tx7_char_is_k     ,
   input   wire [15:0]               pipe_tx7_data          ,
   input   wire                      pipe_tx7_elec_idle     ,
   input   wire [ 1:0]               pipe_tx7_powerdown     ,

   // Physical Layer Interface (GT Pins)
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txn            ,
   output  wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_txp            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxn            ,
   input   wire [ (LINK_CAP_MAX_LINK_WIDTH-1):0] pci_exp_rxp            ,

   // System Interface
   input   wire                      sys_clk                , // System clock (typically Reference clock)
   input   wire                      sys_rst_n              , // System reset (active low)

   // DRP Interface (Optional - not fully shown/connected in this snippet)
   input   wire [3:0]                i_tx_diff_ctr          , // Example DRP input (driving what?)

   // User Clocks Output
   output  wire                      pipe_clk               , // Main PIPE interface clock output (pclk)
   output  wire                      user_clk               , // User clock 1 output
   output  wire                      user_clk2              , // User clock 2 output

   // Debug/Status Outputs (Example: Lane 0)
   output  wire [15:0]               o_rx_data,
   output  wire [1:0]                o_rx_data_k,
   output  wire [1:0]                o_rx_byte_is_comma,   // Not driven in this code?
   output  wire                      o_rx_byte_is_aligned, // Not driven in this code?

   // PHY Ready Signal
   output  wire                      phy_rdy_n,             // PHY not ready (active low)

   // DFT Input
   input   wire                      test_i                 // Test mode input
);
  parameter                          TCQ  = 1;
  localparam                         USERCLK2_FREQ   =  (USER_CLK2_DIV2 == "FALSE") ? USER_CLK_FREQ :
                                                        (USER_CLK_FREQ == 4) ? 3 :
                                                        (USER_CLK_FREQ == 3) ? 2 :
                                                         USER_CLK_FREQ;
  localparam                         PCIE_LPM_DFE    = (PL_FAST_TRAIN == "TRUE") ? "DFE" : "LPM";
  localparam                         PCIE_LINK_SPEED = (PL_FAST_TRAIN == "TRUE") ? 2 : 3; // 1=2.5G, 2=5G, 3=8G
  localparam                         PCIE_OOBCLK_MODE_ENABLE =  1; // Enable OOBCLK mode
  localparam                         PCIE_TX_EIDLE_ASSERT_DELAY = (PL_FAST_TRAIN == "TRUE") ? 3'b100 : 3'b010; // Delay for TX Electrical Idle assertion

  // Internal wires connecting to pipe_wrapper RX side (outputs from wrapper)
  wire [(LINK_CAP_MAX_LINK_WIDTH-1) : 0] gt_rx_phy_status_wire        ;
  wire [(LINK_CAP_MAX_LINK_WIDTH-1) : 0] gt_rxchanisaligned_wire      ;
  wire [((2*LINK_CAP_MAX_LINK_WIDTH)-1):0] gt_rx_data_k_wire            ;
  wire [((16*LINK_CAP_MAX_LINK_WIDTH)-1):0] gt_rx_data_wire              ;
  wire [(LINK_CAP_MAX_LINK_WIDTH-1) : 0] gt_rx_elec_idle_wire         ;
  wire [((3*LINK_CAP_MAX_LINK_WIDTH)-1):0] gt_rx_status_wire            ;
  wire [(LINK_CAP_MAX_LINK_WIDTH-1) : 0] gt_rx_valid_wire             ;

  // Internal wires connecting to pipe_wrapper TX side (inputs to wrapper)
  wire [(LINK_CAP_MAX_LINK_WIDTH-1) : 0] gt_rx_polarity               ;
  wire [((2*LINK_CAP_MAX_LINK_WIDTH)-1):0] gt_power_down                ;
  wire [(LINK_CAP_MAX_LINK_WIDTH-1) : 0] gt_tx_compliance             ; // Aggregated compliance
  wire [((2*LINK_CAP_MAX_LINK_WIDTH)-1):0] gt_tx_data_k                 ;
  wire [((16*LINK_CAP_MAX_LINK_WIDTH)-1):0] gt_tx_data                   ;
  wire                               gt_tx_detect_rx_loopback = 1'b0 ; // Typically tied low
  wire [(LINK_CAP_MAX_LINK_WIDTH-1) : 0] gt_tx_elec_idle              ;

  // Internal wires for status and control
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] plllkdet                     ; // PLL lock detect from wrapper
  wire [LINK_CAP_MAX_LINK_WIDTH-1:0] phystatus_rst = {LINK_CAP_MAX_LINK_WIDTH{1'b0}}; // PHY status reset (tie low?)
  wire                               clock_locked                 ;
  reg                                phy_rdy_n_int;
  reg                                reg_clock_locked;

  // Internal wires for filtered RX data (output from filter)
  wire [(LINK_CAP_MAX_LINK_WIDTH-1) : 0] gt_rx_phy_status_wire_filter ;
  wire [((2*LINK_CAP_MAX_LINK_WIDTH)-1):0] gt_rx_data_k_wire_filter     ;
  wire [((16*LINK_CAP_MAX_LINK_WIDTH)-1):0] gt_rx_data_wire_filter       ;
  wire [(LINK_CAP_MAX_LINK_WIDTH-1