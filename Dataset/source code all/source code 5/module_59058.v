`timescale 1ns / 1ps
`timescale 1ns / 1ps
module FIFO_WxD #(
	parameter U_FIFO_WIDTH = 24, 	
	parameter U_FIFO_SQ_DEPTH = 10 
	)(
	input wire rst,
	input wire [U_FIFO_WIDTH - 1:0] dataIn,
	input wire wr_en,
	input wire rd_en,
	output wire [U_FIFO_WIDTH - 1:0] dataOut,
	output wire full_flg,
	output wire empty_flg
	);
	reg [U_FIFO_WIDTH - 1:0] fifo [(2^U_FIFO_SQ_DEPTH) - 1:0];
	reg [U_FIFO_SQ_DEPTH - 1:0] wr_ptr = 0;
	reg [U_FIFO_SQ_DEPTH - 1:0] rd_ptr = 0;
	always@(posedge wr_en or negedge rst)
	begin
		if(!rst)	
			wr_ptr <= 0;
		else if(!full_flg) 
		begin
			fifo[wr_ptr] <= dataIn;
			wr_ptr <= wr_ptr + 1'b1;
		end
	end 
	always@(posedge rd_en or negedge rst)
	begin
		if(!rst)
			rd_ptr <= 0;
		else if(!empty_flg)
		begin
			rd_ptr <= rd_ptr + 1'b1;
		end
	end 
	assign empty_flg = (wr_ptr == rd_ptr)? 1'b1 : 1'b0; 
	assign full_flg = ((wr_ptr + {{U_FIFO_SQ_DEPTH-1{1'b0}}, 1'b1}) == rd_ptr)? 1'b1 : 1'b0; 
	assign dataOut = (empty_flg)? {U_FIFO_WIDTH{1'b0}} : fifo[rd_ptr]; 
endmodule
