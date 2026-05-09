`timescale 1ns / 1ps
`timescale 1ns / 1ps // Note: Duplicate timescale directive, keeping one is sufficient
module ps2_receiver(
    input wire clk, clr,
	input wire ps2c, ps2d,
	output wire [15:0] xkey
	);

	// Registers for filtering PS/2 clock and data lines
	reg PS2Cf_stable, PS2Df_stable; // Stable filtered signals
	reg [ 7:0] ps2c_filter, ps2d_filter;

	// Registers for shifting in PS/2 data bits
	reg [10:0] shift1, shift2;

	// Registered version of PS2Cf_stable for edge detection
	reg PS2Cf_stable_d;
	wire PS2Cf_negedge; // Signal indicating falling edge of stable PS2Cf

	// Output assignment (combinational)
	assign xkey = {shift2[8:1], shift1[8:1]}; // Combines data from two shift registers

	// Filter logic: clocked by clk, reset by clr
	// Generates stable filtered PS2C (PS2Cf_stable) and PS2D (PS2Df_stable)
	// Also generates delayed version of PS2Cf_stable for edge detection
	always @ (posedge clk or posedge clr)
	begin
		if (clr == 1)
		begin
			ps2c_filter <= 8'hFF; // Initialize filter to all 1s
			ps2d_filter <= 8'hFF; // Initialize filter to all 1s
			PS2Cf_stable <= 1'b1;  // Initialize stable filtered clock high (idle)
			PS2Df_stable <= 1'b1;  // Initialize stable filtered data high (idle)
			PS2Cf_stable_d <= 1'b1; // Initialize delayed stable filtered clock high
		end
		else
		begin
			// Update shift registers for filtering
			ps2c_filter <= {ps2c, ps2c_filter[7:1]};
			ps2d_filter <= {ps2d, ps2d_filter[7:1]};

			// Update stable filtered clock based on filter state
			if (ps2c_filter == 8'b1111_1111)
				PS2Cf_stable <= 1'b1;
			else if (ps2c_filter == 8'b0000_0000)
				PS2Cf_stable <= 1'b0;
			// else PS2Cf_stable retains its value (explicit hold)

			// Update stable filtered data based on filter state
			if (ps2d_filter == 8'b1111_1111)
				PS2Df_stable <= 1'b1;
			else if (ps2d_filter == 8'b0000_0000)
				PS2Df_stable <= 1'b0;
			// else PS2Df_stable retains its value (explicit hold)

			// Update delayed version of stable filtered clock for edge detection
			PS2Cf_stable_d <= PS2Cf_stable;
		end
	end

	// Detect falling edge of the stable filtered clock signal (1 -> 0 transition)
	assign PS2Cf_negedge = PS2Cf_stable_d & ~PS2Cf_stable;

	// Data capture logic: clocked by clk, reset by clr, enabled by PS2Cf_negedge
	// This block is now synchronous to the primary clock 'clk'
	always @ (posedge clk or posedge clr) // Sensitivity list uses primary clock and reset
	begin
		if (clr == 1)
		begin
			shift1 <= 11'b0; // Reset shift register 1
			shift2 <= 11'b1; // Reset shift register 2 (kept original reset value)
		end
		else if (PS2Cf_negedge) // Shift only on the clock cycle where falling edge is detected
		begin
			// Use the stable filtered data value (PS2Df_stable) captured in the same clock cycle
			shift1 <= {PS2Df_stable, shift1[10:1]}; // Shift in stable filtered data
			shift2 <= {shift1[0], shift2[10:1]}; // Shift previous data bit (original logic)
		end
		// No else needed: registers hold their value if not reset and PS2Cf_negedge is low
	end

endmodule