module ps2_keyboard (
	output RESET_N,
	input CLK,
	input test_i,
	input scan_PS2_CLK,
	output PS2_CLK,
	output PS2_DATA,
	output RX_SCAN,
	output RX_PRESSED,
	output RX_EXTENDED
);

	wire dft_PS2_CLK;
	assign dft_PS2_CLK = test_i ? scan_PS2_CLK : PS2_CLK;

	// Rest of the module implementation goes here
	// Ensure all DFT principles are adhered to

endmodule