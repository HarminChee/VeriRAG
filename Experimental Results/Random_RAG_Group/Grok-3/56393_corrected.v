module hi_read_tx(
    input wire pck0, 
    input wire ck_1356meg, 
    input wire ck_1356megb,
    input wire test_i,
    output wire pwr_lo, 
    output wire pwr_hi, 
    output wire pwr_oe1, 
    output wire pwr_oe2, 
    output wire pwr_oe3, 
    output wire pwr_oe4,
    input wire [7:0] adc_d,
    output wire adc_clk,
    input wire ssp_dout,
    output wire ssp_frame, 
    output wire ssp_din, 
    output wire ssp_clk,
    input wire cross_hi, 
    input wire cross_lo,
    output wire dbg,
    input wire shallow_modulation
);

assign pwr_lo = 1'b0;
assign pwr_oe2 = 1'b0;

reg pwr_hi;
reg pwr_oe1;
reg pwr_oe3;
reg pwr_oe4;

wire dft_ck_1356meg;
assign dft_ck_1356meg = test_i ? pck0 : ck_1356meg;

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
always @(posedge dft_ck_1356meg)
    hi_div_by_128 <= hi_div_by_128 + 1;

assign ssp_clk = hi_div_by_128[6];

reg [2:0] hi_byte_div;
always @(negedge ssp_clk)
    hi_byte_div <= hi_byte_div + 1;

assign ssp_frame = (hi_byte_div == 3'b000);
assign adc_clk = dft_ck_1356meg;

reg after_hysteresis;
always @(negedge adc_clk)
begin
    if(& adc_d[7:0]) after_hysteresis <= 1'b1;
    else if(~(| adc_d[7:0])) after_hysteresis <= 1'b0;
end

assign ssp_din = after_hysteresis;
assign dbg = ssp_din;

endmodule