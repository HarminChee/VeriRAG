`timescale 1ps/1ps
module dcm_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  input         test_i
 );
  localparam    C_W       = 16;
  wire          reset_int;
  wire          rst_sync_dft;
  wire          clk_int;
  wire          clk_n;
  wire          clk;
  wire          clk_dft;
  reg  [C_W-1:0] counter;
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2;

  dcm clknetwork
   (
    .CLK_IN            (CLK_IN1),
    .CLK_OUT           (clk_int));
  assign clk_n = ~clk_int;
  assign reset_int = COUNTER_RESET;
  assign clk = clk_int;
  assign clk_dft = test_i ? CLK_IN1 : clk_int;
  assign rst_sync_dft = test_i ? COUNTER_RESET : rst_sync_int2;

  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));

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

  always @(posedge clk_dft or posedge rst_sync_dft) begin
    if (rst_sync_dft) begin
      counter <= #TCQ { C_W { 1'b0 } };
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end
  assign COUNT = counter[C_W-1];
endmodule