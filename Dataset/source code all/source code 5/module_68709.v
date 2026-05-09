module surround_with_regs(
	i_data0,
	o_data0,
	clk
);
	input   [31:0] i_data0;
	output  [31:0] o_data0;
	reg  [31:0] o_data0;
	input clk;
	reg [31:0] i_data0_reg;
	wire [30:0] o_data0_from_mult;
	always @(posedge clk) begin
		i_data0_reg <= i_data0;
		o_data0 <= o_data0_from_mult;
	end
	multiplier_block mult_blk(
		.i_data0(i_data0_reg),
		.o_data0(o_data0_from_mult)
	);
endmodule
module multiplier_block (
    i_data0,
    o_data0
);
  input   [31:0] i_data0;
  output  [31:0]
    o_data0;
  wire [31:0]
    w1,
    w8192,
    w8191,
    w128,
    w8319,
    w32,
    w8287,
    w16638,
    w24925;
  assign w1 = i_data0;
  assign w128 = w1 << 7;
  assign w16638 = w8319 << 1;
  assign w24925 = w8287 + w16638;
  assign w32 = w1 << 5;
  assign w8191 = w8192 - w1;
  assign w8192 = w1 << 13;
  assign w8287 = w8319 - w32;
  assign w8319 = w8191 + w128;
  assign o_data0 = w24925;
endmodule 
module surround_with_regs(
	i_data0,
	o_data0,
	clk
);
	input   [31:0] i_data0;
	output  [31:0] o_data0;
	reg  [31:0] o_data0;
	input clk;
	reg [31:0] i_data0_reg;
	wire [30:0] o_data0_from_mult;
	always @(posedge clk) begin
		i_data0_reg <= i_data0;
		o_data0 <= o_data0_from_mult;
	end
	multiplier_block mult_blk(
		.i_data0(i_data0_reg),
		.o_data0(o_data0_from_mult)
	);
endmodule
