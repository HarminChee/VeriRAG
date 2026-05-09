`define ADD  4'b0111 
`define ADDU 4'b0001 
`define SUB  4'b0010 
`define SUBU 4'b0011 
`define AND  4'b0100 
`define OR   4'b0101 
`define XOR  4'b0110 
`define SLT  4'b1010 
`define SLTU 4'b1011 
`define NOP  4'b0000 
`define SLL 4'b1000 
`define SRL 4'b1100 
`define SRA 4'b1110 
`define BNE 4'b1001  
`define ADD  4'b0111 
`define ADDU 4'b0001 
`define SUB  4'b0010 
`define SUBU 4'b0011 
`define AND  4'b0100 
`define OR   4'b0101 
`define XOR  4'b0110 
`define SLT  4'b1010 
`define SLTU 4'b1011 
`define NOP  4'b0000 
`define SLL 4'b1000 
`define SRL 4'b1100 
`define SRA 4'b1110 
`define BNE 4'b1001  
module ALU_behav( ADin, BDin, ALU_ctr, Result, Overflow, Carry_in, Carry_out, Zero ); 
   parameter n = 32, Ctr_size = 4;
   input     Carry_in;
   input [Ctr_size-1:0] ALU_ctr;
   input [n-1:0] 	ADin, BDin;
   output [n-1:0] 	Result;
   reg [n-1:0] 		Result, tmp;
   output 		Carry_out, Overflow, Zero;
   reg 			Carry_out, Overflow, Zero;
   always @(ALU_ctr or ADin or BDin or Carry_in)
     begin
	 case(ALU_ctr)
	   `ADD:  begin
	      {Carry_out, Result} = ADin + BDin + Carry_in;
	      Overflow = ADin[n-1] & BDin[n-1] & ~Result[n-1]
			 | ~ADin[n-1] & ~BDin[n-1] & Result[n-1];
	   end
	   `ADDU: {Overflow, Result} = ADin + BDin + Carry_in;
	   `SUB:  begin
	      {Carry_out, Result} = ADin - BDin;
	      Overflow = ADin[n-1] & ~BDin[n-1] & Result[n-1]
			 | ~ADin[n-1] & BDin[n-1] & ~Result[n-1];
	   end
	   `SUBU: {Overflow, Result} = ADin - BDin;
	   `SLT:  begin
	      {Carry_out, tmp} = ADin - BDin;
	      Overflow = ADin[n-1] & ~BDin[n-1] & ~tmp[n-1] 
			 | ~ADin[n-1] & BDin[n-1] & tmp[n-1];
	      $display("\nSLT:- [%d] tmp = %d [%b]; Cout=%b, Ovf=%b; A=%d, B=%d",
		       $time, tmp, tmp, Carry_out, Overflow, ADin, BDin );
	      Result = tmp[n-1] ^ Overflow;
	      $display("\nSLT:+R=%d [%b]", Result, Result );
	   end
	   `SLTU: begin
	      {Carry_out, tmp} = ADin - BDin;
	      $display("SLTU:- [%d] tmp = %d [%b]; Cout=%b, Ovf=%b; A=%d, B=%d",
		       $time, tmp, tmp, Carry_out, Overflow, ADin, BDin );
	      Result = Carry_out;
	      $display("SLTU:+R=%d [%b]", Result, Result );
	   end
	   `OR :  Result = ADin | BDin;
	   `AND:  Result = ADin & BDin;
	   `XOR:  Result = ADin ^ BDin;
	   `NOP:  Result = ADin;
	   `SLL:  Result = ADin << BDin;
	   `SRL:  Result = ADin >> BDin;
	   `SRA:  Result = $signed(ADin) >>> BDin;
	   `BNE:  if ((ADin-BDin)!=0)Result =0 ;
	   `NOP: Result= 1'bZ;
	 endcase
	 Zero = ~| Result;  
      end
endmodule
