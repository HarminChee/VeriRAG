`timescale 1ns / 1ps
module tb_bounding_box();
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
    wire [9:0] x_min;
    wire [9:0] y_min;
    wire [9:0] x_max;
    wire [9:0] y_max;
    wire [9:0] curr_h;
    wire [9:0] curr_w;

    bounding_box #
    (
        .IMG_W(64),
        .IMG_H(64)
    )
    box
    (
        .clk(rx_pclk),
        .ce(1'b1),
        .rst(1'b0),
        .de(rx_de),
        .hsync(rx_hsync),
        .vsync(rx_vsync),
        .mask((rx_red == 8'hFF) ? 1'b1 : 1'b0),
        .x_min(x_min),
        .y_min(y_min),
        .x_max(x_max),
        .y_max(y_max),
        .c_h(curr_h),
        .c_w(curr_w)
    );

    reg on_border = 0;
    always @(posedge rx_pclk) begin
        if((curr_h >= y_min && curr_h <= y_max) && (curr_w == x_min || curr_w == x_max))
            on_border = 1;
        else if((curr_w >= x_min && curr_w <= x_max) && (curr_h == y_min || curr_h == y_max))
            on_border = 1;
        else
            on_border = 0;
        cross_r = ((on_border == 1'b1) ? 8'hFF : rx_red);
        cross_g = ((on_border == 1'b1) ? 8'h00 : rx_green);
        cross_b = ((on_border == 1'b1) ? 8'h00 : rx_blue);
    end

    assign tx_de      = rx_de;
    assign tx_hsync   = rx_hsync;
    assign tx_vsync   = rx_vsync;
    assign tx_red     = cross_r;
    assign tx_green   = cross_g;
    assign tx_blue    = cross_b;

    hdmi_out file_output (
        .hdmi_clk(rx_pclk),
        .hdmi_vs(tx_vsync),
        .hdmi_de(tx_de),
        .hdmi_data({8'b0,tx_red,tx_green,tx_blue})
    );
endmodule