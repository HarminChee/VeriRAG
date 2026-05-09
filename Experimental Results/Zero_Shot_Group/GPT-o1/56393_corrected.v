module hi_read_tx(
    input pck0, 
    input ck_1356meg, 
    input ck_1356megb,
    output pwr_lo, 
    output reg pwr_hi, 
    output reg pwr_oe1, 
    output pwr_oe2, 
    output reg pwr_oe3, 
    output reg pwr_oe4,
    input [7:0] adc_d,
    output adc_clk,
    output ssp_frame, 
    output ssp_din, 
    input ssp_dout, 
    output ssp_clk,
    input cross_hi, 
    input cross_lo,
    output dbg,
    input shallow_modulation
);

assign pwr_lo = 1'b0;
assign pwr_oe2 = 1'b0;

always @(ck_1356megb or ssp_dout or shallow_modulation) begin
    if (shallow_modulation) begin
        pwr_hi <= ck_1356megb;
        pwr_oe1 <= 1'b0;
        pwr_oe3 <= 1'b0;
        pwr_oe4 <= ~ssp_dout;
    end
    else begin
        pwr_hi <= ck_1356megb & ssp_dout;
        pwr_oe1 <= 1'b0;
        pwr_oe3 <= 1'b0;
        pwr_oe4 <= 1'b0;
    end
end

reg [6:0] hi_div_by_128;
always @(posedge ck_1356meg) begin
    hi_div_by_128 <= hi_div_by_128 + 1;
end
assign ssp_clk = hi_div_by_128[6];

reg [2:0] hi_byte_div;
always @(negedge ssp_clk) begin
    hi_byte_div <= hi_byte_div + 1;
end
assign ssp_frame = (hi_byte_div == 3'b000);

assign adc_clk = ck_1356meg;

reg after_hysteresis;
always @(negedge adc_clk) begin
    if (&adc_d[7:0]) after_hysteresis <= 1'b1;
    else if (~(|adc_d[7:0])) after_hysteresis <= 1'b0;
end
assign ssp_din = after_hysteresis;
assign dbg = ssp_din;

endmodule