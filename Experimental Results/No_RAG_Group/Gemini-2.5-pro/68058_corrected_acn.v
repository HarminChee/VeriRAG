module comm_corrected_acn ( // Renamed module
	input hash_clk,
	input rst_n, // Added primary input asynchronous reset
	input rx_new_nonce,
	input [31:0] rx_golden_nonce,
	output [255:0] tx_midstate,
	output [95:0] tx_data
);
	reg [351:0] jtag_data_shift; // Removed initial value
	reg [255:0] midstate;       // Removed initial value
	reg [95:0] data;           // Removed initial value
	assign tx_midstate = midstate;
	assign tx_data = data;
	reg [31:0] golden_out;     // Removed initial value
	reg [3:0] golden_count;     // Removed initial value
	reg read;                 // Removed initial value
	wire [8:0] jtag_data;
	wire full, empty;
	reg [5:0] jtag_data_count; // Removed initial value
	wire golden_writing = golden_count[0];

	// Instantiate FIFO - Assuming jtag_fifo handles its own reset or uses hash_clk + rst_n
	// Pass rst_n if the FIFO module requires an asynchronous reset controllable from PI
	jtag_fifo jtag_fifo_blk (
		.rx_clk (hash_clk),
		// .rst_n (rst_n), // Uncomment and connect if jtag_fifo needs external async reset
		.rx_data ({golden_count, golden_out[7:0]}),
		.wr_en (golden_writing & ~full),
		.rd_en (read),
		.tx_data (jtag_data),
		.tx_full (full),
		.tx_empty (empty)
	);

	// Main sequential logic with asynchronous reset controllable from primary input rst_n
	always @ (posedge hash_clk or negedge rst_n) // Added asynchronous reset sensitivity
	begin
		if (!rst_n) begin // Asynchronous reset condition from primary input
			jtag_data_shift <= 352'd0;
			midstate        <= 256'd0;
			data            <= 96'd0;
			golden_out      <= 32'd0;
			golden_count    <= 4'd0; // Reset to 4'd0 matching declaration [3:0]
			read            <= 1'b0;
			jtag_data_count <= 6'd0;
		end else begin // Normal clocked operation
			// Logic for golden nonce processing
			if (!golden_writing & rx_new_nonce)
			begin
				golden_out   <= rx_golden_nonce;
				golden_count <= 4'b1111; // Start count
			end
			else if (golden_writing & ~full) // Continue processing if writing and FIFO not full
			begin
				golden_out   <= golden_out >> 8;
				golden_count <= {1'b0, golden_count[3:1]}; // Shift count down
			end

			// Logic for reading from FIFO and processing JTAG data
			if (!empty & !read) // If FIFO has data and we are not currently reading, start reading
			begin
				read <= 1'b1;
			end
			// Note: 'read' stays high for one cycle during which rd_en is asserted.
			// The FIFO outputs data on the next edge, which is captured here.
			if (read) // If read was asserted in the previous cycle
			begin
				read <= 1'b0; // De-assert read for the next cycle
				jtag_data_shift <= {jtag_data_shift[343:0], jtag_data[7:0]}; // Shift in new data

				// Update state based on received jtag_data
				if (jtag_data[8] == 1'b0) // Indicates start of sequence?
				begin
					jtag_data_count <= 6'd1;
				end
				else if (jtag_data_count == 6'd43) // Reached end of expected data count (44 bytes total)
				begin
					jtag_data_count <= 6'd0; // Reset count
					// Load the completed data into midstate and data registers
					{midstate, data} <= {jtag_data_shift[343:0], jtag_data[7:0]};
				end
				else if (jtag_data_count != 6'd0) // Continue counting if not start and not end
				begin
					jtag_data_count <= jtag_data_count + 6'd1;
				end
				// Case where jtag_data_count is 0 but jtag_data[8] is 1 is implicitly handled
				// by the jtag_data[8]==1'b0 condition taking precedence or potentially
				// starting count if the first byte read has jtag_data[8] == 1.
                // Assuming the first byte read will have jtag_data[8] == 1'b0 if count is 0.
                // If count is 0 and jtag_data[8] == 1, count becomes 1+1=2 in next cycle?
                // Let's stick to original logic's apparent intent:
                else // Handles count == 0 and jtag_data[8] == 1
                begin
                     jtag_data_count <= jtag_data_count + 6'd1; // Increment from 0
                end
			end
		end
	end
endmodule