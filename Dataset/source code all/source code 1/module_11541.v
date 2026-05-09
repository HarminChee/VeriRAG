`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module pll_adv_example (
	input clk,
	input RST,
	output [7:0] led);
    reg [6:0] DADDR;
    reg [15:0] DI;
    wire [15:0] DO;
    reg DEN;
    reg DWE;
    wire DRDY;
	wire CLKFB;
	PLLE2_ADV #(
		.CLKFBOUT_MULT(8),
		.CLKFBOUT_PHASE(90.0),
		.CLKIN1_PERIOD(10.0),
		.CLKIN2_PERIOD(10.0),
		.CLKOUT0_DIVIDE(128),
		.CLKOUT1_DIVIDE(2),
		.CLKOUT2_DIVIDE(32),
		.CLKOUT3_DIVIDE(16),
		.CLKOUT4_DIVIDE(128),
		.CLKOUT5_DIVIDE(128),
		.CLKOUT0_DUTY_CYCLE(0.5),
		.CLKOUT1_DUTY_CYCLE(0.5),
		.CLKOUT2_DUTY_CYCLE(0.5),
		.CLKOUT3_DUTY_CYCLE(0.5),
		.CLKOUT4_DUTY_CYCLE(0.9),
		.CLKOUT5_DUTY_CYCLE(0.1),
		.CLKOUT0_PHASE(0.0),
		.CLKOUT1_PHASE(0.0),
		.CLKOUT2_PHASE(0.0),
		.CLKOUT3_PHASE(0.0),
		.CLKOUT4_PHASE(0.0),
		.CLKOUT5_PHASE(0.0),
		.DIVCLK_DIVIDE(1))
 	pll (
		.CLKOUT0(led[0]),
		.CLKOUT1(led[1]),
		.CLKOUT2(led[2]),
		.CLKOUT3(led[3]),
		.CLKOUT4(led[5]),
		.CLKOUT5(led[6]),
		.CLKFBOUT(CLKFB),
		.LOCKED(led[7]),
		.CLKIN1(clk),
		.CLKIN2(clk),
		.CLKINSEL(1'b1),
		.DADDR(DADDR),
		.DI(DI),
		.DO(DO),
		.DWE(DWE),
		.DEN(DEN),
		.DRDY(DRDY),
		.DCLK(led[0]),
		.PWRDWN(0),
		.RST(RST),
		.CLKFBIN(CLKFB));
	integer step = 0;
	always @(posedge clk) begin
		if (led[7] && DRDY && step == 0) begin
			DADDR <= 7'h0A;
			DI = 16'b011_0_010000_100000;
			DEN <= 1;
			DWE <= 1;
			step <= 1;
		end else if (led[7] && step == 1) begin
			DEN <= 0;
			DWE <= 0;
			step <= 2;
		end else if (led[7] && DRDY && step == 2) begin
			DEN <= 1;
			DWE <= 1;
			DADDR = 7'h0B;
			DI <= 16'b000000_00_0_0_000011;
			step <= 3;
		end else if (led[7] && step == 3) begin
			DEN <= 0;
			DWE <= 0;
			step <= 4;
		end
	end
endmodule
