module pfpu_fmul(
	input sys_clk,
	input alu_rst,
	input [31:0] a,
	input [31:0] b,
	input valid_i,
	output reg [31:0] r,
	output reg valid_o
);
wire		a_sign = a[31];
wire [7:0]	a_expn = a[30:23];
wire [23:0]	a_mant = {1'b1, a[22:0]};
wire		b_sign = b[31];
wire [7:0]	b_expn = b[30:23];
wire [23:0]	b_mant = {1'b1, b[22:0]};
reg		r_zero;
reg		r_sign;
reg [7:0]	r_expn;
reg [23:0]	r_a_mant;
reg [23:0]	r_b_mant;
reg r_valid;
always @(posedge sys_clk) begin
	if(alu_rst)
		r_valid <= 1'b0;
	else
		r_valid <= valid_i;
	r_zero <= (a_expn == 8'd0)|(b_expn == 8'd0);
	r_sign <= a_sign ^ b_sign;
	r_expn <= a_expn + b_expn - 8'd127;
	r_a_mant <= a_mant;
	r_b_mant <= b_mant;
end
reg		r1_zero;
reg		r1_sign;
reg [7:0]	r1_expn;
reg [47:0]	r1_mant;
reg r1_valid;
always @(posedge sys_clk) begin
	if(alu_rst)
		r1_valid <= 1'b0;
	else
		r1_valid <= r_valid;
	r1_zero <= r_zero;
	r1_sign <= r_sign;
	r1_expn <= r_expn;
	r1_mant <= r_a_mant*r_b_mant;
end
reg		r2_zero;
reg		r2_sign;
reg [7:0]	r2_expn;
reg [47:0]	r2_mant;
reg r2_valid;
always @(posedge sys_clk) begin
	if(alu_rst)
		r2_valid <= 1'b0;
	else
		r2_valid <= r1_valid;
	r2_zero <= r1_zero;
	r2_sign <= r1_sign;
	r2_expn <= r1_expn;
	r2_mant <= r1_mant;
end
reg		r3_zero;
reg		r3_sign;
reg [7:0]	r3_expn;
reg [47:0]	r3_mant;
reg r3_valid;
always @(posedge sys_clk) begin
	if(alu_rst)
		r3_valid <= 1'b0;
	else
		r3_valid <= r2_valid;
	r3_zero <= r2_zero;
	r3_sign <= r2_sign;
	r3_expn <= r2_expn;
	r3_mant <= r2_mant;
end
reg		r4_zero;
reg		r4_sign;
reg [7:0]	r4_expn;
reg [47:0]	r4_mant;
reg r4_valid;
always @(posedge sys_clk) begin
	if(alu_rst)
		r4_valid <= 1'b0;
	else
		r4_valid <= r3_valid;
	r4_zero <= r3_zero;
	r4_sign <= r3_sign;
	r4_expn <= r3_expn;
	r4_mant <= r3_mant;
end
always @(posedge sys_clk) begin
	if(alu_rst)
		valid_o <= 1'b0;
	else
		valid_o <= r4_valid;
	if(r4_zero)
		r <= {1'bx, 8'd0, 23'bx};
	else begin
		if(~r4_mant[47])
			r <= {r4_sign, r4_expn,      r4_mant[45:23]};
		else
			r <= {r4_sign, r4_expn+8'd1, r4_mant[46:24]};
	end
end
endmodule
