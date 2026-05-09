`timescale 1ns / 1ps
`timescale 1ns / 1ps
module bounding_box #
(
	parameter [9:0] IMG_W = 720,
	parameter [9:0] IMG_H = 576
)
(
    input clk,
    input ce,
    input rst,
    input de,
    input hsync,
    input vsync,
    input mask,
    output [9:0] x_min,
    output [9:0] y_min,
	 output [9:0] x_max,
    output [9:0] y_max,
	 output [9:0] c_h,
	 output [9:0] c_w,
	 output on_border
    );
reg [9:0] curr_w = 0;
reg [9:0] curr_h = 0;
reg [9:0] min_x = IMG_W;
reg [9:0] max_x = 0;
reg [9:0] min_y = IMG_H;
reg [9:0] max_y = 0;
wire eof;
wire p_vsync;
reg is_valid = 0;
delay #
(
	.DELAY(1),
	.N(1)
)
delay_vsync
(
	.d(vsync),
	.ce(1'b1),
	.clk(clk),
	.q(p_vsync)
);
always @(posedge clk)
begin
	if (vsync == 0) begin
		curr_w <= 0;
		curr_h <= 0;
	end
	else if(de == 1) begin
		curr_w <= curr_w + 1;
		if (curr_w == IMG_W - 1) begin
			curr_w <= 0;
			curr_h <= curr_h + 1;
			if (curr_h == IMG_H - 1) begin
				curr_h <= 0;
			end
		end
	end
end
assign eof = (p_vsync == 1'b1 && vsync == 1'b0) ? 1'b1 : 1'b0;
reg [9:0] min_x_latch = 0;
reg [9:0] max_x_latch = 0;
reg [9:0] min_y_latch = 0;
reg [9:0] max_y_latch = 0;
always @(posedge clk)
begin
	if(eof)
	begin
		min_x_latch = min_x;
		max_x_latch = max_x;
		min_y_latch = min_y;
		max_y_latch = max_y;
		min_x = IMG_W;
		max_x = 0;
		min_y = IMG_H;
		max_y = 0;
	end
	else
	begin
		if(curr_w > 0 && curr_h > 0 && curr_w < IMG_W - 1 && curr_h < IMG_H - 1) is_valid = 1;
		else is_valid = 0;
		if(is_valid == 1 && de == 1 && vsync == 1 && mask == 1'b1 && min_x > curr_w) min_x = curr_w;
		if(is_valid == 1 && de == 1 && vsync == 1 && mask == 1'b1 && max_x < curr_w) max_x = curr_w;
		if(is_valid == 1 && de == 1 && vsync == 1 && mask == 1'b1 && min_y > curr_h) min_y = curr_h;
		if(is_valid == 1 && de == 1 && vsync == 1 && mask == 1'b1 && max_y < curr_h) max_y = curr_h;
	end
end
reg bbox_on_border = 0;
always @(posedge clk)
begin
	if((curr_h >= min_y_latch && curr_h <= max_y_latch) && (curr_w == min_x_latch || curr_w == max_x_latch)) bbox_on_border = 1;
	else if((curr_w >= min_x_latch && curr_w <= max_x_latch) && (curr_h == min_y_latch || curr_h == max_y_latch)) bbox_on_border = 1;
	else bbox_on_border = 0;
end
assign x_min = min_x_latch;
assign x_max = max_x_latch;
assign y_min = min_y_latch;
assign y_max = max_y_latch;
assign c_h = curr_h;
assign c_w = curr_w;
assign on_border = bbox_on_border;
endmodule
