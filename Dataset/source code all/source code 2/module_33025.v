`define STATE_s_start 0
`define STATE_s_wait 1
`define STATE_s_count 2
`define STATE_s_over 3
`define STATE_s_start 0
`define STATE_s_wait 1
`define STATE_s_count 2
`define STATE_s_over 3
module FB_BfbIDMTCurve 
(
		input wire clk,
		input wire tick_eI,
		input wire i_measured_eI,
		input wire iSet_change_eI,
		output wire unsafe_eO,
		input wire unsigned [7:0] i_I,
		input wire unsigned [7:0] iSet_I,
		input reset
);
wire tick;
assign tick = tick_eI;
wire i_measured;
assign i_measured = i_measured_eI;
wire iSet_change;
assign iSet_change = iSet_change_eI;
reg unsafe;
assign unsafe_eO = unsafe;
reg unsigned [7:0] i ;
reg unsigned [7:0] iSet ;
reg  unsigned [15:0] v  = 0; 
reg  unsigned [15:0] thresh  = 0; 
reg [1:0] state = `STATE_s_start;
reg entered = 1'b0;
reg s_wait_alg0_alg_en = 1'b0; 
reg s_count_alg0_alg_en = 1'b0; 
reg updateThresh_alg_en = 1'b0; 
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_s_start;
		unsafe = 1'b0;
		i = 0;
		iSet = 0;
		v = 0;
		thresh = 0;
	end else begin
		unsafe = 1'b0;
		if(i_measured) begin 
			i = i_I;
		end
		if(iSet_change) begin 
			iSet = iSet_I;
		end
		entered = 1'b0;
		case(state) 
			default: begin
				if(1) begin
					state = `STATE_s_wait;
					entered = 1'b1;
				end
			end 
			`STATE_s_wait: begin
				if(i > iSet) begin
					state = `STATE_s_count;
					entered = 1'b1;
				end
			end 
			`STATE_s_count: begin
				if(i <= iSet) begin
					state = `STATE_s_wait;
					entered = 1'b1;
				end else if(v > thresh) begin
					state = `STATE_s_over;
					entered = 1'b1;
				end else if(tick) begin
					state = `STATE_s_count;
					entered = 1'b1;
				end
			end 
			`STATE_s_over: begin
				if(i <= iSet) begin
					state = `STATE_s_wait;
					entered = 1'b1;
				end else if(1) begin
					state = `STATE_s_over;
					entered = 1'b1;
				end
			end 
		endcase
		s_wait_alg0_alg_en = 1'b0; 
		s_count_alg0_alg_en = 1'b0; 
		updateThresh_alg_en = 1'b0; 
		if(entered) begin
			case(state)
				default: begin
				end 
				`STATE_s_wait: begin
					s_wait_alg0_alg_en = 1'b1;
				end 
				`STATE_s_count: begin
					updateThresh_alg_en = 1'b1;
					s_count_alg0_alg_en = 1'b1;
				end 
				`STATE_s_over: begin
					unsafe = 1'b1;
				end 
			endcase
		end
		if(s_wait_alg0_alg_en) begin
			v = 0;
		end 
		if(s_count_alg0_alg_en) begin
			v = v + 1;
		end 
		if(updateThresh_alg_en) begin
			if (i > 145) begin
			thresh = 5;
		end
		 else if (i > 100) begin
			thresh = 10;
		end
		 else if (i > 77) begin
			thresh = 15;
		end
		 else if (i > 55) begin
			thresh = 30;
		end
		 else if (i > 32) begin
			thresh = 60;
		end
		 else if (i > 23) begin
			thresh = 100;
		end
		 else if (i > 19) begin
			thresh = 150;
		end
		 else if (i > 14) begin
			thresh = 300;
		end
		 else begin 
		thresh = 400;
	end
		end 
	end
end
endmodule
