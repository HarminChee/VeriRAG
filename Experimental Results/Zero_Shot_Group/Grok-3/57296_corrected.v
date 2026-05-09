`timescale 1ps/1ps
module clk32to40_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT
 );
  localparam    C_W       = 16;
  wire          reset_int = COUNTER_RESET;
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2;
  wire          clk_int;
  wire          clk_n;
  wire          clk;

  reg  [C_W-1:0] counter;

  clk32to40 clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int)
   );

  assign clk = clk_int;
  assign clk_n = ~clk;

  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0)
   );

  always @(posedge clk or posedge reset_int) begin
    if (reset_int) begin
      rst_sync <= #TCQ 1'b1;
      rst_sync_int <= #TCQ 1'b1;
      rst_sync_int1 <= #TCQ 1'b1;
      rst_sync_int2 <= #TCQ 1'b1;
    end else begin
      rst_sync <= #TCQ 1'b0;
      rst_sync_int <= #TCQ rst_sync;     
      rst_sync_int1 <= #TCQ rst_sync_int; 
      rst_sync_int2 <= #TCQ rst_sync_int1;
    end
  end

  always @(posedge clk or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ {C_W{1'b0}};
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule