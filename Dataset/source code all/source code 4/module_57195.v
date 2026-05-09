module alu(
	input clk,
	input [7:0] A,
	input [7:0] B,
	input [3:0] operation,
	output reg [7:0] result,
	output reg CF,
	output reg ZF,
	output reg SF
);
	localparam ALU_OP_ADD  = 4'b0000;
	localparam ALU_OP_SUB  = 4'b0001;
	localparam ALU_OP_ADC  = 4'b0010;
	localparam ALU_OP_SBC  = 4'b0011;
	localparam ALU_OP_AND  = 4'b0100;
	localparam ALU_OP_OR   = 4'b0101;
	localparam ALU_OP_NOT  = 4'b0110;
	localparam ALU_OP_XOR  = 4'b0111;
	localparam ALU_OP_SHL  = 4'b1000;
	localparam ALU_OP_SHR  = 4'b1001;
	localparam ALU_OP_SAL  = 4'b1010;
	localparam ALU_OP_SAR  = 4'b1011;
	localparam ALU_OP_ROL  = 4'b1100;
	localparam ALU_OP_ROR  = 4'b1101;
	localparam ALU_OP_RCL  = 4'b1110;
	localparam ALU_OP_RCR  = 4'b1111;
	reg [8:0] tmp;
	always @(posedge clk)
	begin
		case (operation)
			ALU_OP_ADD :
				tmp = A + B;
			ALU_OP_SUB :
				tmp = A - B;
			ALU_OP_ADC :
				tmp = A + B + { 7'b0000000, CF };
			ALU_OP_SBC :
				tmp = A - B - { 7'b0000000, CF };
			ALU_OP_AND :
				tmp = {1'b0, A & B };
			ALU_OP_OR :
				tmp = {1'b0, A | B };
			ALU_OP_NOT :
				tmp = {1'b0, ~B };
			ALU_OP_XOR :
				tmp = {1'b0, A ^ B};
			ALU_OP_SHL :
				tmp = { A[7], A[6:0], 1'b0};
			ALU_OP_SHR :
				tmp = { A[0], 1'b0, A[7:1]};
			ALU_OP_SAL :
				tmp = { A[7], A[6:0], 1'b0};
			ALU_OP_SAR :
				tmp = { A[0], A[7], A[7:1]};
			ALU_OP_ROL :
				tmp = { A[7], A[6:0], A[7]};
			ALU_OP_ROR :
				tmp = { A[0], A[0], A[7:1]};
			ALU_OP_RCL :
				tmp = { A[7], A[6:0], CF};
			ALU_OP_RCR :
				tmp = { A[0], CF, A[7:1]};
		endcase
		CF <= tmp[8];
		ZF <= tmp[7:0] == 0;
		SF <= tmp[7];
		result <= tmp[7:0];
	end
endmodule
