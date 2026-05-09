`timescale 1ns / 1ps
`timescale 1ns / 1ps
module control_ascci(
	input clk,
	input top_ascci,
	input top_col,
	input new_string,
	input done,
	output reg add_dirram,
	output reg reset_dirram,
	output reg add_col,
   	output reg reset_col,
	output reg add_ascci,
	output reg reset_ascci,
	output reg init,
	output reg leer_rom,
	output reg leer_ram,	
	output reg run_efect 
	);
	reg [6:0] current_state;
	reg [6:0] next_state;
	parameter start=7'b0000000, state_1=7'b0000001, state_2=7'b0000010, state_3=7'b0000011, state_4=7'b0000100, state_5=7'b0000101,check=7'b0000110,state_1p=7'b0000111; 
	always @(top_ascci or done or top_col  or new_string or current_state)begin
		case(current_state)
     		start: 	begin			
								add_dirram=1'b0;
								reset_dirram=1'b1;
								add_col=1'b0;
								reset_col=1'b1;
								add_ascci=1'b0;
								reset_ascci=1'b0;
								leer_rom=1'b0;	
								leer_ram=1'b1;
								init=0;    
								run_efect=1'b0;
						if (new_string==1'b1 ) next_state<=state_1p;
						else next_state<=start;
					end
			state_1p:	begin 		
								add_dirram=1'b0;
								reset_dirram=1'b0;
								add_col=1'b0;
								reset_col=1'b0;
								add_ascci=1'b0;
								reset_ascci=1'b1;
								leer_rom=1'b1;
								leer_ram=1'b0;
								init=1;
								run_efect=1'b0;
						next_state<=state_1;
					end
			state_1:	begin 		
								add_dirram=1'b0;
								reset_dirram=1'b0;
								add_col=1'b0;
								reset_col=1'b0;
								add_ascci=1'b0;
								reset_ascci=1'b0;
								leer_rom=1'b1;
								leer_ram=1'b0;
								init=1;
								run_efect=1'b0;
						next_state<=state_2;
					end
			state_2:	begin 		
								add_dirram=1'b0;
								reset_dirram=1'b0;
								add_col=1'b0;
								reset_col=1'b0;
								add_ascci=1'b0;
								reset_ascci=1'b0;
								leer_rom=1'b1;
								leer_ram=1'b0;
								init=0;
								run_efect=1'b0;
						if(done==1'b1) next_state<=state_3;
					else next_state<=state_2;
					end
			state_3:	begin 		
								add_dirram=1'b0;
								reset_dirram=1'b0;
								add_col=1'b0;
								reset_col=1'b0;
								add_ascci=1'b0;
								reset_ascci=1'b0;
								leer_rom=1'b1;
								leer_ram=1'b0;
								init=0;
								run_efect=1'b0;
						next_state<=state_4;
					end
			state_4:	begin		
								add_dirram=1'b1;
								reset_dirram=1'b0;
								add_col=1'b1;
								reset_col=1'b0;
								add_ascci=1'b0;
								reset_ascci=1'b0;
								leer_rom=1'b1;
								leer_ram=1'b0;
								init=0;
								run_efect=1'b0;
						if (top_col == 1'b1) next_state<=state_5;
						else next_state<=state_3;
					end
			state_5:	begin		
								add_dirram=1'b1;
								reset_dirram=1'b0;
								add_col=1'b0;
								reset_col=1'b1;
								add_ascci=1'b1;
								reset_ascci=1'b0;
								leer_rom=1'b0;
								leer_ram=1'b0;
								init=0;
								run_efect=1'b0;
						if (top_ascci==1'b1)next_state<=check;
						else next_state<=state_1;
					end
			check: 	begin			
								add_dirram=1'b0;
								reset_dirram=1'b0;
								add_col=1'b0;
								reset_col=1'b0;
								add_ascci=1'b0;
								reset_ascci=1'b0;
								leer_rom=1'b0;	
								leer_ram=1'b1;
								init=0;
								run_efect=1'b1;
						if (new_string==1'b1) next_state<=start;
						else next_state<=check;
					end
			default:
					begin
								add_dirram=1'b0;
								reset_dirram=1'b0;
								add_col=1'b0;
								reset_col=1'b0;
								add_ascci=1'b0;
								reset_ascci=1'b0;
								leer_rom=1'b0;
								leer_ram=1'b0;
								init=0;
								run_efect=1'b0;
						next_state<=start;
					end
		endcase
	end	
	always @(negedge clk) begin
	    current_state<=next_state;	
	end
endmodule
