module fpgaminer_vanitygen_top (
	input clk,
	input test_i // Added test mode input
);
	wire mining_clk;
	wire dft_mining_clk; // Added DFT clock wire

	// DFT Clock Mux: Select primary clock 'clk' in test mode, 'mining_clk' otherwise
	assign dft_mining_clk = test_i ? clk : mining_clk;

	clk_pll clk_pll_blk (
		.rx_clk (clk),
		.tx_mining_clk (mining_clk)
	);
	wire reset;
	wire [255:0] a, b;
	wire [159:0] vanity_min, vanity_max;
	// Use dft_mining_clk for virtual_wire instances
	virtual_wire # (.OUTPUT_WIDTH (256), .INSTANCE_ID ("A")) a_vw (.clk (dft_mining_clk), .rx_input (), .tx_output (a));
	virtual_wire # (.OUTPUT_WIDTH (256), .INSTANCE_ID ("B")) b_vw (.clk (dft_mining_clk), .rx_input (), .tx_output (b));
	virtual_wire # (.OUTPUT_WIDTH (160), .INSTANCE_ID ("MIN")) min_vw (.clk (dft_mining_clk), .rx_input (), .tx_output (vanity_min));
	virtual_wire # (.OUTPUT_WIDTH (160), .INSTANCE_ID ("MAX")) max_vw (.clk (dft_mining_clk), .rx_input (), .tx_output (vanity_max));
	virtual_wire # (.OUTPUT_WIDTH (1), .INSTANCE_ID ("RST")) reset_vw (.clk (dft_mining_clk), .rx_input (), .tx_output (reset));
	reg adder_reset;
	reg [255:0] x, y;
	reg [63:0] cnt;
	wire adder_done;
	wire [255:0] adder_x, adder_y;
	// Use dft_mining_clk for public_key_adder instance
	public_key_adder adder_blk (
		.clk (dft_mining_clk),
		.reset (adder_reset),
		.rx_x (x),
		.rx_y (y),
		.tx_done (adder_done),
		.tx_x (adder_x),
		.tx_y (adder_y)
	);
	wire hash_done;
	wire [159:0] hash_hash;
	// Use dft_mining_clk for address_hash instance
	address_hash hash_blk (
		.clk (dft_mining_clk),
		.rx_reset (adder_done),
		.rx_x (adder_x),
		.rx_y (adder_y),
		.tx_done (hash_done),
		.tx_hash (hash_hash)
	);
	wire vanity_match;
	reg old_vanity_match = 1'b0;
	reg [63:0] vanity_matched_cnt = 64'd0;
	// Use dft_mining_clk for vanity_compare instance
	vanity_compare vanity_compare_blk (
		.clk (dft_mining_clk),
		.rx_reset (hash_done),
		.rx_min (vanity_min),
		.rx_max (vanity_max),
		.rx_hash (hash_hash),
		.tx_match (vanity_match)
	);
	// Use dft_mining_clk for virtual_wire instances
	virtual_wire # (.INPUT_WIDTH (1), .INSTANCE_ID ("DONE")) done_vw (.clk (dft_mining_clk), .rx_input (adder_done), .tx_output ());
	virtual_wire # (.INPUT_WIDTH (256), .INSTANCE_ID ("TXX")) adder_x_vw (.clk (dft_mining_clk), .rx_input (adder_x), .tx_output ());
	virtual_wire # (.INPUT_WIDTH (256), .INSTANCE_ID ("TXY")) adder_y_vw (.clk (dft_mining_clk), .rx_input (adder_y), .tx_output ());
	virtual_wire # (.INPUT_WIDTH (1), .INSTANCE_ID ("HDNE")) hash_done_vw (.clk (dft_mining_clk), .rx_input (hash_done), .tx_output ());
	virtual_wire # (.INPUT_WIDTH (160), .INSTANCE_ID ("HASH")) hash_vw (.clk (dft_mining_clk), .rx_input (hash_hash), .tx_output ());
	virtual_wire # (.INPUT_WIDTH (64), .INSTANCE_ID ("MTCH")) matched_vw (.clk (dft_mining_clk), .rx_input (vanity_matched_cnt), .tx_output ());

	// Use dft_mining_clk for the always block
	always @ (posedge dft_mining_clk)
	begin
		old_vanity_match <= vanity_match;
		adder_reset <= 1'b0;
		if (adder_done && !adder_reset)
		begin
			cnt <= cnt + 64'd1;
			adder_reset <= 1'b1;
			x <= adder_x;
			y <= adder_y;
		end
		if (~old_vanity_match && vanity_match)
		begin
			vanity_matched_cnt <= cnt;
		end
		if (reset)
		begin
			cnt <= 64'd0;
			x <= a;
			y <= b;
			adder_reset <= 1'b1;
		end
	end
endmodule