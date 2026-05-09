`default_nettype none
`default_nettype none
module Location(a, b, c, d, e, f, clk_i, rst_n);
	input wire a;
	input wire b;
	output wire c;
	output wire d;
	input wire e;
	output wire f;
	input wire clk_i;
	input wire rst_n;
	wire clk_108hz;
	wire test_clk;
	wire dft_clk;
	assign dft_clk = test_mode ? clk_i : clk_108hz;
	input wire test_mode;
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
		.CLK(dft_clk),
		.RST(~rst_n),
		.OUT(led_lfosc_raw)
	);
	reg led_out = 0;
	assign c = led_out;
	always @(posedge dft_clk or negedge rst_n) begin
		if(!rst_n) begin
			led_out <= 0;
		end
		else if(por_done) begin
			if(led_lfosc_raw)
				led_out <= ~led_out;
		end
	end
	wire d_int = (a & b & e);
	assign d = d_int;
	assign f = ~d_int;
endmodule