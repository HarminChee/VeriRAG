`begin_keywords "1364-2005"
`end_keywords
`begin_keywords "1364-2005"
module sqrt
  (input clk,
   output wire rdy,
   input reset,
   input [31:0] x,
   output reg [15:0] acc);
   parameter ss=5;  localparam w=1<<ss; 
   reg [w-1:0] acc2;
   reg [ss-1:0]  bitl;
   wire [w/2-1:0] bit = 1 << bitl;
   wire [w-1:0] bit2 = 1 << (bitl << 1);
   assign rdy = bitl[ss-1];
   wire [w/2-1:0] guess  = acc | bit;
   wire [w-1:0] guess2 = acc2 + bit2 + ((acc << bitl) << 1);
   always @(posedge clk or posedge reset)
      if (reset) begin
         acc = 0;
         acc2 = 0;
         bitl = w/2-1;
      end else begin
         if (guess2 <= x) begin
            acc  <= guess;
            acc2 <= guess2;
         end
         bitl <= bitl - 1;
      end
endmodule 
`end_keywords
