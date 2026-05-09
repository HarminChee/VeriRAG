`timescale 1ns/1ns
`timescale 1ns/1ns
module ym2i2s(
    input test_i,
	input nRESET,
	input CLK_I2S,
	input [5:0] ANA,
	input SH1, SH2, OP0, PHI_M,
	output I2S_MCLK, I2S_BICK, I2S_SDTI, I2S_LRCK
);
	wire [23:0] I2S_SAMPLE;
	reg [23:0] I2S_SR;
	reg [3:0] SR_CNT;
	reg [7:0] CLKDIV;
	wire dft_bick;

	assign dft_bick = test_i ? CLK_I2S : I2S_BICK;
	assign I2S_SAMPLE = {18'b0, ANA};
	assign I2S_MCLK = CLK_I2S;
	assign I2S_LRCK = CLKDIV[7];
	assign I2S_BICK = CLKDIV[4];
	assign I2S_SDTI = I2S_SR[23];

	always @(posedge dft_bick)
	begin
		if (!nRESET)
			SR_CNT <= 0;
		else
		begin
			if (SR_CNT == 0)
				I2S_SR <= I2S_SAMPLE;
			else
				I2S_SR <= {I2S_SR[22:0], 1'b0};
			SR_CNT <= SR_CNT + 1'b1;
		end
	end

	always @(posedge I2S_MCLK)
	begin
		CLKDIV <= CLKDIV + 1'b1;
	end
endmodule