`timescale 1ns / 1ps
`timescale 1ns / 1ps
module tb_opening3x3(
    input wire test_clk,       // DFT: Test clock input
    input wire test_rst_n,     // DFT: Test reset input (active low)
    input wire test_i          // DFT: Test mode enable
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

// DFT signals
wire dft_clk;
wire dft_open3_rst;    // Active high reset for open3 instance
wire dft_always_rst_n; // Active low reset for always block

assign dft_clk = test_i ? test_clk : rx_pclk;
assign dft_open3_rst = test_i ? ~test_rst_n : 1'b0; // Functional reset is 1'b0 (inactive)
assign dft_always_rst_n = test_i ? test_rst_n : 1'b1; // Functional reset is inactive (1'b1)

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
opening3x3 #
(
	.H_SIZE(10'd83)
)
open3
(
	.clk(dft_clk), // DFT: Use multiplexed clock
	.ce(1'b1),
	.rst(dft_open3_rst), // DFT: Use multiplexed reset
	.mask((rx_red == 8'hFF) ? 1'b1 : 1'b0),
	.in_de(rx_de),
	.in_vsync(rx_vsync),
	.in_hsync(rx_hsync),
	.opened(opening),
	.out_de(opening_de),
	.out_vsync(opening_vsync),
	.out_hsync(opening_hsync)
);
always @(posedge dft_clk or negedge dft_always_rst_n) begin // DFT: Use muxed clock and reset
    if (!dft_always_rst_n) begin // DFT: Add reset logic
        opening_r <= 8'h00;
        opening_g <= 8'h00;
        opening_b <= 8'h00;
    end else begin
        opening_r <= (opening) ? 8'hFF : 8'h00;
        opening_g <= (opening) ? 8'hFF : 8'h00;
        opening_b <= (opening) ? 8'hFF : 8'h00;
    end
end
	assign tx_de 				= opening_de;
	assign tx_hsync 			= opening_hsync;
	assign tx_vsync 			= opening_vsync;
	assign tx_red         	= opening_r;
	assign tx_green        	= opening_g;
	assign tx_blue         	= opening_b;
hdmi_out file_output (
    .hdmi_clk(dft_clk), // DFT: Use multiplexed clock
    .hdmi_vs(tx_vsync),
    .hdmi_de(tx_de),
    .hdmi_data({8'b0,tx_red,tx_green,tx_blue})
    );
endmodule