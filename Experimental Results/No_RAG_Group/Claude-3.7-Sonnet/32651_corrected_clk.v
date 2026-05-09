`timescale 1ps/1ps
module Clock65MHz_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input         CLK_SCAN, // Added scan clock input
  input         SCAN_MODE, // Added scan mode control
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
  wire          clk_int;
  wire          clk_n;
  wire          clk;
  wire          gated_clk;
  reg  [C_W-1:0] counter;

  Clock65MHz clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED));

  // Clock mux for scan mode
  assign gated_clk = SCAN_MODE ? CLK_SCAN : clk_int;
  assign clk = gated_clk;
  assign clk_n = ~clk;

  ODDR2 clkout_oddr
   (.Q  (CLK_OUT[1]),
    .C0 (CLK_IN1),  // Using primary input clock
    .C1 (~CLK_IN1), // Using inverted primary input clock
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

  always @(posedge CLK_IN1 or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b0 } };
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  assign COUNT = counter[C_W-1];
endmodule