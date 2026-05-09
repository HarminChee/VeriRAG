`timescale 1ns / 1ps
module ElbertV2_FPGA_Board_corrected_acn(
	input[5:0] BTN,
	input clk,
	// Make rst_n a primary input for direct control
	input rst_n, // Dedicated primary input reset
	output[7:0] LED,
	output [7:0] SevenSegment,
	output [2:0] SevenSegment_Enable,
	output IO_P1_1,
	output IO_P1_3,
	inout IO_P1_5
	);

	// Removed wire rst_n; as it's now a primary input
	wire inc_n_btn;
	wire btn2_n;
	wire dht11_dat;
	reg [1:0] state_func;
	wire inc_n_debounced;
	wire btn2_n_debounced;
	// wire btn6_debounced; // Removed, reset comes from rst_n
	wire select_onehot; // Assuming this exists elsewhere or is driven appropriately
	// wire rst_debounced; // Removed, using direct rst_n
	wire clk_div_1Hz;
	wire clk_div_1MHZ;
	wire clk_div_1kHZ;
	wire [9:0] counter_4bit_out;
	wire [9:0] counter_10bit_out;
	wire dummy; // Consider removing if unused
	wire [9:0]humid;
	wire [9:0]temp;
	wire [3:0]status;
	wire [3:0] HUNDREDS;
	wire [3:0] TENS;
	wire [3:0] ONES;
	wire start_dht11_capture;
	reg auto_capture;
	reg [3:0] auto_capture_counter;
	reg auto_capture_start;
	reg auto_capture_rst_n; // Consider renaming if confusing with primary rst_n
	wire [3:0] data0a;
	wire [3:0] data1a;
	wire [3:0] data2a;
	wire [3:0] data0b;
	wire [3:0] data1b;
	wire [3:0] data2b;
	reg [3:0] LCD_3;
	reg [3:0] LCD_2;
	reg [3:0] LCD_1;
	wire dht11_start; // Consider removing if unused
	// wire rst_n_dht11; // Removed, using direct rst_n

	// assign rst_n = BTN[4]; // Removed, rst_n is now a primary input
	assign inc_n_btn = ~BTN[0];
	assign btn2_n = ~BTN[1];

	assign LED[7] = counter_4bit_out[0];
	assign LED[6] = counter_4bit_out[1];
	assign LED[5] = btn2_n_debounced;
	assign LED[4] = inc_n_debounced;
	assign LED[3] = status[0];
	assign LED[2] = status[1];
	assign LED[1] = status[2];
	assign LED[0] = status[3];

	assign SevenSegment[0] = ~clk_div_1Hz;
	assign IO_P1_1 = 1'b0;
	assign IO_P1_3 = 1'b1;
	assign IO_P1_5 = dht11_dat;

	assign start_dht11_capture = auto_capture ? auto_capture_start : btn2_n_debounced;
	// assign rst_n_dht11 = btn6_debounced; // Removed violation, use primary rst_n
	assign humid[9:8] = 2'b0;
	assign temp[9:8] = 2'b0;

	// Changed sensitivity list from negedge rst_debounced to negedge rst_n
	always@(posedge clk or negedge rst_n)
	begin
		// Changed condition from ~rst_debounced to ~rst_n
		if(~rst_n)
		begin
			state_func <= 2'b0;
			auto_capture <= 1'b0;
			// Reset LCD registers on asynchronous reset
			LCD_1 <= 4'b0;
			LCD_2 <= 4'b0;
			LCD_3 <= 4'b0;
		end
		else
		begin
			// Assuming select_onehot is properly driven synchronously
			if(select_onehot == 1'b1) // This condition might need review based on overall design intent
				state_func <= state_func + 1; // Be careful with state transitions and resets

			// Logic driving LCD registers moved here to be synchronous
			case(counter_4bit_out[1:0]) // This logic depends on counter_4bit_out, ensure it's stable
				2'b0:
				begin
					LCD_1 <= ONES;
					LCD_2 <= TENS;
					LCD_3 <= HUNDREDS;
					auto_capture <= 1'b0;
				end
				2'b1:
				begin
					LCD_1 <= data0a;
					LCD_2 <= data1a;
					LCD_3 <= data2a;
					auto_capture <= 1'b0;
				end
				2'b10:
				begin
					LCD_1 <= data0b;
					LCD_2 <= data1b;
					LCD_3 <= data2b;
					auto_capture <= 1'b0;
				end
				2'b11:
				begin
					// Repeated case? Check logic. Assuming display humid data here?
					LCD_1 <= data0a; // Humid Ones
					LCD_2 <= data1a; // Humid Tens
					LCD_3 <= data2a; // Humid Hundreds
					auto_capture <= 1'b1;
				end
				default: // Add default case
				begin
					LCD_1 <= 4'b0;
					LCD_2 <= 4'b0;
					LCD_3 <= 4'b0;
					auto_capture <= 1'b0;
				end
			endcase
		end
	end

	// This block uses rst_n correctly for ACNCPI
	always@(posedge clk_div_1Hz or negedge rst_n)
	begin
		if(~rst_n)
		begin
			auto_capture_counter <= 4'b0;
			auto_capture_start <= 1'b0;
		end
		else
		begin
			// Ensure auto_capture logic is intended
			if(auto_capture) begin // Only increment/start if auto_capture mode is active
				auto_capture_counter <= auto_capture_counter + 1;
				if(auto_capture_counter == 4'd8) // Check for specific count value (e.g., 8 seconds)
					auto_capture_start <= 1'b1;
				else
					auto_capture_start <= 1'b0;
			end else begin
				// Hold values or reset when not in auto_capture mode
				auto_capture_counter <= 4'b0;
				auto_capture_start <= 1'b0;
			end
		end
	end

	// Module instantiations use primary rst_n
	freqdiv freqdiv1(clk, rst_n, clk_div_1Hz, 2'b01); // Assuming freqdiv uses rst_n correctly internally
	freqdiv freqdiv2(clk, rst_n, clk_div_1MHZ, 2'b00); // Assuming freqdiv uses rst_n correctly internally
	freqdiv freqdiv3(clk, rst_n, clk_div_1kHZ, 2'b10); // Assuming freqdiv uses rst_n correctly internally

	debounce debounce_inc(clk_div_1kHZ, inc_n_btn, inc_n_debounced); // Debouncers are okay
	debounce debounce_start(clk_div_1kHZ, btn2_n, btn2_n_debounced);
	// debounce debounce_dht11_rst(clk_div_1kHZ, BTN[5], btn6_debounced); // Removed - reset is rst_n
	// debounce debounce_rst(clk_div_1kHZ, rst_n_from_btn, rst_debounced); // Removed - using primary rst_n directly

	new_counter theNewCounter(rst_n, inc_n_debounced, counter_4bit_out); // Assuming new_counter uses rst_n correctly internally
	new_counter the10bitCounter(rst_n, clk_div_1Hz, counter_10bit_out); // Assuming new_counter uses rst_n correctly internally

	// Pass primary rst_n to mySevenSegment
	mySevenSegment sevenSegementDec(clk, rst_n, LCD_1, LCD_2, LCD_3, SevenSegment[7:1], SevenSegment_Enable); // Assuming mySevenSegment uses rst_n correctly internally

	BINARY_TO_BCD   theBinary2BCD(counter_10bit_out, HUNDREDS, TENS, ONES); // Combinational
	BINARY_TO_BCD   theBinary2BCDhumid(humid[7:0], data2a, data1a, data0a); // Combinational - Slice humid input
	BINARY_TO_BCD   theBinary2BCDtemp(temp[7:0], data2b, data1b, data0b); // Combinational - Slice temp input

	// Pass primary rst_n to dht11_driver
	dht11_driver dht11_driver(clk_div_1MHZ, rst_n, start_dht11_capture, dht11_dat, humid[7:0], temp[7:0], status); // Assuming dht11_driver uses rst_n correctly internally

endmodule

// Note: Assumes sub-modules (freqdiv, debounce, new_counter, mySevenSegment, dht11_driver)
// handle the provided 'rst_n' input correctly as their primary asynchronous reset
// if they contain asynchronously resettable flip-flops.
// BINARY_TO_BCD is assumed combinational.
// Debounce modules generate signals but typically don't have external async resets themselves.