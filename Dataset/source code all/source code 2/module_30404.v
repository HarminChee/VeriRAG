module ddr_clkout (pad, clk);
input clk;
output pad;
ODDR2 ddrout (.Q(pad), .D0(1'b0), .D1(1'b1), .C0(!clk), .C1(clk));
endmodule
module ddr_inbuf (clk, pad, indata, indata180);
parameter WIDTH=32;
input clk;
input [WIDTH-1:0] pad;
output [WIDTH-1:0] indata;
output [WIDTH-1:0] indata180;
reg [WIDTH-1:0] indata, indata180, next_indata;
always @(posedge clk) indata = next_indata;
always @(negedge clk) indata180 = next_indata;
always @* begin #1; next_indata = pad; end
endmodule
module outbuf (pad, clk, outsig, oe);
inout pad;
input clk;
input outsig, oe;
reg sampled_outsig, next_sampled_outsig;
reg sampled_oe, next_sampled_oe;
assign pad = (sampled_oe) ? sampled_outsig : 1'bz;
always @ (posedge clk)
begin
  sampled_outsig = next_sampled_outsig;
  sampled_oe = next_sampled_oe;
end
always @*
begin
  #1;
  next_sampled_outsig = outsig;
  next_sampled_oe = oe;
end
endmodule
module ddr_clkout (pad, clk);
input clk;
output pad;
ODDR2 ddrout (.Q(pad), .D0(1'b0), .D1(1'b1), .C0(!clk), .C1(clk));
endmodule
module ddr_inbuf (clk, pad, indata, indata180);
parameter WIDTH=32;
input clk;
input [WIDTH-1:0] pad;
output [WIDTH-1:0] indata;
output [WIDTH-1:0] indata180;
reg [WIDTH-1:0] indata, indata180, next_indata;
always @(posedge clk) indata = next_indata;
always @(negedge clk) indata180 = next_indata;
always @* begin #1; next_indata = pad; end
endmodule
