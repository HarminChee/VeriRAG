`timescale 1ns/1ns
module ym2i2s(
	input nRESET,
	input CLK_I2S,
	input [5:0] ANA,
	input SH1, SH2, OP0, PHI_M,
	output I2S_MCLK,
	output I2S_BICK,
	output I2S_SDTI,
	output I2S_LRCK
);

	reg [23:0] I2S_SR;
	reg [3:0] SR_CNT;
	reg [7:0] CLKDIV;
	wire [23:0] I2S_SAMPLE;

	assign I2S_SAMPLE = {18'b000000000000000000, ANA};
	assign I2S_MCLK = CLK_I2S;
	assign I2S_LRCK = CLKDIV[7];
	assign I2S_BICK = CLKDIV[4];
	assign I2S_SDTI = I2S_SR[23];

	always @(posedge I2S_BICK)
	begin
		if (!nRESET)
			SR_CNT <= 4'b0;
		else
		begin
			if (SR_CNT == 4'b0)
			begin
				I2S_SR <= I2S_SAMPLE;
				SR_CNT <= SR_CNT + 4'b1;
			end
			else if (SR_CNT < 24)
			begin
				I2S_SR <= {I2S_SR[22:0], 1'b0};
				SR_CNT <= SR_CNT + 4'b1;
			end
			else
				SR_CNT <= 4'b0;
		end
	end

	always @(posedge CLK_I2S)
	begin
		if (!nRESET)
			CLKDIV <= 8'b0;
		else
			CLKDIV <= CLKDIV + 8'b1;
	end

endmodule