module ControlUnit (output reg IR_CU, RFLOAD, PCLOAD, SRLOAD, SRENABLED, ALUSTORE, MFA, WORD_BYTE,READ_WRITE,IRLOAD,MBRLOAD,MBRSTORE,MARLOAD,output reg[4:0] opcode, output reg[3:0] CU,  input MFC, Reset,Clk, input [31:0] IR,input [3:0] SR);
reg [4:0] State, NextState;
always @ (negedge Clk, posedge Reset)
	if (Reset) begin 
		State <= 5'b00001;ALUSTORE = 0 ; IR_CU= 0 ; RFLOAD= 0 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 0 ; WORD_BYTE= 0 ;READ_WRITE= 0 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 0 ;CU=0; opcode=5'b10010;end
	else 
		State <= NextState;
always @ (State, MFC)
	case (State)
		5'b00000 : NextState = 5'b00000; 
		5'b00001 : if(MFC) NextState = 5'b10001 ; else NextState = 5'b00010;
		5'b00010 : NextState = 5'b00011; 
		5'b00011 : if(MFC)NextState = 5'b00100; else  NextState = 5'b00011;
		5'b00100 : NextState = 5'b00101;
		5'b00101 : case(IR[31:28])
						4'b0000: if(SR[2]==1) NextState = 5'b00110; else NextState = 5'b00001;
						4'b0001: if(SR[2]==0) NextState = 5'b00110; else NextState = 5'b00001;
						4'b0010: if(SR[1]==1) NextState = 5'b00110; else NextState = 5'b00001;
						4'b0011: if(SR[1]==0) NextState = 5'b00110; else NextState = 5'b00001;
						4'b0100: if(SR[3]==1) NextState = 5'b00110; else NextState = 5'b00001;
						4'b0101: if(SR[3]==0) NextState = 5'b00110; else NextState = 5'b00001;
						4'b0110: if(SR[0]==1) NextState = 5'b00110; else NextState = 5'b00001;
						4'b0111: if(SR[0]==0) NextState = 5'b00110; else NextState = 5'b00001;
						4'b1000: if(SR[1]==1&SR[2]==0) NextState = 5'b00110; else NextState = 5'b00001;
						4'b1001: if(SR[1]==0|SR[2]==1) NextState = 5'b00110; else NextState = 5'b00001;
						4'b1010: if(SR[3]==SR[0]) NextState = 5'b00110; else NextState = 5'b00001;
						4'b1011: if(SR[3]!=SR[0]) NextState = 5'b00110; else NextState = 5'b00001;
						4'b1100: if(SR[2]==0&SR[3]==SR[0]) NextState = 5'b00110; else NextState = 5'b00001;
						4'b1101: if(SR[2]==1|SR[3]!=SR[0]) NextState = 5'b00110; else NextState = 5'b00001;
						4'b1110: NextState = 5'b00110; 
					endcase
		5'b00110 : case(IR[27:25])
						3'b000,3'b001:NextState = 5'b00111;
						3'b010,3'b011:NextState = 5'b01000;
						3'b101:NextState = 5'b0001;
						default:NextState = 5'b0001;
				   endcase
		5'b00111 : NextState = 5'b00001; 
		5'b01000 : if(IR[24] == 0 & IR[0] ==0 ) NextState = 5'b01001; else if(IR[20]) NextState = 5'b01010;else NextState = 5'b01011; 
		5'b01001 : if(IR[20]) NextState = 5'b01010;else NextState = 5'b01011; 
		5'b01010 : if(MFC) NextState = 5'b01100; else NextState = 5'b01010; 
		5'b01011 : NextState = 5'b01101; 
		5'b01100 : NextState = 5'b00001; 
		5'b01101 : if(MFC) NextState = 5'b00001 ; else NextState = 5'b01101; 
		5'b01110 : NextState = 5'b01111;
		5'b01111 : NextState = 5'b10000;
		5'b10000 : NextState = 5'b00001;
		5'b10001 : if(MFC) NextState = 5'b10001 ; else NextState = 5'b00010; 
	endcase 
always @ (State, MFC)
	case (State)
		5'b00000 : begin  end
		5'b00001 : begin  ALUSTORE = 1 ;IR_CU= 0 ; RFLOAD= 0 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 0 ; WORD_BYTE= 0 ;READ_WRITE= 0 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 1 ; CU=4'hf;opcode=5'b10010;end 
		5'b00010 : begin  ALUSTORE = 1 ;IR_CU= 0 ; RFLOAD= 0 ; PCLOAD= 1 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 1 ; WORD_BYTE= 1 ;READ_WRITE= 1 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 0 ; CU=4'hf;opcode=5'b10001;end 
		5'b00011 : begin  ALUSTORE = 0 ;IR_CU= 0 ; RFLOAD= 0 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 1 ; WORD_BYTE= 1 ;READ_WRITE= 1 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 0 ; CU=4'hf;opcode=5'b10010;end 
		5'b00100 : begin  ALUSTORE = 0 ;IR_CU= 0 ; RFLOAD= 0 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 0 ; WORD_BYTE= 0 ;READ_WRITE= 0 ;IRLOAD= 1 ;MBRLOAD= 0 ;MBRSTORE= 1 ;MARLOAD = 0 ; CU=4'hf;opcode=5'b10010;end 
		5'b00101 : begin  ALUSTORE = 1 ;IR_CU=1 ; RFLOAD= 0 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 0 ; WORD_BYTE= 0 ;READ_WRITE= 0 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 0 ; CU=4'h0;end 
		5'b00110 : begin  ALUSTORE = 0 ;IR_CU= 1 ; RFLOAD= 0 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 0 ; WORD_BYTE= 0 ;READ_WRITE= 0 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 0 ;end 
		5'b00111 : begin  ALUSTORE = 1 ;IR_CU= 1 ; RFLOAD= 1 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 0 ; WORD_BYTE= 0 ;READ_WRITE= 0 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 0 ;opcode = {1'b0,IR[24:21]};end 
		5'b01000 : begin  ALUSTORE = 1 ;IR_CU= 1 ; RFLOAD= IR[21]==1&IR[24]==1 ? 1 : 0; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 0 ; WORD_BYTE= 0 ;READ_WRITE= 0 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 1 ;opcode = IR[24] == 0 & IR[0] ==0 ? 5'b10010 : !IR[23] ? 5'b00100:5'b00010 ; end 
		5'b01001 : begin  ALUSTORE = 1 ;IR_CU= 1 ; RFLOAD=1; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 0 ; WORD_BYTE= 0 ;READ_WRITE= 0 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 0 ;opcode =  !IR[23] ? 5'b00100:5'b00010 ; end 
		5'b01010 : begin  ALUSTORE = 0 ;IR_CU= 0 ; RFLOAD= 0 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 1 ; WORD_BYTE= 1 ;READ_WRITE= 1 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 0 ;end 
		5'b01011 : begin  ALUSTORE = 1 ;IR_CU= 1 ; RFLOAD= 0 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 0 ; WORD_BYTE= 0 ;READ_WRITE= 0 ;IRLOAD= 0 ;MBRLOAD= 1 ;MBRSTORE= 0 ;MARLOAD = 0 ; opcode=5'b10010; end 
		5'b01100 : begin  ALUSTORE = 0 ;IR_CU= 1 ; RFLOAD= 1 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 0 ; WORD_BYTE= 0 ;READ_WRITE= 0 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 1 ;MARLOAD = 0 ;end 
		5'b01101 : begin  ALUSTORE = 0 ;IR_CU= 0 ; RFLOAD= 0 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 1 ; WORD_BYTE= 1 ;READ_WRITE= 0 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 0 ;end 
		5'b01110 : begin  end 
		5'b01111 : begin  end 
		5'b10000 : begin  end 
		5'b10001 : begin  ALUSTORE = 0 ;IR_CU= 0 ; RFLOAD= 0 ; PCLOAD= 0 ; SRLOAD= 0 ; SRENABLED= 0 ; MFA= 0 ; WORD_BYTE= 0 ;READ_WRITE= 0 ;IRLOAD= 0 ;MBRLOAD= 0 ;MBRSTORE= 0 ;MARLOAD = 0 ; CU=4'hf;opcode=5'b10001;end  
		default : begin end
	endcase
endmodule
