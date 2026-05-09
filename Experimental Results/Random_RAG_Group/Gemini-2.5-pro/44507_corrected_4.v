`timescale 1ns/100ps
module axi_ad9739a_if (
  input  wire        test_i,
  input  wire        dac_clk_in_p,
  input  wire        dac_clk_in_n,
  output wire        dac_clk_out_p,
  output wire        dac_clk_out_n,
  output wire [13:0] dac_data_out_a_p,
  output wire [13:0] dac_data_out_a_n,
  output wire [13:0] dac_data_out_b_p,
  output wire [13:0] dac_data_out_b_n,
  input  wire        dac_rst,
  output wire        dac_clk,
  output wire        dac_div_clk,
  output wire        dac_status,
  input  wire [15:0] dac_data_00,
  input  wire [15:0] dac_data_01,
  input  wire [15:0] dac_data_02,
  input  wire [15:0] dac_data_03,
  input  wire [15:0] dac_data_04,
  input  wire [15:0] dac_data_05,
  input  wire [15:0] dac_data_06,
  input  wire [15:0] dac_data_07,
  input  wire [15:0] dac_data_08,
  input  wire [15:0] dac_data_09,
  input  wire [15:0] dac_data_10,
  input  wire [15:0] dac_data_11,
  input  wire [15:0] dac_data_12,
  input  wire [15:0] dac_data_13,
  input  wire [15:0] dac_data_14,
  input  wire [15:0] dac_data_15
);
  parameter   PCORE_DEVICE_TYPE = 0;
  
  reg         dac_status = 'd0;
  wire        dac_clk_in_s;
  wire        dac_div_clk_s;
  wire        dft_dac_clk;
  wire        dft_dac_div_clk;
  wire        dft_dac_rst;

  assign dft_dac_rst = test_i ? dac_rst : dac_rst;
  assign dft_dac_clk = test_i ? dac_clk_in_s : dac_clk;
  assign dft_dac_div_clk = test_i ? dac_clk_in_s : dac_div_clk;

  always @(posedge dft_dac_div_clk or posedge dft_dac_rst) begin
    if (dft_dac_rst == 1'b1) begin
      dac_status <= 1'd0;
    end else begin
      dac_status <= 1'd1;
    end
  end

  ad_serdes_out #(
    .SERDES(1),
    .DATA_WIDTH(14),
    .DEVICE_TYPE(PCORE_DEVICE_TYPE))
  i_serdes_out_data_a (
    .rst(dft_dac_rst),
    .clk(dft_dac_clk),
    .div_clk(dft_dac_div_clk),
    .data_s0(dac_data_00[15:2]),
    .data_s1(dac_data_02[15:2]),
    .data_s2(dac_data_04[15:2]),
    .data_s3(dac_data_06[15:2]),
    .data_s4(dac_data_08[15:2]),
    .data_s5(dac_data_10[15:2]),
    .data_s6(dac_data_12[15:2]),
    .data_s7(dac_data_14[15:2]),
    .data_out_p(dac_data_out_a_p),
    .data_out_n(dac_data_out_a_n));

  ad_serdes_out #(
    .SERDES(1),
    .DATA_WIDTH(14),
    .DEVICE_TYPE(PCORE_DEVICE_TYPE))
  i_serdes_out_data_b (
    .rst(dft_dac_rst),
    .clk(dft_dac_clk),
    .div_clk(dft_dac_div_clk),
    .data_s0(dac_data_01[15:2]),
    .data_s1(dac_data_03[15:2]),
    .data_s2(dac_data_05[15:2]),
    .data_s3(dac_data_07[15:2]),
    .data_s4(dac_data_09[15:2]),
    .data_s5(dac_data_11[15:2]),
    .data_s6(dac_data_13[15:2]),
    .data_s7(dac_data_15[15:2]),
    .data_out_p(dac_data_out_b_p),
    .data_out_n(dac_data_out_b_n));

  ad_serdes_out #(
    .SERDES(1),
    .DATA_WIDTH(1),
    .DEVICE_TYPE(PCORE_DEVICE_TYPE))
  i_serdes_out_clk (
    .rst(dft_dac_rst),
    .clk(dft_dac_clk),
    .div_clk(dft_dac_div_clk),
    .data_s0(1'b1),
    .data_s1(1'b0),
    .data_s2(1'b1),
    .data_s3(1'b0),
    .data_s4(1'b1),
    .data_s5(1'b0),
    .data_s6(1'b1),
    .data_s7(1'b0),
    .data_out_p(dac_clk_out_p),
    .data_out_n(dac_clk_out_n));

  IBUFGDS i_dac_clk_in_ibuf (
    .I(dac_clk_in_p),
    .IB(dac_clk_in_n),
    .O(dac_clk_in_s));

  BUFG i_dac_clk_in_gbuf (
    .I(dac_clk_in_s),
    .O(dac_clk));

  BUFR #(.BUFR_DIVIDE("4")) i_dac_div_clk_rbuf (
    .CLR(1'b0),
    .CE(1'b1),
    .I(dac_clk_in_s),
    .O(dac_div_clk_s));

  BUFG i_dac_div_clk_gbuf (
    .I(dac_div_clk_s),
    .O(dac_div_clk));

endmodule