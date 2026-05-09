`timescale 1 ns / 10 ps

// Placeholder/External module definitions (assuming these are used externally or by a testbench)
module icon
  (
      control0
  );
  output [35:0] control0;
endmodule

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

// Corrected aurora_201_pcore module
module aurora_201_pcore #
(
     parameter   SIM_GTPRESET_SPEEDUP=   0,
     parameter   C_EXT_RESET_HIGH = 1 // Define active level for external RESET (1=active high, 0=active low)
)
(
    RESET,          // External Reset Signal
    USER_CLK,       // User Clock output
    HARD_ERROR,     // Aurora Core Hard Error
    SOFT_ERROR,     // Aurora Core Soft Error
    LANE_UP,        // Aurora Lane Up Status
    CHANNEL_UP,     // Aurora Channel Up Status
    INIT_CLK,       // Initialization Clock (usually free running)
    PMA_INIT,       // PMA Initialization Signal (from GTP/GTX)
    TX_D,           // Transmit Data Input
    TX_SRC_RDY,     // Transmit Source Ready Input
    TX_DST_RDY,     // Transmit Destination Ready Output
    RX_D,           // Receive Data Output
    RX_SRC_RDY,     // Receive Source Ready Output
    GTPD4_P,        // Differential Clock Input P (e.g., Reference Clock)
    GTPD4_N,        // Differential Clock Input N (e.g., Reference Clock)
    RXP,            // Serial Receive Data P
    RXN,            // Serial Receive Data N
    TXP,            // Serial Transmit Data P
    TXN             // Serial Transmit Data N
);
    input              RESET;
    output             USER_CLK;
    input              INIT_CLK;
    input              PMA_INIT;        // Asynchronous input signal
    output             HARD_ERROR;
    output             SOFT_ERROR;
    output             LANE_UP;
    output             CHANNEL_UP;
    input   [15:0]     TX_D;           // Corrected width convention [MSB:LSB]
    input              TX_SRC_RDY;
    output             TX_DST_RDY;
    output  [15:0]     RX_D;           // Corrected width convention [MSB:LSB]
    output             RX_SRC_RDY;
    input              GTPD4_P;
    input              GTPD4_N;
    input              RXP;
    input              RXN;
    output             TXP;
    output             TXN;

    // Internal Registers
    reg                HARD_ERROR;
    reg                SOFT_ERROR;
    reg                FRAME_ERROR;    // Declared but not used in this snippet
    reg                LANE_UP;
    reg                CHANNEL_UP;
    reg     [3:0]      reset_debounce_r; // Register for debouncing/synchronizing reset
    reg     [3:0]      debounce_pma_init_r; // Register for debouncing PMA_INIT

    // Internal Wires
    wire               GTPD4_clk_i;     // Clock from IBUFDS
    wire               hard_error_i;
    wire               soft_error_i;
    wire               channel_up_i;
    wire               lane_up_i;
    wire               warn_cc_i;
    wire               do_cc_i;
    wire               dcm_not_locked_i; // From Clock Module
    wire               user_clk_i;       // Internal User Clock
    wire               sync_clk_i;       // Internal Sync Clock
    wire               reset_i;          // Internal Reset Signal to Core
    wire               reset_level;      // Active level of external RESET
    wire               power_down_i;
    wire    [2:0]      loopback_i;
    wire               tx_lock_i;        // From Aurora Core (GTP/GTX Lock)
    wire               tx_out_clk_i;     // Clock output from Aurora Core (GTP/GTX)
    wire               buf_tx_out_clk_i; // Buffered TX output clock
    wire               init_clk_i;       // Internal wire for INIT_CLK
    wire               pma_init_r;       // Debounced PMA_INIT signal
    wire    [15:0]     tx_d_i;         // Internal TX Data
    wire               tx_src_rdy_n_i;   // Inverted TX Source Ready
    wire               tx_dst_rdy_n_i;   // Inverted TX Dest Ready (from Core)
    wire    [15:0]     rx_d_i;         // Internal RX Data (from Core)
    wire               rx_src_rdy_n_i;   // Inverted RX Source Ready (from Core)

 // Instantiate Differential Clock Buffer
 IBUFDS ibufds_gtp_clk // Added instance name
 (
     .I(GTPD4_P),
     .IB(GTPD4_N),
     .O(GTPD4_clk_i) // Use this clock if needed, original used tx_out_clk? Check design intent.
                     // GTPD4 often refers to the REFCLK. tx_out_clk is from GTX/GTP PLL.
                     // Assuming tx_out_clk is the intended source for BUFG based on original code.
 );

 // Instantiate Clock Buffer for User Clock distribution
 BUFG bufg_tx_out_clk // Added instance name
 (
     .I(tx_out_clk_i),
     .O(buf_tx_out_clk_i)
 );

 // Instantiate Clock Management Module (Definition assumed to exist elsewhere)
 // This module likely generates user_clk_i and sync_clk_i from the buffered GTP/GTX clock
 aurora_201_CLOCK_MODULE clock_module_i
    (
        .GTP_CLK(buf_tx_out_clk_i), // Input clock from GTP/GTX (buffered)
        .GTP_CLK_LOCKED(tx_lock_i), // Lock status from GTP/GTX
        .USER_CLK(user_clk_i),      // Output User Clock
        .SYNC_CLK(sync_clk_i),      // Output Sync Clock
        .DCM_NOT_LOCKED(dcm_not_locked_i) // Output Clock Manager Lock Status
    );

 // Register Aurora status outputs synchronously to user clock
 always @(posedge user_clk_i)
 begin
    HARD_ERROR <= hard_error_i;
    SOFT_ERROR <= soft_error_i;
    LANE_UP    <= lane_up_i;
    CHANNEL_UP <= channel_up_i;
 end

 // Handle Ready Signal polarities (Aurora core often uses active low)
 assign tx_src_rdy_n_i = ~TX_SRC_RDY; // Invert input ready
 assign TX_DST_RDY = ~tx_dst_rdy_n_i; // Invert output ready from core
 assign RX_SRC_RDY = ~rx_src_rdy_n_i; // Invert output ready from core

 // Connect data buses
 assign tx_d_i = TX_D;
 assign RX_D = rx_d_i;

 // Assign User Clock output
 assign USER_CLK = user_clk_i;

 // Static assignments for core configuration inputs
 assign power_down_i = 1'b0; // Tie Power Down low (inactive)
 assign loopback_i   = 3'b000; // Tie Loopback low (inactive)

 // Debounce and Synchronize External Reset (RESET) using user_clk_i
 // Generate internal reset signal `reset_i`
 // `pma_init_r` acts as an asynchronous reset assertion for reset_i generation logic
 assign reset_level = (C_EXT_RESET_HIGH == 1) ? RESET : ~RESET; // Determine active level of RESET input

 always @(posedge user_clk_i or posedge pma_init_r) begin // Asynchronous reset via pma_init_r
     if (pma_init_r) begin // If debounced PMA_INIT is high, assert reset
         reset_debounce_r <= 4'b1111;
     end else begin // Otherwise, shift in the active level of the external RESET signal
         reset_debounce_r <= {reset_level, reset_debounce_r[0:2]};
     end
 end

 // Internal reset `reset_i` is active high when the debounce register is all 1s
 assign reset_i = &reset_debounce_r;

 // Debounce PMA_INIT using INIT_CLK
 assign init_clk_i = INIT_CLK; // Pass through INIT_CLK
 always @(posedge init_clk_i) begin
     debounce_pma_init_r <= {PMA_INIT, debounce_pma_init_r[0:2]}; // Shift in PMA_INIT
 end
 // Debounced PMA_INIT is active high if register is all 1s
 assign pma_init_r = &debounce_pma_init_r;

 // Instantiate Aurora Core (Definition assumed to exist elsewhere)
 aurora_201 #
    (
        .SIM_GTPRESET_SPEEDUP(SIM_GTPRESET_SPEEDUP)
        // Pass other necessary parameters if aurora_201 requires them
    )
    aurora_module_i
    (
        // TX Interface (Data Flow: TX_D -> aurora_module_i -> TXP/N)
        .TX_D(tx_d_i),                 // Data to transmit
        .TX_SRC_RDY_N(tx_src_rdy_n_i), // Source Ready (active low)
        .TX_DST_RDY_N(tx_dst_rdy_n_i), // Destination Ready (active low output)

        // RX Interface (Data Flow: RXP/N -> aurora_module_i -> RX_D)
        .RX_D(rx_d_i),                 // Received Data (output)
        .RX_SRC_RDY_N(rx_src_rdy_n_i), // Source Ready (active low output)

        // High-Speed Serial IO
        .RXP(RXP),                     // Serial Data Input P
        .RXN(RXN),                     // Serial Data Input N
        .TXP(TXP),                     // Serial Data Output P
        .TXN(TXN),                     // Serial Data Output N

        // Reference Clock (Check if GTPD4_clk_i should be connected here or if REFCLK is internal to aurora_201)
        // .REFCLK(GTPD4_clk_i),       // Example: If core needs buffered ref clk explicitly
        // .GTPD4(GTPD4_left_i),       // Original code used GTPD4 - check aurora_201 port list

        // Status & Control
        .HARD_ERROR(hard_error_i),     // Hard Error Status (output)
        .SOFT_ERROR(soft_error_i),     // Soft Error Status (output)
        .CHANNEL_UP(channel_up_i),     // Channel Up Status (output)
        .LANE_UP(lane_up_i),           // Lane Up Status (output)
        .WARN_CC(warn_cc_i),           // Clock Correction Warning (output)
        .DO_CC(do_cc_i),               // Clock Correction Pulse (output)
        .DCM_NOT_LOCKED(dcm_not_locked_i), // Clock Manager Lock Status (input from clock module)
        .USER_CLK(user_clk_i),         // User Clock (input)
        .SYNC_CLK(sync_clk_i),         // Sync Clock (input)
        .RESET(reset_i),               // Reset (active high, input)
        .POWER_DOWN(power_down_i),     // Power Down Control (input)
        .LOOPBACK(loopback_i),         // Loopback Control (input)
        .PMA_INIT(pma_init_r),         // Debounced PMA Init (input)

        // GTP/GTX Related Outputs (to Clock Module)
        .TX_LOCK(tx_lock_i),           // TX PLL Lock Status (output)
        .TX_OUT_CLK(tx_out_clk_i)      // TX Clock Output (output)
    );

 // Instantiate Standard Clock Correction Module (Definition assumed to exist elsewhere)
 // Handles clock correction logic based on core signals
 aurora_201_STANDARD_CC_MODULE standard_cc_module_i
    (
        .WARN_CC(warn_cc_i),           // Clock Correction Warning (input from core)
        .DO_CC(do_cc_i),               // Clock Correction Pulse (input from core)
        .DCM_NOT_LOCKED(dcm_not_locked_i),// Clock Manager Lock Status (input from clock module)
        .USER_CLK(user_clk_i),         // User Clock (input)
        .CHANNEL_UP(channel_up_i)      // Channel Up Status (input from core)
    );

endmodule