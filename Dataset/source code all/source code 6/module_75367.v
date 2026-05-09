`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_TX_MSG (
		input 			clk, 
		input 			clkdiv,  
		input 			rst, 
		input [39:0]	data_in, 
		input				empty,
		output reg		rden,
		output 			OSER_OQ,
		input 			ack_r_one, 
		input 			nack_r_one, 
		output reg		txmsg_miss_one, 	
		output reg		txmsg_pass_one, 	
		input 			msg_r_p_one, 
		input 			msg_r_n_one,
		input 			training_done
	);
	reg [7:0] frame_data;
	wire NotReady;		
	reg	msg_r_p_signal;
	reg	msg_r_n_signal;
	parameter MSG_HEADER	= 8'hF5;
	parameter MSG_SIZE 	= 8'h06;
	parameter ACK_SYM		= 8'h5F;
	parameter NACK_SYM	= 8'hAF;
	parameter DUMMY_WAIT = 8'h44;
	parameter TIME_OUT	= 9'h150;
	parameter RETRY_MAX	= 3'b011;	
	parameter IDLE				= 10'b00_0000_0001;
	parameter HEADER			= 10'b00_0000_0010;
	parameter SIZE				= 10'b00_0000_0100;
	parameter ADDR				= 10'b00_0000_1000;
	parameter DATA_1			= 10'b00_0001_0000;
	parameter DATA_2			= 10'b00_0010_0000;
	parameter DATA_3			= 10'b00_0100_0000;
	parameter DATA_4			= 10'b00_1000_0000;
	parameter CRC				= 10'b01_0000_0000;
	parameter WAIT_FOR_ACK	= 10'b10_0000_0000;	
	reg [9:0] msg_framer_state;
	reg [8:0] cnt;
	wire [7:0] CRC8;
	CRC8_gen RCB_FRL_CRC_gen_inst ( 
		.D({MSG_SIZE,data_in[39:0]}), 
		.NewCRC(CRC8)
	);
	assign NotReady = empty | (~training_done);		
	reg [3:0]	retry_cnt;
	always@(posedge clkdiv) begin
		if (rst) begin
			rden					<= 1'b0;
			retry_cnt			<= 3'b000;
			cnt					<= 9'h000;
			frame_data[7:0]	<= 8'h00;
			msg_framer_state	<= IDLE;
		end else begin
			case(msg_framer_state)
				IDLE: begin
					cnt			<= 9'h000;
					retry_cnt	<= 3'b000;
					if(msg_r_p_signal) begin
						rden					<= 1'b0;
						frame_data[7:0]	<= ACK_SYM;
						msg_framer_state	<= IDLE;
					end else if (msg_r_n_signal) begin
						rden					<= 1'b0;
						frame_data[7:0]	<= NACK_SYM;
						msg_framer_state	<= IDLE;
					end else if (!NotReady) begin
						rden					<= 1'b1;
						frame_data[7:0]	<= 8'h00;
						msg_framer_state	<= HEADER;
					end else begin
						rden					<= 1'b0;
						frame_data[7:0]	<= 8'h00;
						msg_framer_state	<= IDLE;
					end
				end
				HEADER: begin
					rden					<= 1'b0;
					retry_cnt			<= retry_cnt;
					cnt					<= 9'h000;
					frame_data[7:0]	<= MSG_HEADER;
					msg_framer_state	<= SIZE;
				end
				SIZE: begin
					rden					<= 1'b0;
					retry_cnt			<= retry_cnt;
					cnt					<= 9'h000;
					frame_data[7:0]	<= MSG_SIZE;
					msg_framer_state	<= ADDR;
				end
				ADDR: begin
					rden					<= 1'b0;
					retry_cnt			<= retry_cnt;
					cnt					<= 9'h000;
					frame_data[7:0]	<= data_in[39:32];
					msg_framer_state	<= DATA_1;
				end
				DATA_1: begin
					rden					<= 1'b0;
					retry_cnt			<= retry_cnt;
					cnt					<= 9'h000;
					frame_data[7:0]	<= data_in[31:24];
					msg_framer_state	<= DATA_2;
				end
				DATA_2: begin
					rden					<= 1'b0;
					retry_cnt			<= retry_cnt;
					cnt					<= 9'h000;
					frame_data[7:0]	<= data_in[23:16];
					msg_framer_state	<= DATA_3;
				end
				DATA_3: begin
					rden					<= 1'b0;
					retry_cnt			<= retry_cnt;
					cnt					<= 9'h000;
					frame_data[7:0]	<= data_in[15:8];
					msg_framer_state	<= DATA_4;
				end
				DATA_4: begin
					rden					<= 1'b0;
					retry_cnt			<= retry_cnt;
					cnt					<= 9'h000;
					frame_data[7:0]	<= data_in[7:0];
					msg_framer_state	<= CRC;
				end
				CRC: begin
					rden					<= 1'b0;
					retry_cnt			<= retry_cnt;
					cnt					<= 9'h000;
					frame_data[7:0]	<= CRC8;
					msg_framer_state	<= WAIT_FOR_ACK;
				end
				WAIT_FOR_ACK: begin					
					rden					<= 1'b0;
					cnt					<= cnt + 9'h001;
					if (cnt > 9'h001) begin		
						if (msg_r_p_signal)
							frame_data[7:0]	<= ACK_SYM;
						else if (msg_r_n_signal)
							frame_data[7:0]	<= NACK_SYM;
						else
							frame_data[7:0]	<= DUMMY_WAIT;
					end else
							frame_data[7:0]	<= DUMMY_WAIT;
					if (ack_r_one) begin
						retry_cnt			<= 3'b000;
						msg_framer_state	<= IDLE;
					end else if ( nack_r_one | (cnt > TIME_OUT) ) begin
						if (retry_cnt >= RETRY_MAX) begin
							retry_cnt			<= 3'b000;
							msg_framer_state	<= IDLE;
						end else begin
							retry_cnt			<= retry_cnt + 3'b001;
							msg_framer_state	<= HEADER;
						end
					end else begin
						retry_cnt			<= retry_cnt;
						msg_framer_state	<= WAIT_FOR_ACK;						
					end
				end
				default: begin
					rden					<= 1'b0;
					retry_cnt			<= 3'b000;
					cnt					<= 9'h000;
					frame_data[7:0]	<= 8'h00;
					msg_framer_state	<= IDLE;
				end
			endcase
		end
	end
	always@(posedge clkdiv) begin
		if (rst) 
			msg_r_p_signal		<= 1'b0;
		else if (msg_r_p_one)
			msg_r_p_signal		<= 1'b1;
		else if ( (msg_framer_state == IDLE) | ((msg_framer_state == WAIT_FOR_ACK)&(cnt > 9'h001)) )
			msg_r_p_signal		<= 1'b0;
		else
			msg_r_p_signal		<= msg_r_p_signal;
	end
	always@(posedge clkdiv) begin
		if (rst) 
			msg_r_n_signal		<= 1'b0;
		else if (msg_r_n_one)
			msg_r_n_signal		<= 1'b1;
		else if ( (msg_framer_state == IDLE) | ((msg_framer_state == WAIT_FOR_ACK)&(cnt > 9'h001)) )
			msg_r_n_signal		<= 1'b0;
		else
			msg_r_n_signal		<= msg_r_n_signal;
	end
	always@(posedge clkdiv) begin
		if(rst)
			txmsg_miss_one	<= 1'b0;
		else if ( (retry_cnt >= RETRY_MAX) & (cnt > TIME_OUT | nack_r_one) )
			txmsg_miss_one	<= 1'b1;
		else
			txmsg_miss_one	<= 1'b0;
	end
	always@(posedge clkdiv) begin
		if(rst)
			txmsg_pass_one	<= 1'b0;
		else if ( (msg_framer_state == WAIT_FOR_ACK) & (ack_r_one) )
			txmsg_pass_one	<= 1'b1;
		else
			txmsg_pass_one	<= 1'b0;
	end
	wire [7:0] data_to_oserdes;	
	assign data_to_oserdes = training_done ? frame_data : 8'h5c;		
	RCB_FRL_OSERDES_MSG RCB_FRL_OSERDES_MSG_inst (
		.OQ(OSER_OQ), 
		.clk(clk), 
		.clkdiv(clkdiv), 
		.DI(data_to_oserdes), 
		.OCE(1'b1), 
		.SR(rst)
	);
endmodule
