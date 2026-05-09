`timescale 1ps/1ps
module dcm_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // Asynchronous reset input
  input         TEST_MODE,     // Test mode control input
  output [1:1]  CLK_OUT,
  output        COUNT
 );
  localparam    C_W       = 16;

  // Internal signals
  wire           clk_int;       // Clock from DCM
  wire           clk;           // Functional clock
  wire           clk_n;         // Inverted functional clock
  wire           scan_clk;      // Clock used for FFs (muxed)

  reg            rst_meta;      // Reset synchronizer stage 1
  reg            rst_sync;      // Reset synchronizer stage 2 (synchronous reset)

  reg  [C_W-1:0] counter;

  // Clock Generation (DCM) - Assuming 'dcm' is a predefined module/primitive
  dcm clknetwork
   (
    .CLK_IN            (CLK_IN1),
    .CLK_OUT           (clk_int)
   );

  assign clk = clk_int;
  assign clk_n = ~clk;

  // Clock Mux for Testability
  // Selects primary clock CLK_IN1 during test mode, functional clock clk otherwise
  assign scan_clk = TEST_MODE ? CLK_IN1 : clk;

  // Output Driver (ODDR) - clocked by functional clock
  // Assuming 'ODDR2' is a predefined module/primitive
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0)
   );

  // Reset Synchronizer (using scan_clk)
  // Synchronizes the asynchronous COUNTER_RESET to the scan_clk domain
  always @(posedge scan_clk) begin
      rst_meta <= #TCQ COUNTER_RESET;
      rst_sync <= #TCQ rst_meta; // rst_sync is the synchronous reset signal
  end

  // Counter Logic (using scan_clk and synchronous reset)
  always @(posedge scan_clk) begin
    if (rst_sync) begin // Synchronous reset
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  // Output Assignment
  assign COUNT = counter[C_W-1];

endmodule

// Note: The definitions for 'dcm' and 'ODDR2' modules are assumed to exist elsewhere
// (e.g., in a technology library) and are not included here as they were not
// part of the original code provided for modification.