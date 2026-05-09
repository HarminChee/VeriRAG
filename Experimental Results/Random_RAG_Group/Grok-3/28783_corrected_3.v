module hi_simulate(
    input wire test_i,
    input wire pck0, 
    input wire ck_1356meg, 
    input wire ck_1356megb,
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
    input wire [2:0] mod_type
);

wire dft_adc_clk;

assign pwr_hi = 1'b0;
assign pwr_lo = 1'b0;

reg after_hysteresis;
assign adc_clk = ck_1356meg;
assign dft_adc_clk = test_i ? pck0 : ck_1356meg;

always @(negedge dft_adc_clk)
begin
    if(&adc_d[7:5]) after_hysteresis <= 1'b1;
    else if(~(|adc_d[7:5])) after_hysteresis <= 1'b0;
end

reg [6:0] ssp_clk_divider;
always @(posedge dft_adc_clk)
    ssp_clk_divider <= ssp_clk_divider + 1;

assign ssp_clk = ssp_clk_divider[4];

reg [2:0] ssp_frame_divider_to_arm;
always @(posedge ssp_clk)
    ssp_frame_divider_to_arm <= ssp_frame_divider_to_arm + 1;

reg [2:0] ssp_frame_divider_from_arm;
always @(negedge ssp_clk)
    ssp_frame_divider_from_arm <= ssp_frame_divider_from_arm + 1;

reg ssp_frame;
always @(*)
    if(mod_type == 3'b000) 
        ssp_frame = (ssp_frame_divider_to_arm == 3'b000);
    else
        ssp_frame = (ssp_frame_divider_from_arm == 3'b000);

reg ssp_din;
always @(posedge ssp_clk)
    ssp_din <= after_hysteresis;

reg modulating_carrier;
always @(*)
    if(mod_type == 3'b000)
        modulating_carrier = 1'b0;                          
    else if(mod_type == 3'b001)
        modulating_carrier = ssp_dout ^ ssp_clk_divider[3]; 
    else if(mod_type == 3'b010)
        modulating_carrier = ssp_dout & ssp_clk_divider[5]; 
    else if(mod_type == 3'b100)
        modulating_carrier = ssp_dout & ssp_clk_divider[4]; 
    else
        modulating_carrier = 1'b0;                           

assign pwr_oe2 = modulating_carrier;
assign pwr_oe1 = modulating_carrier;
assign pwr_oe4 = modulating_carrier;
assign pwr_oe3 = 1'b0;

assign dbg = after_hysteresis;

endmodule