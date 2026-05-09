`default_nettype none
`timescale 1ns / 1ps

module JtagUserIdentifier #(
	parameter IDCODE_VID = 24'h000000,
	parameter IDCODE_PID = 8'h00
)(
	input  wire tck_in,
	input  wire tms_in,
	input  wire tdi_in,
	output wire tdo_out
);
	reg [31:0] tap_shreg = 0;
	wire       tap_active;
	wire       tap_shift;
	wire       tap_clear;
	wire       tap_tck_bufh;

	JtagTAP #(
		.USER_INSTRUCTION(1)
	) tap_tap (
		.instruction_active(tap_active),
		.state_capture_dr(tap_clear),
		.state_reset(),
		.state_runtest(),
		.state_shift_dr(tap_shift),
		.state_update_dr(),
		.tck(tck_in),
		.tck_gated(),
		.tms(tms_in),
		.tdi(tdi_in),
		.tdo(tdo_out)
	);

	ClockBuffer #(
		.TYPE("LOCAL"),
		.CE("NO")
	) tap_tck_clkbuf (
		.clkin(tck_in),
		.clkout(tap_tck_bufh),
		.ce(1'b1)
	);

	always @(posedge tap_tck_bufh) begin
		if(!tap_active) begin
		end else if(tap_clear)
			tap_shreg <= {IDCODE_VID, IDCODE_PID};
		else if(tap_shift)
			tap_shreg <= {1'b1, tap_shreg[31:1]};
	end
endmodule