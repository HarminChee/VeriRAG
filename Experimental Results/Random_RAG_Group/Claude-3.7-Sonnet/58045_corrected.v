module reginit(input wire clk, input wire test_i, input wire rst_n, output wire [3:0] data);
parameter NP = 23;        
parameter INI = 4'b1100;  
wire clk_pres;
reg [3:0] dout;
wire [3:0] din;
reg sel = 0;
wire dft_clk;
assign dft_clk = test_i ? clk : clk_pres;

always @(posedge dft_clk or negedge rst_n)
  if (!rst_n)
    dout <= 4'b0;
  else
    dout <= din;

assign data = dout;
assign din = (sel == 0) ? INI : ~dout;

always @(posedge dft_clk or negedge rst_n)
  if (!rst_n)
    sel <= 0;
  else
    sel <= 1;

prescaler #(.N(NP))
  PRES (
    .clk_in(clk),
    .clk_out(clk_pres)
  );
endmodule