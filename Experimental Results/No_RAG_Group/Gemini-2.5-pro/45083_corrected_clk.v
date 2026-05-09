`default_nettype none
module Dac(
    // Add primary clock and reset inputs for DFT
    input wire clk,
    input wire rst_n,
    // Original outputs
	output wire bg_ok,
	output wire vout,
	output wire vout2,
	output wire wave_sync
);

	wire por_done;
	GP_POR #(
		.POR_TIME(500)
	) por (
		.RST_DONE(por_done) // This POR reset might be used functionally, but rst_n is the primary DFT reset
	);

    // Internal oscillator remains, but its output clk_1730hz should not clock scannable FFs
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
	reg[7:0] count; // Register to be made scannable

    // Modified counter: Clocked by primary input 'clk', Reset by primary input 'rst_n'
    // This ensures the flip-flops for 'count' are controllable via the scan chain clock.
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin // Use asynchronous reset for DFT friendliness
			count <= COUNT_MAX;
		end else begin
            // Functional logic remains similar, but timing is now based on 'clk'
			if(count == 0)
				count <= COUNT_MAX;
			else
				count <= count - 1'd1;
		end
	end

    // wave_sync generation logic remains, but its timing now depends on 'clk' frequency
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
`default_nettype wire // Reset default_nettype if needed at the end