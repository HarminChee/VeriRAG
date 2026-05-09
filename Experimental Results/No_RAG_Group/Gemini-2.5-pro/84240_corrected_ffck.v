//-----------------------------------------------------------------------------
// The way that we connect things in low-frequency simulation mode. In this
// case just pass everything through to the ARM, which can bit-bang this
// (because it is so slow).
//
// Jonathan Westhues, April 2006
// Modified for DFT FFCKNP Compliance
//-----------------------------------------------------------------------------

module lo_edge_detect(
    pck0, ck_1356meg, ck_1356megb,
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk,
    cross_hi, cross_lo,
    dbg,
	  divisor,
		lf_field
);
    input pck0; // Primary clock input
    input ck_1356meg, ck_1356megb; // Unused in this context?
    output pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4;
    input [7:0] adc_d;
    output adc_clk;
    input ssp_dout;
    output ssp_frame, ssp_din, ssp_clk;
    input cross_hi, cross_lo;
    output dbg;
	  input [7:0] divisor;
		input lf_field;

// Divide the clock to be used for the ADC
reg [7:0] pck_divider;
reg clk_state;

wire tag_modulation;
assign tag_modulation = ssp_dout & !lf_field;
wire reader_modulation;
assign reader_modulation = !ssp_dout & lf_field & clk_state;

// No logic, straight through.
assign pwr_oe1 = 1'b0; // not used in LF mode
assign pwr_oe2 = tag_modulation;
assign pwr_oe3 = tag_modulation;
assign pwr_oe4 = tag_modulation;
assign ssp_clk = cross_lo; // Note: Using data signal as clock output is generally bad DFT practice
assign pwr_lo = reader_modulation;
assign pwr_hi = 1'b0;
assign dbg = ssp_frame;
assign ssp_din = 1'b0; // Assign a default value if not driven otherwise

// Clock divider logic - clocked by primary clock pck0
always @(posedge pck0)
begin
	if(pck_divider == divisor[7:0])
		begin
			pck_divider <= 8'd0;
			clk_state <= !clk_state; // Use non-blocking assignment
		end
	else
	begin
		pck_divider <= pck_divider + 1;
	end
end

// adc_clk generation - derived from a flop, but not clocking internal flops in *this* module
// This might still be flagged by some DFT tools as a generated clock output.
assign adc_clk = ~clk_state;

// Toggle the output with hysteresis
//  Set to high if the ADC value is above 190
//  Set to low if the ADC value is below 70
//  Synchronous implementation clocked by pck0
reg output_state;

// Conditions for setting/resetting output_state, calculated combinationally
wire check_condition = (pck_divider == 8'd7) && !clk_state;
wire set_condition   = check_condition && (adc_d >= 8'd190);
wire reset_condition = check_condition && (adc_d <= 8'd70);

// Update output_state synchronously with the primary clock pck0
always @(posedge pck0)
begin
    // Use an SR latch behavior, prioritizing reset if both conditions occur simultaneously
    if (reset_condition) begin
        output_state <= 1'b0;
    end else if (set_condition) begin
        output_state <= 1'b1;
    end
    // If neither condition is met, output_state holds its value
end

assign ssp_frame = output_state;

endmodule