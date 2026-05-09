`timescale 1ps/1ps
module Clock65MHz_exdes_corrected
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,         // Primary clock input
  input         COUNTER_RESET,   // Functional reset
  input         scan_mode,       // Scan mode control
  input         scan_reset,      // Scan mode reset (synchronous)
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;

  // Internal signals
  wire          clk_int;         // Clock from generator
  wire          clk_n;
  wire          clk;             // Functional clock (from generator)
  wire          scan_clk;        // Clock selected for flops (Test or Functional)
  wire          locked_internal; // Internal LOCKED signal
  wire          reset_int;       // Functional asynchronous reset condition
  wire          effective_reset; // Reset signal selected based on mode

  // Registers for counter and reset synchronization
  reg  [C_W-1:0] counter;
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2; // Synchronized functional reset

  // Instantiate the clock generator
  Clock65MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (locked_internal)); // Use internal wire for LOCKED

  // Assign functional clock and its inverse
  assign clk = clk_int;
  assign clk_n = ~clk;

  // Assign LOCKED output
  assign LOCKED = locked_internal;

  // Define functional reset condition (asynchronous part)
  assign reset_int = !locked_internal || COUNTER_RESET;

  // Clock MUX for DFT: Select primary clock in scan mode, generated clock otherwise
  assign scan_clk = scan_mode ? CLK_IN1 : clk;

  // Reset MUX for DFT: Select scan reset in scan mode, synchronized functional reset otherwise
  // Note: Using rst_sync_int2 ensures the functional reset used is synchronized
  assign effective_reset = scan_mode ? scan_reset : rst_sync_int2;

  // ODDR for clock output generation (remains clocked by functional clock pair)
  // DFT handling for I/O cells like ODDR often requires specific tool wrappers/strategies
  // Kept as original for this example, focusing on internal flop clocking.
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk),           // Still driven by potentially non-scan clock pair
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),          // Asynchronous resets tied off
    .S  (1'b0));         // Asynchronous sets tied off

  // Synchronizer for the functional reset signal using the scan_clk
  // This block now uses the DFT-muxed clock and handles reset synchronously.
  always @(posedge scan_clk) begin
     // Use functional asynchronous reset signal (reset_int) as input to synchronizer chain
     // The actual reset logic for downstream flops uses 'effective_reset'
     if (reset_int) begin // Use the raw functional reset condition to start the sync chain high
          rst_sync <= 1'b1;
          rst_sync_int <= 1'b1;
          rst_sync_int1 <= 1'b1;
          rst_sync_int2 <= 1'b1;
     end
     else begin // Deassert synchronously
          rst_sync <= 1'b0;
          rst_sync_int <= rst_sync;
          rst_sync_int1 <= rst_sync_int;
          rst_sync_int2 <= rst_sync_int1;
     end
  end

  // Counter logic, clocked by scan_clk and reset synchronously by effective_reset
  always @(posedge scan_clk) begin
    if (effective_reset) begin // Use the mode-selected synchronous reset
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  // Assign counter output
  assign COUNT = counter[C_W-1];

endmodule

// Note: The definition of Clock65MHz module is assumed to exist elsewhere
// and is treated as a black box generating clk_int and locked_internal.
// Proper DFT integration might require a wrapper around Clock65MHz
// to bypass it or control its state during scan mode.