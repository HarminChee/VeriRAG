module pipestage
  #(parameter TAGWIDTH = 1)
   (input clk,
    input reset,
    input stb_in,
    input stb_out,
    output reg valid,
    input [TAGWIDTH-1:0] tag_in,
    output reg [TAGWIDTH-1:0] tag_out);
   always @(posedge clk)
     if(reset)
       begin
	  valid <= 0;
	  tag_out <= 0;
       end
     else if(stb_in)
       begin
	  valid <= 1;
	  tag_out <= tag_in;
       end
     else if(stb_out)
       begin
	  valid <= 0;
	  tag_out <= 0;
       end
endmodule 
