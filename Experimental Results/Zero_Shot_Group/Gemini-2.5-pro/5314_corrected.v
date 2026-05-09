`timescale 1ns / 1ps

module ElbertV2_FPGA_Board(
	input[5:0] BTN,
	input clk,
	output[7:0] LED,
	output [7:0] SevenSegment,
	output [2:0] SevenSegment_Enable,
	output IO_P1_1,
	output IO_P1_3,
	inout IO_P1_5 // Changed to inout for DHT11
	);

	// Internal Wires and Regs
	wire rst_n;
	wire inc_n_btn;
	wire btn2_n;
	// wire dht11_dat; // Removed, connect IO_P1_5 directly to driver instance
	wire inc_n_debounced;
	wire btn2_n_debounced;
	wire btn6_debounced;
	wire rst_debounced;
	wire clk_div_1Hz;
	wire clk_div_1MHZ;
	wire clk_div_1kHZ;
	wire [3:0] counter_4bit_out; // Corrected width
	wire [9:0] counter_10bit_out;
	wire [9:0] humid;
	wire [9:0] temp;
	wire [7:0] humid_8bit; // Intermediate wire for driver output
	wire [7:0] temp_8bit;  // Intermediate wire for driver output
	wire [3:0] status;
	wire [3:0] HUNDREDS;
	wire [3:0] TENS;
	wire [3:0] ONES;
	wire start_dht11_capture;
	reg auto_capture;
	reg [3:0] auto_capture_counter;
	reg auto_capture_start;
	// reg auto_capture_rst_n; // Seems unused, removed
	wire [3:0] data0a; // Humid Ones
	wire [3:0] data1a; // Humid Tens
	wire [3:0] data2a; // Humid Hundreds
	wire [3:0] data0b; // Temp Ones
	wire [3:0] data1b; // Temp Tens
	wire [3:0] data2b; // Temp Hundreds
	reg [3:0] LCD_3; // Display Digit 3 (Most Significant)
	reg [3:0] LCD_2; // Display Digit 2
	reg [3:0] LCD_1; // Display Digit 1 (Least Significant)
	wire dht11_start; // Seems unused, dht11 driver uses start_dht11_capture
	wire rst_n_dht11;

	// Input Assignments
	assign rst_n = BTN[4];       // Reset button (active low likely intended)
	assign inc_n_btn = ~BTN[0];    // Increment button (active low)
	assign btn2_n = ~BTN[1];       // Start capture button (active low)

	// Output Assignments
	assign LED[7] = counter_4bit_out[3]; // Map counter bits to LEDs
	assign LED[6] = counter_4bit_out[2];
	assign LED[5] = counter_4bit_out[1];
	assign LED[4] = counter_4bit_out[0];
	assign LED[3] = status[0];     // DHT11 Status bits
	assign LED[2] = status[1];
	assign LED[1] = status[2];
	assign LED[0] = status[3];

	// Assign 7-Segment[0] - maybe for blinking or indication
	assign SevenSegment[0] = ~clk_div_1Hz;

	// Fixed IO assignments
	assign IO_P1_1 = 1'b0;
	assign IO_P1_3 = 1'b1;
	// IO_P1_5 is handled by dht11_driver instance (inout)
	// assign IO_P1_5 = dht11_dat; // Removed assignment

	// DHT11 Control Logic
	assign start_dht11_capture = auto_capture ? auto_capture_start : btn2_n_debounced;
	assign rst_n_dht11 = btn6_debounced; // Use debounced BTN[5] for DHT11 reset

	// Combine 8-bit DHT data with 0 padding for 10-bit BCD converter input
	assign humid = {2'b00, humid_8bit};
	assign temp = {2'b00, temp_8bit};

	// Display Multiplexing Logic
	always @(posedge clk or negedge rst_debounced)
	begin
		if (~rst_debounced)
		begin
			// state_func <= 2'b0; // Removed unused state_func
			auto_capture <= 1'b0;
			LCD_1 <= 4'b0;
			LCD_2 <= 4'b0;
			LCD_3 <= 4'b0;
		end
		else
		begin
			// if(select_onehot==1'b1) // Removed unused logic
			//	state_func <=state_func +1;

			// Select display content based on lower bits of 4-bit counter
			case (counter_4bit_out[1:0])
				2'b00: // Display 10-bit counter value
				begin
					LCD_1 <= ONES;
					LCD_2 <= TENS;
					LCD_3 <= HUNDREDS;
					auto_capture <= 1'b0; // Disable auto capture in this mode
				end
				2'b01: // Display Humidity
				begin
					LCD_1 <= data0a; // Ones
					LCD_2 <= data1a; // Tens
					LCD_3 <= data2a; // Hundreds
					auto_capture <= 1'b0; // Disable auto capture in this mode
				end
				2'b10: // Display Temperature
				begin
					LCD_1 <= data0b; // Ones
					LCD_2 <= data1b; // Tens
					LCD_3 <= data2b; // Hundreds
					auto_capture <= 1'b0; // Disable auto capture in this mode
				end
				2'b11: // Display Humidity with Auto Capture Enabled
				begin
					LCD_1 <= data0a; // Ones
					LCD_2 <= data1a; // Tens
					LCD_3 <= data2a; // Hundreds
					auto_capture <= 1'b1; // Enable auto capture in this mode
				end
				default: // Default case (optional, but good practice)
				begin
					LCD_1 <= 4'b0;
					LCD_2 <= 4'b0;
					LCD_3 <= 4'b0;
					auto_capture <= 1'b0;
				end
			endcase
		end
	end

	// Auto Capture Timer Logic (generates a pulse every ~8 seconds)
	always @(posedge clk_div_1Hz or negedge rst_debounced) // Use debounced reset
	begin
		if (~rst_debounced) // Use debounced reset
		begin
			auto_capture_counter <= 4'b0;
			auto_capture_start <= 1'b0;
		end
		else
		begin
			if (auto_capture) // Only count if auto_capture is enabled
			begin
				auto_capture_counter <= auto_capture_counter + 1;
				// Generate a pulse when counter reaches 7 (approx 8 seconds)
				if (auto_capture_counter == 4'd7) // Pulse when counter[2:0] was 111
					auto_capture_start <= 1'b1;
				else
					auto_capture_start <= 1'b0;

				// Reset counter after pulse (or let it wrap around naturally)
				// if (auto_capture_counter == 4'd8)
				//     auto_capture_counter <= 4'b0; // Optional explicit reset
			end
			else // Reset counter and start signal if auto_capture is disabled
			begin
				auto_capture_counter <= 4'b0;
				auto_capture_start <= 1'b0;
			end
		end
	end

	// Instantiate Clock Dividers (Assuming 'freqdiv' module exists)
	// freqdiv #( .FREQ_IN(50_000_000), .FREQ_OUT(1) ) // Example with parameters
	freqdiv freqdiv1(clk, rst_debounced, clk_div_1Hz, 2'b01); // Mode for 1Hz? Check freqdiv module
	// freqdiv #( .FREQ_IN(50_000_000), .FREQ_OUT(1_000_000) )
	freqdiv freqdiv2(clk, rst_debounced, clk_div_1MHZ, 2'b00); // Mode for 1MHz?
	// freqdiv #( .FREQ_IN(50_000_000), .FREQ_OUT(1_000) )
	freqdiv freqdiv3(clk, rst_debounced, clk_div_1kHZ, 2'b10); // Mode for 1kHz?

	// Instantiate Debouncers (Assuming 'debounce' module exists)
	debounce debounce_inc(clk_div_1kHZ, inc_n_btn, inc_n_debounced);
	debounce debounce_start(clk_div_1kHZ, btn2_n, btn2_n_debounced);
	debounce debounce_dht11_rst(clk_div_1kHZ, BTN[5], btn6_debounced); // Debounce for DHT reset button
	debounce debounce_rst(clk_div_1kHZ, rst_n, rst_debounced);       // Debounce for main reset

	// Instantiate Counters (Assuming 'new_counter' module exists and handles different widths/inputs)
	// This counter increments on button press (debounced)
	new_counter #( .WIDTH(4) ) theNewCounter (
		.rst_n(rst_debounced), // Use debounced reset
		.clk_enable(inc_n_debounced), // Increment signal
		.clk(clk), // Needs a clock input if synchronous
		.count_out(counter_4bit_out)
	);
	// This counter increments at 1Hz
	new_counter #( .WIDTH(10) ) the10bitCounter (
		.rst_n(rst_debounced), // Use debounced reset
		.clk_enable(1'b1), // Always enabled
		.clk(clk_div_1Hz), // Clocked by 1Hz
		.count_out(counter_10bit_out)
	);

	// Instantiate 7-Segment Display Driver (Assuming 'mySevenSegment' module exists)
	mySevenSegment sevenSegementDec (
		.clk(clk), // Use main clock or a faster divided clock for refresh
		.rst(rst_debounced), // Use debounced reset
		.data0(LCD_1), // Digit 1 (LSB) data
		.data1(LCD_2), // Digit 2 data
		.data2(LCD_3), // Digit 3 (MSB) data
		.segments_out(SevenSegment[7:1]), // Segment outputs (a-g, dp)
		.anode_enable_out(SevenSegment_Enable) // Digit enable outputs
	);

	// Instantiate Binary to BCD Converters (Assuming 'BINARY_TO_BCD' module exists)
	BINARY_TO_BCD #( .WIDTH_IN(10) ) theBinary2BCD (
		.binary_in(counter_10bit_out),
		.hundreds(HUNDREDS),
		.tens(TENS),
		.ones(ONES)
	);
	BINARY_TO_BCD #( .WIDTH_IN(10) ) theBinary2BCDhumid (
		.binary_in(humid), // Input is 10-bit padded value
		.hundreds(data2a),
		.tens(data1a),
		.ones(data0a)
	);
	BINARY_TO_BCD #( .WIDTH_IN(10) ) theBinary2BCDtemp (
		.binary_in(temp), // Input is 10-bit padded value
		.hundreds(data2b),
		.tens(data1b),
		.ones(data0b)
	);

	// Instantiate DHT11 Driver (Assuming 'dht11_driver' module exists)
	dht11_driver dht11_driver_inst (
		.clk(clk_div_1MHZ),          // Clock input (e.g., 1MHz)
		.rst_n(rst_n_dht11),         // Reset input (active low)
		.start_capture(start_dht11_capture), // Start signal
		.dht_pin(IO_P1_5),           // Connect directly to inout pin
		.humid_out(humid_8bit),      // 8-bit Humidity output
		.temp_out(temp_8bit),        // 8-bit Temperature output
		.status_out(status)          // Status indicator bits
	);

endmodule