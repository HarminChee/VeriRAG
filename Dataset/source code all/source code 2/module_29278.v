`define STATE_Start 0
`define STATE_Resting 1
`define STATE_LRI_Timer_Expired 2
`define STATE_VSense_Detected 3
`define STATE_Start 0
`define STATE_Resting 1
`define STATE_LRI_Timer_Expired 2
`define STATE_VSense_Detected 3
module FB_VVI_LRI 
(
		input wire clk,
		input wire VSense_eI,
		input wire LRI_Timer_Timeout_eI,
		output wire LRI_Timer_Start_eO,
		output wire LRI_Timer_Stop_eO,
		output wire VPace_eO,
		output reg signed [15:0] LRI_Timeout_Value_O ,
		input reset
);
wire VSense;
assign VSense = VSense_eI;
wire LRI_Timer_Timeout;
assign LRI_Timer_Timeout = LRI_Timer_Timeout_eI;
reg LRI_Timer_Start;
assign LRI_Timer_Start_eO = LRI_Timer_Start;
reg LRI_Timer_Stop;
assign LRI_Timer_Stop_eO = LRI_Timer_Stop;
reg VPace;
assign VPace_eO = VPace;
reg signed [15:0] LRI_Timeout_Value ;
reg [1:0] state = `STATE_Start;
reg entered = 1'b0;
reg LRI_Set_Timeout_Value_alg_en = 1'b0; 
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_Start;
		LRI_Timer_Start = 1'b0;
		LRI_Timer_Stop = 1'b0;
		VPace = 1'b0;
		LRI_Timeout_Value = 0;
	end else begin
		LRI_Timer_Start = 1'b0;
		LRI_Timer_Stop = 1'b0;
		VPace = 1'b0;
		entered = 1'b0;
		case(state) 
			`STATE_Start: begin
				if(1) begin
					state = `STATE_Resting;
					entered = 1'b1;
				end
			end 
			`STATE_Resting: begin
				if(VSense) begin
					state = `STATE_VSense_Detected;
					entered = 1'b1;
				end else if(LRI_Timer_Timeout) begin
					state = `STATE_LRI_Timer_Expired;
					entered = 1'b1;
				end
			end 
			`STATE_LRI_Timer_Expired: begin
				if(1) begin
					state = `STATE_Resting;
					entered = 1'b1;
				end
			end 
			`STATE_VSense_Detected: begin
				if(1) begin
					state = `STATE_Resting;
					entered = 1'b1;
				end
			end 
			default: begin
				state = 0;
			end
		endcase
		LRI_Set_Timeout_Value_alg_en = 1'b0; 
		if(entered) begin
			case(state)
				`STATE_Start: begin
				end 
				`STATE_Resting: begin
					LRI_Set_Timeout_Value_alg_en = 1'b1;
					LRI_Timer_Start = 1'b1;
				end 
				`STATE_LRI_Timer_Expired: begin
					VPace = 1'b1;
				end 
				`STATE_VSense_Detected: begin
					LRI_Timer_Stop = 1'b1;
				end 
				default: begin
				end
			endcase
		end
		if(LRI_Set_Timeout_Value_alg_en) begin
			LRI_Timeout_Value = 800;
		end 
		if(LRI_Timer_Start) begin 
			LRI_Timeout_Value_O = LRI_Timeout_Value;
		end
	end
end
endmodule
