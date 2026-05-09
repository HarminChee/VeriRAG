`timescale 1ps/1ps
module Clock70MHz_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [0:0]  CLK_OUT,
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
  reg  [C_W-1:0] counter;
  wire LOCKED;
  Clock70MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED));
  assign clk_n = ~clk;
  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[0]),
    .C0 (clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0));
  assign clk = clk_int;
    always @(posedge clk or posedge reset_int) begin
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
      counter <= { C_W { 1'b 0 } };
    end else begin
      counter <= counter + 1'b 1;
    end
  end
  assign COUNT = counter[C_W-1];
endmodule

module Clock70MHz
(
    input CLK_IN1,
    output CLK_OUT1,
    output reg LOCKED
);

  reg clk_int;

  always @(CLK_IN1) begin
    clk_int <= CLK_IN1;
  end

  assign CLK_OUT1 = clk_int;

  always @(CLK_IN1) begin
    LOCKED <= 1'b1;
  end
endmodule

module ODDR2 (
    input C0,
    input C1,
    input CE,
    input D0,
    input D1,
    input R,
    input S,
    output reg Q
);

  always @(posedge C0 or posedge C1 or posedge R or posedge S) begin
    if (R) begin
      Q <= 1'b0;
    end else if (S) begin
      Q <= 1'b1;
    end else if (CE) begin
      if (C0) begin
        Q <= D0;
      end else if (C1) begin
        Q <= D1;
      end
    end
  end

endmodule