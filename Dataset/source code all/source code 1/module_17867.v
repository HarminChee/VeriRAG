module ID_EX(input clk,
             input reset,
             input [1:0] WB_in, 
             input [1:0] M_in, 
             input [3:0] EX_in, 
             input [31:0] RDdata1_in, 
             input [31:0] RDdata2_in, 
             input [31:0] sign_extended_in, 
             input [4:0] Inst_25_to_21_in,
             input [4:0] Inst_20_to_16_in, 
             input [4:0] Inst_15_to_11_in, 
             input [5:0] Inst_5_to_0_in,
			 input [31:0] pc_plus4_in,
			 input hold_i,
             output reg[1:0] WB_out, 
             output reg[1:0] M_out, 
             output reg ALUSrc_out,
			 output reg [1:0] ALUOp_out,
			 output reg RegDst_out,
             output reg[31:0] RDdata1_out, 
             output reg[31:0] RDdata2_out, 
             output reg[31:0] sign_extended_out, 
             output reg[4:0] Inst_25_to_21_out, 
             output reg[4:0] Inst_20_to_16_out, 
             output reg[4:0] Inst_15_to_11_out, 
             output reg[5:0] Inst_5_to_0_out);
	always@(posedge reset)begin
		WB_out = 0;
		M_out = 0;
		ALUSrc_out = 0;
		ALUOp_out = 0;
		RegDst_out = 0;
		RDdata1_out = 0;
		RDdata2_out = 0;
		sign_extended_out = 0;
		Inst_15_to_11_out = 0; 
        Inst_20_to_16_out = 0; 
        Inst_25_to_21_out = 0; 
        Inst_5_to_0_out = 0;
    end
	always@(posedge clk)begin
		if(hold_i) begin
			WB_out <= WB_out;
			M_out <= M_out;
			ALUSrc_out <= ALUSrc_out;
			ALUOp_out <= ALUOp_out;
			RegDst_out <=  RegDst_out;
			RDdata1_out <= RDdata1_out;
			RDdata2_out <= RDdata2_out;
			sign_extended_out <= sign_extended_out;
			Inst_15_to_11_out <= Inst_15_to_11_out; 
			Inst_20_to_16_out <= Inst_20_to_16_out; 
			Inst_25_to_21_out <= Inst_25_to_21_out;
			Inst_5_to_0_out <= Inst_5_to_0_out;
		end
		else begin
			WB_out <= WB_in;
			M_out <= M_in;
			ALUSrc_out <= EX_in[0];
			ALUOp_out <= EX_in[2:1];
			RegDst_out <=  EX_in[3];
			RDdata1_out <= RDdata1_in;
			RDdata2_out <= RDdata2_in;
			sign_extended_out <= sign_extended_in;
			Inst_15_to_11_out <= Inst_15_to_11_in; 
			Inst_20_to_16_out <= Inst_20_to_16_in; 
			Inst_25_to_21_out <= Inst_25_to_21_in; 
			Inst_5_to_0_out <= Inst_5_to_0_in;
		end
	end
endmodule
