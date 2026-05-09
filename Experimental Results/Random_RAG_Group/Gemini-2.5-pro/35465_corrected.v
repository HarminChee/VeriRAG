`timescale 1ns / 1ps
`timescale 1ns / 1ps
module maincore(
    input clk,
    input reset_n, // Added reset input
    input test_i,  // Added test mode input
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
reg [5:0] Red = 0;
reg [5:0] Blue = 0;
reg [5:0] Green = 0;
reg HSync = 1, VSync = 1, DataEnable = 0;
reg [10:0] ContadorX = 0;
reg [10:0] ContadorY = 0;
reg [7:0] SendFrames = 0; // Note: This register seems unused
wire dft_clk; // DFT clock selection

// DFT Clock Mux: Select functional clock (clk4x) or test clock (clk)
assign dft_clk = test_i ? clk : clk4x;

DCM_SP #(
	.CLKIN_PERIOD	("62.5ns"),
	.CLKFX_MULTIPLY	(4),
	.CLKFX_DIVIDE 		(1)
	)
dcm_main (
	.CLKIN   	(clk),
	.CLKFB   	(clo),
	.RST     	(~reset_n), // Connect reset to primary input
	.CLK0    	(clkdcm),
	.CLKFX   	(clk4x),
	.LOCKED  	(clk_lckd)
);
BUFG 	clk_bufg	(.I(clkdcm), 		.O(clo) ) ;
video_lvds videoencoder (
    .DotClock(dft_clk), // Use DFT controlled clock
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
// Timing generation logic - Clocked by dft_clk, with synchronous reset
always @(posedge dft_clk or negedge reset_n)
begin
    if (!reset_n) begin
        ContadorX <= 0;
        ContadorY <= 0;
        HSync <= 1;
        VSync <= 1;
        DataEnable <= 0;
        Parallax <= 0;
    end else begin
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
                        Parallax 	<= Parallax - 1; // Consider reset behavior if Parallax needs specific init
                        ContadorY 	<= 0;
                        ContadorX 	<= 0;
                end
                else
                        ContadorY <= ContadorY +1;
                end
        if(ContadorX == (ScreenX+BlankingHorizontal))
                ContadorX 	<= 0;
    end
end
// Color generation logic - Clocked by dft_clk, with synchronous reset
always @(posedge dft_clk or negedge reset_n)
begin
    if (!reset_n) begin
        Red <= 0;
        Green <= 0;
        Blue <= 0;
    end else begin
        if(ContadorX == ScreenX) // Use the synchronously updated ContadorX
        begin
                Blue 				<= 0;
                Red 				<= 0;
                Green 			<= 0;
        end
        else
        begin
            if( (ContadorX > 320 && ContadorY > 160) && ( ContadorX < 960 && ContadorY < 640) )
            begin
                Blue <= 0;
                Red <= 0;
                Green <= 0;
            end
            else if ( (ContadorX >= 317 && ContadorY >= 160 && ContadorY <= 640 && ContadorX <= 320) ||
                         (ContadorX >= 317 && ContadorY >= 157 && ContadorY <= 160 && ContadorX <= 963) ||
                         (ContadorX >= 960 && ContadorY >= 157 && ContadorY <= 640 && ContadorX <= 963) ||
                         (ContadorX >= 317 && ContadorY >= 640 && ContadorY <= 643 && ContadorX <= 963)  )
            begin
                    Red		<= 6'd63; // Assuming 6-bit color depth based on reg declaration
                    Green		<= 0;
                    Blue		<= 0;
            end
            else
            begin
                    // Ensure calculation fits within 6 bits
                    Red	 	<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) 	) * 2	) & 6'h3F;
                    Blue 		<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) 	) * 3	) & 6'h3F;
                    Green 	<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) 	) * 4	) & 6'h3F;
            end
        end
    end
end
endmodule