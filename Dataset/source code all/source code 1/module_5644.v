`timescale 1ns / 10ps
`timescale 1ns / 10ps
module gen_pipe_1
	#(
	parameter PIPE_WIDTH   = 9'd32,
		  PIPE_DEPTH   = 5'd4
	)
	(
	input				clk,
	input	[PIPE_WIDTH -1 :0]	din,
	output	[PIPE_WIDTH -1 :0]	dout_1,
	output	[PIPE_WIDTH -1 :0]	dout
	);
	reg	[PIPE_WIDTH - 1:0]	pipe_reg [PIPE_DEPTH - 1:0];
	reg	[9:0]	n;
	always @(posedge clk) begin
		for(n=(PIPE_DEPTH[9:0] - 10'h1); n!=10'h0; n=n-10'h1)
			pipe_reg[n] <= pipe_reg[n-1];
		pipe_reg[0] <= din;;
	end
	assign dout = pipe_reg[PIPE_DEPTH - 1];
	assign dout_1 = pipe_reg[PIPE_DEPTH - 2];
endmodule
