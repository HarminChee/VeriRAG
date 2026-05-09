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
    w4096,
    w4097,
    w16384,
    w20481,
    w1024,
    w21505,
    w32,
    w21473,
    w2,
    w21475;
  assign w1 = i_data0;
  assign w1024 = w1 << 10;
  assign w16384 = w1 << 14;
  assign w2 = w1 << 1;
  assign w20481 = w4097 + w16384;
  assign w21473 = w21505 - w32;
  assign w21475 = w21473 + w2;
  assign w21505 = w20481 + w1024;
  assign w32 = w1 << 5;
  assign w4096 = w1 << 12;
  assign w4097 = w1 + w4096;
  assign o_data0 = w21475;
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
