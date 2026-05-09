module clip_and_round_reg
  #(parameter bits_in=0,
    parameter bits_out=0,
    parameter clip_bits=0)
    (input clk,
     input [bits_in-1:0] in,
     output reg [bits_out-1:0] out);
   wire [bits_out-1:0] 	   temp;
   clip_and_round #(.bits_in(bits_in),.bits_out(bits_out),.clip_bits(clip_bits))
     clip_and_round (.in(in),.out(temp));
   always@(posedge clk)
     out <= temp;
endmodule 
