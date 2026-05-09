`timescale 1ns / 1ps
module pcie_7x_v1_11_0_pipe_wrapper #
(
    parameter PCIE_SIM_MODE                 = "FALSE",      // Simulation Speedup Mode
    parameter PCIE_SIM_SPEEDUP              = "FALSE",      // Simulation Speedup Mode
    parameter PCIE_SIM_TX_EIDLE_DRIVE_LEVEL = "1",          // TX Electrical Idle Drive Level
    parameter PCIE_GT_DEVICE                = "GTX",        // GT Device Type GTX, GTH
    parameter PCIE_USE_MODE                 = "3.0",        // Mode Select 1.0=GEN1=2.5G, 2.0=GEN2=5.0G, 3.0=GEN3=8.0G
    parameter PCIE_PLL_SEL                  = "CPLL",       // PLL Select CPLL, QPLL
    parameter PCIE_AUX_CDR_GEN3_EN          = "TRUE",       // Aux CDR Enable for GEN3
    parameter PCIE_LPM_DFE                  = "LPM",        // RX Equalization LPM, DFE
    parameter PCIE_LPM_DFE_GEN3             = "DFE",        // RX Equalization for GEN3 LPM, DFE
    parameter PCIE_EXT_CLK                  = "FALSE",      // External Clocking Mode
    parameter PCIE_POWER_SAVING             = "TRUE",       // Power Saving Mode Enable
    parameter PCIE_ASYNC_EN                 = "FALSE",      // Async Gearbox Enable
    parameter PCIE_TXBUF_EN                 = "FALSE",      // TX Buffer Enable
    parameter PCIE_RXBUF_EN                 = "TRUE",       // RX Buffer Enable
    parameter PCIE_TXSYNC_MODE              = 0,            // TX Sync Mode 0=Use Sync Master, 1=Independent Lane Sync
    parameter PCIE_RXSYNC_MODE              = 0,            // RX Sync Mode 0=Use Sync Master, 1=Independent Lane Sync
    parameter PCIE_CHAN_BOND                = 1,            // Channel Bonding Mode 0=Slave, 1=Master Tx/Rx Ind, 2=Master Tx/Rx Dep
    parameter PCIE_CHAN_BOND_EN             = "TRUE",       // Channel Bonding Enable
    parameter PCIE_LANE                     = 1,            // Number of Lanes 1, 2, 4, 8
    parameter PCIE_LINK_SPEED               = 3,            // Link Speed Mode 1=2.5G, 2=5.0G, 3=8.0G
    parameter PCIE_REFCLK_FREQ              = 0,            // Reference Clock Frequency 0=100MHz, 1=125MHz, 2=250MHz
    parameter PCIE_USERCLK1_FREQ            = 2,            // USERCLK1 Frequency 0=31.25MHz, 1=62.5MHz, 2=125MHz, 3=250MHz, 4=500MHz
    parameter PCIE_USERCLK2_FREQ            = 2,            // USERCLK2 Frequency 0=31.25MHz, 1=62.5MHz, 2=125MHz, 3=250MHz, 4=500MHz
    parameter PCIE_TX_EIDLE_ASSERT_DELAY    = 3'd4,         // TX Eidle Assert Delay 0-7
    parameter PCIE_RXEQ_MODE_GEN3           = 1,            // RX Equalization Mode for GEN3 0=Auto, 1=Manual
    parameter PCIE_OOBCLK_MODE              = 1,            // OOBCLK Mode 0=Use OOBCLK from GT, 1=Use OOBCLK from USER
    parameter PCIE_JTAG_MODE                = 0,            // JTAG Mode 0=Disable, 1=Enable
    parameter PCIE_DEBUG_MODE               = 0             // Debug Mode 0=Disable, 1=Enable
)
(
    //--------------------------------------------------------------------------
    // PIPE Interface
    //--------------------------------------------------------------------------
    // Clocking Interface
    input                           PIPE_CLK,               // Reference Clock 100/125/250MHz
    input                           PIPE_RESET_N,           // PIPE Reset Active Low Asynchronous
    output                          PIPE_PCLK,              // PIPE Clock from GT
    // TX Interface
    input       [(PCIE_LANE*32)-1:0]PIPE_TXDATA,            // TX Data
    input       [(PCIE_LANE*4)-1:0] PIPE_TXDATAK,           // TX Data K Character Indicator
    output      [PCIE_LANE-1:0]     PIPE_TXP,               // TX Differential Data Positive
    output      [PCIE_LANE-1:0]     PIPE_TXN,               // TX Differential Data Negative
    // RX Interface
    input       [PCIE_LANE-1:0]     PIPE_RXP,               // RX Differential Data Positive
    input       [PCIE_LANE-1:0]     PIPE_RXN,               // RX Differential Data Negative
    output      [(PCIE_LANE*32)-1:0]PIPE_RXDATA,            // RX Data
    output      [(PCIE_LANE*4)-1:0] PIPE_RXDATAK,           // RX Data K Character Indicator
    // TX Control Interface
    input                           PIPE_TXDETECTRX,        // TX Receiver Detection Request
    input       [PCIE_LANE-1:0]     PIPE_TXELECIDLE,        // TX Electrical Idle Request
    input       [PCIE_LANE-1:0]     PIPE_TXCOMPLIANCE,      // TX Compliance Pattern Request
    input       [PCIE_LANE-1:0]     PIPE_RXPOLARITY,        // RX Polarity Inversion Request
    input       [(PCIE_LANE*2)-1:0] PIPE_POWERDOWN,         // Power Down Request
    input       [ 1:0]              PIPE_RATE,              // Rate Change Request
    input       [ 2:0]              PIPE_TXMARGIN,          // TX Margin Control
    input                           PIPE_TXSWING,           // TX Swing Control
    input       [PCIE_LANE-1:0]     PIPE_TXDEEMPH,          // TX Deemphasis Control
    // TX EQ Interface
    input       [(PCIE_LANE*2)-1:0] PIPE_TXEQ_CONTROL,      // TX Equalization Control
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET,       // TX Equalization Preset
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET_DEFAULT,// TX Equalization Preset Default
    input       [(PCIE_LANE*6)-1:0] PIPE_TXEQ_DEEMPH,       // TX Equalization Deemphasis
    // RX EQ Interface
    input       [(PCIE_LANE*2)-1:0] PIPE_RXEQ_CONTROL,      // RX Equalization Control
    input       [(PCIE_LANE*3)-1:0] PIPE_RXEQ_PRESET,       // RX Equalization Preset
    input       [(PCIE_LANE*6)-1:0] PIPE_RXEQ_LFFS,         // RX Equalization LFFS
    input       [(PCIE_LANE*4)-1:0] PIPE_RXEQ_TXPRESET,     // RX Equalization TX Preset
    input       [PCIE_LANE-1:0]     PIPE_RXEQ_USER_EN,      // RX Equalization User Enable
    input       [(PCIE_LANE*18)-1:0]PIPE_RXEQ_USER_TXCOEFF, // RX Equalization User TX Coefficient
    input       [PCIE_LANE-1:0]     PIPE_RXEQ_USER_MODE,    // RX Equalization User Mode
    // TX EQ Status Interface
    output      [ 5:0]              PIPE_TXEQ_FS,           // TX Equalization Full Scale Coefficient
    output      [ 5:0]              PIPE_TXEQ_LF,           // TX Equalization Low Frequency Coefficient
    output      [(PCIE_LANE*18)-1:0]PIPE_TXEQ_COEFF,        // TX Equalization Coefficient
    output      [PCIE_LANE-1:0]     PIPE_TXEQ_DONE,         // TX Equalization Done
    // RX EQ Status Interface
    output      [(PCIE_LANE*18)-1:0]PIPE_RXEQ_NEW_TXCOEFF,  // RX Equalization New TX Coefficient
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_LFFS_SEL,     // RX Equalization LFFS Select
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_ADAPT_DONE,   // RX Equalization Adapt Done
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_DONE,         // RX Equalization Done
    // RX Status Interface
    output      [PCIE_LANE-1:0]     PIPE_RXVALID,           // RX Data Valid Indicator
    output      [PCIE_LANE-1:0]     PIPE_PHYSTATUS,         // PHY Status Indicator
    output      [PCIE_LANE-1:0]     PIPE_PHYSTATUS_RST,     // PHY Status Reset
    output      [PCIE_LANE-1:0]     PIPE_RXELECIDLE,        // RX Electrical Idle Indicator
    output      [(PCIE_LANE*3)-1:0] PIPE_RXSTATUS,          // RX Status Indicator
    output      [(PCIE_LANE*3)-1:0] PIPE_RXBUFSTATUS,       // RX Buffer Status Indicator
    // Reset Interface
    input                           PIPE_MMCM_RST_N,        // MMCM Reset Active Low Asynchronous
    // RX Control Interface
    input       [PCIE_LANE-1:0]     PIPE_RXSLIDE,           // RX Slide Request
    // PLL Interface
    output      [PCIE_LANE-1:0]     PIPE_CPLL_LOCK,         // CPLL Lock Indicator
    output      [(PCIE_LANE-1)>>2:0]PIPE_QPLL_LOCK,         // QPLL Lock Indicator
    // Clocking Status Interface
    output                          PIPE_PCLK_LOCK,         // PCLK Lock Indicator
    output      [PCIE_LANE-1:0]     PIPE_RXCDRLOCK,         // RX CDR Lock Indicator
    // User Clock Interface
    output                          PIPE_USERCLK1,          // User Clock 1
    output                          PIPE_USERCLK2,          // User Clock 2
    output                          PIPE_RXUSRCLK,          // RX User Clock
    output      [PCIE_LANE-1:0]     PIPE_RXOUTCLK,          // RX Output Clock from GT
    // Sync Interface
    output      [PCIE_LANE-1:0]     PIPE_TXSYNC_DONE,       // TX Sync Done
    output      [PCIE_LANE-1:0]     PIPE_RXSYNC_DONE,       // RX Sync Done
    output      [PCIE_LANE-1:0]     PIPE_GEN3_RDY,          // GEN3 Ready
    // Channel Bonding Interface
    output      [PCIE_LANE-1:0]     PIPE_RXCHANISALIGNED,
    // Active Lane Interface
    output      [PCIE_LANE-1:0]     PIPE_ACTIVE_LANE,
    //--------------------------------------------------------------------------
    // External Clocking Interface
    //--------------------------------------------------------------------------
    input                           PIPE_PCLK_IN,           // PCLK Input
    input                           PIPE_RXUSRCLK_IN,       // RXUSRCLK Input
    input       [PCIE_LANE-1:0]     PIPE_RXOUTCLK_IN,       // RXOUTCLK Input
    input                           PIPE_DCLK_IN,           // DCLK Input
    input                           PIPE_USERCLK1_IN,       // USERCLK1 Input
    input                           PIPE_USERCLK2_IN,       // USERCLK2 Input
    input                           PIPE_OOBCLK_IN,         // OOBCLK Input
    input                           PIPE_MMCM_LOCK_IN,      // MMCM Lock Input
    output                          PIPE_TXOUTCLK_OUT,      // TXOUTCLK Output
    output      [PCIE_LANE-1:0]     PIPE_RXOUTCLK_OUT,      // RXOUTCLK Output
    output      [PCIE_LANE-1:0]     PIPE_PCLK_SEL_OUT,      // PCLK Select Output
    output                          PIPE_GEN3_OUT,          // GEN3 Output
    //--------------------------------------------------------------------------
    // PRBS Interface
    //--------------------------------------------------------------------------
    input       [ 2:0]              PIPE_TXPRBSSEL,         // TX PRBS Select
    input       [ 2:0]              PIPE_RXPRBSSEL,         // RX PRBS Select
    input                           PIPE_TXPRBSFORCEERR,    // TX PRBS Force Error
    input                           PIPE_RXPRBSCNTRESET,    // RX PRBS Counter Reset
    input       [ 2:0]              PIPE_LOOPBACK,          // Loopback Control
    output      [PCIE_LANE-1:0]     PIPE_RXPRBSERR,         // RX PRBS Error
    //--------------------------------------------------------------------------
    // Debug Interface
    //--------------------------------------------------------------------------
    output      [10:0]              PIPE_RST_FSM,           // Reset FSM State
    output      [11:0]              PIPE_QRST_FSM,          // QPLL Reset FSM State
    output      [(PCIE_LANE*31)-1:0]PIPE_RATE_FSM,          // Rate FSM State
    output      [(PCIE_LANE*6)-1:0] PIPE_SYNC_FSM_TX,       // TX Sync FSM State
    output      [(PCIE_LANE*7)-1:0] PIPE_SYNC_FSM_RX,       // RX Sync FSM State
    output      [(PCIE_LANE*7)-1:0] PIPE_DRP_FSM,           // DRP FSM State
    output      [(PCIE_LANE*6)-1:0] PIPE_TXEQ_FSM,          // TX EQ FSM State
    output      [(PCIE_LANE*6)-1:0] PIPE_RXEQ_FSM,          // RX EQ FSM State
    output      [((((PCIE_LANE-1)>>2)+1)*9)-1:0]PIPE_QDRP_FSM, // QPLL DRP FSM State
    output                          PIPE_RST_IDLE,          // Reset Idle State
    output                          PIPE_QRST_IDLE,         // QPLL Reset Idle State
    output                          PIPE_RATE_IDLE,         // Rate Idle State
    input                           PIPE_JTAG_EN,           // JTAG Enable
    output      [PCIE_LANE-1:0]     PIPE_JTAG_RDY,          // JTAG Ready
    input       [3:0]               i_tx_diff_ctr,
    output      [1:0]               o_rx_byte_is_comma,
    output                          o_rx_byte_is_aligned,
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_0,           // Debug Port 0
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_1,           // Debug Port 1
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_2,           // Debug Port 2
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_3,           // Debug Port 3
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_4,           // Debug Port 4
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_5,           // Debug Port 5
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_6,           // Debug Port 6
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_7,           // Debug Port 7
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_8,           // Debug Port 8
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_9,           // Debug Port 9
    output      [31:0]              PIPE_DEBUG,             // Debug Port
    output      [(PCIE_LANE*15)-1:0] PIPE_DMONITOROUT       // DRP Monitor Output
);

    //--------------------------------------------------------------------------
    // Internal Signals
    //--------------------------------------------------------------------------
    // Reset Synchronizer Registers
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             reset_n_reg1;
(* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             reset_n_reg2;

    // Clocking Signals
    wire                            clk_pclk;
    wire                            clk_rxusrclk;
    wire        [PCIE_LANE-1:0]     clk_rxoutclk;
    wire                            clk_dclk;
    wire                            clk_oobclk;
    wire                            clk_mmcm_lock;

    // Reset Signals
    wire                            rst_cpllreset;
    wire                            rst_cpllpd;
    wire                            rst_rxusrclk_reset;
    wire                            rst_dclk_reset;
    wire                            rst_gtreset;
    wire                            rst_drp_start;
    wire                            rst_drp_x16x20_mode;
    wire                            rst_drp_x16;
    wire                            rst_userrdy;
    wire                            rst_txsync_start;
    wire                            rst_idle;
    wire        [ 4:0]              rst_fsm;

    // QPLL Reset Signals
    wire                            gtp_rst_qpllreset;      // QPLL Reset for GTP
    wire                            gtp_rst_qpllpd;         // QPLL Power Down for GTP
    wire        [(PCIE_LANE-1)>>2:0]qpllreset;
    wire                            qpllpd;
    wire                            qrst_ovrd;
    wire                            qrst_drp_start;
    wire                            qrst_qpllreset;
    wire                            qrst_qpllpd;
    wire                            qrst_idle;
    wire        [ 3:0]              qrst_fsm;

    // JTAG Interface Signals
    wire        [(PCIE_LANE*37)-1:0] jtag_sl_iport;
    wire        [(PCIE_LANE*17)-1:0] jtag_sl_oport;

    // User Signals
    wire        [PCIE_LANE-1:0]     user_oobclk;
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
    wire        [PCIE_LANE-1:0]     user_resetdone ;
    wire        [PCIE_LANE-1:0]     user_rxcdrlock;
    wire        [PCIE_LANE-1:0]     user_rx_converge;

    // Rate Signals
    wire        [PCIE_LANE-1:0]     rate_cpllpd;
    wire        [PCIE_LANE-1:0]     rate_qpllpd;
    wire        [PCIE_LANE-1:0]     rate_cpllreset;
    wire        [PCIE_LANE-1:0]     rate_qpllreset;
    wire        [PCIE_LANE-1:0]     rate_txpmareset;
    wire        [PCIE_LANE-1:0]     rate_rxpmareset;
    wire        [(PCIE_LANE*2)-1:0] rate_sysclksel;
    wire        [PCIE_LANE-1:0]     rate_pclk_sel;
    wire        [PCIE_LANE-1:0]     rate_drp_start;
    wire        [PCIE_LANE-1:0]     rate_drp_x16x20_mode;
    wire        [PCIE_LANE-1:0]     rate_drp_x16;
    wire        [PCIE_LANE-1:0]     rate_gen3;
    wire        [(PCIE_LANE*3)-1:0] rate_rate;
    wire        [PCIE_LANE-1:0]     rate_resetovrd_start;
    wire        [PCIE_LANE-1:0]     rate_txsync_start;
    wire        [PCIE_LANE-1:0]     rate_done;
    wire        [PCIE_LANE-1:0]     rate_rxsync_start;
    wire        [PCIE_LANE-1:0]     rate_rxsync;
    wire        [PCIE_LANE-1:0]     rate_idle;
    wire        [(PCIE_LANE*5)-1:0]rate_fsm;

    // Sync Signals
    wire        [PCIE_LANE-1:0]     sync_txphdlyreset;
    wire        [PCIE_LANE-1:0]     sync_txphalign;
    wire        [PCIE_LANE-1:0]     sync_txphalignen;
    wire        [PCIE_LANE-1:0]     sync_txphinit;
    wire        [PCIE_LANE-1:0]     sync_txdlybypass;
    wire        [PCIE_LANE-1:0]     sync_txdlysreset;
    wire        [PCIE_LANE-1:0]     sync_txdlyen;
    wire        [PCIE_LANE-1:0]     sync_txsync_done;
    wire        [(PCIE_LANE*6)-1:0] sync_fsm_tx;
    wire