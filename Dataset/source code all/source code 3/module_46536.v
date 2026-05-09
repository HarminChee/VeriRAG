`timescale 1ns / 1ps
`timescale 1ns / 1ps
module clock_divider #
(
    parameter clock_division = 2
)
(
    input wire reset,
    input wire input_clock,
    output wire output_clock
); 
    reg[7:0] counter;
    reg output_clock_value;
    assign output_clock =  clock_division == 1 ? input_clock & reset : output_clock_value; 
    always @(posedge input_clock)
    begin
         if(~reset)
         begin
             counter <= 0;
             output_clock_value <= 0;
         end
         else
         begin
             if(counter == clock_division - 1)
             begin
                 output_clock_value <= ~output_clock_value;
                 counter <= 1;
             end
             else
                 counter <= counter + 1;
         end
    end
endmodule
