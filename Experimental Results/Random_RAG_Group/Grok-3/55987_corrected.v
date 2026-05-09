`timescale 1ns / 1ps
module tb_opening3x3(
    input wire test_i,
    input wire rst
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
wire dft_rx_pclk;

hdmi_in file_input (
    .hdmi_clk(rx_pclk), 
    .hdmi_de(rx_de), 
    .hdmi_hs(rx_hsync), 
    .hdmi_vs(rx_vsync), 
    .hdmi_r(rx_red), 
    .hdmi_g(rx_green), 
    .hdmi_b(rx_blue)
    );

reg [7:0] opening_r;
reg [7:0] opening_g;
reg [7:0] opening_b;
wire opening;
wire opening_de;
wire opening_vsync;
wire opening_hsync;

assign dft_rx_pclk = test_i ? rx_pclk : rx_pclk;

opening3x3 #
(
	.H_SIZE(10'd83)
)
open3
(
	.clk(dft_rx_pclk),
	.ce(1'b1),
	.rst(rst),
	.mask((rx_red == 8'hFF) ? 1'b1 : 1'b0),
	.in_de(rx_de),
	.in_vsync(rx_vsync),
	.in_hsync(rx_hsync),
	.opened(opening),
	.out_de(opening_de),
	.out_vsync(opening_vsync),
	.out_hsync(opening_hsync)
);

always @(posedge dft_rx_pclk or posedge rst) begin
    if (rst) begin
        opening_r <= 8'h00;
        opening_g <= 8'h00;
        opening_b <= 8'h00;
    end else begin
        opening_r <= (opening) ? 8'hFF : 8'h00;
        opening_g <= (opening) ? 8'hFF : 8'h00;
        opening_b <= (opening) ? 8'hFF : 8'h00;
    end
end

assign tx_de        = opening_de;
assign tx_hsync     = opening_hsync;
assign tx_vsync     = opening_vsync;
assign tx_red       = opening_r;
assign tx_green     = opening_g;
assign tx_blue      = opening_b;

hdmi_out file_output (
    .hdmi_clk(dft_rx_pclk), 
    .hdmi_vs(tx_vsync), 
    .hdmi_de(tx_de), 
    .hdmi_data({8'b0,tx_red,tx_green,tx_blue})
    );

endmodule