`timescale 1ns/100ps
`timescale 1ns/100ps
module axi_ad9122_if (
  input           test_i,
  input           dac_clk_in_p,
  input           dac_clk_in_n,
  output          dac_clk_out_p,
  output          dac_clk_out_n,
  output          dac_frame_out_p,
  output          dac_frame_out_n,
  output  [15:0]  dac_data_out_p,
  output  [15:0]  dac_data_out_n,
  input           dac_rst,
  output          dac_clk,
  output          dac_div_clk,
  output          dac_status,
  input           dac_frame_i0,
  input   [15:0]  dac_data_i0,
  input           dac_frame_i1,
  input   [15:0]  dac_data_i1,
  input           dac_frame_i2,
  input   [15:0]  dac_data_i2,
  input           dac_frame_i3,
  input   [15:0]  dac_data_i3,
  input           dac_frame_q0,
  input   [15:0]  dac_data_q0,
  input           dac_frame_q1,
  input   [15:0]  dac_data_q1,
  input           dac_frame_q2,
  input   [15:0]  dac_data_q2,
  input           dac_frame_q3,
  input   [15:0]  dac_data_q3,
  input           mmcm_rst,
  input           up_clk,
  input           up_rstn,
  input           up_drp_sel,
  input           up_drp_wr,
  input   [11:0]  up_drp_addr,
  input   [15:0]  up_drp_wdata,
  output  [15:0]  up_drp_rdata,
  output          up_drp_ready,
  output          up_drp_locked);

  parameter   PCORE_DEVICE_TYPE = 0;
  parameter   PCORE_SERDES_DDR_N = 1;
  parameter   PCORE_MMCM_BUFIO_N = 1;
  parameter   PCORE_IODELAY_GROUP = "dac_if_delay_group";

  wire         dft_dac_div_clk = test_i ? up_clk : dac_div_clk;
  reg          dac_status_m1 = 'd0;
  reg          dac_status = 'd0;

  always @(posedge dft_dac_div_clk) begin
    if (dac_rst == 1'b1) begin
      dac_status_m1 <= 1'd0;
      dac_status <= 1'd0;
    end else begin
      dac_status_m1 <= up_drp_locked;
      dac_status <= dac_status_m1;
    end
  end

  ad_serdes_out #(
    .DEVICE_TYPE (PCORE_DEVICE_TYPE),
    .SERDES(PCORE_SERDES_DDR_N),
    .DATA_WIDTH(16))
  i_serdes_out_data (
    .rst (dac_rst),
    .clk (dac_clk),
    .div_clk (dac_div_clk),
    .data_s0 (dac_data_i0),
    .data_s1 (dac_data_q0),
    .data_s2 (dac_data_i1),
    .data_s3 (dac_data_q1),
    .data_s4 (dac_data_i2),
    .data_s5 (dac_data_q2),
    .data_s6 (dac_data_i3),
    .data_s7 (dac_data_q3),
    .data_out_p (dac_data_out_p),
    .data_out_n (dac_data_out_n));

  ad_serdes_out #(
    .DEVICE_TYPE (PCORE_DEVICE_TYPE),
    .SERDES(PCORE_SERDES_DDR_N),
    .DATA_WIDTH(1))
  i_serdes_out_frame (
    .rst (dac_rst),
    .clk (dac_clk),
    .div_clk (dac_div_clk),
    .data_s0 (dac_frame_i0),
    .data_s1 (dac_frame_q0),
    .data_s2 (dac_frame_i1),
    .data_s3 (dac_frame_q1),
    .data_s4 (dac_frame_i2),
    .data_s5 (dac_frame_q2),
    .data_s6 (dac_frame_i3),
    .data_s7 (dac_frame_q3),
    .data_out_p (dac_frame_out_p),
    .data_out_n (dac_frame_out_n));

  ad_serdes_out #(
    .DEVICE_TYPE (PCORE_DEVICE_TYPE),
    .SERDES(PCORE_SERDES_DDR_N),
    .DATA_WIDTH(1))
  i_serdes_out_clk (
    .rst (dac_rst),
    .clk (dac_clk),
    .div_clk (dac_div_clk),
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

  ad_serdes_clk #(
    .SERDES (PCORE_SERDES_DDR_N),
    .MMCM (PCORE_MMCM_BUFIO_N),
    .MMCM_DEVICE_TYPE (PCORE_DEVICE_TYPE),
    .MMCM_CLKIN_PERIOD (1.667),
    .MMCM_VCO_DIV (6),
    .MMCM_VCO_MUL (12),
    .MMCM_CLK0_DIV (2),
    .MMCM_CLK1_DIV (8))
  i_serdes_clk (
    .mmcm_rst (mmcm_rst),
    .clk_in_p (dac_clk_in_p),
    .clk_in_n (dac_clk_in_n),
    .clk (dac_clk),
    .div_clk (dac_div_clk),
    .up_clk (up_clk),
    .up_rstn (up_rstn),
    .up_drp_sel (up_drp_sel),
    .up_drp_wr (up_drp_wr),
    .up_drp_addr (up_drp_addr),
    .up_drp_wdata (up_drp_wdata),
    .up_drp_rdata (up_drp_rdata),
    .up_drp_ready (up_drp_ready),
    .up_drp_locked (up_drp_locked));

endmodule