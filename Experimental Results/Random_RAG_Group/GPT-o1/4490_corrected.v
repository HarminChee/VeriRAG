module lo_simulate(
    input pck0, 
    input ck_1356meg, 
    input ck_1356megb,
    output pwr_lo, 
    output pwr_hi, 
    output pwr_oe1, 
    output pwr_oe2, 
    output pwr_oe3, 
    output pwr_oe4,
    input [7:0] adc_d,
    output adc_clk,
    output ssp_frame, 
    output ssp_din, 
    input ssp_dout, 
    output ssp_clk,
    input cross_hi, 
    input cross_lo,
    output dbg,
    input [7:0] divisor
);

// No logic, straight through.
assign pwr_oe3 = 1'b0;
assign pwr_oe1 = ssp_dout;
assign pwr_oe2 = ssp_dout;
assign pwr_oe4 = ssp_dout;
assign ssp_clk = cross_lo;
assign pwr_lo = 1'b0;
assign pwr_hi = 1'b0;
assign dbg = ssp_frame;
assign ssp_din = 1'b0;

// Divide the clock to be used for the ADC (remove internal clock generation for DFT)
reg [7:0] pck_divider;
reg clk_state;

always @(posedge pck0) begin
	if(pck_divider == divisor) begin
		pck_divider <= 8'd0;
		clk_state <= ~clk_state;
	end
	else begin
		pck_divider <= pck_divider + 1;
	end
end

assign adc_clk = pck0;

// Toggle the output with hysteresis, made fully synchronous
reg is_high;
reg is_low;
reg output_state;

always @(posedge pck0) begin
	if((pck_divider == 8'd7) && !clk_state) begin
		is_high <= (adc_d >= 8'd200);
		is_low <= (adc_d <= 8'd64);
	end

	if(is_high)
		output_state <= 1'b1;
	else if(is_low)
		output_state <= 1'b0;
end

assign ssp_frame = output_state;

endmodule