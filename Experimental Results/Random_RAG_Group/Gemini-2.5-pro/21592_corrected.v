module fpgaminer_vanitygen_top (
	input clk,
    // DFT Ports
    input test_mode,      // Scan mode enable
    input test_clk,       // Scan clock
    input test_reset_n    // Scan asynchronous reset (active low)
);
	wire mining_clk;
	clk_pll clk_pll_blk (
		.rx_clk (clk),
		.tx_mining_clk (mining_clk)
		// Assuming PLL can be bypassed or controlled during test mode if necessary
	);

    // DFT Clock Selection
    wire dft_clk;
    assign dft_clk = test_mode ? test_clk : mining_clk;

	wire reset; // Original internal reset signal (active high)
	wire [255:0] a, b;
	wire [159:0] vanity_min, vanity_max;

	// Virtual Wires - Clocked by dft_clk
	virtual_wire # (.OUTPUT_WIDTH (256), .INSTANCE_ID ("A")) a_vw (.clk (dft_clk), .rx_input (), .tx_output (a));
	virtual_wire # (.OUTPUT_WIDTH (256), .INSTANCE_ID ("B")) b_vw (.clk (dft_clk), .rx_input (), .tx_output (b));
	virtual_wire # (.OUTPUT_WIDTH (160), .INSTANCE_ID ("MIN")) min_vw (.clk (dft_clk), .rx_input (), .tx_output (vanity_min));
	virtual_wire # (.OUTPUT_WIDTH (160), .INSTANCE_ID ("MAX")) max_vw (.clk (dft_clk), .rx_input (), .tx_output (vanity_max));
	virtual_wire # (.OUTPUT_WIDTH (1), .INSTANCE_ID ("RST")) reset_vw (.clk (dft_clk), .rx_input (), .tx_output (reset)); // Source of ACNCPI

    // DFT Reset Selection (Active Low for unified control)
    wire dft_effective_reset_n;
    assign dft_effective_reset_n = test_mode ? test_reset_n : ~reset; // Combine functional (active high -> active low) and test (active low) resets

	reg adder_reset;
	reg [255:0] x, y;
	reg [63:0] cnt;
	wire adder_done;
	wire [255:0] adder_x, adder_y;

    // DFT Reset for submodules (derive active high signal for modules if needed, or use active low if supported)
    // Assuming submodule reset inputs are active high based on original usage (e.g., adder_reset)
    // adder_reset is handled directly by the FF below.
    wire dft_hash_reset; // Active high reset for hash_blk
    assign dft_hash_reset = test_mode ? ~test_reset_n : adder_done; // Use primary reset in test mode, functional otherwise
    wire dft_vanity_reset; // Active high reset for vanity_compare_blk
    assign dft_vanity_reset = test_mode ? ~test_reset_n : hash_done; // Use primary reset in test mode, functional otherwise


	// Adder Block - Clocked by dft_clk, reset input is the FF 'adder_reset'
	public_key_adder adder_blk (
		.clk (dft_clk),
		.reset (adder_reset), // adder_reset FF itself is reset by dft_effective_reset_n
		.rx_x (x),
		.rx_y (y),
		.tx_done (adder_done),
		.tx_x (adder_x),
		.tx_y (adder_y)
	);

	wire hash_done;
	wire [159:0] hash_hash;

	// Hash Block - Clocked by dft_clk, reset controlled by DFT
	address_hash hash_blk (
		.clk (dft_clk),
		.rx_reset (dft_hash_reset), // Use DFT-controlled reset signal
		.rx_x (adder_x),
		.rx_y (adder_y),
		.tx_done (hash_done),
		.tx_hash (hash_hash)
	);

	wire vanity_match;
	reg old_vanity_match = 1'b0;
	reg [63:0] vanity_matched_cnt = 64'd0;

	// Vanity Compare Block - Clocked by dft_clk, reset controlled by DFT
	vanity_compare vanity_compare_blk (
		.clk (dft_clk),
		.rx_reset (dft_vanity_reset), // Use DFT-controlled reset signal
		.rx_min (vanity_min),
		.rx_max (vanity_max),
		.rx_hash (hash_hash),
		.tx_match (vanity_match)
	);

    // Output Virtual Wires - Clocked by dft_clk
	virtual_wire # (.INPUT_WIDTH (1), .INSTANCE_ID ("DONE")) done_vw (.clk (dft_clk), .rx_input (adder_done), .tx_output ());
	virtual_wire # (.INPUT_WIDTH (256), .INSTANCE_ID ("TXX")) adder_x_vw (.clk (dft_clk), .rx_input (adder_x), .tx_output ());
	virtual_wire # (.INPUT_WIDTH (256), .INSTANCE_ID ("TXY")) adder_y_vw (.clk (dft_clk), .rx_input (adder_y), .tx_output ());
	virtual_wire # (.INPUT_WIDTH (1), .INSTANCE_ID ("HDNE")) hash_done_vw (.clk (dft_clk), .rx_input (hash_done), .tx_output ());
	virtual_wire # (.INPUT_WIDTH (160), .INSTANCE_ID ("HASH")) hash_vw (.clk (dft_clk), .rx_input (hash_hash), .tx_output ());
	virtual_wire # (.INPUT_WIDTH (64), .INSTANCE_ID ("MTCH")) matched_vw (.clk (dft_clk), .rx_input (vanity_matched_cnt), .tx_output ());

    // Main Logic Block - Clocked by dft_clk, Asynchronously Reset by dft_effective_reset_n (active low)
	always @ (posedge dft_clk or negedge dft_effective_reset_n)
	begin
		if (~dft_effective_reset_n) // Asynchronous reset condition (active low)
		begin
            // Reset values for flip-flops to known constants
			cnt <= 64'd0;
			x <= 256'd0;
			y <= 256'd0;
			adder_reset <= 1'b1; // Reset state for adder_reset FF (active high signal for adder_blk)
            old_vanity_match <= 1'b0;
            vanity_matched_cnt <= 64'd0;
		end
		else // Normal clocked operation
		begin
			old_vanity_match <= vanity_match;
            // Default assignment for adder_reset (gets overridden below if adder_done)
			adder_reset <= 1'b0;
			if (adder_done)
			begin
				cnt <= cnt + 64'd1;
				adder_reset <= 1'b1; // Set adder_reset high when adder is done
				x <= adder_x;
				y <= adder_y;
			end

			if (~old_vanity_match && vanity_match)
			begin
				vanity_matched_cnt <= cnt;
			end
            // Original synchronous functional reset logic 'if (reset)' is removed as reset is now asynchronous via dft_effective_reset_n.
		end
	end
endmodule