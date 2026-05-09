`timescale 1ns / 1ps
`timescale 1ns / 1ps
module maincore(
    input test_i,
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
wire clo,clk4x_unbuf,clk_lckd, clkdcm;
wire clk4x;
BUFG clk4x_bufg (.I(clk4x_unbuf), .O(clk4x));

reg [5:0] Red = 0;
reg [5:0] Blue = 0;
reg [5:0] Green = 0;
reg HSync = 1, VSync = 1, DataEnable = 0;
reg [10:0] ContadorX = 0; 
reg [10:0] ContadorY = 0; 
reg [7:0] SendFrames = 0;
DCM_SP #(
	.CLKIN_PERIOD	("62.5ns"), 
	.CLKFX_MULTIPLY	(4),
	.CLKFX_DIVIDE 		(1)
	)
dcm_main (
	.CLKIN   	(clk),
	.CLKFB   	(clo),
	.RST     	(1'b0),
	.CLK0    	(clkdcm),
	.CLKFX   	(clk4x_unbuf),
	.LOCKED  	(clk_lckd)
);
BUFG 	clk_bufg	(.I(clkdcm), 		.O(clo) ) ;
wire dft_clk4x;
assign dft_clk4x = test_i ? clk : clk4x;

video_lvds videoencoder (
    .DotClock(dft_clk4x), 
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
always @(posedge dft_clk4x)
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
							Parallax 	<= Parallax - 1;
							ContadorY 	<= 0;
							ContadorX 	<= 0;
					end
					else
							ContadorY <= ContadorY +1;
					end
			if(ContadorX == (ScreenX+BlankingHorizontal))
					ContadorX 	<= 0;
end
always @(posedge dft_clk4x)
begin
		if(ContadorX == ScreenX)
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
					Red		<= 255;
					Green		<= 0;
					Blue		<= 0;
			end
			else
			begin
					Red	 	<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) 	) * 2	);
					Blue 		<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) 	) * 3	);
					Green 	<= ( ( (ContadorY[5:0]+Parallax) ^ (ContadorX[5:0]+Parallax) 	) * 4	);
			end
		end
end
endmodule