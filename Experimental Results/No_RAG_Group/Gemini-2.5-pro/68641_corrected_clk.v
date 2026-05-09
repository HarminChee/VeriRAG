// 1_corrected_clk.v
module jtag_fifo (
	input rx_clk,
	input [11:0] rx_data,
	input wr_en, rd_en,
	// DFT Inputs
	input test_mode, // Scan enable / Test mode select
	input test_clk,  // Test clock input
	input test_rst_n, // Asynchronous test reset (active low)

	output [8:0] tx_data,
	output tx_full, tx_empty
);
	wire jt_capture, jt_drck, jt_reset, jt_sel, jt_shift, jt_tck, jt_tdi, jt_update;
	wire jt_tdo;

	// BSCAN primitive - Assumed handled by DFT tools or specific constraints
	BSCAN_SPARTAN6 # (.JTAG_CHAIN(1)) jtag_blk (
		.CAPTURE(jt_capture),
		.DRCK(jt_drck),
		.RESET(jt_reset), // Functional JTAG reset
		.RUNTEST(),
		.SEL(jt_sel),
		.SHIFT(jt_shift),
		.TCK(jt_tck),     // Functional JTAG clock (output of BSCAN)
		.TDI(jt_tdi),
		.TDO(jt_tdo),
		.TMS(),
		.UPDATE(jt_update)
	);

	reg captured_data_valid = 1'b0;
	reg [12:0] dr;
	wire full;

	// Clock multiplexing for DFT
	wire muxed_tck;
	wire muxed_rx_clk;
	wire effective_reset; // Combined functional and test reset

	// Select functional clock or test clock based on test_mode
	assign muxed_tck = test_mode ? test_clk : jt_tck;
	assign muxed_rx_clk = test_mode ? test_clk : rx_clk;

	// Combine functional reset (jt_reset, posedge sensitive) and test reset (test_rst_n, active low)
	// Prioritize test reset when test_mode is active.
	// Assuming jt_reset is synchronous to jt_tck or handled appropriately for functional mode CDC.
	// For DFT, use the async test_rst_n.
	assign effective_reset = test_mode ? !test_rst_n : jt_reset; // effective_reset is high when reset is active

	// FIFO 1: TCK domain -> RX_CLK domain
	fifo_generator_v8_2 tck_to_rx_clk_blk (
		.wr_clk(muxed_tck),       // Use multiplexed clock
		.rd_clk(muxed_rx_clk),     // Use multiplexed clock
		.din({7'd0, dr[8:0]}),
		.wr_en(jt_update & jt_sel & !full & !test_mode), // Disable functional write in test mode
		.rd_en(rd_en & !tx_empty & !test_mode),         // Disable functional read in test mode
		.dout(tx_data),
		.full(full),
		.empty(tx_empty)
		// Assuming FIFO reset is handled internally or tied to effective_reset if available
	);

	wire [11:0] captured_data;
	wire empty;

	// FIFO 2: RX_CLK domain -> TCK domain
	fifo_generator_v8_2 rx_clk_to_tck_blk (
		.wr_clk(muxed_rx_clk),     // Use multiplexed clock
		.rd_clk(muxed_tck),       // Use multiplexed clock
		.din({4'd0, rx_data}),
		.wr_en(wr_en & !tx_full & !test_mode),           // Disable functional write in test mode
		.rd_en(jt_capture & ~empty & ~jt_reset & !test_mode), // Disable functional read in test mode (using original jt_reset for functional condition)
		.dout(captured_data),
		.full(tx_full),
		.empty(empty)
		// Assuming FIFO reset is handled internally or tied to effective_reset if available
	);

	// TDO Mux
	assign jt_tdo = captured_data_valid ? captured_data[0] : dr[0];

	// JTAG DR logic with DFT modifications
	always @ (posedge muxed_tck or posedge effective_reset) // Clocked by muxed clock, reset by combined reset
	begin
		if (effective_reset == 1'b1) // Reset condition (covers functional and test reset)
		begin
			dr <= 13'd0;
			captured_data_valid <= 1'b0;
		end
		else if (!test_mode) // Functional mode updates
		begin
		    // Note: Scan insertion tools will handle scan shift updates when test_mode=1
			if (jt_capture == 1'b1)
			begin
				captured_data_valid <= !empty;
				dr <= 13'd0; // Load zeros on capture (as per original logic)
			end
			else if (jt_shift == 1'b1 & captured_data_valid) // Shift previously captured data
			begin
				captured_data_valid <= 1'b0; // Only valid for one shift cycle
				dr <= {jt_tdi, 1'b1, captured_data[11:1]}; // Shift in TDI, marker bit, captured data
			end
			else if (jt_shift == 1'b1) // Standard DR shift
			begin
			    // captured_data_valid remains 1'b0
				dr <= {jt_tdi, dr[12:1]}; // Shift in TDI
			end
			// No change if not reset, capture, or shift
		end
		// Else (test_mode == 1'b1): Flip-flop state controlled by scan chain inputs (SI, SE) - Handled by DFT tool
	end

endmodule