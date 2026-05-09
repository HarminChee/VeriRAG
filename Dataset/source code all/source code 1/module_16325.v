module vga_sram(CLOCK_PX ,rst,VGA_R, VGA_G, VGA_B,VGA_HS, VGA_VS,VGA_SYNC, VGA_BLANK,FB_ADDR,fb_data,we_nIN);
input CLOCK_PX,rst;
input we_nIN;
input [7:0] fb_data;
output VGA_BLANK, VGA_SYNC, VGA_HS, VGA_VS;
output [7:0] VGA_R, VGA_G, VGA_B;
output [18:0] FB_ADDR;
reg [7:0] VGA_R, VGA_G, VGA_B;
reg  VGA_HS, VGA_VS, h_blank, v_blank, status;
reg [31:0] pixelcount, linecount;
reg red_value;
reg [9:0] rdaddress;
reg [9:0] wraddress;
reg [18:0] FB_ADDR;
reg [7:0] Rdata, Bdata;
reg UBwe, LBwe;
wire CLOCK_PX,we_nIN;
wire VGA_BLANK, VGA_SYNC;
wire [7:0] Rq,Bq, gray;
parameter	H_FRONT	=	16;
parameter	H_SYNC	=	96;
parameter	H_BACK	=	48;
parameter	H_ACT	=	640;
parameter	H_BLANK	=	H_FRONT+H_SYNC+H_BACK;
parameter	H_TOTAL	=	H_FRONT+H_SYNC+H_BACK+H_ACT;
parameter	V_FRONT	=	11;
parameter	V_SYNC	=	2;
parameter	V_BACK	=	31;
parameter	V_ACT	=	480;
parameter	V_BLANK	=	V_FRONT+V_SYNC+V_BACK;
parameter	V_TOTAL	=	V_FRONT+V_SYNC+V_BACK+V_ACT;
parameter FB_SIZE = V_ACT * H_ACT;
`define fb_addr_size 19
parameter SH_ACT = 0;
parameter S_FILLER = 0;
assign VGA_SYNC = 1'b1,
		 VGA_BLANK = h_blank || v_blank;
linebuffer red(Rdata,rdaddress,CLOCK_PX,wraddress,CLOCK_PX,LBwe,Rq);
always@(posedge CLOCK_PX or negedge rst)
begin
	if (rst==1'b0)
		begin
		pixelcount<=32'd0;
		linecount<=32'd0;
		end
	else
		if(we_nIN==1'b1)
			if (pixelcount>H_TOTAL)
				begin
					pixelcount<=32'd0;
					if (linecount>V_TOTAL)
						linecount<=32'd0;
					else
						linecount<= linecount+1;
				end
			else
				pixelcount<= pixelcount+1;
		else
			begin
				pixelcount<=32'd0;
				linecount<=32'd0;
			end
end
always@(posedge CLOCK_PX or negedge rst)
begin
	if (rst == 1'b0)
		begin 
		VGA_HS<=1'b0;
		h_blank<=1'b1;
		VGA_R<=8'h00;
		VGA_G<=8'h00;
		VGA_B<=8'h00;
		rdaddress<=10'b0000000100;
		end
	else
	begin
	if (pixelcount< H_SYNC)
		VGA_HS<=1'b0;
	else
		VGA_HS<=1'b1;
   if (pixelcount < H_BLANK)
		h_blank<=1'b0;
	else
		h_blank<=1'b1;
	if (linecount>=(V_BACK+V_SYNC) &&
      linecount<(V_BACK+V_SYNC+V_ACT) &&
      pixelcount>=(H_BACK+H_SYNC) && 
      pixelcount<(H_BACK+H_SYNC+H_ACT) &&
      we_nIN==1'b1)
		begin
			VGA_R<=Rq;
			VGA_G<=Rq;
			VGA_B<=Rq;
			rdaddress<=rdaddress+10'd1;
		end
	else
		begin
		VGA_R<=8'h00;
		VGA_G<=8'h00;
		VGA_B<=8'h00;
    rdaddress <= 10'd0;
		end
	end
end
always@(posedge CLOCK_PX or negedge rst)
begin 
	if (rst ==1'b0)
		begin
		VGA_VS<=1'b0;
		v_blank <= 1'b0;
		end
	else
	begin
	if (linecount<V_SYNC)
		VGA_VS<=1'b0;
	else
		VGA_VS <= 1'b1;
	if (linecount < V_BLANK )
		v_blank<=1'b1;
	else
		v_blank <= 1'b0;
	end
end
always@(posedge CLOCK_PX or negedge rst)
begin
	if(rst==1'b0)
		begin
			wraddress<=10'd0;
			FB_ADDR<=`fb_addr_size'd0;
		end
	else
		if(linecount>=(V_SYNC+V_BACK)&&linecount<(V_SYNC+V_BACK+V_ACT)&&pixelcount<H_ACT&&we_nIN==1'b1)
			begin
				Rdata<=fb_data;
				wraddress<=wraddress+10'd1;
				if(FB_ADDR >= FB_SIZE) begin
				  FB_ADDR <= `fb_addr_size'd0;
				end else begin 
  				  FB_ADDR<=FB_ADDR+`fb_addr_size'd1;
				end 
				UBwe<=1'b1;
				LBwe<=1'b1;
			end
		else
			begin
				UBwe<=1'b0;
				LBwe<=1'b0;	
        wraddress <= 10'd0;
			end
end
endmodule
