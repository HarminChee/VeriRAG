`timescale 1ns / 1ps
module clock_div_50k(clk, clkcnt_reset,  div_50k);
     input clk;
     input clkcnt_reset;
    output div_50k;
      reg div_50k;
     reg [19:0] cnt;
  always @(negedge clkcnt_reset or posedge clk)begin
  if(~clkcnt_reset) cnt <= 0;
  else if (cnt >= 50000) begin
          div_50k <= 0;
          cnt <= 0; end
      else if (cnt < 25000) begin
          div_50k <= 0;
          cnt <= cnt + 1; end
      else if ((cnt >= 25000) && (cnt < 50000)) begin   
            div_50k <= 1;
            cnt <= cnt + 1; end
  end 
endmodule
module clock_div_500k(clk, clkcnt_reset,  div_500k);
     input clk;
     input clkcnt_reset;     
    output div_500k;
      reg div_500k;
     reg [19:0] cnt;
  always @(negedge clkcnt_reset or posedge clk)begin
  if(~clkcnt_reset) cnt <= 0;
  else if (cnt >= 500000) begin
          div_500k <= 0;
          cnt <= 0; end
      else if (cnt < 250000) begin
          div_500k <= 0;
          cnt <= cnt + 1; end
      else if ((cnt >= 250000) && (cnt < 500000)) begin 
            div_500k <= 1;
            cnt <= cnt + 1; end
  end 
endmodule
`timescale 1ns / 1ps
module clock_get_all(input clk_origin, 
                   input clkcnt_reset, 
                    output out_clk_1khz, 
                   output out_clk_100hz); 
    wire clk_1ms; 
    wire clk_1cs; 
    assign out_clk_1khz = clk_1ms;
    assign out_clk_100hz = clk_1cs;
     clock_div_50k instan_div_50k (.clk(clk_origin),
                                   .clkcnt_reset(clkcnt_reset),
                                   .div_50k(clk_1ms)); 
     clock_div_500k instan_div_500k(.clk(clk_origin),
                                    .clkcnt_reset(clkcnt_reset),
                                    .div_500k(clk_1cs)); 
endmodule
module clock_div_50k(clk, clkcnt_reset,  div_50k);
     input clk;
     input clkcnt_reset;
    output div_50k;
      reg div_50k;
     reg [19:0] cnt;
  always @(negedge clkcnt_reset or posedge clk)begin
  if(~clkcnt_reset) cnt <= 0;
  else if (cnt >= 50000) begin
          div_50k <= 0;
          cnt <= 0; end
      else if (cnt < 25000) begin
          div_50k <= 0;
          cnt <= cnt + 1; end
      else if ((cnt >= 25000) && (cnt < 50000)) begin   
            div_50k <= 1;
            cnt <= cnt + 1; end
  end 
endmodule
module clock_div_500k(clk, clkcnt_reset,  div_500k);
     input clk;
     input clkcnt_reset;     
    output div_500k;
      reg div_500k;
     reg [19:0] cnt;
  always @(negedge clkcnt_reset or posedge clk)begin
  if(~clkcnt_reset) cnt <= 0;
  else if (cnt >= 500000) begin
          div_500k <= 0;
          cnt <= 0; end
      else if (cnt < 250000) begin
          div_500k <= 0;
          cnt <= cnt + 1; end
      else if ((cnt >= 250000) && (cnt < 500000)) begin 
            div_500k <= 1;
            cnt <= cnt + 1; end
  end 
endmodule
