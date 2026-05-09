<xaiArtifact artifact_id="8250926a-8f15-4c62-aaca-d150546fabff" artifact_version_id="7889d6c0-b6d1-471e-bc48-ac423d2e0aec" title="tb_closing3x3_corrected.v" contentType="text/verilog">
`timescale 1ns / 1ps
module tb_closing3x3 (
    input wire test_mode
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

reg [7:0] closing_r;
reg [7:0] closing_g;
reg [7:0] closing_b;
wire closing;
wire closing_de;
wire closing_vsync;
wire closing_hsync;

assign dft_rx_pclk = test_mode ? rx_pclk : rx_pclk;

closing3x3 #(
    .H_SIZE(10'd83)
)
close33 (
    .clk(dft_rx_pclk),
    .ce(1'b1),
    .rst(test_mode ? 1'b0 : 1'b0),
    .mask((rx_red == 8'hFF) ? 1'b1 : 1'b0),
    .in_de(rx_de),
    .in_vsync(rx_vsync),
    .in_hsync(rx_hsync),
    .closed(closing),
    .out_de(closing_de),
    .out_vsync(closing_vsync),
    .out_hsync(closing_hsync)
);

always @(posedge dft_rx_pclk) begin
    closing_r <= (closing) ? 8'hFF : 8'h00;
    closing_g <= (closing) ? 8'hFF : 8'h00;
    closing_b <= (closing) ? 8'hFF : 8'h00;
end

assign tx_de        = closing_de;
assign tx_hsync     = closing_hsync;
assign tx_vsync     = closing_vsync;
assign tx_red       = closing_r;
assign tx_green     = closing_g;
assign tx_blue      = closing_b;

hdmi_out file_output (
    .hdmi_clk(dft_rx_pclk), 
    .hdmi_vs(tx_vsync), 
    .hdmi_de(tx_de), 
    .hdmi_data({8'b0, tx_red, tx_green, tx_blue})
);

endmodule
</xaiArtifact>