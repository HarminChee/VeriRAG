`timescale 1ns / 1ps
`timescale 1ns / 1ps
module debounce(pb_debounced, pb, clk);
  output    pb_debounced; 
  input     pb;           
  input     clk;          
  reg [3:0] shift_reg;    
  always @(posedge clk) begin
    shift_reg[3:1] <= shift_reg[2:0];
    shift_reg[0] <= pb;
  end 
  assign pb_debounced = ((shift_reg == 4'b0000) ? 1'b0 : 1'b1);
endmodule
