module jtag_cores (
    // JTAG Interface Inputs
    input tck,             // Test Clock
    input tdi,             // Test Data In
    input reset,           // Test Reset (active high) - often driven by TRSTN inverted

    // Parallel Data Interface (for Capture-DR)
    input [7:0] reg_d,     // Data to be captured into shift register
    input [2:0] reg_addr_d,// Address to be captured into shift register

    // JTAG Interface Outputs
    output tdo,            // Test Data Out
    output jrstn,          // Test Reset (active low) output - reflects inverted reset input

    // Parallel Data Interface (from Update-DR)
    output reg reg_update, // Indicates data has been updated in the latched register
    output reg [7:0] reg_q, // Latched data output
    output reg [2:0] reg_addr_q, // Latched address output

    // Exposing TCK (optional, but present in original)
    output jtck
);

// Internal signals from JTAG TAP controller
wire shift;
wire update;
// Note: The 'reset' input to this module drives the TAP reset
// Note: 'tck', 'tdi', 'tdo' are now module ports

// Instantiate the JTAG TAP controller (Assuming this module exists elsewhere)
// It controls the state machine and generates shift/update signals.
jtag_tap jtag_tap_inst (
    .tck(tck),
    .tdi(tdi),
    .tdo(/* connect TDO output if TAP provides it directly, or handle below */), // TAP TDO might be handled differently depending on design
    .shift(shift),   // Signal active during Shift-DR/IR states
    .update(update), // Signal active during Update-DR/IR states
    .reset(reset)    // TAP controller reset
    // Add other necessary TAP connections like TMS if needed by jtag_tap module
);

// JTAG Shift Register (Data Register portion)
// Combined register and address bits: 8 + 3 = 11 bits
reg [10:0] jtag_shift;

// Shift Register Logic (Capture and Shift)
always @(posedge tck or posedge reset) begin
    if (reset) begin
        jtag_shift <= 11'b0;
    end else begin
        // Shift operation during Shift-DR state
        if (shift) begin
            jtag_shift <= {tdi, jtag_shift[10:1]};
        // Capture operation during Capture-DR state (assuming shift is low)
        end else begin
            // Load parallel data when not shifting (Capture phase)
            // Note: In a real JTAG DR, capture might only happen on the first TCK edge
            //       in the Capture-DR state. This implementation captures whenever 'shift' is low.
            //       This might need refinement based on the exact TAP controller behavior.
            jtag_shift <= {reg_d, reg_addr_d};
        end
    end
end

// Assign TDO output from the LSB of the shift register
assign tdo = jtag_shift[0];

// JTAG Update Register (Latched Register)
// Holds the data stable after the Shift-DR state, updated during Update-DR state.
reg [10:0] jtag_latched;

// Update Register Logic (Latch)
always @(posedge tck or posedge reset) begin
    if (reset) begin
        jtag_latched <= 11'b0;
        reg_q <= 8'b0;         // Reset output registers directly
        reg_addr_q <= 3'b0;
        reg_update <= 1'b0;    // Reset update flag
    end else begin
        // Latch the shifted data on the TCK edge when 'update' is active (Update-DR state)
        if (update) begin
            jtag_latched <= jtag_shift;
            // Assign outputs directly here for registered outputs
            reg_q <= jtag_shift[10:3];
            reg_addr_q <= jtag_shift[2:0];
            reg_update <= 1'b1; // Signal that an update occurred (pulse)
        end else begin
            // Deassert update signal on the next clock edge if update is not active
            reg_update <= 1'b0;
            // Outputs hold their previous value if not updated
        end
    end
end

// Assign other outputs
assign jtck = tck;      // Pass through TCK
assign jrstn = ~reset;  // Generate active-low reset output

endmodule