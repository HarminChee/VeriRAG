module comm_corrected_clk (
    // Standard inputs/outputs
    input hash_clk,
    input rx_new_nonce,
    input [31:0] rx_golden_nonce,
    output [255:0] tx_midstate,
    output [95:0] tx_data,

    // DFT specific inputs for clock control
    input test_mode, // Signal to enable test mode
    input test_clk   // Dedicated clock for testing (e.g., scan clock)
);

    // Internal clock selection mux for DFT
    // Ensures the clock source is controllable and derived from primary inputs
    wire clk;
    assign clk = test_mode ? test_clk : hash_clk; // Use test_clk in test_mode

    reg [351:0] jtag_data_shift = 352'd0;
    reg [255:0] midstate = 256'd0;
    reg [95:0] data = 96'd0;
    assign tx_midstate = midstate;
    assign tx_data = data;
    reg [31:0] golden_out = 32'd0;
    // Corrected initial value width for golden_count
    reg [3:0] golden_count = 4'd0;
    reg read = 1'b0;
    wire [8:0] jtag_data;
    wire full, empty;
    reg [5:0] jtag_data_count = 6'd0;
    wire golden_writing = golden_count[0];

    // Instantiate jtag_fifo using the DFT-friendly muxed clock
    jtag_fifo jtag_fifo_blk (
        .rx_clk (clk), // Use the muxed clock (test_clk or hash_clk)
        .rx_data ({golden_count, golden_out[7:0]}),
        .wr_en (golden_writing & ~full),
        .rd_en (read),
        .tx_data (jtag_data),
        .tx_full (full),
        .tx_empty (empty)
    );

    // Main logic clocked by the DFT-friendly muxed clock
    always @ (posedge clk) // Use the muxed clock
    begin
        // Nonce handling logic
        if (!golden_writing & rx_new_nonce)
        begin
            golden_out <= rx_golden_nonce;
            golden_count <= 4'b1111;
        end
        // FIFO writing logic (when golden_writing is active)
        else if (golden_writing & !full)
        begin
            golden_out <= golden_out >> 8;
            // Corrected shift operation for golden_count
            golden_count <= {1'b0, golden_count[3:1]};
        end

        // FIFO reading control logic
        // Initiate read if FIFO has data and not currently reading
        if (!empty & !read)
        begin
            read <= 1'b1;
        end

        // JTAG data processing logic (when read is active)
        if (read)
        begin
            read <= 1'b0; // Deassert read for the next cycle
            // Shift in new data from FIFO into the shift register
            jtag_data_shift <= {jtag_data_shift[343:0], jtag_data[7:0]};

            // Update state based on the received jtag_data marker bit jtag_data[8]
            // Assumes jtag_data is valid when read was asserted
            if (jtag_data[8] == 1'b0) // Start of a new sequence?
            begin
                jtag_data_count <= 6'd1;
            end
            else if (jtag_data_count == 6'd43) // End of the 44-byte sequence
            begin
                jtag_data_count <= 6'd0;
                // Load the completed data into midstate and data registers
                {midstate, data} <= {jtag_data_shift[343:0], jtag_data[7:0]};
            end
            // Continue sequence: Increment count if currently counting (count > 0)
            else if (jtag_data_count != 6'd0)
            begin
                jtag_data_count <= jtag_data_count + 1'b1; // Increment count
            end
            // If count is 0 and jtag_data[8] is 1, count remains 0 (no action needed)
        end
    end

endmodule

// Note: The definition for the instantiated module 'jtag_fifo' is not provided
// and is assumed to exist elsewhere. It is assumed 'jtag_fifo' uses 'rx_clk'
// for its internal sequential logic as intended.