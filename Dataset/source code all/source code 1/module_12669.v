module Sec5_SM(
	input DigitalLDir,
	input DigitalRDir,
	input clk_i,
	input reset_n,
	output reg [3:0] outputs
	);
	reg [2:0] state;
	reg [2:0] state_next;
	parameter S0 = 3'b000;  
	parameter S1 = 3'b001;  
	parameter S2 = 3'b010;  
	parameter S3 = 3'b011;  
	parameter S4 = 3'b100;  
	parameter S5 = 3'b101;  
	parameter S6 = 3'b110;  
	always @ (posedge clk_i, negedge reset_n)
		begin
			if(!reset_n)
				state <= S0;
			else
				state <= state_next;
		end
	always @ (*)
		begin
			case(state)
				S0: 
				begin
					if( !DigitalLDir )		state_next <= S4;
					else if( !DigitalRDir )	state_next <= S1;
					else 					state_next <= S0;
				end
				S1:							state_next = S2;
				S2:							state_next = S3;
				S3:							state_next = S0;
				S4:							state_next = S5;
				S5:							state_next = S6;
				S6:							state_next = S0;
				default: state_next = S0;
			endcase
		end
	always @ (*)
		begin
			case (state)
				S0:
				begin
					outputs = 4'b0101;
				end
				S1:
				begin
					outputs = 4'b0000;
				end
				S2:
				begin
					outputs = 4'b0000;
				end
				S3:
				begin
					outputs = 4'b0100;
				end
				S4:
				begin
					outputs = 4'b0000;
				end
				S5:
				begin
					outputs = 4'b0000;
				end
				S6:
				begin
					outputs = 4'b0001;
				end
				default:
				begin
					outputs = 4'b0101;
				end
			endcase
		end
endmodule
