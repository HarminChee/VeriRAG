`timescale 100ns/1ns
`timescale 100ns/1ns
module register #(parameter WIDTH=8)
		(input clk,
		 input reset,
		 input xclear,
		 input xload,
		 input [WIDTH-1:0] xin,
		 output reg [WIDTH-1:0] xout);
always @ (posedge clk) begin
	if(xclear || reset)
		xout <= 0;
	else if(xload) begin
			xout <= xin;
	end
end
endmodule
