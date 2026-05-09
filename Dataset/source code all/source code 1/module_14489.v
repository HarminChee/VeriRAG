`define STATE_RejectCanister 0
`define STATE_AwaitPump 1
`define STATE_VacuumPump 2
`define STATE_FinishPump 3
`define STATE_StartPump 4
`define STATE_OpenValve 5
`define STATE_StopVacuum 6
`define STATE_RejectCanister 0
`define STATE_AwaitPump 1
`define STATE_VacuumPump 2
`define STATE_FinishPump 3
`define STATE_StartPump 4
`define STATE_OpenValve 5
`define STATE_StopVacuum 6
module FB_InjectorPumpsController 
(
		input wire clk,
		input wire StartPump_eI,
		input wire EmergencyStopChanged_eI,
		input wire CanisterPressureChanged_eI,
		input wire FillContentsAvailableChanged_eI,
		input wire VacuumTimerElapsed_eI,
		output wire PumpFinished_eO,
		output wire RejectCanister_eO,
		output wire InjectorControlsChanged_eO,
		output wire FillContentsChanged_eO,
		output wire StartVacuumTimer_eO,
		input wire  EmergencyStop_I,
		input wire [7:0] CanisterPressure_I,
		input wire [7:0] FillContentsAvailable_I,
		output reg  InjectorContentsValveOpen_O ,
		output reg  InjectorVacuumRun_O ,
		output reg  InjectorPressurePumpRun_O ,
		output reg  FillContents_O ,
		input reset
);
wire StartPump;
assign StartPump = StartPump_eI;
wire EmergencyStopChanged;
assign EmergencyStopChanged = EmergencyStopChanged_eI;
wire CanisterPressureChanged;
assign CanisterPressureChanged = CanisterPressureChanged_eI;
wire FillContentsAvailableChanged;
assign FillContentsAvailableChanged = FillContentsAvailableChanged_eI;
wire VacuumTimerElapsed;
assign VacuumTimerElapsed = VacuumTimerElapsed_eI;
reg PumpFinished;
assign PumpFinished_eO = PumpFinished;
reg RejectCanister;
assign RejectCanister_eO = RejectCanister;
reg InjectorControlsChanged;
assign InjectorControlsChanged_eO = InjectorControlsChanged;
reg FillContentsChanged;
assign FillContentsChanged_eO = FillContentsChanged;
reg StartVacuumTimer;
assign StartVacuumTimer_eO = StartVacuumTimer;
reg  EmergencyStop ;
reg [7:0] CanisterPressure ;
reg [7:0] FillContentsAvailable ;
reg  InjectorContentsValveOpen ;
reg  InjectorVacuumRun ;
reg  InjectorPressurePumpRun ;
reg  FillContents ;
reg [2:0] state = `STATE_RejectCanister;
reg entered = 1'b0;
reg StartVacuum_alg_en = 1'b0; 
reg ClearControls_alg_en = 1'b0; 
reg OpenValve_alg_en = 1'b0; 
reg StartPump_alg_en = 1'b0; 
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_RejectCanister;
		PumpFinished = 1'b0;
		RejectCanister = 1'b0;
		InjectorControlsChanged = 1'b0;
		FillContentsChanged = 1'b0;
		StartVacuumTimer = 1'b0;
		EmergencyStop = 0;
		CanisterPressure = 0;
		FillContentsAvailable = 0;
		InjectorContentsValveOpen = 0;
		InjectorVacuumRun = 0;
		InjectorPressurePumpRun = 0;
		FillContents = 0;
	end else begin
		PumpFinished = 1'b0;
		RejectCanister = 1'b0;
		InjectorControlsChanged = 1'b0;
		FillContentsChanged = 1'b0;
		StartVacuumTimer = 1'b0;
		if(EmergencyStopChanged) begin 
			EmergencyStop = EmergencyStop_I;
		end
		if(CanisterPressureChanged) begin 
			CanisterPressure = CanisterPressure_I;
		end
		if(FillContentsAvailableChanged) begin 
			FillContentsAvailable = FillContentsAvailable_I;
		end
		entered = 1'b0;
		case(state) 
			`STATE_RejectCanister: begin
				if(1) begin
					state = `STATE_AwaitPump;
					entered = 1'b1;
				end
			end 
			`STATE_AwaitPump: begin
				if(StartPump) begin
					state = `STATE_VacuumPump;
					entered = 1'b1;
				end
			end 
			`STATE_VacuumPump: begin
				if(VacuumTimerElapsed) begin
					state = `STATE_RejectCanister;
					entered = 1'b1;
				end else if(CanisterPressureChanged && CanisterPressure <= 10) begin
					state = `STATE_StopVacuum;
					entered = 1'b1;
				end
			end 
			`STATE_FinishPump: begin
				if(1) begin
					state = `STATE_AwaitPump;
					entered = 1'b1;
				end
			end 
			`STATE_StartPump: begin
				if(CanisterPressureChanged && CanisterPressure >= 245) begin
					state = `STATE_FinishPump;
					entered = 1'b1;
				end
			end 
			`STATE_OpenValve: begin
				if(1) begin
					state = `STATE_StartPump;
					entered = 1'b1;
				end
			end 
			`STATE_StopVacuum: begin
				if(1) begin
					state = `STATE_OpenValve;
					entered = 1'b1;
				end
			end 
			default: begin
				state = 0;
			end
		endcase
		StartVacuum_alg_en = 1'b0; 
		ClearControls_alg_en = 1'b0; 
		OpenValve_alg_en = 1'b0; 
		StartPump_alg_en = 1'b0; 
		if(entered) begin
			case(state)
				`STATE_RejectCanister: begin
					ClearControls_alg_en = 1'b1;
					RejectCanister = 1'b1;
					InjectorControlsChanged = 1'b1;
				end 
				`STATE_AwaitPump: begin
					PumpFinished = 1'b1;
				end 
				`STATE_VacuumPump: begin
					StartVacuum_alg_en = 1'b1;
					InjectorControlsChanged = 1'b1;
					StartVacuumTimer = 1'b1;
				end 
				`STATE_FinishPump: begin
					ClearControls_alg_en = 1'b1;
					InjectorControlsChanged = 1'b1;
				end 
				`STATE_StartPump: begin
					StartPump_alg_en = 1'b1;
					InjectorControlsChanged = 1'b1;
				end 
				`STATE_OpenValve: begin
					OpenValve_alg_en = 1'b1;
					InjectorControlsChanged = 1'b1;
				end 
				`STATE_StopVacuum: begin
					ClearControls_alg_en = 1'b1;
					InjectorControlsChanged = 1'b1;
				end 
				default: begin
				end
			endcase
		end
		if(StartVacuum_alg_en) begin
			InjectorVacuumRun = 1;
		end 
		if(ClearControls_alg_en) begin
			InjectorContentsValveOpen = 0;
InjectorPressurePumpRun = 0;
InjectorVacuumRun = 0;
		end 
		if(OpenValve_alg_en) begin
			InjectorContentsValveOpen = 1;
		end 
		if(StartPump_alg_en) begin
			InjectorPressurePumpRun = 1;
		end 
		if(InjectorControlsChanged) begin 
			InjectorContentsValveOpen_O = InjectorContentsValveOpen;
			InjectorVacuumRun_O = InjectorVacuumRun;
			InjectorPressurePumpRun_O = InjectorPressurePumpRun;
		end
		if(FillContentsChanged) begin 
			FillContents_O = FillContents;
		end
	end
end
endmodule
