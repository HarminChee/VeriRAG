`timescale 1ps/1ps
module sdram_clk_gen_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input test_i,
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
  reg           clk_pre;
  reg clk;
  wire dftclk;

  assign dftclk = test_i ? CLK_IN1 : clk_pre;
  reg  [C_W-1:0] counter;
  sdram_clk_gen clknetwork
   (
    .clk_in            (CLK_IN1),
    .clk_out           (clk_int));
  assign clk_n = ~dftclk;
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (dftclk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));
  always @(posedge clk_int)
  begin
    clk_pre <= clk_int;
  end
    always @(posedge CLK_IN1 or posedge reset_int) begin
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
  always @(posedge dftclk or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end
  assign COUNT = counter[C_W-1];
endmodule