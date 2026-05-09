module bytefifo (
		 CLK,
		 RST,
                 DATA_IN,
		 DATA_OUT,
		 PUSH_POPn,
                 EN,
                 BYTES_AVAIL,
		 BYTES_FREE
		);
   input        CLK;
   input        RST;
   input  [7:0] DATA_IN;
   output [7:0] DATA_OUT;
   input        PUSH_POPn;
   input        EN;
   output [3:0] BYTES_AVAIL;
   output [3:0] BYTES_FREE;
   reg [7:0] 	reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
   reg [3:0] 	counter;
   reg [7:0]  DATA_OUT;
   wire [3:0]  BYTES_AVAIL;
   wire [3:0] 	BYTES_FREE;
   wire 	push_ok;
   wire    pop_ok;
   assign BYTES_AVAIL = counter;  
   assign  BYTES_FREE = 4'h8 - BYTES_AVAIL;
   assign  push_ok = !(counter == 4'h8);
   assign  pop_ok = !(counter == 4'h0);
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg0 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg0 <= DATA_IN;
     end
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg1 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg1 <= reg0;
     end
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg2 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg2 <= reg1;
     end
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg3 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg3 <= reg2;
     end
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg4 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg4 <= reg3;
     end
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg5 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg5 <= reg4;
     end
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg6 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg6 <= reg5;
     end
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg7 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg7 <= reg6;
     end
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)             counter <= 4'h0;
	else if(EN & PUSH_POPn & push_ok)  counter <= counter + 4'h1;
	else if(EN & (~PUSH_POPn) & pop_ok)    counter <= counter - 4'h1;
     end
   always @ (counter or reg0 or reg1 or reg2 or reg3 or reg4 or reg5
	     or reg6 or reg7)
     begin
	case (counter)
	  4'h1:     DATA_OUT <= reg0; 
	  4'h2:     DATA_OUT <= reg1;
	  4'h3:     DATA_OUT <= reg2;
	  4'h4:     DATA_OUT <= reg3;
	  4'h5:     DATA_OUT <= reg4;
	  4'h6:     DATA_OUT <= reg5;
	  4'h7:     DATA_OUT <= reg6;
	  4'h8:     DATA_OUT <= reg7;
	  default:  DATA_OUT <= 8'hXX;
	endcase
     end
endmodule
