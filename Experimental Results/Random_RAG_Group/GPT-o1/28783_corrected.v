module hi_simulate(
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
    output ssp_frame, 
    output ssp_din, 
    input ssp_dout, 
    output ssp_clk,
    input cross_hi, 
    input cross_lo,
    output dbg,
    input [2:0] mod_type
);

assign pwr_hi = 1'b0;
assign pwr_lo = 1'b0;

wire dft_adc_clk = test_i ? pck0 : ck_1356meg;
assign adc_clk = dft_adc_clk;

reg after_hysteresis;
always @(posedge adc_clk) begin
    if(&adc_d[7:5]) 
        after_hysteresis <= 1'b1;
    else if(~(|adc_d[7:5])) 
        after_hysteresis <= 1'b0;
end

reg [6:0] ssp_clk_divider;
always @(posedge adc_clk)
    ssp_clk_divider <= ssp_clk_divider + 1;

wire dft_ssp_clk = test_i ? pck0 : ssp_clk_divider[4];
assign ssp_clk = dft_ssp_clk;

reg [2:0] ssp_frame_divider_to_arm;
always @(posedge ssp_clk)
    ssp_frame_divider_to_arm <= ssp_frame_divider_to_arm + 1;

reg [2:0] ssp_frame_divider_from_arm;
always @(posedge ssp_clk)
    ssp_frame_divider_from_arm <= ssp_frame_divider_from_arm + 1;

reg ssp_frame_reg;
always @* begin
    if(mod_type == 3'b000) 
        ssp_frame_reg = (ssp_frame_divider_to_arm == 3'b000);
    else
        ssp_frame_reg = (ssp_frame_divider_from_arm == 3'b000);
end
assign ssp_frame = ssp_frame_reg;

reg ssp_din_reg;
always @(posedge ssp_clk)
    ssp_din_reg <= after_hysteresis;
assign ssp_din = ssp_din_reg;

reg modulating_carrier;
always @(posedge ssp_clk) begin
    case(mod_type)
        3'b000: modulating_carrier <= 1'b0;
        3'b001: modulating_carrier <= ssp_dout ^ ssp_clk_divider[3];
        3'b010: modulating_carrier <= ssp_dout & ssp_clk_divider[5];
        3'b100: modulating_carrier <= ssp_dout & ssp_clk_divider[4];
        default: modulating_carrier <= 1'b0;
    endcase
end

assign pwr_oe2 = modulating_carrier;
assign pwr_oe1 = modulating_carrier;
assign pwr_oe4 = modulating_carrier;
assign pwr_oe3 = 1'b0;
assign dbg = after_hysteresis;

endmodule