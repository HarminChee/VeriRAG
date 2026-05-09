`timescale 1ns / 1ps
`define WRITE_TIMER 2'b00
`define READ_TIMER 2'b01
//`include "riot.vh"
`define NOP 1'b1
module RIOT(A, 
	    Din, 
	    Dout, 
	    CS, 
	    CS_n, 
	    R_W_n, 
	    RS_n, 
	    RES_n, 
	    IRQ_n, 
	    CLK,   
	    PAin,  
	    PAout, 
	    PBin,  
	    PBout);
   input [6:0] A;
   input [7:0] Din;
   output [7:0] Dout;
   input 	CS, CS_n, R_W_n, RS_n, RES_n, CLK;
   output 	IRQ_n;
   input [7:0] 	PAin, PBin;
   output [7:0] PAout, PBout; 
   reg [7:0] 	Dout; 
   reg [7:0] 	RAM[127:0]; 
   reg [7:0] 	DRA, DRB; 
   reg [7:0] 	DDRA, DDRB; 
   wire 	PA7;
   reg 		R_PA7;
   assign PA7 = (PAin[7] & ~DDRA[7]) | (DRA[7] & DDRA[7]);
   assign PAout = DRA & DDRA;
   assign PBout = DRB & DDRB;
   reg [8:0] 	Timer;
   reg [9:0] 	Prescaler;
   reg [1:0] 	Timer_Mode;
   reg 		Timer_Int_Flag, PA7_Int_Flag, Timer_Int_Enable, PA7_Int_Enable, PA7_Int_Mode; 
   wire [9:0] 	PRESCALER_VALS[3:0];
   assign PRESCALER_VALS[0] = 10'd0;
   assign PRESCALER_VALS[1] = 10'd7;
   assign PRESCALER_VALS[2] = 10'd63;
   assign PRESCALER_VALS[3] = 10'd1023;
   assign IRQ_n = ~(Timer_Int_Flag & Timer_Int_Enable | PA7_Int_Flag & PA7_Int_Enable);
   wire [6:0] 	op;
   reg [6:0] 	R_op;
   assign op = {RS_n, R_W_n, A[4:0]};
   reg [7:0] 	R_Din;
   integer 	cnt;
   always @(posedge CLK)
     begin
	if (~RES_n) begin
	   DRA <= 8'b0;
	   DDRA <= 8'b0;
	   DRB <= 8'b0;
	   DDRB <= 8'b0;
	   Timer_Int_Flag <= 1'b0;
	   PA7_Int_Flag <= 1'b0;
	   PA7_Int_Enable <= 1'b0;
	   PA7_Int_Mode <= 1'b0;
	   for (cnt = 0; cnt < 128; cnt = cnt + 1)
	     RAM[cnt] <= 8'b0;
	   R_PA7 <= 1'b0;
	   R_op <= `NOP;
	   R_Din <= 8'b0;
	end
	else if (CS & ~CS_n) begin
	   R_PA7 <= PA7;
	   R_op <= op;
	   R_Din <= Din;
	   casex (op)
	     2'b00: Timer_Int_Flag <= 1'b0;
	     2'b01: Timer_Int_Flag <= 1'b0;
	     default: if (Timer == 9'b111111111) Timer_Int_Flag <= 1'b1;
	   endcase
	   casex (op)
	     1'b0: PA7_Int_Flag <= 1'b0;
	     default: PA7_Int_Flag <= PA7_Int_Flag | (PA7 != R_PA7 & PA7 == PA7_Int_Mode);
	   endcase
	   casex(op) 
	     4'b0000: Dout <= RAM[A];
	     4'b0001: RAM[A] <= Din;
	     4'b0010: Dout <= (PAin & ~DDRA) | (DRA & DDRA);
	     4'b0011: DRA <= Din;
	     4'b0100: Dout <= DDRA;
	     4'b0101: DDRA <= Din;
	     4'b0110: Dout <= (PBin & ~DDRB) | (DRB & DDRB);
	     4'b0111: DRB <= Din;
	     4'b1000: Dout <= DDRB;
	     4'b1001: DDRB <= Din;
	     4'b1010: Dout <= Timer[7:0];
	     4'b1011: Dout <= {Timer_Int_Flag, PA7_Int_Flag, 6'b0};
	     4'b1100: begin
		PA7_Int_Mode <= A[0]; PA7_Int_Enable <= A[1];
	     end
	   endcase
	end
	else begin
	   if (Timer == 9'b111111111)
	     Timer_Int_Flag <= 1'b1;
	   R_PA7 <= PA7;
	   PA7_Int_Flag <= PA7_Int_Flag | (PA7 != R_PA7 & PA7 == PA7_Int_Mode);
	   R_op <=`NOP;
	end
     end
   always @(negedge CLK)begin
      if (~RES_n) begin
	 Timer <= 9'b0;
	 Timer_Mode <= 2'b0;
	 Prescaler <= 10'b0;
	 Timer_Int_Enable <= 1'b0;
      end
      else
	casex
	  (R_op)
	  1'b0:begin
	     Timer <= {1'b0, R_Din};
	     Timer_Mode <= R_op[1:0];
	     Prescaler <= PRESCALER_VALS[R_op[1:0]];
	     Timer_Int_Enable <= R_op[3];
	  end
	  default:if (Timer != 9'b100000000) begin
	     if (Prescaler != 10'b0)
	       Prescaler <= Prescaler - 10'b1;
	     else begin
		if (Timer == 9'b0)
		  begin
		     Prescaler <= 10'b0;
		     Timer_Mode <= 2'b0;
		  end
		else
		  Prescaler <= PRESCALER_VALS[Timer_Mode];
		Timer <= Timer - 9'b1;
	     end
	  end
	endcase
   end
endmodule
