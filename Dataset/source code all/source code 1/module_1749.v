`timescale 1ns / 1ps
`timescale 1ns / 1ps
module pwm #(CLK_PERIOD = 1000)(
    input clk,
    input enable,
    input [31:0] pwm_period,
    output out
    );
reg clk_out=1'b0;
reg [31:0] counter = 32'b0;
always @(posedge clk)
begin
  if (enable == 1'b1)
    begin
      if (counter < pwm_period)
        begin
         clk_out <= 1'b1;
         counter <= counter + 32'b1;
        end
      else
        begin
        if (counter < (CLK_PERIOD-1))
         begin
          clk_out <= 1'b0;
          counter <= counter + 32'b1;
         end
        else 
         begin
          clk_out <= 1'b0;
          counter <= 32'b0;
         end
       end 
     end   
   else
     begin
        if ((counter > 0) && (counter < pwm_period) )   
           begin
              clk_out <= 1'b1;
              counter <= counter + 32'b1;
           end
        else
           begin
             clk_out <= 1'b0;
             counter <= 32'b0;
           end
     end 
end 
assign out = clk_out;
endmodule
