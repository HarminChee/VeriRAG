`define STATE_E_Stop 0
`define STATE_Run 1
`define STATE_Await 2
`define STATE_E_Stop 0
`define STATE_Run 1
`define STATE_Await 2
module FB_DoorController 
(
		input wire clk,
		input wire ReleaseDoorOverride_eI,
		input wire BottlingDone_eI,
		input wire EmergencyStopChanged_eI,
		output wire DoorReleaseCanister_eO,
		input wire  EmergencyStop_I,
		input reset
);
wire ReleaseDoorOverride;
assign ReleaseDoorOverride = ReleaseDoorOverride_eI;
wire BottlingDone;
assign BottlingDone = BottlingDone_eI;
wire EmergencyStopChanged;
assign EmergencyStopChanged = EmergencyStopChanged_eI;
reg DoorReleaseCanister;
assign DoorReleaseCanister_eO = DoorReleaseCanister;
reg  EmergencyStop ;
reg [1:0] state = `STATE_E_Stop;
reg entered = 1'b0;
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_E_Stop;
		DoorReleaseCanister = 1'b0;
		EmergencyStop = 0;
	end else begin
		DoorReleaseCanister = 1'b0;
		if(EmergencyStopChanged) begin 
			EmergencyStop = EmergencyStop_I;
		end
		entered = 1'b0;
		case(state) 
			`STATE_E_Stop: begin
				if(EmergencyStopChanged && ~EmergencyStop) begin
					state = `STATE_Await;
					entered = 1'b1;
				end
			end 
			`STATE_Run: begin
				if(EmergencyStopChanged && EmergencyStop) begin
					state = `STATE_E_Stop;
					entered = 1'b1;
				end else if(ReleaseDoorOverride || BottlingDone) begin
					state = `STATE_Run;
					entered = 1'b1;
				end
			end 
			`STATE_Await: begin
				if(ReleaseDoorOverride || BottlingDone) begin
					state = `STATE_Run;
					entered = 1'b1;
				end
			end 
			default: begin
				state = 0;
			end
		endcase
		if(entered) begin
			case(state)
				`STATE_E_Stop: begin
				end 
				`STATE_Run: begin
					DoorReleaseCanister = 1'b1;
				end 
				`STATE_Await: begin
				end 
				default: begin
				end
			endcase
		end
	end
end
endmodule
