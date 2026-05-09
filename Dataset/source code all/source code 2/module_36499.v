`timescale 1ps/1ps
`timescale 1ps/1ps
module ad_mul_u16 (
  clk,
  data_a,
  data_b,
  data_p,
  ddata_in,
  ddata_out);
  parameter   DELAY_DATA_WIDTH = 16;
  localparam  DW = DELAY_DATA_WIDTH - 1;
  input           clk;
  input   [15:0]  data_a;
  input   [15:0]  data_b;
  output  [31:0]  data_p;
  input   [DW:0]  ddata_in;
  output  [DW:0]  ddata_out;
  reg     [DW:0]  p1_ddata = 'd0;
  reg     [DW:0]  p2_ddata = 'd0;
  reg     [DW:0]  ddata_out = 'd0;
  wire    [33:0]  data_p_s;
  always @(posedge clk) begin
    p1_ddata <= ddata_in;
    p2_ddata <= p1_ddata;
    ddata_out <= p2_ddata;
  end
  assign data_p = data_p_s[31:0];
  MULT_MACRO #(
    .LATENCY (3),
    .A_DATA_WIDTH (17),
    .B_DATA_WIDTH (17))
  i_mult_macro (
    .CE (1'b1),
    .RST (1'b0),
    .CLK (clk),
    .A ({1'b0, data_a}),
    .B ({1'b0, data_b}),
    .P (data_p_s));
endmodule
