module comm (
	input rst_n, // Added primary asynchronous reset input
	input hash_clk,
	input rx_new_nonce,
	input [31:0] rx_golden_nonce,
	output [255:0] tx_midstate,
	output [95:0] tx_data
);
	reg [351:0] jtag_data_shift = 352'd0;
	reg [255:0] midstate = 256'd0;
	reg [95:0] data = 96'd0;
	assign tx_midstate = midstate;
	assign tx_data = data;
	reg [31:0] golden_out = 32'd0;
	reg [3:0] golden_count = 4'd0; // Initialize to 0 for reset state consistency
	reg read = 1'b0;
	wire [8:0] jtag_data;
	wire full, empty;
	reg [5:0] jtag_data_count = 6'd0;
	wire golden_writing = golden_count[0];

	// Assuming jtag_fifo has a reset input, connect it to the primary reset
	jtag_fifo jtag_fifo_blk (
		.rst_n   (rst_n), // Connect primary reset to FIFO reset
		.rx_clk (hash_clk),
		.rx_data ({golden_count, golden_out[7:0]}),
		.wr_en (golden_writing & ~full),
		.rd_en (read),
		.tx_data (jtag_data),
		.tx_full (full),
		.tx_empty (empty)
	);

	// Add asynchronous reset to the main logic block
	always @ (posedge hash_clk or negedge rst_n)
	begin
		if (!rst_n) // Asynchronous reset condition
		begin
			jtag_data_shift <= 352'd0;
			midstate        <= 256'd0;
			data            <= 96'd0;
			golden_out      <= 32'd0;
			golden_count    <= 4'd0;
			read            <= 1'b0;
			jtag_data_count <= 6'd0;
		end
		else // Normal operation on positive clock edge
		begin
			// Original logic for golden_out and golden_count
			if (!golden_writing & rx_new_nonce)
			begin
				golden_out <= rx_golden_nonce;
				golden_count <= 4'b1111;
			end
			else if (golden_writing & !full)
			begin
				golden_out <= golden_out >> 8;
				golden_count <= {1'b0, golden_count[3:1]};
			end

			// Original logic for read
			// Make read update conditional on not being reset
			// If read could be set high by !empty in the same cycle reset is asserted,
			// ensure reset takes precedence. The async reset handles this, but
			// making the functional logic cleaner is good practice.
			if (!empty & !read)
			begin
				read <= 1'b1;
			end
			// Note: The 'if (read)' block below handles the case where read is high.

			// Original logic for jtag_data_shift, jtag_data_count, midstate, data
			if (read) // If read was set high in the previous cycle or by the logic above
			begin
				read <= 1'b0; // Deassert read for the next cycle
				jtag_data_shift <= {jtag_data_shift[343:0], jtag_data[7:0]};
				if (jtag_data[8] == 1'b0) // Check the MSB from FIFO data
					jtag_data_count <= 6'd1;
				else if (jtag_data_count == 6'd43)
				begin
					jtag_data_count <= 6'd0;
					{midstate, data} <= {jtag_data_shift[343:0], jtag_data[7:0]}; // Load data
				end
				else
					jtag_data_count <= jtag_data_count + 6'd1;
			end
			// If read was not high, retain existing values (implicit in non-blocking assignments)
            // unless updated by other conditions (e.g., golden_out/count logic)
		end
	end
endmodule