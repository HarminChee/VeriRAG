`timescale 1ns / 10ps
`timescale 1ns / 10ps
module clk_div(input  reset,
	       input  clk_in,
	       output reg clk_out);
	reg [2:0] count;
	always @(posedge clk_in) begin
		if (!reset) begin
			clk_out <= 1'b0;
			count <= 3'b111;
		end
		else if (count == 5) begin
			clk_out <= ~clk_out;
			count <= 0;
		end
		else begin
			count <= count + 1;
		end
	end
endmodule
