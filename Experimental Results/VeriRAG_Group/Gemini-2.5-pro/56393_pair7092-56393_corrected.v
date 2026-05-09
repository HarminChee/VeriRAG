module hi_read_tx(
    pck0, ck_1356meg, ck_1356megb,
    test_i, // Added test_i input for DFT
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk,
    cross_hi, cross_lo,
    dbg,
    shallow_modulation
);
    input pck0, ck_1356meg, ck_1356megb;
    input test_i; // Added test_i input for DFT
    output pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4;
    input [7:0] adc_d;
    output adc_clk;
    input ssp_dout;
    output ssp_frame, ssp_din, ssp_clk;
    input cross_hi, cross_lo;
    output dbg;
    input shallow_modulation;

assign pwr_lo = 1'b0;
assign pwr_oe2 = 1'b0;
reg pwr_hi;
reg pwr_oe1;
reg pwr_oe3;
reg pwr_oe4;
always @(ck_1356megb or ssp_dout or shallow_modulation)
begin
    if(shallow_modulation)
    begin
        pwr_hi <= ck_1356megb;
        pwr_oe1 <= 1'b0;
        pwr_oe3 <= 1'b0;
        pwr_oe4 <= ~ssp_dout;
    end
    else
    begin
        pwr_hi <= ck_1356megb & ssp_dout;
        pwr_oe1 <= 1'b0;
        pwr_oe3 <= 1'b0;
        pwr_oe4 <= 1'b0;
    end
end

reg [6:0] hi_div_by_128;
always @(posedge ck_1356meg)
    hi_div_by_128 <= hi_div_by_128 + 1;

wire ssp_clk_internal = hi_div_by_128[6]; // Internal generated clock signal
assign ssp_clk = ssp_clk_internal; // Assign internal signal to output port

wire dft_ssp_clk; // DFT clock signal for hi_byte_div FF
// Mux to select primary clock in test mode, internal clock in functional mode
assign dft_ssp_clk = test_i ? ck_1356meg : ssp_clk_internal;

reg [2:0] hi_byte_div;
// Use the DFT-muxed clock signal, keeping the original negedge sensitivity for functional mode
always @(negedge dft_ssp_clk)
    hi_byte_div <= hi_byte_div + 1;

assign ssp_frame = (hi_byte_div == 3'b000);
assign adc_clk = ck_1356meg;

reg after_hysteresis;
// This FF is clocked by negedge adc_clk (which is negedge ck_1356meg)
// Keeping as is, assuming negedge of primary clock is acceptable or handled by DFT tools
always @(negedge adc_clk)
begin
    if(& adc_d[7:0]) after_hysteresis <= 1'b1;
    else if(~(| adc_d[7:0])) after_hysteresis <= 1'b0;
end

assign ssp_din = after_hysteresis;
assign dbg = ssp_din;

endmodule