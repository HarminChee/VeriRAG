module ps2lab1_corrected_ffc(
  input  CLOCK_50,
  input  [3:0]  KEY,
  input  [17:0]  SW,
  output  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
  output  [8:0]  LEDG,  
  output  [17:0]  LEDR,  
  input	PS2_DAT,
  input	PS2_CLK,
  inout  [35:0]  GPIO_0, GPIO_1
);
assign  GPIO_0    =  36'hzzzzzzzzz;
assign  GPIO_1    =  36'hzzzzzzzzz;
wire RST;
assign RST = KEY[0];
assign LEDR[17:0] = SW[17:0];
assign LEDG = 0;
wire reset = 1'b0;
wire [7:0] scan_code;
reg [7:0] history[1:4];
wire read, scan_ready;
oneshot pulser(
   .pulse_out(read),
   .trigger_in(scan_ready),
   .clk(CLOCK_50)
);
keyboard kbd(
  .keyboard_clk(PS2_CLK),
  .keyboard_data(PS2_DAT),
  .clock50(CLOCK_50),
  .reset(reset),
  .read(read),
  .scan_ready(scan_ready),
  .scan_code(scan_code)
);
hex_7seg dsp0(history[1][3:0],HEX0);
hex_7seg dsp1(history[1][7:4],HEX1);
hex_7seg dsp2(history[2][3:0],HEX2);
hex_7seg dsp3(history[2][7:4],HEX3);
hex_7seg dsp4(history[3][3:0],HEX4);
hex_7seg dsp5(history[3][7:4],HEX5);
hex_7seg dsp6(history[4][3:0],HEX6);
hex_7seg dsp7(history[4][7:4],HEX7);
always @(posedge CLOCK_50)
begin
	if (scan_ready)
	begin
		history[4] <= history[3];
		history[3] <= history[2];
		history[2] <= history[1];
		history[1] <= scan_code;
	end
end
endmodule