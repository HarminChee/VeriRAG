module SPI_MASTER_ADC # (parameter outBits = 16)(
	input					SYS_CLK,
	input 				ENA, // Active high enable for transaction
	input		[outBits-1:0]	DATA_MOSI, // Data to be sent
	input 				MISO,      // Data received from slave
	output  	reg			MOSI,      // Data sent to slave
	output  	reg			CSbar,     // Chip Select (active low)
	output 				SCK,       // SPI Clock
	output  	reg			FIN,       // Transaction finished flag
	output  	reg [outBits-1:0]	DATA_MISO  // Data received from slave (registered)
	);

	// Calculate counter width dynamically based on outBits
	// Needs to count from 0 up to outBits
	localparam C_WIDTH = $clog2(outBits + 1);

	// Internal registers
	reg	[outBits-1:0]	data_in_sr 		= {outBits{1'b0}}; // Input Shift Register
	reg	[outBits-1:0]	data_out_sr 	= {outBits{1'b0}}; // Output Shift Register
	reg	[C_WIDTH-1:0]	bit_counter 	= {C_WIDTH{1'b0}}; // Unified counter for bits shifted

	// SPI Clock Generation (Divide SYS_CLK by 4)
	reg	[1:0]	clk_divider_count = 2'b0;
	always @(posedge SYS_CLK) begin
		clk_divider_count <= clk_divider_count + 1;
	end
	// Use the MSB for a 50% duty cycle /4 clock relative to SYS_CLK
	// Ensure SCK is stable when CSbar potentially changes and data is sampled/driven
	wire SPI_CLK = clk_divider_count[1];

	// Assign SCK output
	assign SCK = (CSbar == 1'b0) ? SPI_CLK : 1'b0; // Keep SCK low when CSbar is high

	// CSbar generation synchronized to SYS_CLK
	// Assumes ENA is stable around the posedge of SYS_CLK
	reg ENA_sync = 1'b0;
	always @(posedge SYS_CLK) begin
	    ENA_sync <= ENA;
		CSbar <= ~ENA_sync; // CSbar is active low when ENA is active high
	end

	// Main SPI Logic (Data Shifting and Control)
	// Use negedge SPI_CLK sampling/shifting if required by device (common SPI mode)
	// Assuming posedge SPI_CLK for shifting based on original code
	always @(posedge SPI_CLK or posedge CSbar) begin // Reset logic on CSbar going high
		if (CSbar) begin // If Chip Select is inactive (high) - Asynchronous reset for counters/state
			bit_counter <= {C_WIDTH{1'b0}};
			data_out_sr <= DATA_MOSI; // Load data for next transmission
			data_in_sr  <= {outBits{1'b0}}; // Clear input shift register
			FIN         <= 1'b0;      // Deassert FINished flag
			MOSI        <= 1'b1;      // Set MOSI to idle state (typically high)
			// DATA_MISO retains its last latched value
		end else begin // If Chip Select is active (low) - Synchronous operation on SPI_CLK edge
			// Default assignments for signals that don't change every cycle
			FIN <= 1'b0; // Keep FIN low during transaction unless it's the last cycle

			if (bit_counter < outBits) begin
				// Shift data out on MOSI (MSB first)
				MOSI <= data_out_sr[outBits-1];
				data_out_sr <= {data_out_sr[outBits-2:0], 1'b0}; // Shift left

				// Shift data in from MISO (MSB first)
				data_in_sr <= {data_in_sr[outBits-2:0], MISO}; // Shift left

				// Increment bit counter
				bit_counter <= bit_counter + 1;

			end

			// Check if the transaction will complete *after* this clock edge
			if (bit_counter == outBits - 1) begin
				// This is the last bit being shifted IN and OUT now.
				// The counter will become 'outBits' on the next clock edge.
				// Latch the final received data on the *next* cycle when counter hits outBits.
			end

            // Handle state when counter reaches outBits (transaction finished)
            // Need to ensure this doesn't conflict with the initial state when CSbar just went low
            // The counter only reaches outBits *after* the last bit is shifted.
            if (bit_counter == outBits) begin
                FIN <= 1'b1; // Assert FINished flag - transaction complete
                DATA_MISO <= data_in_sr; // Latch the fully received word
                MOSI <= 1'b1; // Set MOSI to idle state after last bit is sent
                // Keep counter, shift registers in final state until CSbar goes high
            end
		end
	end

	// If DATA_MISO should reflect the incoming data immediately (not just at the end):
	// assign DATA_MISO = data_in_sr; // Combinatorial assignment - remove reg declaration for DATA_MISO

endmodule