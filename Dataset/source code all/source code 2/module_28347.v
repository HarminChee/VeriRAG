`timescale 1ns / 1ps
`timescale 1ns / 1ps
module control(clk, lsb_B, init, Z, ld_rst, shift, acc, done);
	input clk;
	input lsb_B;
	input init; 
	input Z;
	output reg ld_rst;
	output reg shift;
	output reg acc;
	output reg done;
	reg [2:0] current_state;
	reg [2:0] next_state;
	parameter start=3'b000, check=3'b001, acum=3'b010, shft=3'b011, end1=3'b100;
	always @(lsb_B or init or Z or current_state)begin
		case(current_state)
     		start: 	begin
						acc=1'b0;
						ld_rst=1'b1;
						shift=1'b0;
						done=1'b0;
						if (init == 1'b1) next_state<=check;
						else next_state<=start;
					end
			check:	begin
						acc=1'b0;
						ld_rst=1'b0;
						shift=1'b0;
						done=1'b0;
						if (lsb_B == 1'b1) next_state<=acum;
						else next_state<=shft;
					end
			acum:	begin
						acc=1'b1;
						ld_rst=1'b0;
						shift=1'b0;
						done=1'b0;
						next_state<=shft;
					end
			shft:	begin
						acc=1'b0;
						ld_rst=1'b0;
						shift=1'b1;
						done=1'b0;
						if (Z == 1'b1) next_state<=end1;
						else next_state<=check;
					end
			end1:	begin
						acc=1'b0;
						ld_rst=1'b0;
						shift=1'b0;
						done=1'b1;
						next_state<=start;
					end
			default:
					begin
						acc=1'b0;
						ld_rst=1'b1;
						shift=1'b0;
						done=1'b0;
						next_state<=start;
					end
		endcase
	end	
	always @(negedge clk) begin
	    current_state<=next_state;	
	end
endmodule
