`timescale 1ns / 1ps
module ps2_keyboard (
	input RESET_N,
	input CLK,
	output PS2_CLK,
	output PS2_DATA,
	output RX_SCAN,
	output RX_PRESSED,
	output RX_EXTENDED
);

assign PS2_CLK = 1'b0;
assign PS2_DATA = 1'b0;
assign RX_SCAN = 1'b0;
assign RX_PRESSED = 1'b0;
assign RX_EXTENDED = 1'b0;

endmodule