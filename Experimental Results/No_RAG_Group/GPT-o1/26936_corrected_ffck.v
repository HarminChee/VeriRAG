`timescale 1ns/1ns
module ym2i2s_corrected_ffc(
	input nRESET,
	input CLK_I2S,
	input [5:0] ANA,
	input SH1, SH2, OP0, PHI_M,
	output I2S_MCLK,
	output I2S_BICK,
	output I2S_SDTI,
	output I2S_LRCK
);
	wire [23:0] I2S_SAMPLE;
	reg [23:0] I2S_SR;
	reg [3:0] SR_CNT;
	reg [7:0] CLKDIV;
	reg I2S_BICK_d;

	assign I2S_SAMPLE = {18'b000000000000000000, ANA};
	assign I2S_MCLK   = CLK_I2S;
	assign I2S_LRCK   = CLKDIV[7];
	assign I2S_BICK   = CLKDIV[4];
	assign I2S_SDTI   = I2S_SR[23];

	always @(posedge CLK_I2S or negedge nRESET)
	begin
		if(!nRESET)
		begin
			SR_CNT      <= 4'b0;
			I2S_SR      <= 24'b0;
			I2S_BICK_d  <= 1'b0;
		end
		else
		begin
			I2S_BICK_d <= I2S_BICK;
			if(I2S_BICK_d & ~I2S_BICK)
			begin
				if(!SR_CNT)
					I2S_SR <= I2S_SAMPLE;
				else
					I2S_SR <= {I2S_SR[22:0], 1'b0};
				SR_CNT <= SR_CNT + 1'b1;
			end
		end
	end

	always @(posedge CLK_I2S or negedge nRESET)
	begin
		if(!nRESET)
			CLKDIV <= 8'b0;
		else
			CLKDIV <= CLKDIV + 1'b1;
	end
endmodule