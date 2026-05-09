module ps2lab1(
  input  CLOCK_50,
  input  [3:0]  KEY,
  input  [17:0]  SW,
  output  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
  output  [8:0]  LEDG,  
  output  [17:0]  LEDR,  
  input PS2_DAT,
  input PS2_CLK,
  inout  [35:0]  GPIO_0, GPIO_1
);
assign  GPIO_0    =  36'hzzzzzzzzz;
assign  GPIO_1    =  36'hzzzzzzzzz;
wire RST;
assign RST = KEY[0];
assign LEDR[17:0] = SW[17:0];
assign LEDG = 9'b0; // Corrected size of LEDG
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
  .reset(RST), // Use RST instead of reset
  .read(read),
  .scan_ready(scan_ready),
  .scan_code(scan_code)
);

hex_7seg dsp0(.hex(history[1][3:0]), .segments(HEX0));
hex_7seg dsp1(.hex(history[1][7:4]), .segments(HEX1));
hex_7seg dsp2(.hex(history[2][3:0]), .segments(HEX2));
hex_7seg dsp3(.hex(history[2][7:4]), .segments(HEX3));
hex_7seg dsp4(.hex(history[3][3:0]), .segments(HEX4));
hex_7seg dsp5(.hex(history[3][7:4]), .segments(HEX5));
hex_7seg dsp6(.hex(history[4][3:0]), .segments(HEX6));
hex_7seg dsp7(.hex(history[4][7:4]), .segments(HEX7));

always @(posedge scan_ready)
begin
  history[4] <= history[3];
  history[3] <= history[2];
  history[2] <= history[1];
  history[1] <= scan_code;
end

endmodule