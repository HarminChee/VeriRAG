`timescale 1ps/1ps
module Clock65MHz_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input         test_i,
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W       = 16;
  wire          reset_int = !LOCKED || COUNTER_RESET;
  wire          dft_reset_int;
  wire          clk_int;
  wire          dft_clk_int;
  wire          clk_n;
  wire          clk;
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2;
  reg  [C_W-1:0] counter;

  assign dft_reset_int = test_i ? COUNTER_RESET : reset_int;
  assign dft_clk_int = test_i ? CLK_IN1 : clk_int;

  Clock65MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED));

  assign clk_n = ~clk;
  assign clk = clk_int;

  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));

  always @(posedge dft_reset_int or posedge clk) begin
    if (dft_reset_int) begin
      rst_sync <= 1'b1;
      rst_sync_int <= 1'b1;
      rst_sync_int1 <= 1'b1;
      rst_sync_int2 <= 1'b1;
    end else begin
      rst_sync <= 1'b0;
      rst_sync_int <= rst_sync;     
      rst_sync_int1 <= rst_sync_int; 
      rst_sync_int2 <= rst_sync_int1;
    end
  end

  always @(posedge dft_clk_int or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b0 } };
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  assign COUNT = counter[C_W-1];
endmodule