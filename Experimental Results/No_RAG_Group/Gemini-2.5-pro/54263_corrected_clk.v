module ctrl_clk_xilinx_corrected (
  input  wire inclk0,
  input  wire test_clk, // Added test clock input for DFT
  input  wire test_mode, // Added test mode control input for DFT
  output wire c0,
  output wire c1,
  output wire c2,
  output wire locked
);

wire pll_50;
wire dll_50;
wire dll_100;
wire c0_internal;
wire c1_internal;
wire c2_internal;
wire clk_25_internal;

reg  clk_25_ff = 0; // Register for clock division

wire clk_for_clk25_ff; // Muxed clock signal for the clock divider FF

// DCM instances to generate functional clocks
DCM #(
  .CLKDV_DIVIDE(2.0),
  .CLKFX_DIVIDE(32),
  .CLKFX_MULTIPLY(24),
  .CLKIN_DIVIDE_BY_2("FALSE"),
  .CLKIN_PERIOD(15.015), // Assuming input clock period for pll
  .CLKOUT_PHASE_SHIFT("NONE"),
  .CLK_FEEDBACK("NONE"),
  .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
  .DFS_FREQUENCY_MODE("LOW"),
  .DLL_FREQUENCY_MODE("LOW"),
  .DUTY_CYCLE_CORRECTION("TRUE"),
  .FACTORY_JF(16'h8080),
  .PHASE_SHIFT(0),
  .STARTUP_WAIT("TRUE")
) pll (
  .CLKIN(inclk0),
  .CLKFX(pll_50)   // Output 50MHz based on parameters (e.g. if inclk0 is 66.6MHz) - check calculation
  // Note: Unconnected ports omitted for brevity
);

DCM #(
  .CLKDV_DIVIDE(2.0), // Generates CLKDV output (if connected) at CLKIN/2 = 25MHz
  .CLKFX_DIVIDE(1),   // Parameters for CLKFX (if connected)
  .CLKFX_MULTIPLY(4),
  .CLKIN_DIVIDE_BY_2("FALSE"),
  .CLKIN_PERIOD(20.000), // Input is pll_50 (50MHz), period is 20ns
  .CLKOUT_PHASE_SHIFT("NONE"),
  .CLK_FEEDBACK("1X"), // Feedback is CLK0 (50MHz) buffered
  .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
  .DFS_FREQUENCY_MODE("LOW"),
  .DLL_FREQUENCY_MODE("LOW"),
  .DUTY_CYCLE_CORRECTION("TRUE"),
  .FACTORY_JF(16'h8080),
  .PHASE_SHIFT(0),
  .STARTUP_WAIT("TRUE")
) dll (
  .CLKIN(pll_50),     // Input 50MHz clock
  .CLK0(dll_50),      // Output 1X clock (50MHz)
  .CLK2X(dll_100),    // Output 2X clock (100MHz)
  .CLKFB(c1_internal), // Feedback from buffered 50MHz clock
  .LOCKED(locked)
  // Note: Unconnected ports omitted for brevity
);

// Internal clock buffering for functional paths
BUFG BUFG_100 (.I(dll_100), .O(c0_internal)); // Buffered 100MHz clock
BUFG BUFG_50  (.I(dll_50),  .O(c1_internal)); // Buffered 50MHz clock

// Clock MUX for the clock divider flip-flop
// Selects test_clk in test_mode, otherwise uses the internal 100MHz clock
assign clk_for_clk25_ff = test_mode ? test_clk : c0_internal;

// Clock divider flip-flop (Toggle FF)
// Clocked by clk_for_clk25_ff, which is controllable during test mode
always @ (posedge clk_for_clk25_ff) begin
  clk_25_ff <= ~clk_25_ff;
end
assign clk_25_internal = clk_25_ff; // Assign FF output to internal wire

// Buffer the generated 25MHz clock (derived from 100MHz / 4)
BUFG BUFG_25 (.I(clk_25_internal), .O(c2_internal));

// Output Clock Multiplexers for DFT
// Selects test_clk in test_mode, otherwise selects the buffered functional clocks
assign c0 = test_mode ? test_clk : c0_internal;
assign c1 = test_mode ? test_clk : c1_internal;
assign c2 = test_mode ? test_clk : c2_internal;

endmodule