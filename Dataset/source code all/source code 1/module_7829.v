`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_traffic_gen_v2_0_7_asynch_rst_ff (
data  ,
clk    ,
reset ,
q     
);
input data, clk, reset ; 
output q;
(*ASYNC_REG = "TRUE" *) reg q;
always @ ( posedge clk or posedge reset) begin
  if (reset) begin
    q <= 1'b1;
  end  else begin
    q <= data;
  end
end
endmodule 
