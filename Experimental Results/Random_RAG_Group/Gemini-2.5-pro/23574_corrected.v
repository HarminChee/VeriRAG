`timescale 1ns/1ns
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

// Use primary clock directly
assign pixclk = refclk;

// Horizontal and Vertical Sync Counters clocked by primary clock
always @(negedge refclk or negedge reset_n)
begin
	if(reset_n == 0)
		begin
			hs_counter <= 0;
			vs_counter <= 0;
		end
	else
		begin
			if(hs_counter == 1567) // Example values, assuming 800x600@60Hz-like timing
			begin
				hs_counter <= 0;
				if(vs_counter == 510) // Example values
					vs_counter <= 0;
				else
					vs_counter <= vs_counter + 1;
			end
			else
			hs_counter <= hs_counter + 1;
		end
end

// Generate enable signal instead of a derived clock
reg toggle_ff = 0;
reg toggle_ff_dly = 0;
wire pixel_counter_enable;

// Toggle FF clocked by primary clock and reset by primary reset
always @(negedge refclk or negedge reset_n)
begin
  if (!reset_n) begin
      toggle_ff <= 1'b0;
      toggle_ff_dly <= 1'b0;
  end
  else begin
      toggle_ff <= ~toggle_ff;
      toggle_ff_dly <= toggle_ff; // Store previous state for data muxing
  end
end

// Enable signal derived from toggle FF state
assign pixel_counter_enable = toggle_ff; // Enable on one phase

// Pixel Counter clocked by primary clock, enabled by derived enable, reset by primary reset
reg [16:0] pixel_counter = 0;
always @(negedge refclk or negedge reset_n)
begin
	if (!reset_n) begin
		pixel_counter <= 0;
	end
	else begin
      // Reset condition based on horizontal counter (matches original logic intent)
      // Note: Original logic used hs_counter == 1566 on posedge clk2.
      // This needs careful translation. Let's assume reset at end of line.
      // If hs_counter resets on 1567->0, then 1566 is the cycle before it increments to 1567.
      // Check timing: hs_counter increments on negedge refclk.
      // If hs_counter == 1567 on a negedge, it means the line ended. Reset pixel counter.
		if(hs_counter == 1567) begin // Reset at the start of the new line cycle
			pixel_counter <= 0;
      end
		else if (pixel_counter_enable) begin // Increment only when enabled (half rate)
			pixel_counter <= pixel_counter + 1;
      end
	end
end

// Data register clocked by primary clock and reset by primary reset
reg [7:0] temp_data;
always @(negedge refclk or negedge reset_n)
begin
    if(reset_n == 0) begin
        temp_data <= 0;
    end
    else begin
        // Use the delayed toggle state to mimic original sampling behavior
        // If toggle_ff_dly is 0 (was 0 before edge), sample upper byte.
        // If toggle_ff_dly is 1 (was 1 before edge), sample lower byte.
        // This corresponds to the state *before* the current negedge refclk.
        if (!toggle_ff_dly) begin // Corresponds to original !clk2 condition
            temp_data <= pixel_counter[15:8];
        end
        else begin // Corresponds to original clk2 condition
            temp_data <= pixel_counter[7:0];
        end
    end
end

assign data = temp_data;

// Combinational assignments for sync signals using primary reset
assign vsync = (vs_counter < 3) && reset_n; // Simplified condition, adjust based on actual spec
assign hsync = (vs_counter > 19 && vs_counter < 500 && hs_counter < 1280) && reset_n; // Simplified condition

// Unused signals from original code removed (line_counter, line_counter_2, data_part)

endmodule