`timescale 1ps/1ps
`timescale 1ps/1ps
module ad_mul #(
  parameter   A_DATA_WIDTH = 17,
  parameter   B_DATA_WIDTH = 17,
  parameter   DELAY_DATA_WIDTH = 16) (
  input                                     clk,
  input   [               A_DATA_WIDTH-1:0] data_a,
  input   [               B_DATA_WIDTH-1:0] data_b,
  output  [A_DATA_WIDTH + B_DATA_WIDTH-1:0] data_p,
  input       [(DELAY_DATA_WIDTH-1):0]  ddata_in,
  output  reg [(DELAY_DATA_WIDTH-1):0]  ddata_out);
  reg     [(DELAY_DATA_WIDTH-1):0]    p1_ddata = 'd0;
  reg     [(DELAY_DATA_WIDTH-1):0]    p2_ddata = 'd0;
  always @(posedge clk) begin
    p1_ddata <= ddata_in;
    p2_ddata <= p1_ddata;
    ddata_out <= p2_ddata;
  end
  lpm_mult #(
    .lpm_type ("lpm_mult"),
    .lpm_widtha (A_DATA_WIDTH),
    .lpm_widthb (B_DATA_WIDTH),
    .lpm_widthp (A_DATA_WIDTH + B_DATA_WIDTH),
    .lpm_representation ("SIGNED"),
    .lpm_pipeline (3))
  i_lpm_mult (
    .clken (1'b1),
    .aclr (1'b0),
    .sclr (1'b0),
    .sum (1'b0),
    .clock (clk),
    .dataa (data_a),
    .datab (data_b),
    .result (data_p));
endmodule
