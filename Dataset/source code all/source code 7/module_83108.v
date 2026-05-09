`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_TX_MSG (
		CLK, 
		CLKDIV, 
		DATA_IN, 
		OSER_OQ, 
		RST, 
		CLKWR, 
		WREN, 
		CON_P, 
		CON_N, 
		BACK_WRONG, 
		BACK_RIGHT, 
		ALMOSTFULL, 
		EMPTY, 
		probe, 
		EN_SIG, 
		RE_SIG, 
		TRAINING_DONE
	);
	input CLK, CLKDIV, RST, CLKWR, WREN, CON_P, CON_N, TRAINING_DONE;
	input [39:0] DATA_IN;
	output probe;
	input RE_SIG, EN_SIG;
	output OSER_OQ;
	output BACK_WRONG, BACK_RIGHT, ALMOSTFULL;
	output EMPTY;
	reg [7:0] input_reg;
	wire [39:0] fifo_DO;
	wire ALMOSTEMPTY, ALMOSTFULL, EMPTY, FULL;
	wire EMPTY_fifo;				
	wire RDEN;
	reg [8:0] count;
	parameter NUM = 8'h06;
	reg RDEN_REG;
	RCB_FRL_fifo_MSG RCB_FRL_fifo_MSG_inst (
			.ALMOSTEMPTY(ALMOSTEMPTY), 
			.ALMOSTFULL(ALMOSTFULL), 
			.DO(fifo_DO), 
			.EMPTY(EMPTY_fifo),			
			.FULL(FULL), 
			.DI(DATA_IN), 
			.RDCLK(CLKDIV), 
			.RDEN(RDEN_REG), 
			.WRCLK(CLKWR), 
			.WREN(WREN), 
			.RST(RST)
	);
	wire [7:0] CRC;
	RCB_FRL_CRC_gen RCB_FRL_CRC_gen_inst ( .D({{NUM},{fifo_DO}}), .NewCRC(CRC));
	assign EMPTY = EMPTY_fifo | (~TRAINING_DONE);		
	reg [3:0] times;
	reg BACK_WRONG, BACK_RIGHT;
	assign probe = RDEN_REG;
	always @ (posedge CLKDIV) begin
		if (RST == 1'b1) begin
			count <= 9'h000;
			RDEN_REG <= 1'b0;
			times <= 4'h0;
		end
		else begin
			if (count == 9'h1FF | count == 9'h1FE) 
			begin
				count <= 9'h000;
			end
			else if (count == 9'h000) begin
				if ( EN_SIG == 1'b1)					
				begin
					count <= 9'h1FF;
				end
				else if (RE_SIG == 1'b1)
				begin
					count <= 9'h1FE;
				end
				else
				begin
					if (EMPTY == 1'b1 & times == 4'h0) begin
						count <= 9'h000;
					end
					else if (EMPTY == 1'b0) begin
						count <= 9'h001;
						RDEN_REG <= 1'b0;
					end
					else if (times == 4'h1 | times ==4'h2) begin
						count <= 9'h001;
						RDEN_REG <= 1'b0;
					end
					else if (times == 4'h3) begin
						times <= 1'b0;
						RDEN_REG <= 1'b0;
					end						
				end
				BACK_WRONG <= 1'b0;
				BACK_RIGHT <= 1'b0;
			end
			else if (count == 9'h001) begin
				if (times == 4'h0) begin
					RDEN_REG <= 1'b1;
				end
				times <= times + 4'h1;
				count <= 9'h002;
				BACK_WRONG <= 1'b0;
				BACK_RIGHT <= 1'b0;
			end
			else if (count == 9'h002) begin
				RDEN_REG <= 1'b0;
				count <= 9'h003;
			end
			else if ( CON_P == 1'b1) begin	
					count <= 9'h000;
				times <= 4'h0;
				BACK_RIGHT <= 1'b1;
			end
			else if (times == 4'h3 & count == 9'h150) begin
				count <= 9'h000;
				times <= 4'h0;
				BACK_WRONG <= 1'b1;
			end
			else if ( CON_N == 1'b1 | count == 9'h150) begin
				count <= 9'h000;
			end			
			else begin
				count <= count + 9'h001;
			end
		end			
	end
	reg [8:0] data_counter;
	always @ (negedge CLKDIV) begin
		if ( RST == 1'b1 ) begin
			input_reg[7:0] <= 8'h00;
			data_counter <= 8'h00;
		end
		else if (count == 9'h001) begin
			input_reg[7:0] <= 8'hF5;
		end
		else if (count == 9'h002) begin
			input_reg[7:0] <= NUM;
		end
		else if (count == 9'h000) begin
			input_reg[7:0] <= 8'h44;		
		end
		else if (count == 9'h003) begin
			input_reg[7:0] <= fifo_DO[39:32];
		end
		else if (count == 9'h004) begin
			input_reg[7:0] <= fifo_DO[31:24];
		end
		else if (count == 9'h005) begin
			input_reg[7:0] <= fifo_DO[23:16];
		end
		else if (count == 9'h006) begin
			input_reg[7:0] <= fifo_DO[15:8];
		end
		else if (count == 9'h007) begin
			input_reg[7:0] <= fifo_DO[7:0];
		end
		else if (count == 9'h008) begin
			input_reg[7:0] <= CRC[7:0];
		end
		else if (count == 9'h1FF) begin
			input_reg[7:0] <= 8'h5f;
		end
		else if (count == 9'h1FE) begin
			input_reg[7:0] <= 8'haf;
		end
		else begin
			input_reg[7:0] <= 8'h00;
		end
	end
	wire [7:0] PATTERN;
	RCB_FRL_TrainingPattern RCB_FRL_TrainingPattern_inst(
		.CLK(CLKDIV),
		.RST(RST),
		.DATA_OUT(PATTERN));	
	wire [7:0] input_reg_inv;	
	assign input_reg_inv = TRAINING_DONE ? input_reg : PATTERN;
	RCB_FRL_OSERDES_MSG RCB_FRL_OSERDES_MSG_inst (
			.OQ(OSER_OQ), .CLK(CLK), .CLKDIV(CLKDIV), .DI(input_reg_inv), .OCE(1'b1), .SR(RST));
endmodule
