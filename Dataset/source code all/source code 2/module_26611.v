module public_key_adder (
	input clk,
	input reset,
	input [255:0] rx_x,
	input [255:0] rx_y,
	output reg tx_done = 1'b0,
	output reg [255:0] tx_x,
	output reg [255:0] tx_y
);
	wire [255:0] G_x = 256'h79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
	wire [255:0] G_y = 256'h483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
	wire [255:0] p = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
	reg [3:0] state;
	reg sub_reset, inv_reset, mul_reset;
	reg [255:0] slope;
	reg [255:0] sub_a, sub_b, mul_a, mul_b;
	wire sub_done, inv_done, mul_done;
	wire [255:0] sub_result, inv_result, mul_result;
	ff_sub sub_blk (
		.clk (clk),
		.reset (sub_reset),
		.rx_a (sub_a),
		.rx_b (sub_b),
		.rx_p (p),
		.tx_done (sub_done),
		.tx_a (sub_result)
	);
	ff_inv inv_blk (
		.clk (clk),
		.reset (inv_reset),
		.rx_a (sub_result),
		.rx_p (p),
		.tx_done (inv_done),
		.tx_a (inv_result)
	);
	ff_mul mul_blk (
		.clk (clk),
		.reset (mul_reset),
		.rx_a (mul_a),
		.rx_b (mul_b),
		.tx_done (mul_done),
		.tx_c (mul_result)
	);
	always @ (*)
	begin
		sub_reset = 1'b0;
		inv_reset = 1'b0;
		mul_reset = 1'b0;
		sub_a = G_x;
		sub_b = rx_x;
		mul_a = sub_result;
		mul_b = inv_result;
		if (reset)
		begin
			sub_reset = 1'b1;
			sub_a = G_x;
			sub_b = rx_x;
		end
		else if (state == 0)
		begin
			sub_reset = 1'b0;
			sub_a = G_x;
			sub_b = rx_x;
			if (sub_done)
			begin
				inv_reset = 1'b1;
				sub_reset = 1'b1;
				sub_a = G_y;
				sub_b = rx_y;
			end
		end
		else if (state == 1)
		begin
			inv_reset = 1'b0;
			sub_reset = 1'b0;
			sub_a = G_y;
			sub_b = rx_y;
			if (sub_done && inv_done)
			begin
				mul_reset = 1'b1;
				mul_a = sub_result;
				mul_b = inv_result;
			end
		end
		else if (state == 2)
		begin
			mul_reset = 1'b0;
			mul_a = sub_result;
			mul_b = inv_result;
			if (mul_done)
			begin
				mul_reset = 1'b1;
				mul_a = mul_result;
				mul_b = mul_result;
			end
		end
		else if (state == 3)
		begin
			mul_reset = 1'b0;
			mul_a = mul_result;
			mul_b = mul_result;
			if (mul_done)
			begin
				sub_reset = 1'b1;
				sub_a = mul_result;
				sub_b = rx_x;
			end
		end
		else if (state == 4)
		begin
			sub_reset = 1'b0;
			sub_a = mul_result;
			sub_b = rx_x;
			if (sub_done)
			begin
				sub_reset = 1'b1;
				sub_a = sub_result;
				sub_b = G_x;
			end
		end
		else if (state == 5)
		begin
			sub_reset = 1'b0;
			sub_a = sub_result;
			sub_b = G_x;
			if (sub_done)
			begin
				sub_reset = 1'b1;
				sub_a = rx_x;
				sub_b = sub_result;
			end
		end
		else if (state == 6)
		begin
			sub_reset = 1'b0;
			sub_a = rx_x;
			sub_b = sub_result;
			if (sub_done)
			begin
				mul_reset = 1'b1;
				mul_a = sub_result;
				mul_b = slope;
			end
		end
		else if (state == 7)
		begin
			mul_reset = 1'b0;
			mul_a = sub_result;
			mul_b = slope;
			if (mul_done)
			begin
				sub_reset = 1'b1;
				sub_a = mul_result;
				sub_b = rx_y;
			end
		end
		else if (state == 8)
		begin
			sub_reset = 1'b0;
			sub_a = mul_result;
			sub_b = rx_y;
		end
	end
	always @ (posedge clk)
	begin
		if (state == 0 && sub_done)
			state <= 1;
		if (state == 1 && sub_done && inv_done)
			state <= 2;
		if (state == 2 && mul_done)
		begin
			state <= 3;
			slope <= mul_result;
		end
		if (state == 3 && mul_done)
			state <= 4;
		if (state == 4 && sub_done)
			state <= 5;
		if (state == 5 && sub_done)
		begin
			state <= 6;
			tx_x <= sub_result;
		end
		if (state == 6 && sub_done)
			state <= 7;
		if (state == 7 && mul_done)
			state <= 8;
		if (state == 8 && sub_done && !tx_done)
		begin
			tx_done <= 1'b1;
			tx_y <= sub_result;
		end
		if (reset)
		begin
			state <= 0;
			tx_done <= 1'b0;
		end
	end
endmodule
