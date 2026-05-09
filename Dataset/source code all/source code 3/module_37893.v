`timescale 1ps/1ps
`timescale 1ps/1ps
module ad_csc_1_mul #(
  parameter   DELAY_DATA_WIDTH = 16) (
  input                             clk,
  input   [16:0]                    data_a,
  input   [ 7:0]                    data_b,
  output  [24:0]                    data_p,
  input   [(DELAY_DATA_WIDTH-1):0]  ddata_in,
  output  [(DELAY_DATA_WIDTH-1):0]  ddata_out);
  reg     [(DELAY_DATA_WIDTH-1):0]  p1_ddata = 'd0;
  reg     [(DELAY_DATA_WIDTH-1):0]  p2_ddata = 'd0;
  reg     [(DELAY_DATA_WIDTH-1):0]  p3_ddata = 'd0;
  reg                               p1_sign = 'd0;
  reg                               p2_sign = 'd0;
  reg                               p3_sign = 'd0;
  wire    [33:0]                    p3_data_s;
  always @(posedge clk) begin
    p1_ddata <= ddata_in;
    p2_ddata <= p1_ddata;
    p3_ddata <= p2_ddata;
  end
  always @(posedge clk) begin
    p1_sign <= data_a[16];
    p2_sign <= p1_sign;
    p3_sign <= p2_sign;
  end
  assign ddata_out = p3_ddata;
  assign data_p = {p3_sign, p3_data_s[23:0]};
  ad_mul ad_mul_1 (
  .clk(clk),
  .data_a({1'b0, data_a[15:0]}),
  .data_b({9'b0, data_b}),
  .data_p(p3_data_s),
  .ddata_in(16'h0),
  .ddata_out());
endmodule
