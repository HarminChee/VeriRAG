`timescale 1ns / 1ps
`timescale 1ns / 1ps
module vgachar(
    input wire clk,
	input wire clr,
	input wire cBlink,
	input wire [6:0] char,
	input wire [7:0] fontcolor,
	input wire [7:0] backcolor,
	input wire Blink,
	input wire xsync,
	input wire ysync,
	input wire [11:0] xpos,
	input wire [11:0] ypos,
	input wire valid,
	output reg [2:0] vgaRed,
	output reg [2:0] vgaGreen,
	output reg [2:1] vgaBlue,
	output reg hsync,
	output reg vsync
    );
wire [10:0] addra;
wire [7:0] douta;
wire pixel;
asciifont fontmap (
  .a(addra), 
  .spo({douta[0], douta[1], douta[2], douta[3],
        douta[4], douta[5], douta[6], douta[7]}) 
);
assign addra = {char, ypos[3:0]};
assign pixel = douta[xpos[2:0]];
always @(posedge clk or posedge clr)
    if(clr == 1) begin
	    vgaRed <= 3'b000;
		vgaGreen <= 3'b000;
		vgaBlue[2:1] <= 2'b00;
		hsync <= 0;
		vsync <= 0;
	end else begin
		hsync <= xsync;
		vsync <= ysync;
		if(valid == 0) begin
			vgaRed <= 3'b000;
			vgaGreen <= 3'b000;
			vgaBlue[2:1] <= 2'b00;
		end else if(pixel && ~(Blink && cBlink)) begin
			vgaRed <= fontcolor[7:5];
			vgaGreen <= fontcolor[4:2];
			vgaBlue[2:1] <= fontcolor[1:0];
		end else begin
		    vgaRed <= backcolor[7:5];
			vgaGreen <= backcolor[4:2];
			vgaBlue[2:1] <= backcolor[1:0];
		end
	end
endmodule
