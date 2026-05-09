module jtag_fifo (
    input wire test_i,    // Added DFT test mode input
    input wire reset_n,   // Added primary reset input (assuming active low)
	input wire rx_clk,
	input wire [11:0] rx_data,
	input wire wr_en, rd_en,
	output wire [8:0] tx_data,
	output wire tx_full, tx_empty
);
	wire jt_capture, jt_drck, jt_reset, jt_sel, jt_shift, jt_tck, jt_tdi, jt_update;
	wire jt_tdo;

    // DFT Signals
    wire dft_tck;
    wire async_reset_active_high;

    // Clock Mux: Use rx_clk during test mode, jt_tck during functional mode
    assign dft_tck = test_i ? rx_clk : jt_tck;

    // Reset Mux: Use !reset_n (active high) during test mode, jt_reset (active high) during functional mode
    // Handles ACNCPI for the always block reset
    assign async_reset_active_high = test_i ? !reset_n : jt_reset;


	BSCAN_SPARTAN6 # (.JTAG_CHAIN(1)) jtag_blk (
		.CAPTURE(jt_capture),
		.DRCK(jt_drck),
		.RESET(jt_reset), // jt_reset is active high
		.RUNTEST(),
		.SEL(jt_sel),
		.SHIFT(jt_shift),
		.TCK(jt_tck),     // jt_tck is the JTAG clock output
		.TDI(jt_tdi),
		.TDO(jt_tdo),
		.TMS(),
		.UPDATE(jt_update)
	);

	reg captured_data_valid = 1'b0;
	reg [12:0] dr;
	wire full;

    // Note: Assuming fifo_generator_v8_2 has an asynchronous reset input 'rst'.
    // The actual reset pin name and polarity might differ based on FIFO generation options.
	fifo_generator_v8_2 tck_to_rx_clk_blk (
		.wr_clk(dft_tck), // Use muxed clock (Handles CLKNPI/FFCKNP)
		.rd_clk(rx_clk),
		.din({7'd0, dr[8:0]}),
		.wr_en(jt_update & jt_sel & !full),
		.rd_en(rd_en & !tx_empty),
		.dout(tx_data),
		.full(full),
		.empty(tx_empty),
        .rst(async_reset_active_high) // Use muxed reset (Handles ACNCPI for FIFO)
	);

	wire [11:0] captured_data;
	wire empty;

	fifo_generator_v8_2 rx_clk_to_tck_blk (
		.wr_clk(rx_clk),
		.rd_clk(dft_tck), // Use muxed clock (Handles CLKNPI/FFCKNP)
		.din({4'd0, rx_data}),
		.wr_en(wr_en & !tx_full),
		.rd_en(jt_capture & ~empty & ~jt_reset), // Functional read enable logic
		.dout(captured_data),
		.full(tx_full),
		.empty(empty),
        .rst(async_reset_active_high) // Use muxed reset (Handles ACNCPI for FIFO)
	);

	assign jt_tdo = captured_data_valid ? captured_data[0] : dr[0];

	// Changed sensitivity list for DFT compliance
    // Uses muxed clock (dft_tck) and muxed reset (async_reset_active_high)
	always @ (posedge dft_tck or posedge async_reset_active_high)
	begin
		// Changed reset condition to use muxed reset signal
		if (async_reset_active_high == 1'b1)
		begin
			dr <= 13'd0;
            captured_data_valid <= 1'b0; // Ensure state is reset
		end
		else // Logic clocked by dft_tck
		begin
            // Capture logic driven by JTAG signals
            if (jt_capture == 1'b1)
            begin
                // Reading 'empty' status from rx_clk_to_tck_blk FIFO, read clock is dft_tck
                captured_data_valid <= !empty;
                dr <= 13'd0;
            end
            // Shift logic driven by JTAG signals
            else if (jt_shift == 1'b1)
            begin
                if (captured_data_valid) // First shift after capture loads data from FIFO
                begin
                    captured_data_valid <= 1'b0;
                    // Reading 'captured_data' from rx_clk_to_tck_blk FIFO, read clock is dft_tck
                    dr <= {jt_tdi, 1'b1, captured_data[11:1]};
                end
                else // Subsequent shifts
                begin
                    dr <= {jt_tdi, dr[12:1]};
                end
            end
            // In other JTAG states (e.g., Update-DR, Run-Test/Idle), registers hold their value
        end
	end
endmodule