module jtag_fifo (
	input				test_i, // DFT test mode signal
	input				test_clk, // DFT test clock
	input				test_rst, // DFT test reset (active high)
	input rx_clk,
	input [11:0] rx_data,
	input wr_en, rd_en,
	output [8:0] tx_data,
	output tx_full, tx_empty
);
	wire jt_capture, jt_drck, jt_reset, jt_sel, jt_shift, jt_tck, jt_tdi, jt_update;
	wire jt_tdo;

	// DFT clock and reset muxing
	wire jt_tck_dft;
	wire jt_reset_dft;
	assign jt_tck_dft   = test_i ? test_clk : jt_tck;
	assign jt_reset_dft = test_i ? test_rst : jt_reset; // Assuming test_rst active high matches jt_reset active high

	BSCAN_SPARTAN6 # (.JTAG_CHAIN(1)) jtag_blk (
		.CAPTURE(jt_capture),
		.DRCK(jt_drck),
		.RESET(jt_reset), // Original reset connected to BSCAN
		.RUNTEST(),
		.SEL(jt_sel),
		.SHIFT(jt_shift),
		.TCK(jt_tck),     // Original clock connected to BSCAN
		.TDI(jt_tdi),
		.TDO(jt_tdo),
		.TMS(),
		.UPDATE(jt_update)
	);
	reg captured_data_valid = 1'b0;
	reg [12:0] dr;
	wire full;
	// Assuming FIFOs are treated as black-boxes or bypassed during scan,
	// their clock inputs are not modified here based on test_i.
	// If FIFOs need internal scan, specific vendor DFT wrappers/flows are needed.
	fifo_generator_v8_2 tck_to_rx_clk_blk (
		.wr_clk(jt_tck), // Original clock
		.rd_clk(rx_clk), // Original clock
		.din({7'd0, dr[8:0]}),
		.wr_en(jt_update & jt_sel & !full),
		.rd_en(rd_en & !tx_empty),
		.dout(tx_data),
		.full(full),
		.empty(tx_empty)
	);
	wire [11:0] captured_data;
	wire empty;
	fifo_generator_v8_2 rx_clk_to_tck_blk (
		.wr_clk(rx_clk), // Original clock
		.rd_clk(jt_tck), // Original clock
		.din({4'd0, rx_data}),
		.wr_en(wr_en & !tx_full),
		.rd_en(jt_capture & ~empty & ~jt_reset), // Uses original jt_reset for FIFO read enable logic
		.dout(captured_data),
		.full(tx_full),
		.empty(empty)
	);
	assign jt_tdo = captured_data_valid ? captured_data[0] : dr[0];

	// Always block modified to use DFT clock and reset
	always @ (posedge jt_tck_dft or posedge jt_reset_dft)
	begin
		if (jt_reset_dft == 1'b1) // Use muxed DFT reset
		begin
			dr <= 13'd0;
			captured_data_valid <= 1'b0; // Ensure reset state
		end
		// Using original JTAG control signals for functional behavior
		else if (jt_capture == 1'b1)
		begin
			captured_data_valid <= !empty;
			dr <= 13'd0; // Load dr on capture (as per original logic seems to imply)
		end
		else if (jt_shift == 1'b1 & captured_data_valid)
		begin
			captured_data_valid <= 1'b0; // Cleared after first shift
			dr <= {jt_tdi, 1'b1, captured_data[11:1]}; // Shift in TDI, marker bit, and captured data
		end
		else if (jt_shift == 1'b1) // Shift when captured_data_valid is low
		begin
			dr <= {jt_tdi, dr[12:1]}; // Standard shift operation
		end
		// No change if not reset, capture, or shift
	end
endmodule