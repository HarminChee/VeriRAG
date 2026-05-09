module hi_simulate(
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
    output reg ssp_frame,
    output reg ssp_din,
    input ssp_dout,
    output ssp_clk,
    input cross_hi,
    input cross_lo,
    output dbg,
    input [2:0] mod_type
);

assign pwr_hi = 1'b0;
assign pwr_lo = 1'b0;

reg after_hysteresis;
assign adc_clk = ck_1356meg;

always @(negedge adc_clk)
begin
    if(&adc_d[7:5]) begin
        after_hysteresis <= 1'b1;
    end else if(~(|adc_d[7:5])) begin
        after_hysteresis <= 1'b0;
    end
    // else: after_hysteresis retains its value (hysteresis behavior)
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

// Combinational logic for ssp_frame
always @* begin // Use @* for combinational logic sensitivity
    if(mod_type == 3'b000) begin
        ssp_frame = (ssp_frame_divider_to_arm == 3'b000);
    end else begin
        ssp_frame = (ssp_frame_divider_from_arm == 3'b000);
    end
end

// Sequential logic for ssp_din
always @(posedge ssp_clk) begin
    ssp_din <= after_hysteresis; // Use non-blocking assignment
end

reg modulating_carrier;
// Combinational logic for modulating_carrier
always @* begin // Use @* for combinational logic sensitivity
    case(mod_type)
        3'b000: modulating_carrier = 1'b0;
        3'b001: modulating_carrier = ssp_dout ^ ssp_clk_divider[3];
        3'b010: modulating_carrier = ssp_dout & ssp_clk_divider[5];
        3'b100: modulating_carrier = ssp_dout & ssp_clk_divider[4];
        default: modulating_carrier = 1'b0; // Default case is good practice
    endcase
    // Note: Use blocking assignments (=) for combinational logic
end

assign pwr_oe2 = modulating_carrier;
assign pwr_oe1 = modulating_carrier;
assign pwr_oe4 = modulating_carrier;
assign pwr_oe3 = 1'b0;

assign dbg = after_hysteresis;

endmodule