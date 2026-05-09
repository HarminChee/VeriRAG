`timescale 1ns / 1ps

module tb_opening3x3();

// Clock and Reset generation
reg rx_pclk;
reg rst;

// Input signals (driven by hdmi_in)
wire rx_de;
wire rx_hsync;
wire rx_vsync;
wire [7:0] rx_red;
wire [7:0] rx_green;
wire [7:0] rx_blue;

// Output signals (driven to hdmi_out)
wire tx_de;
wire tx_hsync;
wire tx_vsync;
wire [7:0] tx_red;
wire [7:0] tx_green;
wire [7:0] tx_blue;

// Intermediate signals for opening result
reg [7:0] opening_r;
reg [7:0] opening_g;
reg [7:0] opening_b;
wire opening;
wire opening_de;
wire opening_vsync;
wire opening_hsync;

// Instantiate the input simulation module
hdmi_in file_input (
    .hdmi_clk(rx_pclk),
    .hdmi_de(rx_de),
    .hdmi_hs(rx_hsync),
    .hdmi_vs(rx_vsync),
    .hdmi_r(rx_red),
    .hdmi_g(rx_green),
    .hdmi_b(rx_blue)
);

// Instantiate the DUT (Device Under Test)
opening3x3 #
(
	.H_SIZE(10'd83) // Example size, adjust as needed
)
open3
(
	.clk(rx_pclk),
	.ce(1'b1), // Assuming clock enable is always active
	.rst(rst), // Connect reset
	.mask((rx_red == 8'hFF) ? 1'b1 : 1'b0), // Mask based on input red channel
	.in_de(rx_de),
	.in_vsync(rx_vsync),
	.in_hsync(rx_hsync),
	.opened(opening),
	.out_de(opening_de),
	.out_vsync(opening_vsync),
	.out_hsync(opening_hsync)
);

// Generate clock signal (e.g., 100 MHz -> 10 ns period)
parameter CLK_PERIOD = 10;
initial begin
    rx_pclk = 1'b0;
    forever #(CLK_PERIOD / 2) rx_pclk = ~rx_pclk;
end

// Generate reset signal
initial begin
    rst = 1'b1;
    #(CLK_PERIOD * 5); // Hold reset for 5 clock cycles
    rst = 1'b0;
end

// Logic to determine output RGB based on 'opening' signal
always @(posedge rx_pclk) begin
    if (rst) begin
        opening_r <= 8'h00;
        opening_g <= 8'h00;
        opening_b <= 8'h00;
    end else begin
        // Assign output color based on the opening result
        // If 'opening' is true (pixel survived opening), set to white (FF), else black (00)
        opening_r <= (opening) ? 8'hFF : 8'h00;
        opening_g <= (opening) ? 8'hFF : 8'h00;
        opening_b <= (opening) ? 8'hFF : 8'h00;
    end
end

// Connect intermediate signals to output wires
assign tx_de    = opening_de;
assign tx_hsync = opening_hsync;
assign tx_vsync = opening_vsync;
assign tx_red   = opening_r;
assign tx_green = opening_g;
assign tx_blue  = opening_b;

// Instantiate the output simulation module
hdmi_out file_output (
    .hdmi_clk(rx_pclk),
    .hdmi_vs(tx_vsync),
    .hdmi_hs(tx_hsync), // Added missing hsync connection assumed by name
    .hdmi_de(tx_de),
    // Assuming hdmi_data expects 32 bits: {unused[7:0], R[7:0], G[7:0], B[7:0]}
    .hdmi_data({8'b0, tx_red, tx_green, tx_blue})
);

// Optional: Simulation control
initial begin
    // Add simulation timeout or specific stimulus control if needed
    // For example, wait for a certain number of frames or time
    #100000; // Simulate for 100,000 ns
    $finish;
end

endmodule