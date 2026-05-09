`default_nettype none
`timescale 1ns / 1ps

module JtagUserIdentifier #(
	parameter IDCODE_VID = 24'h000000,
	parameter IDCODE_PID = 8'h00
)(
	input wire primary_clk  // Add a primary input for clock
);
	reg[31:0]	tap_shreg = 0;
	wire		tap_active;
	wire		tap_shift;
	wire		tap_clear;
	wire		tap_tck_raw;
	wire		tap_tck_bufh;

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

	// Remove ClockBuffer instantiation and use primary_clk directly
	assign tap_tck_bufh = primary_clk;

	always @(posedge tap_tck_bufh) begin
		if(!tap_active) begin
		end
		else if(tap_clear)
			tap_shreg	<= {IDCODE_VID, IDCODE_PID};
		else if(tap_shift)
			tap_shreg	<= {1'b1, tap_shreg[31:1]};
	end
endmodule