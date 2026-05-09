module jtag_fifo (
	input rx_clk,
	input [11:0] rx_data,
	input wr_en, rd_en,
    input rst_n, // Added primary asynchronous reset (active low)
	output [8:0] tx_data,
	output tx_full, tx_empty
);
	wire jt_capture, jt_drck, jt_reset, jt_sel, jt_shift, jt_tck, jt_tdi, jt_update;
	wire jt_tdo;
	BSCAN_SPARTAN6 # (.JTAG_CHAIN(1)) jtag_blk (
		.CAPTURE(jt_capture),
		.DRCK(jt_drck),
		.RESET(jt_reset), // Internal JTAG reset signal
		.RUNTEST(),
		.SEL(jt_sel),
		.SHIFT(jt_shift),
		.TCK(jt_tck),
		.TDI(jt_tdi),
		.TDO(jt_tdo),
		.TMS(),
		.UPDATE(jt_update)
	);
	reg captured_data_valid = 1'b0;
	reg [12:0] dr;
	wire full;
	// Assuming fifo_generator_v8_2 handles reset appropriately or doesn't require async reset here
	fifo_generator_v8_2 tck_to_rx_clk_blk (
		.wr_clk(jt_tck),
		.rd_clk(rx_clk),
		.din({7'd0, dr[8:0]}),
		.wr_en(jt_update & jt_sel & !full),
		.rd_en(rd_en & !tx_empty),
		.dout(tx_data),
		.full(full),
		.empty(tx_empty)
        // .rst(!rst_n) // Example: Connect primary reset if FIFO needs it
	);
	wire [11:0] captured_data;
	wire empty;
	// Assuming fifo_generator_v8_2 handles reset appropriately or doesn't require async reset here
	fifo_generator_v8_2 rx_clk_to_tck_blk (
		.wr_clk(rx_clk),
		.rd_clk(jt_tck),
		.din({4'd0, rx_data}),
		.wr_en(wr_en & !tx_full),
		.rd_en(jt_capture & ~empty), // Removed dependency on internal jt_reset
		.dout(captured_data),
		.full(tx_full),
		.empty(empty)
        // .rst(!rst_n) // Example: Connect primary reset if FIFO needs it
	);
	assign jt_tdo = captured_data_valid ? captured_data[0] : dr[0];

    // Corrected always block using primary asynchronous reset rst_n
	always @ (posedge jt_tck or negedge rst_n)
	begin
		if (!rst_n) // Asynchronous reset based on primary input rst_n
		begin
			dr <= 13'd0;
			captured_data_valid <= 1'b0;
		end
		else // Synchronous logic clocked by jt_tck
		begin
            // Logic based on JTAG state signals (capture, shift)
			if (jt_capture == 1'b1)
			begin
				captured_data_valid <= !empty; // Check if data is available from FIFO
				dr <= 13'd0;                 // Reset DR in Capture-DR state
			end
			else if (jt_shift == 1'b1) // Shift-DR state
			begin
				if (captured_data_valid) // First shift after capture
				begin
					captured_data_valid <= 1'b0; // Clear flag
                    // Load captured data into DR, shifted by TDI
					dr <= {jt_tdi, 1'b1, captured_data[11:1]};
				end
				else // Subsequent shifts
				begin
					dr <= {jt_tdi, dr[12:1]}; // Shift data through DR
				end
			end
            // No change to dr or captured_data_valid in other states (e.g., Update-DR)
		end
	end
endmodule