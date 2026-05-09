`timescale 1ns / 1ps

module tb_centro();

// Clock and Reset for the testbench
reg rx_pclk;
reg rst;

// Signals from HDMI Input (Stimulus Generator)
wire rx_de;
wire rx_hsync;
wire rx_vsync;
wire [7:0] rx_red;
wire [7:0] rx_green;
wire [7:0] rx_blue;

// Signals for HDMI Output (DUT Output + Overlay)
wire tx_de;
wire tx_hsync;
wire tx_vsync;
wire [7:0] tx_red;
wire [7:0] tx_green;
wire [7:0] tx_blue;

// Instantiate the HDMI Input stimulus module
// Assumes hdmi_in generates the rx_* signals based on rx_pclk
hdmi_in file_input (
    .hdmi_clk(rx_pclk),
    .hdmi_de(rx_de),
    .hdmi_hs(rx_hsync),
    .hdmi_vs(rx_vsync),
    .hdmi_r(rx_red),
    .hdmi_g(rx_green),
    .hdmi_b(rx_blue)
);

// Registers for crosshair overlay logic
reg [7:0] cross_r;
reg [7:0] cross_g;
reg [7:0] cross_b;

// Wires for centroid calculation outputs
wire [9:0] centr_x;
wire [9:0] centr_y;
wire [9:0] curr_h; // Current row (Y) from DUT
wire [9:0] curr_w; // Current column (X) from DUT

// Instantiate the DUT (Device Under Test)
centroid #
(
    .IMG_W(64), // Example image width
    .IMG_H(64)  // Example image height
)
centro
(
    .clk(rx_pclk),
    .ce(1'b1),      // Clock enable always high in this TB
    .rst(rst),      // Connect testbench reset
    .de(rx_de),
    .hsync(rx_hsync),
    .vsync(rx_vsync),
    .mask((rx_red == 8'hFF) ? 1'b1 : 1'b0), // Example mask: pixel is white
    .x(centr_x),
    .y(centr_y),
    .c_h(curr_h),
    .c_w(curr_w)
);

// Clock Generation
initial begin
    rx_pclk = 1'b0;
end
always #5 rx_pclk = ~rx_pclk; // 100 MHz clock (period = 10ns)

// Reset Generation and Simulation Control
initial begin
    rst = 1'b1; // Assert reset
    #20;        // Wait for 20 ns
    rst = 1'b0; // Deassert reset
    #20000;     // Simulate for 20000 ns (adjust as needed)
    $finish;    // End simulation
end

// Logic to create crosshair overlay on the output image
// Runs on the clock edge
always @(posedge rx_pclk) begin
    if (rst) begin // Reset crosshair registers
        cross_r <= 8'b0;
        cross_g <= 8'b0;
        cross_b <= 8'b0;
    end else if (rx_de) begin // Only modify active pixel data
        // If current pixel matches centroid X or Y, draw red crosshair
        if (curr_h == centr_y || curr_w == centr_x) begin
            cross_r <= 8'hFF; // Red color for crosshair
            cross_g <= 8'h00;
            cross_b <= 8'h00;
        end else begin
            // Otherwise, pass through the input pixel data
            cross_r <= rx_red;
            cross_g <= rx_green;
            cross_b <= rx_blue;
        end
    end else begin // Outside active pixel area, output black (or keep previous)
         cross_r <= 8'b0;
         cross_g <= 8'b0;
         cross_b <= 8'b0;
    end
end

// Assign output HDMI signals
// Pass through timing signals directly
assign tx_de    = rx_de;
assign tx_hsync = rx_hsync;
assign tx_vsync = rx_vsync;
// Assign color data from the crosshair overlay logic
assign tx_red   = cross_r;
assign tx_green = cross_g;
assign tx_blue  = cross_b;

// Instantiate the HDMI Output module
// Assumes hdmi_out takes the tx_* signals and processes/saves them
hdmi_out file_output (
    .hdmi_clk(rx_pclk),
    .hdmi_vs(tx_vsync), // Assuming hdmi_out needs vsync
    .hdmi_de(tx_de),    // Assuming hdmi_out needs de
    .hdmi_data({8'b0, tx_red, tx_green, tx_blue}) // Example 32-bit data format
    // .hdmi_hs(tx_hsync) // Add if hdmi_out module requires hsync
);

endmodule