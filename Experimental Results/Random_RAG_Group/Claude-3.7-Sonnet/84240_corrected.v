module lo_edge_detect(
    pck0, ck_1356meg, ck_1356megb,
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk,
    cross_hi, cross_lo,
    dbg,
    divisor,
    lf_field,
    test_mode
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
    input lf_field;
    input test_mode;

reg [7:0] pck_divider;
reg clk_state;

wire tag_modulation; 
assign tag_modulation = ssp_dout & !lf_field;
wire reader_modulation; 
assign reader_modulation = !ssp_dout & lf_field & clk_state;

assign pwr_oe1 = 1'b0;
assign pwr_oe2 = tag_modulation;
assign pwr_oe3 = tag_modulation;
assign pwr_oe4 = tag_modulation;
assign ssp_clk = cross_lo;
assign pwr_lo = reader_modulation;
assign pwr_hi = 1'b0;
assign dbg = ssp_frame;

always @(posedge pck0)
begin
    if(pck_divider == divisor[7:0])
        begin
            pck_divider <= 8'd0;
            clk_state <= !clk_state;
        end
    else
    begin
        pck_divider <= pck_divider + 1;
    end
end

assign adc_clk = ~clk_state;

reg is_high;
reg is_low;
reg output_state;

always @(posedge pck0)
begin
    if((pck_divider == 8'd7) && !clk_state) begin
        is_high <= (adc_d >= 8'd190);
        is_low <= (adc_d <= 8'd70);
    end
end

wire dft_clk;
assign dft_clk = test_mode ? pck0 : is_high;
wire dft_rst;
assign dft_rst = test_mode ? pck0 : is_low;

always @(posedge dft_clk or posedge dft_rst)
begin
    if(dft_rst)
        output_state <= 1'd0;
    else
        output_state <= 1'd1;
end

assign ssp_frame = output_state;
assign ssp_din = 1'b0;

endmodule