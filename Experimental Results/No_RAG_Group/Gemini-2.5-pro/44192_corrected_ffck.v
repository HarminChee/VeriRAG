`timescale 1ns / 1ps
module can_controller_corrected_ffc // Renamed module
    (
    input wire GCLK,           // Primary clock input
    input wire RES,            // Primary reset input (active high)
    inout wire CAN,
    input wire [107:0] DIN,
    output reg [107:0] DOUT,
    input wire tx_start,
    output reg tx_ready = 1'b0,
    output reg rx_ready = 1'b0
    );

    // Internal signals from sub-module
    wire tx;                   // Transmit data to CAN bus interface
    wire rx;                   // Receive data from CAN bus interface
    wire cntmn;                // Contention detected signal
    wire cntmn_ready;          // Contention status ready
    wire tsync;                // Timing synchronization pulse (used as enable)

    // Internal state registers
    reg [107:0] DIN_BUF = 108'd0; // Buffer for data to be transmitted
    reg timeslot_start  = 1'b0;   // Indicates start of a new timeslot/frame
    reg timeslot_finish = 1'b0;   // Indicates end of a timeslot/frame
    reg have_arb = 1'b0;          // Flag indicating arbitration ownership (reset to 0)
    reg tx_requested = 1'b0;      // Flag indicating a transmission request

    // State machine encoding (using parameters for clarity)
    localparam STATE_BITS = 2; // Example: 2 bits for 2 states
    localparam RECEIVING    = 2'b00;
    localparam TRANSMITTING = 2'b01;
    reg [STATE_BITS-1:0] can_state = RECEIVING; // Current state of the CAN controller

    reg [63:0] bit_cnt = 64'd0;   // Counter for bits within a CAN frame
    reg [107:0] rx_buf = 108'd0;  // Buffer for received data

    // --- Edge detection logic for timeslot_start (uses GCLK) ---
    reg timeslot_start_prev = 1'b0;
    always @(posedge GCLK or posedge RES) begin
        if (RES) begin
            timeslot_start_prev <= 1'b0;
        end else begin
            timeslot_start_prev <= timeslot_start; // Store previous value
        end
    end
    // Combinational signal detecting the rising edge of timeslot_start
    wire timeslot_start_posedge = timeslot_start & ~timeslot_start_prev;

    // --- Combined logic for DIN_BUF, tx_ready, rx_ready, tx_requested (uses GCLK) ---
    always @(posedge GCLK or posedge RES) begin
        if (RES) begin
            // Reset conditions
            DIN_BUF <= 108'd0;
            tx_ready <= 1'b0;
            rx_ready <= 1'b0;
            tx_requested <= 1'b0;
        end else begin
            // Default assignments (hold values unless changed below)

            // Actions triggered on the detected start of a timeslot
            if (timeslot_start_posedge) begin
                if (tx_start) begin
                    DIN_BUF <= DIN;       // Load data to transmit
                    tx_ready <= 1'b0;     // Clear ready flag when starting
                    tx_requested <= 1'b1; // Set request flag
                end
            end

            // Actions triggered on the detected end of a timeslot
            if (timeslot_finish) begin
                if (cntmn_ready) begin
                    if (cntmn) begin // Contention occurred (reception mode)
                       rx_ready <= 1'b1; // Signal data received
                       // tx_ready remains low (or unchanged)
                       // tx_requested remains low (or unchanged)
                    end else begin       // No contention (transmission successful)
                       tx_ready <= 1'b1; // Signal transmission complete
                       tx_requested <= 1'b0; // Clear request flag
                       // rx_ready remains low (or unchanged)
                    end
                end
            end else if (!timeslot_start_posedge) begin
                 // If neither finish nor start edge, maintain state
                 // (e.g. rx_ready stays high until cleared by RES)
                 // Note: tx_ready is cleared by timeslot_start_posedge above or RES
            end
        end
    end

    // --- Combined logic for have_arb, can_state (uses GCLK) ---
    always @