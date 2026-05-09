`timescale 1ns/100ps
`timescale 1ns/100ps
module ad_dds_1 (
  clk,
  angle,
  scale,
  dds_data);
  input           clk;
  input   [15:0]  angle;
  input   [15:0]  scale;
  output  [15:0]  dds_data;
  reg     [15:0]  dds_data = 'd0;
  wire    [15:0]  sine_s;
  wire    [33:0]  s1_data_s;
  ad_dds_sine #(.DELAY_DATA_WIDTH(1)) i_dds_sine (
    .clk (clk),
    .angle (angle),
    .sine (sine_s),
    .ddata_in (1'b0),
    .ddata_out ());
  ad_mul #(.DELAY_DATA_WIDTH(1)) i_dds_scale (
    .clk (clk),
    .data_a ({sine_s[15], sine_s}),
    .data_b ({scale[15], scale}),
    .data_p (s1_data_s),
    .ddata_in (1'b0),
    .ddata_out ());
  always @(posedge clk) begin
    dds_data <= s1_data_s[29:14];
  end
endmodule
