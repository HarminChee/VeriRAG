`default_nettype none
`default_nettype none
module RedundantFF(clear, scan_clk,test_i,underflow);
	input wire clear,scan_clk,test_i;
	output wire underflow;
	wire dft_clk_108hz,clk_108hz;
	GP_LFOSC #(
		.PWRDN_EN(0),
		.AUTO_PWRDN(0),
		.OUT_DIV(16)
	) lfosc (
		.PWRDN(1'b0),
		.CLKOUT(clk_108hz)
	);
	reg[7:0] count = 15;
	assign dft_clk_108hz = test_i ? scan_clk : clk_108hz ;
	always @(posedge dft_clk_108hz) begin
		count <= count - 1'h1;
		if(count == 0)
			count <= 15;
	end
	assign underflow = (count == 0);
endmodule
