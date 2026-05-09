`define STATE_s_init 0
`define STATE_s_reset 1
`define STATE_s_set 2
`define STATE_s_init 0
`define STATE_s_reset 1
`define STATE_s_set 2
module FB_BfbSetterResetter 
(
		input wire clk,
		input wire test_eI,
		input wire set_eI,
		input wire unsafe_eI,
		output wire b_change_eO,
		output reg  b_O ,
		input reset
);
wire test;
assign test = test_eI;
wire set;
assign set = set_eI;
wire unsafe;
assign unsafe = unsafe_eI;
reg b_change;
assign b_change_eO = b_change;
reg  b ;
reg [1:0] state = `STATE_s_init;
reg entered = 1'b0;
reg s_reset_alg0_alg_en = 1'b0; 
reg s_set_alg0_alg_en = 1'b0; 
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_s_init;
		b_change = 1'b0;
		b = 0;
	end else begin
		b_change = 1'b0;
		entered = 1'b0;
		case(state) 
			default: begin
				if(1) begin
					state = `STATE_s_reset;
					entered = 1'b1;
				end
			end 
			`STATE_s_reset: begin
				if(set) begin
					state = `STATE_s_set;
					entered = 1'b1;
				end
			end 
			`STATE_s_set: begin
				if(test || unsafe) begin
					state = `STATE_s_reset;
					entered = 1'b1;
				end
			end 
		endcase
		s_reset_alg0_alg_en = 1'b0; 
		s_set_alg0_alg_en = 1'b0; 
		if(entered) begin
			case(state)
				default: begin
				end 
				`STATE_s_reset: begin
					b_change = 1'b1;
					s_reset_alg0_alg_en = 1'b1;
				end 
				`STATE_s_set: begin
					b_change = 1'b1;
					s_set_alg0_alg_en = 1'b1;
				end 
			endcase
		end
		if(s_reset_alg0_alg_en) begin
			b = 0;
		end 
		if(s_set_alg0_alg_en) begin
			b = 1;
		end 
		if(b_change) begin 
			b_O = b;
		end
	end
end
endmodule
