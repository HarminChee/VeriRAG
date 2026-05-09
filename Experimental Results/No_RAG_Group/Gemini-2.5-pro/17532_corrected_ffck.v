module ps2lab1_corrected_ffc (
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
// Use KEY[0] as active low reset
assign RST = ~KEY[0]; // Assuming KEY[0] is active low reset button

assign LEDR[17:0] = SW[17:0];
assign LEDG = 9'b0; // Initialize LEDG

wire reset_kbd = 1'b0; // Keep keyboard reset tied low as in original, assuming specific need
wire [7:0] scan_code;
reg [7:0] history[1:4];
wire read, scan_ready;

// Instantiate oneshot pulser
oneshot pulser(
   .pulse_out(read),
   .trigger_in(scan_ready),
   .clk(CLOCK_50)
   // Assuming oneshot needs reset, add it if necessary: .rst_n(RST)
);

// Instantiate keyboard interface
keyboard kbd(
  .keyboard_clk(PS2_CLK),
  .keyboard_data(PS2_DAT),
  .clock50(CLOCK_50),
  .reset(reset_kbd), // Use the tied-low reset for keyboard module
  .read(read),
  .scan_ready(scan_ready),
  .scan_code(scan_code)
);

// Instantiate 7-segment displays
hex_7seg dsp0(history[1][3:0],HEX0);
hex_7seg dsp1(history[1][7:4],HEX1);
hex_7seg dsp2(history[2][3:0],HEX2);
hex_7seg dsp3(history[2][7:4],HEX3);
hex_7seg dsp4(history[3][3:0],HEX4);
hex_7seg dsp5(history[3][7:4],HEX5);
hex_7seg dsp6(history[4][3:0],HEX6);
hex_7seg dsp7(history[4][7:4],HEX7);

// Modified history register logic: Clocked by primary clock CLOCK_50, enabled by scan_ready
// Use active-low asynchronous reset RST derived from primary input KEY[0]
always @(posedge CLOCK_50 or negedge RST)
begin
  if (!RST) begin // Active low asynchronous reset
    history[1] <= 8'b0;
    history[2] <= 8'b0;
    history[3] <= 8'b0;
    history[4] <= 8'b0;
  end else if (scan_ready) begin // Update only when scan_ready is high (use as enable)
    history[4] <= history[3];
    history[3] <= history[2];
    history[2] <= history[1];
    history[1] <= scan_code;
  end
  // If scan_ready is low, registers hold their values (implicit)
end

// Assuming hex_7seg, oneshot, and keyboard modules exist and are defined elsewhere.
// Placeholder definitions if needed for completeness (replace with actual modules)
/*
module hex_7seg (input [3:0] i, output [6:0] o); assign o = 7'bxxxxxxx; endmodule
module oneshot (input clk, trigger_in, output pulse_out); assign pulse_out = 1'b0; endmodule
module keyboard (input keyboard_clk, keyboard_data, clock50, reset, read, output scan_ready, output [7:0] scan_code); assign scan_ready=1'b0; assign scan_code=8'b0; endmodule
*/

endmodule