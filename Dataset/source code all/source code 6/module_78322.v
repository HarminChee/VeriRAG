module syncreg (
                CLKA,
		CLKB,
		RST,
                DATA_IN,
                DATA_OUT
		);
   input   CLKA;
   input   CLKB;
   input   RST;
   input   [3:0] DATA_IN;
   output  [3:0] DATA_OUT;
   reg 	   [3:0] regA;
   reg 	   [3:0] regB;
   reg 	   strobe_toggle;
   reg 	   ack_toggle;
   wire    A_not_equal;
   wire    A_enable;
   wire    strobe_sff_out;
   wire    ack_sff_out;
   wire [3:0]   DATA_OUT;
   assign  A_enable = A_not_equal & ack_sff_out;
   assign  A_not_equal = !(DATA_IN == regA);
   assign DATA_OUT = regB;   
   always @ (posedge CLKA or posedge RST)
     begin
	if(RST)
	  regA <= 4'b0;
	else if(A_enable)
	  regA <= DATA_IN;
     end
   always @ (posedge CLKB or posedge RST)
     begin
	if(RST)
	  regB <= 4'b0;
	else if(strobe_sff_out)
	  regB <= regA;
     end
   always @ (posedge CLKA or posedge RST)
     begin
	if(RST)
	  strobe_toggle <= 1'b0;
	else if(A_enable)
	  strobe_toggle <= ~strobe_toggle;
     end
   always @ (posedge CLKB or posedge RST)
     begin
	if(RST)
	  ack_toggle <= 1'b1;
	else if (strobe_sff_out)
	  ack_toggle <= ~ack_toggle;
     end
   syncflop strobe_sff (
			.DEST_CLK (CLKB),
			.D_SET (1'b0),
			.D_RST (strobe_sff_out),
			.RESET (RST),
			.TOGGLE_IN (strobe_toggle),
			.D_OUT (strobe_sff_out)
			);
   syncflop ack_sff (
		     .DEST_CLK (CLKA),
		     .D_SET (1'b0),
		     .D_RST (A_enable),
		     .RESET (RST),
		     .TOGGLE_IN (ack_toggle),
		     .D_OUT (ack_sff_out)
		     );  
endmodule
