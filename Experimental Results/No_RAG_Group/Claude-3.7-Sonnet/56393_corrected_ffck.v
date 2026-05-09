module hi_read_tx(
    pck0, ck_1356meg, ck_1356megb,
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk,
    cross_hi, cross_lo,
    dbg,
    shallow_modulation,
    clk,
    rst_n
);
    input pck0, ck_1356meg, ck_1356megb;
    output pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4;
    input [7:0] adc_d;
    output adc_clk;
    input ssp_dout;
    output ssp_frame, ssp_din, ssp_clk;
    input cross_hi, cross_lo;
    output dbg;
    input shallow_modulation;
    input clk;
    input rst_n;

assign pwr_lo = 1'b0;
assign pwr_oe2 = 1'b0;
reg pwr_hi;
reg pwr_oe1;
reg pwr_oe3;
reg pwr_oe4;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) begin
        pwr_hi <= 1'b0;
        pwr_oe1 <= 1'b0;
        pwr_oe3 <= 1'b0;
        pwr_oe4 <= 1'b0;
    end
    else if(shallow_modulation) begin
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
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        hi_div_by_128 <= 7'b0;
    else
        hi_div_by_128 <= hi_div_by_128 + 1;
end

reg ssp_clk_reg;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        ssp_clk_reg <= 1'b0;
    else
        ssp_clk_reg <= hi_div_by_128[6];
end
assign ssp_clk = ssp_clk_reg;

reg [2:0] hi_byte_div;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        hi_byte_div <= 3'b0;
    else if (!ssp_clk_reg)
        hi_byte_div <= hi_byte_div + 1;
end

assign ssp_frame = (hi_byte_div == 3'b000);
assign adc_clk = clk;

reg after_hysteresis;
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        after_hysteresis <= 1'b0;
    else begin
        if(& adc_d[7:0]) 
            after_hysteresis <= 1'b1;
        else if(~(| adc_d[7:0])) 
            after_hysteresis <= 1'b0;
    end
end

assign ssp_din = after_hysteresis;
assign dbg = ssp_din;

endmodule