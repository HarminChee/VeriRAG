`timescale 1ps/1ps
`timescale 1ps/1ps
module Clock70MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         test_i, // Added test mode signal
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;
  wire          reset_int = !LOCKED || COUNTER_RESET;
   reg rst_sync;
   reg rst_sync_int;
   reg rst_sync_int1;
   reg rst_sync_int2;
  wire           clk_int;
  wire           clk_n;
  wire           clk;
  wire           dft_clk; // DFT clock
  wire           dft_clk_n; // Inverted DFT clock
  wire           dft_reset; // DFT reset for synchronizer
  wire           dft_counter_reset; // DFT reset for counter

  reg  [C_W-1:0] counter;

  // DFT Mux for Clock
  assign dft_clk = test_i ? CLK_IN1 : clk;
  assign dft_clk_n = ~dft_clk;

  // DFT Mux for Resets (Assuming Active High Reset based on original posedge usage)
  assign dft_reset = test_i ? COUNTER_RESET : reset_int;
  assign dft_counter_reset = test_i ? COUNTER_RESET : rst_sync_int2;


  Clock70MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED));

  assign clk_n = ~clk; // Functional inverted clock

  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (dft_clk),   // Use DFT clock
    .C1 (dft_clk_n), // Use inverted DFT clock
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),      // Assuming synchronous operation or external DFT reset handling for ODDR
    .S  (1'b0));

  assign clk = clk_int; // Functional clock assignment

    // Reset Synchronizer Flops
    // Using DFT clock and DFT reset
    always @(posedge dft_clk or posedge dft_reset) begin // Use DFT clock and DFT reset
       if (dft_reset) begin // Use DFT reset condition
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

  // Counter Flop
  // Using DFT clock and DFT counter reset
  always @(posedge dft_clk or posedge dft_counter_reset) begin // Use DFT clock and DFT counter reset
    if (dft_counter_reset) begin // Use DFT counter reset condition
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule