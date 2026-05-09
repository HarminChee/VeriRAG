`timescale 1ns / 1ps
`timescale 1ns / 1ps
module sobel #(
    	parameter [9:0] H_SIZE = 83 
)(
	input clk,
	input ce,
	input rst,
	input [7:0] in_image,
	input in_de,
	input in_vsync,
	input in_hsync,
	output [7:0] out_sobel,
	output out_de,
	output out_vsync,
	output out_hsync   
	);
wire [10:0] delay_line11;
reg  [10:0] delay_line12 [2:0];
wire [10:0] delay_line21;
reg  [10:0] delay_line22 [2:0];
wire [10:0] delay_line31;
reg  [10:0] delay_line32 [2:0];
reg signed [11:0] sum_linesX[2:0];
reg signed [11:0] sum_finalX;
reg signed [11:0] sum_linesY[2:0];
reg signed [11:0] sum_finalY;
assign delay_line11 = {in_image, in_de, in_hsync, in_vsync};
genvar i;
generate
		always @(posedge clk)
		begin
				delay_line12[0] <= delay_line11;
				delay_line22[0] <= delay_line21;
				delay_line32[0] <= delay_line31;
				delay_line12[1] <= delay_line12[0];
				delay_line22[1] <= delay_line22[0];
				delay_line32[1] <= delay_line32[0];
				delay_line12[2] <= delay_line12[1];
				delay_line22[2] <= delay_line22[1];
				delay_line32[2] <= delay_line32[1];
	end
endgenerate;
wire [9:0] dummy;
delayLinieBRAM_WP long_delay1
(    
	.clk(clk),
	.rst(1'b0),
	.ce(1'b1),
	.din({5'b0, delay_line12[2]}),
	.dout({dummy[4:0], delay_line21}),
	.h_size(H_SIZE - 3)
);
delayLinieBRAM_WP long_delay2
(    
	.clk(clk),
	.rst(1'b0),
	.ce(1'b1),
	.din({5'b0, delay_line22[2]}),
	.dout({dummy[9:5], delay_line31}),
	.h_size(H_SIZE - 3)
);
always @(posedge clk)
begin
		sum_linesY[0] <= - {4'b0, delay_line12[0][10:3]} - {3'b0, delay_line12[1][10:3], 1'b0} - {4'b0,delay_line12[2][10:3]};
		sum_linesY[1] <= 12'b0;
		sum_linesY[2] <= {4'b0, delay_line32[0][10:3]} + {3'b0, delay_line32[1][10:3], 1'b0} + {4'b0,delay_line32[2][10:3]};
		sum_finalY <= sum_linesY[0] + sum_linesY[1] + sum_linesY[2];
		sum_linesX[0] <= - {4'b0, delay_line12[0][10:3]} + {4'b0,delay_line12[2][10:3]};
		sum_linesX[1] <= - {3'b0, delay_line22[0][10:3], 1'b0} + {3'b0,delay_line22[2][10:3], 1'b0};
		sum_linesX[2] <= -{4'b0, delay_line32[0][10:3]} + {4'b0,delay_line32[2][10:3]};
		sum_finalX <= sum_linesX[0] + sum_linesX[1] + sum_linesX[2];
		if(sum_finalY < 12'b0) sum_finalY <= -sum_finalY;
		if(sum_finalX < 12'b0) sum_finalX <= -sum_finalX;
end
wire context_valid;
assign context_valid = delay_line12[0][1] & delay_line12[1][1] & delay_line12[2][1] & 
	delay_line22[0][1] & delay_line22[1][1] & delay_line22[2][1] & 
	delay_line32[0][1] & delay_line32[1][1] & delay_line32[2][1];
wire [2:0] d_dhv;
delay #
(
	.N(3),
	.DELAY(4)
)
dhv
(
	.d(delay_line22[2][2:0]),
	.ce(1'b1),
	.clk(clk),
	.q({d_dhv})
);
assign out_de = d_dhv[2];
assign out_hsync = d_dhv[1];
assign out_vsync = d_dhv[0];
reg signed[11:0] sobel_latch = 0;
always @(posedge clk)
begin
	 sobel_latch <= sum_finalX + sum_finalY;
end;
assign out_sobel = sobel_latch[10:3];
endmodule
