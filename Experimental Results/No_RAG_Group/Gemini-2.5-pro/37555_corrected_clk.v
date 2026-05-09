`timescale 1ps/1ps
module SystemClockUnit_exdes_corrected_clk
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,         // Primary clock input
  input         reset_n,         // Primary synchronous reset input (active low)
  input         test_mode,       // Test mode select signal
  input         COUNTER_RESET,   // Original counter reset input (functionality preserved if needed)
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED           // Output from SystemClockUnit
 );
  localparam    C_W       = 16;

  // Internal signals
  wire          clk_int;         // Clock from PLL/Clock Unit
  wire          clk;             // Functional clock (derived from clk_int)
  wire          clk_n;           // Inverted functional clock
  wire          ff_clk;          // Muxed clock for FFs (functional or test clock)
  wire          sync_reset;      // Synchronous reset signal (active high) derived from reset_n

  reg  [C_W-1:0] counter;
  reg           rst_sync_1;      // Reset synchronizer stages
  reg           rst_sync_2;

  // Instantiate the clock generation unit
  SystemClockUnit clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED)
   );

  // Assign functional clock and its inverse
  assign clk = clk_int;
  assign clk_n = ~clk;

  // Select clock source based on test_mode
  // Use primary input CLK_IN1 as the test clock for scan compatibility
  assign ff_clk = test_mode ? CLK_IN1 : clk;

  // Synchronize the active-low primary reset using the muxed clock 'ff_clk'
  // This ensures the reset logic works correctly in both functional and test modes
  always @(posedge ff_clk or negedge reset_n) begin
    if (!reset_n) begin
      rst_sync_1 <= 1'b1;
      rst_sync_2 <= 1'b1;
    end else begin
      rst_sync_1 <= 1'b0;
      rst_sync_2 <= rst_sync_1;
    end
  end
  assign sync_reset = rst_sync_2; // Use the synchronized, active high reset

  // ODDR for output clock generation
  // Typically clocked by the functional clock pair for correct output timing.
  // DFT tools often have specific ways to handle I/O DDR elements.
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk),          // Use functional clock 'clk' for C0
    .C1 (clk_n),        // Use inverted functional clock 'clk_n' for C1
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),         // Tie asynchronous reset/set to inactive
    .S  (1'b0));

  // Counter logic - uses muxed clock 'ff_clk' and synchronous reset 'sync_reset'
  // The original COUNTER_RESET functionality based on LOCKED is removed
  // in favor of a standard synchronous primary reset for DFT compliance.
  // If COUNTER_RESET needs to act as a secondary synchronous reset, logic can be added.
  always @(posedge ff_clk) begin
    if (sync_reset) begin // Use active high synchronous reset
      counter <= #TCQ { C_W { 1'b0 } };
    // Example: Add synchronous COUNTER_RESET functionality if required
    // end else if (COUNTER_RESET) begin
    //   counter <= #TCQ { C_W { 1'b0 } };
    end else begin
      // Increment counter only if not reset
      counter <= #TCQ counter + 1'b1;
    end
  end

  assign COUNT = counter[C_W-1];

  // Removed original asynchronous reset logic based on !LOCKED || COUNTER_RESET

endmodule