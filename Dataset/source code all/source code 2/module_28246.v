`define ADD 0
`define SUB 1
`define AND 2
`define OR 3
`define SLL 4
`define SRL 5
`define SRA 6
`define RL 7
`define ADD 0
`define SUB 1
`define AND 2
`define OR 3
`define SLL 4
`define SRL 5
`define SRA 6
`define RL 7
module alu(
   a,   
   b,   
   op,   
   imm,   
   nop,
   flag_prev_to_send, 
   out   
   );
   parameter DSIZE = 16;
   input [DSIZE-1:0] a, b;
   input [2:0] op;
   input [3:0] imm;
   input nop;
   output reg[DSIZE-1:0] out;
   output [2:0] flag_prev_to_send;
   wire [DSIZE-1:0] b_N;
   assign b_N = ~b + 1'b1;
   reg [2:0] flag_temp;
   reg [2:0] flag_curr;
   reg [2:0] flag_prev;
always @(a or b or op or imm or nop)
  begin
  if(nop > 1'b0)
  begin
  end 
  else
  begin 
	 flag_temp = flag_curr;
	 flag_curr[1] = 1'b0;
   case(op)
      `ADD: 
        begin
          out = a + b;
          flag_curr[1] = ((a[15] == b[15])&&(b[15] != out[15]))? 1'b1 : 1'b0;
          if (flag_curr[1] == 0) 
            flag_curr[0] = (out[15] == 1)? 1'b1 : 1'b0;
          flag_curr[2] = (out == 16'h0000)? 1'b1 : 1'b0;  
        end
      `SUB: 
        begin
          if (b_N == 16'b1000000000000000)
				    flag_curr[1] = 1'b1;
			    else
				    begin
				      out = a + b_N;
				      flag_curr[1] = ((a[15] == b_N[15])&&(b_N[15] != out[15]))? 1'b1 : 1'b0;
				      if (flag_curr[1] == 0)
					      flag_curr[0] = (out[15] == 1)? 1'b1 : 1'b0;
					  end
					flag_curr[2] = (out == 16'h0000)? 1'b1 : 1'b0;      
			  end
			`AND:             
          out = a & b;
      `OR:           
          out = a | b;
      `SLL: out = a << imm;
      `SRL: out = a >> imm;
      `SRA: out = $signed(a) >>> imm;
      `RL: out = a << imm | a >> (16-imm);
      default: out = 0;
  endcase
  flag_curr[2] = (out == 16'h0000)? 1'b1 : 1'b0;
  flag_prev = flag_temp;
  end 
end
assign flag_prev_to_send = flag_prev;
endmodule
