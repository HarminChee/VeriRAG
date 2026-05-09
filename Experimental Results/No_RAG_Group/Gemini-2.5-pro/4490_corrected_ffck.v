//-----------------------------------------------------------------------------
// The way that we connect things in low-frequency simulation mode. In this
// case just pass everything through to the ARM, which can bit-bang this
// (because it is so slow).
//
// Jonathan Westhues, April 2006
// Corrected for FFCKNP DFT violation.
//-----------------------------------------------------------------------------

module lo_simulate_corrected_ffc (
    pck0, ck_1356meg, ck_1356megb,
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk,
    cross_hi, cross_lo,
    dbg,
	 divisor
);
    input pck0, ck_1356meg, ck_1356megb; // pck0 is the primary clock
    output pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4;
    input [7:0] adc_d;
    output adc_clk;
    input ssp_dout;
    output ssp_frame, ssp_din, ssp_clk;
    input cross_hi, cross_lo;
    output dbg;
	 input [7:0] divisor;

// No logic, straight through.
assign pwr_oe3 = 1'b0;
assign pwr_oe1 = ssp_dout;
assign pwr_oe2 = ssp_dout;
assign pwr_oe4 = ssp_dout;
assign ssp_clk = cross_lo; // Assuming cross_lo is acceptable or comes from primary input/test logic
assign pwr_lo = 1'b0;
assign pwr_hi = 1'b0;
assign dbg = ssp_frame;
// ssp_din is undriven, should be assigned if used. Assigning default value.
assign ssp_din = 1'b0;

// Divide the clock to be used for the ADC
reg [7:0] pck_divider;
reg clk_state;

always @(posedge pck0)
begin
	if(pck_divider == divisor[7:0])
		begin
			pck_divider <= 8'd0;
			clk_state <= !clk_state; // Use non-blocking assignment for registers
		end
	else
	begin
		pck_divider <= pck_divider + 1;
	end
end

assign adc_clk = ~clk_state; // adc_clk is derived, but not used to clock internal FFs directly in this module

// Toggle the output with hysteresis based on ADC value, clocked by primary clock pck0
// Set to high if the ADC value is above 200
// Set to low if the ADC value is below 64
reg output_state;
// Removed is_high and is_low registers to avoid using them as clocks

always @(posedge pck0)
begin
    // Sample ADC value and update output_state based on hysteresis thresholds
    // The sampling happens when the divider logic indicates, e.g., (pck_divider == 8'd7) && !clk_state
    // This ensures output_state is clocked directly by the primary clock pck0
	 if ((pck_divider == 8'd7) && !clk_state) begin // Condition to sample ADC value
        if (adc_d >= 8'd200) begin
            output_state <= 1'b1; // Set high
        end else if (adc_d <= 8'd64) begin
            output_state <= 1'b0; // Set low
        end
        // If adc_d is between 64 and 200, output_state retains its previous value (hysteresis)
    end
end

assign ssp_frame = output_state;

endmodule