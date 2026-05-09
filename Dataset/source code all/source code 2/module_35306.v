`define STATE_Start 0
`define STATE_Start 0
module FB_IOManager 
(
		input wire clk,
		input wire DoorReleaseCanister_eI,
		input wire ConveyorChanged_eI,
		input wire InjectorPositionChanged_eI,
		input wire InjectorControlsChanged_eI,
		input wire FillContentsChanged_eI,
		input wire StartVacuumTimer_eI,
		input wire GoRejectArm_eI,
		input wire CanisterCountChanged_eI,
		input wire InjectDone_eI,
		output wire InjectorArmFinishMovement_eO,
		output wire EmergencyStopChanged_eO,
		output wire CanisterPressureChanged_eO,
		output wire FillContentsAvailableChanged_eO,
		output wire LasersChanged_eO,
		output wire DoorOverride_eO,
		output wire VacuumTimerElapsed_eO,
		input wire [7:0] ConveyorSpeed_I,
		input wire [7:0] InjectorPosition_I,
		input wire  InjectorContentsValveOpen_I,
		input wire  InjectorVacuumRun_I,
		input wire  InjectorPressurePumpRun_I,
		input wire  FillContents_I,
		input wire [7:0] CanisterCount_I,
		output reg  EmergencyStop_O ,
		output reg [7:0] CanisterPressure_O ,
		output reg [7:0] FillContentsAvailable_O ,
		output reg  DoorSiteLaser_O ,
		output reg  InjectSiteLaser_O ,
		output reg  RejectSiteLaser_O ,
		output reg  RejectBinLaser_O ,
		output reg  AcceptBinLaser_O ,
		input reset
);
wire DoorReleaseCanister;
assign DoorReleaseCanister = DoorReleaseCanister_eI;
wire ConveyorChanged;
assign ConveyorChanged = ConveyorChanged_eI;
wire InjectorPositionChanged;
assign InjectorPositionChanged = InjectorPositionChanged_eI;
wire InjectorControlsChanged;
assign InjectorControlsChanged = InjectorControlsChanged_eI;
wire FillContentsChanged;
assign FillContentsChanged = FillContentsChanged_eI;
wire StartVacuumTimer;
assign StartVacuumTimer = StartVacuumTimer_eI;
wire GoRejectArm;
assign GoRejectArm = GoRejectArm_eI;
wire CanisterCountChanged;
assign CanisterCountChanged = CanisterCountChanged_eI;
wire InjectDone;
assign InjectDone = InjectDone_eI;
reg InjectorArmFinishMovement;
assign InjectorArmFinishMovement_eO = InjectorArmFinishMovement;
reg EmergencyStopChanged;
assign EmergencyStopChanged_eO = EmergencyStopChanged;
reg CanisterPressureChanged;
assign CanisterPressureChanged_eO = CanisterPressureChanged;
reg FillContentsAvailableChanged;
assign FillContentsAvailableChanged_eO = FillContentsAvailableChanged;
reg LasersChanged;
assign LasersChanged_eO = LasersChanged;
reg DoorOverride;
assign DoorOverride_eO = DoorOverride;
reg VacuumTimerElapsed;
assign VacuumTimerElapsed_eO = VacuumTimerElapsed;
reg [7:0] ConveyorSpeed ;
reg [7:0] InjectorPosition ;
reg  InjectorContentsValveOpen ;
reg  InjectorVacuumRun ;
reg  InjectorPressurePumpRun ;
reg  FillContents ;
reg [7:0] CanisterCount ;
reg  EmergencyStop ;
reg [7:0] CanisterPressure ;
reg [7:0] FillContentsAvailable ;
reg  DoorSiteLaser ;
reg  InjectSiteLaser ;
reg  RejectSiteLaser ;
reg  RejectBinLaser ;
reg  AcceptBinLaser ;
reg   EmergencyStopped ; 
reg  state = `STATE_Start;
reg entered = 1'b0;
reg IOAlgorithm_alg_en = 1'b0; 
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_Start;
		InjectorArmFinishMovement = 1'b0;
		EmergencyStopChanged = 1'b0;
		CanisterPressureChanged = 1'b0;
		FillContentsAvailableChanged = 1'b0;
		LasersChanged = 1'b0;
		DoorOverride = 1'b0;
		VacuumTimerElapsed = 1'b0;
		ConveyorSpeed = 0;
		InjectorPosition = 0;
		InjectorContentsValveOpen = 0;
		InjectorVacuumRun = 0;
		InjectorPressurePumpRun = 0;
		FillContents = 0;
		CanisterCount = 0;
		EmergencyStop = 0;
		CanisterPressure = 0;
		FillContentsAvailable = 0;
		DoorSiteLaser = 0;
		InjectSiteLaser = 0;
		RejectSiteLaser = 0;
		RejectBinLaser = 0;
		AcceptBinLaser = 0;
		EmergencyStopped = 0;
	end else begin
		InjectorArmFinishMovement = 1'b0;
		EmergencyStopChanged = 1'b0;
		CanisterPressureChanged = 1'b0;
		FillContentsAvailableChanged = 1'b0;
		LasersChanged = 1'b0;
		DoorOverride = 1'b0;
		VacuumTimerElapsed = 1'b0;
		if(ConveyorChanged) begin 
			ConveyorSpeed = ConveyorSpeed_I;
		end
		if(InjectorPositionChanged) begin 
			InjectorPosition = InjectorPosition_I;
		end
		if(InjectorControlsChanged) begin 
			InjectorContentsValveOpen = InjectorContentsValveOpen_I;
			InjectorVacuumRun = InjectorVacuumRun_I;
			InjectorPressurePumpRun = InjectorPressurePumpRun_I;
		end
		if(FillContentsChanged) begin 
			FillContents = FillContents_I;
		end
		if(CanisterCountChanged) begin 
			CanisterCount = CanisterCount_I;
		end
		entered = 1'b0;
		case(state) 
			`STATE_Start: begin
				if(1) begin
					state = `STATE_Start;
					entered = 1'b1;
				end
			end 
			default: begin
				state = 0;
			end
		endcase
		IOAlgorithm_alg_en = 1'b0; 
		if(entered) begin
			case(state)
				`STATE_Start: begin
					IOAlgorithm_alg_en = 1'b1;
					EmergencyStopChanged = 1'b1;
				end 
				default: begin
				end
			endcase
		end
		if(IOAlgorithm_alg_en) begin
		end 
		if(EmergencyStopChanged) begin 
			EmergencyStop_O = EmergencyStop;
		end
		if(CanisterPressureChanged) begin 
			CanisterPressure_O = CanisterPressure;
		end
		if(FillContentsAvailableChanged) begin 
			FillContentsAvailable_O = FillContentsAvailable;
		end
		if(LasersChanged) begin 
			DoorSiteLaser_O = DoorSiteLaser;
			InjectSiteLaser_O = InjectSiteLaser;
			RejectSiteLaser_O = RejectSiteLaser;
			RejectBinLaser_O = RejectBinLaser;
			AcceptBinLaser_O = AcceptBinLaser;
		end
	end
end
endmodule
