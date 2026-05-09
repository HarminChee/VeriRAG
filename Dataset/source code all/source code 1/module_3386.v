`define STATE_Start 0
`define STATE_Wait_For_VSense 1
`define STATE_Resting 2
`define STATE_Detected_VPulse 3
`define STATE_Detected_VRefractory 4
`define STATE_Start 0
`define STATE_Wait_For_VSense 1
`define STATE_Resting 2
`define STATE_Detected_VPulse 3
`define STATE_Detected_VRefractory 4
module FB_VVI_VRP 
(
		input wire clk,
		input wire VPulse_eI,
		input wire VPace_eI,
		input wire VRP_Timer_Timeout_eI,
		output wire VRP_Start_Timer_eO,
		output wire VSense_eO,
		output wire VRefractory_eO,
		output reg signed [15:0] VRP_Timeout_Value_O ,
		input reset
);
wire VPulse;
assign VPulse = VPulse_eI;
wire VPace;
assign VPace = VPace_eI;
wire VRP_Timer_Timeout;
assign VRP_Timer_Timeout = VRP_Timer_Timeout_eI;
reg VRP_Start_Timer;
assign VRP_Start_Timer_eO = VRP_Start_Timer;
reg VSense;
assign VSense_eO = VSense;
reg VRefractory;
assign VRefractory_eO = VRefractory;
reg signed [15:0] VRP_Timeout_Value ;
reg [2:0] state = `STATE_Start;
reg entered = 1'b0;
reg VRP_Set_Timeout_Value_alg_en = 1'b0; 
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_Start;
		VRP_Start_Timer = 1'b0;
		VSense = 1'b0;
		VRefractory = 1'b0;
		VRP_Timeout_Value = 0;
	end else begin
		VRP_Start_Timer = 1'b0;
		VSense = 1'b0;
		VRefractory = 1'b0;
		entered = 1'b0;
		case(state) 
			`STATE_Start: begin
				if(1) begin
					state = `STATE_Detected_VPulse;
					entered = 1'b1;
				end
			end 
			`STATE_Wait_For_VSense: begin
				if(VPulse) begin
					state = `STATE_Resting;
					entered = 1'b1;
				end else if(VPace) begin
					state = `STATE_Resting;
					entered = 1'b1;
				end
			end 
			`STATE_Resting: begin
				if(VPulse) begin
					state = `STATE_Detected_VRefractory;
					entered = 1'b1;
				end else if(VRP_Timer_Timeout) begin
					state = `STATE_Wait_For_VSense;
					entered = 1'b1;
				end
			end 
			`STATE_Detected_VPulse: begin
				if(VRP_Timer_Timeout) begin
					state = `STATE_Wait_For_VSense;
					entered = 1'b1;
				end
			end 
			`STATE_Detected_VRefractory: begin
				if(1) begin
					state = `STATE_Resting;
					entered = 1'b1;
				end
			end 
			default: begin
				state = 0;
			end
		endcase
		VRP_Set_Timeout_Value_alg_en = 1'b0; 
		if(entered) begin
			case(state)
				`STATE_Start: begin
				end 
				`STATE_Wait_For_VSense: begin
				end 
				`STATE_Resting: begin
					VRP_Set_Timeout_Value_alg_en = 1'b1;
					VRP_Start_Timer = 1'b1;
					VSense = 1'b1;
				end 
				`STATE_Detected_VPulse: begin
					VRP_Set_Timeout_Value_alg_en = 1'b1;
					VRP_Start_Timer = 1'b1;
				end 
				`STATE_Detected_VRefractory: begin
					VRefractory = 1'b1;
				end 
				default: begin
				end
			endcase
		end
		if(VRP_Set_Timeout_Value_alg_en) begin
			VRP_Timeout_Value = 300;
		end 
		if(VRP_Start_Timer) begin 
			VRP_Timeout_Value_O = VRP_Timeout_Value;
		end
	end
end
endmodule
