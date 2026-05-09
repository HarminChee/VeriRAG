module jtag_cores_corrected_clk (
    // Primary Inputs
    input jtag_tck,      // Primary JTAG clock input
    input jtag_tdi,      // Primary JTAG data input
    input jtag_trst_n,   // Primary JTAG reset input (active low)
    input [7:0] reg_d,       // Data input for parallel load
    input [2:0] reg_addr_d,  // Address input for parallel load

    // Primary Outputs
    output jtag_tdo,      // Primary JTAG data output
    output reg_update,    // Indicates data register update
    output [7:0] reg_q,       // Latched data output
    output [2:0] reg_addr_q   // Latched address output
);

// Internal signals from JTAG TAP controller
wire shift;  // Shift enable for the shift register
wire update; // Update enable for the latch register
wire reset;  // Internal reset signal (derived from jtag_trst_n and TAP state)
wire tdo_internal; // Internal TDO from shift register

// Instantiate JTAG TAP Controller
// Assuming jtag_tap takes primary clock and reset, and TDI
// and generates control signals (shift, update, reset) and TDO enable etc.
// The exact ports depend on the jtag_tap definition, adapting here based on common practice.
// NOTE: The definition of jtag_tap is not provided, assuming standard JTAG TAP behavior.
jtag_tap jtag_tap_inst (
    .tck(jtag_tck),      // Connect to primary clock
    .trst_n(jtag_trst_n), // Connect to primary reset
    .tdi(jtag_tdi),      // Connect to primary TDI
    .tdo(tdo_internal),  // TDO output from TAP (might control buffer) - Assuming TAP drives this based on shift reg output
    .shift(shift),       // Output shift control
    .update(update),     // Output update control
    .reset(reset)        // Output internal reset (active high for logic below)
    // Add other necessary jtag_tap ports like TMS, TDO enable etc. if needed
);

// JTAG Shift Register (Boundary Scan Register part)
reg [10:0] jtag_shift;

// Clocked by primary jtag_tck, asynchronous reset 'reset' (derived from jtag_trst_n by TAP)
// Parallel load happens when shift is low (Capture-DR state)
// Serial shift happens when shift is high (Shift-DR state)
always @(posedge jtag_tck or posedge reset) begin
    if (reset) begin
        jtag_shift <= 11'b0;
    end else begin
        if (shift) begin
            // Shift in jtag_tdi during Shift-DR
            jtag_shift <= {jtag_tdi, jtag_shift[10:1]};
        end else begin
            // Capture register inputs during Capture-DR (assuming shift=0 here)
            jtag_shift <= {reg_d, reg_addr_d};
        end
    end
end

// Assign internal TDO signal from the shift register's LSB
assign tdo_internal = jtag_shift[0];
// Assign primary TDO output (potentially needs tristate buffer controlled by TAP)
assign jtag_tdo = tdo_internal; // Simplification: directly assign internal TDO


// JTAG Latch Register (Update Register)
reg [10:0] jtag_latched;

// *** FIX: Clocked by primary jtag_tck, enabled by 'update', asynchronous reset 'reset' ***
// The original code used 'reg_update' (derived from 'update') as a clock, causing CLKNPI.
// Now, 'jtag_tck' is the clock and 'update' is the enable signal.
always @(posedge jtag_tck or posedge reset) begin
    if (reset) begin
        jtag_latched <= 11'b0;
    end else if (update) begin // Use 'update' as clock enable
        jtag_latched <= jtag_shift;
    end
    // else: jtag_latched holds its value when reset is low and update is low
end

// Assign outputs from the latched register
assign reg_update = update; // Pass update signal out
assign reg_q = jtag_latched[10:3];
assign reg_addr_q = jtag_latched[2:0];

// Removed original jtck and jrstn outputs as they were incorrectly defined or redundant

endmodule