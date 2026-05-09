module control_pipeline(opcode, RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUOp, Jumper);
    input [5:0] opcode;
    output RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jumper;
    output [1:0] ALUOp;
    reg    RegDst, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Jumper;
    reg    [1:0] ALUOp;
    parameter R_FORMAT = 6'd0;
    parameter LW = 6'd35;
    parameter SW = 6'd43;
    parameter BEQ = 6'd4;
    parameter J = 6'd2; 
    always @(opcode)
    begin
        case (opcode)
          R_FORMAT : 
          begin
              RegDst=1'b1; ALUSrc=1'b0; MemtoReg=1'b0; RegWrite=1'b1; MemRead=1'b0; 
              MemWrite=1'b0; Branch=1'b0; ALUOp = 2'b10; Jumper = 1'b0;
          end
          LW :
          begin
              RegDst=1'b0; ALUSrc=1'b1; MemtoReg=1'b1; RegWrite=1'b1; MemRead=1'b1; 
              MemWrite=1'b0; Branch=1'b0; ALUOp = 2'b00; Jumper = 1'b0;
          end
          SW :
          begin
              RegDst=1'bx; ALUSrc=1'b1; MemtoReg=1'bx; RegWrite=1'b0; MemRead=1'b0; 
              MemWrite=1'b1; Branch=1'b0; ALUOp = 2'b00; Jumper = 1'b0;
          end
          BEQ :
          begin
              RegDst=1'bx; ALUSrc=1'b0; MemtoReg=1'bx; RegWrite=1'b0; MemRead=1'b0; 
              MemWrite=1'b0; Branch=1'b1; ALUOp = 2'b01; Jumper = 1'b0;
          end
          J : 
          begin 
              RegDst=1'bx; ALUSrc=1'bX; MemtoReg=1'bx; RegWrite=1'b0; MemRead=1'b0; 
              MemWrite=1'b0; Branch=1'b0; ALUOp = 2'b01; Jumper = 1'b1; 
          end 
          default
          begin
              $display("control_single unimplemented opcode %d", opcode);
              RegDst=1'b0; ALUSrc=1'b0; MemtoReg=1'b0; RegWrite=1'b0; MemRead=1'b0; 
              MemWrite=1'b0; Branch=1'b0; ALUOp = 2'b00; Jumper = 1'b0;
          end
        endcase
    end
endmodule
