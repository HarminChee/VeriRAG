module clk_prescaler( 
   CLK, CLK_EN, div_1, div_2, div_3, MR, pre_0, pre_1, clk_1us);
   input  CLK;
   input  CLK_EN;              
   input  div_1;               
   input  div_2;               
   input  div_3;               
   input  MR;
   input  pre_0;               
   input  pre_1;               
   output clk_1us;             
   wire   CLK;
   wire   MR;
   wire   pre_0;
   wire   pre_1;
   wire   div_1;
   wire   div_2;
   wire   div_3;
   wire   clk_prescaled;      
   wire    clk_1us;            
   reg    clk_div;            
   reg    en_div;             
   reg    clk_prescaled_reg;
   reg [6:0] div_cnt;
   reg [2:0] ClkPrescale;
   parameter [2:0] s0=3'b000, s1=3'b001, s2=3'b010, s3=3'b011, s4=3'b100,
                   s5=3'b101, s6=3'b110;
  wire rst_clk = MR || !CLK_EN;
  always @(posedge rst_clk or posedge CLK)
    if(rst_clk)
      ClkPrescale <= s0;
    else
      case(ClkPrescale)
        s0:      ClkPrescale <= s1;
        s1:      ClkPrescale <= s2;
        s2:      if(pre_0 && !pre_1)
                   ClkPrescale <= s0;
                 else
                   ClkPrescale <= s3;
        s3:      ClkPrescale <= s4;
        s4:      if(!pre_0 && pre_1)
                   ClkPrescale <= s0;
                 else
                   ClkPrescale <= s5;
        s5:      ClkPrescale <= s6;
        s6:      ClkPrescale <= s0;
        default: ClkPrescale<=s0;
      endcase
   reg en_clk;
   always @(posedge MR or posedge CLK)
      if (MR)
         clk_prescaled_reg<=1;
      else
         clk_prescaled_reg <= (!ClkPrescale[0] && !ClkPrescale[1] 
                               && !ClkPrescale[2]);  
  always @(posedge MR or negedge CLK)
    if (MR)
      en_clk <= 1'b1;
    else
      en_clk <= CLK_EN && ((!pre_0 && !pre_1) || (ClkPrescale[2:0] == 3'b000));
  assign clk_prescaled = en_clk & CLK;
  always @(posedge MR or posedge CLK)
    if (MR)
      div_cnt <= 7'h00;
    else if (en_clk)
      div_cnt <= div_cnt + 1;
  reg    clk_1us_en;
  always @(posedge MR or negedge CLK)
    if (MR) 
      clk_1us_en <= 1'b1;
    else
      case ({div_3, div_2, div_1})
        3'b000 : clk_1us_en <= CLK_EN;
        3'b001 : clk_1us_en <= ~div_cnt[0];
        3'b010 : clk_1us_en <= (div_cnt[1:0] == 2'h1);
        3'b011 : clk_1us_en <= (div_cnt[2:0] == 3'h3);
        3'b100 : clk_1us_en <= (div_cnt[3:0] == 4'h7);
        3'b101 : clk_1us_en <= (div_cnt[4:0] == 5'h0f);
        3'b110 : clk_1us_en <= (div_cnt[5:0] == 6'h1f);
        3'b111 : clk_1us_en <= (div_cnt[6:0] == 7'h3f);
      endcase
  reg clk_1us_en_d1;
  always @(negedge CLK)
  if(!en_clk)
  	clk_1us_en_d1 <= 1'b0;
  else
    clk_1us_en_d1 <= clk_1us_en;
  assign clk_1us = (!clk_1us_en_d1 && clk_1us_en);
endmodule 
