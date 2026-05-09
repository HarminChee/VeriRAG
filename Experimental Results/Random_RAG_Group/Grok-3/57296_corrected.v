`timescale 1ps/1ps
module clk32to40_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input         test_i,
  output [1:1]  CLK_OUT,
  output        COUNT
 );
  localparam    C_W       = 16;
  wire          reset_int = COUNTER_RESET;
  wire          dft_reset;
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2;
  wire          clk_int;
  wire          clk_n;
  wire          clk;
  wire          dft_clk;
  reg  [C_W-1:0] counter;

  clk32to40 clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int)
   );

  assign clk_n = ~clk;
  assign dft_clk = test_i ? CLK_IN1 : clk;
  assign dft_reset = test_i ? reset_int : rst_sync_int2;

  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));

  assign clk = clk_int;

  always @(posedge dft_reset or posedge dft_clk) begin
    if (dft_reset) begin
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

  always @(posedge dft_clk or posedge dft_reset) begin
    if (dft_reset) begin
      counter <= #TCQ { C_W { 1'b0 } };
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  assign COUNT = counter[C_W-1];
endmodule