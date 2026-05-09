//-----------------------------------------------------------------------------
// The way that we connect things in low-frequency simulation mode. In this
// case just pass everything through to the ARM, which can bit-bang this
// (because it is so slow).
//
// Jonathan Westhues, April 2006
// Corrected Verilog Code
//-----------------------------------------------------------------------------

module lo_simulate(
    pck0, ck_1356meg, ck_1356megb,
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk,
    cross_hi, cross_lo,
    dbg,
	 divisor
);
    input pck0, ck_1356meg, ck_1356megb;
    output pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4;
    input [7:0] adc_d;
    output adc_clk;
    input ssp_dout;
    output ssp_frame, ssp_din, ssp_clk;
    input cross_hi, cross_lo;
    output dbg;
	 input [7:0] divisor;

// No logic, straight through assignments (partially)
assign pwr_oe3 = 1'b0;
assign pwr_oe1 = ssp_dout;
assign pwr_oe2 = ssp_dout;
assign pwr_oe4 = ssp_dout;
assign ssp_clk = cross_lo;
assign pwr_lo = 1'b0;
assign pwr_hi = 1'b0;
assign dbg = ssp_frame;
assign ssp_din = 1'b0; // Assign previously unassigned output

// Divide the clock to be used for the ADC
reg [7:0] pck_divider = 8'd0; // Initialize register
reg clk_state = 1'b0;         // Initialize register

always @(posedge pck0)
begin
	if(pck_divider == divisor) // Use divisor directly
		begin
			pck_divider <= 8'd0;
			clk_state <= !clk_state; // Use non-blocking assignment
		end
	else
	begin
		pck_divider <= pck_divider + 1; // Use non-blocking assignment
	end
end

assign adc_clk = ~clk_state;

// Toggle the output with hysteresis based on ADC value
// Sample ADC when pck_divider is 7 and clk_state is low
// Set to high if the ADC value is above 200
// Set to low if the ADC value is below 64
// Otherwise, hold the state
reg output_state = 1'b0; // Initialize register

always @(posedge pck0)
begin
    // Sample ADC value at a specific point in the divided clock cycle
	 if ((pck_divider == 8'd7) && !clk_state) begin
        // Hysteresis logic
		  if (adc_d >= 8'd200) begin
				output_state <= 1'b1; // Use non-blocking assignment
		  end else if (adc_d <= 8'd64) begin
				output_state <= 1'b0; // Use non-blocking assignment
		  end
        // else: output_state retains its previous value (implicit)
	 end
end

assign ssp_frame = output_state;

endmodule