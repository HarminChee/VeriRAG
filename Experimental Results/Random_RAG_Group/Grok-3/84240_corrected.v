module lo_edge_detect(
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
    output wire ssp_frame, 
    output wire ssp_din, 
    input wire ssp_dout, 
    output wire ssp_clk,
    input wire cross_hi, 
    input wire cross_lo,
    output wire dbg,
    input wire [7:0] divisor,
    input wire lf_field,
    input wire test_i,
    input wire rst
);

wire dft_pck0;
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

assign dft_pck0 = test_i ? pck0 : pck0;

always @(posedge dft_pck0 or posedge rst)
begin
    if (rst) begin
        pck_divider <= 8'd0;
        clk_state <= 1'b0;
    end else begin
        if (pck_divider == divisor[7:0]) begin
            pck_divider <= 8'd0;
            clk_state <= !clk_state;
        end else begin
            pck_divider <= pck_divider + 1;
        end
    end
end

assign adc_clk = ~clk_state;

reg is_high;
reg is_low;
reg output_state;

always @(posedge dft_pck0 or posedge rst)
begin
    if (rst) begin
        is_high <= 1'b0;
        is_low <= 1'b0;
    end else begin
        if ((pck_divider == 8'd7) && !clk_state) begin
            is_high <= (adc_d >= 8'd190);
            is_low <= (adc_d <= 8'd70);
        end
    end
end

always @(posedge is_high or posedge is_low or posedge rst)
begin
    if (rst)
        output_state <= 1'd0;
    else if (is_high)
        output_state <= 1'd1;
    else if (is_low)
        output_state <= 1'd0;
end

assign ssp_frame = output_state;
assign ssp_din = 1'b0;

endmodule