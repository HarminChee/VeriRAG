`timescale 1ns/100ps
`timescale 1ns/100ps
module cf_ddsx (
  dac_div3_clk,
  dds_data_00,
  dds_data_01,
  dds_data_02,
  dds_data_03,
  dds_data_04,
  dds_data_05,
  dds_data_06,
  dds_data_07,
  dds_data_08,
  dds_data_09,
  dds_data_10,
  dds_data_11,
  up_dds_enable,
  up_dds_incr);
  input           dac_div3_clk;
  output  [13:0]  dds_data_00;
  output  [13:0]  dds_data_01;
  output  [13:0]  dds_data_02;
  output  [13:0]  dds_data_03;
  output  [13:0]  dds_data_04;
  output  [13:0]  dds_data_05;
  output  [13:0]  dds_data_06;
  output  [13:0]  dds_data_07;
  output  [13:0]  dds_data_08;
  output  [13:0]  dds_data_09;
  output  [13:0]  dds_data_10;
  output  [13:0]  dds_data_11;
  input           up_dds_enable;
  input   [15:0]  up_dds_incr;
  reg             dds_enable_in_m1 = 'd0;
  reg             dds_enable_in_m2 = 'd0;
  reg     [ 5:0]  dds_enable_cnt = 'd0;
  reg             dds_enable_clr = 'd0;
  reg             dds_enable_int = 'd0;
  reg             dds_enable_m1 = 'd0;
  reg             dds_enable_m2 = 'd0;
  reg             dds_enable_m3 = 'd0;
  reg             dds_enable_m4 = 'd0;
  reg             dds_enable_m5 = 'd0;
  reg             dds_enable_m6 = 'd0;
  reg             dds_enable_m7 = 'd0;
  reg     [15:0]  dds_incr_m = 'd0;
  reg             dds_enable = 'd0;
  reg     [15:0]  dds_incr = 'd0;
  reg     [15:0]  dds_init_00 = 'd0;
  reg     [15:0]  dds_init_01 = 'd0;
  reg     [15:0]  dds_init_02 = 'd0;
  reg     [15:0]  dds_init_03 = 'd0;
  reg     [15:0]  dds_init_04 = 'd0;
  reg     [15:0]  dds_init_05 = 'd0;
  reg     [15:0]  dds_init_06 = 'd0;
  reg     [15:0]  dds_init_07 = 'd0;
  reg     [15:0]  dds_init_08 = 'd0;
  reg     [15:0]  dds_init_09 = 'd0;
  reg     [15:0]  dds_init_10 = 'd0;
  reg     [15:0]  dds_init_11 = 'd0;
  reg             dds_enable_d = 'd0;
  reg     [15:0]  dds_data_in_00 = 'd0;
  reg     [15:0]  dds_data_in_01 = 'd0;
  reg     [15:0]  dds_data_in_02 = 'd0;
  reg     [15:0]  dds_data_in_03 = 'd0;
  reg     [15:0]  dds_data_in_04 = 'd0;
  reg     [15:0]  dds_data_in_05 = 'd0;
  reg     [15:0]  dds_data_in_06 = 'd0;
  reg     [15:0]  dds_data_in_07 = 'd0;
  reg     [15:0]  dds_data_in_08 = 'd0;
  reg     [15:0]  dds_data_in_09 = 'd0;
  reg     [15:0]  dds_data_in_10 = 'd0;
  reg     [15:0]  dds_data_in_11 = 'd0;
  reg     [13:0]  dds_data_00 = 'd0;
  reg     [13:0]  dds_data_01 = 'd0;
  reg     [13:0]  dds_data_02 = 'd0;
  reg     [13:0]  dds_data_03 = 'd0;
  reg     [13:0]  dds_data_04 = 'd0;
  reg     [13:0]  dds_data_05 = 'd0;
  reg     [13:0]  dds_data_06 = 'd0;
  reg     [13:0]  dds_data_07 = 'd0;
  reg     [13:0]  dds_data_08 = 'd0;
  reg     [13:0]  dds_data_09 = 'd0;
  reg     [13:0]  dds_data_10 = 'd0;
  reg     [13:0]  dds_data_11 = 'd0;
  wire    [15:0]  dds_data_out_00_s;
  wire    [15:0]  dds_data_out_01_s;
  wire    [15:0]  dds_data_out_02_s;
  wire    [15:0]  dds_data_out_03_s;
  wire    [15:0]  dds_data_out_04_s;
  wire    [15:0]  dds_data_out_05_s;
  wire    [15:0]  dds_data_out_06_s;
  wire    [15:0]  dds_data_out_07_s;
  wire    [15:0]  dds_data_out_08_s;
  wire    [15:0]  dds_data_out_09_s;
  wire    [15:0]  dds_data_out_10_s;
  wire    [15:0]  dds_data_out_11_s;
  always @(posedge dac_div3_clk) begin
    dds_enable_in_m1 <= up_dds_enable;
    dds_enable_in_m2 <= dds_enable_in_m1;
    if (dds_enable_in_m2 == 1'b0) begin
      dds_enable_cnt <= 6'h20;
    end else if (dds_enable_cnt[5] == 1'b1) begin
      dds_enable_cnt <= dds_enable_cnt + 1'b1;
    end
    dds_enable_clr <= dds_enable_cnt[5];
    dds_enable_int <= ~dds_enable_cnt[5];
  end
  always @(posedge dac_div3_clk) begin
    dds_enable_m1 <= dds_enable_int;
    dds_enable_m2 <= dds_enable_m1;
    dds_enable_m3 <= dds_enable_m2;
    dds_enable_m4 <= dds_enable_m3;
    dds_enable_m5 <= dds_enable_m4;
    dds_enable_m6 <= dds_enable_m5;
    dds_enable_m7 <= dds_enable_m6;
    if ((dds_enable_m2 == 1'b1) && (dds_enable_m3 == 1'b0)) begin
      dds_incr_m <= up_dds_incr;
    end
  end
  always @(posedge dac_div3_clk) begin
    dds_enable <= dds_enable_m7;
    dds_incr <= dds_init_08 + dds_init_04;
    dds_init_00 <= 16'd0;
    dds_init_01 <= dds_incr_m;
    dds_init_02 <= {dds_incr_m[14:0], 1'd0};
    dds_init_03 <= dds_init_02 + dds_init_01;
    dds_init_04 <= {dds_incr_m[13:0], 2'd0};
    dds_init_05 <= dds_init_04 + dds_init_01;
    dds_init_06 <= dds_init_04 + dds_init_02;
    dds_init_07 <= dds_init_05 + dds_init_02;
    dds_init_08 <= {dds_incr_m[12:0], 3'd0};
    dds_init_09 <= dds_init_05 + dds_init_04;
    dds_init_10 <= dds_init_06 + dds_init_04;
    dds_init_11 <= dds_init_06 + dds_init_05;
  end
  always @(posedge dac_div3_clk) begin
    dds_enable_d <= dds_enable;
    if (dds_enable_d == 1'b1) begin
      dds_data_in_00 <= dds_data_in_00 + dds_incr;
      dds_data_in_01 <= dds_data_in_01 + dds_incr;
      dds_data_in_02 <= dds_data_in_02 + dds_incr;
      dds_data_in_03 <= dds_data_in_03 + dds_incr;
      dds_data_in_04 <= dds_data_in_04 + dds_incr;
      dds_data_in_05 <= dds_data_in_05 + dds_incr;
      dds_data_in_06 <= dds_data_in_06 + dds_incr;
      dds_data_in_07 <= dds_data_in_07 + dds_incr;
      dds_data_in_08 <= dds_data_in_08 + dds_incr;
      dds_data_in_09 <= dds_data_in_09 + dds_incr;
      dds_data_in_10 <= dds_data_in_10 + dds_incr;
      dds_data_in_11 <= dds_data_in_11 + dds_incr;
    end else if (dds_enable == 1'b1) begin
      dds_data_in_00 <= dds_init_00;
      dds_data_in_01 <= dds_init_01;
      dds_data_in_02 <= dds_init_02;
      dds_data_in_03 <= dds_init_03;
      dds_data_in_04 <= dds_init_04;
      dds_data_in_05 <= dds_init_05;
      dds_data_in_06 <= dds_init_06;
      dds_data_in_07 <= dds_init_07;
      dds_data_in_08 <= dds_init_08;
      dds_data_in_09 <= dds_init_09;
      dds_data_in_10 <= dds_init_10;
      dds_data_in_11 <= dds_init_11;
    end else begin
      dds_data_in_00 <= 16'd0;
      dds_data_in_01 <= 16'd0;
      dds_data_in_02 <= 16'd0;
      dds_data_in_03 <= 16'd0;
      dds_data_in_04 <= 16'd0;
      dds_data_in_05 <= 16'd0;
      dds_data_in_06 <= 16'd0;
      dds_data_in_07 <= 16'd0;
      dds_data_in_08 <= 16'd0;
      dds_data_in_09 <= 16'd0;
      dds_data_in_10 <= 16'd0;
      dds_data_in_11 <= 16'd0;
    end
  end
  always @(posedge dac_div3_clk) begin
    dds_data_00 <= {~dds_data_out_00_s[15], dds_data_out_00_s[14:2]};
    dds_data_01 <= {~dds_data_out_01_s[15], dds_data_out_01_s[14:2]};
    dds_data_02 <= {~dds_data_out_02_s[15], dds_data_out_02_s[14:2]};
    dds_data_03 <= {~dds_data_out_03_s[15], dds_data_out_03_s[14:2]};
    dds_data_04 <= {~dds_data_out_04_s[15], dds_data_out_04_s[14:2]};
    dds_data_05 <= {~dds_data_out_05_s[15], dds_data_out_05_s[14:2]};
    dds_data_06 <= {~dds_data_out_06_s[15], dds_data_out_06_s[14:2]};
    dds_data_07 <= {~dds_data_out_07_s[15], dds_data_out_07_s[14:2]};
    dds_data_08 <= {~dds_data_out_08_s[15], dds_data_out_08_s[14:2]};
    dds_data_09 <= {~dds_data_out_09_s[15], dds_data_out_09_s[14:2]};
    dds_data_10 <= {~dds_data_out_10_s[15], dds_data_out_10_s[14:2]};
    dds_data_11 <= {~dds_data_out_11_s[15], dds_data_out_11_s[14:2]};
  end
  cf_ddsx_1 i_ddsx_00 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_00),
    .sine (dds_data_out_00_s));
  cf_ddsx_1 i_ddsx_01 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_01),
    .sine (dds_data_out_01_s));
  cf_ddsx_1 i_ddsx_02 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_02),
    .sine (dds_data_out_02_s));
  cf_ddsx_1 i_ddsx_03 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_03),
    .sine (dds_data_out_03_s));
  cf_ddsx_1 i_ddsx_04 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_04),
    .sine (dds_data_out_04_s));
  cf_ddsx_1 i_ddsx_05 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_05),
    .sine (dds_data_out_05_s));
  cf_ddsx_1 i_ddsx_06 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_06),
    .sine (dds_data_out_06_s));
  cf_ddsx_1 i_ddsx_07 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_07),
    .sine (dds_data_out_07_s));
  cf_ddsx_1 i_ddsx_08 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_08),
    .sine (dds_data_out_08_s));
  cf_ddsx_1 i_ddsx_09 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_09),
    .sine (dds_data_out_09_s));
  cf_ddsx_1 i_ddsx_10 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_10),
    .sine (dds_data_out_10_s));
  cf_ddsx_1 i_ddsx_11 (
    .clk (dac_div3_clk),
    .sclr (dds_enable_clr),
    .phase_in (dds_data_in_11),
    .sine (dds_data_out_11_s));
endmodule
