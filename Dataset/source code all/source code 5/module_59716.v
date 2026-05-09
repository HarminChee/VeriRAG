module notegen(input wire clk,          
               input wire rstn,         
               input wire [15:0] note,  
               output reg clk_out);     
wire clk_tmp;
reg [15:0] divcounter = 0;
always @(posedge clk)
  if (rstn == 0)
    divcounter <= 0;      
  else if (note == 0)
    divcounter <= 0;
  else if (divcounter == note - 1)
    divcounter <= 0;
  else
    divcounter <= divcounter + 1;
assign clk_tmp = (divcounter == 0) ? 1 : 0;
always @(posedge clk)
  if (rstn == 0)
    clk_out <= 0;
  else if (note == 0)
    clk_out <= 0;
  else if (clk_tmp == 1)
    clk_out <= ~clk_out;
endmodule
