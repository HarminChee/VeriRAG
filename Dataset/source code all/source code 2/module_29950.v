`define STATE_E_Stop 0
`define STATE_Running 1
`define STATE_Pause 2
`define STATE_E_Stop 0
`define STATE_Running 1
`define STATE_Pause 2
module FB_ConveyorController 
(
		input wire clk,
		input wire InjectDone_eI,
		input wire EmergencyStopChanged_eI,
		input wire LasersChanged_eI,
		output wire ConveyorChanged_eO,
		output wire ConveyorStoppedForInject_eO,
		input wire  EmergencyStop_I,
		input wire  InjectSiteLaser_I,
		output reg [7:0] ConveyorSpeed_O ,
		input reset
);
wire InjectDone;
assign InjectDone = InjectDone_eI;
wire EmergencyStopChanged;
assign EmergencyStopChanged = EmergencyStopChanged_eI;
wire LasersChanged;
assign LasersChanged = LasersChanged_eI;
reg ConveyorChanged;
assign ConveyorChanged_eO = ConveyorChanged;
reg ConveyorStoppedForInject;
assign ConveyorStoppedForInject_eO = ConveyorStoppedForInject;
reg  EmergencyStop ;
reg  InjectSiteLaser ;
reg [7:0] ConveyorSpeed ;
reg   Variable1 ; 
reg [1:0] state = `STATE_E_Stop;
reg entered = 1'b0;
reg ConveyorStart_alg_en = 1'b0; 
reg ConveyorStop_alg_en = 1'b0; 
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_E_Stop;
		ConveyorChanged = 1'b0;
		ConveyorStoppedForInject = 1'b0;
		EmergencyStop = 0;
		InjectSiteLaser = 0;
		ConveyorSpeed = 0;
		Variable1 = 0;
	end else begin
		ConveyorChanged = 1'b0;
		ConveyorStoppedForInject = 1'b0;
		if(EmergencyStopChanged) begin 
			EmergencyStop = EmergencyStop_I;
		end
		if(LasersChanged) begin 
			InjectSiteLaser = InjectSiteLaser_I;
		end
		entered = 1'b0;
		case(state) 
			`STATE_E_Stop: begin
				if(EmergencyStopChanged && ~EmergencyStop) begin
					state = `STATE_Running;
					entered = 1'b1;
				end
			end 
			`STATE_Running: begin
				if(LasersChanged && InjectSiteLaser) begin
					state = `STATE_Pause;
					entered = 1'b1;
				end
			end 
			`STATE_Pause: begin
				if(InjectDone) begin
					state = `STATE_Running;
					entered = 1'b1;
				end else if(EmergencyStopChanged && EmergencyStop) begin
					state = `STATE_E_Stop;
					entered = 1'b1;
				end
			end 
			default: begin
				state = 0;
			end
		endcase
		ConveyorStart_alg_en = 1'b0; 
		ConveyorStop_alg_en = 1'b0; 
		if(entered) begin
			case(state)
				`STATE_E_Stop: begin
				end 
				`STATE_Running: begin
					ConveyorStart_alg_en = 1'b1;
					ConveyorChanged = 1'b1;
				end 
				`STATE_Pause: begin
					ConveyorStop_alg_en = 1'b1;
					ConveyorChanged = 1'b1;
					ConveyorStoppedForInject = 1'b1;
				end 
				default: begin
				end
			endcase
		end
		if(ConveyorStart_alg_en) begin
			ConveyorSpeed = 1;
		end 
		if(ConveyorStop_alg_en) begin
			ConveyorSpeed = 0;
		end 
		if(ConveyorChanged) begin 
			ConveyorSpeed_O = ConveyorSpeed;
		end
	end
end
endmodule
