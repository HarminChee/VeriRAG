module pfpu_regf(
	input sys_clk,
	input sys_rst,
	output reg ifb,
	output [31:0] a,
	output [31:0] b,
	input [31:0] r,
	input w_en,
	input [6:0] a_addr,
	input [6:0] b_addr,
	input [6:0] w_addr,
	input c_en,
	input [6:0] c_addr,
	output [31:0] c_do,
	input [31:0] c_di,
	input c_w_en,
	input [31:0] r0,
	input [31:0] r1,
	output err_stray
);
wire [6:0] p1_a;
wire [31:0] p1_d;
wire [6:0] p2_a;
wire [31:0] p2_d;
wire p3_en;
wire [6:0] p3_a;
wire [31:0] p3_d;
pfpu_tpram tpram(
	.sys_clk(sys_clk),
	.p1_a(p1_a),
	.p1_d(p1_d),
	.p2_a(p2_a),
	.p2_d(p2_d),
	.p3_en(p3_en),
	.p3_a(p3_a),
	.p3_d(p3_d)
);
assign p1_a = c_en ? c_addr : a_addr;
reg p1_bram_en;
reg p1_overlay_en;
reg [31:0] p1_overlay;
always @(posedge sys_clk) begin
	p1_bram_en <= 1'b0;
	p1_overlay_en <= 1'b1;
	     if(p1_a == 7'd0) p1_overlay <= r0;
	else if(p1_a == 7'd1) p1_overlay <= r1;
	else begin
		p1_bram_en <= 1'b1;
		p1_overlay_en <= 1'b0;
		p1_overlay <= 32'bx;
	end
end
assign a = ({32{p1_bram_en}} & p1_d)|({32{p1_overlay_en}} & p1_overlay);
assign c_do = a;
assign p2_a = b_addr;
reg p2_bram_en;
reg p2_overlay_en;
reg [31:0] p2_overlay;
always @(posedge sys_clk) begin
	p2_bram_en <= 1'b0;
	p2_overlay_en <= 1'b1;
	     if(p2_a == 7'd0) p2_overlay <= r0;
	else if(p2_a == 7'd1) p2_overlay <= r1;
	else begin
		p2_bram_en <= 1'b1;
		p2_overlay_en <= 1'b0;
		p2_overlay <= 32'bx;
	end
end
assign b = ({32{p2_bram_en}} & p2_d)|({32{p2_overlay_en}} & p2_overlay);
assign p3_en = c_en ? c_w_en : w_en;
assign p3_a = c_en ? c_addr : w_addr;
assign p3_d = c_en ? c_di : r;
always @(posedge sys_clk) begin
	if(p3_en) begin
		if(p3_a == 7'd2)
			ifb <= p3_d != 32'd0;
	end
end
assign err_stray = p3_en & (p3_a == 7'd0);
endmodule
