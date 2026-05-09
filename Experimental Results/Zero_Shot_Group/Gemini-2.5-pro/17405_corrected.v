module top_SRAM (
	input 		   CLOCK_50,
	input  [3:0]   KEY,
	input  [17:0]  SW,
	output [6:0]   HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7,
	output [7:0]   LEDG,
	output [17:0]  LEDR,
	inout [35:0]   GPIO,
	inout  [15:0]  SRAM_DQ,
	output [19:0]  SRAM_ADDR,
	output SRAM_CE_N, SRAM_OE_N, SRAM_WE_N, SRAM_UB_N, SRAM_LB_N
  	);
	parameter
	state_rst          = 4'd0,
	state_idle         = 4'd1,
	state_delay        = 4'd2,
	state_check_block  = 4'd3,
	state_start_send   = 4'd4,
	state_cnt_increase = 4'd5;
	parameter AVAIL     = 21'b 0_1000_0000_0000_0000_0000;
	parameter AVAIL_DIV = AVAIL/21'd18;

	wire clk;
	wire rst_n;
	wire locked;
	wire [7:0] sum_SW; // Max sum is 12, so 8 bits is enough
	wire [31:0] delay;
	wire SW_17_debounced; // Assuming DeBounce module exists
	reg  fifo_block_read;
	wire pll_in_c0;
	wire pll_out_c0;
	wire dout;
	wire sck;
	wire ss;
	wire send_data;
	wire cc3200_flow_ctrl_n;
	wire fifo_busy;
	wire fifo_full;
	wire [31:0] din;
	reg  fifo_we;
	wire [31:0] fifo_debug;
	wire [21:0] available;
	wire [4:0]  number_0, number_1, number_2, number_3,
				number_4, number_5, number_6, number_7;
	wire [31:0] delay_cnt_plus_one;
	wire [31:0] data_cnt_plus_one;
	reg  [31:0] delay_cnt;
	reg  [31:0] data_cnt;
	reg  [3:0] current_state, next_state;

	// Assuming DeBounce module exists and is defined elsewhere
	// DeBounce DeBounce_i_0 (clk, rst_n, SW[17], SW_17_debounced);

	// Assuming pll module exists and is defined elsewhere
	pll pll_0 (
		.areset (!rst_n),
		.inclk0 (pll_in_c0),
		.c0 	(pll_out_c0),
		.locked (locked)
		);

	// Assuming fifo_spi_sram module exists and is defined elsewhere
	fifo_spi_sram fifo_spi_i (
		.clk		 	(clk),
		.nrst		 	(rst_n),
		.block  	 	(fifo_block_read),
		.we			 	(fifo_we),
		.din		 	(din),
		.fifo_busy 	 	(fifo_busy),
		.fifo_full 	 	(fifo_full),
		.dout 		 	(dout),
		.sck  		 	(sck),
		.ss   		 	(ss),
		.fifo_SRAM_ADDR (SRAM_ADDR),
		.fifo_SRAM_DQ 	(SRAM_DQ),
		.fifo_SRAM_CE_N (SRAM_CE_N),
		.fifo_SRAM_OE_N (SRAM_OE_N),
		.fifo_SRAM_WE_N (SRAM_WE_N),
		.fifo_SRAM_LB_N (SRAM_LB_N),
		.fifo_SRAM_UB_N (SRAM_UB_N),
		.available		(available),
		.debug			(fifo_debug)
		);

	// Assuming SSD module exists and is defined elsewhere
	SSD seven_seg_0 (number_0, HEX0);
	SSD seven_seg_1 (number_1, HEX1);
	SSD seven_seg_2 (number_2, HEX2);
	SSD seven_seg_3 (number_3, HEX3);
	SSD seven_seg_4 (number_4, HEX4);
	SSD seven_seg_5 (number_5, HEX5);
	SSD seven_seg_6 (number_6, HEX6);
	SSD seven_seg_7 (number_7, HEX7);

	// Calculate sum of lower 12 SW bits (number of switches ON)
	assign sum_SW = SW[0] + SW[1] + SW[2] + SW[3] + SW[4] + SW[5] +
					SW[6] + SW[7] + SW[8] + SW[9] + SW[10] + SW[11];

	// Calculate delay based on sum_SW
	assign delay = 32'd128 + (1 << sum_SW);

	assign pll_in_c0 = CLOCK_50;
	assign clk = pll_out_c0;
	assign din       = data_cnt;
	assign rst_n     = KEY[0];
	assign send_data = KEY[1]; // Assuming KEY[1] controls when to start sending

	// GPIO Assignments
	assign GPIO[0]   = sck;    // SPI Clock
	assign GPIO[1]   = dout;   // SPI MOSI (Master Out)
	assign GPIO[2]   = ss;     // SPI Slave Select
	assign GPIO[5:3] = 3'b000; // Unused or specific function
	// Removed duplicate assignments to GPIO[6], GPIO[7], GPIO[8]
	assign GPIO[6]     = 1'bz; // Keep as Z unless driven
	assign GPIO[7]     = 1'bz; // Keep as Z unless driven
	assign GPIO[8]     = 1'bz; // Keep as Z unless driven
	assign GPIO[9]     = fifo_debug[8];  // FIFO Debug info
	assign GPIO[10]    = fifo_debug[9];  // FIFO Debug info
	assign GPIO[11]    = fifo_debug[10]; // FIFO Debug info
	assign GPIO[34:12] = {23{1'bz}};     // High-impedance for unused/inputs
	assign cc3200_flow_ctrl_n  = GPIO[35]; // Input flow control from GPIO pin 35

	assign delay_cnt_plus_one = delay_cnt + 32'b1;
	assign data_cnt_plus_one  = data_cnt +  32'b1;

	// 7-Segment Display Assignments
	assign number_0 = {1'b0, fifo_debug[3:0]};  // Display lower nibble of fifo_debug
	assign number_1 = {1'b0, fifo_debug[7:4]};  // Display next nibble of fifo_debug
	assign number_2 = {1'b0, current_state};    // Display current state
	assign number_3 = 5'h10; // Display 'blank' or specific pattern (depends on SSD module)
	assign number_4 = 5'h10; // Display 'blank' or specific pattern
	assign number_5 = 5'h10; // Display 'blank' or specific pattern
	assign number_6 = 5'h10; // Display 'blank' or specific pattern
	assign number_7 = 5'h10; // Display 'blank' or specific pattern

	// LED Assignments
	assign LEDG[0]  = fifo_busy;
	assign LEDG[1]  = fifo_full;
	assign LEDG[7:2] = 6'b0; // Turn off unused green LEDs

	// Red LEDs indicate FIFO fill level
	assign LEDR[0]  = available > (AVAIL_DIV * 1)  ? 1'b1 : 1'b0;
	assign LEDR[1]  = available > (AVAIL_DIV * 2)  ? 1'b1 : 1'b0;
	assign LEDR[2]  = available > (AVAIL_DIV * 3)  ? 1'b1 : 1'b0;
	assign LEDR[3]  = available > (AVAIL_DIV * 4)  ? 1'b1 : 1'b0;
	assign LEDR[4]  = available > (AVAIL_DIV * 5)  ? 1'b1 : 1'b0;
	assign LEDR[5]  = available > (AVAIL_DIV * 6)  ? 1'b1 : 1'b0;
	assign LEDR[6]  = available > (AVAIL_DIV * 7)  ? 1'b1 : 1'b0;
	assign LEDR[7]  = available > (AVAIL_DIV * 8)  ? 1'b1 : 1'b0;
	assign LEDR[8]  = available > (AVAIL_DIV * 9)  ? 1'b1 : 1'b0;
	assign LEDR[9]  = available > (AVAIL_DIV * 10) ? 1'b1 : 1'b0;
	assign LEDR[10] = available > (AVAIL_DIV * 11) ? 1'b1 : 1'b0;
	assign LEDR[11] = available > (AVAIL_DIV * 12) ? 1'b1 : 1'b0;
	assign LEDR[12] = available > (AVAIL_DIV * 13) ? 1'b1 : 1'b0;
	assign LEDR[13] = available > (AVAIL_DIV * 14) ? 1'b1 : 1'b0;
	assign LEDR[14] = available > (AVAIL_DIV * 15) ? 1'b1 : 1'b0;
	assign LEDR[15] = available > (AVAIL_DIV * 16) ? 1'b1 : 1'b0;
	assign LEDR[16] = available > (AVAIL_DIV * 17) ? 1'b1 : 1'b0;
	assign LEDR[17] = available > (AVAIL_DIV * 18) ? 1'b1 : 1'b0; // Corresponds to full


	// Sequential logic for fifo_block_read based on input flow control
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			fifo_block_read <= 1'b0; // Default to not blocking read on reset
		end
		else begin
			fifo_block_read <= !cc3200_flow_ctrl_n; // Block read if flow control is asserted (active low)
		end
	end

	// Sequential logic for fifo_we based on state machine
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			fifo_we <= 1'b0;
		end
		else begin
			if (current_state == state_start_send)
				fifo_we <= 1'b1; // Assert write enable only in the start_send state
			else
				fifo_we <= 1'b0; // Deassert otherwise
		end
	end

	// Sequential logic for counters based on state machine
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			delay_cnt <= 32'b0;
			data_cnt  <= 32'b0;
		end
		else begin
			case (current_state)
				state_idle : begin
					delay_cnt <= 32'b0; // Reset delay counter in idle
					data_cnt  <= data_cnt; // Keep data counter
				end
				state_delay : begin
					delay_cnt <= delay_cnt_plus_one; // Increment delay counter
					data_cnt  <= data_cnt; // Keep data counter
				end
				state_cnt_increase : begin
					delay_cnt <= delay_cnt; // Keep delay counter
					data_cnt  <= data_cnt_plus_one; // Increment data counter after sending
				end
				// No change in state_rst, state_check_block, state_start_send for these counters
				default : begin
					delay_cnt <= delay_cnt;
					data_cnt  <= data_cnt;
				end
			endcase
		end
	end

	// State Register: Update current state on clock edge
	// Corrected sensitivity list to use posedge clk
	always @ (posedge clk or negedge rst_n) begin
		if (!rst_n)
			current_state <= state_rst; // Go to reset state when reset is active
		else
			current_state <= next_state; // Update state based on combinational logic
	end

	// Combinational Logic: Determine next state based on current state and inputs
	always @ (*) begin
		next_state = current_state; // Default: stay in current state
		case (current_state)
			state_rst : begin
				// Automatically move out of reset state once reset is deasserted
				next_state = state_idle;
			end
			state_idle : begin
			    // Only start the process if send_data is asserted (e.g., button press)
			    // and the FIFO is not full (as a basic precaution)
			    if (send_data && !fifo_full) begin
			        next_state = state_delay;
			    end else begin
			        next_state = state_idle; // Stay idle otherwise
			    end
			end
			state_delay : begin
				if (delay_cnt >= delay) begin // Check if delay has elapsed
					next_state = state_check_block;
				end
				// If send_data is deasserted during delay, maybe go back to idle? (Optional enhancement)
				// else if (!send_data) begin
				//     next_state = state_idle;
				// end
			end
			state_check_block : begin
				// Check if FIFO is ready to accept data (not busy processing previous write and not full)
				if (!fifo_busy && !fifo_full) begin
					next_state = state_start_send;
				end
				// Stay in check_block if FIFO is busy or full
				// If send_data is deasserted, maybe go back to idle? (Optional enhancement)
				// else if (!send_data) begin
				//     next_state = state_idle;
				// end
			end
			state_start_send : begin
				// This state asserts fifo_we for one cycle. Move to next state immediately.
				next_state = state_cnt_increase;
			end
			state_cnt_increase : begin
				// After incrementing the counter, go back to idle to wait for next send trigger or delay
				next_state = state_idle;
			end
			default : next_state = state_rst; // Should not happen, but go to reset state if it does
		endcase
	end

endmodule

// Placeholder for assumed modules (definitions not provided)
/*
module DeBounce (input clk, rst_n, noisy_in, output clean_out);
    // Debouncing logic here
endmodule

module pll (input areset, inclk0, output c0, locked);
    // PLL logic here
endmodule

module fifo_spi_sram (
    input clk, nrst, block, we,
    input [31:0] din,
    output fifo_busy, fifo_full, dout, sck, ss,
    output [19:0] fifo_SRAM_ADDR,
    inout [15:0] fifo_SRAM_DQ,
    output fifo_SRAM_CE_N, fifo_SRAM_OE_N, fifo_SRAM_WE_N, fifo_SRAM_LB_N, fifo_SRAM_UB_N,
    output [21:0] available,
    output [31:0] debug
);
    // FIFO and SRAM interface logic here
endmodule

module SSD (input [4:0] num, output [6:0] segments);
    // 7-segment display driver logic here
endmodule
*/