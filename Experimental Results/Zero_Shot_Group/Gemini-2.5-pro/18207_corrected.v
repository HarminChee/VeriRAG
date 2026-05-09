`default_nettype none
`timescale 1ns / 1ps

// Note: This corrected code assumes the existence of modules named 'JtagTAP' and 'ClockBuffer'.
// It also assumes the 'JtagTAP' module interface includes:
// - Outputs: instruction_active, state_capture_dr, state_shift_dr, tdo
// - Inputs: tck, tms, tdi, user_reg_tdi (or similar name for receiving data from the user register)
// - Parameter: USER_INSTRUCTION to specify which instruction this logic pertains to.
// The 'JtagTAP' module is responsible for overall TAP state control and TDO multiplexing.

module JtagUserIdentifier #(
	parameter IDCODE_VID = 24'h000000, // Value loaded into shreg on capture when USER1 active
	parameter IDCODE_PID = 8'h00      // Value loaded into shreg on capture when USER1 active
)(
	// JTAG Ports
	input wire tck,
	input wire tms,
	input wire tdi,
	output wire tdo
);

	// Internal shift register for the user instruction
	reg[31:0]	tap_shreg = 32'b0;

	// Internal control signals from TAP
	wire		tap_instruction_active; // High when USER_INSTRUCTION is active
	wire		tap_state_shift_dr;     // High during Shift-DR state
	wire		tap_state_capture_dr;   // High during Capture-DR state

	// Buffered clock
	wire		tap_tck_bufh;

	// Data output from shift register (LSB) to TAP
	wire		tap_tdo_data_out;


	// Instantiate JTAG TAP Controller
	// This TAP instance controls the state and provides signals for the user register.
	JtagTAP #(
		.USER_INSTRUCTION(1) // Assuming this module implements logic for USER instruction 1
	) tap_tap (
		// Control signals from TAP to user logic
		.instruction_active(tap_instruction_active),
		.state_capture_dr(tap_state_capture_dr),
		.state_shift_dr(tap_state_shift_dr),

		// Unused/Internal TAP state outputs (connections based on original code)
		.state_reset(),
		.state_runtest(),
		.state_update_dr(),
		.tck_gated(),

		// JTAG Port connections
		.tck(tck),          // Module TCK input
		.tms(tms),          // Module TMS input
		.tdi(tdi),          // Module TDI input (used by TAP and user shreg)

		// Data input from User Shift Register (assuming TAP has such an input)
		.user_reg_tdi(tap_tdo_data_out), // LSB of user shift register

		// JTAG Data Output
		.tdo(tdo)           // Final TDO output from TAP controller
	);

	// Instantiate Clock Buffer
	// Uses the primary TCK input. Assumes ClockBuffer module is defined elsewhere.
	ClockBuffer #(
		.TYPE("LOCAL"), // Example parameter, actual may vary
		.CE("NO")       // Example parameter, actual may vary
	) tap_tck_clkbuf (
		.clkin(tck),         // Use module's TCK input
		.clkout(tap_tck_bufh), // Provide buffered clock
		.ce(1'b1)            // Buffer always enabled
	);

	// User Shift Register Logic (synchronized to buffered TCK)
	always @(posedge tap_tck_bufh) begin
		// Only update the register if the associated USER instruction is active
		if (tap_instruction_active) begin
			if (tap_state_capture_dr) begin
				// Load the specified value in the Capture-DR state
				tap_shreg <= {IDCODE_VID, IDCODE_PID};
			end else if (tap_state_shift_dr) begin
				// Shift in data from TDI during the Shift-DR state
				// Assumes TDI feeds the MSB, LSB shifts out
				tap_shreg <= {tdi, tap_shreg[31:1]};
			end
			// In other states (e.g., Update-DR, Run-Test/Idle), the register holds its value.
		end
		// If instruction is not active, register holds its value.
		// Consider adding reset logic if needed (e.g., on TAP reset state).
	end

	// Assign the LSB of the shift register to the output wire connecting to the TAP
	assign tap_tdo_data_out = tap_shreg[0];

endmodule
`default_nettype wire // Reset default net type if needed elsewhere