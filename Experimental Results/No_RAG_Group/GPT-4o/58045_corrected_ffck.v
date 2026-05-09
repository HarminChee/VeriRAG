module reginit_corrected_ffc(input wire clk, output wire [3:0] data);
parameter NP = 23;        
parameter INI = 4'b1100;  
reg [3:0] dout;
wire [3:0] din;
reg sel = 0;
always @(posedge(clk))
  dout <= din;
assign data = dout;
assign din = (sel == 0) ? INI : ~dout;
always @(posedge(clk))
  sel <= 1;
endmodule