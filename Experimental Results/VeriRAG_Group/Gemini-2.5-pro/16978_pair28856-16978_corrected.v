`timescale 1ps/1ps
`timescale 1ps/1ps
module Clock70MHz_exdes
 #(
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  // DFT Inputs
  input         test_mode,
  input         test_clk,
  input         dft_reset, // DFT synchronous reset (active high)
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;

  // Internal functional clock
  wire           clk_int;
  wire           clk;
  // DFT clock selection
  wire           dft_clk;
  wire           dft_clk_n;

  // Synchronous reset logic
  reg            sync_reset_reg;

  reg  [C_W-1:0] counter;
  wire           locked_internal; // Use internal wire for LOCKED

  Clock70MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (locked_internal)); // Connect to internal wire

  assign LOCKED = locked_internal; // Assign to output port

  assign clk = clk_int;

  // DFT Clock MUX: Selects test_clk in test_mode, otherwise functional clk
  assign dft_clk = test_mode ? test_clk : clk;
  assign dft_clk_n = ~dft_clk;

  // Synchronous Reset Logic: DFT reset overrides functional reset
  // Assumes both dft_reset and COUNTER_RESET are active high
  always @(posedge dft_clk) begin
      if (dft_reset) begin
          sync_reset_reg <= 1'b1;
      end else begin
          sync_reset_reg <= COUNTER_RESET;
      end
  end

  // ODDR for clock output generation, driven by DFT-muxed clock
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (dft_clk),    // Use DFT clock
    .C1 (dft_clk_n),  // Use inverted DFT clock
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),       // Ensure Reset is inactive during operation/test
    .S  (1'b0));      // Ensure Set is inactive during operation/test

  // Counter logic with synchronous reset
  always @(posedge dft_clk) begin
    if (sync_reset_reg) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule