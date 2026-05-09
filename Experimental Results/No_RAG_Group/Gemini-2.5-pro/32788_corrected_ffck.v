module uart_tx_corrected_ffc #(parameter CLOCK_FREQ = 12_000_000, BAUD_RATE = 115_200)
	(
	input clock,
	input [7:0] read_data,
	input read_clock_enable,
	input reset,
	output reg ready,
	output reg tx,
	// output reg uart_clock // Removed internally generated clock output
    );

	reg [9:0] data; // 0: start, 1-8: data, 9: stop
	// Calculate clocks per bit period
	localparam CLOCKS_PER_BAUD_TICK = CLOCK_FREQ / BAUD_RATE;
	// Check if the division results in a meaningful value
	initial begin
		if (CLOCKS_PER_BAUD_TICK == 0) begin
			$display("Error: CLOCK_FREQ is too low for the specified BAUD_RATE.");
			$finish;
		end
		if (CLOCK_FREQ % BAUD_RATE != 0) begin
            $display("Warning: CLOCK_FREQ / BAUD_RATE is not an integer. Baud rate timing may be inaccurate.");
        end
	end

    localparam DIVIDER_MAX = CLOCKS_PER_BAUD_TICK - 1;
    // Use a sufficiently large divider, original size was [24:0]
    // $clog2(CLOCKS_PER_BAUD_TICK) bits are needed.
	reg [$clog2(CLOCKS_PER_BAUD_TICK > 0 ? CLOCKS_PER_BAUD_TICK : 1)-1:0] divider;
    reg baud_tick; // Replaces uart_clock edge detection

	reg new_data;
	reg state;
	reg [3:0] bit_pos;
	localparam IDLE = 1'h0, DATA = 1'h1;

    // Baud tick generator
	always @(posedge clock or negedge reset) begin
		if (~reset) begin
			divider <= 0;
			baud_tick <= 1'b0;
		end
		else begin
            baud_tick <= 1'b0; // Default to low
			if (divider == DIVIDER_MAX) begin
				divider <= 0;
                baud_tick <= 1'b1; // Generate tick when counter rolls over
			end else begin
				divider <= divider + 1;
			end
		end
	end

    // Input data latching and ready signal logic
	always @(posedge clock or negedge reset) begin // Changed to posedge clock
		if (~reset) begin
			ready <= 1'b0;
			new_data <= 1'b0;
            data <= 10'b1111111111; // Initialize data (idle = high)
		end
		else begin
			if (state == IDLE) begin
				if (~new_data) begin // If no new data is pending
					if (~ready) begin
						ready <= 1'b1; // Signal ready if not already ready
                    end
                    // Check read_clock_enable only when ready is high
                    if (ready && read_clock_enable) begin // If ready and read enable is high
						data[0] <= 1'b0;           // Start bit
						data[8:1] <= read_data; // Data bits
						data[9] <= 1'b1;           // Stop bit
						new_data <= 1'b1;          // Flag new data is loaded
						ready <= 1'b0;             // Signal not ready anymore
					end
                end else begin // If new_data is already high (waiting for transmission start)
                    ready <= 1'b0; // Keep ready low
                end
			end
			else begin // If state is DATA (transmitting)
                // new_data is cleared by the state machine when it transitions to DATA
				ready <= 1'b0; // Keep ready low during transmission
                if (baud_tick && state == DATA && bit_pos == 9) begin // Check if transmission just finished
                    // If just finished, allow ready to potentially go high next cycle if IDLE
                end else if (state == DATA) begin
                    ready <= 1'b0; // Ensure ready stays low while transmitting
                end
			end
            // Clear new_data AFTER state machine consumes it (detects state==IDLE and new_data==1)
            if (state == DATA) begin
                 new_data <= 1'b0;
            end
		end
	end

    // UART state machine logic, clocked by system clock, enabled by baud_tick
	always @(posedge clock or negedge reset) begin // Changed to posedge clock
		if (~reset) begin
			state <= IDLE;
			tx <= 1'b1; // TX high when idle/reset
			bit_pos <= 0;
		end
		else if (baud_tick) begin // Update state machine logic on baud tick
			case (state)
				IDLE: begin
					tx <= 1'b1; // Keep TX high
					if (new_data) begin
						state <= DATA;
						bit_pos <= 0; // Start with bit 0 (start bit)
						tx <= data[0]; // Send start bit (0)
                        // new_data is cleared in the other always block now
					end
				end
				DATA: begin
                    // Send the bit corresponding to the current bit_pos
                    tx <= data[bit_pos];
                    // Check if the current bit is the stop bit (index 9)
					if (bit_pos == 9) begin
						state <= IDLE;
                        // tx was set to data[9] (stop bit = 1) above.
                        // Next cycle in IDLE state will keep tx high.
                        // bit_pos will be reset if/when returning to DATA state.
                    end else begin
                        bit_pos <= bit_pos + 1; // Move to next bit position
                    end
				end
                default: begin // Add default case for safety
                    state <= IDLE;
                    tx <= 1'b1;
                    bit_pos <= 0;
                end
			endcase
		end
        // If not baud_tick, hold previous values (implied latch for tx, state, bit_pos)
        // This is handled by the nature of sequential always block.
        // However, ensure tx holds correct value when IDLE and no baud_tick
        else if (state == IDLE) begin
            tx <= 1'b1; // Ensure TX stays high in idle between ticks
        end
	end

endmodule