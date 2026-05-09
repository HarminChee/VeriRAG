`timescale 1ps/1ps
`timescale 1ps/1ps
module Clock70MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // Assumed Active High Synchronous Reset Control
  input         TEST_MODE,     // Test Mode signal
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;

  // Internal signals
  wire           clk_int;
  wire           clk_n;
  wire           clk;
  wire           clk_scan;      // Muxed clock for internal FFs
  wire           sync_reset;    // Synchronized reset for internal FFs
  reg  [C_W-1:0] counter;

  // Clock generator instance
  Clock70MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED));

  // Assign functional clock and its inverse
  assign clk = clk_int;
  assign clk_n = ~clk;

  // Select clock source based on TEST_MODE
  // Use primary input clock CLK_IN1 during test mode for scan
  // Use generated clock clk during functional mode
  assign clk_scan = TEST_MODE ? CLK_IN1 : clk;

  // Synchronize the external reset signal to the scan clock domain
  // Creates an active high synchronous reset signal 'sync_reset'
  reg counter_reset_s1, counter_reset_s2;
  always @(posedge clk_scan) begin
      counter_reset_s1 <= COUNTER_RESET;
      counter_reset_s2 <= counter_reset_s1;
  end
  assign sync_reset = counter_reset_s2;

  // Output DDR Flip-Flop - Remains clocked by the functional clock 'clk'
  // Output logic often handled differently in DFT, keeping functional clock here.
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0), // Using asynchronous R/S pins is generally discouraged by DFT, but ODDR2 primitive has them. Assuming tied inactive.
    .S  (1'b0));

  // Counter logic - Now uses muxed scan clock and synchronous reset
  always @(posedge clk_scan) begin // Clocked by scan-compatible clock
    if (sync_reset) begin // Use synchronous reset
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  // Assign counter output
  assign COUNT = counter[C_W-1];

endmodule