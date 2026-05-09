`default_nettype none
`timescale 1ns / 1ps

module JtagUserIdentifier_corrected_clk #(
	parameter IDCODE_VID = 24'h000000,
	parameter IDCODE_PID = 8'h00
)(
	input wire tap_tck_raw
);

	reg [31:0] tap_shreg = 32'b0;
	wire       tap_active;
	wire       tap_shift;
	wire       tap_clear;

	JtagTAP #(
		.USER_INSTRUCTION(1)
	) tap_tap (
		.instruction_active(tap_active),
		.state_capture_dr(tap_clear),
		.state_reset(),
		.state_runtest(),
		.state_shift_dr(tap_shift),
		.state_update_dr(),
		.tck(tap_tck_raw),
		.tck_gated(),
		.tms(),
		.tdi(),
		.tdo(tap_shreg[0])
	);

	always @(posedge tap_tck_raw) begin
		if (!tap_active) begin
		end
		else if (tap_clear) begin
			tap_shreg <= {IDCODE_VID, IDCODE_PID};
		end
		else if (tap_shift) begin
			tap_shreg <= {1'b1, tap_shreg[31:1]};
		end
	end

endmodule