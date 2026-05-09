`define STATE_s_init 0
`define STATE_s_N_S_Go 1
`define STATE_s_E_W_Go 2
`define STATE_s_init 0
`define STATE_s_N_S_Go 1
`define STATE_s_E_W_Go 2
module FB_BfbIntersectionMutex 
(
		input wire clk,
		input wire Start_eI,
		input wire N_S_Done_eI,
		input wire E_W_Done_eI,
		output wire N_S_Start_eO,
		output wire E_W_Start_eO,
		input reset
);
wire Start;
assign Start = Start_eI;
wire N_S_Done;
assign N_S_Done = N_S_Done_eI;
wire E_W_Done;
assign E_W_Done = E_W_Done_eI;
reg N_S_Start;
assign N_S_Start_eO = N_S_Start;
reg E_W_Start;
assign E_W_Start_eO = E_W_Start;
reg [1:0] state = `STATE_s_init;
reg entered = 1'b0;
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_s_init;
		N_S_Start = 1'b0;
		E_W_Start = 1'b0;
	end else begin
		N_S_Start = 1'b0;
		E_W_Start = 1'b0;
		entered = 1'b0;
		case(state) 
			`STATE_s_init: begin
				if(Start) begin
					state = `STATE_s_N_S_Go;
					entered = 1'b1;
				end
			end 
			`STATE_s_N_S_Go: begin
				if(N_S_Done) begin
					state = `STATE_s_E_W_Go;
					entered = 1'b1;
				end
			end 
			`STATE_s_E_W_Go: begin
				if(E_W_Done) begin
					state = `STATE_s_N_S_Go;
					entered = 1'b1;
				end
			end 
			default: begin
				state = 0;
			end
		endcase
		if(entered) begin
			case(state)
				`STATE_s_init: begin
				end 
				`STATE_s_N_S_Go: begin
					N_S_Start = 1'b1;
				end 
				`STATE_s_E_W_Go: begin
					E_W_Start = 1'b1;
				end 
				default: begin
				end
			endcase
		end
	end
end
endmodule
