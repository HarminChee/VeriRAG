`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module sync1s (
                f_clk ,
                s_clk ,
                rst_n ,
                in_fclk,
                out_sclk
               );
parameter WIDTH = 1 ;
input              f_clk ;       
input              s_clk ;       
input              rst_n ;       
input  [WIDTH-1:0] in_fclk ;     
output [WIDTH-1:0] out_sclk ;    
reg [WIDTH-1:0]   f_reg1 ;
reg [WIDTH-1:0]   f_reg2 ;
reg [WIDTH-1:0]   f_reg3 ;
reg [WIDTH-1:0]   s_reg1 ;
reg [WIDTH-1:0]   s_reg2 ;
wire [WIDTH-1:0]  hold_fb ;
wire [WIDTH-1:0]  out_sclk ;
integer i ;
always @(posedge f_clk or negedge rst_n) begin
   if (!rst_n)
      f_reg1 <= {WIDTH{1'b0}};
   else
      for (i = 0; i <= WIDTH-1; i = i+1) begin
         f_reg1[i] <= (hold_fb[i]=== 1'b1) ? f_reg1[i] : in_fclk[i];
      end
end
always @(posedge s_clk or negedge rst_n) begin
   if (!rst_n)
      s_reg1 <= {WIDTH{1'b0}};
   else
      s_reg1 <= f_reg1;
end
always @(posedge s_clk or negedge rst_n) begin
   if (!rst_n)
      s_reg2 <= {WIDTH{1'b0}};
   else
      s_reg2 <= s_reg1;
end
assign out_sclk  = s_reg2 ;
always @(posedge f_clk or negedge rst_n) begin
   if (!rst_n)
      f_reg2 <= {WIDTH{1'b0}};
   else
      f_reg2 <= s_reg2;
end
always @(posedge f_clk or negedge rst_n) begin
   if (!rst_n)
      f_reg3 <= {WIDTH{1'b0}};
   else
      f_reg3 <= f_reg2;
end
assign hold_fb  = f_reg1 ^ f_reg3;
endmodule
