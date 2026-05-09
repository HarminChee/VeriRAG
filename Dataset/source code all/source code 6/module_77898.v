module lo_read(
    pck0, ck_1356meg, ck_1356megb,
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk,
    cross_hi, cross_lo,
    dbg,
    lo_is_125khz, divisor
);
    input pck0, ck_1356meg, ck_1356megb;
    output pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4;
    input [7:0] adc_d;
    output adc_clk;
    input ssp_dout;
    output ssp_frame, ssp_din, ssp_clk;
    input cross_hi, cross_lo;
    output dbg;
    input lo_is_125khz; 
    input [7:0] divisor;
reg [7:0] to_arm_shiftreg;
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
always @(posedge pck0)
begin
	if((pck_divider == 8'd7) && !ant_lo)
        to_arm_shiftreg <= adc_d;
    else
	begin
        to_arm_shiftreg[7:1] <= to_arm_shiftreg[6:0];
        to_arm_shiftreg[0] <= 1'b0;
	end
end
assign ssp_din = to_arm_shiftreg[7] && !ant_lo;
assign ssp_clk = pck0;
assign ssp_frame = (pck_divider[7:3] == 5'd1) && !ant_lo;
assign pwr_hi = 1'b0;
assign pwr_oe1 = 1'b0;
assign pwr_oe2 = 1'b0;
assign pwr_oe3 = 1'b0;
assign pwr_oe4 = 1'b0;
assign pwr_lo = ant_lo;
assign adc_clk = ~ant_lo;
assign dbg = adc_clk;
endmodule
