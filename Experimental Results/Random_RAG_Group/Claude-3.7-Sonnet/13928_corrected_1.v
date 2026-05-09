module ps2_keyboard (
    input   RESET_N,
    input   CLK,
    input   PS2_CLK,
    input   PS2_DATA,
    output  RX_SCAN,
    output  RX_PRESSED,
    output  RX_EXTENDED,
    input   test_i
);

// synthesis translate_off
initial RESET_N = 1'b1;
// synthesis translate_on

endmodule