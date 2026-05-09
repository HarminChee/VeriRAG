`timescale 1ps/1ps
// File: 1_corrected_clk.v
module Clock35MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,         // Primary Clock Input (used as test clock)
  input         COUNTER_RESET,   // Functional asynchronous reset input
  input         scan_en,         // Scan enable signal
  input         test_reset,      // Synchronous test reset signal (active high)
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED           // Output from Clock35MHz module
 );

  localparam C_W = 16;

  // Internal signals
  wire          clk_int;         // Clock from Clock35MHz module
  wire          clk;             // Functional clock derived from clk_int
  wire          clk_n;           // Inverted functional clock
  wire          func_reset_async; // Asynchronous functional reset condition
  wire          effective_clk;   // Clock selected for FF based on scan_en
  wire          effective_oddr_clk0; // Clock for ODDR C0
  wire          effective_oddr_clk1; // Clock for ODDR C1

  // Reset synchronization registers
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2; // Synchronized functional reset

  // Counter register
  reg  [C_W-1:0] counter;

  // Instantiate the clock generator
  Clock35MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int), // Generated clock output
    .LOCKED             (LOCKED)   // Lock status output
   );

  // Assign functional clock and its inverse
  assign clk = clk_int;
  assign clk_n = ~clk;

  // Select the effective clock for FFs based on scan mode
  // Use primary clock CLK_IN1 during scan, functional clock 'clk' otherwise
  assign effective_clk = scan_en ? CLK_IN1 : clk;

  // Define asynchronous functional reset condition
  assign func_reset_async = !LOCKED || COUNTER_RESET;

  // Reset Synchronizer Logic (using effective_clk)
  // Synchronizes the asynchronous functional reset source 'func_reset_async'.
  // Overridden by synchronous 'test_reset' during scan mode.
  always @(posedge effective_clk) begin
    if (scan_en && test_reset) begin // Use synchronous test reset in scan mode
         rst_sync <= #TCQ 1'b1;
         rst_sync_int <= #TCQ 1'b1;
         rst_sync_int1 <= #TCQ 1'b1;
         rst_sync_int2 <= #TCQ 1'b1; // Synchronized reset output asserted
    end else begin
         // In functional mode or when test_reset is inactive during scan,
         // synchronize the functional reset condition.
         rst_sync <= #TCQ func_reset_async; // Capture async reset source
         rst_sync_int <= #TCQ rst_sync;
         rst_sync_int1 <= #TCQ rst_sync_int;
         rst_sync_int2 <= #TCQ rst_sync_int1; // rst_sync_int2 is the synchronized functional reset
    end
  end

  // Counter Logic (using effective_clk and synchronous reset)
  // The reset source depends on scan_en: test_reset during scan, rst_sync_int2 otherwise.
  always @(posedge effective_clk) begin
    // Use synchronous reset: test_reset in scan mode, synchronized functional reset otherwise
    if (scan_en ? test_reset : rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      // Increment counter when not in reset
      counter <= #TCQ counter + 1'b 1;
    end
  end

  // Assign counter output
  assign COUNT = counter[C_W-1];

  // ODDR2 Output Driver
  // Mux the clock inputs based on scan_en
  assign effective_oddr_clk0 = scan_en ? CLK_IN1 : clk;
  assign effective_oddr_clk1 = scan_en ? ~CLK_IN1 : clk_n;

  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),           // Output port
    .C0 (effective_oddr_clk0), // Muxed Clock input
    .C1 (effective_oddr_clk1), // Muxed Inverted Clock input
    .CE (1'b1),                // Clock Enable (tied high)
    .D0 (1'b1),                // Data input for C0 edge
    .D1 (1'b0),                // Data input for C1 edge
    .R  (1'b0),                // Asynchronous Reset (tied low)
    .S  (1'b0));               // Asynchronous Set (tied low)

endmodule