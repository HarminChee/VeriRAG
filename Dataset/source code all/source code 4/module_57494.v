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
    w1024,
    w1023,
    w2048,
    w3071,
    w32,
    w33,
    w132,
    w2939,
    w23512;
  assign w1 = i_data0;
  assign w1023 = w1024 - w1;
  assign w1024 = w1 << 10;
  assign w132 = w33 << 2;
  assign w2048 = w1 << 11;
  assign w23512 = w2939 << 3;
  assign w2939 = w3071 - w132;
  assign w3071 = w1023 + w2048;
  assign w32 = w1 << 5;
  assign w33 = w1 + w32;
  assign o_data0 = w23512;
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
