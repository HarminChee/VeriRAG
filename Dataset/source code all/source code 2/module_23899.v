module cf_iqcor (
  clk,
  data_i,
  data_q,
  data_cor_i,
  data_cor_q,
  up_iqcor_enable,
  up_iqcor_scale_ii,
  up_iqcor_scale_iq,
  up_iqcor_scale_qi,
  up_iqcor_scale_qq,
  up_iqcor_offset_i,
  up_iqcor_offset_q);
  input           clk;
  input   [15:0]  data_i;
  input   [15:0]  data_q;
  output  [15:0]  data_cor_i;
  output  [15:0]  data_cor_q;
  input           up_iqcor_enable;
  input   [15:0]  up_iqcor_scale_ii;
  input   [15:0]  up_iqcor_scale_iq;
  input   [15:0]  up_iqcor_scale_qi;
  input   [15:0]  up_iqcor_scale_qq;
  input   [15:0]  up_iqcor_offset_i;
  input   [15:0]  up_iqcor_offset_q;
  reg             iqcor_enable_m1 = 'd0;
  reg             iqcor_enable_m2 = 'd0;
  reg             iqcor_enable_m3 = 'd0;
  reg             iqcor_enable = 'd0;
  reg     [15:0]  iqcor_scale_ii = 'd0;
  reg     [15:0]  iqcor_scale_iq = 'd0;
  reg     [15:0]  iqcor_scale_qi = 'd0;
  reg     [15:0]  iqcor_scale_qq = 'd0;
  reg     [15:0]  iqcor_offset_i = 'd0;
  reg     [15:0]  iqcor_offset_q = 'd0;
  always @(posedge clk) begin
    iqcor_enable_m1 <= up_iqcor_enable;
    iqcor_enable_m2 <= iqcor_enable_m1;
    iqcor_enable_m3 <= iqcor_enable_m2;
    iqcor_enable <= iqcor_enable_m3;
    if ((iqcor_enable_m3 == 1'b0) && (iqcor_enable_m2 == 1'b1)) begin
      iqcor_scale_ii <= up_iqcor_scale_ii;
      iqcor_scale_iq <= up_iqcor_scale_iq;
      iqcor_scale_qi <= up_iqcor_scale_qi;
      iqcor_scale_qq <= up_iqcor_scale_qq;
      iqcor_offset_i <= up_iqcor_offset_i;
      iqcor_offset_q <= up_iqcor_offset_q;
    end
  end
  cf_iqcor_1 #(.IQSEL(0)) i_iqcor_1_i (
    .clk (clk),
    .data_i (data_i),
    .data_q (data_q),
    .data_cor (data_cor_i),
    .iqcor_enable (iqcor_enable),
    .iqcor_scale_i (iqcor_scale_ii),
    .iqcor_scale_q (iqcor_scale_iq),
    .iqcor_offset_i (iqcor_offset_i),
    .iqcor_offset_q (iqcor_offset_q));
  cf_iqcor_1 #(.IQSEL(1)) i_iqcor_1_q (
    .clk (clk),
    .data_i (data_i),
    .data_q (data_q),
    .data_cor (data_cor_q),
    .iqcor_enable (iqcor_enable),
    .iqcor_scale_i (iqcor_scale_qi),
    .iqcor_scale_q (iqcor_scale_qq),
    .iqcor_offset_i (iqcor_offset_i),
    .iqcor_offset_q (iqcor_offset_q));
endmodule
