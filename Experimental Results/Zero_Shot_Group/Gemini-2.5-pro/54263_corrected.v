module ctrl_clk_xilinx (
  input  wire inclk0,
  output wire c0,      // 100 MHz (derived from dll_clk2x)
  output wire c1,      // 50 MHz  (derived from dll_clk0)
  output wire c2,      // 50 MHz  (derived from clk_div2_from_c0)
  output wire locked
);

// Internal wires
wire pll_clkfx;      // Output from first DCM (intended 50MHz)
wire pll_locked;     // Locked signal from first DCM (unused in final output)

wire dll_clk0;       // 50 MHz from second DCM
wire dll_clk2x;      // 100 MHz from second DCM
wire dll_locked;     // Locked signal from second DCM (used for final output)

reg  clk_div2_from_c0 = 1'b0; // Register for clock division

// Instance 1: Frequency Synthesizer (using CLKFX)
// Input: inclk0 (66.6 MHz, Period 15.015 ns)
// Output: pll_clkfx (Target: 66.6 * 24 / 32 = 49.95 MHz, Period ~20ns)
DCM #(
  .CLKDV_DIVIDE(2.0),           // Parameter default, not directly used here
  .CLKFX_DIVIDE(32),
  .CLKFX_MULTIPLY(24),
  .CLKIN_DIVIDE_BY_2("FALSE"),
  .CLKIN_PERIOD(15.015),
  .CLKOUT_PHASE_SHIFT("NONE"),
  .CLK_FEEDBACK("NONE"),        // Only using CLKFX for frequency synthesis
  .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // May not be relevant if CLK_FEEDBACK is NONE
  .DFS_FREQUENCY_MODE("LOW"),
  .DLL_FREQUENCY_MODE("LOW"),
  .DUTY_CYCLE_CORRECTION("TRUE"),
  .FACTORY_JF(16'h8080),
  .PHASE_SHIFT(0),
  .STARTUP_WAIT("TRUE")
) pll (
  // Inputs
  .CLKIN(inclk0),
  .CLKFB(1'b0),           // Not used with CLK_FEEDBACK("NONE"), tie low
  .RST(1'b0),             // Tie reset low (active high reset)
  .PSEN(1'b0),            // Tie phase shift enable low
  .PSINCDEC(1'b0),        // Tie phase shift inc/dec low
  .PSCLK(1'b0),           // Tie phase shift clock low
  // Outputs
  .CLKFX(pll_clkfx),      // Used output (~50 MHz)
  .LOCKED(pll_locked),    // Locked signal of this DCM
  .CLK0(),                // Unconnected output
  .CLK90(),               // Unconnected output
  .CLK180(),              // Unconnected output
  .CLK270(),              // Unconnected output
  .CLK2X(),               // Unconnected output
  .CLK2X180(),            // Unconnected output
  .CLKDV(),               // Unconnected output
  .CLKFX180(),            // Unconnected output
  .STATUS(),              // Unconnected output
  .PSDONE()               // Unconnected output
);

// Instance 2: Clock Deskew/Multiplier
// Input: pll_clkfx (~50 MHz, Period 20.020 ns)
// Outputs: dll_clk0 (50 MHz), dll_clk2x (100 MHz)
DCM #(
  .CLKDV_DIVIDE(2.0),           // Parameter default, not directly used here
  .CLKFX_DIVIDE(1),             // Parameter default, not directly used here
  .CLKFX_MULTIPLY(4),           // Parameter default, not directly used here
  .CLKIN_DIVIDE_BY_2("FALSE"),
  .CLKIN_PERIOD(20.020),        // Input period from pll_clkfx
  .CLKOUT_PHASE_SHIFT("NONE"),
  .CLK_FEEDBACK("1X"),          // Use CLK0 output for feedback
  .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
  .DFS_FREQUENCY_MODE("LOW"),
  .DLL_FREQUENCY_MODE("LOW"),
  .DUTY_CYCLE_CORRECTION("TRUE"),
  .FACTORY_JF(16'h8080),
  .PHASE_SHIFT(0),
  .STARTUP_WAIT("TRUE")
) dll (
  // Inputs
  .CLKIN(pll_clkfx),      // Input clock (~50 MHz)
  .CLKFB(dll_clk0),       // Feedback from CLK0 output (connect CLK0 back to CLKFB)
  .RST(1'b0),             // Tie reset low (active high reset)
  .PSEN(1'b0),            // Tie phase shift enable low
  .PSINCDEC(1'b0),        // Tie phase shift inc/dec low
  .PSCLK(1'b0),           // Tie phase shift clock low
  // Outputs
  .CLK0(dll_clk0),        // 50 MHz output (used for feedback and c1)
  .CLK2X(dll_clk2x),      // 100 MHz output (used for c0)
  .LOCKED(dll_locked),    // Locked output signal for this DCM
  .CLK90(),               // Unconnected output
  .CLK180(),              // Unconnected output
  .CLK270(),              // Unconnected output
  .CLK2X180(),            // Unconnected output
  .CLKDV(),               // Unconnected output
  .CLKFX(),               // Unconnected output
  .CLKFX180(),            // Unconnected output
  .STATUS(),              // Unconnected output
  .PSDONE()               // Unconnected output
);

// Clock divider: Generate 50 MHz from c0 (100 MHz) using a toggle flip-flop
// Note: Output is 50 MHz. Original name 'clk_25' was misleading.
always @ (posedge c0) begin
  clk_div2_from_c0 <= ~clk_div2_from_c0;
end

// Output buffers for driving global clock networks
BUFG BUFG_100 (.I(dll_clk2x), .O(c0));        // 100 MHz global clock output
BUFG BUFG_50  (.I(dll_clk0),  .O(c1));        // 50 MHz global clock output
BUFG BUFG_DIV2 (.I(clk_div2_from_c0), .O(c2)); // 50 MHz derived global clock output

// Assign overall locked status based on the second (main) DCM
assign locked = dll_locked;

endmodule