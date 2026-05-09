`timescale 1ns / 1ps
`timescale 1ns / 1ps
module VideoSync(
			input CLOCK,
			input rst_n, // Added primary input reset
			output PIXEL_CLOCK,
			output V_SYNC,
			output H_SYNC,
			output C_SYNC,
			output reg [8:0] H_COUNTER,
			output reg [8:0] V_COUNTER);
		parameter H_PIXELS = 320;
		parameter H_FP_DURATION   = 4;
		parameter H_SYNC_DURATION = 48;
		parameter H_BP_DURATION   = 28;
		parameter V_PIXELS = 240;
		parameter V_FP_DURATION   = 1;
		parameter V_SYNC_DURATION = 15;
		parameter V_BP_DURATION   = 4;
		parameter H_FP_EDGE = H_FP_DURATION;
		parameter H_SYNC_EDGE = H_FP_EDGE + H_SYNC_DURATION;
		parameter H_BP_EDGE = H_SYNC_EDGE + H_BP_DURATION;
		parameter H_PERIOD = H_BP_EDGE + H_PIXELS;
		parameter V_FP_EDGE = V_FP_DURATION;
		parameter V_SYNC_EDGE = V_FP_EDGE + V_SYNC_DURATION;
		parameter V_BP_EDGE = V_SYNC_EDGE + V_BP_DURATION;
		parameter V_PERIOD = V_BP_EDGE + V_PIXELS;

		reg [3:0] clock_divider = 0;
		wire pixel_clock_enable;

		// Clock divider logic with synchronous reset
		always @(posedge CLOCK or negedge rst_n) begin
			if (!rst_n) begin
				clock_divider <= 4'b0;
			end else begin
				clock_divider <= clock_divider + 1;
			end
		end

		// Generate enable signal based on divider state
		// Enable pulses high for one CLOCK cycle when the original PIXEL_CLOCK would rise
		assign pixel_clock_enable = (clock_divider == 4'b0111);

		// Assign output PIXEL_CLOCK based on divider (remains as output signal)
		assign PIXEL_CLOCK = clock_divider[3];

		// Counter logic clocked by primary CLOCK, enabled by pixel_clock_enable
		always @(posedge CLOCK or negedge rst_n) begin
			if (!rst_n) begin
				H_COUNTER <= 9'b0;
				V_COUNTER <= 9'b0;
			end else if (pixel_clock_enable) begin // Update counters only when enabled
				if (H_COUNTER == H_PERIOD - 1) begin
					H_COUNTER <= 0;
					// V_COUNTER increments when H_COUNTER rolls over
					if (V_COUNTER == V_PERIOD - 1) begin
						V_COUNTER <= 0;
					end else begin
						V_COUNTER <= V_COUNTER + 1;
					end
				end else begin
					H_COUNTER <= H_COUNTER + 1;
					// V_COUNTER holds its value until H_COUNTER rolls over
				end
			// If not enabled, counters hold their values (implicit)
			// else begin
			//    H_COUNTER <= H_COUNTER;
			//    V_COUNTER <= V_COUNTER;
			// end
			end
		end

	// Combinational logic for sync signals based on counter values
	assign V_SYNC = (V_COUNTER < V_FP_EDGE || V_COUNTER >= V_SYNC_EDGE); // Corrected condition >=
	assign H_SYNC = (H_COUNTER < H_FP_EDGE || H_COUNTER >= H_SYNC_EDGE); // Corrected condition >=
	assign C_SYNC = !(H_SYNC ^ V_SYNC);
endmodule