module jtag_fifo (
	input rst, // Added primary input reset
	input rx_clk,
	input [11:0] rx_data,
	input wr_en, rd_en,
	output [8:0] tx_data,
	output tx_full, tx_empty
);
	wire jt_capture, jt_drck, jt_reset, jt_sel, jt_shift, jt_tck, jt_tdi, jt_update;
	wire jt_tdo;
	// Instance of the JTAG boundary scan primitive
	BSCAN_SPARTAN6 # (.JTAG_CHAIN(1)) jtag_blk (
		.CAPTURE(jt_capture),
		.DRCK(jt_drck),
		.RESET(jt_reset), // This reset is internal to JTAG state machine, not used for FF async reset
		.RUNTEST(),
		.SEL(jt_sel),
		.SHIFT(jt_shift),
		.TCK(jt_tck),
		.TDI(jt_tdi),
		.TDO(jt_tdo),
		.TMS(), // Assuming TMS is controlled externally or tied off if not used directly
		.UPDATE(jt_update)
	);

	// State register indicating if valid data has been captured from the RX->TCK FIFO
	reg captured_data_valid = 1'b0;
	// JTAG Data Register (DR)
	reg [12:0] dr;

	// FIFO instance: TCK clock domain to RX clock domain (for transmitting data out via JTAG)
	wire full;
	fifo_generator_v8_2 tck_to_rx_clk_blk (
		.wr_clk(jt_tck),
		.rd_clk(rx_clk),
		.din({7'd0, dr[8:0]}), // Data input from the JTAG DR
		.wr_en(jt_update & jt_sel & !full), // Write enable controlled by JTAG update state
		.rd_en(rd_en & !tx_empty), // Read enable controlled by external signal
		.dout(tx_data), // Data output to the RX clock domain logic
		.full(full), // FIFO full status
		.empty(tx_empty) // FIFO empty status
		// Add asynchronous reset connection if the FIFO generator supports it and requires it
		// .rst(rst) // Example: Connect primary reset if FIFO needs it
	);

	// FIFO instance: RX clock domain to TCK clock domain (for capturing data into JTAG)
	wire [11:0] captured_data;
	wire empty;
	fifo_generator_v8_2 rx_clk_to_tck_blk (
		.wr_clk(rx_clk),
		.rd_clk(jt_tck),
		.din({4'd0, rx_data}), // Data input from the RX clock domain logic
		.wr_en(wr_en & !tx_full), // Write enable controlled by external signal
		.rd_en(jt_capture & ~empty & ~jt_reset), // Read enable controlled by JTAG capture state (avoid read on JTAG reset)
		.dout(captured_data), // Data output to the TCK clock domain logic (to be loaded into DR)
		.full(tx_full), // FIFO full status
		.empty(empty) // FIFO empty status
		// Add asynchronous reset connection if the FIFO generator supports it and requires it
		// .rst(rst) // Example: Connect primary reset if FIFO needs it
	);

	// JTAG TDO output logic
	// Selects between the LSB of the shift register (dr) during shift,
	// or the LSB of the captured data when valid.
	// Note: Standard JTAG TDO changes on falling edge of TCK, this implies logic clocked on posedge. Check BSCAN primitive details.
	// Assuming TDO combinatorial based on current DR state for simplicity here.
	assign jt_tdo = captured_data_valid ? captured_data[0] : dr[0];

	// JTAG Data Register (DR) logic with asynchronous reset from primary input
	always @ (posedge jt_tck or posedge rst) // Use primary input 'rst' for asynchronous reset
	begin
		if (rst == 1'b1) // Asynchronous reset condition using primary input
		begin
			dr <= 13'd0;
			captured_data_valid <= 1'b0; // Reset the validity flag as well
		end
		else // Synchronous logic clocked by jt_tck
		begin
			// Capture state: Load data from RX->TCK FIFO if not empty
			if (jt_capture == 1'b1)
			begin
				captured_data_valid <= !empty; // Set validity flag based on FIFO empty status
				// DR is often loaded with a fixed pattern or status in Capture-DR state.
				// Original code cleared DR, let's keep that behavior unless specified otherwise.
				// If captured_data needs to be loaded here, it should be done carefully.
				dr <= 13'd0; // Clear DR during capture as per original logic
			end
			// Shift state: Shift data in from TDI, out to TDO (handled by assign jt_tdo)
			else if (jt_shift == 1'b1)
			begin
				// If valid data was just captured, load it into the shift register (DR)
				// The first bit shifted out will be captured_data[0] via jt_tdo assign
				if (captured_data_valid)
				begin
					captured_data_valid <= 1'b0; // Clear flag after first shift cycle
					// Load captured data into DR, format seems specific {TDI, fixed '1', data[11:1]}
					dr <= {jt_tdi, 1'b1, captured_data[11:1]};
				end
				// Otherwise, perform standard shift operation
				else
				begin
					dr <= {jt_tdi, dr[12:1]}; // Shift in TDI, shift out dr[0]
				end
			end
			// Update state: DR content is stable, used by tck_to_rx_clk_blk write enable
			// No explicit change to dr needed here based on original logic.
            // If jt_update required specific action on DR, it would be added here.
		end
	end

endmodule