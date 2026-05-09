`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_RX_MSG(
		input		CLKDIV,
		input		RST,
		input [7:0]	DATA_IN,
		output reg [39:0]	DATA_OUT,
		output reg	ack_r_one, 
		output reg	nack_r_one,		
		output reg	msg_r_p_one, 
		output reg	msg_r_n_one
	);
	reg [7:0]	data_reg;
	always@(posedge CLKDIV)	data_reg[7:0]	<= DATA_IN[7:0];
	parameter MSG_HEADER	= 8'hF5;
	parameter MSG_SIZE 	= 8'h06;
	parameter ACK_SYM		= 8'h5F;
	parameter NACK_SYM	= 8'hAF;
	parameter DUMMY_WAIT = 8'h44;
	reg [39:0]	DATA_rem;
	reg [7:0]	CRC_rem;
	reg [8:0] msg_parser_state;
	localparam IDLE		= 9'b0_0000_0001;
	localparam SIZE		= 9'b0_0000_0010;
	localparam ADDR		= 9'b0_0000_0100;
	localparam DATA_1		= 9'b0_0000_1000;
	localparam DATA_2		= 9'b0_0001_0000;
	localparam DATA_3		= 9'b0_0010_0000;
	localparam DATA_4		= 9'b0_0100_0000;
	localparam CRC			= 9'b0_1000_0000;
	localparam OUTPUT		= 9'b1_0000_0000;
	wire [7:0]	crc_calc;
	CRC8_gen RCB_FRL_CRC_gen_inst( 
		.D({MSG_SIZE,DATA_rem[39:0]}), 
		.NewCRC(crc_calc)
	);
	always@(posedge CLKDIV) DATA_OUT[39:0]	<= DATA_rem[39:0];
	always@(posedge CLKDIV) begin
		if(RST) begin
			ack_r_one	<= 1'b0;
			nack_r_one	<= 1'b0;
		end else if (msg_parser_state==IDLE) begin
			if(data_reg[7:0] == ACK_SYM) begin
				ack_r_one	<= 1'b1;
				nack_r_one	<= 1'b0;
			end else if (data_reg[7:0] == NACK_SYM) begin
				ack_r_one	<= 1'b0;
				nack_r_one	<= 1'b1;
			end else begin
				ack_r_one	<= 1'b0;
				nack_r_one	<= 1'b0;
			end
		end else begin
			ack_r_one	<= 1'b0;
			nack_r_one	<= 1'b0;
		end
	end
	always@(posedge CLKDIV) begin
		if(RST) begin
			msg_r_p_one	<= 1'b0;
			msg_r_n_one	<= 1'b0;
		end else if (msg_parser_state==OUTPUT) begin
			if(CRC_rem[7:0]==crc_calc[7:0]) begin
				msg_r_p_one	<= 1'b1;
				msg_r_n_one	<= 1'b0;
			end else begin
				msg_r_p_one	<= 1'b0;
				msg_r_n_one	<= 1'b1;
			end
		end else begin
			msg_r_p_one	<= 1'b0;
			msg_r_n_one	<= 1'b0;
		end
	end
	always@(posedge CLKDIV) begin
		if (RST) begin
			DATA_rem[39:0]	<= 40'h0_0000;
			CRC_rem[7:0]	<= 8'h00;
			msg_parser_state	<= IDLE;
		end else begin
			case (msg_parser_state)
				IDLE: begin
					DATA_rem[39:0]	<= DATA_rem[39:0];
					CRC_rem[7:0]	<= CRC_rem[7:0];
					if (data_reg[7:0] == MSG_HEADER)
						msg_parser_state	<= SIZE;		
					else
						msg_parser_state	<= IDLE;
				end
				SIZE: begin		
					DATA_rem[39:0]	<= DATA_rem[39:0];
					CRC_rem[7:0]	<= CRC_rem[7:0];
					if (data_reg[7:0] == MSG_SIZE)
						msg_parser_state	<= ADDR;
					else if (data_reg[7:0] == MSG_HEADER)
						msg_parser_state	<= SIZE;
					else
						msg_parser_state	<= IDLE;
				end
				ADDR: begin
					DATA_rem[39:32]	<= data_reg[7:0];		
					DATA_rem[31:0]		<= DATA_rem[31:0];
					CRC_rem[7:0]		<= CRC_rem[7:0];
					msg_parser_state	<= DATA_1;
				end
				DATA_1: begin
					DATA_rem[39:32]	<= DATA_rem[39:32];
					DATA_rem[31:24]	<= data_reg[7:0];		
					DATA_rem[23:0]		<= DATA_rem[23:0];
					CRC_rem[7:0]		<= CRC_rem[7:0];
					msg_parser_state	<= DATA_2;
				end
				DATA_2: begin
					DATA_rem[39:24]	<= DATA_rem[39:24];
					DATA_rem[23:16]	<= data_reg[7:0];		
					DATA_rem[15:0]		<= DATA_rem[15:0];
					CRC_rem[7:0]		<= CRC_rem[7:0];
					msg_parser_state	<= DATA_3;
				end
				DATA_3: begin
					DATA_rem[39:16]	<= DATA_rem[39:16];
					DATA_rem[15:8]		<= data_reg[7:0];		
					DATA_rem[7:0]		<= DATA_rem[7:0];
					CRC_rem[7:0]		<= CRC_rem[7:0];
					msg_parser_state	<= DATA_4;
				end
				DATA_4: begin
					DATA_rem[39:8]		<= DATA_rem[39:8];
					DATA_rem[7:0]		<= data_reg[7:0];			
					CRC_rem[7:0]		<= CRC_rem[7:0];
					msg_parser_state	<= CRC;
				end
				CRC: begin								
					DATA_rem[39:0]		<= DATA_rem[39:0];
					CRC_rem[7:0]		<= data_reg[7:0];	
					msg_parser_state	<= OUTPUT;
				end
				OUTPUT: begin		
					DATA_rem[39:0]		<= DATA_rem[39:0];
					CRC_rem[7:0]		<= CRC_rem[7:0];
					msg_parser_state	<= IDLE;					
				end
				default: begin
					DATA_rem[39:0]		<= DATA_rem[39:0];
					CRC_rem[7:0]		<= CRC_rem[7:0];
					msg_parser_state	<= IDLE;
				end
			endcase
		end
	end
endmodule
