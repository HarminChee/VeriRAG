module jtag_fifo (
	input test_mode, test_clk, test_rst, // DFT inputs
	input rx_clk,
	input [11:0] rx_data,
	input wr_en, rd_en,
	output [8:0] tx_data,
	output tx_full, tx_empty
);
	wire jt_capture, jt_drck, jt_reset, jt_sel, jt_shift, jt_tck, jt_tdi, jt_update;
	wire jt_tdo;

	// DFT Muxing for clock and reset
	wire dft_jt_tck;
	wire dft_jt_reset;
	assign dft_jt_tck = test_mode ? test_clk : jt_tck;
	assign dft_jt_reset = test_mode ? test_rst : jt_reset;


	BSCAN_SPARTAN6 # (.JTAG_CHAIN(1)) jtag_blk (
		.CAPTURE(jt_capture),
		.DRCK(jt_drck),
		.RESET(jt_reset), // Original reset source
		.RUNTEST(),
		.SEL(jt_sel),
		.SHIFT(jt_shift),
		.TCK(jt_tck),     // Original clock source
		.TDI(jt_tdi),
		.TDO(jt_tdo),
		.TMS(),
		.UPDATE(jt_update)
	);
	reg captured_data_valid = 1'b0;
	reg [12:0] dr;
	wire full;
	fifo_generator_v8_2 tck_to_rx_clk_blk (
		.wr_clk(dft_jt_tck), // Use muxed clock
		.rd_clk(rx_clk),
		.din({7'd0, dr[8:0]}),
		.wr_en(jt_update & jt_sel & !full),
		.rd_en(rd_en & !tx_empty),
		.dout(tx_data),
		.full(full),
		.empty(tx_empty)
		// Assuming FIFO reset is handled internally or tied appropriately
	);
	wire [11:0] captured_data;
	wire empty;
	fifo_generator_v8_2 rx_clk_to_tck_blk (
		.wr_clk(rx_clk),
		.rd_clk(dft_jt_tck), // Use muxed clock
		.din({4'd0, rx_data}),
		.wr_en(wr_en & !tx_full),
		.rd_en(jt_capture & ~empty & ~dft_jt_reset), // Use muxed reset for read enable logic check
		.dout(captured_data),
		.full(tx_full),
		.empty(empty)
		// Assuming FIFO reset is handled internally or tied appropriately
	);
	assign jt_tdo = captured_data_valid ? captured_data[0] : dr[0];

	// Use muxed clock and reset for the sequential logic
	always @ (posedge dft_jt_tck or posedge dft_jt_reset)
	begin
		if (dft_jt_reset == 1'b1)
		begin
			dr <= 13'd0;
			captured_data_valid <= 1'b0; // Reset this state as well
		end
		// Note: Original code didn't reset captured_data_valid on jt_reset, added here for robustness
		else if (jt_capture == 1'b1) // Capture logic depends on original JTAG signals
		begin
			captured_data_valid <= !empty;
			dr <= 13'd0;
		end
		else if (jt_shift == 1'b1 & captured_data_valid) // Shift logic depends on original JTAG signals
		begin
			captured_data_valid <= 1'b0;
			dr <= {jt_tdi, 1'b1, captured_data[11:1]};
		end
		else if (jt_shift == 1'b1) // Shift logic depends on original JTAG signals
		begin
			dr <= {jt_tdi, dr[12:1]};
		end
	end
endmodule