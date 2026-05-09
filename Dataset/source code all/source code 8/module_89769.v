`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_STATUS_OUT(	CLK,
							RESET,				
							MODULE_RST,			
							FIFO_FULL,			
							TRAINING_DONE,		
							STATUS,
							INT_SAT				
							);
	input		CLK;
	input		MODULE_RST;
	input		RESET,
				FIFO_FULL,
				TRAINING_DONE;
	output	STATUS;
	reg		STATUS;
	output reg		[1:0] INT_SAT;
	parameter RST = 2'b00;
	parameter FULL = 2'b01;
	parameter DONE = 2'b10;
	parameter IDLE = 2'b11;
	reg		[2:0] counter;
	wire MODULE_RST_one;
	rising_edge_detect MODULE_RESET_one_inst(
						 .clk(CLK),
						 .rst(1'b0),
						 .in(MODULE_RST),
						 .one_shot_out(MODULE_RST_one)
						 );
	always @ ( posedge CLK ) begin
		if ( counter == 3'b000 ) begin
			if ( RESET == 1'b1 ) begin
				INT_SAT <= RST;
			end
			else if ( FIFO_FULL == 1'b1 & TRAINING_DONE == 1'b1 ) begin
				INT_SAT <= FULL;
			end
			else if ( TRAINING_DONE == 1'b1 ) begin
				INT_SAT <= DONE;
			end
			else begin
				INT_SAT <= IDLE;
			end
		end
	end
	always @ ( posedge CLK ) begin
		if ( MODULE_RST_one == 1'b1 ) begin
			counter <= 3'b000;
		end
		else begin
			counter <= counter + 3'b001;
		end
	end
	always @ ( posedge CLK) begin
		if ( INT_SAT == RST ) begin
			if ( counter == 3'b000 | counter == 3'b010 | counter == 3'b100 | counter == 3'b110 ) begin
				STATUS <= 1'b0;
			end
			else if (counter == 3'b001 | counter == 3'b011 | counter == 3'b101 | counter == 3'b111 ) begin
				STATUS <= 1'b1;
			end
		end
		else if ( INT_SAT == FULL) begin
			if (counter == 3'b000 | counter == 3'b001 | counter == 3'b010 | counter == 3'b011 ) begin
				STATUS <= 1'b0;
			end
			else if ( counter == 3'b100 | counter == 3'b101 | counter == 3'b110 | counter == 3'b111  ) begin
				STATUS <= 1'b1;
			end
		end
		else if ( INT_SAT == DONE) begin
			if ( counter == 3'b000 | counter == 3'b001 | counter == 3'b100 | counter == 3'b101  ) begin
				STATUS <= 1'b0;
			end
			else if ( counter == 3'b010 | counter == 3'b011 | counter == 3'b110 | counter == 3'b111  )begin
				STATUS <= 1'b1;
			end
		end
		else if ( INT_SAT == IDLE) begin
			STATUS <= 1'b0;
		end
	end
endmodule
