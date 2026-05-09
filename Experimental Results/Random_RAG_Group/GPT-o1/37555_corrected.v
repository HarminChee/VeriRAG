`timescale 1ps/1ps
`timescale 1ps/1ps
module SystemClockUnit_exdes 
 #( 
  parameter TCQ = 100
  )
 (
  input         CLK_IN1,
  input         COUNTER_RESET,
  input         scan_clk,
  input         test_i,
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );

  localparam    C_W       = 16;
  wire          reset_int;
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2;
  wire          clk_int;
  wire          dft_clk;
  wire          clk_n;
  reg  [C_W-1:0] counter;

  SystemClockUnit clknetwork
   (
    .CLK_IN1            (CLK_IN1),
    .CLK_OUT1           (clk_int),
    .LOCKED             (LOCKED)
   );

  assign reset_int = COUNTER_RESET;
  assign dft_clk = test_i ? scan_clk : clk_int;
  assign clk_n = ~dft_clk;

  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]),
    .C0 (dft_clk),
    .C1 (clk_n),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0)
   );

  always @(posedge reset_int or posedge dft_clk) begin
    if (reset_int) begin
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

  always @(posedge dft_clk) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b0 } };
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule