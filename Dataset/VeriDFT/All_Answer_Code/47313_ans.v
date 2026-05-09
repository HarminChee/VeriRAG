`default_nettype none
`default_nettype none
module Location(test_i,scan_clk,a, b, c, d, e, f);
	input wire a;
	input wire b;
	output wire c;
	output wire d;
	input wire e;
	output wire f;
	input scan_clk;
	input test_i;
	wire clk_108hz;
	wire clk_108hz_dft;
	assign clk_108hz_dft = test_i ? scan_clk : clk_108hz ;
	GP_LFOSC #(
		.PWRDN_EN(1),
		.AUTO_PWRDN(0),
		.OUT_DIV(16)
	) lfosc (
		.PWRDN(1'b0),
		.CLKOUT(clk_108hz)
	);
	wire por_done;
	GP_POR #(
		.POR_TIME(500)
	) por (
		.RST_DONE(por_done)
	);
	localparam COUNT_MAX = 'd31;
	wire led_lfosc_raw;
	GP_COUNT8 #(
		.RESET_MODE("LEVEL"),
		.COUNT_TO(COUNT_MAX),
		.CLKIN_DIVIDE(1)
	) lfosc_cnt (
		.CLK(clk_108hz),
		.RST(1'b0),
		.OUT(led_lfosc_raw)
	);
	reg led_out = 0;
	assign c = led_out;
	always @(posedge clk_108hz_dft) begin
		if(por_done) begin
			if(led_lfosc_raw)
				led_out <= ~led_out;
		end
	end
	wire d_int = (a & b & e);
	assign d = d_int;
	assign f = ~d_int;
endmodule
