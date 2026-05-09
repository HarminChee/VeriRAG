`timescale 1ns / 1ps
module pcie_7x_v1_3_pipe_wrapper #
(
    parameter PCIE_SIM_MODE                 = "FALSE",      // PCIe sim mode
    parameter PCIE_SIM_TX_EIDLE_DRIVE_LEVEL = "1",          // PCIe sim TX EIdle drive level
    parameter PCIE_GT_DEVICE                = "GTX",        // PCIe GT device
    parameter PCIE_USE_MODE                 = "1.1",        // PCIe use mode
    parameter PCIE_PLL_SEL                  = "CPLL",       // PCIe PLL select
    parameter PCIE_LPM_DFE                  = "LPM",        // PCIe LPM/DFE select
    parameter PCIE_EXT_CLK                  = "FALSE",      // PCIe external clock
    parameter PCIE_POWER_SAVING             = "TRUE",       // PCIe power saving
    parameter PCIE_ASYNC_EN                 = "FALSE",      // PCIe asynchronous enable
    parameter PCIE_TXBUF_EN                 = "FALSE",      // PCIe TX buffer enable
    parameter PCIE_RXBUF_EN                 = "TRUE",       // PCIe RX buffer enable
    parameter PCIE_TXSYNC_MODE              = 0,            // PCIe TX sync mode
    parameter PCIE_RXSYNC_MODE              = 0,            // PCIe RX sync mode
    parameter PCIE_CHAN_BOND                = 0,            // PCIe channel bonding
    parameter PCIE_CHAN_BOND_EN             = "TRUE",       // PCIe channel bonding enable
    parameter PCIE_LANE                     = 1,            // PCIe lane width
    parameter PCIE_LINK_SPEED               = 2,            // PCIe link speed
    parameter PCIE_REFCLK_FREQ              = 0,            // PCIe reference clock frequency
    parameter PCIE_USERCLK1_FREQ            = 2,            // PCIe user clock 1 frequency
    parameter PCIE_USERCLK2_FREQ            = 2,            // PCIe user clock 2 frequency
    parameter PCIE_DEBUG_MODE               = 0             // PCIe debug mode
)
(                                                           // Interface ports
    //--------------------------------------------------------------------------
    // Clock Interface
    //--------------------------------------------------------------------------
    input                           PIPE_CLK,               // PIPE clock input
    input                           PIPE_RESET_N,           // PIPE reset input (active low)
    output                          PIPE_PCLK,              // PIPE pclk output
    //--------------------------------------------------------------------------
    // TX Interface
    //--------------------------------------------------------------------------
    input       [(PCIE_LANE*32)-1:0]PIPE_TXDATA,            // PIPE TX data input
    input       [(PCIE_LANE*4)-1:0] PIPE_TXDATAK,           // PIPE TX data K input
    output      [PCIE_LANE-1:0]     PIPE_TXP,               // PIPE TX P output
    output      [PCIE_LANE-1:0]     PIPE_TXN,               // PIPE TX N output
    //--------------------------------------------------------------------------
    // RX Interface
    //--------------------------------------------------------------------------
    input       [PCIE_LANE-1:0]     PIPE_RXP,               // PIPE RX P input
    input       [PCIE_LANE-1:0]     PIPE_RXN,               // PIPE RX N input
    output      [(PCIE_LANE*32)-1:0]PIPE_RXDATA,            // PIPE RX data output
    output      [(PCIE_LANE*4)-1:0] PIPE_RXDATAK,           // PIPE RX data K output
    //--------------------------------------------------------------------------
    // PIPE Interface
    //--------------------------------------------------------------------------
    input                           PIPE_TXDETECTRX,        // PIPE TX detect RX input
    input       [PCIE_LANE-1:0]     PIPE_TXELECIDLE,        // PIPE TX electrical idle input
    input       [PCIE_LANE-1:0]     PIPE_TXCOMPLIANCE,      // PIPE TX compliance input
    input       [PCIE_LANE-1:0]     PIPE_RXPOLARITY,        // PIPE RX polarity input
    input       [(PCIE_LANE*2)-1:0] PIPE_POWERDOWN,         // PIPE power down input
    input       [ 1:0]              PIPE_RATE,              // PIPE rate input
    input       [ 2:0]              PIPE_TXMARGIN,          // PIPE TX margin input
    input                           PIPE_TXSWING,           // PIPE TX swing input
    input       [(PCIE_LANE*6)-1:0] PIPE_TXDEEMPH,          // PIPE TX de-emphasis input
    input       [(PCIE_LANE*2)-1:0] PIPE_TXEQ_CONTROL,      // PIPE TX equalization control input
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET,       // PIPE TX equalization preset input
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET_DEFAULT,// PIPE TX equalization preset default input
    input       [(PCIE_LANE*2)-1:0] PIPE_RXEQ_CONTROL,      // PIPE RX equalization control input
    input       [(PCIE_LANE*3)-1:0] PIPE_RXEQ_PRESET,       // PIPE RX equalization preset input
    input       [(PCIE_LANE*6)-1:0] PIPE_RXEQ_LFFS,         // PIPE RX equalization LFFS input
    input       [(PCIE_LANE*4)-1:0] PIPE_RXEQ_TXPRESET,     // PIPE RX equalization TX preset input
    output      [ 5:0]              PIPE_TXEQ_FS,           // PIPE TX equalization FS output
    output      [ 5:0]              PIPE_TXEQ_LF,           // PIPE TX equalization LF output
    output      [(PCIE_LANE*18)-1:0]PIPE_TXEQ_DEEMPH,       // PIPE TX equalization de-emphasis output
    output      [PCIE_LANE-1:0]     PIPE_TXEQ_DONE,         // PIPE TX equalization done output
    output      [(PCIE_LANE*18)-1:0]PIPE_RXEQ_NEW_TXCOEFF,  // PIPE RX equalization new TX coefficient output
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_LFFS_SEL,     // PIPE RX equalization LFFS select output
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_ADAPT_DONE,   // PIPE RX equalization adapt done output
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_DONE,         // PIPE RX equalization done output
    output      [PCIE_LANE-1:0]     PIPE_RXVALID,           // PIPE RX valid output
    output      [PCIE_LANE-1:0]     PIPE_PHYSTATUS,         // PIPE PHY status output
    output      [PCIE_LANE-1:0]     PIPE_PHYSTATUS_RST,     // PIPE PHY status reset output
    output      [PCIE_LANE-1:0]     PIPE_RXELECIDLE,        // PIPE RX electrical idle output
    output      [(PCIE_LANE*3)-1:0] PIPE_RXSTATUS,          // PIPE RX status output
    output      [(PCIE_LANE*3)-1:0] PIPE_RXBUFSTATUS,       // PIPE RX buffer status output
    input       [PCIE_LANE-1:0]     PIPE_RXSLIDE,           // PIPE RX slide input
    output      [PCIE_LANE-1:0]     PIPE_CPLL_LOCK,         // PIPE CPLL lock output
    output      [(PCIE_LANE-1)>>2:0]PIPE_QPLL_LOCK,         // PIPE QPLL lock output
    output                          PIPE_PCLK_LOCK,         // PIPE PCLK lock output
    output      [PCIE_LANE-1:0]     PIPE_RXCDRLOCK,         // PIPE RX CDR lock output
    //--------------------------------------------------------------------------
    // Clock Interface
    //--------------------------------------------------------------------------
    output                          PIPE_USERCLK1,          // PIPE user clock 1 output
    output                          PIPE_USERCLK2,          // PIPE user clock 2 output
    output                          PIPE_RXUSRCLK,          // PIPE RX user clock output
    output      [PCIE_LANE-1:0]     PIPE_RXOUTCLK,          // PIPE RX out clock output
    //--------------------------------------------------------------------------
    // Sync Interface
    //--------------------------------------------------------------------------
    output      [PCIE_LANE-1:0]     PIPE_TXSYNC_DONE,       // PIPE TX sync done output
    output      [PCIE_LANE-1:0]     PIPE_RXSYNC_DONE,       // PIPE RX sync done output
    output      [PCIE_LANE-1:0]     PIPE_GEN3_RDY,          // PIPE Gen3 ready output
    //--------------------------------------------------------------------------
    // Channel Bonding Interface
    //--------------------------------------------------------------------------
    output      [PCIE_LANE-1:0]     PIPE_RXCHANISALIGNED,   // PIPE RX channel is aligned output
    //--------------------------------------------------------------------------
    // Active Lane Interface
    //--------------------------------------------------------------------------
    output      [PCIE_LANE-1:0]     PIPE_ACTIVE_LANE,       // PIPE active lane output
    //--------------------------------------------------------------------------
    // External Clock Interface
    //--------------------------------------------------------------------------
    input                           PIPE_PCLK_IN,           // PIPE pclk input
    input                           PIPE_RXUSRCLK_IN,       // PIPE RX user clock input
    input       [PCIE_LANE-1:0]     PIPE_RXOUTCLK_IN,       // PIPE RX out clock input
    input                           PIPE_DCLK_IN,           // PIPE DCLK input
    input                           PIPE_USERCLK1_IN,       // PIPE user clock 1 input
    input                           PIPE_USERCLK2_IN,       // PIPE user clock 2 input
    input                           PIPE_MMCM_LOCK_IN,      // PIPE MMCM lock input
    output                          PIPE_TXOUTCLK_OUT,      // PIPE TX out clock output
    output      [PCIE_LANE-1:0]     PIPE_RXOUTCLK_OUT,      // PIPE RX out clock output
    output      [PCIE_LANE-1:0]     PIPE_PCLK_SEL_OUT,      // PIPE pclk select output
    output                          PIPE_GEN3_OUT,          // PIPE Gen3 output
    //--------------------------------------------------------------------------
    // PRBS Interface
    //--------------------------------------------------------------------------
    input       [ 2:0]              PIPE_TXPRBSSEL,         // PIPE TX PRBS select input
    input       [ 2:0]              PIPE_RXPRBSSEL,         // PIPE RX PRBS select input
    input                           PIPE_TXPRBSFORCEERR,    // PIPE TX PRBS force error input
    input                           PIPE_RXPRBSCNTRESET,    // PIPE RX PRBS counter reset input
    input       [ 2:0]              PIPE_LOOPBACK,          // PIPE loopback input
    output      [PCIE_LANE-1:0]     PIPE_RXPRBSERR,         // PIPE RX PRBS error output
    //--------------------------------------------------------------------------
    // Debug Interface
    //--------------------------------------------------------------------------
    output      [10:0]              PIPE_RST_FSM,           // PIPE reset FSM output
    output      [11:0]              PIPE_QRST_FSM,          // PIPE QPLL reset FSM output
    output      [(PCIE_LANE*24)-1:0]PIPE_RATE_FSM,          // PIPE rate FSM output
    output      [(PCIE_LANE*6)-1:0] PIPE_SYNC_FSM_TX,       // PIPE sync FSM TX output
    output      [(PCIE_LANE*7)-1:0] PIPE_SYNC_FSM_RX,       // PIPE sync FSM RX output
    output      [(PCIE_LANE*7)-1:0] PIPE_DRP_FSM,           // PIPE DRP FSM output
    output      [(PCIE_LANE*5)-1:0] PIPE_TXEQ_FSM,          // PIPE TX equalization FSM output
    output      [(PCIE_LANE*6)-1:0] PIPE_RXEQ_FSM,          // PIPE RX equalization FSM output
    output      [((((PCIE_LANE-1)>>2)+1)*7)-1:0]PIPE_QDRP_FSM, // PIPE QPLL DRP FSM output
    output                          PIPE_RST_IDLE,          // PIPE reset idle output
    output                          PIPE_QRST_IDLE,         // PIPE QPLL reset idle output
    output                          PIPE_RATE_IDLE,         // PIPE rate idle output
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_0,           // PIPE debug 0 output
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_1,           // PIPE debug 1 output
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_2,           // PIPE debug 2 output
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_3,           // PIPE debug 3 output
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_4,           // PIPE debug 4 output
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_5,           // PIPE debug 5 output
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_6,           // PIPE debug 6 output
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_7,           // PIPE debug 7 output
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_8,           // PIPE debug 8 output
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_9,           // PIPE debug 9 output
    output      [31:0]              PIPE_DEBUG,             // PIPE debug output
    output      [(PCIE_LANE*8)-1:0] PIPE_DMONITOROUT,       // PIPE D monitor output
    //--------------------------------------------------------------------------
    // DFT Interface
    //--------------------------------------------------------------------------
    input                           scan_clk,               // DFT Scan Clock Input
    input                           test_i                  // DFT Test Mode Input
);
    //--------------------------------------------------------------------------
    // Internal Signals
    //--------------------------------------------------------------------------
    reg                             reset_n_reg1;
    reg                             reset_n_reg2;
    wire                            clk_pclk;
    wire                            clk_rxusrclk;
    wire        [PCIE_LANE-1:0]     clk_rxoutclk;
    wire                            clk_dclk;               // Assuming this exists if PIPE_DCLK_IN is used
    wire                            clk_userclk1;           // Assuming this exists if PIPE_USERCLK1 is generated/used
    wire                            clk_userclk2;           // Assuming this exists if PIPE_USERCLK2 is generated/used
    wire                            clk_mmcm_lock;
    wire                            rst_cpllreset;
    wire                            rst_cpllpd;
    wire                            rst_rxusrclk_reset;
    wire                            rst_dclk_reset;
    wire                            rst_gtreset;
    wire                            rst_userrdy;
    wire                            rst_txsync_start;
    wire                            rst_idle;
    wire        [10:0]              rst_fsm;
    wire                            qrst_ovrd;
    wire                            qrst_drp_start;
    wire                            qrst_qpllreset;
    wire                            qrst_qpllpd;
    wire                            qrst_idle;
    wire        [11:0]              qrst_fsm;
    wire        [PCIE_LANE-1:0]     user_resetovrd;
    wire        [PCIE_LANE-1:0]     user_txpmareset;
    wire        [PCIE_LANE-1:0]     user_rxpmareset;
    wire        [PCIE_LANE-1:0]     user_rxcdrreset;
    wire        [PCIE_LANE-1:0]     user_rxcdrfreqreset;
    wire        [PCIE_LANE-1:0]     user_rxdfelpmreset;
    wire        [PCIE_LANE-1:0]     user_eyescanreset;
    wire        [PCIE_LANE-1:0]     user_txpcsreset;
    wire        [PCIE_LANE-1:0]     user_rxpcsreset;
    wire        [PCIE_LANE-1:0]     user_rxbufreset;
    wire        [PCIE_LANE-1:0]     user_resetovrd_done;
    wire        [PCIE_LANE-1:0]     user_active_lane;
    wire        [PCIE_LANE-1:0]     user_resetdone;
    wire        [PCIE_LANE-1:0]     user_rxcdrlock;
    wire        [PCIE_LANE-1:0]     rate_cpllpd;
    wire        [PCIE_LANE-1:0]     rate_qpllpd;
    wire        [PCIE_LANE-1:0]     rate_cpllreset;
    wire        [PCIE_LANE-1:0]     rate_qpllreset;
    wire        [PCIE_LANE-1:0]     rate_txpmareset;
    wire        [PCIE_LANE-1:0]     rate_rxpmareset;
    wire        [(PCIE_LANE*2)-1:0] rate_sysclksel;