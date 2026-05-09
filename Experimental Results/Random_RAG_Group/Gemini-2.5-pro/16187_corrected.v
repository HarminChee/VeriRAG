`timescale 1ns / 1ps
`timescale 1ns / 1ps
module nes_controller(
		input master_clock,
		input reset_n_i, // Added primary reset input
		input test_i,    // Added primary test mode input
		output data_clock,
		output data_latch,
		input serial_data,
		output reg [7:0] button_state,
		output update_clock
   );
	parameter Hz  = 1;
	parameter KHz = 1000*Hz;
	parameter MHz = 1000*KHz;
	parameter MASTER_CLOCK_FREQUENCY = 100*MHz;
	parameter OUTPUT_UPDATE_FREQUENCY = 120*Hz;
	// Recalculate DIVIDER_EXPONENT based on corrected log2 function if necessary
	// Assuming original calculation with potentially flawed log2 was intended value
	parameter DIVIDER_EXPONENT = log2( (MASTER_CLOCK_FREQUENCY / OUTPUT_UPDATE_FREQUENCY) / 10 ) - 2;

	reg [DIVIDER_EXPONENT:0] sample_count;
	wire sample_clock_internal = sample_count[DIVIDER_EXPONENT]; // Internal clock signal

	// Counter clocked by primary clock
	always @(posedge master_clock or negedge reset_n_i) begin
		if (!reset_n_i) begin
			sample_count <= {DIVIDER_EXPONENT+1{1'b0}};
		end else begin
			sample_count <= sample_count + 1;
		end
	end

	// DFT clock selection mux
	wire dft_clk;
	assign dft_clk = test_i ? master_clock : sample_clock_internal;

	reg [3:0] cycle_stage;
	reg [7:0] data;

	wire latch_phase = cycle_stage == 0;
	wire data_phase = cycle_stage >= 1 & cycle_stage <= 8;
	wire end_phase = cycle_stage == 9;

	// Registers potentially clocked by derived clock (sample_clock_internal)
	// Use muxed clock (dft_clk) and primary synchronous reset (reset_n_i)
	always @(posedge dft_clk or negedge reset_n_i) begin
		if(!reset_n_i) begin
			cycle_stage <= 4'h0;
			data <= 8'h0;
			button_state <= 8'h0; // Ensure all FFs have reset
		end else begin
			// Conditional updates based on cycle_stage
			if(latch_phase) begin
				data <= 8'h0; // Clear data at start
				cycle_stage <= cycle_stage + 1; // Move to next stage
			end else if(data_phase) begin
				data <= {data[6:0], serial_data}; // Shift in serial data
				cycle_stage <= cycle_stage + 1; // Move to next stage
			end else if(end_phase) begin
				button_state <= data; // Update output register
				cycle_stage <= 4'h0; // Reset cycle for next round
			end else begin
				// Keep current state if not in latch, data, or end phase (should not happen with 4 bits)
				// Or increment if cycle_stage is between 9 and 15? Original code implies increment unless end_phase.
				// Let's stick to original implied behavior: increment unless end_phase caused reset
				cycle_stage <= cycle_stage + 1;
			end
		end
	end

	// Combinational output assignments
	assign data_latch = latch_phase;

	// Output clocks - Note: These are derived/gated clocks, generally discouraged by DFT,
	// but fixing them requires architectural changes beyond correcting the internal FF clocking rule violations.
	assign data_clock = data_phase & sample_clock_internal;
	assign update_clock = sample_clock_internal; // This is a divided clock output

	// Corrected log2 function
	function integer log2;
		 input [31:0] value;
		 integer i;
		 integer result;
		 begin
			  // Handle value=0 or value=1 case for log2
			  if (value <= 1) begin
				  log2 = 0;
			  end else begin
				  i = value - 1;
				  result = 0;
				  while (i > 0) begin
						i = i >> 1;
						result = result + 1;
				  end
				  log2 = result;
			  end
		 end
	endfunction
endmodule