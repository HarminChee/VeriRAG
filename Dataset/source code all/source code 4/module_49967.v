`timescale 1ns/100ps
`timescale 1ns/100ps
module axi_ad9122_if (
  dac_clk_in_p,
  dac_clk_in_n,
  dac_clk_out_p,
  dac_clk_out_n,
  dac_frame_out_p,
  dac_frame_out_n,
  dac_data_out_p,
  dac_data_out_n,
  dac_rst,
  dac_clk,
  dac_div_clk,
  dac_status,
  dac_frame_i0,
  dac_data_i0,
  dac_frame_i1,
  dac_data_i1,
  dac_frame_i2,
  dac_data_i2,
  dac_frame_i3,
  dac_data_i3,
  dac_frame_q0,
  dac_data_q0,
  dac_frame_q1,
  dac_data_q1,
  dac_frame_q2,
  dac_data_q2,
  dac_frame_q3,
  dac_data_q3,
  mmcm_rst,
  drp_clk,
  drp_rst,
  drp_sel,
  drp_wr,
  drp_addr,
  drp_wdata,
  drp_rdata,
  drp_ack_t);
  parameter   PCORE_DEVICE_TYPE = 0;
  parameter   PCORE_SERDES_DDR_N = 1;
  parameter   PCORE_MMCM_BUFIO_N = 1;
  parameter   PCORE_IODELAY_GROUP = "dac_if_delay_group";
  input           dac_clk_in_p;
  input           dac_clk_in_n;
  output          dac_clk_out_p;
  output          dac_clk_out_n;
  output          dac_frame_out_p;
  output          dac_frame_out_n;
  output  [15:0]  dac_data_out_p;
  output  [15:0]  dac_data_out_n;
  input           dac_rst;
  output          dac_clk;
  output          dac_div_clk;
  output          dac_status;
  input           dac_frame_i0;
  input   [15:0]  dac_data_i0;
  input           dac_frame_i1;
  input   [15:0]  dac_data_i1;
  input           dac_frame_i2;
  input   [15:0]  dac_data_i2;
  input           dac_frame_i3;
  input   [15:0]  dac_data_i3;
  input           dac_frame_q0;
  input   [15:0]  dac_data_q0;
  input           dac_frame_q1;
  input   [15:0]  dac_data_q1;
  input           dac_frame_q2;
  input   [15:0]  dac_data_q2;
  input           dac_frame_q3;
  input   [15:0]  dac_data_q3;
  input           mmcm_rst;
  input           drp_clk;
  input           drp_rst;
  input           drp_sel;
  input           drp_wr;
  input   [11:0]  drp_addr;
  input   [15:0]  drp_wdata;
  output  [15:0]  drp_rdata;
  output          drp_ack_t;
  reg             dac_status_m1 = 'd0;
  reg             dac_status = 'd0;
  wire            drp_locked_s;
  always @(posedge dac_div_clk) begin
    if (dac_rst == 1'b1) begin
      dac_status_m1 <= 1'd0;
      dac_status <= 1'd0;
    end else begin
      dac_status_m1 <= drp_locked_s;
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
    .drp_clk (drp_clk),
    .drp_rst (drp_rst),
    .drp_sel (drp_sel),
    .drp_wr (drp_wr),
    .drp_addr (drp_addr),
    .drp_wdata (drp_wdata),
    .drp_rdata (drp_rdata),
    .drp_ack_t (drp_ack_t),
    .drp_locked (drp_locked_s));
endmodule
