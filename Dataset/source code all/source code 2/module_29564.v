module ff_mul (
	input clk,
	input reset,
	input [255:0] rx_a,
	input [255:0] rx_b,
	output tx_done,
	output [255:0] tx_c
);
	wire mul_done;
	wire [511:0] mul_result;
	bn_mul uut (
		.clk (clk),
		.reset (reset),
		.rx_a (rx_a),
		.rx_b (rx_b),
		.tx_done (mul_done),
		.tx_r (mul_result)
	);
	reg reduce_reset = 1'b1;
	ff_reduce_secp256k1 uut2 (
		.clk (clk),
		.reset (reset | reduce_reset),
		.rx_a (mul_result),
		.tx_done (tx_done),
		.tx_a (tx_c)
	);
	always @ (posedge clk)
	begin
		if (reset)
			reduce_reset <= 1'b1;
		else if (mul_done)
			reduce_reset <= 1'b0;
	end
endmodule
