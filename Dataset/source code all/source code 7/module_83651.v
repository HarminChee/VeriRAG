module acl_fp_add_sub_dbl_pumped
#(
  parameter WIDTH=32
)
(
    input clock,
    input clock2x,
    input enable,
    input add_sub,
    input [WIDTH-1:0] a1,
    input [WIDTH-1:0] b1,
    input [WIDTH-1:0] a2,
    input [WIDTH-1:0] b2,
    output reg [WIDTH-1:0] y1,
    output reg [WIDTH-1:0] y2
    );
  reg [WIDTH-1:0] a1_reg;
  reg [WIDTH-1:0] b1_reg;
  reg [WIDTH-1:0] a2_reg;
  reg [WIDTH-1:0] b2_reg;
  reg add_sub_reg;
  reg clk_90deg, sel2x ;
  reg [WIDTH-1:0] fp_add_sub_inp_a;
  reg [WIDTH-1:0] fp_add_sub_inp_b;
  reg fp_add_sub_inp_add_sub;
  wire [WIDTH-1:0] fp_add_sub_res;
  reg [WIDTH-1:0] fp_add_sub_res_reg;
  reg [WIDTH-1:0] fp_add_sub_res_del1_2x_cycle;
  always@(posedge clock)
  begin
    if (enable) a1_reg <= a1;
    if (enable) a2_reg <= a2;
    if (enable) b1_reg <= b1;
    if (enable) b2_reg <= b2;
    if (enable) add_sub_reg <= add_sub;
  end
  generate
    if (WIDTH == 32)
      acl_fp_add_sub_fast the_sub(
          .add_sub(fp_add_sub_inp_add_sub), 
          .clk_en(enable), 
          .clock(clock2x), 
          .dataa(fp_add_sub_inp_a), 
          .datab(fp_add_sub_inp_b), 
          .result(fp_add_sub_res));
    else 
      acl_fp_add_sub_fast_double the_sub(
          .add_sub(fp_add_sub_inp_add_sub), 
          .enable(enable), 
          .clock(clock2x), 
          .dataa(fp_add_sub_inp_a), 
          .datab(fp_add_sub_inp_b), 
          .result(fp_add_sub_res));    
  endgenerate
  always@(posedge clock2x)
  begin
    if (enable) fp_add_sub_res_del1_2x_cycle <= fp_add_sub_res_reg;
    if (enable) fp_add_sub_inp_a <= (!sel2x) ? a1_reg : a2_reg;
    if (enable) fp_add_sub_inp_b <= (!sel2x) ? b1_reg : b2_reg;
    if (enable) fp_add_sub_inp_add_sub <= add_sub_reg;
    if (enable) fp_add_sub_res_reg <= fp_add_sub_res;
  end
  always@(posedge clock)
  begin
     if (enable) y1 <= fp_add_sub_res_del1_2x_cycle;
     if (enable) y2 <= fp_add_sub_res_reg;
  end    
  always@(negedge clock2x)
    clk_90deg<=clock;
  always@(posedge clock2x)
    sel2x<=clk_90deg;  
endmodule
