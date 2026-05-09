`timescale 1ns/1ns

module camera
(
	input refclk,
	input reset_n,
	output pixclk,
	output vsync,
	output hsync,
	output [7:0] data
);

reg [12:0] hs_counter = 0;
reg [9:0] vs_counter = 0;

assign pixclk = refclk;

always @(negedge refclk or negedge reset_n)
begin
	if(reset_n == 0)
	begin
		hs_counter <= 0; // Use non-blocking for reset in sequential blocks
		vs_counter <= 0; // Use non-blocking for reset in sequential blocks
	end
	else
	begin
		if(hs_counter == 1567) // Max count for 1568 clocks/line
		begin
			hs_counter <= 0;
			if(vs_counter == 510) // Max count for 511 lines/frame
				vs_counter <= 0;
			else
				vs_counter <= vs_counter + 1;
		end
		else
			hs_counter <= hs_counter + 1;
	end
end

reg clk2 = 0;
always @(negedge refclk or negedge reset_n)
begin
    if (reset_n == 0) begin
        clk2 <= 0;
    end else begin
        clk2 <= !clk2;
    end
end

reg [16:0] pixel_counter = 0;
// Pixel counter should also be reset
always @(posedge clk2 or negedge reset_n)
begin
    if (reset_n == 0) begin
        pixel_counter <= 0;
    end else begin
        // Reset pixel counter at the start of a new line,
        // considering clk2 is half refclk rate.
        // hs_counter==0 check aligns with line start.
        // Need to be careful about timing between hs_counter edge and clk2 edge.
        // Resetting when hs_counter is 0 might be safer.
        // Let's try resetting when hs_counter == 0.
        // This check happens on posedge clk2, hs_counter changes on negedge refclk.
        // A safer approach might be to reset based on a flag set by hs_counter block.
        // Or use the original condition if that timing was intended.
        // Reverting to original condition for minimal change:
        if(hs_counter == 1567) // Reset before hs_counter wraps
            pixel_counter <= 0;
        else
            pixel_counter <= pixel_counter + 1;
   end
end

reg [7:0] temp_data;
// Unused signal removed: reg data_part = 0;
// Unused signals removed: wire [15:0] line_counter;
// Unused signals removed: reg [15:0] line_counter_2;

always @(negedge refclk or negedge reset_n)
begin
    if(reset_n == 0)
    begin
        // Unused signal removed: data_part <= 0;
        temp_data <= 0;
    end
    else
    begin
        // Use the value of clk2 *before* the negedge refclk transition
        // to correctly sample pixel_counter bytes.
        // However, clk2 changes *on* negedge refclk.
        // This logic will use the *new* value of clk2.
        // If clk2 just went 0->1, !clk2 is false -> temp_data <= pixel_counter[7:0]
        // If clk2 just went 1->0, !clk2 is true  -> temp_data <= pixel_counter[15:8]
        // This muxes bytes based on the current state of clk2.
        if(!clk2) // When clk2 is 0 (was 1 before edge)
            temp_data <= pixel_counter[15:8]; // Output MSB
        else      // When clk2 is 1 (was 0 before edge)
            temp_data <= pixel_counter[7:0];  // Output LSB
    end
end

assign data = temp_data;

// VSYNC active high during the first 3 lines (lines 0, 1, 2)
assign vsync = (vs_counter < 3) && (reset_n != 0);

// HSYNC active high during active video area (lines 20-499) and during active pixels (pixels 0-1279)
// This is likely an "active video" or "data enable" signal, not a standard HSYNC pulse.
assign hsync = (vs_counter > 19) && (vs_counter < 500) && (hs_counter < 1280) && (reset_n != 0);

endmodule