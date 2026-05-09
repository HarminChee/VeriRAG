module syncflop(
                DEST_CLK,
		D_SET,
		D_RST,
		RESET,
                TOGGLE_IN,
                D_OUT
		);
   input   DEST_CLK;
   input   D_SET;
   input   D_RST;
   input   RESET;
   input   TOGGLE_IN;
   output  D_OUT;
   reg 	   sync1;
   reg 	   sync2;
   reg 	   syncprev;
   reg 	   srflop;
   wire    syncxor;
   wire    srinput;
   wire    D_OUT;
   assign  syncxor = sync2 ^ syncprev;
   assign  srinput = syncxor | D_SET;  
   assign  D_OUT = srflop | syncxor;
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET) sync1 <= 1'b0;
	else sync1 <= TOGGLE_IN;
     end
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET) sync2 <= 1'b0;
	else sync2 <= sync1;
     end
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET) syncprev <= 1'b0;
	else syncprev <= sync2;
     end
   always @ (posedge DEST_CLK or posedge RESET)
     begin
	if(RESET)         srflop <= 1'b0;
	else if(D_RST)    srflop <= 1'b0;
	else if (srinput) srflop <= 1'b1;
     end
endmodule
