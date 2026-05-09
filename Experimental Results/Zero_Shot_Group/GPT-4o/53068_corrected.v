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
	reg[7:0] count = 8'd15; // Initialize with decimal 15
	always @(posedge clk_108hz or posedge clear) begin
		if (clear)
			count <= 8'd15; // Reset count to 15 when clear is high
		else begin
			count <= count - 1'h1;
			if(count == 0)
				count <= 8'd15; // Reload count with 15
		end
	end
	assign underflow = (count == 0);
endmodule