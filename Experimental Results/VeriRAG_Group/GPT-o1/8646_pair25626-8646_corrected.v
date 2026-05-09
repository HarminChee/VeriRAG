`timescale 1ps/1ps
`timescale 1ps/1ps
module clk_wiz_v3_6_exdes 
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

  wire          clk_in1_buf;
  wire          clk_int;
  wire          reset_int = COUNTER_RESET;
  wire          dft_clk;
  reg           rst_sync;
  reg           rst_sync_int;
  reg           rst_sync_int1;
  reg           rst_sync_int2;
  reg  [C_W-1:0] counter;

  assign dft_clk = test_i ? CLK_IN1 : clk_int;

  BUFG clkin1_buf_inst
   (
    .O (clk_in1_buf),
    .I (CLK_IN1)
   );

  clk_wiz_v3_6 clknetwork
   (
    .clk      (clk_in1_buf),
    .clk_20MHz(clk_int)
   );

  ODDR2 clkout_oddr
   (
    .Q  (CLK_OUT[1]),
    .C0 (dft_clk),
    .C1 (~dft_clk),
    .CE (1'b1),
    .D0 (1'b1),
    .D1 (1'b0),
    .R  (1'b0),
    .S  (1'b0)
   );

  always @(posedge reset_int or posedge dft_clk) begin
    if (reset_int) begin
      rst_sync      <= 1'b1;
      rst_sync_int  <= 1'b1;
      rst_sync_int1 <= 1'b1;
      rst_sync_int2 <= 1'b1;
    end
    else begin
      rst_sync      <= 1'b0;
      rst_sync_int  <= rst_sync;
      rst_sync_int1 <= rst_sync_int;
      rst_sync_int2 <= rst_sync_int1;
    end
  end

  always @(posedge dft_clk or posedge rst_sync_int2) begin
    if (rst_sync_int2) begin
      counter <= #TCQ { C_W { 1'b0 } };
    end 
    else begin
      counter <= #TCQ counter + 1'b1;
    end
  end

  assign COUNT = counter[C_W-1];

endmodule