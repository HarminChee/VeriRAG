`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ModmCountr
   #(parameter M=50000000) 
   (
    input wire clk, reset,
    output wire max_tick,
    output wire [log2(M)-1:0] q
   );
   localparam N = log2(M);   
   reg [N-1:0] r_reg;
   wire [N-1:0] r_next;
   always @(posedge clk, posedge reset)
      if (reset)
         r_reg <= 0;
      else
         r_reg <= r_next;
   assign r_next = (r_reg==(M-1)) ? 0 : r_reg + 1;
   assign q = r_reg;
   assign max_tick = (r_reg==(M-1)) ? 1'b1 : 1'b0;
   function integer log2(input integer n);
      integer i;
   begin
      log2 = 1;
      for (i = 0; 2**i < n; i = i + 1)
         log2 = i + 1;
   end
   endfunction
endmodule
