`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_STATUS_IN(	
	input CLK,
	input MODULE_RST,
	output reg		RESET,				
	output reg		FIFO_FULL,			
	output reg		TRAINING_DONE,		
	input STATUS,
	output reg		status_error		
							);
	reg			IDLE_RESET;
	reg			IDLE_FLAG;					
	reg			ambiguity;			
	reg [2:0]		error_cnt;
	reg	[7:0] shift_reg;
	parameter RST = 2'b00;
	parameter FULL = 2'b01;
	parameter DONE = 2'b10;
	parameter IDLE = 2'b11;
	reg	[1:0] INT_SAT;
	always @ ( negedge CLK ) begin
		if ( MODULE_RST == 1'b1 ) begin
			shift_reg <= 8'h00;
		end
		else begin
			shift_reg <= {shift_reg[6:0], STATUS};
		end
	end
	always @ ( negedge CLK ) begin
		ambiguity <= 1'b0;
		if ( shift_reg == 8'h55 | shift_reg == 8'hAA) begin
			INT_SAT <= RST;
		end
		else if ( shift_reg == 8'hF0 | shift_reg == 8'h87 | shift_reg == 8'hC3 | shift_reg == 8'hE1 | shift_reg == 8'h78 | shift_reg == 8'h3C | shift_reg == 8'h1E | shift_reg == 8'h0F ) begin
			INT_SAT <= FULL;
		end
		else if ( shift_reg == 8'h33 | shift_reg == 8'h66 | shift_reg == 8'hCC | shift_reg == 8'h99 ) begin
			INT_SAT <= DONE;
		end
		else if ( shift_reg == 8'h00) begin
			INT_SAT <= IDLE;
		end
		else begin
			INT_SAT <= INT_SAT;
			ambiguity <= 1'b1;
		end
	end
	always@ (negedge CLK) begin
		if (MODULE_RST) begin
			error_cnt <= 3'b000;
		end else if(ambiguity) begin
			if (error_cnt != 3'b111)
				error_cnt <= error_cnt + 3'b001;
			else
				error_cnt <= error_cnt;
		end else begin
			error_cnt <= 3'b000;
		end
	end
	always@ (negedge CLK) begin
		status_error <= (error_cnt == 3'b111) ? 1'b1 : 1'b0;
	end
	always @ (posedge CLK) begin
		if ( MODULE_RST == 1'b1 ) begin
			RESET <= 1'b0;
			TRAINING_DONE <= 1'b0;
			FIFO_FULL <= 1'b0;
			IDLE_RESET <= 0;
			IDLE_FLAG <= 0;
		end
		else if ( INT_SAT == RST) begin
			RESET <= 1'b1;
			TRAINING_DONE <= 1'b0;
			FIFO_FULL <= 1'b0;
			IDLE_RESET <= 0;
			IDLE_FLAG <= 0;
		end
		else if ( INT_SAT == DONE ) begin
			TRAINING_DONE <= 1'b1;
			FIFO_FULL <= 1'b0;
			RESET <= 1'b0;
			IDLE_RESET <= 0;
			IDLE_FLAG <= 0;
		end
		else if ( INT_SAT == FULL ) begin
			RESET <= 1'b0;
			FIFO_FULL <= 1'b1;
			TRAINING_DONE <= 1'b1;
			IDLE_RESET <= 0;
			IDLE_FLAG <= 0;
		end
		else if ( INT_SAT == IDLE ) begin
			if(IDLE_FLAG == 0)					
			begin
				IDLE_FLAG <= 1;
				IDLE_RESET <= 1;
			end
			else
			begin
				IDLE_RESET <= 0;
			end
			RESET <= 1'b0;
			FIFO_FULL <= 1'b0;
			TRAINING_DONE <= 1'b0;
		end
	end
endmodule
