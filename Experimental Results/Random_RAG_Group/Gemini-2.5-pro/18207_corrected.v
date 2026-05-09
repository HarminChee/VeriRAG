`default_nettype none
`timescale 1ns / 1ps

module JtagUserIdentifier #(
	parameter IDCODE_VID = 24'h000000,
	parameter IDCODE_PID = 8'h00
)(
    input  wire tck, // Added Primary Input Clock
    input  wire tms, // Added Primary Input
    input  wire tdi, // Added Primary Input
    output wire tdo  // Added Primary Output
    // Consider adding input wire trst_n if the JtagTAP module requires an async reset
);

	reg[31:0]	tap_shreg = 32'b0; // Initialize
	wire		tap_active; // Assuming this indicates USER1 instruction is active
	wire		tap_shift;  // Signal active during Shift-DR state for this DR
	wire		tap_clear;  // Signal active during Capture-DR state for this DR
	wire		tap_tck_bufh; // Buffered clock
    wire        tdo_internal; // TDO signal from JtagTAP instance

	// Instantiate JtagTAP - Assuming standard port names and behavior
	// The specific ports depend on the actual JtagTAP module definition.
	JtagTAP #(
		.USER_INSTRUCTION(1) // Assuming USER_INSTRUCTION=1 selects this ID register
	) tap_tap (
		.instruction_active(tap_active), // Output: Indicates USER1 instruction is current
		.state_capture_dr(tap_clear),    // Output: Pulse in Capture-DR state
		.state_reset(),                  // Output: Unused in this example
		.state_runtest(),                // Output: Unused in this example
		.state_shift_dr(tap_shift),      // Output: High during Shift-DR state
		.state_update_dr(),              // Output: Unused in this example
		.tck(tck),                       // Input: Connect to primary input tck
		.tck_gated(),                    // Output: Unused in this example
		.tms(tms),                       // Input: Connect to primary input tms
		.tdi(tdi),                       // Input: Connect to primary input tdi
		// Assuming JtagTAP takes the serial input from the selected Data Register
		.dr_serial_in(tap_shreg[0]),     // Input: Provide LSB of IDCODE register to TAP MUX
		.tdo(tdo_internal)               // Output: Final TDO output from TAP MUX
        // .trst_n(trst_n)                // Input: Connect async reset if available/needed
	);

    // Connect internal TDO from TAP to the module's primary output
    assign tdo = tdo_internal;

	// Instantiate Clock Buffer (Optional, depends on timing/fanout requirements)
	ClockBuffer #(
		.TYPE("LOCAL"), // Or "GLOBAL" / "BUFG" etc. depending on target technology
		.CE("NO")
	) tap_tck_clkbuf (
		.clkin(tck), // Input is the primary clock tck
		.clkout(tap_tck_bufh),
		.ce(1'b1)
	);

	// IDCODE Register Logic (32-bit shift register)
	always @(posedge tap_tck_bufh) begin // Clocked by buffered tck (derived from primary input)
		// JTAG Test-Logic-Reset state should implicitly reset the state machine in JtagTAP,
		// leading to tap_clear being asserted in Capture-DR after reset.
		// No separate asynchronous reset is shown for this register itself.
		if(tap_active) begin // Only load/shift when USER1 instruction is active
			if(tap_clear) // Load parallel value in Capture-DR state
				tap_shreg <= {IDCODE_VID, IDCODE_PID};
			else if(tap_shift) // Shift in serial data (tdi) in Shift-DR state
				tap_shreg <= {tdi, tap_shreg[31:1]};
            // else: Hold value in other states (e.g., Update-DR, Run-Test/Idle)
		end
        // else: Behavior when instruction is not active depends on JtagTAP spec.
        //       Typically holds value or might be cleared. Assuming hold here.
	end

endmodule
`default_nettype wire // Restore default net type