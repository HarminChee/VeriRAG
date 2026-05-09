`timescale 1 ns / 10 ps
// Definition for icon (unused in aurora_201_pcore but provided in original)
module icon
  (
      control0
  );
  output [35:0] control0;
endmodule

// Definition for ila (unused in aurora_201_pcore but provided in original)
module ila
  (
    control,
    clk,
    trig0
  );
  input [35:0] control;
  input clk;
  input [47:0] trig0;
endmodule

// Corrected aurora_201_pcore module for CLKNPI violation
`timescale 1 ns / 10 ps
module aurora_201_pcore #
(
     parameter   SIM_GTPRESET_SPEEDUP=   0,
     parameter   C_EXT_RESET_HIGH = 0
)
(
    RESET,
    USER_CLK, // Functional clock output
    HARD_ERROR,
    SOFT_ERROR,
    LANE_UP,
    CHANNEL_UP,
    INIT_CLK,   // Primary clock input
    PMA_INIT,
    TX_D,
    TX_SRC_RDY,
    TX_DST_RDY,
    RX_D,
    RX_SRC_RDY,
    GTPD4_P,    // Primary clock input (differential)
    GTPD4_N,    // Primary clock input (differential)
    RXP,
    RXN,
    TXP,
    TXN,
    // DFT Ports
    scan_enable, // Test mode control
    test_clk     // Test clock input
);
    input              RESET;
    output             USER_CLK; // Output functional clock
    input              INIT_CLK; // Primary input clock
    input              PMA_INIT;
    output             HARD_ERROR;
    output             SOFT_ERROR;
    output             LANE_UP;
    output             CHANNEL_UP;
    input   [0:15]     TX_D;
    input              TX_SRC_RDY;
    output             TX_DST_RDY;
    output  [0:15]     RX_D;
    output             RX_SRC_RDY;
    input              GTPD4_P;  // Primary input
    input              GTPD4_N;  // Primary input
    input              RXP;
    input              RXN;
    output             TXP;
    output             TXN;
    // DFT Inputs
    input              scan_enable; // Test mode input
    input              test_clk;    // Test clock input

    reg                HARD_ERROR;
    reg                SOFT_ERROR;
    // FRAME_ERROR seems unused in the original logic provided
    // reg                FRAME_ERROR;
    reg                LANE_UP;
    reg                CHANNEL_UP;
    reg     [0:3]      reset_debounce_r;
    reg     [0:3]      debounce_pma_init_r;
    // ila_data_i seems unused
    // wire   [255:0]    ila_data_i;
    // icon_ila_i seems unused
    // wire   [35:0]     icon_ila_i;
    wire    [0:15]     tx_d_i;
    wire               tx_src_rdy_n_i;
    wire               tx_dst_rdy_n_i;
    wire    [0:15]     rx_d_i;
    wire               rx_src_rdy_n_i;
    wire               GTPD4_left_i;
    wire               hard_error_i;
    wire               soft_error_i;
    wire               channel_up_i;
    wire               lane_up_i;
    wire               warn_cc_i;
    wire               do_cc_i;
    wire               dcm_not_locked_i;
    wire               user_clk_i; // Internal functional clock
    wire               sync_clk_i;
    wire               reset_i;
    wire               power_down_i;
    wire    [0:2]      loopback_i;
    wire               tx_lock_i;
    wire               tx_out_clk_i;
    wire               buf_tx_out_clk_i;
    wire               init_clk_i; // Derived from primary input INIT_CLK
    wire               pma_init_r;

    // DFT Clock Mux
    wire               muxed_clk; // Clock signal selected based on scan_enable

    // Clock mux logic: Select test_clk in scan mode, otherwise use functional clock
    assign muxed_clk = scan_enable ? test_clk : user_clk_i;

 IBUFDS IBUFDS
 (
 .I(GTPD4_P),
 .IB(GTPD4_N),
 .O(GTPD4_left_i)
 );

 BUFG BUFG
 (
  .I(tx_out_clk_i),
  .O(buf_tx_out_clk_i)
 );

    // Instantiate clock module (generates internal user_clk_i)
    // This module likely contains PLL/DCM which is the source of the internal clock
    aurora_201_CLOCK_MODULE clock_module_i
    (
        .GTP_CLK(buf_tx_out_clk_i),
        .GTP_CLK_LOCKED(tx_lock_i),
        .USER_CLK(user_clk_i), // Internal functional clock generated here
        .SYNC_CLK(sync_clk_i),
        .DCM_NOT_LOCKED(dcm_not_locked_i)
    );

    // Registers clocked by the MUXED clock (muxed_clk)
    // In functional mode (scan_enable=0), muxed_clk = user_clk_i
    // In test mode (scan_enable=1), muxed_clk = test_clk (primary input)
    always @(posedge muxed_clk)
    begin
        HARD_ERROR      <=  hard_error_i;
        SOFT_ERROR      <=  soft_error_i;
        LANE_UP         <=  lane_up_i;
        CHANNEL_UP      <=  channel_up_i;
    end

    assign tx_src_rdy_n_i = ~TX_SRC_RDY;
    assign TX_DST_RDY = ~tx_dst_rdy_n_i;
    assign RX_SRC_RDY = ~rx_src_rdy_n_i;
    assign tx_d_i = TX_D;
    assign RX_D = rx_d_i;
    assign USER_CLK = user_clk_i; // Output the functional clock
    assign  power_down_i        =   1'b0;
    assign  loopback_i          =   3'b000;

    // Reset synchronizer/debouncer clocked by the MUXED clock
    // Asynchronous reset pma_init_r remains, potentially needs DFT handling (RSTNPI)
    // but clock source is now DFT-friendly.
    always @(posedge muxed_clk or posedge pma_init_r)
        if(pma_init_r)
            reset_debounce_r    <=  4'b1111;
        else
            reset_debounce_r    <=  {RESET,reset_debounce_r[0:2]};

    assign  reset_i =   &reset_debounce_r;

   // init_clk_i is derived directly from primary input INIT_CLK, so OK for DFT
   assign init_clk_i = INIT_CLK;

    // PMA_INIT synchronizer/debouncer clocked by init_clk_i (primary input clock)
    // This part is already DFT-friendly regarding the clock source.
    always @(posedge init_clk_i)
        debounce_pma_init_r <=  {PMA_INIT,debounce_pma_init_r[0:2]};

    assign  pma_init_r  =   &debounce_pma_init_r;

    // Instantiate the Aurora core module
    aurora_201 #
    (
        .SIM_GTPRESET_SPEEDUP(SIM_GTPRESET_SPEEDUP)
    )
    aurora_module_i
    (
        .TX_D(tx_d_i),
        .TX_SRC_RDY_N(tx_src_rdy_n_i),
        .TX_DST_RDY_N(tx_dst_rdy_n_i),
        .RX_D(rx_d_i),
        .RX_SRC_RDY_N(rx_src_rdy_n_i),
        .RXP(RXP),
        .RXN(RXN),
        .TXP(TXP),
        .TXN(TXN),
        .GTPD4(GTPD4_left_i),
        .HARD_ERROR(hard_error_i),
        .SOFT_ERROR(soft_error_i),
        .CHANNEL_UP(channel_up_i),
        .LANE_UP(lane_up_i),
        .WARN_CC(warn_cc_i),
        .DO_CC(do_cc_i),
        .DCM_NOT_LOCKED(dcm_not_locked_i),
        // Pass the MUXED clock to the core if it uses user_clk internally for FF clocking
        // However, the original code used user_clk_i. Assuming internal FFs within aurora_module_i
        // also need DFT modification, this requires modifying aurora_201 module itself.
        // For this level (aurora_201_pcore), we ensure FFs *at this level* are DFT friendly.
        // We pass the internal functional clock user_clk_i here as per original connection.
        // The TX_OUT_CLK is generated within this module based on its inputs.
        .USER_CLK(user_clk_i),
        .SYNC_CLK(sync_clk_i),
        .RESET(reset_i),
        .POWER_DOWN(power_down_i),
        .LOOPBACK(loopback_i),
        .PMA_INIT(pma_init_r),
        .TX_LOCK(tx_lock_i),
        .TX_OUT_CLK(tx_out_clk_i) // Output clock from the core
    );

    // Instantiate standard CC module
    // Clocked by user_clk_i. If this module contains FFs, it needs similar DFT modification
    // (either internally or by passing muxed_clk). Assuming black-box or combinatorial for now.
    aurora_201_STANDARD_CC_MODULE standard_cc_module_i
    (
        .WARN_CC(warn_cc_i),
        .DO_CC(do_cc_i),
        .DCM_NOT_LOCKED(dcm_not_locked_i),
        .USER_CLK(user_clk_i), // Or potentially muxed_clk if FFs inside
        .CHANNEL_UP(channel_up_i)
    );

  // Unused wire from original code stub for icon
  wire [35:0] control0;

// Assume aurora_201_CLOCK_MODULE, aurora_201, and aurora_201_STANDARD_CC_MODULE are defined elsewhere.
// The DFT modifications (clock muxing) primarily affect the flip-flops within *this* module (aurora_201_pcore).
// Full DFT compliance would require ensuring sub-modules are also DFT-clean or properly handled (e.g., bypassed).

endmodule