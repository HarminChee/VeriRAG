`timescale 1ps/1ps
`timescale 1ps/1ps
module ad_dcfilter (
  clk,
  valid,
  data,
  valid_out,
  data_out,
  dcfilt_enb,
  dcfilt_coeff,
  dcfilt_offset);
  input           clk;
  input           valid;
  input   [15:0]  data;
  output          valid_out;
  output  [15:0]  data_out;
  input           dcfilt_enb;
  input   [15:0]  dcfilt_coeff;
  input   [15:0]  dcfilt_offset;
  reg     [15:0]  dc_offset = 'd0;
  reg     [32:0]  dc_offset_33 = 'd0;
  reg             valid_d = 'd0;
  reg     [15:0]  data_d = 'd0;
  reg             valid_out = 'd0;
  reg     [15:0]  data_out = 'd0;
  wire    [32:0]  dc_offset_33_s;
  always @(posedge clk) begin
    dc_offset <= dc_offset_33_s[32:17];
    dc_offset_33 <= dc_offset_33_s;
    valid_d <= valid;
    if (valid == 1'b1) begin
      data_d <= data + dcfilt_offset;
    end
    if (dcfilt_enb == 1'b1) begin
      valid_out <= valid_d;
      data_out <= data_d - dc_offset;
    end else begin
      valid_out <= valid_d;
      data_out <= data_d;
    end
  end
  ad_dcfilter_1 i_dcfilter_1 (
    .clk (clk),
    .d (data_d),
    .b (dcfilt_coeff),
    .a (dc_offset_33[32:17]),
    .c (dc_offset_33[32:17]),
    .p (dc_offset_33_s));
endmodule
