`timescale 1ns/100ps
`timescale 1ns/100ps
module ad_dds (
  clk,
  dds_format,
  dds_phase_0,
  dds_scale_0,
  dds_phase_1,
  dds_scale_1,
  dds_data);
  input           clk;
  input           dds_format;
  input   [15:0]  dds_phase_0;
  input   [15:0]  dds_scale_0;
  input   [15:0]  dds_phase_1;
  input   [15:0]  dds_scale_1;
  output  [15:0]  dds_data;
  reg     [15:0]  dds_data_int = 'd0;
  reg     [15:0]  dds_data = 'd0;
  wire    [15:0]  dds_data_0_s;
  wire    [15:0]  dds_data_1_s;
  always @(posedge clk) begin
    dds_data_int <= dds_data_0_s + dds_data_1_s;
    dds_data[15:15] <= dds_data_int[15] ^ dds_format;
    dds_data[14: 0] <= dds_data_int[14:0];
  end
  ad_dds_1 i_dds_1_0 (
    .clk (clk),
    .angle (dds_phase_0),
    .scale (dds_scale_0),
    .dds_data (dds_data_0_s));
  ad_dds_1 i_dds_1_1 (
    .clk (clk),
    .angle (dds_phase_1),
    .scale (dds_scale_1),
    .dds_data (dds_data_1_s));
endmodule
