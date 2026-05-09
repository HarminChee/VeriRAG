module ps2lab1(
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
assign RST = KEY[0]; // Use KEY[0] as primary reset (assuming active low)
assign LEDR[17:0] = SW[17:0];
assign LEDG = 0;
// wire reset = 1'b0; // Removed - Uncontrollable reset
wire [7:0] scan_code;
reg [7:0] history[1:4];
wire read, scan_ready;

// Assuming oneshot module has an asynchronous reset input (e.g., reset_n)
// If oneshot does not have flip-flops or its reset is handled internally correctly, this might not be needed.
// Without the definition of oneshot, we assume it needs a reset connection if it contains FFs.
oneshot pulser(
   .pulse_out(read),
   .trigger_in(scan_ready),
   .clk(CLOCK_50),
   .reset_n(RST) // Connect primary reset, assuming active low input name 'reset_n'
);

keyboard kbd(
  .keyboard_clk(PS2_CLK),
  .keyboard_data(PS2_DAT),
  .clock50(CLOCK_50),
  .reset(RST), // Connect primary reset (assuming active low for keyboard module)
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

// Corrected always block: Use primary clock and reset, enable with scan_ready
always @(posedge CLOCK_50 or negedge RST) // Use primary clock and asynchronous reset
begin
	if (!RST) begin // Reset condition (active low)
		history[1] <= 8'b0;
		history[2] <= 8'b0;
		history[3] <= 8'b0;
		history[4] <= 8'b0;
	end else if (scan_ready) begin // Enable logic using the original trigger signal
		history[4] <= history[3];
		history[3] <= history[2];
		history[2] <= history[1];
		history[1] <= scan_code;
	end
end

endmodule