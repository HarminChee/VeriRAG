`timescale 1ns / 1ps
module tb_erosion3x3(
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
wire dft_rst;
hdmi_in file_input (
    .hdmi_clk(rx_pclk), 
    .hdmi_de(rx_de), 
    .hdmi_hs(rx_hsync), 
    .hdmi_vs(rx_vsync), 
    .hdmi_r(rx_red), 
    .hdmi_g(rx_green), 
    .hdmi_b(rx_blue)
    );
reg [7:0] erosion_r;
reg [7:0] erosion_g;
reg [7:0] erosion_b;
wire erosion;
wire erosion_de;
wire erosion_vsync;
wire erosion_hsync;
assign dft_rx_pclk = test_i ? rx_pclk : rx_pclk;
assign dft_rst = test_i ? rst : rst;
erosion3x3 #
(
	.H_SIZE(10'd83)
)
erode3
(
	.clk(dft_rx_pclk),
	.ce(1'b1),
	.rst(dft_rst),
	.mask((rx_red == 8'hFF) ? 1'b1 : 1'b0),
	.in_de(rx_de),
	.in_vsync(rx_vsync),
	.in_hsync(rx_hsync),
	.eroded(erosion),
	.out_de(erosion_de),
	.out_vsync(erosion_vsync),
	.out_hsync(erosion_hsync)
);
always @(posedge dft_rx_pclk or posedge dft_rst) begin
    if (dft_rst) begin
        erosion_r <= 8'h00;
        erosion_g <= 8'h00;
        erosion_b <= 8'h00;
    end else begin
        erosion_r <= (erosion) ? 8'hFF : 8'h00;
        erosion_g <= (erosion) ? 8'hFF : 8'h00;
        erosion_b <= (erosion) ? 8'hFF : 8'h00;
    end
end
assign tx_de = erosion_de;
assign tx_hsync = erosion_hsync;
assign tx_vsync = erosion_vsync;
assign tx_red = erosion_r;
assign tx_green = erosion_g;
assign tx_blue = erosion_b;
hdmi_out file_output (
    .hdmi_clk(dft_rx_pclk), 
    .hdmi_vs(tx_vsync), 
    .hdmi_de(tx_de), 
    .hdmi_data({8'b0,tx_red,tx_green,tx_blue})
    );
endmodule