module collider(cclk, bx, by, ptop, pbot, reset, collide);
	parameter px = 0;
	parameter pw = 16;
	input cclk;
	input [9:0]bx;
	input [9:0]by; 
	input [9:0]ptop;
	input [9:0]pbot;
	input reset;
	output reg collide;
	always @(posedge cclk or posedge reset) begin
		if (cclk) begin
			collide <= (bx >= px && bx <= (px + pw)) && (by+4 >= ptop && by-4 <= pbot); 
		end 
		else begin
			collide <= 0;
		end
	end
endmodule
module vga(clk,scan_rst,test_i, LED1, LED2,scan_clk, VSYNC, HSYNC, RED, GREEN, BLUE, MISO, MOSI, SCK, SCS, SOUND, BATON1, BATON2);
input clk;
input scan_rst,test_i,scan_clk;
output LED1;
output LED2;
output VSYNC;
output HSYNC;
output RED, GREEN, BLUE;
input MISO;
output MOSI;
output SCK;
output SCS;
output SOUND;
input BATON1;
input BATON2;
wand RED;
wand GREEN;
wand BLUE;
parameter SCREENWIDTH = 10'd640;
parameter SCREENHEIGHT = 10'd480;
parameter PADDLESIZE = 10'd64;
parameter BALLSIZE = 8;
wire paddle_scan,dft_clk;
wire ball_scan;
wire[9:0] paddleA_y;			
wire[9:0] paddleB_y_manual;		
wire[9:0] paddleB_y_robot;		
reg [9:0] paddleB_y;			
reg playerBswitch;				
reg clkdiv8;					
wire dft_clkdiv8;
assign dft_clkdiv8 = test_i ? clk : clkdiv8;
reg [6:0] clkdiv8_cnt;
assign dft_clk = test_i ? scan_clk : clk ;
always @(posedge clk) begin
	if (clkdiv8_cnt == 0)
		clkdiv8 <= !clkdiv8;
	clkdiv8_cnt <= clkdiv8_cnt - 1'b1;
end
reg [7:0] paddle_cnt;				
reg [6:0] ball_cnt;
reg paddleAdvance;
reg ballAdvance;
wire dft_playerBbutton;
always @(posedge dft_clkdiv8) begin
	paddle_cnt <= paddle_cnt - 1'b1;
	ball_cnt <= ball_cnt - 1'b1;
	if (ball_cnt == 0) ball_cnt <= 7'b1100000;
end
always @(posedge dft_clk) paddleAdvance = paddle_cnt == 0;
always @(posedge dft_clk) ballAdvance = ball_cnt == 0;
wire resetpulse,dft_resetpulse;			
assign dft_resetpulse = test_i ? scan_rst : resetpulse ;
wire gamereset;				
resetgen resetgen(clk, resetpulse, 1);	
button2 #(8192) gameresetter(clkdiv8, gamereset, BATON1);
button2 #(8192) button2(clkdiv8, playerBbutton, BATON2);
assign dft_playerBbutton = test_i ? scan_clk : playerBbutton ;
always @(posedge dft_playerBbutton or posedge dft_resetpulse) begin
	if (dft_resetpulse) 
		playerBswitch <= 1;
	else 
		playerBswitch <= !playerBswitch;
end
assign LED2 = playerBswitch;
wire[9:0] realx;				
wire[9:0] realy;				
wire videoActive;				
wire xscanstart, xscanend;		
vgascan vgascan(dft_clk, HSYNC, VSYNC, realx, realy, videoActive, xscanstart, xscanend);
analinput #(PADDLESIZE, SCREENHEIGHT) analinput(clkdiv8, paddleA_y, paddleB_y_manual, MISO, MOSI, SCS, SCK);
wire[9:0] ball_y;
robohand #(PADDLESIZE,SCREENHEIGHT) paddleB(resetpulse, paddleAdvance, ball_y, paddleB_y_robot);
always @(posedge dft_clkdiv8) begin
	paddleB_y <= playerBswitch ? paddleB_y_manual : paddleB_y_robot;
end
tehgame teh(clk, clkdiv8, resetpulse, gamereset, HSYNC, realx, realy, paddleA_y, paddleB_y, ballAdvance, {ball_scan, paddle_scan, score_scan}, ball_y, SOUND, LED1);
wire border_scan;
borderscan #(640,480) borderscan(clk, xscanstart, xscanend, realy, border_scan);
reg [3:0] netcnt;
always @(posedge dft_clk) begin
	if (realx == SCREENWIDTH/2 && realy[1])
		netcnt = 4;
	if (netcnt != 0) netcnt = netcnt - 1'b1;
end
wire net_scan = netcnt != 0;
wire bgr, bgg, bgb;
bgfill bgfill(clk, HSYNC, VSYNC, bgr, bgg, bgb);
reg red, green, blue;
always @(negedge dft_clk) begin
	red 	<= videoActive & (bgr | paddle_scan | border_scan | ball_scan | score_scan);
	green 	<= videoActive & (bgg | paddle_scan | border_scan | ball_scan | net_scan | score_scan);
	blue 	<= videoActive & (bgb | paddle_scan | border_scan | ball_scan);
end
assign RED = red;
assign GREEN = green;
assign BLUE = blue;
endmodule
module borderscan(clk, xstart, xend, realy, q);
	parameter SCREENWIDTH = 0;
	parameter SCREENHEIGHT = 0;
	input clk, xstart, xend;
	input [9:0] realy;
	output q;
	assign q = xstart | xend | realy == 0 | realy == SCREENHEIGHT - 1;
endmodule
module bgfill(clk, test_i,hsync,scan_hsync, vsync, r, g, b);
	input clk, hsync, vsync,test_i,scan_hsync;
	output r, g, b;
	reg ff1, ff2;
	always @(negedge clk) begin
		if (vsync)
			ff1 <= ~ff1;
		else ff1 <= 0;
	end
	wire dft_hsync;
	assign dft_hsync = test_i ? scan_hsync : hsync ;
	always @(negedge dft_hsync) begin
		if (vsync)
			ff2 <= ~ff2;
		else ff2 <= 0;
	end
	assign r = (1'b0 &  ~(ff1^ff2));
	assign g = (1'b0 & (ff1^ff2));
	assign b = (1'b1 & (ff1^ff2));
endmodule
module collider(cclk, bx, by, ptop, pbot, reset, collide);
	parameter px = 0;
	parameter pw = 16;
	input cclk;
	input [9:0]bx;
	input [9:0]by; 
	input [9:0]ptop;
	input [9:0]pbot;
	input reset;
	output reg collide;
	always @(posedge cclk or posedge reset) begin
		if (cclk) begin
			collide <= (bx >= px && bx <= (px + pw)) && (by+4 >= ptop && by-4 <= pbot); 
		end 
		else begin
			collide <= 0;
		end
	end
endmodule
