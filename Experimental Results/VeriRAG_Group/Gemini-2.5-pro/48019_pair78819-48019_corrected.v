`timescale 1ps/1ps
`timescale 1ps/1ps
module dcm_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         test_i,         // DFT test mode signal
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT
 );
  localparam    C_W       = 16;
  wire          reset_int = COUNTER_RESET;
   reg rst_sync;
   reg rst_sync_int;
   reg rst_sync_int1;
   reg rst_sync_int2;
  wire           clk_int;
  wire           clk_n;
  wire           clk;
  reg  [C_W-1:0] counter;

  // DFT clock signal
  wire           dft_clk;
  assign dft_clk = test_i ? CLK_IN1 : clk;
  wire           dft_clk_n = ~dft_clk;

  dcm clknetwork
   (
    .CLK_IN            (CLK_IN1),
    .CLK_OUT           (clk_int));

  assign clk_n = ~clk; // Functional inverted clock

  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (dft_clk),      // Use DFT clock
    .C1 (dft_clk_n),    // Use inverted DFT clock
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),         // Assuming synchronous reset or no reset needed here based on original
    .S  (1'b0));

  assign clk = clk_int;

    // Reset synchronizer - uses primary reset and DFT clock
    always @(posedge reset_int or posedge dft_clk) begin // Use DFT clock
       if (reset_int) begin // Async reset from primary input derivative - OK
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

  // Counter - uses primary reset and DFT clock
  always @(posedge dft_clk or posedge reset_int) begin // Use DFT clock and primary reset
    if (reset_int) begin // Use primary reset directly - Fixes ACNCPI
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule