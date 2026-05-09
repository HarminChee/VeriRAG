`timescale 1ns / 1ps
`timescale 1ns / 1ps
module motor_ctl(
input clk,
input rst_32,
input [31:0] din_32,
input [0:0] wr_en_32,
input [0:0] rd_en_32,
output [31:0] dout_32,
output [0:0] full_32,
output [0:0] empty_32,
output  dir_out_r,
output  dir_out_l,
output  en_out_r,
output  en_out_l
);
parameter INIT_32 = 0,
			READY_RCV_32 	= 1,
			RCV_DATA_32 	= 2,
			POSE_32		= 3,
			READY_SND_32	= 4,
			SND_DATA_32	= 5;
wire [31:0] rcv_data_32;
wire rcv_en_32;
wire data_empty_32;
wire [31:0] snd_data_32;
wire snd_en_32;
wire data_full_32;
reg [3:0] state_32;
fifo_32x512 input_fifo_32(
	.clk(clk),
	.srst(rst_32),
	.din(din_32),
	.wr_en(wr_en_32),
	.full(full_32),
	.dout(rcv_data_32),
	.rd_en(rcv_en_32),
	.empty(data_empty_32)
	);
fifo_32x512 output_fifo_32(
	.clk(clk),
	.srst(rst_32),
	.din(snd_data_32),
	.wr_en(snd_en_32),
	.full(data_full_32),
	.dout(dout_32),
	.rd_en(rd_en_32),
	.empty(empty_32)
	);
reg dir_right;
reg [14:0] para_right;
reg dir_left;
reg [14:0] para_left;
pwm_ctl right
(
.clk(clk),
.rst(rst_32),
.para_in(para_right),
.dir_in(dir_right),
.dir_out(dir_out_r),
.en_out(en_out_r)
);
pwm_ctl left
(
.clk(clk),
.rst(rst_32),
.para_in(para_left),
.dir_in(dir_left),
.dir_out(dir_out_l),
.en_out(en_out_l)
);
always @(posedge clk)begin
	if(rst_32)
		state_32 <= 0;
	else
		case (state_32)
			INIT_32: 										state_32 <= READY_RCV_32;
			READY_RCV_32: if(data_empty_32 == 0) 	state_32 <= RCV_DATA_32;
			RCV_DATA_32: 									state_32 <= POSE_32;
			POSE_32:											state_32 <= READY_SND_32;
			READY_SND_32: if(1)							state_32 <= SND_DATA_32;
			SND_DATA_32:									state_32 <= READY_RCV_32;
		endcase
end
assign rcv_en_32 = (state_32 == RCV_DATA_32);
assign snd_en_32 = (state_32 == SND_DATA_32);
always @(posedge clk)begin
	if(rst_32)begin
		dir_right <= 0;
		para_right <= 0;
		dir_left <= 0;
		para_left <= 0;
	end
	else if (state_32 == RCV_DATA_32)begin
		dir_right <= din_32[0:0];
		para_right <= din_32[15:1];
		dir_left <= din_32[16:16];
		para_left <= din_32[31:17];
	end
end
endmodule
