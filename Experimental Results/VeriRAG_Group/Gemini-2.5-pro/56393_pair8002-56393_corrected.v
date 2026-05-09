module hi_read_tx(
    pck0, ck_1356meg, ck_1356megb, test_i, // Added test_i input
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk,
    cross_hi, cross_lo,
    dbg,
    shallow_modulation
);
    input pck0, ck_1356meg, ck_1356megb, test_i; // Added test_i
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

// Changed <= to = for combinational logic
always @(ck_1356megb or ssp_dout or shallow_modulation)
begin
    if(shallow_modulation)
    begin
        pwr_hi = ck_1356megb;
        pwr_oe1 = 1'b0;
        pwr_oe3 = 1'b0;
        pwr_oe4 = ~ssp_dout;
    end
    else
    begin
        pwr_hi = ck_1356megb & ssp_dout;
        pwr_oe1 = 1'b0;
        pwr_oe3 = 1'b0;
        pwr_oe4 = 1'b0;
    end
end

reg [6:0] hi_div_by_128;
always @(posedge ck_1356meg)
    hi_div_by_128 <= hi_div_by_128 + 1;

wire ssp_clk_internal; // Renamed original ssp_clk driver
assign ssp_clk_internal = hi_div_by_128[6];
assign ssp_clk = ssp_clk_internal; // Assign to output port

reg [2:0] hi_byte_div;
wire dft_ssp_clk; // DFT clock mux for hi_byte_div

// Mux between functional generated clock and primary test clock
assign dft_ssp_clk = test_i ? ck_1356meg : ssp_clk_internal;

// Clock hi_byte_div with the muxed clock
always @(negedge dft_ssp_clk)
    hi_byte_div <= hi_byte_div + 1;

assign ssp_frame = (hi_byte_div == 3'b000);
assign adc_clk = ck_1356meg;

reg after_hysteresis;
always @(negedge adc_clk) // This FF is clocked by primary clock derived signal (neg edge) - OK
begin
    if(& adc_d[7:0]) after_hysteresis <= 1'b1;
    else if(~(| adc_d[7:0])) after_hysteresis <= 1'b0;
end

assign ssp_din = after_hysteresis;
assign dbg = ssp_din;

endmodule