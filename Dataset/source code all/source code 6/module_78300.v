module ISERDESE2 (
   O, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, SHIFTOUT1, SHIFTOUT2,
   BITSLIP, CE1, CE2, CLK, CLKB, CLKDIV, CLKDIVP, D, DDLY,
   DYNCLKDIVSEL, DYNCLKSEL, OCLK, OCLKB, OFB, RST, SHIFTIN1, SHIFTIN2
   );
   parameter DATA_RATE         = 0; 
   parameter DATA_WIDTH        = 0; 
   parameter DYN_CLK_INV_EN    = 0; 
   parameter DYN_CLKDIV_INV_EN = 0; 
   parameter INIT_Q1           = 0; 
   parameter INIT_Q2           = 0; 
   parameter INIT_Q3           = 0; 
   parameter INIT_Q4           = 0; 
   parameter INTERFACE_TYPE    = 0; 
   parameter IOBDELAY          = 0; 
   parameter NUM_CE            = 0; 
   parameter OFB_USED          = 0; 
   parameter SERDES_MODE       = 0; 
   parameter SRVAL_Q1          = 0; 
   parameter SRVAL_Q2          = 0; 
   parameter SRVAL_Q3          = 0; 
   parameter SRVAL_Q4          = 0; 
   input  BITSLIP;        
   input  CE1;            
   input  CE2;            
   input  CLK;            
   input  CLKB;           
   input  CLKDIV;         
   input  CLKDIVP;        
   input  D;              
   input  DDLY;           
   input  DYNCLKDIVSEL;   
   input  DYNCLKSEL;      
   input  OCLK;           
   input  OCLKB;          
   input  OFB;            
   input  RST;            
   input  SHIFTIN1;       
   input  SHIFTIN2;       
   output O;              
   output Q1;             
   output Q2;
   output Q3;
   output Q4;   
   output Q5;
   output Q6;
   output Q7;
   output Q8;             
   output SHIFTOUT1;      
   output SHIFTOUT2;      
   reg [3:0] even_samples;
   reg [3:0] odd_samples;
   reg 	     Q1; 
   reg 	     Q2;
   reg 	     Q3;
   reg 	     Q4;   
   reg 	     Q5;
   reg 	     Q6;
   reg 	     Q7;
   reg 	     Q8;           
   always @ (posedge CLK)
     odd_samples[3:0] <=   {odd_samples[2:0],D};
   always @ (negedge CLK)
     even_samples[3:0] <=  {even_samples[2:0],D};
   always @ (posedge CLKDIV)
     begin
	 Q1 <=  odd_samples[0];
	 Q2 <=  even_samples[0];
	 Q3 <=  odd_samples[1];
	 Q4 <=  even_samples[1];
	 Q5 <=  odd_samples[2];
	 Q6 <=  even_samples[2];
	 Q7 <=  odd_samples[3];
	 Q8 <=  even_samples[3];
     end
   assign O=D;
   assign SHIFTOUT1=1'b0;
   assign SHIFTOUT2=1'b0;
endmodule 
