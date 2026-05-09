module jtag_fifo (
	input test_i,            // DFT test mode input
	input test_rst_n_i,      // DFT test reset input (active low)
	input rx_clk,
	input [11:0] rx_data,
	input wr_en, rd_en,
	output [8:0] tx_data,
	output tx_full, tx_empty
);
	wire jt_capture, jt_drck, jt_reset, jt_sel, jt_shift, jt_tck, jt_tdi, jt_update;
	wire jt_tdo;

	// DFT Muxed signals
	wire dft_jt_tck;
	wire dft_jt_reset; // Active high reset for the always block

	assign dft_jt_tck = test_i ? rx_clk : jt_tck;
	assign dft_jt_reset = test_i ? ~test_rst_n_i : jt_reset;

	BSCAN_SPARTAN6 # (.JTAG_CHAIN(1)) jtag_blk (
		.CAPTURE(jt_capture),
		.DRCK(jt_drck),
		.RESET(jt_reset), // Functional reset from JTAG
		.RUNTEST(),
		.SEL(jt_sel),
		.SHIFT(jt_shift),
		.TCK(jt_tck),     // Functional clock from JTAG
		.TDI(jt_tdi),
		.TDO(jt_tdo),
		.TMS(),
		.UPDATE(jt_update)
	);

	reg captured_data_valid = 1'b0;
	reg [12:0] dr;
	wire full;

	// FIFO instance 1: Use DFT clock for write side
	fifo_generator_v8_2 tck_to_rx_clk_blk (
		.wr_clk(dft_jt_tck), // Use muxed clock
		.rd_clk(rx_clk),     // Primary input clock (OK)
		.din({7'd0, dr[8:0]}),
		.wr_en(jt_update & jt_sel & !full), // Functional enables
		.rd_en(rd_en & !tx_empty),
		.dout(tx_data),
		.full(full),
		.empty(tx_empty)
		// Assuming FIFO reset is handled internally or tied off if not present
	);

	wire [11:0] captured_data;
	wire empty;

	// FIFO instance 2: Use DFT clock for read side
	fifo_generator_v8_2 rx_clk_to_tck_blk (
		.wr_clk(rx_clk),     // Primary input clock (OK)
		.rd_clk(dft_jt_tck), // Use muxed clock
		.din({4'd0, rx_data}),
		.wr_en(wr_en & !tx_full), // Functional enables
		.rd_en(jt_capture & ~empty & ~jt_reset), // Functional enables/conditions
		.dout(captured_data),
		.full(tx_full),
		.empty(empty)
		// Assuming FIFO reset is handled internally or tied off if not present
	);

	assign jt_tdo = captured_data_valid ? captured_data[0] : dr[0];

	// Flip-flops clocked by muxed clock and reset by muxed reset
	always @ (posedge dft_jt_tck or posedge dft_jt_reset)
	begin
		if (dft_jt_reset == 1'b1) // Use muxed reset (active high)
		begin
			dr <= 13'd0;
			captured_data_valid <= 1'b0; // Reset this FF as well
		end
		else // Clocked logic using functional JTAG control signals
		begin
			if (jt_capture == 1'b1)
			begin
				captured_data_valid <= !empty;
				dr <= 13'd0;
			end
			else if (jt_shift == 1'b1) // Combined shift conditions
			begin
			    if (captured_data_valid) begin // Prioritize using captured_data if valid
			        captured_data_valid <= 1'b0;
			        dr <= {jt_tdi, 1'b1, captured_data[11:1]};
			    end else begin // Standard shift otherwise
			        dr <= {jt_tdi, dr[12:1]};
			        // captured_data_valid remains 1'b0
			    end
			end
			// If not reset, capture, or shift, FFs hold their value
		end
	end
endmodule