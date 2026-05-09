`timescale 1ns / 1ps
`timescale 1ns / 1ps
module generador_caracteres
(
input wire clk,
input wire [3:0] digit0_HH, digit1_HH, digit0_MM, digit1_MM, digit0_SS, digit1_SS,
digit0_DAY, digit1_DAY, digit0_MES, digit1_MES, digit0_YEAR, digit1_YEAR,
digit0_HH_T, digit1_HH_T, digit0_MM_T, digit1_MM_T, digit0_SS_T, digit1_SS_T,
input wire AM_PM,
input wire parpadeo,
input wire [1:0] config_mode,
input wire [1:0] cursor_location,
input wire [9:0] pixel_x, pixel_y,
output wire AMPM_on, 
output wire text_on, 
output reg [7:0] text_RGB 
);
wire [11:0] rom_addr; 
reg [6:0] char_addr; 
reg [4:0] row_addr; 
reg [3:0] bit_addr; 
wire [15:0] font_word;
wire font_bit;
reg [6:0] char_addr_digHORA, char_addr_digFECHA, char_addr_digTIMER, char_addr_AMPM;
wire [4:0] row_addr_digHORA, row_addr_digFECHA, row_addr_digTIMER,  row_addr_AMPM;
wire [3:0] bit_addr_digHORA, bit_addr_digFECHA, bit_addr_digTIMER, bit_addr_AMPM; 
wire digHORA_on, digFECHA_on, digTIMER_on;
ROM_16x32 Instancia_ROM_16x32
(.clk(clk), .addr(rom_addr), .data(font_word));
assign digHORA_on = (pixel_y[9:5]==4)&&(pixel_x[9:4]>=16)&&(pixel_x[9:4]<=23);
assign row_addr_digHORA = pixel_y[4:0];
assign bit_addr_digHORA = pixel_x[3:0];
always@*
begin
	case(pixel_x[6:4])
	3'b000: char_addr_digHORA = {3'b011, digit1_HH};
	3'b001: char_addr_digHORA = {3'b011, digit0_HH};
	3'b010: char_addr_digHORA = 7'h3a;
	3'b011: char_addr_digHORA = {3'b011, digit1_MM};
	3'b100: char_addr_digHORA = {3'b011, digit0_MM};
	3'b101: char_addr_digHORA = 7'h3a;
	3'b110: char_addr_digHORA = {3'b011, digit1_SS};
	3'b111: char_addr_digHORA = {3'b011, digit0_SS};
	endcase
end
assign digFECHA_on = (pixel_y[9:5]==12)&&(pixel_x[9:4]>=7)&&(pixel_x[9:4]<=14);
assign row_addr_digFECHA = pixel_y[4:0];
assign bit_addr_digFECHA = pixel_x[3:0];
always@*
begin
	case(pixel_x[6:4])
	3'b111: char_addr_digFECHA = {3'b011, digit1_DAY};
	3'b000: char_addr_digFECHA = {3'b011, digit0_DAY};
	3'b001: char_addr_digFECHA = 7'h2f;
	3'b010: char_addr_digFECHA = {3'b011, digit1_MES};
	3'b011: char_addr_digFECHA = {3'b011, digit0_MES};
	3'b100: char_addr_digFECHA = 7'h2f;
	3'b101: char_addr_digFECHA = {3'b011, digit1_YEAR};
	3'b110: char_addr_digFECHA = {3'b011, digit0_YEAR};
	endcase	
end
assign digTIMER_on = (pixel_y[9:5]==12)&&(pixel_x[9:4]>=25)&&(pixel_x[9:4]<=32);
assign row_addr_digTIMER = pixel_y[4:0];
assign bit_addr_digTIMER = pixel_x[3:0];
always@*
begin
	case(pixel_x[6:4])
	3'b001: char_addr_digTIMER = {3'b011, digit1_HH_T};
	3'b010: char_addr_digTIMER = {3'b011, digit0_HH_T};
	3'b011: char_addr_digTIMER = 7'h3a;
	3'b100: char_addr_digTIMER = {3'b011, digit1_MM_T};
	3'b101: char_addr_digTIMER = {3'b011, digit0_MM_T};
	3'b110: char_addr_digTIMER = 7'h3a;
	3'b111: char_addr_digTIMER = {3'b011, digit1_SS_T};
	3'b000: char_addr_digTIMER = {3'b011, digit0_SS_T};
	endcase	
end
assign AMPM_on = (pixel_y[9:5]==1)&&(pixel_x[9:4]>=26)&&(pixel_x[9:4]<=27);
assign row_addr_AMPM = pixel_y[4:0];
assign bit_addr_AMPM = pixel_x[3:0];
always@*
begin
	case(pixel_x[4])
	1'b0:
	begin
	case(AM_PM)
	1'b0: char_addr_AMPM = 7'h61;
	1'b1: char_addr_AMPM = 7'h64;
	endcase
	end
	1'b1: char_addr_AMPM = 7'h63;
	endcase	
end
always @*
begin
text_RGB = 8'b0;
	if(digHORA_on)
		begin
		char_addr = char_addr_digHORA;
      row_addr = row_addr_digHORA;
      bit_addr = bit_addr_digHORA;
			if(font_bit) text_RGB = 8'h00; 
			else if ((parpadeo)&&(~font_bit)&&(config_mode == 1)&&(pixel_y[9:5]==4)&&(pixel_x[9:4]>=16)&&(pixel_x[9:4]<=17)&&(cursor_location==2)) 
			text_RGB =8'hFF;
			else if ((parpadeo)&&(~font_bit)&&(config_mode == 1)&&(pixel_y[9:5]==4)&&(pixel_x[9:4]>=19)&&(pixel_x[9:4]<=20)&&(cursor_location==1))
			text_RGB = 8'hFF;
			else if ((parpadeo)&&(~font_bit)&&(config_mode == 1)&&(pixel_y[9:5]==4)&&(pixel_x[9:4]>=22)&&(pixel_x[9:4]<=23)&&(cursor_location==0))
			text_RGB = 8'hFF;
			else if(~font_bit) text_RGB = 8'h1E;
		end
	else if(digFECHA_on)
		begin
		char_addr = char_addr_digFECHA;
      row_addr = row_addr_digFECHA;
      bit_addr = bit_addr_digFECHA;
			if(font_bit) text_RGB =8'h00; 
			else if ((parpadeo)&&(~font_bit)&&(config_mode == 2)&&(pixel_y[9:5]==12)&&(pixel_x[9:4]>=7)&&(pixel_x[9:4]<=8)&&(cursor_location==2))
			text_RGB = 8'hFF;
			else if ((parpadeo)&&(~font_bit)&&(config_mode == 2)&&(pixel_y[9:5]==12)&&(pixel_x[9:4]>=10)&&(pixel_x[9:4]<=11)&&(cursor_location==1))
			text_RGB = 8'hFF;
			else if ((parpadeo)&&(~font_bit)&&(config_mode == 2)&&(pixel_y[9:5]==12)&&(pixel_x[9:4]>=13)&&(pixel_x[9:4]<=14)&&(cursor_location==0))
			text_RGB = 8'hFF;
			else if(~font_bit) text_RGB = 8'h1E;
		end
	else if ((digTIMER_on))
		begin
		char_addr = char_addr_digTIMER;
      row_addr = row_addr_digTIMER;
      bit_addr = bit_addr_digTIMER;
			if(font_bit) text_RGB = 8'h00; 
			else if ((parpadeo)&&(~font_bit)&&(config_mode == 3)&&(pixel_y[9:5]==12)&&(pixel_x[9:4]>=25)&&(pixel_x[9:4]<=26)&&(cursor_location==2)) 
			text_RGB = 8'hFF;
			else if ((parpadeo)&&(~font_bit)&&(config_mode == 3)&&(pixel_y[9:5]==12)&&(pixel_x[9:4]>=28)&&(pixel_x[9:4]<=29)&&(cursor_location==1))
			text_RGB = 8'hFF;
			else if ((parpadeo)&&(~font_bit)&&(config_mode == 3)&&(pixel_y[9:5]==12)&&(pixel_x[9:4]>=31)&&(pixel_x[9:4]<=32)&&(cursor_location==0))
			text_RGB = 8'hFF;
			else if(~font_bit) text_RGB = 8'h1E;
		end
	else
		begin
		char_addr = char_addr_AMPM;
      row_addr = row_addr_AMPM;
      bit_addr = bit_addr_AMPM;
			if(font_bit) text_RGB = 8'hFF; 
		end
end
assign text_on = digHORA_on|digFECHA_on|digTIMER_on;
assign rom_addr = {char_addr, row_addr};
assign font_bit = font_word[~bit_addr];
endmodule
