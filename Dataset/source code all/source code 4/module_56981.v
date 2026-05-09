`timescale 1ns / 1ps
`define KQSTAT		0
`define KQDATA		1
`timescale 1ns / 1ps
`define KQSTAT		0
`define KQDATA		1
module KIA(
	input CLK_I,
	input RES_I,
	input [0:0] ADR_I,
	input WE_I,
	input CYC_I,
	input STB_I,
	output ACK_O,
	output [7:0] DAT_O,
	input D_I,
	input C_I
);
	reg [7:0] queue[0:15];
	reg [3:0] rp;
	reg [3:0] wp;
	wire [3:0] next_wp = wp+1;
	wire queue_full = (next_wp == rp);
	wire queue_empty = (rp == wp);
	reg ack;
	assign ACK_O = ack;
	always @(posedge CLK_I) begin
		if(~RES_I) begin
			ack <= CYC_I & STB_I;
		end else begin
			ack <= 0;
		end
	end
	wire kqstat_addressed	= (ADR_I == `KQSTAT) & ack & ~WE_I;
	wire kqdata_addressed	= (ADR_I == `KQDATA) & ack & ~WE_I;
	wire kqpop_addressed		= (ADR_I == `KQDATA) & ack & WE_I & ~queue_empty;
	wire [7:0] kqstat_value	= {6'h00, queue_full, queue_empty};
	wire [7:0] kqdata_value	= queue[rp];
	wire [3:0] next_rp		= RES_I ? 4'h0 : (kqpop_addressed ? rp+1 : rp);
	assign DAT_O = ({8{kqstat_addressed}} & kqstat_value) | ({8{kqdata_addressed}} & kqdata_value);
	always @(posedge CLK_I) begin
		rp <= next_rp;
	end
	reg [10:0] sr;
	reg cur_C;
	reg prev_C;
	reg [3:0] bits_received;
	wire ps2clk_edge = ~cur_C && prev_C;
	wire waiting_for_start_bit = bits_received == 0;
	wire waiting_for_stop_bit = bits_received == 10;
	wire is_start_bit = D_I == 0;
	wire is_stop_bit = D_I == 1;
	always @(posedge CLK_I) begin
		if(~RES_I) begin
			cur_C <= C_I;
			if(ps2clk_edge && waiting_for_start_bit && is_start_bit) begin
				sr <= {D_I, sr[10:1]};
				bits_received <= bits_received+1;
			end
			if(ps2clk_edge && ~waiting_for_stop_bit && ~waiting_for_start_bit) begin
				sr <= {D_I, sr[10:1]};
				bits_received <= bits_received+1;
			end
			if(ps2clk_edge && waiting_for_stop_bit && is_stop_bit && ~queue_full) begin
				queue[wp] <= sr[9:2];
				wp <= next_wp;
				bits_received <= 0;
			end
			if(ps2clk_edge && waiting_for_stop_bit && is_stop_bit && queue_full) begin
				bits_received <= 0;
			end
			prev_C <= cur_C;
		end else begin
			sr <= 11'h7FF;
			prev_C <= 1;
			cur_C <= 1;
			bits_received <= 0;
			wp <= 0;
		end
	end
endmodule
