`timescale 1ns / 1ps

module maincore(
    input clk,
	 output channel1_p,
	 output channel1_n,
	 output channel2_p,
	 output channel2_n,
	 output channel3_p,
	 output channel3_n,
	 output clock_p,
	 output clock_n
    );

parameter ScreenX = 1280;
parameter ScreenY = 800;
parameter BlankingVertical = 12;
parameter BlankingHorizontal = 192;
localparam TotalX = ScreenX + BlankingHorizontal;
localparam TotalY = ScreenY + BlankingVertical;

wire clo, clk4x, clk_lckd, clkdcm;
reg [5:0] Red = 0;
reg [5:0] Blue = 0;
reg [5:0] Green = 0;
reg HSync = 1;
reg VSync = 1;
reg DataEnable = 0;
reg [10:0] ContadorX = 0;
reg [10:0] ContadorY = 0;
// reg [7:0] SendFrames = 0; // Removed unused register

// Note: Using string for CLKIN_PERIOD might not be portable, but kept as per original code structure.
// Consider using a real number (e.g., 62.5) or deriving from a parameter if issues arise.
DCM_SP #(
	.CLKIN_PERIOD	("62.5ns"), // Assuming 16MHz input clock (1/16MHz = 62.5ns)
	.CLKFX_MULTIPLY	(4),
	.CLKFX_DIVIDE 	(1)
	)
dcm_main (
	.CLKIN   	(clk),
	.CLKFB   	(clo),      // Corrected feedback connection
	.RST     	(1'b0),     // Consider adding a proper reset signal
	.CLK0    	(clkdcm),
	.CLKFX   	(clk4x),    // Output clock (16MHz * 4 / 1 = 64MHz)
	.LOCKED  	(clk_lckd)
);

BUFG clk_bufg (.I(clkdcm), .O(clo)); // BUFG output feeds back to DCM

video_lvds videoencoder (
    .DotClock(clk4x),
    .HSync(HSync),
    .VSync(VSync),
    .DataEnable(DataEnable),
    .Red(Red),
    .Green(Green),
    .Blue(Blue),
    .channel1_p(channel1_p),
    .channel1_n(channel1_n),
    .channel2_p(channel2_p),
    .channel2_n(channel2_n),
    .channel3_p(channel3_p),
    .channel3_n(channel3_n),
    .clock_p(clock_p),
    .clock_n(clock_n)
    );

reg [5:0] Parallax = 0;

// Timing generation logic
always @(posedge clk4x)
begin
    if (ContadorX == (TotalX - 1)) begin
        ContadorX <= 0;
        if (ContadorY == (TotalY - 1)) begin
            ContadorY <= 0;
            Parallax <= Parallax - 1; // Update Parallax at the end of the frame
        end else begin
            ContadorY <= ContadorY + 1;
        end
    end else begin
        ContadorX <= ContadorX + 1;
    end

    // HSync generation (active low during horizontal blanking)
    if (ContadorX >= ScreenX && ContadorX < (ScreenX + BlankingHorizontal - 1)) begin // Adjust active low period if needed
        HSync <= 0;
    end else begin
        HSync <= 1;
    end

    // VSync generation (active low during vertical blanking)
    if (ContadorY >= ScreenY && ContadorY < (ScreenY + BlankingVertical - 1)) begin // Adjust active low period if needed
        VSync <= 0;
    end else begin
        VSync <= 1;
    end

    // DataEnable generation (active high during active video)
    if (ContadorX < ScreenX && ContadorY < ScreenY) begin
        DataEnable <= 1;
    end else begin
        DataEnable <= 0;
    end
end

// Video pattern generation logic
always @(posedge clk4x)
begin
    if (DataEnable) begin // Generate color only when DataEnable is high
        // Draw a red border around a central black box
        if ( (ContadorX >= 317 && ContadorX <= 963) && (ContadorY >= 157 && ContadorY <= 643) ) begin // Area including border and box
            if ( (ContadorX > 320 && ContadorX < 960) && (ContadorY > 160 && ContadorY < 640) ) begin // Inner black box
                Red   <= 6'd0;
                Green <= 6'd0;
                Blue  <= 6'd0;
            end else begin // Red border
                Red   <= 6'd63; // Corrected max value for 6 bits
                Green <= 6'd0;
                Blue  <= 6'd0;
            end
        end else begin // Outside pattern
            // Calculation result will be truncated to 6 bits
            Red   <= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) ) * 2 );
            Green <= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) ) * 3 );
            Blue  <= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) ) * 4 );
        end
    end else begin // Blanking interval
        Red   <= 6'd0;
        Green <= 6'd0;
        Blue  <= 6'd0;
    end
end

// Dummy module definition for video_lvds if not provided elsewhere
// Replace with actual module if available
`ifndef VIDEO_LVDS_MODULE_DEFINED
`define VIDEO_LVDS_MODULE_DEFINED
module video_lvds (
    input DotClock,
    input HSync,
    input VSync,
    input DataEnable,
    input [5:0] Red,
    input [5:0] Green,
    input [5:0] Blue,
    output channel1_p,
    output channel1_n,
    output channel2_p,
    output channel2_n,
    output channel3_p,
    output channel3_n,
    output clock_p,
    output clock_n
    );
    // Dummy implementation: Assign outputs to avoid warnings/errors
    // In a real design, this would contain LVDS serialization and output logic
    assign channel1_p = 1'b0;
    assign channel1_n = 1'b0;
    assign channel2_p = 1'b0;
    assign channel2_n = 1'b0;
    assign channel3_p = 1'b0;
    assign channel3_n = 1'b0;
    assign clock_p = 1'b0;
    assign clock_n = 1'b0;

endmodule
`endif // VIDEO_LVDS_MODULE_DEFINED


endmodule