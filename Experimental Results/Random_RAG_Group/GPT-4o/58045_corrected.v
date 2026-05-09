module reginit(input wire clk, input wire test_i, input wire scan_clk_pres, output wire [3:0] data);
parameter NP = 23;        
parameter INI = 4'b1100;  
wire clk_pres;
reg [3:0] dout;
wire [3:0] din;
reg sel = 0;
wire dft_clk_pres;
assign dft_clk_pres = test_i ? scan_clk_pres : clk_pres;
always @(posedge(dft_clk_pres))
  dout <= din;
assign data = dout;
assign din = (sel == 0) ? INI : ~dout;
always @(posedge(dft_clk_pres))
  sel <= 1;
prescaler #(.N(NP))
  PRES (
    .clk_in(clk),
    .clk_out(clk_pres)
  );
endmodule