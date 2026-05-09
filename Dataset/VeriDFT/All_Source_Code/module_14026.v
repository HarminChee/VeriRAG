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
always @(negedge adc_clk)
begin
    if(& adc_d[7:5]) after_hysteresis = 1'b1;
    else if(~(| adc_d[7:5])) after_hysteresis = 1'b0;
end
reg [6:0] ssp_clk_divider;
always @(posedge adc_clk)
    ssp_clk_divider <= (ssp_clk_divider + 1);
assign ssp_clk = ssp_clk_divider[4];
reg [2:0] ssp_frame_divider_to_arm;
always @(posedge ssp_clk)
    ssp_frame_divider_to_arm <= (ssp_frame_divider_to_arm + 1);
reg [2:0] ssp_frame_divider_from_arm;
always @(negedge ssp_clk)
    ssp_frame_divider_from_arm <= (ssp_frame_divider_from_arm + 1);
reg ssp_frame;
always @(ssp_frame_divider_to_arm or ssp_frame_divider_from_arm or mod_type)
    if(mod_type == 3'b000) 
        ssp_frame = (ssp_frame_divider_to_arm == 3'b000);
    else
        ssp_frame = (ssp_frame_divider_from_arm == 3'b000);
reg ssp_din;
always @(posedge ssp_clk)
    ssp_din = after_hysteresis;
reg modulating_carrier;
always @(mod_type or ssp_clk or ssp_dout)
    if(mod_type == 3'b000)
        modulating_carrier <= 1'b0;                          
    else if(mod_type == 3'b001)
        modulating_carrier <= ssp_dout ^ ssp_clk_divider[3]; 
    else if(mod_type == 3'b010)
	modulating_carrier <= ssp_dout & ssp_clk_divider[5]; 
    else if(mod_type == 3'b100)
	modulating_carrier <= ssp_dout & ssp_clk_divider[4]; 
    else
        modulating_carrier <= 1'b0;                           
assign pwr_oe2 = modulating_carrier;
assign pwr_oe1 = modulating_carrier;
assign pwr_oe4 = modulating_carrier;
assign pwr_oe3 = 1'b0;
assign dbg = after_hysteresis;
endmodule
