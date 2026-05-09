`timescale 1ns / 1ps
module tb_centro(
    input wire clk_in,  // Primary input clock
    input wire rst_n    // Primary input reset
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

// Clock buffer to derive rx_pclk from primary input
BUFG clk_buf (
    .I(clk_in),
    .O(rx_pclk)
);

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
    .clk(clk_in),      // Use primary input clock
    .ce(1'b1),
    .rst(~rst_n),      // Active high reset derived from rst_n
    .de(rx_de),
    .hsync(rx_hsync),
    .vsync(rx_vsync),
    .mask((rx_red == 8'hFF) ? 1'b1 : 1'b0),
    .x(centr_x),
    .y(centr_y),
    .c_h(curr_h),
    .c_w(curr_w)
);

always @(posedge clk_in) begin  // Use primary input clock
    cross_r <= ((curr_h[9:0] == centr_y || curr_w == centr_x) ? 8'hFF : rx_red);
    cross_g <= ((curr_h[9:0] == centr_y || curr_w == centr_x) ? 8'h00 : rx_red);
    cross_b <= ((curr_h[9:0] == centr_y || curr_w == centr_x) ? 8'h00 : rx_red);
end

assign tx_de = rx_de;
assign tx_hsync = rx_hsync;
assign tx_vsync = rx_vsync;
assign tx_red = cross_r;
assign tx_green = cross_g;
assign tx_blue = cross_b;

hdmi_out file_output (
    .hdmi_clk(clk_in),     // Use primary input clock
    .hdmi_vs(tx_vsync), 
    .hdmi_de(tx_de), 
    .hdmi_data({8'b0,tx_red,tx_green,tx_blue})
    );

endmodule