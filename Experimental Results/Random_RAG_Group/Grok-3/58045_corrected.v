module reginit(input wire test_i, input wire clk, input wire rst, output wire [3:0] data);
parameter NP = 23;        
parameter INI = 4'b1100;  
wire clk_pres;
wire dft_clk_pres;
reg [3:0] dout;
wire [3:0] din;
reg sel = 0;
assign dft_clk_pres = test_i ? clk : clk_pres;
always @(posedge dft_clk_pres or posedge rst)
  if (rst)
    dout <= 4'b0;
  else
    dout <= din;
assign data = dout;
assign din = (sel == 0) ? INI : ~dout;
always @(posedge dft_clk_pres or posedge rst)
  if (rst)
    sel <= 0;
  else
    sel <= 1;
prescaler #(.N(NP))
  PRES (
    .clk_in(clk),
    .clk_out(clk_pres)
  );
endmodule