`timescale 1ps/1ps
module Clock65MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET, // Functional reset input
  input         test_i,        // Test mode enable
  input         test_clk_i,    // Test clock input
  // Assuming COUNTER_RESET can also serve as test reset
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;

  // Internal functional signals
  wire           clk_int; // Functional clock from PLL/MMCM
  wire           clk;     // Functional clock used internally
  wire           clk_n;   // Inverted functional clock
  wire           func_reset_int; // Functional reset condition

  // DFT signals
  wire           dft_clk;         // Muxed clock for DFT
  wire           dft_clk_n;       // Inverted muxed clock
  wire           reset_for_sync;  // Muxed reset for synchronizer

  // Reset synchronizer registers (synchronous reset)
  reg rst_sync;
  reg rst_sync_int;
  reg rst_sync_int1;
  reg rst_sync_int2; // Synchronized reset signal

  // Counter register
  reg  [C_W-1:0] counter;

  // Instantiate the clock generator
  Clock65MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED)
   );

  // Assign functional clock
  assign clk = clk_int;
  assign clk_n = ~clk; // Functional inverted clock

  // Define functional reset condition
  assign func_reset_int = !LOCKED || COUNTER_RESET;

  // DFT MUX for clock (CLKNPI fix)
  assign dft_clk = test_i ? test_clk_i : clk;
  assign dft_clk_n = test_i ? ~test_clk_i : clk_n; // Muxed inverted clock

  // DFT MUX for reset synchronizer input (ACNCPI fix - using synchronous reset)
  // Use COUNTER_RESET as the primary reset source during test mode
  assign reset_for_sync = test_i ? COUNTER_RESET : func_reset_int;

  // Reset Synchronizer (using synchronous reset and dft_clk)
  always @(posedge dft_clk) begin
     if (reset_for_sync) begin // Synchronous reset
          rst_sync <= #TCQ 1'b1;
          rst_sync_int <= #TCQ 1'b1;
          rst_sync_int1 <= #TCQ 1'b1;
          rst_sync_int2 <= #TCQ 1'b1;
     end
     else begin
          rst_sync <= #TCQ 1'b0;
          rst_sync_int <= #TCQ rst_sync;
          rst_sync_int1 <= #TCQ rst_sync_int;
          rst_sync_int2 <= #TCQ rst_sync_int1;
     end
  end

  // Counter (using synchronous reset rst_sync_int2 and dft_clk)
  always @(posedge dft_clk) begin
    if (rst_sync_int2) begin // Synchronous reset from synchronized source
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  // Output driver (ODDR) using muxed clock
  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]),
    .C0 (dft_clk),     // Use muxed clock
    .C1 (dft_clk_n),   // Use muxed inverted clock
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),       // Assuming ODDR reset is handled elsewhere or not needed for DFT scan
    .S  (1'b0)        // Assuming ODDR set is handled elsewhere or not needed for DFT scan
   );

  // Assign counter output
  assign COUNT = counter[C_W-1];

endmodule