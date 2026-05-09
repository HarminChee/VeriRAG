`timescale 1ns/100ps
module axi_ad9739a_if (
  input           dac_clk_in_p,
  input           dac_clk_in_n,
  output          dac_clk_out_p,
  output          dac_clk_out_n,
  output  [13:0]  dac_data_out_a_p,
  output  [13:0]  dac_data_out_a_n,
  output  [13:0]  dac_data_out_b_p,
  output  [13:0]  dac_data_out_b_n,
  input           dac_rst,
  output          dac_clk,
  output          dac_div_clk,
  output          dac_status,
  input   [15:0]  dac_data_00,
  input   [15:0]  dac_data_01,
  input   [15:0]  dac_data_02,
  input   [15:0]  dac_data_03,
  input   [15:0]  dac_data_04,
  input   [15:0]  dac_data_05,
  input   [15:0]  dac_data_06,
  input   [15:0]  dac_data_07,
  input   [15:0]  dac_data_08,
  input   [15:0]  dac_data_09,
  input   [15:0]  dac_data_10,
  input   [15:0]  dac_data_11,
  input   [15:0]  dac_data_12,
  input   [15:0]  dac_data_13,
  input   [15:0]  dac_data_14,
  input   [15:0]  dac_data_15);

  parameter   PCORE_DEVICE_TYPE = 0;

  reg             dac_status = 'd0;
  wire            dac_clk_in_s;

  always @(posedge dac_clk_in_s) begin
    if (dac_rst == 1'b1) begin
      dac_status <= 1'd0;
    end else begin
      dac_status <= 1'd1;
    end
  end

  ad_serdes_out #(
    .SERDES(1),
    .DATA_WIDTH(14),
    .DEVICE_TYPE (PCORE_DEVICE_TYPE))
  i_serdes_out_data_a (
    .rst (dac_rst),
    .clk (dac_clk_in_s),
    .div_clk (dac_clk_in_s),
    .data_s0 (dac_data_00[15:2]),
    .data_s1 (dac_data_02[15:2]),
    .data_s2 (dac_data_04[15:2]),
    .data_s3 (dac_data_06[15:2]),
    .data_s4 (dac_data_08[15:2]),
    .data_s5 (dac_data_10[15:2]),
    .data_s6 (dac_data_12[15:2]),
    .data_s7 (dac_data_14[15:2]),
    .data_out_p (dac_data_out_a_p),
    .data_out_n (dac_data_out_a_n));

  ad_serdes_out #(
    .SERDES(1),
    .DATA_WIDTH(14),
    .DEVICE_TYPE (PCORE_DEVICE_TYPE))
  i_serdes_out_data_b (
    .rst (dac_rst),
    .clk (dac_clk_in_s),
    .div_clk (dac_clk_in_s),
    .data_s0 (dac_data_01[15:2]),
    .data_s1 (dac_data_03[15:2]),
    .data_s2 (dac_data_05[15:2]),
    .data_s3 (dac_data_07[15:2]),
    .data_s4 (dac_data_09[15:2]),
    .data_s5 (dac_data_11[15:2]),
    .data_s6 (dac_data_13[15:2]),
    .data_s7 (dac_data_15[15:2]),
    .data_out_p (dac_data_out_b_p),
    .data_out_n (dac_data_out_b_n));

  ad_serdes_out #(
    .SERDES(1),
    .DATA_WIDTH(1),
    .DEVICE_TYPE (PCORE_DEVICE_TYPE))
  i_serdes_out_clk (
    .rst (dac_rst),
    .clk (dac_clk_in_s),
    .div_clk (dac_clk_in_s),
    .data_s0 (1'b1),
    .data_s1 (1'b0),
    .data_s2 (1'b1),
    .data_s3 (1'b0),
    .data_s4 (1'b1),
    .data_s5 (1'b0),
    .data_s6 (1'b1),
    .data_s7 (1'b0),
    .data_out_p (dac_clk_out_p),
    .data_out_n (dac_clk_out_n));

  IBUFGDS i_dac_clk_in_ibuf (
    .I (dac_clk_in_p),
    .IB (dac_clk_in_n),
    .O (dac_clk_in_s));

  assign dac_clk = dac_clk_in_s;
  assign dac_div_clk = dac_clk_in_s;

endmodule