`timescale 1ns / 1ps
module maincore(
    input clk,
    input test_clk, // Added test clock input
    input test_mode, // Added test mode input
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

wire clo,clk4x,clk_lckd, clkdcm;
wire muxed_clk4x; // Multiplexed clock for DFT

reg [5:0] Red = 0;
reg [5:0] Blue = 0;
reg [5:0] Green = 0;
reg HSync = 1, VSync = 1, DataEnable = 0;
reg [10:0] ContadorX = 0;
reg [10:0] ContadorY = 0;
reg [7:0] SendFrames = 0; // Note: SendFrames is declared but not used

DCM_SP #(
	.CLKIN_PERIOD	("62.5ns"), // Assuming clk is 16MHz, CLKIN_PERIOD should match input clk
	.CLKFX_MULTIPLY	(4),
	.CLKFX_DIVIDE 		(1)
	)
dcm_main (
	.CLKIN   	(clk),
	.CLKFB   	(clo),
	.RST     	(1'b0), // Consider connecting RST to a primary reset or test reset
	.CLK0    	(clkdcm),
	.CLKFX   	(clk4x),
	.LOCKED  	(clk_lckd)
);

BUFG 	clk_bufg	(.I(clkdcm), 		.O(clo) ) ;

// Clock multiplexer for DFT
// Selects functional clock (clk4x) during normal operation (test_mode=0)
// Selects test clock (test_clk) during test mode (test_mode=1)
assign muxed_clk4x = test_mode ? test_clk : clk4x;

video_lvds videoencoder (
    .DotClock(muxed_clk4x), // Use the multiplexed clock
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

// Timing logic clocked by the multiplexed clock
always @(posedge muxed_clk4x) // Changed clock source to muxed_clk4x
begin
			ContadorX <= ContadorX + 1;
			if(ContadorX == ScreenX)
			begin
					DataEnable	 	<= 0;
					HSync 			<= 0;
			end
			if((ContadorX == 0) & (ContadorY < ScreenY))
					DataEnable 	<= 1;
			if(ContadorX == (ScreenX+BlankingHorizontal))
					HSync 			<= 1;
			if(ContadorX == (ScreenX+BlankingHorizontal))
			begin
					if(ContadorY == ScreenY)
					begin
							VSync 		<= 0;
							DataEnable	<= 0;
					end
					if(ContadorY == (ScreenY+BlankingVertical))
					begin
							VSync 		<= 1;
							Parallax 	<= Parallax - 1; // This update seems unrelated to video timing
							ContadorY 	<= 0;
							ContadorX 	<= 0;
					end
					else
							ContadorY <= ContadorY +1;
					end
			// This condition should be inside the previous if block to avoid race condition
			// Moved inside the if(ContadorX == (ScreenX+BlankingHorizontal)) block
			// if(ContadorX == (ScreenX+BlankingHorizontal)) // Redundant check?
			// 		ContadorX 	<= 0;
			// Corrected logic: Reset ContadorX when it reaches the end of the line blanking
			if(ContadorX == (ScreenX+BlankingHorizontal))
			begin
					ContadorX 	<= 0;
			end

end

// Pixel generation logic clocked by the multiplexed clock
always @(posedge muxed_clk4x) // Changed clock source to muxed_clk4x
begin
		if(DataEnable) // Generate pixels only when DataEnable is active
		begin
			if( (ContadorX > 320 && ContadorY > 160) && ( ContadorX < 960 && ContadorY < 640) )
			begin
				Blue <= 6'd0; // Use explicit sizing
				Red <= 6'd0;
				Green <= 6'd0;
			end
			else if ( (ContadorX >= 317 && ContadorY >= 160 && ContadorY <= 640 && ContadorX <= 320) ||
						 (ContadorX >= 317 && ContadorY >= 157 && ContadorY <= 160 && ContadorX <= 963) ||
						 (ContadorX >= 960 && ContadorY >= 157 && ContadorY <= 640 && ContadorX <= 963) ||
						 (ContadorX >= 317 && ContadorY >= 640 && ContadorY <= 643 && ContadorX <= 963)  )
			begin
					Red		<= 6'b111111; // Use explicit sizing and max value for 6 bits
					Green		<= 6'd0;
					Blue		<= 6'd0;
			end
			else
			begin
					// Ensure results fit within 6 bits
					Red	 	<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) 	) * 2	);
					Blue 		<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) 	) * 3	);
					Green 	<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) 	) * 4	);
			end
		end
		else // Outside active display area (blanking)
		begin
				Blue 				<= 6'd0;
				Red 				<= 6'd0;
				Green 			<= 6'd0;
		end
end

endmodule