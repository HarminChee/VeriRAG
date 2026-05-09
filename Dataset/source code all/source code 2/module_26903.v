`timescale 1ns / 1ps
`timescale 1ns / 1ps
module Registro_Universal
#(parameter N = 8) 
(
	input wire hold,
	input wire [N-1:0]in_rtc_dato,
	input wire [N-1:0]in_count_dato,
	input wire clk, 
	input wire reset, 
	input wire chip_select, 
	output wire [N-1:0]out_dato
);
reg [N-1:0]reg_dato;
reg [N-1:0]next_dato;
always@(negedge clk, posedge reset)
begin
	if(reset) reg_dato <= 0;
	else reg_dato <= next_dato;
end
always@*
	begin
	if (~hold) begin
	case(chip_select)
	1'b0: next_dato = in_rtc_dato;
	1'b1: next_dato = in_count_dato;
	endcase
	end
	else next_dato = reg_dato;
	end
assign out_dato = reg_dato;
endmodule
