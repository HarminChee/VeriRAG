`timescale 1ps/1ps
`timescale 1ps/1ps
module ad_mul (
  clk,
  data_a,
  data_b,
  data_p,
  ddata_in,
  ddata_out);
  parameter   DELAY_DATA_WIDTH = 16;
  input                               clk;
  input   [16:0]                      data_a;
  input   [16:0]                      data_b;
  output  [33:0]                      data_p;
  input   [(DELAY_DATA_WIDTH-1):0]    ddata_in;
  output  [(DELAY_DATA_WIDTH-1):0]    ddata_out;
  reg     [(DELAY_DATA_WIDTH-1):0]    p1_ddata = 'd0;
  reg     [(DELAY_DATA_WIDTH-1):0]    p2_ddata = 'd0;
  reg     [(DELAY_DATA_WIDTH-1):0]    ddata_out = 'd0;
  always @(posedge clk) begin
    p1_ddata <= ddata_in;
    p2_ddata <= p1_ddata;
    ddata_out <= p2_ddata;
  end
  MULT_MACRO #(
    .LATENCY (3),
    .WIDTH_A (17),
    .WIDTH_B (17))
  i_mult_macro (
    .CE (1'b1),
    .RST (1'b0),
    .CLK (clk),
    .A (data_a),
    .B (data_b),
    .P (data_p));
endmodule
