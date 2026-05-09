module oh_stretcher #(parameter CYCLES = 5) 
   ( input  clk, 
     input  in, 
     input  nreset, 
     output out 
     );  
   reg [CYCLES-1:0] valid;
   always @ (posedge clk or negedge nreset)
     if(!nreset)       
       valid[CYCLES-1:0] <='b0;   
     else if(in)
       valid[CYCLES-1:0] <={(CYCLES){1'b1}};   
     else
       valid[CYCLES-1:0] <={valid[CYCLES-2:0],1'b0};
   assign out = valid[CYCLES-1];
endmodule 
