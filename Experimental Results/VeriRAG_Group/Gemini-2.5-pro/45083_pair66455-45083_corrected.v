`default_nettype none
`default_nettype none
module Dac(
	input wire test_mode_i, // DFT control signal
	input wire test_clk_i,  // DFT test clock input
	output wire bg_ok,
	output wire vout,
	output wire vout2,
	output wire wave_sync);
	wire por_done;
	GP_POR #(
		.POR_TIME(500)
	) por (
		.RST_DONE(por_done)
	);
	wire clk_1730hz;
	GP_LFOSC #(
		.PWRDN_EN(0),
		.AUTO_PWRDN(0),
		.OUT_DIV(1)
	) lfosc (
		.PWRDN(1'b0),
		.CLKOUT(clk_1730hz)
	);
	GP_BANDGAP #(
		.AUTO_PWRDN(0),
		.CHOPPER_EN(1),
		.OUT_DELAY(550)
	) bandgap (
		.OK(bg_ok)
	);
	wire vref_1v0;
	GP_VREF #(
		.VIN_DIV(4'd1),
		.VREF(16'd1000)
	) vr1000 (
		.VIN(1'b0),
		.VOUT(vref_1v0)
	);
	localparam COUNT_MAX = 255;
	reg[7:0] count = COUNT_MAX;

	wire dft_clk; // Muxed clock for DFT
	assign dft_clk = test_mode_i ? test_clk_i : clk_1730hz; // Select test clock in test mode

	always @(posedge dft_clk) begin // Use muxed clock
		if(count == 0)
			count <= COUNT_MAX;
		else
			count <= count - 1'd1;
	end
	assign wave_sync = (count == 0);
	GP_DAC dac(
		.DIN(count),
		.VOUT(vout),
		.VREF(vref_1v0)
	);
	wire vdac2;
	GP_DAC dac2(
		.DIN(8'hff),
		.VOUT(vdac2),
		.VREF(vref_1v0)
	);
	GP_VREF #(
		.VIN_DIV(4'd1),
		.VREF(16'd00)
	) vrdac (
		.VIN(vdac2),
		.VOUT(vout2)
	);
endmodule