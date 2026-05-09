`timescale 1ns/100ps
`timescale 1ns/100ps
module axi_ad9250_if (
  rx_clk,
  rx_data,
  adc_clk,
  adc_rst,
  adc_data_a,
  adc_data_b,
  adc_or_a,
  adc_or_b,
  adc_status);
  input           rx_clk;
  input   [63:0]  rx_data;
  output          adc_clk;
  input           adc_rst;
  output  [27:0]  adc_data_a;
  output  [27:0]  adc_data_b;
  output          adc_or_a;
  output          adc_or_b;
  output          adc_status;
  reg             adc_status = 'd0;
  wire    [15:0]  adc_data_a_s1_s;
  wire    [15:0]  adc_data_a_s0_s;
  wire    [15:0]  adc_data_b_s1_s;
  wire    [15:0]  adc_data_b_s0_s;
  assign adc_clk = rx_clk;
  assign adc_or_a = 1'b0;
  assign adc_or_b = 1'b0;
  assign adc_data_a = {adc_data_a_s1_s[13:0], adc_data_a_s0_s[13:0]};
  assign adc_data_b = {adc_data_b_s1_s[13:0], adc_data_b_s0_s[13:0]};
  assign adc_data_a_s1_s = {rx_data[25:24], rx_data[23:16], rx_data[31:26]}; 
  assign adc_data_a_s0_s = {rx_data[ 9: 8], rx_data[ 7: 0], rx_data[15:10]};
  assign adc_data_b_s1_s = {rx_data[57:56], rx_data[55:48], rx_data[63:58]}; 
  assign adc_data_b_s0_s = {rx_data[41:40], rx_data[39:32], rx_data[47:42]};
  always @(posedge rx_clk) begin
    if (adc_rst == 1'b1) begin
      adc_status <= 1'b0;
    end else begin
      adc_status <= 1'b1;
    end
  end
endmodule
