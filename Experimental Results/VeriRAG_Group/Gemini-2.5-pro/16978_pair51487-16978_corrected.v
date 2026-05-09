`timescale 1ps/1ps
module Clock70MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         test_i, scan_clk, IO_RESET, // Added DFT inputs
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;
  wire          reset_int = !LOCKED || COUNTER_RESET;
  wire          dft_reset; // DFT reset signal
  wire          dft_clk;   // DFT clock signal
   reg rst_sync;
   reg rst_sync_int;
   reg rst_sync_int1;
   reg rst_sync_int2;
  wire           clk_int;
  wire           clk_n;
  wire           clk;
  reg  [C_W-1:0] counter;

  // DFT Logic: Select functional reset or test reset
  assign dft_reset = test_i ? IO_RESET : reset_int;

  Clock70MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED));

  // DFT Logic: Select functional clock or test clock
  assign clk = clk_int;
  assign dft_clk = test_i ? scan_clk : clk;
  assign clk_n = ~clk; // Functional inverted clock for ODDR2

  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]),
    .C0 (dft_clk),         // Use DFT clock
    .C1 (~dft_clk),        // Use inverted DFT clock
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),            // ODDR reset tied low - check if functional reset needed here
    .S  (1'b0));           // ODDR set tied low

    // Reset synchronizer flops - use DFT reset and DFT clock
    always @(posedge dft_clk or posedge dft_reset) begin // Use dft_clk and dft_reset
       if (dft_reset) begin // Use dft_reset
            rst_sync <= 1'b1;
            rst_sync_int <= 1'b1;
            rst_sync_int1 <= 1'b1;
            rst_sync_int2 <= 1'b1;
       end
       else begin
            rst_sync <= 1'b0;
            rst_sync_int <= rst_sync;
            rst_sync_int1 <= rst_sync_int;
            rst_sync_int2 <= rst_sync_int1;
       end
    end

  // Counter flop - use DFT reset and DFT clock
  always @(posedge dft_clk or posedge dft_reset) begin // Use dft_clk and dft_reset
    if (dft_reset) begin // Use direct DFT reset for testability
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];
endmodule