`timescale 1ns / 1ps

module tb_bounding_box(
    );

// Inputs to DUT (driven by file_input or testbench logic)
wire rx_pclk;
wire rx_de;
wire rx_hsync;
wire rx_vsync;
wire [7:0] rx_red;
wire [7:0] rx_green;
wire [7:0] rx_blue;

// Outputs from DUT (used for drawing box and output)
wire [9:0] x_min;
wire [9:0] y_min;
wire [9:0] x_max;
wire [9:0] y_max;
wire [9:0] curr_h;
wire [9:0] curr_w;

// Outputs for display/file_output
wire tx_de;
wire tx_hsync;
wire tx_vsync;
wire [7:0] tx_red;
wire [7:0] tx_green;
wire [7:0] tx_blue;

// Placeholder for input stimulus (replace with actual stimulus generation if needed)
// Assumes hdmi_in drives the rx_* signals based on some input file/logic
hdmi_in file_input (
    .hdmi_clk(rx_pclk),
    .hdmi_de(rx_de),
    .hdmi_hs(rx_hsync),
    .hdmi_vs(rx_vsync),
    .hdmi_r(rx_red),
    .hdmi_g(rx_green),
    .hdmi_b(rx_blue)
    );

// Instantiate the DUT
bounding_box #
(
	.IMG_W(64), // Example size, adjust if needed
	.IMG_H(64)  // Example size, adjust if needed
)
box
(
    .clk(rx_pclk),
    .ce(1'b1),     // Assuming clock enable is always active
    .rst(1'b0),    // Assuming reset is inactive (active low reset would need pulsing)
    .de(rx_de),
    .hsync(rx_hsync),
    .vsync(rx_vsync),
    .mask((rx_red == 8'hFF) ? 1'b1 : 1'b0), // Example mask logic: object is pure red
    .x_min(x_min),
    .y_min(y_min),
	 .x_max(x_max),
    .y_max(y_max),
	 .c_h(curr_h), // Current row output from DUT
	 .c_w(curr_w)  // Current column output from DUT
);

// Logic to draw the bounding box overlay
reg [7:0] cross_r;
reg [7:0] cross_g;
reg [7:0] cross_b;
reg on_border = 0;

always @(posedge rx_pclk) begin
	// Check if the current pixel is on the border of the detected bounding box
	if (rx_de) begin // Only process active pixels
	    if(((curr_h >= y_min && curr_h <= y_max) && (curr_w == x_min || curr_w == x_max)) ||
	       ((curr_w >= x_min && curr_w <= x_max) && (curr_h == y_min || curr_h == y_max))) begin
	        on_border <= 1'b1;
	    end else begin
	        on_border <= 1'b0;
	    end
	end else begin
	    on_border <= 1'b0; // Not on border if data enable is low
	end

	// Assign output colors: Red for border, original pixel otherwise
	cross_r <= (on_border == 1'b1) ? 8'hFF : rx_red;
	cross_g <= (on_border == 1'b1) ? 8'h00 : rx_green; // Corrected: use rx_green
	cross_b <= (on_border == 1'b1) ? 8'h00 : rx_blue;  // Corrected: use rx_blue
end

// Assign outputs for display/file_output
assign tx_de    = rx_de;
assign tx_hsync = rx_hsync;
assign tx_vsync = rx_vsync;
assign tx_red   = cross_r;
assign tx_green = cross_g;
assign tx_blue  = cross_b;

// Placeholder for output handling (replace with actual verification/display logic)
// Assumes hdmi_out takes the tx_* signals and writes to a file/display
hdmi_out file_output (
    .hdmi_clk(rx_pclk),
    .hdmi_vs(tx_vsync),
    .hdmi_hs(tx_hsync), // Assuming hdmi_out needs hsync
    .hdmi_de(tx_de),
    .hdmi_data({tx_red, tx_green, tx_blue}) // Assuming 24-bit data format R,G,B
    );

// Add clock generation, reset sequence, and stimulus driving logic here
// Example clock generation (replace hdmi_in if generating clock here)
// reg rx_pclk_reg = 0;
// initial begin
//     forever #5 rx_pclk_reg = ~rx_pclk_reg; // 10ns period = 100MHz
// end
// assign rx_pclk = rx_pclk_reg;

// Add simulation control
// initial begin
//     // Apply reset if needed
//     // Drive input signals (rx_de, rx_hsync, rx_vsync, rx_red, etc.)
//     // Wait for simulation to complete
//     #10000;
//     $finish;
// end

endmodule

// Note: Assumed definitions for hdmi_in and hdmi_out modules.
// Note: Assumed IMG_W and IMG_H match the bounding_box module parameters.
// Note: A real testbench would need clock generation, reset logic,
//       and stimulus generation for the rx_* signals instead of relying
//       solely on the placeholder hdmi_in module.