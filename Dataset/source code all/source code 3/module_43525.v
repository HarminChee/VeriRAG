`timescale 1ps/1ps
`timescale 1ps/1ps
module ad_csc_1_mul (
  clk,
  data_a,
  data_b,
  data_p,
  ddata_in,
  ddata_out);
  parameter   DELAY_DATA_WIDTH = 16;
  localparam  DW = DELAY_DATA_WIDTH - 1;
  input           clk;
  input   [16:0]  data_a;
  input   [ 7:0]  data_b;
  output  [24:0]  data_p;
  input   [DW:0]  ddata_in;
  output  [DW:0]  ddata_out;
  reg     [DW:0]  p1_ddata = 'd0;
  reg     [DW:0]  p2_ddata = 'd0;
  reg     [DW:0]  ddata_out = 'd0;
  reg             p1_sign = 'd0;
  reg             p2_sign = 'd0;
  reg             sign_p = 'd0;
  wire    [25:0]  data_p_s;
  always @(posedge clk) begin
    p1_ddata <= ddata_in;
    p2_ddata <= p1_ddata;
    ddata_out <= p2_ddata;
  end
  always @(posedge clk) begin
    p1_sign <= data_a[16];
    p2_sign <= p1_sign;
    sign_p <= p2_sign;
  end
  assign data_p = {sign_p, data_p_s[23:0]};
  MULT_MACRO #(
    .LATENCY (3),
    .WIDTH_A (17),
    .WIDTH_B (9))
  i_mult_macro (
    .CE (1'b1),
    .RST (1'b0),
    .CLK (clk),
    .A ({1'b0, data_a[15:0]}),
    .B ({1'b0, data_b}),
    .P (data_p_s));
endmodule
