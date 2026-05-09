module lo_passthru(
    pck0, ck_1356meg, ck_1356megb,
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk,
    cross_hi, cross_lo,
    dbg, divisor
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
reg [7:0] pck_divider;
reg ant_lo;
always @(posedge pck0)
begin
	if(pck_divider == divisor[7:0])
		begin
			pck_divider <= 8'd0;
			ant_lo = !ant_lo;
		end
	else
	begin
		pck_divider <= pck_divider + 1;
	end
end
assign pwr_oe3 = 1'b0;
assign pwr_oe1 = ssp_dout;
assign pwr_oe2 = ssp_dout;
assign pwr_oe4 = ssp_dout;
assign pwr_lo = ant_lo && ssp_dout;
assign pwr_hi = 1'b0;
assign adc_clk = 1'b0;
assign ssp_din = cross_lo;
assign dbg = cross_lo;
endmodule
