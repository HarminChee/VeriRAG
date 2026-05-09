`timescale 1ns / 1ps
`timescale 1ns / 1ps
module tb_dilation3x3(
    input wire test_i
    );
wire rx_pclk;
wire rx_de;
wire rx_hsync;
wire rx_vsync;
wire [7:0] rx_red;
wire [7:0] rx_green;
wire [7:0] rx_blue;
wire tx_de;
wire tx_hsync;
wire tx_vsync;
wire [7:0] tx_red;
wire [7:0] tx_green;
wire [7:0] tx_blue;
wire dft_rx_pclk, dft_rst;
hdmi_in file_input (
    .hdmi_clk(rx_pclk), 
    .hdmi_de(rx_de), 
    .hdmi_hs(rx_hsync), 
    .hdmi_vs(rx_vsync), 
    .hdmi_r(rx_red), 
    .hdmi_g(rx_green), 
    .hdmi_b(rx_blue)
    );
reg [7:0] dilation_r;
reg [7:0] dilation_g;
reg [7:0] dilation_b;
wire dilation;
wire dilation_de;
wire dilation_vsync;
wire dilation_hsync;
assign dft_rx_pclk = test_i ? 1'b0 : rx_pclk;
assign dft_rst = test_i ? 1'b0 : 1'b0;
dilation3x3 #
(
	.H_SIZE(10'd83)
)
dilate3
(
	.clk(dft_rx_pclk),
	.ce(1'b1),
	.rst(dft_rst),
	.mask((rx_red == 8'hFF) ? 1'b1 : 1'b0),
	.in_de(rx_de),
	.in_vsync(rx_vsync),
	.in_hsync(rx_hsync),
	.dilated(dilation),
	.out_de(dilation_de),
	.out_vsync(dilation_vsync),
	.out_hsync(dilation_hsync)
);
always @(posedge dft_rx_pclk) begin
	dilation_r = (dilation) ? 8'hFF : 8'h00;
	dilation_g = (dilation) ? 8'hFF : 8'h00;
	dilation_b = (dilation) ? 8'hFF : 8'h00;
end
	assign tx_de 				= dilation_de;
	assign tx_hsync 			= dilation_hsync;
	assign tx_vsync 			= dilation_vsync;
	assign tx_red         	= dilation_r;
	assign tx_green        	= dilation_g;
	assign tx_blue         	= dilation_b;
hdmi_out file_output (
    .hdmi_clk(dft_rx_pclk), 
    .hdmi_vs(tx_vsync), 
    .hdmi_de(tx_de), 
    .hdmi_data({8'b0,tx_red,tx_green,tx_blue})
    );
endmodule