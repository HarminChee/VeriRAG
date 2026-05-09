////////////////////////////////////////////////////////////////
// File:   vga_sync.v
// Author: BBB (based on Terasic module VGA_Ctrl.v)
// About:  Same VGA controller from vga_demo except push button
// 		   logic has been removed and input RGB data added.
// Modified: Corrected errors related to sync generation and counter clocking.
////////////////////////////////////////////////////////////////

module vga_sync #(
	parameter H_TOTAL_WIDTH = 11, // Min bits needed for H_TOTAL = ceil(log2(1040+1))=11
	parameter V_TOTAL_WIDTH = 11, // Min bits needed for V_TOTAL = ceil(log2(666+1))=10 (11 is safe)

	//0 for active low, 1 for active high sync polarity
	parameter POLARITY		= 1'b0, // Common VGA is active low

	// Horizontal Timing (800x600 @ 72Hz, pixel clock approx 50MHz)
	// Values below match common 800x600@60Hz (pixel clock 40MHz)
	// Adjust parameters based on target resolution and refresh rate
	parameter H_FRONT 		= 40,   // Horizontal Front Porch
	parameter H_SYNC		= 128,  // Horizontal Sync Pulse Width
	parameter H_BACK 		= 88,   // Horizontal Back Porch
	parameter H_ACT 		= 800,  // Horizontal Active Pixels

	// Vertical Timing (800x600 @ 72Hz)
	// Values below match common 800x600@60Hz
	parameter V_FRONT 		= 1,    // Vertical Front Porch
	parameter V_SYNC		= 4,    // Vertical Sync Pulse Width
	parameter V_BACK 		= 23,   // Vertical Back Porch
	parameter V_ACT 		= 600   // Vertical Active Lines
)(

	input wire 							clock,    // Pixel clock
	input wire 							aresetn,  // Asynchronous reset, active low

	//Input Data
	input wire [9:0] 					R_in,
	input wire [9:0] 					G_in,
	input wire [9:0] 					B_in,

	//Output Control Logic (Pixel Coordinates)
	output wire [(H_TOTAL_WIDTH-1):0] 	current_x, // Active Horizontal Pixel Coordinate (0 to H_ACT-1)
	output wire [(V_TOTAL_WIDTH-1):0] 	current_y, // Active Vertical Pixel Coordinate (0 to V_ACT-1)
	output wire 					  	ready,     // High during active display area

	//Output VGA Signals
	output wire 						vga_clk,   // VGA Clock (often inverted pixel clock)
	output reg [7:0] 					R_out,     // 8-bit Red Output
	output reg [7:0] 					G_out,     // 8-bit Green Output
	output reg [7:0] 					B_out,     // 8-bit Blue Output
	output reg 							h_sync,    // Horizontal Sync Signal
	output reg 							v_sync,    // Vertical Sync Signal
	output wire 						blank_n,   // Blanking Signal (active low during blanking)
	output wire 						sync_n     // Composite Sync Signal (typically active low)
);

// Calculated Parameters
localparam	H_BLANK	= H_FRONT+H_SYNC+H_BACK; // Total horizontal blanking interval duration
localparam	H_TOTAL	= H_FRONT+H_SYNC+H_BACK+H_ACT; // Total horizontal duration (pixels per line)
localparam	V_BLANK	= V_FRONT+V_SYNC+V_BACK; // Total vertical blanking interval duration
localparam	V_TOTAL	= V_FRONT+V_SYNC+V_BACK+V_ACT; // Total vertical duration (lines per frame)

// Sanity check parameter widths
initial begin
    if (H_TOTAL > (1 << H_TOTAL_WIDTH)) begin
        $display("Error: H_TOTAL_WIDTH (%0d) is too small for H_TOTAL (%0d)", H_TOTAL_WIDTH, H_TOTAL);
        $finish;
    end
    if (V_TOTAL > (1 << V_TOTAL_WIDTH)) begin
        $display("Error: V_TOTAL_WIDTH (%0d) is too small for V_TOTAL (%0d)", V_TOTAL_WIDTH, V_TOTAL);
        $finish;
    end
end

// Internal Signals
reg [(H_TOTAL_WIDTH-1):0] hor_pos; // Horizontal counter (0 to H_TOTAL-1)
reg [(V_TOTAL_WIDTH-1):0] ver_pos; // Vertical counter (0 to V_TOTAL-1)

wire h_sync_period; // High during the horizontal sync pulse period
wire v_sync_period; // High during the vertical sync pulse period
wire active_area;   // High during the active display area
wire end_of_line;   // High for one clock cycle at the end of a horizontal line
wire end_of_frame;  // High for one clock cycle at the end of a vertical frame (at end of last line)

// Clock Output (Often inverted for VGA DACs like ADV7123)
assign vga_clk = clock; // Or assign vga_clk = ~clock; depending on hardware requirement

// Counters
assign end_of_line = (hor_pos == H_TOTAL - 1);
assign end_of_frame = end_of_line && (ver_pos == V_TOTAL - 1);

// Horizontal Counter
always @(posedge clock or negedge aresetn) begin
	if (~aresetn) begin
		hor_pos <= 'd0;
	end else begin
		if (end_of_line) begin
			hor_pos <= 'd0;
		end else begin
			hor_pos <= hor_pos + 1;
		end
	end
end

// Vertical Counter
always @(posedge clock or negedge aresetn) begin
	if (~aresetn) begin
		ver_pos <= 'd0;
	end else begin
		if (end_of_line) begin // Only check vertical position at the end of a line
			if (ver_pos == V_TOTAL - 1) begin
				ver_pos <= 'd0;
			end else begin
				ver_pos <= ver_pos + 1;
			end
		end
        // else: hold ver_pos value during the line
	end
end

// Determine Active Display Area and Sync Periods (Combinational)
assign h_sync_period = (hor_pos >= H_FRONT) && (hor_pos < (H_FRONT + H_SYNC));
assign v_sync_period = (ver_pos >= V_FRONT) && (ver_pos < (V_FRONT + V_SYNC));
assign active_area   = (hor_pos >= H_BLANK) && (ver_pos >= V_BLANK);

// Generate Output Sync Signals (Registered)
// Sync signals generated based on counter positions and POLARITY parameter
always @(posedge clock or negedge aresetn) begin
    if (~aresetn) begin
        h_sync <= ~POLARITY; // Start in inactive state based on polarity
        v_sync <= ~POLARITY; // Start in inactive state based on polarity
    end else begin
        h_sync <= (POLARITY == 1'b1) ? h_sync_period : ~h_sync_period;
        v_sync <= (POLARITY == 1'b1) ? v_sync_period : ~v_sync_period;
    end
end

// RGB Data Output (Registered)
// Output 0 during blanking intervals, otherwise pass through input data (truncated)
always @(posedge clock or negedge aresetn) begin
	if (~aresetn) begin
		R_out <= 8'd0;
		G_out <= 8'd0;
		B_out <= 8'd0;
	end else begin
		if (active_area) begin
			R_out <= R_in[9:2]; // Use top 8 bits
			G_out <= G_in[9:2]; // Use top 8 bits
			B_out <= B_in[9:2]; // Use top 8 bits
		end else begin
			R_out <= 8'd0;
			G_out <= 8'd0;
			B_out <= 8'd0;
		end
	end
end

// Blanking Signal (High during active area, Low during blanking)
// Common VGA DACs use BLANK# (active low blanking)
assign blank_n = active_area; // Directly reflects active area state

// Composite Sync Output (Typically Active Low)
// Combine HSync and VSync using XOR for composite sync.
// The polarity depends on the standard; usually negative for VGA.
// sync_n = ~(h_sync ^ v_sync) provides active-low composite sync
assign sync_n = ~(h_sync ^ v_sync);
// Alternative: If only HSync is needed on sync pin: assign sync_n = ~h_sync; (assuming POLARITY=0)
// Alternative: If only VSync is needed on sync pin: assign sync_n = ~v_sync; (assuming POLARITY=0)

// Pixel Coordinate Outputs (Combinational)
// Calculate coordinates relative to the start of the active area (0,0)
assign current_x = active_area ? (hor_pos - H_BLANK) : 'd0;
assign current_y = active_area ? (ver_pos - V_BLANK) : 'd0;

// Ready Signal (High during active display area)
assign ready = active_area;

endmodule