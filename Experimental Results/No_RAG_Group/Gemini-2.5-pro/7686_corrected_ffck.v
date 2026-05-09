`timescale 1ns / 1ps
module test_corrected_ffc ( // Renamed module as requested
    input CLK_IN,         // Primary clock input
    output [7:0] LEDS,
    output [7:0] DEBUG,
	 output reg WS,
	 output OPEN,
	 input [2:0] COL,
	 inout [3:0] ROW,
	 input [3:0] SW
    );

localparam CLKDIV = 20;
wire [7:0] BRT;         // Unused in the provided logic snippet
// Removed internally generated clocks:
// wire CLK; (* BUFG = "clk" *)
// wire CLK2;
reg RESET = 1;
wire [255:0] W;
reg [255:0] W2 = 256'b0;
wire WS_asic;
wire ERROR;
// Use a wider counter if comparing against large values like FFFF
// reg [8:0] startup = 0; // Original was 9 bits, compared to 8'hFF (255) or maybe 16'hFFFF?
reg [15:0] startup_counter = 0; // Using 16 bits for clarity if 0xFFFF comparison intended

reg [CLKDIV:0] counter = 0;
wire [3:0] ROW_asic;
wire OPENER; // Added missing wire declaration

// --- Enable Signal Generation ---
// Registers to store previous state for edge detection
reg counter_clkdiv_prev;
reg counter_clkdiv3_prev;

// Enable signal corresponding to the original posedge CLK (counter[CLKDIV-1])
wire clk_enable;
// Enable signal corresponding to the original negedge CLK2 (counter[CLKDIV-3])
wire clk2_neg_enable;


// --- Submodule Instantiations ---
// Modules now clocked by the primary clock CLK_IN.
// Enable signals (clk_enable) should ideally be passed if modules support them,
// otherwise modules need internal modification or logic gating using the enable.
custom challenge (
    .RESET(SW[0]),
    .CLK(CLK_IN),       // Use primary clock CLK_IN
    // .ENABLE(clk_enable), // Pass enable if module has an enable port
    .COL(COL),
    .ROW(ROW_asic),
    .OPEN(OPEN),
    .W(W),
    .DEBUG(DEBUG[6:0])
    );

ws2812b display (
    .RESET(RESET),
    .W(W2),
	 .CLK50(CLK_IN),     // Already using primary clock
    .WS(WS_asic),
	 .OPENER(OPENER),    // Pass OPENER signal
	 .ERROR(ERROR)
    );

sr_timer #(200) success (
    .S(OPEN),
    .R(RESET),
    .CLK(CLK_IN),       // Use primary clock CLK_IN
    // .ENABLE(clk_enable), // Pass enable if module has an enable port
	 .OUT(OPENER)
);

keypad keypad (
    .COL(COL),
    .ROW(ROW),
    .ROW_asic(ROW_asic),
    .ERROR(ERROR)       // Assuming ERROR connects here
    );

// --- Clock Division Counter ---
always @(posedge CLK_IN) begin
	counter <= counter + 1;
end

// --- Generate Enable Signals Synchronously ---
always @(posedge CLK_IN) begin
    // Store previous values of counter bits used for original clocks
    counter_clkdiv_prev <= counter[CLKDIV-1];
    counter_clkdiv3_prev <= counter[CLKDIV-3];
end

// Generate enable pulse on the cycle corresponding to the original posedge CLK
assign clk_enable = (counter[CLKDIV-1] == 1'b1) && (counter_clkdiv_prev == 1'b0);

// Generate enable pulse on the cycle corresponding to the original negedge CLK2
assign clk2_neg_enable = (counter[CLKDIV-3] == 1'b0) && (counter_clkdiv3_prev == 1'b1);


// --- W2 Register Update ---
// Use primary clock CLK_IN and the generated enable signal
always @(posedge CLK_IN) begin
	if (clk2_neg_enable) begin
	   W2 <= W;
   end
end

// --- Startup Reset Logic ---
always @(posedge CLK_IN) begin
  // Assuming comparison intended for 16'hFFFF (65535)
  if (startup_counter < 16'hFFFF) begin
      startup_counter <= startup_counter + 1;
      RESET <= 1; // Assert RESET during startup count
  end else begin
      RESET <= 0; // Deassert RESET after count completes
  end
end

// --- Combinational Output Logic ---
assign LEDS = DEBUG | {8{OPENER}};
assign DEBUG[7] = WS;

// Use continuous assignment for WS instead of always @(*)
assign WS = WS_asic;

endmodule