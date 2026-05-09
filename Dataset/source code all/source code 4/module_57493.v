`timescale 1ps/1ps
`timescale 1ps/1ps
module bclk_dll_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  input         RESET,
  output        LOCKED
 );
  localparam    C_W       = 16;
  wire          reset_int = !LOCKED || RESET || COUNTER_RESET;
   reg rst_sync;
   reg rst_sync_int;
   reg rst_sync_int1;
   reg rst_sync_int2;
  wire           clk_int;
  wire           clk;
  reg  [C_W-1:0] counter;
  BUFG clkin1_buf
   (.O (clk_in1_buf),
    .I (CLK_IN1));
  bclk_dll clknetwork
   (
    .clk133in            (clk_in1_buf),
    .clk133           (clk_int),
    .RESET              (RESET),
    .LOCKED             (LOCKED));
  assign CLK_OUT[1] =  clk_int;
  assign clk = clk_int;
    always @(posedge reset_int or posedge clk) begin
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
  always @(posedge clk or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b 0 } };
    end else begin
      counter <= #TCQ counter + 1'b 1;
    end
  end
  assign COUNT = counter[C_W-1];
endmodule
