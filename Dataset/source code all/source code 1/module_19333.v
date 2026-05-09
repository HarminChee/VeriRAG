module vga(clk, r, g, b, hs, vs, cs_, oe_, we_, addr, data);
	input clk;
	output reg r;
	output reg g;
	output reg b;
	output reg hs;
	output reg vs;
	input cs_;
	input oe_;
	input we_;
	input [11:0] addr;
	inout [7:0] data;
reg [10:0] counterX = 11'd0;		
reg [9:0] counterY = 10'd0;		
parameter Width = 640;
parameter Height = 480;
parameter LineFrontPorch = 16;
parameter LineSyncPulse = 96;
parameter LineBackPorch = 48;
parameter FrameFrontPorch = 11;
parameter FrameSyncPulse = 2;
parameter FrameBackPorch = 31;
parameter ClocksPerPixel = 2;
localparam TotalLine = (Width + LineFrontPorch + LineSyncPulse + LineBackPorch) * ClocksPerPixel;
localparam TotalFrame = Height + FrameFrontPorch + FrameSyncPulse + FrameBackPorch;
localparam LWVal = Width * ClocksPerPixel;
localparam LFPVal = (Width + LineFrontPorch) * ClocksPerPixel;
localparam LSPVal = (Width + LineFrontPorch + LineSyncPulse) * ClocksPerPixel;
localparam FFPVal = Height + FrameFrontPorch;
localparam FSPVal = Height + FrameFrontPorch + FrameSyncPulse;
wire counterXMaxed = (counterX == TotalLine);
wire counterYMaxed = (counterY == TotalFrame);
always @(posedge clk)
	if(counterXMaxed)
		counterX <= 11'd0;
	else
		counterX <= counterX + 11'd1;
always @(posedge clk)
	if(counterXMaxed)
		if(counterYMaxed)
			counterY <= 10'd0;
		else
			counterY <= counterY + 10'd1;
parameter CharsAcross = 80;
parameter CharsAcrossLog = 7;
parameter CharsDown = 25;
parameter CharWidth = 8;
parameter CharHeight = 16;
parameter AllCharWidth = CharsAcross * CharWidth * ClocksPerPixel;
parameter AllCharHeight = CharsDown * CharHeight;
wire [6:0] xchar = (counterX < AllCharWidth) ? counterX[10:4] : 7'h7f;
wire xcharvalid = ~&xchar;
wire [6:0] ychar = (counterY < AllCharHeight) ? { 1'b0, counterY[9:4] } : 7'h7f;
wire ycharvalid = ~&ychar;
wire charvalid = xcharvalid & ycharvalid;
wire [11:0] mem_addr = { ychar[4:0], xchar[6:0] };
wire [7:0] fbuf_out;
wire [7:0] fbuf_out_to_cpu;
assign data = (~cs_ & ~oe_) ? fbuf_out_to_cpu : 8'bzzzzzzzz;
vga_ram ram_fb(.address_a(addr), .address_b(mem_addr), .clock_a(clk), .clock_b(clk), .data_a(data), .q_a(fbuf_out_to_cpu), .q_b(fbuf_out), .wren_a(~cs_ & ~we_), .wren_b(1'b0));
wire [2:0] charxbit = counterX[3:1];
wire [3:0] charybit = counterY[3:0];
wire [7:0] font_out;
wire [11:0] font_addr = { fbuf_out[7:0], charybit };
vga_font_rom font_rom(.clock(clk), .address(font_addr), .q(font_out));
wire font_bit = font_out[charxbit] & charvalid;
always @(posedge clk)
	if(counterY < Height)
	begin
		if(counterX < LWVal)
			{ r, g, b, hs, vs } <= { font_bit, font_bit, font_bit, 1'b1, 1'b1 };
		else if(counterX < LFPVal)
			{ r, g, b, hs, vs } <= { 1'b0, 1'b0, 1'b0, 1'b1, 1'b1 };
		else if(counterX < LSPVal)
			{ r, g, b, hs, vs } <= { 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 };		
		else
			{ r, g, b, hs, vs } <= { 1'b0, 1'b0, 1'b0, 1'b1, 1'b1 };
	end
	else if(counterY < FFPVal)
	begin
		if(counterX < LFPVal)
			{ r, g, b, hs, vs } <= { 1'b0, 1'b0, 1'b0, 1'b1, 1'b1 };
		else if(counterX < LSPVal)
			{ r, g, b, hs, vs } <= { 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 };
		else
			{ r, g, b, hs, vs } <= { 1'b0, 1'b0, 1'b0, 1'b1, 1'b1 };
	end
	else if(counterY < FSPVal)
	begin
		if(counterX < LFPVal)
			{ r, g, b, hs, vs } <= { 1'b0, 1'b0, 1'b0, 1'b1, 1'b0 };
		else if(counterX < LSPVal)
			{ r, g, b, hs, vs } <= { 1'b0, 1'b1, 1'b0, 1'b0, 1'b0 };			
		else
			{ r, g, b, hs, vs } <= { 1'b0, 1'b0, 1'b0, 1'b1, 1'b0 };
	end
	else
	begin
		if(counterX < LFPVal)
			{ r, g, b, hs, vs } <= { 1'b0, 1'b0, 1'b0, 1'b1, 1'b1 };
		else if(counterX < LSPVal)
			{ r, g, b, hs, vs } <= { 1'b0, 1'b0, 1'b0, 1'b0, 1'b1 };
		else
			{ r, g, b, hs, vs } <= { 1'b0, 1'b0, 1'b0, 1'b1, 1'b1 };
	end
endmodule
