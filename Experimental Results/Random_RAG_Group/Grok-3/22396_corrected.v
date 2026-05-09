`timescale 1ns/100ps
module axi_ad9122_if (
  input  wire        test_i,
  input  wire        dac_clk_in_p,
  input  wire        dac_clk_in_n,
  output wire        dac_clk_out_p,
  output wire        dac_clk_out_n,
  output wire        dac_frame_out_p,
  output wire        dac_frame_out_n,
  output wire [15:0] dac_data_out_p,
  output wire [15:0] dac_data_out_n,
  input  wire        dac_rst,
  output wire        dac_clk,
  output wire        dac_div_clk,
  output wire        dac_status,
  input  wire        dac_frame_i0,
  input  wire [15:0] dac_data_i0,
  input  wire        dac_frame_i1,
  input  wire [15:0] dac_data_i1,
  input  wire        dac_frame_i2,
  input  wire [15:0] dac_data_i2,
  input  wire        dac_frame_i3,
  input  wire [15:0] dac_data_i3,
  input  wire        dac_frame_q0,
  input  wire [15:0] dac_data_q0,
  input  wire        dac_frame_q1,
  input  wire [15:0] dac_data_q1,
  input  wire        dac_frame_q2,
  input  wire [15:0] dac_data_q2,
  input  wire        dac_frame_q3,
  input  wire [15:0] dac_data_q3,
  input  wire        mmcm_rst,
  input  wire        up_clk,
  input  wire        up_rstn,
  input  wire        up_drp_sel,
  input  wire        up_drp_wr,
  input  wire [11:0] up_drp_addr,
  input  wire [15:0] up_drp_wdata,
  output wire [15:0] up_drp_rdata,
  output wire        up_drp_ready,
  output wire        up_drp_locked
);
  parameter   PCORE_DEVICE_TYPE = 0;
  parameter   PCORE_SERDES_DDR_N = 1;
  parameter   PCORE_MMCM_BUFIO_N = 1;
  parameter   PCORE_IODELAY_GROUP = "dac_if_delay_group";

  wire        dft_dac_rst;
  wire        dft_dac_clk;
  wire        dft_dac_div_clk;
  reg         dac_status_m1 = 'd0;
  reg         dac_status = 'd0;

  assign dft_dac_rst = test_i ? dac_rst : dac_rst;
  assign dft_dac_clk = test_i ? up_clk : dac_clk;
  assign dft_dac_div_clk = test_i ? up_clk : dac_div_clk;

  always @(posedge dft_dac_div_clk) begin
    if (dft_dac_rst == 1'b1) begin
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
    .rst (dft_dac_rst),
    .clk (dft_dac_clk),
    .div_clk (dft_dac_div_clk),
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
    .rst (dft_dac_rst),
    .clk (dft_dac_clk),
    .div_clk (dft_dac_div_clk),
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
    .rst (dft_dac_rst),
    .clk (dft_dac_clk),
    .div_clk (dft_dac_div_clk),
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