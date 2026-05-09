`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module delay_in
(
	input csi_clock_clk,
	input csi_clock_reset,
	input avs_ctrl_write,
	input [31:0]avs_ctrl_writedata,
	input sync,
	input clk400,
	input sig_in,
	output reg sig_out40,
	output sig_out80
);
	wire clk80 = csi_clock_clk;
	wire reset = csi_clock_reset;
	reg [5:0]delay;
	always @(posedge clk80 or posedge reset)
	begin
		if (reset) delay <= 0;
		else if (avs_ctrl_write) delay <= avs_ctrl_writedata[5:0];
	end
	wire [5:0]delout;
	delay_ddrin half_stage
	(
		.clk(clk400),
		.reset(reset),
		.select(delay[0]),
		.in(sig_in),
		.out(delout[0])
	);
	delay_in_stage d1(clk400, reset, delay[1], delout[0], delout[1]);
	delay_in_stage d2(clk400, reset, delay[2], delout[1], delout[2]);
	delay_in_stage d3(clk400, reset, delay[3], delout[2], delout[3]);
	delay_in_stage d4(clk400, reset, delay[4], delout[3], delout[4]);
	reg ccreg;
	always @(posedge clk80 or posedge reset)
	begin
		if (reset) ccreg <= 0;
		else ccreg <= delout[4];
	end
	delay_in_stage d5(clk80, reset, delay[5], ccreg, delout[5]);
	assign sig_out80 = delout[5];
	always @(posedge clk80 or posedge reset)
	begin
		if (reset) sig_out40 <= 0;
		else if (sync) sig_out40 <= delout[5];
	end
endmodule
