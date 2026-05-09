module ctrl_clk_xilinx (
  input  wire inclk0,
  input  wire test_clk, // Added for DFT test clock
  input  wire test_i,   // Added for DFT test mode enable
  output wire c0,
  output wire c1,
  output wire c2,
  output wire locked
);
wire pll_50;
wire dll_50;
wire dll_100;
reg  clk_25 = 0;

// Existing DCMs (unchanged)
DCM #(
  .CLKDV_DIVIDE(2.0),
  .CLKFX_DIVIDE(32),
  .CLKFX_MULTIPLY(24),
  .CLKIN_DIVIDE_BY_2("FALSE"),
  .CLKIN_PERIOD(15.015),
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
  .CLKFX(pll_50)
);

DCM #(
  .CLKDV_DIVIDE(2.0),
  .CLKFX_DIVIDE(1),
  .CLKFX_MULTIPLY(4),
  .CLKIN_DIVIDE_BY_2("FALSE"),
  .CLKIN_PERIOD(20.020),
  .CLKOUT_PHASE_SHIFT("NONE"),
  .CLK_FEEDBACK("1X"),
  .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"),
  .DFS_FREQUENCY_MODE("LOW"),
  .DLL_FREQUENCY_MODE("LOW"),
  .DUTY_CYCLE_CORRECTION("TRUE"),
  .FACTORY_JF(16'h8080),
  .PHASE_SHIFT(0),
  .STARTUP_WAIT("TRUE")
) dll (
  .CLKIN(pll_50),
  .CLK0(dll_50),
  .CLK2X(dll_100),
  .CLKFB(c1), // Note: c1 is used as feedback AND output
  .LOCKED(locked)
);

// BUFGs driving outputs c0 and c1 (unchanged)
BUFG  BUFG_100 (.I(dll_100), .O(c0));
BUFG  BUFG_50  (.I(dll_50),  .O(c1));

// DFT Correction for clk_25 generation (CLKNPI/FFCKNP fix)
// Select clock source based on test_i
wire dft_clk_sel_clk25 = test_i ? test_clk : c0;

// Flip-flop for clock division
// Clocked by dft_clk_sel_clk25
// Data path logic active only in functional mode
always @ (posedge dft_clk_sel_clk25) begin
  if (!test_i) begin // Functional mode: Toggle flop
    clk_25 <= #1 ~clk_25;
  end
  // else begin
    // In test mode (test_i=1), this flop is clocked by test_clk.
    // Its data input would be controlled by scan_in via DFT insertion tools.
    // clk_25 <= scan_in; // Example if scan logic were explicit
  // end
end

// BUFG driving output c2 (source flop is now DFT-friendly clocked)
BUFG  BUFG_25  (.I(clk_25),  .O(c2));

endmodule