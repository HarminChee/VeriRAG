`timescale 1ns/1ns
module clocks(
	input CLK_24M,
	input nRESETP,
	output CLK_12M,
	output CLK_68KCLK,
	output CLK_68KCLKB,
	output CLK_6MB,
	output CLK_1MB
);
	reg [2:0] CLK_DIV;
	reg clk_68k_reg;
	reg clk_1m_reg;
	wire CLK_3M;

	// Synchronous clock divider
	always @(posedge CLK_24M or negedge nRESETP) begin
		if (!nRESETP) begin
			clk_68k_reg <= 1'b0;
			CLK_DIV <= 3'b100;
			clk_1m_reg <= 1'b0;
		end else begin
			clk_68k_reg <= ~clk_68k_reg;
			CLK_DIV <= CLK_DIV + 1'b1;
			clk_1m_reg <= ~CLK_3M;
		end
	end

	assign CLK_68KCLK = clk_68k_reg;
	assign CLK_68KCLKB = ~clk_68k_reg;
	assign CLK_12M = CLK_DIV[0];
	assign CLK_6MB = ~CLK_DIV[1];
	assign CLK_3M = CLK_DIV[2];
	assign CLK_1MB = clk_1m_reg;

endmodule