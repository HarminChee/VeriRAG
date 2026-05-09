`timescale 1ps/1ps
module dcm_exdes 
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
  wire          dft_clk;
  wire          clk_int;
  wire          clk_n;
  wire          clk;
  reg  [C_W-1:0] counter;
  reg            rst_sync;
  reg            rst_sync_int;
  reg            rst_sync_int1; 
  reg            rst_sync_int2;

  dcm clknetwork
   (
    .CLK_IN            (CLK_IN1),
    .CLK_OUT           (clk_int));

  assign clk = clk_int;
  assign clk_n = ~clk;
  assign dft_clk = test_i ? CLK_IN1 : clk;

  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (CLK_IN1),
    .C1 (~CLK_IN1),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));

  always @(posedge CLK_IN1) begin
    if (reset_int) begin
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

  always @(posedge CLK_IN1) begin
    if (reset_int) begin
      counter <= #TCQ { C_W { 1'b0 } };
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule