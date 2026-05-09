module hi_read_tx(
    input reset,
    input test_i,
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
    input ssp_dout,
    output ssp_frame,
    output ssp_din,
    output ssp_clk,
    input cross_hi,
    input cross_lo,
    output dbg,
    input shallow_modulation
);

reg r_pwr_hi;
reg r_pwr_oe1;
reg r_pwr_oe3;
reg r_pwr_oe4;
reg [6:0] hi_div_by_128;
reg [2:0] hi_byte_div;
reg after_hysteresis;

assign pwr_lo = 1'b0;
assign pwr_oe2 = 1'b0;
assign pwr_hi = r_pwr_hi;
assign pwr_oe1 = r_pwr_oe1;
assign pwr_oe3 = r_pwr_oe3;
assign pwr_oe4 = r_pwr_oe4;
assign adc_clk = ck_1356meg;

always @(posedge ck_1356megb)
begin
    if(shallow_modulation)
    begin
        r_pwr_hi <= ck_1356megb;
        r_pwr_oe1 <= 1'b0;
        r_pwr_oe3 <= 1'b0;
        r_pwr_oe4 <= ~ssp_dout;
    end
    else
    begin
        r_pwr_hi <= ck_1356megb & ssp_dout;
        r_pwr_oe1 <= 1'b0;
        r_pwr_oe3 <= 1'b0;
        r_pwr_oe4 <= 1'b0;
    end
end

always @(posedge ck_1356meg)
    hi_div_by_128 <= hi_div_by_128 + 1'b1;

wire ssp_clk_int = hi_div_by_128[6];
assign ssp_clk = test_i ? ck_1356meg : ssp_clk_int;

always @(negedge ssp_clk)
    hi_byte_div <= hi_byte_div + 1'b1;

assign ssp_frame = (hi_byte_div == 3'b000);

always @(negedge adc_clk)
begin
    if(&adc_d[7:0])
        after_hysteresis <= 1'b1;
    else if(~(|adc_d[7:0]))
        after_hysteresis <= 1'b0;
end

assign ssp_din = after_hysteresis;
assign dbg = ssp_din;

endmodule