`define M     593         
`define WIDTH (2*`M-1)    
`define WIDTH_D0 1187
`define M     593         
`define WIDTH (2*`M-1)    
`define WIDTH_D0 1187
module pairing(clk, reset, sel, addr, w, update, ready, i, o, done);
   input clk;
   input reset; 
   input sel;
   input [5:0] addr;
   input w;
   input update; 
   input ready;  
   input i;
   output o;
   output done;
   reg [`WIDTH_D0:0] reg_in, reg_out;
   wire [`WIDTH_D0:0] out;
   assign o = reg_out[0];
   tiny
      tiny0 (clk, reset, sel, addr, w, reg_in, out, done);
   always @ (posedge clk) 
      if (update) reg_in <= 0;
      else if (ready) reg_in <= {i,reg_in[`WIDTH_D0:1]};
   always @ (posedge clk) 
      if (update) reg_out <= out;
      else if (ready) reg_out <= reg_out>>1;
endmodule
