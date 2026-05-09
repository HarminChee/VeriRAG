`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pcie_7x_v1_3_pipe_wrapper #
(
    parameter PCIE_SIM_MODE                 = "FALSE",
    parameter PCIE_SIM_TX_EIDLE_DRIVE_LEVEL = "1",
    parameter PCIE_GT_DEVICE                = "GTX",
    parameter PCIE_USE_MODE                 = "1.1",
    parameter PCIE_PLL_SEL                  = "CPLL",
    parameter PCIE_LPM_DFE                  = "LPM",
    parameter PCIE_EXT_CLK                  = "FALSE",
    parameter PCIE_POWER_SAVING             = "TRUE",
    parameter PCIE_ASYNC_EN                 = "FALSE",
    parameter PCIE_TXBUF_EN                 = "FALSE",
    parameter PCIE_RXBUF_EN                 = "TRUE",
    parameter PCIE_TXSYNC_MODE              = 0,
    parameter PCIE_RXSYNC_MODE              = 0,
    parameter PCIE_CHAN_BOND                = 0,
    parameter PCIE_CHAN_BOND_EN             = "TRUE",
    parameter PCIE_LANE                     = 1,
    parameter PCIE_LINK_SPEED               = 2,
    parameter PCIE_REFCLK_FREQ              = 0,
    parameter PCIE_USERCLK1_FREQ            = 2,
    parameter PCIE_USERCLK2_FREQ            = 2,
    parameter PCIE_DEBUG_MODE               = 0
)
(
    input                           PIPE_CLK,
    input                           test_i, // Added test input
    input                           PIPE_RESET_N,
    output                          PIPE_PCLK,
    input       [(PCIE_LANE*32)-1:0]PIPE_TXDATA,
    input       [(PCIE_LANE*4)-1:0] PIPE_TXDATAK,
    output      [PCIE_LANE-1:0]     PIPE_TXP,
    output      [PCIE_LANE-1:0]     PIPE_TXN,
    input       [PCIE_LANE-1:0]     PIPE_RXP,
    input       [PCIE_LANE-1:0]     PIPE_RXN,
    output      [(PCIE_LANE*32)-1:0]PIPE_RXDATA,
    output      [(PCIE_LANE*4)-1:0] PIPE_RXDATAK,
    input                           PIPE_TXDETECTRX,
    input       [PCIE_LANE-1:0]     PIPE_TXELECIDLE,
    input       [PCIE_LANE-1:0]     PIPE_TXCOMPLIANCE,
    input       [PCIE_LANE-1:0]     PIPE_RXPOLARITY,
    input       [(PCIE_LANE*2)-1:0] PIPE_POWERDOWN,
    input       [ 1:0]              PIPE_RATE,
    input       [ 2:0]              PIPE_TXMARGIN,
    input                           PIPE_TXSWING,
    input       [(PCIE_LANE*6)-1:0] PIPE_TXDEEMPH,
    input       [(PCIE_LANE*2)-1:0] PIPE_TXEQ_CONTROL,
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET,
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET_DEFAULT,
    input       [(PCIE_LANE*2)-1:0] PIPE_RXEQ_CONTROL,
    input       [(PCIE_LANE*3)-1:0] PIPE_RXEQ_PRESET,
    input       [(PCIE_LANE*6)-1:0] PIPE_RXEQ_LFFS,
    input       [(PCIE_LANE*4)-1:0] PIPE_RXEQ_TXPRESET,
    output      [ 5:0]              PIPE_TXEQ_FS,
    output      [ 5:0]              PIPE_TXEQ_LF,
    output      [(PCIE_LANE*18)-1:0]PIPE_TXEQ_DEEMPH,
    output      [PCIE_LANE-1:0]     PIPE_TXEQ_DONE,
    output      [(PCIE_LANE*18)-1:0]PIPE_RXEQ_NEW_TXCOEFF,
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_LFFS_SEL,
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_ADAPT_DONE,
    output      [PCIE_LANE-1:0]     PIPE_RXEQ_DONE,
    output      [PCIE_LANE-1:0]     PIPE_RXVALID,
    output      [PCIE_LANE-1:0]     PIPE_PHYSTATUS,
    output      [PCIE_LANE-1:0]     PIPE_PHYSTATUS_RST,
    output      [PCIE_LANE-1:0]     PIPE_RXELECIDLE,
    output      [(PCIE_LANE*3)-1:0] PIPE_RXSTATUS,
    output      [(PCIE_LANE*3)-1:0] PIPE_RXBUFSTATUS,
    input       [PCIE_LANE-1:0]     PIPE_RXSLIDE,
    output      [PCIE_LANE-1:0]     PIPE_CPLL_LOCK,
    output      [(PCIE_LANE-1)>>2:0]PIPE_QPLL_LOCK,
    output                          PIPE_PCLK_LOCK,
    output      [PCIE_LANE-1:0]     PIPE_RXCDRLOCK,
    output                          PIPE_USERCLK1,
    output                          PIPE_USERCLK2,
    output                          PIPE_RXUSRCLK,
    output      [PCIE_LANE-1:0]     PIPE_RXOUTCLK,
    output      [PCIE_LANE-1:0]     PIPE_TXSYNC_DONE,
    output      [PCIE_LANE-1:0]     PIPE_RXSYNC_DONE,
    output      [PCIE_LANE-1:0]     PIPE_GEN3_RDY,
    output      [PCIE_LANE-1:0]     PIPE_RXCHANISALIGNED,
    output      [PCIE_LANE-1:0]     PIPE_ACTIVE_LANE,
    input                           PIPE_PCLK_IN,
    input                           PIPE_RXUSRCLK_IN,
    input       [PCIE_LANE-1:0]     PIPE_RXOUTCLK_IN,
    input                           PIPE_DCLK_IN,
    input                           PIPE_USERCLK1_IN,
    input                           PIPE_USERCLK2_IN,
    input                           PIPE_MMCM_LOCK_IN,
    output                          PIPE_TXOUTCLK_OUT,
    output      [PCIE_LANE-1:0]     PIPE_RXOUTCLK_OUT,
    output      [PCIE_LANE-1:0]     PIPE_PCLK_SEL_OUT,
    output                          PIPE_GEN3_OUT,
    input       [ 2:0]              PIPE_TXPRBSSEL,
    input       [ 2:0]              PIPE_RXPRBSSEL,
    input                           PIPE_TXPRBSFORCEERR,
    input                           PIPE_RXPRBSCNTRESET,
    input       [ 2:0]              PIPE_LOOPBACK,
    output      [PCIE_LANE-1:0]     PIPE_RXPRBSERR,
    output      [10:0]              PIPE_RST_FSM,
    output      [11:0]              PIPE_QRST_FSM,
    output      [(PCIE_LANE*24)-1:0]PIPE_RATE_FSM,
    output      [(PCIE_LANE*6)-1:0] PIPE_SYNC_FSM_TX,
    output      [(PCIE_LANE*7)-1:0] PIPE_SYNC_FSM_RX,
    output      [(PCIE_LANE*7)-1:0] PIPE_DRP_FSM,
    output      [(PCIE_LANE*5)-1:0] PIPE_TXEQ_FSM,
    output      [(PCIE_LANE*6)-1:0] PIPE_RXEQ_FSM,
    output      [((((PCIE_LANE-1)>>2)+1)*7)-1:0]PIPE_QDRP_FSM,
    output                          PIPE_RST_IDLE,
    output                          PIPE_QRST_IDLE,
    output                          PIPE_RATE_IDLE,
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_0,
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_1,
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_2,
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_3,
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_4,
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_5,
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_6,
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_7,
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_8,
    output      [PCIE_LANE-1:0]     PIPE_DEBUG_9,
    output      [31:0]              PIPE_DEBUG,
    output      [(PCIE_LANE*8)-1:0] PIPE_DMONITOROUT
);
    reg                             reset_n_reg1;
    reg                             reset_n_reg2;
    wire                            clk_pclk;
    wire                            clk_rxusrclk;
    wire        [PCIE_LANE-1:0]     clk_rxoutclk;
    wire                            clk_dclk;
    wire                            dft_clk_pclk; // Added for DFT
    wire                            dft_clk_rxusrclk; // Added for DFT
    wire                            dft_clk_dclk; // Added for DFT

    assign                          dft_clk_pclk = test_i ? PIPE_CLK : clk_pclk;
    assign                          dft_clk_rxusrclk = test_i ? PIPE_CLK : clk_rxusrclk;
    assign                          dft_clk_dclk = test_i ? PIPE_CLK : clk_dclk;

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
    wire        [PCIE_LANE-1:0]     rate_drp_start;
    wire        [PCIE_LANE-1:0]     rate_pclk_sel;
    wire        [PCIE_LANE-1:0]     rate_gen3;
    wire        [(PCIE_LANE*3)-1:0] rate_rate;
    wire        [PCIE_LANE-1:0]     rate_resetovrd_start;
    wire        [PCIE_LANE-1:0]     rate_txsync_start;
    wire        [PCIE_LANE-1:0]     rate_done;
    wire        [PCIE_LANE-1:0]     rate_rxsync_start;
    wire        [PCIE_LANE-1:0]     rate_rxsync;
    wire        [PCIE_LANE-1:0]     rate_idle;
    wire        [(PCIE_LANE*24)-1:0]rate_fsm;
    wire        [PCIE_LANE-1:0]     sync_txphdlyreset;
    wire        [PCIE_LANE-1:0]     sync_txphalign;
    wire        [PCIE_LANE-1:0]     sync_txphalignen;
    wire        [PCIE_LANE-1:0]     sync_txphinit;
    wire        [PCIE_LANE-1:0]     sync_txdlybypass;
    wire        [PCIE_LANE-1:0]     sync_txdlysreset;
    wire        [PCIE_LANE-1:0]     sync_txdlyen;
    wire        [PCIE_LANE-1:0]     sync_txsync_done;
    wire        [(PCIE_LANE*6)-1:0] sync_fsm_tx;
    wire        [PCIE_LANE-1:0]     sync_rxphalign;
    wire        [PCIE_LANE-1:0]     sync_rxphalignen;
    wire        [PCIE_LANE-1:0]     sync_rxdlybypass;
    wire        [PCIE_LANE-1:0]     sync_rxdlysreset;
    wire        [PCIE_LANE-1:0]     sync_rxdlyen;
    wire        [PCIE_LANE-1:0]     sync_rxddien;
    wire        [PCIE_LANE-1:0]     sync_rxsync_done;
    wire        [PCIE_LANE-1:0]     sync_rxsync_donem;
    wire        [(PCIE_LANE*7)-1:0] sync_fsm_rx;
    wire        [PCIE_LANE-1:0]     txdlysresetdone;
    wire        [PCIE_LANE-1:0]     txphaligndone;
    wire        [PCIE_LANE-1:0]     rxdlysresetdone;
    wire        [PCIE_LANE-1:0]     rxphaligndone_s;
    wire                            txsyncallin;
    wire                            rxsyncallin;
    wire        [(PCIE_LANE*9)-1:0] drp_addr;
    wire        [PCIE_LANE-1:0]     drp_en;
    wire        [(PCIE_LANE*16)-1:0]drp_di;
    wire        [PCIE_LANE-1:0]     drp_we;
    wire        [PCIE_LANE-1:0]     drp_done;
    wire        [(PCIE_LANE*7)-1:0] drp_fsm;
    wire        [PCIE_LANE-1:0]     eq_txeq_deemph;
    wire        [(PCIE_LANE*5)-1:0] eq_txeq_precursor;
    wire        [(PCIE_LANE*7)-1:0] eq_txeq_maincursor;
    wire        [(PCIE_LANE*5)-1:0] eq_txeq_postcursor;
    wire        [((((PCIE_LANE-1)>>2)+1)*8)-1:0]  qdrp_addr;
    wire        [(PCIE_LANE-1)>>2:0]              qdrp_en;
    wire        [((((PCIE_LANE-1)>>2)+1)*16)-1:0] qdrp_di;
    wire        [(PCIE_LANE-1)>>2:0]              qdrp_we;
    wire        [(PCIE_LANE-1)>>2:0]              qdrp_done;
    wire        [((((PCIE_LANE-1)>>2)+1)*6)-1:0]  qdrp_crscode;
    wire        [((((PCIE_LANE-1)>>2)+1)*7)-1:0]  qdrp_fsm;
    wire        [(PCIE_LANE-1)>>2:0]              qpll_qplloutclk;
    wire        [(PCIE_LANE-1)>>2:0]              qpll_qplloutrefclk;
    wire        [(PCIE_LANE-1)>>2:0]              qpll_qplllock;
    wire        [((((PCIE_LANE-1)>>2)+1)*16)-1:0] qpll_do;
    wire        [(PCIE_LANE-1)>>2:0