`default_nettype none
`default_nettype none
module RedundantFF(clear, underflow);
	input wire clear;
	output wire underflow;
	wire clk_108hz;
	GP_LFOSC #(
		.PWRDN_EN(0),
		.AUTO_PWRDN(0),
		.OUT_DIV(16)
	) lfosc (
		.PWRDN(1'b0),
		.CLKOUT(clk_108hz)
	);
	reg[7:0] count = 15;
	always @(posedge clk_108hz) begin
		count <= count - 1'h1;
		if(count == 0)
			count <= 15;
	end
	assign underflow = (count == 0);
endmodule
