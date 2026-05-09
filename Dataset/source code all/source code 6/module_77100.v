`timescale 1ns / 1ps
`timescale 1ns / 1ps
module RCB_FRL_COUNT_TO_64(clk, rst, count, ud, counter_value);
input clk, rst, count, ud;
output [5:0] counter_value;
wire [5:0] counter_value_preserver;
reg [5:0] counter_value;
always@(posedge clk or posedge rst)
begin
if(rst == 1'b1)
 counter_value = 6'h00;
else
 begin
  case({count,ud})
   2'b00: counter_value = counter_value_preserver;
   2'b01: counter_value = counter_value_preserver;
   2'b10: counter_value = counter_value_preserver - 1;
   2'b11: counter_value = counter_value_preserver + 1;
   default: counter_value = 6'h00;
  endcase
 end
end
assign counter_value_preserver = counter_value;
endmodule
