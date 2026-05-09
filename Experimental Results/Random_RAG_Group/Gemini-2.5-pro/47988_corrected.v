`timescale 1ns / 1ps
module tb_centro(
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
assign dft_rx_pclk = test_i ? rx_pclk : rx_pclk;
hdmi_in file_input (
    .hdmi_clk(rx_pclk), 
    .hdmi_de(rx_de), 
    .hdmi_hs(rx_hsync), 
    .hdmi_vs(rx_vsync), 
    .hdmi_r(rx_red), 
    .hdmi_g(rx_green), 
    .hdmi_b(rx_blue)
    );
reg [7:0] cross_r;
reg [7:0] cross_g;
reg [7:0] cross_b;	 
wire [9:0] centr_x;
wire [9:0] centr_y;
wire [9:0] curr_h;
wire [9:0] curr_w;
centroid #
(
	.IMG_W(64),
	.IMG_H(64)
)
centro
(
    .clk(dft_rx_pclk),
    .ce(1'b1),
    .rst(rst),
    .de(rx_de),
    .hsync(rx_hsync),
    .vsync(rx_vsync),
    .mask((rx_red == 8'hFF) ? 1'b1 : 1'b0),
    .x(centr_x),
    .y(centr_y),
	 .c_h(curr_h),
	 .c_w(curr_w)
);
always @(posedge dft_rx_pclk or posedge rst) begin
    if (rst) begin
        cross_r <= 8'h00;
        cross_g <= 8'h00;
        cross_b <= 8'h00;
    end else begin
        cross_r <= ((curr_h[9:0] == centr_y || curr_w == centr_x) ? 8'hFF : rx_red);
        cross_g <= ((curr_h[9:0] == centr_y || curr_w == centr_x) ? 8'h00 : rx_green);
        cross_b <= ((curr_h[9:0] == centr_y || curr_w == centr_x) ? 8'h00 : rx_blue);
    end
end
	assign tx_de 				= rx_de;
	assign tx_hsync 			= rx_hsync;
	assign tx_vsync 			= rx_vsync;
	assign tx_red         	= cross_r;
	assign tx_green        	= cross_g;
	assign tx_blue         	= cross_b;
hdmi_out file_output (
    .hdmi_clk(dft_rx_pclk), 
    .hdmi_vs(tx_vsync), 
    .hdmi_de(tx_de), 
    .hdmi_data({8'b0,tx_red,tx_green,tx_blue})
    );
endmodule