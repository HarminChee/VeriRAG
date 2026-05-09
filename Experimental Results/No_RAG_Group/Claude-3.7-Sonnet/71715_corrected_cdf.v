`define IDX(x) (((x)+1)*(32)-1):((x)*(32))

module miner130 (clk, reset, test_mode, midstate, data, golden_nonce, nonce2, hash2);

	parameter NONCE_OFFS = 32'd0;
	parameter NONCE_INCR = 32'd1;

	input clk, reset, test_mode;
	input [255:0] midstate;
	input [95:0] data;
	output reg [31:0] golden_nonce, nonce2, hash2;

	reg [31:0] nonce;
	wire [255:0] hash;
	
	reg [7:0] cnt;
	reg feedback;
	reg is_golden_nonce;
	reg feedback_b1, feedback_b2, feedback_b3, feedback_b4, feedback_b5, feedback_b6, reset_b1, reset_b2;

	reg [255:0] state_buf;
	reg [511:0] data_buf;
	
	wire feedback_mux;
	wire [7:0] cnt_next;
	
	assign feedback_mux = test_mode ? 1'b0 : feedback;
	assign cnt_next = (cnt == 8'd129) ? 8'd0 : (cnt + 8'd1);
	
	sha256_pipe129 p (
		.clk(clk),
		.state(state_buf),
		.data(data_buf),
		.hash(hash)
	);

	always @(posedge clk or posedge reset)
	begin
		if (reset) begin
			cnt <= 8'd0;
			feedback <= 1'b0;
			is_golden_nonce <= 1'b0;
			feedback_b1 <= 1'b0;
			feedback_b2 <= 1'b0; 
			feedback_b3 <= 1'b0;
			feedback_b4 <= 1'b0;
			feedback_b5 <= 1'b0;
			feedback_b6 <= 1'b0;
			reset_b1 <= 1'b0;
			reset_b2 <= 1'b0;
			nonce <= NONCE_OFFS;
			golden_nonce <= 32'd0;
			hash2 <= 32'd0;
			nonce2 <= 32'd0;
		end
		else begin
			cnt <= cnt_next;
			feedback <= (cnt == 8'd129) ? ~feedback : feedback;

			if (feedback_b1) begin
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
			end 
			else begin
				data_buf <= {384'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000, nonce, data};
			end

			state_buf <= feedback_b2 ? 256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667 : midstate;

			nonce <= (!feedback_b3) ? (nonce + NONCE_INCR) : nonce;
			golden_nonce <= is_golden_nonce ? nonce2 : golden_nonce;
			hash2 <= (!feedback_b4) ? hash[255:224] : hash2;
			nonce2 <= (!feedback_b5) ? nonce : nonce2;
			is_golden_nonce <= (!feedback_b6) ? (hash[255:224] == 32'ha41f32e7) : is_golden_nonce;
			
			feedback_b1 <= feedback_mux;
			feedback_b2 <= feedback_mux;
			feedback_b3 <= feedback_mux;
			feedback_b4 <= feedback_mux;
			feedback_b5 <= feedback_mux;
			feedback_b6 <= feedback_mux;
			
			reset_b1 <= reset;
			reset_b2 <= reset;
		end
	end

endmodule