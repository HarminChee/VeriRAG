`timescale 1ns / 1ps

module tb_erosion3x3 (
    );

// Interface signals from input source (e.g., file reader)
wire rx_pclk;
wire rx_de;
wire rx_hsync;
wire rx_vsync;
wire [7:0] rx_red;
wire [7:0] rx_green;
wire [7:0] rx_blue;

// Interface signals to output sink (e.g., file writer)
wire tx_de;
wire tx_hsync;
wire tx_vsync;
wire [7:0] tx_red;
wire [7:0] tx_green;
wire [7:0] tx_blue;

// Reset signal for the DUT
reg rst;

// Instantiate the input source model
hdmi_in file_input (
    .hdmi_clk(rx_pclk),
    .hdmi_de(rx_de),
    .hdmi_hs(rx_hsync),
    .hdmi_vs(rx_vsync),
    .hdmi_r(rx_red),
    .hdmi_g(rx_green),
    .hdmi_b(rx_blue)
    );

// Internal signals for erosion output
wire erosion;
wire erosion_de;
wire erosion_vsync;
wire erosion_hsync;

// Registers to hold the processed color data based on erosion output
reg [7:0] erosion_r;
reg [7:0] erosion_g;
reg [7:0] erosion_b;

// Instantiate the Design Under Test (DUT)
erosion3x3 #
(
    .H_SIZE(10'd830) // Example H_SIZE, adjust as needed for actual resolution
)
erode3
(
    .clk(rx_pclk),
    .ce(1'b1),       // Assuming clock enable is always active
    .rst(rst),       // Connect reset signal
    .mask((rx_red > 8'd128) ? 1'b1 : 1'b0), // Example mask generation (e.g., based on threshold)
    .in_de(rx_de),
    .in_vsync(rx_vsync),
    .in_hsync(rx_hsync),
    .eroded(erosion),
    .out_de(erosion_de),
    .out_vsync(erosion_vsync),
    .out_hsync(erosion_hsync)
);

// Generate reset sequence
initial begin
    rst = 1'b1; // Assert reset
    #50;        // Hold reset for 50 time units (adjust as needed)
    rst = 1'b0; // Deassert reset
end

// Logic to generate output color based on erosion result
// Assigns white (FF) if eroded, black (00) otherwise
always @(posedge rx_pclk) begin
    if (rst) begin
        erosion_r <= 8'h00;
        erosion_g <= 8'h00;
        erosion_b <= 8'h00;
    end else begin
        // Latch based on the output valid signal (erosion_de)
        if (erosion_de) begin
            erosion_r <= (erosion) ? 8'hFF : 8'h00;
            erosion_g <= (erosion) ? 8'hFF : 8'h00;
            erosion_b <= (erosion) ? 8'hFF : 8'h00;
        end
        // Optionally hold previous value or set to default if not erosion_de
        // else begin
        //    erosion_r <= erosion_r; // Hold value
        //    erosion_g <= erosion_g;
        //    erosion_b <= erosion_b;
        // end
   end
end

// Connect processed signals to output interface wires
assign tx_de    = erosion_de;
assign tx_hsync = erosion_hsync;
assign tx_vsync = erosion_vsync;
assign tx_red   = erosion_r;
assign tx_green = erosion_g;
assign tx_blue  = erosion_b;

// Instantiate the output sink model
hdmi_out file_output (
    .hdmi_clk(rx_pclk),
    .hdmi_vs(tx_vsync),
    .hdmi_hs(tx_hsync), // Assuming hdmi_out needs hsync
    .hdmi_de(tx_de),
    .hdmi_data({tx_red, tx_green, tx_blue}) // Assuming 24-bit data {R,G,B}
    );

// Optional: Add simulation control (e.g., run for a specific time)
// initial begin
//     #100000; // Run simulation for 100,000 time units
//     $finish;
// end

endmodule