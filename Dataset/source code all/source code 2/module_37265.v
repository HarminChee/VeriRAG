`define STATE_Start 0
`define STATE_Start 0
module FB_CanisterCounter 
(
		input wire clk,
		input wire LasersChanged_eI,
		output wire CanisterCountChanged_eO,
		input wire  DoorSiteLaser_I,
		input wire  RejectBinLaser_I,
		input wire  AcceptBinLaser_I,
		output reg [7:0] CanisterCount_O ,
		input reset
);
wire LasersChanged;
assign LasersChanged = LasersChanged_eI;
reg CanisterCountChanged;
assign CanisterCountChanged_eO = CanisterCountChanged;
reg  DoorSiteLaser ;
reg  RejectBinLaser ;
reg  AcceptBinLaser ;
reg [7:0] CanisterCount ;
reg  state = `STATE_Start;
reg entered = 1'b0;
reg ChangeCount_alg_en = 1'b0; 
always@(posedge clk) begin
	if(reset) begin
		state = `STATE_Start;
		CanisterCountChanged = 1'b0;
		DoorSiteLaser = 0;
		RejectBinLaser = 0;
		AcceptBinLaser = 0;
		CanisterCount = 0;
	end else begin
		CanisterCountChanged = 1'b0;
		if(LasersChanged) begin 
			DoorSiteLaser = DoorSiteLaser_I;
			RejectBinLaser = RejectBinLaser_I;
			AcceptBinLaser = AcceptBinLaser_I;
		end
		entered = 1'b0;
		case(state) 
			`STATE_Start: begin
				if(LasersChanged) begin
					state = `STATE_Start;
					entered = 1'b1;
				end
			end 
			default: begin
				state = 0;
			end
		endcase
		ChangeCount_alg_en = 1'b0; 
		if(entered) begin
			case(state)
				`STATE_Start: begin
					ChangeCount_alg_en = 1'b1;
					CanisterCountChanged = 1'b1;
				end 
				default: begin
				end
			endcase
		end
		if(ChangeCount_alg_en) begin
			if (DoorSiteLaser) begin
			CanisterCount = CanisterCount + 1;
		end
		if (RejectBinLaser) begin
			CanisterCount = CanisterCount - 1;
		end
		if (AcceptBinLaser) begin
			CanisterCount = CanisterCount - 1;
		end
		end 
		if(CanisterCountChanged) begin 
			CanisterCount_O = CanisterCount;
		end
	end
end
endmodule
