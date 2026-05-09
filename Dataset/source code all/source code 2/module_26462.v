`timescale 1ns / 1ps
`timescale 1ns / 1ps
module registers_memory
	#(
	parameter B=32, 
				 W=5	 
	)
	(
		input wire clk,	
		input wire reset,
		input wire wr_en,	
		input wire [W-1:0] w_addr, r_addr1, r_addr2,
		input wire [B-1:0] w_data,
		output wire [B-1:0] r_data1, r_data2,
		output wire [B-1:0] reg_0,
		output wire [B-1:0] reg_1,
		output wire [B-1:0] reg_2,
		output wire [B-1:0] reg_3,
		output wire [B-1:0] reg_4,
		output wire [B-1:0] reg_5,
		output wire [B-1:0] reg_6,
		output wire [B-1:0] reg_7,
		output wire [B-1:0] reg_8,
		output wire [B-1:0] reg_9,
		output wire [B-1:0] reg_10,
		output wire [B-1:0] reg_11,
		output wire [B-1:0] reg_12,
		output wire [B-1:0] reg_13,
		output wire [B-1:0] reg_14,
		output wire [B-1:0] reg_15,
		output wire [B-1:0] reg_16,
		output wire [B-1:0] reg_17,
		output wire [B-1:0] reg_18,
		output wire [B-1:0] reg_19,
		output wire [B-1:0] reg_20,
		output wire [B-1:0] reg_21,
		output wire [B-1:0] reg_22,
		output wire [B-1:0] reg_23,
		output wire [B-1:0] reg_24,
		output wire [B-1:0] reg_25,
		output wire [B-1:0] reg_26,
		output wire [B-1:0] reg_27,
		output wire [B-1:0] reg_28,
		output wire [B-1:0] reg_29,
		output wire [B-1:0] reg_30,
		output wire [B-1:0] reg_31
   );
	reg [B-1:0] array_reg [0:31];
	integer i;
	always @(negedge clk,posedge reset)
	begin 		
			if (reset)
				begin
					for (i=0;i<32;i=i+1)
					begin
						array_reg[i] <= 0;
					end
				end
			else if (wr_en)
				array_reg[w_addr] <= w_data;
	end
	assign r_data1 = array_reg[r_addr1];
	assign r_data2 = array_reg[r_addr2];
	assign reg_0 = array_reg[0];
	assign reg_1 = array_reg[1];
	assign reg_2 = array_reg[2];
	assign reg_3 = array_reg[3];
	assign reg_4 = array_reg[4];
	assign reg_5 = array_reg[5];
	assign reg_6 = array_reg[6];
	assign reg_7 = array_reg[7];
	assign reg_8 = array_reg[8];
	assign reg_9 = array_reg[9];
	assign reg_10 = array_reg[10];
	assign reg_11 = array_reg[11];
	assign reg_12 = array_reg[12];
	assign reg_13 = array_reg[13];
	assign reg_14 = array_reg[13];
	assign reg_15 = array_reg[15];
	assign reg_16 = array_reg[16];
	assign reg_17 = array_reg[17];
	assign reg_18 = array_reg[18];
	assign reg_19 = array_reg[19];
	assign reg_20 = array_reg[20];
	assign reg_21 = array_reg[21];
	assign reg_22 = array_reg[22];
	assign reg_23 = array_reg[23];
	assign reg_24 = array_reg[24];
	assign reg_25 = array_reg[25];
	assign reg_26 = array_reg[26];
	assign reg_27 = array_reg[27];
	assign reg_28 = array_reg[28];
	assign reg_29 = array_reg[29];
	assign reg_30 = array_reg[30];
	assign reg_31 = array_reg[31];
endmodule
