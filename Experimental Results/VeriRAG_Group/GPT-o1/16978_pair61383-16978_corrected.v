`timescale 1ps/1ps
`timescale 1ps/1ps
module Clock70MHz_exdes 
 #(
  parameter TCQ = 100
 )
 (
  input         test_mode_i,
  input         scan_chain_clk_i,
  input         scan_chain_rst_i,
  input         CLK_IN1,
  input         COUNTER_RESET,
  output [1:1]  CLK_OUT,
  output        COUNT,
  output        LOCKED
 );
  localparam    C_W = 16;
  wire          reset_int;
  wire          clk_dft;
  wire          reset_dft;
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2;
  wire          clk_int;
  wire          clk_n;
  wire          clk;
  reg  [C_W-1:0] counter;
  assign reset_int = !LOCKED || COUNTER_RESET;
  assign clk_dft   = test_mode_i ? scan_chain_clk_i : clk;
  assign reset_dft = test_mode_i ? scan_chain_rst_i : reset_int;
  Clock70MHz clknetwork
   (
    .CLK_IN1  (CLK_IN1),
    .CLK_OUT1 (clk_int),
    .LOCKED   (LOCKED)
   );
  assign clk   = clk_int;
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
  always @(posedge reset_dft or posedge clk_dft) begin
    if (reset_dft) begin
      rst_sync       <= 1'b1;
      rst_sync_int   <= 1'b1;
      rst_sync_int1  <= 1'b1;
      rst_sync_int2  <= 1'b1;
    end else begin
      rst_sync       <= 1'b0;
      rst_sync_int   <= rst_sync;     
      rst_sync_int1  <= rst_sync_int; 
      rst_sync_int2  <= rst_sync_int1;
    end
  end
  always @(posedge clk_dft or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b0 } };
    end else begin
      counter <= #TCQ counter + 1'b1;
    end
  end
  assign COUNT = counter[C_W-1];
endmodule