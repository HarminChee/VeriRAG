module ohr_reg0 #(parameter DW = 1            
		  ) 
   ( input           nreset, 
     input 	     clk, 
     input [DW-1:0]  in, 
     output [DW-1:0] out  
     );
`ifdef CFG_ASIC
   asic_reg0 ireg [DW-1:0] (.nreset(nreset),
			    .clk(clk),
			    .in(in[DW-1:0]),
			    .out(out[DW-1:0]));
`else
   reg [DW-1:0]      out_reg;	   
   always @ (negedge clk or negedge nreset)
     if(~nreset)
       out_reg[DW-1:0] <= 'b0;
     else	      
       out_reg[DW-1:0] <= in[DW-1:0];
   assign out[DW-1:0] = out_reg[DW-1:0];	 
`endif
endmodule 
