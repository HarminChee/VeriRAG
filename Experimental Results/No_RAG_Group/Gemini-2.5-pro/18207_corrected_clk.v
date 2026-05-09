`default_nettype none
`timescale 1ns / 1ps

module JtagUserIdentifier_corrected_clk #(
    parameter IDCODE_VID = 24'h000000,
    parameter IDCODE_PID = 8'h00
)(
    // Primary JTAG Interface Pins
    input wire tck_in,
    input wire tms_in,
    input wire tdi_in,
    output wire tdo_out
    // Optional: Add scan enable and test clock if needed for specific DFT strategy
    // input wire scan_en,
    // input wire test_clk
);
    reg[31:0]   tap_shreg = 0;
    wire        tap_active;      // Indicates USER instruction is active
    wire        tap_shift;       // Indicates Shift-DR state
    wire        tap_clear;       // Indicates Capture-DR state (used to load parallel value)
    wire        tap_update;      // Indicates Update-DR state (optional for this register)
    wire        tap_tdo_core;    // TDO output from the core TAP logic (e.g., bypass)
    wire        tap_tck_bufh;    // Buffered primary clock

    // Instantiate the JTAG TAP controller
    // Assumes JtagTAP module is defined elsewhere and provides standard TAP functionality.
    // It takes primary JTAG pins and generates internal state/control signals.
    JtagTAP #(
        .USER_INSTRUCTION(1) // Assuming '1' is the instruction code for this ID register
    ) tap_tap (
        .instruction_active(tap_active), // Output: High when USER_INSTRUCTION is active
        .state_capture_dr(tap_clear),    // Output: High during Capture-DR
        .state_reset(),                  // Output: Unused in this snippet
        .state_runtest(),                // Output: Unused in this snippet
        .state_shift_dr(tap_shift),      // Output: High during Shift-DR
        .state_update_dr(tap_update),    // Output: High during Update-DR
        .tck(tck_in),                    // Input: Primary JTAG clock
        .tck_gated(),                    // Output: Gated TCK (if used, potentially problematic for DFT - ensure not used for register clocking)
        .tms(tms_in),                    // Input: Primary JTAG TMS
        .tdi(tdi_in),                    // Input: Primary JTAG TDI
        .tdo(tap_tdo_core)               // Output: TDO from TAP core (e.g., bypass path)
    );

    // Buffer the primary TCK input for driving the user register flop
    // This ensures the flop clock is derived directly from a primary input, fixing CLKNPI.
    // Assumes ClockBuffer module is defined elsewhere.
    ClockBuffer #(
        .TYPE("LOCAL"), // Or "GLOBAL" depending on clock tree strategy
        .CE("NO")
    ) tap_tck_clkbuf (
        .clkin(tck_in),        // Clock sourced from primary input
        .clkout(tap_tck_bufh), // Buffered clock for the register
        .ce(1'b1)              // Clock enable (tied high here)
    );

    // Implement the 32-bit User Identification Register (Data Register)
    // Clocked by the buffered primary TCK input (tap_tck_bufh)
    always @(posedge tap_tck_bufh /* or negedge depending on JTAG standard */) begin
        // JTAG state machine controls register operations when instruction is active
        if (tap_active) begin
            if (tap_clear) begin // Capture-DR state: Parallel load IDCODE
                tap_shreg <= {IDCODE_VID, IDCODE_PID};
            end else if (tap_shift) begin // Shift-DR state: Shift in TDI, shift out LSB
                tap_shreg <= {tdi_in, tap_shreg[31:1]}; // Shift TDI into MSB
            end
            // Update-DR state: tap_shreg holds the shifted-in value.
            // No action needed for this type of register on Update-DR unless it drives parallel outputs.
        end
        // If not active, the register should hold its value.
    end

    // Drive the primary TDO output
    // When the USER instruction is active (meaning this DR is selected) TDO comes from tap_shreg[0].
    // Otherwise, TDO comes from the TAP core (e.g., bypass register or other DRs selected by other instructions).
    assign tdo_out = tap_active ? tap_shreg[0] : tap_tdo_core;

endmodule