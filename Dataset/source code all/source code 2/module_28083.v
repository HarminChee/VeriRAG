module tmu2_qpram32 #(
	parameter depth = 11 
) (
	input sys_clk,
	input [depth-1:0] a1,
	output [31:0] d1,
	input [depth-1:0] a2,
	output [31:0] d2,
	input [depth-1:0] a3,
	output [31:0] d3,
	input [depth-1:0] a4,
	output [31:0] d4,
	input we,
	input [depth-1-1:0] aw,
	input [63:0] dw
);
wire [63:0] mem_d1;
wire [63:0] mem_d2;
wire [63:0] mem_d3;
wire [63:0] mem_d4;
reg r1, r2, r3, r4;
always @(posedge sys_clk) begin
	r1 <= a1[0];
	r2 <= a2[0];
	r3 <= a3[0];
	r4 <= a4[0];
end
tmu2_qpram #(
	.depth(depth-1),
	.width(64)
) workaround (
	.sys_clk(sys_clk),
	.a1(a1[depth-1:1]),
	.d1(mem_d1),
	.a2(a2[depth-1:1]),
	.d2(mem_d2),
	.a3(a3[depth-1:1]),
	.d3(mem_d3),
	.a4(a4[depth-1:1]),
	.d4(mem_d4),
	.we(we),
	.aw(aw),
	.dw(dw)
);
assign d1 = r1 ? mem_d1[31:0] : mem_d1[63:32];
assign d2 = r2 ? mem_d2[31:0] : mem_d2[63:32];
assign d3 = r3 ? mem_d3[31:0] : mem_d3[63:32];
assign d4 = r4 ? mem_d4[31:0] : mem_d4[63:32];
endmodule
