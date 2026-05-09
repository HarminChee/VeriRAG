`timescale 1ns / 1ps

module tb_dilation3x3(
    );

// Clock and Reset Generation
reg rx_pclk;
reg rst_n;

// Input signals (driven by stimulus/hdmi_in)
wire rx_de;
wire rx_hsync;
wire rx_vsync;
wire [7:0] rx_red;
wire [7:0] rx_green;
wire [7:0] rx_blue;

// Output signals (driven by DUT/assignments)
wire tx_de;
wire tx_hsync;
wire tx_vsync;
wire [7:0] tx_red;
wire [7:0] tx_green;
wire [7:0] tx_blue;

// Instantiate the input stimulus generator (assuming it exists)
// If hdmi_in is not available, replace this with direct stimulus generation
// using reg types for rx_de, rx_hsync, etc. and driving them in an initial block.
hdmi_in file_input (
    .hdmi_clk(rx_pclk),
    .hdmi_de(rx_de),
    .hdmi_hs(rx_hsync),
    .hdmi_vs(rx_vsync),
    .hdmi_r(rx_red),
    .hdmi_g(rx_green),
    .hdmi_b(rx_blue)
    );

// Intermediate signals for dilation output
reg [7:0] dilation_r;
reg [7:0] dilation_g;
reg [7:0] dilation_b;
wire dilation;
wire dilation_de;
wire dilation_vsync;
wire dilation_hsync;

// Instantiate the DUT (Device Under Test)
dilation3x3 #
(
	.H_SIZE(10'd83) // Example size, adjust if needed
)
dilate3
(
	.clk(rx_pclk),
	.ce(1'b1),        // Assuming always enabled, change if needed
	.rst(~rst_n),     // Connect reset (active high)
	.mask((rx_red == 8'hFF) ? 1'b1 : 1'b0), // Example mask logic based on red channel
	.in_de(rx_de),
	.in_vsync(rx_vsync),
	.in_hsync(rx_hsync),

	.dilated(dilation),
	.out_de(dilation_de),
	.out_vsync(dilation_vsync),
	.out_hsync(dilation_hsync)
);

// Clock generation
initial begin
    rx_pclk = 0;
    forever #5 rx_pclk = ~rx_pclk; // Example: 100MHz clock (10ns period)
end

// Reset generation
initial begin
    rst_n = 1'b0; // Assert reset (active low)
    #100;         // Hold reset for 100 ns
    rst_n = 1'b1; // Deassert reset
end

// Logic to convert single dilated bit to RGB output
always @(posedge rx_pclk) begin
    if (~rst_n) begin // Reset condition
        dilation_r <= 8'h00;
        dilation_g <= 8'h00;
        dilation_b <= 8'h00;
    end else begin
        // Assign white (FF) if dilated, black (00) otherwise
        dilation_r <= (dilation) ? 8'hFF : 8'h00;
        dilation_g <= (dilation) ? 8'hFF : 8'h00;
        dilation_b <= (dilation) ? 8'hFF : 8'h00;
    end
end

// Assign outputs for hdmi_out
assign tx_de 				= dilation_de;
assign tx_hsync 			= dilation_hsync;
assign tx_vsync 			= dilation_vsync;
assign tx_red         	    = dilation_r;
assign tx_green        	    = dilation_g;
assign tx_blue         	    = dilation_b;

// Instantiate the output sink (assuming it exists)
// If hdmi_out is not available, you might use $display or $writemem instead.
// Note: The original .hdmi_data port mapping is kept, assuming the
// hdmi_out module expects data in this specific packed format.
// If it expects separate R,G,B, change the connections accordingly.
hdmi_out file_output (
    .hdmi_clk(rx_pclk),
    .hdmi_vs(tx_vsync),
    .hdmi_hs(tx_hsync), // Added missing hsync connection, common for HDMI output modules
    .hdmi_de(tx_de),
    .hdmi_data({8'b0,tx_red,tx_green,tx_blue}) // Keep original format unless module definition dictates otherwise
    // Alternative if hdmi_out expects separate R,G,B:
    // .hdmi_r(tx_red),
    // .hdmi_g(tx_green),
    // .hdmi_b(tx_blue)
    );

// Optional: Simulation control
initial begin
    #50000; // Run simulation for 50,000 ns (adjust as needed)
    $finish;
end

endmodule