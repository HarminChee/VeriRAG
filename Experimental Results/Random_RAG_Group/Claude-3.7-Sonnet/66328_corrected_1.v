module miner130 (clk, reset, test_i, midstate, data, golden_nonce, nonce2, hash2);

	parameter NONCE_OFFS = 32'd0;
	parameter NONCE_INCR = 32'd1;

	input clk, reset, test_i;
	input [255:0] midstate;
	input [95:0] data;
	output reg [31:0] golden_nonce, nonce2, hash2;

	reg [31:0] nonce;
	wire [255:0] hash;
	
	reg [7:0] cnt = 8'd0;
	reg feedback = 1'b0;
	reg is_golden_nonce;
	reg feedback_b1, feedback_b2, feedback_b3, feedback_b4, feedback_b5, feedback_b6;
	wire dft_clk;

	reg [255:0] state_buf;
	reg [511:0] data_buf;
	
	assign dft_clk = test_i ? clk : clk;
	
	sha256_pipe129 p (
		.clk(dft_clk),
		.state(state_buf),
		.data(data_buf),
		.hash(hash)
	);

	always @ (posedge dft_clk)
	begin
		if (!reset)
		begin
			cnt <= 8'd0;
			feedback <= 1'b0;
		end
		else begin
			if ( cnt == 8'd129 )
			begin
				feedback <= ~feedback;
				cnt <= 8'd0;
			end else begin
				cnt <= cnt + 8'd1;
			end
		end
	end

	always @ (posedge dft_clk)
	begin
		if (!reset)
		begin
			data_buf <= 512'd0;
			state_buf <= 256'd0;
			nonce <= NONCE_OFFS;
			golden_nonce <= 32'd0;
			hash2 <= 32'd0;
			nonce2 <= 32'd0;
			is_golden_nonce <= 1'b0;
			feedback_b1 <= 1'b0;
			feedback_b2 <= 1'b0;
			feedback_b3 <= 1'b0;
			feedback_b4 <= 1'b0;
			feedback_b5 <= 1'b0;
			feedback_b6 <= 1'b0;
		end
		else begin
			if ( feedback_b1 ) 
			begin
				data_buf <= { 256'h0000010000000000000000000000000000000000000000000000000080000000, 
							hash[`IDX(7)] + midstate[`IDX(7)], 
							hash[`IDX(6)] + midstate[`IDX(6)], 
							hash[`IDX(5)] + midstate[`IDX(5)], 
							hash[`IDX(4)] + midstate[`IDX(4)], 
							hash[`IDX(3)] + midstate[`IDX(3)], 
							hash[`IDX(2)] + midstate[`IDX(2)], 
							hash[`IDX(1)] + midstate[`IDX(1)], 
							hash[`IDX(0)] + midstate[`IDX(0)]
							};
			end else begin
				data_buf <= {384'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000, nonce, data};
			end

			if ( feedback_b2 ) 
			begin
				state_buf <= 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667;
			end else begin
				state_buf <= midstate;
			end

			if ( ! feedback_b3 ) 
			begin
				nonce <= nonce + NONCE_INCR;
			end

			if ( is_golden_nonce ) 
			begin
				golden_nonce <= nonce2;
			end
			
			if ( ! feedback_b4 ) 
			begin
				hash2 <= hash[255:224];
			end
			
			if ( ! feedback_b5 ) 
			begin
				nonce2 <= nonce;
			end

			if ( ! feedback_b6 ) 
			begin
				is_golden_nonce <= hash[255:224] == 32'ha41f32e7;
			end
			
			feedback_b1 <= feedback;
			feedback_b2 <= feedback;
			feedback_b3 <= feedback;
			feedback_b4 <= feedback;
			feedback_b5 <= feedback;
			feedback_b6 <= feedback;
		end
	end

endmodule