module SPI_MASTER_ADC_corrected_ffc # (parameter outBits = 16)(
	input					SYS_CLK,
	input 				ENA, // Use a synchronous reset if possible, or ensure ENA is stable around SYS_CLK edges
	input		[15:0]	DATA_MOSI,
	input 				MISO,
	output  				MOSI,
	output  	reg		CSbar,
	output 				SCK,
	output  	reg		FIN,
	output  	[15:0]	DATA_MISO
	);

	reg	[(outBits-1):0]	data_in 				= 0;
	reg	[(outBits-1):0]	data_in_final 		= 0;
	reg	[(outBits-1):0]	data_out 			= 0;
	reg	[5 			:0]	icounter 			= 0;
	reg	[5 			:0]	ocounter 			= 0;
	reg	[1:0]				CLK_16              = 0; // Internal clock divider register

	// Generate clock division logic based on SYS_CLK
	always @(posedge SYS_CLK) begin
		CLK_16 <= CLK_16 + 1;
	end

	// Generate the SPI clock output SCK
	// This generated clock is acceptable for an output pin, but not for internal FFs
	assign SCK = CLK_16[1];

	// Create an enable signal that pulses high for one SYS_CLK cycle
	// when the SPI clock rising edge should occur (CLK_16 transitions from 01 to 10)
	wire spi_clk_enable = (CLK_16 == 2'b01);

	// Assign combinational outputs
	assign DATA_MISO 		= data_in_final;
	assign MOSI 				= data_out[(outBits-1)]; // MOSI driven by the MSB of data_out shift register

	// All flip-flops are now clocked by the primary clock SYS_CLK
	// Logic is enabled using spi_clk_enable to mimic the original SPI_CLK rate

	// CSbar logic update
	always @(posedge SYS_CLK) begin
		// Consider adding an explicit reset condition here if needed
		if (spi_clk_enable) begin // Update only when the enable is high
			CSbar <= ~ENA;
		end
		// Implicitly holds value otherwise
	end

	// FIN logic update
	always @(posedge SYS_CLK) begin
		// Consider adding an explicit reset condition here if needed
		if (spi_clk_enable) begin // Update only when the enable is high
			FIN <= (ocounter > (outBits-1)) & (icounter > (outBits-1));
		end
		// Implicitly holds value otherwise
	end

	// Input data path logic (MISO sampling)
	always @(posedge SYS_CLK) begin
		// Consider adding an explicit reset condition here if needed
		if (spi_clk_enable) begin // Update only when the enable is high
			// Use the value of CSbar registered in the previous cycle
			if (CSbar == 1'b1) begin // If chip select is inactive (using previous cycle's value)
				icounter 	<= 0;
				data_in		<= 0;
				// data_in_final often reset here too, depends on spec. Assuming hold.
			end else begin // Chip select is active (CSbar == 1'b0)
				if (icounter <= (outBits-1)) begin // Shift in data
				    if (icounter < (outBits)) begin // Avoid incrementing beyond limit before check
				        data_in 		<= {data_in[(outBits-2):0], MISO};
				        icounter 	    <= icounter + 1;
				    end else begin // icounter == outBits (just shifted last bit)
				        // Capture final value on the next enable after counter reaches 'outBits'
				        data_in_final <= data_in;
				        // Hold icounter or reset? Holding implicitly.
				    end
				end else begin // icounter > (outBits-1), i.e., icounter == outBits has happened
				    data_in_final <= data_in; // Keep updating final value or just once? Update once seems more typical.
				    // Let's modify to update only once:
				    // if (icounter == outBits) begin // Capture only on the specific cycle
                    //    data_in_final <= data_in;
                    // end
                    // The original logic implies continuous update after counter limit is reached.
                    // Let's stick closer to original for now, but be aware this might be refined.
				end
			end
		end
		// Implicitly hold register values otherwise
	end


	// Output data path logic (MOSI driving)
	always @(posedge SYS_CLK) begin
		// Consider adding an explicit reset condition here if needed
		if (spi_clk_enable) begin // Update only when the enable is high
			// Use the value of CSbar registered in the previous cycle
			if (CSbar == 1'b1) begin // If chip select is inactive
				ocounter <= 0;
				data_out <= DATA_MOSI; // Load parallel data
			end else begin // Chip select is active (CSbar == 1'b0)
				if (ocounter <= (outBits-1)) begin // Shift out data
				    if (ocounter < (outBits)) begin // Avoid incrementing beyond limit before check
				        data_out 		<= {data_out[(outBits-2):0], 1'b0}; // Shift left, LSB is 0
				        ocounter 		<= ocounter + 1;
                    end else begin // ocounter == outBits (just shifted last bit)
                        // What should happen here? Original sets data_out to 1.
                        data_out <= {{(outBits){1'b1}}}; // Set all bits to 1? Or just LSB? Original implies scalar '1'. Let's assume all ones.
                        // Hold ocounter or reset? Holding implicitly.
                    end
				end else begin // ocounter > (outBits-1) is true
				    // Original behavior: keep setting data_out to 1
					data_out <= {{(outBits){1'b1}}}; // Set all bits to 1
                    // Hold ocounter implicitly.
				end
			end
		end
		// Implicitly hold register values otherwise
	end

endmodule