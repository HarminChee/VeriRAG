`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_TX (	CLK,
						CLKDIV,
						DATA_IN,
						SEND_EN,
						TRAINING_DONE,
						OSER_OQ,
						RST,
						RDEN);
	input 	CLK, CLKDIV, RST;
	input 	[31:0] DATA_IN;
	input   SEND_EN, TRAINING_DONE;
	output 	[3:0] OSER_OQ;
	output 	RDEN;
	reg  		[31:0] input_reg;
	wire 		[31:0] fifo_DO;
	wire 		RDEN;
	wire 		CE;
	reg [8:0] count;
	parameter NUM = 10'h008;    
	reg RDEN_REG;
	wire [7:0] PATTERN;
	assign 	RDEN = RDEN_REG;
	assign	fifo_DO = DATA_IN;
	assign   CE = 1'b1;
	always @ (posedge CLKDIV) begin
		if (RST == 1'b1) begin
			count <= 9'h000;
		end
		else begin
			if (count == 9'h000) begin
				if (SEND_EN == 1'b1) begin
					count <= 9'h001;
				end
			end
			else if (count == (NUM+9'h002) ) begin 
				if (SEND_EN == 1'b1) begin
					count <= 9'h001;
				end
				else begin
					count <= 9'h000;
				end				
			end
			else begin
				count <= count + 9'h001;
			end
		end			
	end
	always @ (negedge CLKDIV) begin
		if (RST == 1'b1) begin
			RDEN_REG <= 1'b0;
		end
		else if (count == 9'h002) begin
			RDEN_REG <= 1'b1;
		end
		else if (count == NUM+9'h002) begin
			RDEN_REG <= 1'b0;
		end
	end
	RCB_FRL_TrainingPattern RCB_FRL_TrainingPattern_inst(
		.CLK(CLKDIV),
		.RST(RST),
		.DATA_OUT(PATTERN));			
	reg [7:0] data_count1;		
	always @ (negedge CLKDIV) begin
		if ( RST == 1'b1 ) begin
			input_reg[31:0] <= 32'h00000000;
			data_count1 <= 0;
		end
		else if (count == 9'h001) begin
			input_reg[31:0] <= 32'hF5F5F5F5;
		end
		else if (count == 9'h002) begin
			input_reg[31:0] <= {NUM[7:0],NUM[7:0],NUM[7:0],NUM[7:0]};
		end
		else if (count == 9'h000) begin
			input_reg[31:0] <= 32'h44444444;
		end
		else if (count > NUM+9'h002) begin
			input_reg[31:0] <= 32'h00000000;
		end
		else begin
			input_reg[31:0] <= fifo_DO[31:0];
		end
	end
	wire [31:0] input_reg_INV;
	assign input_reg_INV = TRAINING_DONE ? input_reg : {PATTERN,PATTERN,PATTERN,PATTERN};
	RCB_FRL_OSERDES RCB_FRL_OSERDES_inst1 (.OQ(OSER_OQ[0]), .CLK(CLK), .CLKDIV(CLKDIV), .DI(input_reg_INV[7:0]), .OCE(1'b1), .SR(RST));
	RCB_FRL_OSERDES RCB_FRL_OSERDES_inst2 (.OQ(OSER_OQ[1]), .CLK(CLK), .CLKDIV(CLKDIV), .DI(input_reg_INV[15:8]), .OCE(1'b1), .SR(RST));
	RCB_FRL_OSERDES RCB_FRL_OSERDES_inst3 (.OQ(OSER_OQ[2]), .CLK(CLK), .CLKDIV(CLKDIV), .DI(input_reg_INV[23:16]), .OCE(1'b1), .SR(RST));
	RCB_FRL_OSERDES RCB_FRL_OSERDES_inst4 (.OQ(OSER_OQ[3]), .CLK(CLK), .CLKDIV(CLKDIV), .DI(input_reg_INV[31:24]), .OCE(1'b1), .SR(RST));
endmodule
