`timescale 1ns / 1ps
module hi_read_tx(
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
    input shallow_modulation,
    input test_i
);
reg pwr_hi_reg;
reg pwr_oe1_reg;
reg pwr_oe3_reg;
reg pwr_oe4_reg;
assign pwr_lo = 1'b0;
assign pwr_oe2 = 1'b0;
assign pwr_hi = pwr_hi_reg;
assign pwr_oe1 = pwr_oe1_reg;
assign pwr_oe3 = pwr_oe3_reg;
assign pwr_oe4 = pwr_oe4_reg;

always @(posedge ck_1356megb) begin
    if(shallow_modulation) begin
        pwr_hi_reg <= ck_1356megb;
        pwr_oe1_reg <= 1'b0;
        pwr_oe3_reg <= 1'b0;
        pwr_oe4_reg <= ~ssp_dout;
    end
    else begin
        pwr_hi_reg <= ck_1356megb & ssp_dout;
        pwr_oe1_reg <= 1'b0;
        pwr_oe3_reg <= 1'b0;
        pwr_oe4_reg <= 1'b0;
    end
end

reg [6:0] hi_div_by_128;
always @(posedge ck_1356meg) begin
    hi_div_by_128 <= hi_div_by_128 + 1;
end
wire functional_ssp_clk = hi_div_by_128[6];
wire dft_ssp_clk = test_i ? ck_1356meg : functional_ssp_clk;
assign ssp_clk = dft_ssp_clk;

reg [2:0] hi_byte_div;
always @(negedge dft_ssp_clk) begin
    hi_byte_div <= hi_byte_div + 1;
end
assign ssp_frame = (hi_byte_div == 3'b000);

assign adc_clk = ck_1356meg;

reg after_hysteresis;
always @(negedge adc_clk) begin
    if(&adc_d[7:0])      after_hysteresis <= 1'b1;
    else if(~(|adc_d[7:0])) after_hysteresis <= 1'b0;
end

assign ssp_din = after_hysteresis;
assign dbg = ssp_din;
endmodule