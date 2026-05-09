module pc_forwarding(clk,equ,pr2_IR,pr3_IR,pr4_IR,pr5_IR,pc_mux_select);
parameter ADD = 6'b000000;
parameter NDU = 6'b001000;
parameter ADC = 6'b000010;
parameter ADZ = 6'b000001;
parameter ADI = 4'b0001;
parameter NDC = 6'b001010;
parameter NDZ = 6'b001001;
parameter LHI = 4'b0011;
parameter LW  = 4'b0100;
parameter SW  = 4'b0101;
parameter LM  = 4'b0110;
parameter SM  = 4'b0111;
parameter BEQ = 4'b1100;
parameter JAL = 4'b1000;
parameter JLR = 4'b1001;
parameter rb=3'd1;
parameter c=3'd2;
parameter m= 3'd3;
parameter one = 3'd4;
parameter h = 3'd5;
parameter a = 3'd6;
output reg [2:0] pc_mux_select;
input [15:0] pr2_IR,pr3_IR,pr4_IR,pr5_IR;
input equ,clk;
wire [5:0] op2,op3,op4,op5;
wire[2:0] pr2RA,pr2RB,pr4RC,pr5RA;
assign op2={pr2_IR[15:12],pr2_IR[1:0]};
assign op3={pr3_IR[15:12],pr3_IR[1:0]};
assign op4={pr4_IR[15:12],pr4_IR[1:0]};
assign op5={pr5_IR[15:12],pr5_IR[1:0]};
assign pr2RA = pr2_IR[11:9];
assign pr2RB = pr2_IR[8:6];
assign pr4RC = pr2_IR[5:3];
assign pr5RA = pr5_IR[11:9];
always @(negedge clk)
begin
if((op5[5:2]==LW||op5[5:2]==LM)&&pr5RA==3'b111)
pc_mux_select=c;
else if(op2[5:2]==LHI&&pr2RA==3'b111)
pc_mux_select=h;
else if((op4==ADD||op4==NDU||op4==ADC||op4==ADZ||op4==NDC||op4==NDC||op4==NDZ)&&(pr4RC==3'b111))
	pc_mux_select=a;
else if(op4[5:2]==ADI&&pr2RB==3'b111)
	pc_mux_select=a;
else if(equ==1&&op3[5:2]==BEQ)
	pc_mux_select=one;
else if(op3[5:2]==JLR)
	pc_mux_select=rb;
else if(op2[5:2]==JAL)
	pc_mux_select=m;
else
	pc_mux_select=0;
end
endmodule
module fetch(IR_load_mux,new_IR_multi,equ,pr2_IR ,pr3_IR ,pr4_IR, pr5_IR,fromPipe2_PCim, fromPipe2_970, fromPipe3RFOut, fromPipe3PCInc, fromPipe4_Aluout, fromPipe5Mem, PCWrite, PCOut, IROut, incPCOut, clk, reset);
	output [15:0] PCOut, IROut, incPCOut;
	input [15:0]new_IR_multi;
	wire [15:0] next_IR;
	input IR_load_mux;
	input  [15:0] fromPipe2_PCim, fromPipe2_970, fromPipe3RFOut, fromPipe3PCInc, fromPipe4_Aluout, fromPipe5Mem;
	input [15:0] pr2_IR ,pr3_IR ,pr4_IR, pr5_IR;
	wire  [ 2:0] fromForwarding;
	input         PCWrite, clk, reset;
	input equ;
	wire   [15:0] PCWriteWire;
	pc_forwarding f_u(.clk(clk),.equ(equ),.pr2_IR(pr2_IR),.pr3_IR(pr3_IR),.pr4_IR(pr4_IR),.pr5_IR(pr5_IR),.pc_mux_select(fromForwarding))	;
	mux16x8 PCWriteSelect(.data0(incPCOut), .data1(fromPipe3RFOut), .data2(fromPipe5Mem), .data3(fromPipe2_PCim), .data4(fromPipe3PCInc), .data5(fromPipe2_970), .data6(fromPipe4_Aluout), .data7(16'b0), .selectInput(fromForwarding), .out(PCWriteWire));
	register16 PCReg(.clk(clk), .out(PCOut), .in(PCWriteWire), .write(PCWrite), .reset(reset));
	plus_one PlusOne(.in(PCOut), .out(incPCOut));
	instr_mem InstructionMemory(.readAdd(PCOut), .out(next_IR));
	mux16x2 IR_write_select(.data0(next_IR), .data1(new_IR_multi), .selectInput(IR_load_mux), .out(IROut));
endmodule
module pc_forwarding(clk,equ,pr2_IR,pr3_IR,pr4_IR,pr5_IR,pc_mux_select);
parameter ADD = 6'b000000;
parameter NDU = 6'b001000;
parameter ADC = 6'b000010;
parameter ADZ = 6'b000001;
parameter ADI = 4'b0001;
parameter NDC = 6'b001010;
parameter NDZ = 6'b001001;
parameter LHI = 4'b0011;
parameter LW  = 4'b0100;
parameter SW  = 4'b0101;
parameter LM  = 4'b0110;
parameter SM  = 4'b0111;
parameter BEQ = 4'b1100;
parameter JAL = 4'b1000;
parameter JLR = 4'b1001;
parameter rb=3'd1;
parameter c=3'd2;
parameter m= 3'd3;
parameter one = 3'd4;
parameter h = 3'd5;
parameter a = 3'd6;
output reg [2:0] pc_mux_select;
input [15:0] pr2_IR,pr3_IR,pr4_IR,pr5_IR;
input equ,clk;
wire [5:0] op2,op3,op4,op5;
wire[2:0] pr2RA,pr2RB,pr4RC,pr5RA;
assign op2={pr2_IR[15:12],pr2_IR[1:0]};
assign op3={pr3_IR[15:12],pr3_IR[1:0]};
assign op4={pr4_IR[15:12],pr4_IR[1:0]};
assign op5={pr5_IR[15:12],pr5_IR[1:0]};
assign pr2RA = pr2_IR[11:9];
assign pr2RB = pr2_IR[8:6];
assign pr4RC = pr2_IR[5:3];
assign pr5RA = pr5_IR[11:9];
always @(negedge clk)
begin
if((op5[5:2]==LW||op5[5:2]==LM)&&pr5RA==3'b111)
pc_mux_select=c;
else if(op2[5:2]==LHI&&pr2RA==3'b111)
pc_mux_select=h;
else if((op4==ADD||op4==NDU||op4==ADC||op4==ADZ||op4==NDC||op4==NDC||op4==NDZ)&&(pr4RC==3'b111))
	pc_mux_select=a;
else if(op4[5:2]==ADI&&pr2RB==3'b111)
	pc_mux_select=a;
else if(equ==1&&op3[5:2]==BEQ)
	pc_mux_select=one;
else if(op3[5:2]==JLR)
	pc_mux_select=rb;
else if(op2[5:2]==JAL)
	pc_mux_select=m;
else
	pc_mux_select=0;
end
endmodule
