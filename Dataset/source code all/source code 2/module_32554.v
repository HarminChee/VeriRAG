`define STATE_s_start 0
`define STATE_s_idle 1
`define STATE_s_balance 2
`define STATE_s_fill 3
`define STATE_s_start 0
`define STATE_s_idle 1
`define STATE_s_balance 2
`define STATE_s_fill 3
module FB_BfbWaterPump 
(
		input wire clk,
		input wire UpdateLevels_eI,
		input wire UpdateControls_eI,
		output wire UpdatePump_eO,
		input wire unsigned [7:0] Level1_I,
		input wire unsigned [7:0] Level2_I,
		input wire  ModeBalance_I,
		input wire  ModeFill1_I,
		input wire  ModeFill2_I,
		output reg  PumpDir_O  = 0,
		output reg  PumpRun_O  = 0,
		input reset
);
wire UpdateLevels;
assign UpdateLevels = UpdateLevels_eI;
wire UpdateControls;
assign UpdateControls = UpdateControls_eI;
reg UpdatePump;
assign UpdatePump_eO = UpdatePump;
reg unsigned [7:0] Level1  = 0;
reg unsigned [7:0] Level2  = 0;
reg  ModeBalance ;
reg  ModeFill1 ;
reg  ModeFill2 ;
reg  PumpDir  = 0;
reg  PumpRun  = 0;
reg [1:0] state = `STATE_s_start;
reg entered = 1'b0;
reg s_idle_alg0_alg_en = 1'b0; 
reg s_balance_alg0_alg_en = 1'b0; 
reg s_fill_alg0_alg_en = 1'b0; 
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_s_start;
		UpdatePump = 1'b0;
		Level1 = 0;
		Level2 = 0;
		ModeBalance = 0;
		ModeFill1 = 0;
		ModeFill2 = 0;
		PumpDir = 0;
		PumpRun = 0;
	end else begin
		UpdatePump = 1'b0;
		if(UpdateLevels) begin 
			Level1 = Level1_I;
			Level2 = Level2_I;
		end
		if(UpdateControls) begin 
			ModeBalance = ModeBalance_I;
			ModeFill1 = ModeFill1_I;
			ModeFill2 = ModeFill2_I;
		end
		entered = 1'b0;
		case(state) 
			`STATE_s_start: begin
				if(1) begin
					state = `STATE_s_idle;
					entered = 1'b1;
				end
			end 
			`STATE_s_idle: begin
				if(UpdateControls && ModeBalance) begin
					state = `STATE_s_balance;
					entered = 1'b1;
				end else if(UpdateControls && ModeFill1 || ModeFill2) begin
					state = `STATE_s_fill;
					entered = 1'b1;
				end
			end 
			`STATE_s_balance: begin
				if(UpdateControls && ~ModeBalance && ModeFill1 || ModeFill2) begin
					state = `STATE_s_fill;
					entered = 1'b1;
				end else if(UpdateControls && ~ModeBalance) begin
					state = `STATE_s_idle;
					entered = 1'b1;
				end else if(UpdateLevels) begin
					state = `STATE_s_balance;
					entered = 1'b1;
				end
			end 
			`STATE_s_fill: begin
				if(UpdateControls && ModeBalance) begin
					state = `STATE_s_balance;
					entered = 1'b1;
				end else if(UpdateControls && ~ModeBalance && ~ModeFill1 && ~ModeFill2) begin
					state = `STATE_s_idle;
					entered = 1'b1;
				end else if(UpdateControls) begin
					state = `STATE_s_fill;
					entered = 1'b1;
				end
			end 
			default: begin
				state = 0;
			end
		endcase
		s_idle_alg0_alg_en = 1'b0; 
		s_balance_alg0_alg_en = 1'b0; 
		s_fill_alg0_alg_en = 1'b0; 
		if(entered) begin
			case(state)
				`STATE_s_start: begin
				end 
				`STATE_s_idle: begin
					UpdatePump = 1'b1;
					s_idle_alg0_alg_en = 1'b1;
				end 
				`STATE_s_balance: begin
					UpdatePump = 1'b1;
					s_balance_alg0_alg_en = 1'b1;
				end 
				`STATE_s_fill: begin
					UpdatePump = 1'b1;
					s_fill_alg0_alg_en = 1'b1;
				end 
				default: begin
				end
			endcase
		end
		if(s_idle_alg0_alg_en) begin
			PumpDir = 0;
PumpRun = 0;
		end 
		if(s_balance_alg0_alg_en) begin
			if (Level1 > Level2) begin
			PumpDir = 0;
PumpRun = 1;
		end
		 else if (Level2 > Level1) begin
			PumpDir = 1;
PumpRun = 1;
		end
		 else begin 
		PumpRun = 0;
	end
		end 
		if(s_fill_alg0_alg_en) begin
			if (ModeFill1) begin
			PumpDir = 1;
PumpRun = 1;
		end
		 else if (ModeFill2) begin
			PumpDir = 0;
PumpRun = 1;
		end
		 else begin 
		PumpRun = 0;
	end
		end 
		if(UpdatePump) begin 
			PumpDir_O = PumpDir;
			PumpRun_O = PumpRun;
		end
	end
end
endmodule
