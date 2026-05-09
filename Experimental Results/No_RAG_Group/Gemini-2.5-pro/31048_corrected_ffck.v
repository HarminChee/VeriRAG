////////////////////////////////////////////////////////////////
// File:   1_corrected_ffc.v
// Author: BBB (based on Terasic module VGA_Ctrl.v)
// About:  Same VGA controller from vga_demo except push button
// 		   logic has been removed and input RGB data added.
//         Modified to fix FFCKNP DFT violation.
////////////////////////////////////////////////////////////////

module vga_sync #(
	parameter H_TOTAL_WIDTH = 11,
	parameter V_TOTAL_WIDTH = 11,

	//0 for active low, 1 for active high
	parameter POLARITY		= 1'b1,

	parameter H_FRONT 		= 56,
	parameter H_SYNC		= 120,
	parameter H_BACK 		= 64,
	parameter H_ACT 		= 800,

	parameter V_FRONT 		= 37,
	parameter V_SYNC		= 6,
	parameter V_BACK 		= 23,
	parameter V_ACT 		= 600
)(

	input wire 							clock,
	input wire 							aresetn,

	//Input Data
	input wire [9:0] 					R_in,
	input wire [9:0] 					G_in,
	input wire [9:0] 					B_in,

	//Output Control Logic
	output wire [(H_TOTAL_WIDTH-1):0] 	current_x,
	output wire [(V_TOTAL_WIDTH-1):0] 	current_y,
	output wire 					  	ready,

	//Output VGA Signals
	output wire 						vga_clk,
	output reg [7:0] 					R_out,
	output reg [7:0] 					G_out,
	output reg [7:0] 					B_out,
	output reg 							h_sync,
	output reg 							v_sync,
	output wire 						blank_n,
	output wire 						sync_n
);

//Parameters
localparam	H_BLANK	= H_FRONT+H_SYNC+H_BACK;
localparam	H_TOTAL	= H_FRONT+H_SYNC+H_BACK+H_ACT;
localparam	V_BLANK	= V_FRONT+V_SYNC+V_BACK;
localparam	V_TOTAL	= V_FRONT+V_SYNC+V_BACK+V_ACT;

//Internal Signals
reg [(H_TOTAL_WIDTH-1):0] hor_pos;
reg [(V_TOTAL_WIDTH-1):0] ver_pos;
// Removed is_active_high register, use POLARITY directly

//Clock
assign vga_clk = ~clock;

//Position Info (External Logic)
assign current_x = (hor_pos >= H_BLANK) ? hor_pos - H_BLANK : 'd0;
assign current_y = (ver_pos >= V_BLANK) ? ver_pos - V_BLANK : 'd0;

//Horizontal Data
always @(posedge clock or negedge aresetn) begin
	if (~aresetn)
		begin
			hor_pos <= 'd0;
			h_sync  <= POLARITY ? 1'b0 : 1'b1; // Use POLARITY directly
		end
	else
		begin
			// Horizontal counter increments every clock cycle
			if (hor_pos < H_TOTAL - 1)	 hor_pos <= hor_pos + 1;
			else 						 hor_pos <= 0;

			// Horizontal sync generation based on hor_pos
			// Assert h_sync during the H_SYNC period
            // Note: Using '<=' for non-blocking assignment in sequential logic
            // Sync pulse starts after H_FRONT pixels
			if (hor_pos == H_FRONT - 1) begin
                h_sync <= POLARITY ? 1'b1 : 1'b0;
            end
            // Sync pulse ends after H_FRONT + H_SYNC pixels
			if (hor_pos == H_FRONT + H_SYNC - 1) begin
                h_sync <= POLARITY ? 1'b0 : 1'b1;
            end
		end
end

//Vertical Data - Modified to use primary clock 'clock'
always @(posedge clock or negedge aresetn) begin
	if (~aresetn)
		begin
			ver_pos <= 'd0;
			v_sync  <= POLARITY ? 1'b0 : 1'b1; // Use POLARITY directly
		end
	else
		begin
            // Vertical counter increments at the end of each horizontal line (hor_pos == H_TOTAL - 1)
			if (hor_pos == H_TOTAL - 1) begin
                // Check vertical position before incrementing
                // Assert v_sync during the V_SYNC period
                // Sync pulse starts after V_FRONT lines
                if (ver_pos == V_FRONT - 1) begin
                    v_sync <= POLARITY ? 1'b1 : 1'b0;
                end
                // Sync pulse ends after V_FRONT + V_SYNC lines
                if (ver_pos == V_FRONT + V_SYNC - 1) begin
                    v_sync <= POLARITY ? 1'b0 : 1'b1;
                end

                // Increment vertical counter
				if (ver_pos < V_TOTAL - 1) begin
                    ver_pos <= ver_pos + 1;
                end
				else begin
                    ver_pos <= 0;
                end
			end
		end
end

//RGB Data
always @(posedge clock or negedge aresetn) begin
	if (~aresetn)
		begin
			R_out <= 8'd0;
			B_out <= 8'd0;
			G_out <= 8'd0;
		end
	// Blank output during horizontal or vertical blanking intervals
	else if ((hor_pos < H_BLANK) || (ver_pos < V_BLANK)) // Use || for logical OR
		begin
			R_out <= 8'd0;
			B_out <= 8'd0;
			G_out <= 8'd0;
		end
	// Output input RGB data during active video period
	else
		begin
			R_out <= R_in[9:2]; // Use upper 8 bits
			B_out <= B_in[9:2];
			G_out <= G_in[9:2];
		end
end

//Blank (ADV7123) - Active low blanking signal
assign blank_n = ~((hor_pos < H_BLANK) || (ver_pos < V_BLANK)); // Use || for logical OR

//Sync (ADV7123) - Typically unused or grounded for VGA
assign sync_n  = 1'b1;

//Ready (External Logic) - Indicates active display area
assign ready   = ((hor_pos >= H_BLANK && hor_pos < H_TOTAL) && (ver_pos >= V_BLANK && ver_pos < V_TOTAL)); // Use && for logical AND

endmodule