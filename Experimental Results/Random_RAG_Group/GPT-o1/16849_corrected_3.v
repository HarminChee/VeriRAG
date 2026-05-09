`timescale 1ns / 1ps
module VGAInterface(
	input test_i,
	input aresetPll,
	input CLOCK_50,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS
);

wire  pixelClock;
wire  [10:0] XPixelPosition;
wire  [10:0] YPixelPosition; 
reg   [7:0] redValue;
reg   [7:0] greenValue;
reg   [7:0] blueValue;

reg   [1:0] movement = 0;
parameter r = 15;

reg  [20:0] slowClockCounter = 0;
wire slowClock;

reg  [20:0] fastClockCounter = 0;
wire fastClock;

reg  [10:0] XDotPosition = 500;
reg  [10:0] YDotPosition = 500; 

reg  [10:0] P1x = 225;
reg  [10:0] P1y = 500;

reg  [10:0] P2x = 1030;
reg  [10:0] P2y = 500;

reg  [3:0] P1Score = 0;
reg  [3:0] P2Score = 0;
reg  flag = 1'b0;

wire dft_slowClock;
wire dft_fastClock;
wire dft_pixelClock;
assign dft_slowClock = test_i ? CLOCK_50 : slowClock;
assign dft_fastClock = test_i ? CLOCK_50 : fastClock;
assign dft_pixelClock = test_i ? CLOCK_50 : pixelClock;

assign LEDR[10:0] = SW[1] ? YDotPosition : XDotPosition;
assign LEDR[17:11] = 7'b0000000;
assign LEDG = 9'b000000000;

assign slowClock = slowClockCounter[16];
always@(posedge CLOCK_50)
begin
	slowClockCounter <= slowClockCounter + 1;
end

assign fastClock = fastClockCounter[17];
always@(posedge CLOCK_50)
begin
	fastClockCounter <= fastClockCounter + 1;
end

always@(posedge dft_fastClock)
begin
	if (SW[0] == 1'b0) 
	begin
		if (KEY[2] == 1'b0 && KEY[3] == 1'b0) 
			P1y <= P1y;
		else if (KEY[2] == 1'b0) 
		begin
			if (P1y+125 > 896)
				P1y <= 771;
			else
				P1y <= P1y + 1;
		end
		else if (KEY[3] == 1'b0) 
		begin
			if(P1y < 128)
				P1y <= 128;
			else
				P1y <= P1y - 1;
		end
	end
	else if (SW[0] == 1'b1 || flag == 1)
		P1y <= 500;
end

always@(posedge dft_fastClock)
begin
	if (SW[0] == 1'b0) 
	begin
		if (KEY[0] == 1'b0 && KEY[1] == 1'b0)
			P2y <= P2y;
		else if (KEY[0] == 1'b0)
		begin
			if(P2y+125 > 896)
				P2y <= 771;
			else
				P2y <= P2y + 1;
		end
		else if (KEY[1] == 1'b0)
		begin
			if(P2y < 128)
				P2y <= 128;
			else
				P2y <= P2y - 1;
		end
	end
	else if (SW[0] == 1'b1 || flag == 1)
		P2y <= 500;
end

always@(posedge dft_slowClock)
begin
	if (SW[0] == 1'b0)
	begin
		case(movement)
			0:	begin
					XDotPosition <= XDotPosition + 1;
					YDotPosition <= YDotPosition - 1;
				end
			1:	begin
					XDotPosition <= XDotPosition + 1;
					YDotPosition <= YDotPosition + 1;
				end
			2:	begin
					XDotPosition <= XDotPosition - 1;
					YDotPosition <= YDotPosition + 1;
				end
			3:	begin
					XDotPosition <= XDotPosition - 1;
					YDotPosition <= YDotPosition - 1;
				end
			default: movement <= movement;
		endcase
		
		if(YDotPosition - r <= 128 && movement == 0)
			movement <= 1;
		else if (YDotPosition - r <= 128 && movement == 3)
			movement <= 2;
		else if (YDotPosition + r >= 896 && movement == 1)
			movement <= 0;
		else if (YDotPosition + r >= 896 && movement == 2)
			movement <= 3;
		else if (XDotPosition - r <= P1x+25 && YDotPosition > P1y && YDotPosition < P1y+125 &&  movement == 2)
			movement <= 1;
		else if (XDotPosition - r <= P1x+25 && YDotPosition > P1y && YDotPosition < P1y+125 &&  movement == 3)
			movement <= 0;
		else if (XDotPosition + r >= P2x && YDotPosition > P2y && YDotPosition < P2y+125 && movement == 1)
			movement <= 2;
		else if (XDotPosition + r >= P2x && YDotPosition > P2y && YDotPosition < P2y+125 && movement == 0)
			movement <= 3;
		else if (XDotPosition - r <= 160)
		begin
			P2Score <= P2Score + 1;
			XDotPosition <= 640;
			YDotPosition <= 512;
		end
		else if (XDotPosition + r >= 1120)
		begin
			P1Score <= P1Score + 1;
			XDotPosition <= 640;
			YDotPosition <= 512;
		end
		
		if(P1Score == 10 || P2Score == 10)
		begin
			P1Score <= 0;
			P2Score <= 0;
			flag <= 1;
		end
	end
	else
	begin
		XDotPosition <= 500;
		YDotPosition <= 500;
		P1Score <= 0;
		P2Score <= 0;
	end
end

VGAFrequency VGAFreq (aresetPll, CLOCK_50, pixelClock);
VGAController VGAControl (pixelClock, redValue, greenValue, blueValue, VGA_R, VGA_G, VGA_B, VGA_VS, VGA_HS, XPixelPosition, YPixelPosition);

always@ (posedge dft_pixelClock)
begin		
	if (XPixelPosition < 160)
	begin
		redValue <= 8'b00000000; 
		blueValue <= 8'b00000000;
		greenValue <= 8'b11111111;
	end
	else if (XPixelPosition > 1120)
	begin
		redValue <= 8'b00000000; 
		blueValue <= 8'b00000000;
		greenValue <= 8'b11111111;
	end
	else if (YPixelPosition < 128 && XPixelPosition > 160 && XPixelPosition < 1120)
	begin
		redValue <= 8'b11111111; 
		blueValue <= 8'b11111111;
		greenValue <= 8'b00000000;
	end
	else if (XPixelPosition < 1120 && XPixelPosition > 160 && YPixelPosition > 896)
	begin
		redValue <= 8'b11111111; 
		blueValue <= 8'b11111111;
		greenValue <= 8'b00000000;
	end
	else if (XPixelPosition > P1x && XPixelPosition < P1x+25 && YPixelPosition > P1y && YPixelPosition < P1y+125)
	begin
		redValue <= 8'b00000000; 
		blueValue <= 8'b11111111;
		greenValue <= 8'b11111111;
	end
	else if (XPixelPosition > P2x && XPixelPosition < P2x+25 && YPixelPosition > P2y && YPixelPosition < P2y+125)
	begin
		redValue <= 8'b00000000; 
		blueValue <= 8'b11111111;
		greenValue <= 8'b11111111;
	end
	else if (((XPixelPosition - XDotPosition)*(XPixelPosition - XDotPosition) + (YPixelPosition - YDotPosition)*(YPixelPosition - YDotPosition)) < (15*15))
	begin
		redValue <= 8'b11111111; 
		blueValue <= 8'b00000000;
		greenValue <= 8'b00000000;
	end
	else
	begin
		redValue <= 8'b00000000; 
		blueValue <= 8'b00000000;
		greenValue <= 8'b00000000;
	end
end

ScoreDecoder p1(P1Score, HEX7, HEX6);
ScoreDecoder p2(P2Score, HEX5, HEX4);
assign HEX3 = 7'b0000000;
assign HEX2 = 7'b0000000;
assign HEX1 = 7'b0000000;
assign HEX0 = 7'b0000000;

assign VGA_BLANK_N = 1'b1;
assign VGA_SYNC_N = 1'b1;			
assign VGA_CLK = pixelClock;

endmodule