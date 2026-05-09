`default_nettype none
module RedundantFF(clear, underflow, clk_108hz);
	input wire clear;
	input wire clk_108hz; // Make the clock a primary input
	output wire underflow;
	reg[7:0] count = 15;
	always @(posedge clk_108hz) begin
		count <= count - 1'h1;
		if(count == 0)
			count <= 15;
	end
	assign underflow = (count == 0);
endmodule