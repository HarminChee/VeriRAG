`define STATE_Clear 0
`define STATE_AwaitCanister 1
`define STATE_GoReject 2
`define STATE_Clear 0
`define STATE_AwaitCanister 1
`define STATE_GoReject 2
module FB_RejectArmController 
(
		input wire clk,
		input wire RejectCanister_eI,
		input wire LasersChanged_eI,
		output wire GoRejectArm_eO,
		input wire  RejectSiteLaser_I,
		input reset
);
wire RejectCanister;
assign RejectCanister = RejectCanister_eI;
wire LasersChanged;
assign LasersChanged = LasersChanged_eI;
reg GoRejectArm;
assign GoRejectArm_eO = GoRejectArm;
reg  RejectSiteLaser ;
reg [1:0] state = `STATE_Clear;
reg entered = 1'b0;
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_Clear;
		GoRejectArm = 1'b0;
		RejectSiteLaser = 0;
	end else begin
		GoRejectArm = 1'b0;
		if(LasersChanged) begin 
			RejectSiteLaser = RejectSiteLaser_I;
		end
		entered = 1'b0;
		case(state) 
			`STATE_Clear: begin
				if(RejectCanister) begin
					state = `STATE_AwaitCanister;
					entered = 1'b1;
				end
			end 
			`STATE_AwaitCanister: begin
				if(LasersChanged && RejectSiteLaser) begin
					state = `STATE_GoReject;
					entered = 1'b1;
				end
			end 
			`STATE_GoReject: begin
				if(RejectCanister) begin
					state = `STATE_AwaitCanister;
					entered = 1'b1;
				end
			end 
			default: begin
				state = 0;
			end
		endcase
		if(entered) begin
			case(state)
				`STATE_Clear: begin
				end 
				`STATE_AwaitCanister: begin
				end 
				`STATE_GoReject: begin
					GoRejectArm = 1'b1;
				end 
				default: begin
				end
			endcase
		end
	end
end
endmodule
