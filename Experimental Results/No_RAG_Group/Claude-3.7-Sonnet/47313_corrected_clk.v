`default_nettype none
module Location(a, b, c, d, e, f, clk_in, rst_n);
	input wire a;
	input wire b;
	output wire c;
	output wire d;
	input wire e;
	output wire f;
	input wire clk_in;
	input wire rst_n;

	localparam COUNT_MAX = 'd31;
	wire led_raw;
	GP_COUNT8 #(
		.RESET_MODE("LEVEL"),
		.COUNT_TO(COUNT_MAX), 
		.CLKIN_DIVIDE(1)
	) lfosc_cnt (
		.CLK(clk_in),
		.RST(~rst_n),
		.OUT(led_raw)
	);

	reg led_out = 0;
	assign c = led_out;

	always @(posedge clk_in) begin
		if(!rst_n) begin
			led_out <= 0;
		end
		else begin
			if(led_raw)
				led_out <= ~led_out;
		end
	end

	wire d_int = (a & b & e);
	assign d = d_int;
	assign f = ~d_int;

endmodule