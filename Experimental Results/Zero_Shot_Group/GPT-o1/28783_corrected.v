module hi_simulate(
    pck0, ck_1356meg, ck_1356megb,
    pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4,
    adc_d, adc_clk,
    ssp_frame, ssp_din, ssp_dout, ssp_clk,
    cross_hi, cross_lo,
    dbg,
    mod_type
);
    input pck0, ck_1356meg, ck_1356megb;
    output pwr_lo, pwr_hi, pwr_oe1, pwr_oe2, pwr_oe3, pwr_oe4;
    input [7:0] adc_d;
    output adc_clk;
    input ssp_dout;
    output ssp_frame, ssp_din, ssp_clk;
    input cross_hi, cross_lo;
    output dbg;
    input [2:0] mod_type;

    assign pwr_hi = 1'b0;
    assign pwr_lo = 1'b0;

    reg after_hysteresis;
    assign adc_clk = ck_1356meg;
    always @(negedge adc_clk) begin
        if (&adc_d[7:5])
            after_hysteresis <= 1'b1;
        else if (~(|adc_d[7:5]))
            after_hysteresis <= 1'b0;
    end

    reg [6:0] ssp_clk_divider;
    always @(posedge adc_clk) begin
        ssp_clk_divider <= ssp_clk_divider + 1;
    end
    assign ssp_clk = ssp_clk_divider[4];

    reg [2:0] ssp_frame_divider_to_arm;
    always @(posedge ssp_clk) begin
        ssp_frame_divider_to_arm <= ssp_frame_divider_to_arm + 1;
    end

    reg [2:0] ssp_frame_divider_from_arm;
    always @(negedge ssp_clk) begin
        ssp_frame_divider_from_arm <= ssp_frame_divider_from_arm + 1;
    end

    reg ssp_frame_reg;
    assign ssp_frame = ssp_frame_reg;
    always @(*) begin
        if (mod_type == 3'b000) 
            ssp_frame_reg = (ssp_frame_divider_to_arm == 3'b000);
        else
            ssp_frame_reg = (ssp_frame_divider_from_arm == 3'b000);
    end

    reg ssp_din_reg;
    assign ssp_din = ssp_din_reg;
    always @(posedge ssp_clk) begin
        ssp_din_reg <= after_hysteresis;
    end

    reg modulating_carrier;
    always @(*) begin
        case (mod_type)
            3'b000: modulating_carrier = 1'b0;
            3'b001: modulating_carrier = ssp_dout ^ ssp_clk_divider[3];
            3'b010: modulating_carrier = ssp_dout & ssp_clk_divider[5];
            3'b100: modulating_carrier = ssp_dout & ssp_clk_divider[4];
            default: modulating_carrier = 1'b0;
        endcase
    end

    assign pwr_oe2 = modulating_carrier;
    assign pwr_oe1 = modulating_carrier;
    assign pwr_oe4 = modulating_carrier;
    assign pwr_oe3 = 1'b0;

    assign dbg = after_hysteresis;
endmodule