`timescale 1ns / 1ps
`timescale 1ns / 1ps
module summator(
    input [9:0] A,
    input clk,
    input ce,
    input rst,
	 output [27:0] Y
    );
reg [27:0] sum = 28'b0;
wire [27:0] new_sum;
reg [9:0] tmp = 10'b0;
always @(posedge clk)
begin
	if(rst) 	sum = 28'b0;
	else 		sum = new_sum;
end
summator_add adder (
  .a(sum), 
  .b((ce ? A : 10'b0)), 
  .s(new_sum) 
);
assign Y = sum;
endmodule
