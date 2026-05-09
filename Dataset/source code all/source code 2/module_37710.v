`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ram_memory # (parameter N=4, M=4) 
(input clk,
input we,                
input [N-1:0] adr,
input [M-1:0] din,
output  [N-1:0]dout);
reg [M-1:0] mem [N-1:0];   
always @ (posedge clk)    
if (we) mem [adr] <= din;
assign dout = mem[adr];
endmodule
