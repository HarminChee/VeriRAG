`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_TX (
		input				CLK,
		input				CLKDIV,
		input				RST,
		input [31:0]	DATA_IN,
		input				SEND_EN,
		input				TRAINING_DONE,
		output [3:0]	OSER_OQ,
		output			RDEN
	);
	reg  		[31:0] frame_data;
	reg [8:0] count;
	parameter NUM = 10'h008;    
	reg RDEN_REG;		
	assign 	RDEN = RDEN_REG;
	wire [7:0] PATTERN;
	wire [31:0] data_to_oserdes;	
	assign data_to_oserdes = TRAINING_DONE ? frame_data : {8'h5c,8'h5c,8'h5c,8'h5c};				
	always @ (posedge CLKDIV) begin
		if (RST == 1'b1) begin
			count <= 9'h000;
		end else begin
			if (count == 9'h000) begin
				if (SEND_EN == 1'b1) 
					count <= 9'h001;
				else
					count <= 9'h000;
			end else if (count == (NUM+9'h002) ) begin 
				if (SEND_EN == 1'b1) begin
					count <= 9'h001;
				end else begin
					count <= 9'h000;
				end				
			end else begin
				count <= count + 9'h001;
			end
		end			
	end
	always @ (posedge CLKDIV) begin
		if (RST == 1'b1) begin
			RDEN_REG <= 1'b0;
		end
		else if (count == 9'h001) begin
			RDEN_REG <= 1'b1;
		end
		else if (count == NUM+9'h001) begin
			RDEN_REG <= 1'b0;
		end
	end
	RCB_FRL_TrainingPattern RCB_FRL_TrainingPattern_inst(
		.clk			(CLKDIV),
		.rst			(RST),
		.trainingpattern	(PATTERN)
	);			
	always @ (posedge CLKDIV) begin
		if ( RST == 1'b1 ) begin
			frame_data[31:0] <= 32'h00000000;
		end else if (count == 9'h001) begin		
			frame_data[31:0] <= 32'hF5F5F5F5;
		end else if (count == 9'h002) begin
			frame_data[31:0] <= {NUM[7:0],NUM[7:0],NUM[7:0],NUM[7:0]};	
		end else if (count == 9'h000) begin
			frame_data[31:0] <= 32'h44444444;	
		end else if (count > NUM+9'h002) begin
			frame_data[31:0] <= 32'h00000000;	
		end else begin
			frame_data[31:0] <= DATA_IN[31:0];	
		end
	end
	RCB_FRL_OSERDES RCB_FRL_OSERDES_inst1 (
		.OQ(OSER_OQ[0]), 
		.CLK(CLK), 
		.CLKDIV(CLKDIV), 
		.DI(data_to_oserdes[7:0]), 
		.OCE(1'b1), 
		.SR(RST)
	);
	RCB_FRL_OSERDES RCB_FRL_OSERDES_inst2 (
		.OQ(OSER_OQ[1]), 
		.CLK(CLK), 
		.CLKDIV(CLKDIV), 
		.DI(data_to_oserdes[15:8]), 
		.OCE(1'b1), 
		.SR(RST)
	);
	RCB_FRL_OSERDES RCB_FRL_OSERDES_inst3 (
		.OQ(OSER_OQ[2]), 
		.CLK(CLK), 
		.CLKDIV(CLKDIV), 
		.DI(data_to_oserdes[23:16]), 
		.OCE(1'b1), 
		.SR(RST)
	);
	RCB_FRL_OSERDES RCB_FRL_OSERDES_inst4 (
		.OQ(OSER_OQ[3]), 
		.CLK(CLK), 
		.CLKDIV(CLKDIV), 
		.DI(data_to_oserdes[31:24]), 
		.OCE(1'b1), 
		.SR(RST)
	);
endmodule 
