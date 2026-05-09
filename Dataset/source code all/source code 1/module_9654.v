`timescale 1ns / 1ps
`timescale 1ns / 1ps
module freqdiv(
input clk,
input rst_n,
output clk_out,
input [1:0] select
);
reg [23:0]counter;
reg out_clk_reg;
reg [23:0]divider;
assign clk_out=out_clk_reg;
always@(posedge clk or negedge rst_n)
begin
	if(~rst_n) begin
		counter<=24'd0;
		out_clk_reg<=1'b0;
	end
	else 
	begin
		case(select)
		2'b0:
		begin
			divider <= 24'd5;
		end
		2'b1:
		begin
			divider <= 24'd5999999;
		end
		2'b10:
		begin
			divider <= 24'd5999;
		end
		2'b11:
		begin
			divider <= 24'd5;
		end
		endcase
		if(counter==divider) 
		begin
			counter<=24'd000000;
			out_clk_reg<=~out_clk_reg;
		end
		else
		begin
			counter<=counter+1;
		end
	end
end
endmodule
