`timescale 1ns/1ns

// Module name changed as requested
module camera_corrected_cdf
(
	input refclk,
	input reset_n,
	output pixclk,
	output vsync,
	output hsync,
	output [7:0] data
);

reg [12:0] hs_counter = 13'd0; // Explicit sizing and initialization
reg [9:0] vs_counter = 10'd0;  // Explicit sizing and initialization

// pixclk assignment remains, not a CDFDAT issue for internal flops
assign pixclk = refclk;

// Hsync/Vsync counters - Added asynchronous reset sensitivity
always @(negedge refclk or negedge reset_n)
begin
	if(reset_n == 0)
		begin
			hs_counter <= 13'd0;
			vs_counter <= 10'd0;
		end
	else
		begin
			if(hs_counter == 13'd1567) // Explicit sizing
			begin
				hs_counter <= 13'd0;
				if(vs_counter == 10'd510) // Explicit sizing
					vs_counter <= 10'd0;
				else
					vs_counter <= vs_counter + 1;
			end
			else
				hs_counter <= hs_counter + 1;
		end
end

// Internal divided clock generation - Added asynchronous reset
reg clk2 = 1'b0; // Initialization
always @(negedge refclk or negedge reset_n)
begin
    if (reset_n == 0) begin
        clk2 <= 1'b0;
    end else begin
	    clk2 <= !clk2;
    end
end

// Pixel counter - Added asynchronous reset
reg [16:0] pixel_counter = 17'd0; // Explicit sizing and initialization
always @(posedge clk2 or negedge reset_n)
begin
    if (reset_n == 0) begin
        pixel_counter <= 17'd0;
    end else begin
	    // Logic depends on hs_counter (from refclk domain). Assume handled by timing constraints.
	    if(hs_counter == 13'd1566) // Explicit sizing
		    pixel_counter <= 17'd0;
	    else
		    pixel_counter <= pixel_counter + 1;
    end
end

// -- CDFDAT Fix --
// The original code used 'clk2' (a clock signal) to select data for 'temp_data',
// which is clocked by 'refclk'. This can cause testability issues.
// Fix: Register the control signal 'clk2' in the 'refclk' domain.
reg clk2_reg = 1'b0; // Register to hold clk2 value synchronous to negedge refclk
always @(negedge refclk or negedge reset_n) begin
  if (reset_n == 0) begin
    clk2_reg <= 1'b0; // Reset value for the registered control signal
  end else begin
    clk2_reg <= clk2; // Capture clk2 value on negedge refclk
  end
end

// Data output register - Added asynchronous reset
reg [7:0] temp_data;
// Removed unused wire line_counter and regs line_counter_2, data_part

always @(negedge refclk or negedge reset_n)
begin
    if(reset_n == 0)
        begin
            temp_data <= 8'd0;
        end
    else
        begin
            // Use the registered control signal 'clk2_reg' instead of 'clk2'
            if(!clk2_reg)
                temp_data[7:0] <= pixel_counter[15:8];
            else
                temp_data[7:0] <= pixel_counter[7:0];
        end
end

assign data = temp_data;

// Combinational logic for sync signals - simplified reset check
assign vsync = (vs_counter < 10'd3) && (reset_n != 1'b0);
assign hsync = (vs_counter > 10'd19) && (vs_counter < 10'd500) && (hs_counter < 13'd1280) && (reset_n != 1'b0);

endmodule