`timescale 1ns/100ps
`timescale 1ns/100ps
module ad_dds_sine (
  clk,
  angle,
  sine,
  ddata_in,
  ddata_out);
  parameter   DELAY_DATA_WIDTH = 16;
  localparam  DW = DELAY_DATA_WIDTH - 1;
  input             clk;
  input   [ 15:0]   angle;
  output  [ 15:0]   sine;
  input   [ DW:0]   ddata_in;
  output  [ DW:0]   ddata_out;
  reg     [ 33:0]   s1_data_p = 'd0;
  reg     [ 33:0]   s1_data_n = 'd0;
  reg     [ 15:0]   s1_angle = 'd0;
  reg     [ DW:0]   s1_ddata = 'd0;
  reg     [ 18:0]   s2_data_0 = 'd0;
  reg     [ 18:0]   s2_data_1 = 'd0;
  reg     [ DW:0]   s2_ddata = 'd0;
  reg     [ 18:0]   s3_data = 'd0;
  reg     [ DW:0]   s3_ddata = 'd0;
  reg     [ 33:0]   s4_data2_p = 'd0;
  reg     [ 33:0]   s4_data2_n = 'd0;
  reg     [ 16:0]   s4_data1_p = 'd0;
  reg     [ 16:0]   s4_data1_n = 'd0;
  reg     [ DW:0]   s4_ddata = 'd0;
  reg     [ 16:0]   s5_data2_0 = 'd0;
  reg     [ 16:0]   s5_data2_1 = 'd0;
  reg     [ 16:0]   s5_data1 = 'd0;
  reg     [ DW:0]   s5_ddata = 'd0;
  reg     [ 16:0]   s6_data2 = 'd0;
  reg     [ 16:0]   s6_data1 = 'd0;
  reg     [ DW:0]   s6_ddata = 'd0;
  reg     [ 33:0]   s7_data = 'd0;
  reg     [ DW:0]   s7_ddata = 'd0;
  reg     [ 15:0]   sine = 'd0;
  reg     [ DW:0]   ddata_out = 'd0;
  wire    [ 15:0]   angle_s;
  wire    [ 33:0]   s1_data_s;
  wire    [ DW:0]   s1_ddata_s;
  wire    [ 15:0]   s1_angle_s;
  wire    [ 33:0]   s4_data2_s;
  wire    [ DW:0]   s4_ddata_s;
  wire    [ 16:0]   s4_data1_s;
  wire    [ 33:0]   s7_data2_s;
  wire    [ 33:0]   s7_data1_s;
  wire    [ DW:0]   s7_ddata_s;
  assign angle_s = {~angle[15], angle[14:0]};
  ad_mul #(.DELAY_DATA_WIDTH(DELAY_DATA_WIDTH+16)) i_mul_s1 (
    .clk (clk),
    .data_a ({angle_s[15], angle_s}),
    .data_b ({angle_s[15], angle_s}),
    .data_p (s1_data_s),
    .ddata_in ({ddata_in, angle_s}),
    .ddata_out ({s1_ddata_s, s1_angle_s}));
  always @(posedge clk) begin
    s1_data_p <= s1_data_s;
    s1_data_n <= ~s1_data_s + 1'b1;
    s1_angle <= s1_angle_s;
    s1_ddata <= s1_ddata_s;
  end
  always @(posedge clk) begin
    s2_data_0 <= (s1_angle[15] == 1'b0) ? s1_data_n[31:13] : s1_data_p[31:13];
    s2_data_1 <= {s1_angle[15], s1_angle[15:0], 2'b00};
    s2_ddata <= s1_ddata;
  end
  always @(posedge clk) begin
    s3_data <= s2_data_0 + s2_data_1;
    s3_ddata <= s2_ddata;
  end
  ad_mul #(.DELAY_DATA_WIDTH(DELAY_DATA_WIDTH+17)) i_mul_s2 (
    .clk (clk),
    .data_a (s3_data[16:0]),
    .data_b (s3_data[16:0]),
    .data_p (s4_data2_s),
    .ddata_in ({s3_ddata, s3_data[16:0]}),
    .ddata_out ({s4_ddata_s, s4_data1_s}));
  always @(posedge clk) begin
    s4_data2_p <= s4_data2_s;
    s4_data2_n <= ~s4_data2_s + 1'b1;
    s4_data1_p <= s4_data1_s;
    s4_data1_n <= ~s4_data1_s + 1'b1;
    s4_ddata <= s4_ddata_s;
  end
  always @(posedge clk) begin
    s5_data2_0 <= (s4_data1_p[16] == 1'b1) ? s4_data2_n[31:15] : s4_data2_p[31:15];
    s5_data2_1 <= s4_data1_n;
    s5_data1 <= s4_data1_p;
    s5_ddata <= s4_ddata;
  end
  always @(posedge clk) begin
    s6_data2 <= s5_data2_0 + s5_data2_1;
    s6_data1 <= s5_data1;
    s6_ddata <= s5_ddata;
  end
  ad_mul #(.DELAY_DATA_WIDTH(1)) i_mul_s3_2 (
    .clk (clk),
    .data_a (s6_data2),
    .data_b (17'h1d08),
    .data_p (s7_data2_s),
    .ddata_in (1'b0),
    .ddata_out ());
  ad_mul #(.DELAY_DATA_WIDTH(DELAY_DATA_WIDTH)) i_mul_s3_1 (
    .clk (clk),
    .data_a (s6_data1),
    .data_b (17'h7fff),
    .data_p (s7_data1_s),
    .ddata_in (s6_ddata),
    .ddata_out (s7_ddata_s));
  always @(posedge clk) begin
    s7_data <= s7_data2_s + s7_data1_s;
    s7_ddata <= s7_ddata_s;
  end
  always @(posedge clk) begin
    sine <= s7_data[30:15];
    ddata_out <= s7_ddata;
  end
endmodule
