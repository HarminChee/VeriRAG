`timescale 1ns / 1ps
module pcie_7x_v1_11_0_pipe_wrapper #
(
    parameter PCIE_SIM_MODE                 = "FALSE",
    parameter PCIE_SIM_SPEEDUP              = "FALSE",
    parameter PCIE_SIM_TX_EIDLE_DRIVE_LEVEL = "1",
    parameter PCIE_GT_DEVICE                = "GTX",
    parameter PCIE_USE_MODE                 = "3.0",
    parameter PCIE_PLL_SEL                  = "CPLL",
    parameter PCIE_AUX_CDR_GEN3_EN          = "TRUE",
    parameter PCIE_LPM_DFE                  = "LPM",
    parameter PCIE_LPM_DFE_GEN3             = "DFE",
    parameter PCIE_EXT_CLK                  = "FALSE",
    parameter PCIE_POWER_SAVING             = "TRUE",
    parameter PCIE_ASYNC_EN                 = "FALSE",
    parameter PCIE_TXBUF_EN                 = "FALSE",
    parameter PCIE_RXBUF_EN                 = "TRUE",
    parameter PCIE_TXSYNC_MODE              = 0,
    parameter PCIE_RXSYNC_MODE              = 0,
    parameter PCIE_CHAN_BOND                = 1,
    parameter PCIE_CHAN_BOND_EN             = "TRUE",
    parameter PCIE_LANE                     = 1,
    parameter PCIE_LINK_SPEED               = 3,
    parameter PCIE_REFCLK_FREQ              = 0,
    parameter PCIE_USERCLK1_FREQ            = 2,
    parameter PCIE_USERCLK2_FREQ            = 2,
    parameter PCIE_TX_EIDLE_ASSERT_DELAY    = 3'd4,
    parameter PCIE_RXEQ_MODE_GEN3           = 1,
    parameter PCIE_OOBCLK_MODE              = 1,
    parameter PCIE_JTAG_MODE                = 0,
    parameter PCIE_DEBUG_MODE               = 0
)
(
    input                           PIPE_CLK,
    input                           PIPE_RESET_N, // Primary Async Reset Input
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
    input       [PCIE_LANE-1:0]     PIPE_TXDEEMPH,
    input       [(PCIE_LANE*2)-1:0] PIPE_TXEQ_CONTROL,
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET,
    input       [(PCIE_LANE*4)-1:0] PIPE_TXEQ_PRESET_DEFAULT,
    input       [(PCIE_LANE*6)-1:0] PIPE_TXEQ_DEEMPH,
    input       [(PCIE_LANE*2)-1:0] PIPE_RXEQ_CONTROL,
    input       [(PCIE_LANE*3)-1:0] PIPE_RXEQ_PRESET,
    input       [(PCIE_LANE*6)-1:0] PIPE_RXEQ_LFFS,
    input       [(PCIE_LANE*4)-1:0] PIPE_RXEQ_TXPRESET,
    input       [PCIE_LANE-1:0]     PIPE_RXEQ_USER_EN,
    input       [(PCIE_LANE*18)-1:0]PIPE_RXEQ_USER_TXCOEFF,
    input       [PCIE_LANE-1:0]     PIPE_RXEQ_USER_MODE,
    output      [ 5:0]              PIPE_TXEQ_FS,
    output      [ 5:0]              PIPE_TXEQ_LF,
    output      [(PCIE_LANE*18)-1:0]PIPE_TXEQ_COEFF,
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
    input                           PIPE_MMCM_RST_N,
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
    input                           PIPE_OOBCLK_IN,
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
    output      [(PCIE_LANE*31)-1:0]PIPE_RATE_FSM,
    output      [(PCIE_LANE*6)-1:0] PIPE_SYNC_FSM_TX,
    output      [(PCIE_LANE*7)-1:0] PIPE_SYNC_FSM_RX,
    output      [(PCIE_LANE*7)-1:0] PIPE_DRP_FSM,
    output      [(PCIE_LANE*6)-1:0] PIPE_TXEQ_FSM,
    output      [(PCIE_LANE*6)-1:0] PIPE_RXEQ_FSM,
    output      [((((PCIE_LANE-1)>>2)+1)*9)-1:0]PIPE_QDRP_FSM,
    output                          PIPE_RST_IDLE,
    output                          PIPE_QRST_IDLE,
    output                          PIPE_RATE_IDLE,
    input                           PIPE_JTAG_EN,           // Used as test_mode signal
    output      [PCIE_LANE-1:0]     PIPE_JTAG_RDY,
    input       [3:0]               i_tx_diff_ctr,
    output      [1:0]               o_rx_byte_is_comma,
    output                          o_rx_byte_is_aligned,
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
    output      [(PCIE_LANE*15)-1:0] PIPE_DMONITOROUT
);

    // DFT Reset Synchronization
    (* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             reset_n_reg1;
    (* ASYNC_REG = "TRUE", SHIFT_EXTRACT = "NO" *)    reg                             reset_n_reg2;
    wire                            pipe_reset_sync_n; // Synchronized, active-low reset

    always @(posedge PIPE_CLK or negedge PIPE_RESET_N) begin
        if (!PIPE_RESET_N) begin
            reset_n_reg1 <= 1'b0;
            reset_n_reg2 <= 1'b0;
        end else begin
            reset_n_reg1 <= 1'b1;
            reset_n_reg2 <= reset_n_reg1;
        end
    end
    assign pipe_reset_sync_n = reset_n_reg2; // Use this for synchronous resets or DFT-controlled async resets

    // Internal Functional Clocks (Assume these might clock FFs)
    wire                            clk_pclk;
    wire                            clk_rxusrclk;
    wire        [PCIE_LANE-1:0]     clk_rxoutclk;
    wire                            clk_dclk;
    wire                            clk_oobclk;
    wire                            clk_mmcm_lock; // This is a status signal, likely not a clock source itself

    // DFT Clock Selection (Use PIPE_CLK during test mode)
    // Note: This assumes PIPE_CLK is the primary test clock source.
    //       Actual implementation requires replacing clock usage at FF level.
    wire                            dft_clk_pclk;
    wire                            dft_clk_rxusrclk;
    wire        [PCIE_LANE-1:0]     dft_clk_rxoutclk;
    wire                            dft_clk_dclk;
    wire                            dft_clk_oobclk;

    assign dft_clk_pclk     = PIPE_JTAG_EN ? PIPE_CLK : clk_pclk;
    assign dft_clk_rxusrclk = PIPE_JTAG_EN ? PIPE_CLK : clk_rxusrclk;
    // For multi-bit clocks, apply muxing bit-wise or ensure generation logic is bypassed
    genvar i_clk;
    generate
       for (i_clk = 0; i_clk < PCIE_LANE; i_clk = i_clk + 1) begin : gen_dft_rxoutclk
           assign dft_clk_rxoutclk[i_clk] = PIPE_JTAG_EN ? PIPE_CLK : clk_rxoutclk[i_clk];
       end
    endgenerate
    assign dft_clk_dclk     = PIPE_JTAG_EN ? PIPE_CLK : clk_dclk;
    assign dft_clk_oobclk   = PIPE_JTAG_EN ? PIPE_CLK : clk_oobclk;


    // Internal Functional Resets (Assume these might drive FF async resets)
    // Note: ACNCPI violations occur if these drive FF async pins directly without primary input control.
    //       Correction requires modifying FF reset connections based on PIPE_JTAG_EN and pipe_reset_sync_n.
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
    wire        [ 4:0]              rst_fsm; // FSM outputs driving resets are highly suspect for ACNCPI
    wire                            gtp_rst_qpllreset;
    wire                            gtp_rst_qpllpd;
    wire        [(PCIE_LANE-1)>>2:0]qpllreset;
    wire                            qpllpd;
    wire                            qrst_ovrd;
    wire                            qrst_drp_start;
    wire                            qrst_qpllreset;
    wire                            qrst_qpllpd;
    wire                            qrst_idle;
    wire        [ 3:0]              qrst_fsm; // FSM outputs driving resets are highly suspect for ACNCPI

    // JTAG/Scan Interface Signals
    wire        [(PCIE_LANE*37)-1:0] jtag_sl_iport;
    wire        [(PCIE_LANE*17)-1:0] jtag_sl_oport;

    // User Control Signals (Some might generate resets)
    wire        [PCIE_LANE-1:0]     user_oobclk;
    wire        [PCIE_LANE-1:0]     user_resetovrd;
    wire        [PCIE_LANE-1:0]     user_txpmareset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     user_rxpmareset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     user_rxcdrreset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     user_rxcdrfreqreset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     user_rxdfelpmreset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     user_eyescanreset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     user_txpcsreset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     user_rxpcsreset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     user_rxbufreset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     user_resetovrd_done;
    wire        [PCIE_LANE-1:0]     user_active_lane;
    wire        [PCIE_LANE-1:0]     user_resetdone ;
    wire        [PCIE_LANE-1:0]     user_rxcdrlock;
    wire        [PCIE_LANE-1:0]     user_rx_converge;

    // Rate Control Signals (Some might generate resets/clocks)
    wire        [PCIE_LANE-1:0]     rate_cpllpd;
    wire        [PCIE_LANE-1:0]     rate_qpllpd;
    wire        [PCIE_LANE-1:0]     rate_cpllreset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     rate_qpllreset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     rate_txpmareset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     rate_rxpmareset; // Suspect for ACNCPI
    wire        [(PCIE_LANE*2)-1:0] rate_sysclksel; // Clock selection logic needs DFT bypass
    wire        [PCIE_LANE-1:0]     rate_pclk_sel; // Clock selection logic needs DFT bypass
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
    wire        [(PCIE_LANE*5)-1:0] rate_fsm; // FSM outputs driving resets/clocks are suspect

    // Sync Control Signals (Some might generate resets)
    wire        [PCIE_LANE-1:0]     sync_txphdlyreset; // Suspect for ACNCPI
    wire        [PCIE_LANE-1:0]     sync_txphalign;