`timescale 1ns / 1ps
`timescale 1ns / 1ps
module time_cnt(
   input ce, 
   input clk_100hz, 
   input clr, 
   output [3:0] lit_lsb, 
   output [3:0] lit_msb, 
   output [3:0] sec_lsb, 
   output [3:0] sec_msb, 
   output [3:0] min_lsb, 
   output [3:0] min_msb);
  reg [3:0] lit_lsb_cnt;
  reg [3:0] lit_msb_cnt;
  reg [3:0] sec_lsb_cnt;
  reg [3:0] sec_msb_cnt;
  reg [3:0] min_lsb_cnt;
  reg [3:0] min_msb_cnt;
  wire up; 
  assign up = 1; 
  wire enable, tc_1up, tc_2up, tc_3up, tc_4up, tc_5up;
  wire tc_1dn, tc_2dn, tc_3dn, tc_4dn, tc_5dn; 
  assign tc_1up = (up && (lit_lsb_cnt == 4'd9));
  assign tc_2up = (up && (lit_msb_cnt == 4'd9));
  assign tc_3up = (up && (sec_lsb_cnt == 4'd9));
  assign tc_4up = (up && (sec_msb_cnt == 4'd5));
  assign tc_5up = (up && (min_lsb_cnt == 4'd9));
  assign tc_6up = (up && (min_msb_cnt == 4'd5));
  assign enable = ~(tc_1up && tc_2up && tc_3up && tc_4up && tc_5up && tc_6up)&& ce; 
  always @(posedge clk_100hz or posedge clr)  
  begin
    if (clr)
      lit_lsb_cnt <= 0;
    else if (enable) 
       if (up)  
          if (lit_lsb_cnt == 4'd9)
                 lit_lsb_cnt <= 4'd0;
             else lit_lsb_cnt <= lit_lsb_cnt + 1;
  end 
  always @(posedge clk_100hz or posedge clr)  
  begin
    if (clr)
      lit_msb_cnt <= 0;
    else if (enable)
       if (tc_1up)
          if (lit_msb_cnt == 4'd9)
                 lit_msb_cnt <= 4'd0;
             else lit_msb_cnt <= lit_msb_cnt + 1;
  end 
  always @(posedge clk_100hz or posedge clr)  
  begin
    if (clr)
      sec_lsb_cnt <= 0;
    else if (enable)
       if (tc_1up && tc_2up) 
          if (sec_lsb_cnt == 4'd9)
                 sec_lsb_cnt <= 4'd0;
             else sec_lsb_cnt <= sec_lsb_cnt + 1;
  end 
  always @(posedge clk_100hz or posedge clr)  
  begin
    if (clr)
      sec_msb_cnt <= 0;
    else if (enable)
       if (tc_1up && tc_2up && tc_3up) 
          if (sec_msb_cnt == 4'd5)
                 sec_msb_cnt <= 4'd0;
             else sec_msb_cnt <= sec_msb_cnt + 1;
  end 
  always @(posedge clk_100hz or posedge clr)  
  begin
    if (clr)
      min_lsb_cnt <= 0;
    else if (enable)
       if (tc_1up && tc_2up && tc_3up && tc_4up) 
          if (min_lsb_cnt == 4'd9)
                 min_lsb_cnt <= 4'd0;
             else min_lsb_cnt <= min_lsb_cnt + 1;
  end 
  always @(posedge clk_100hz or posedge clr)  
  begin
    if (clr)
      min_msb_cnt <= 0;
    else if (enable)
       if (tc_1up && tc_2up && tc_3up && tc_4up && tc_5up) 
          if (min_msb_cnt == 4'd5)
                 min_msb_cnt <= 4'd0;
             else min_msb_cnt <= min_msb_cnt + 1;
  end 
  assign lit_lsb = lit_lsb_cnt;
  assign lit_msb = lit_msb_cnt;
  assign sec_lsb = sec_lsb_cnt;
  assign sec_msb = sec_msb_cnt; 
  assign min_lsb = min_lsb_cnt;
  assign min_msb = min_msb_cnt;
endmodule
