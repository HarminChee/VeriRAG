module	ps2_keyboard (
	output	RESET_N ,
	input	CLK ,
	output	PS2_CLK ,
	output	PS2_DATA ,
	output	RX_SCAN ,
	output	RX_PRESSED ,
	output	RX_EXTENDED,
    input test_i
);

// synthesis translate_off
initial RESET_N = 1'b1;
// synthesis translate_on

endmodule