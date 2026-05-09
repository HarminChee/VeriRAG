module red_pitaya_iq_modulator_block #(
    parameter     INBITS   = 18,
    parameter     OUTBITS   = 14,
    parameter     SINBITS   = 14,
    parameter     GAINBITS  = 16,
    parameter     SHIFTBITS = 0)
(
    input clk_i,
    input signed [SINBITS-1:0] sin, 
    input signed [SINBITS-1:0] cos, 
    input signed [GAINBITS-1:0] g1,
    input signed [GAINBITS-1:0] g2,
    input signed [GAINBITS-1:0] g3,
    input signed [GAINBITS-1:0] g4,
    input signed [INBITS-1:0] signal1_i,
    input signed [INBITS-1:0] signal2_i,
    output signed [OUTBITS-1:0] dat_o,            
    output signed [OUTBITS-1:0] signal_q1_o, 
    output signed [OUTBITS-1:0] signal_q2_o  
);
wire signed [OUTBITS-1:0] firstproduct1;
wire signed [OUTBITS-1:0] firstproduct2;
red_pitaya_product_sat  #(
	.BITS_IN1(INBITS),
	.BITS_IN2(GAINBITS),
	.SHIFT(GAINBITS+INBITS-OUTBITS-SHIFTBITS),
	.BITS_OUT(OUTBITS))
firstproduct_saturation [1:0]
( .factor1_i  (  {signal2_i, signal1_i} ),
  .factor2_i  (  {       g4,        g1} ),
  .product_o  (  {firstproduct2, firstproduct1})
);
reg signed [OUTBITS+1-1:0] firstproduct1_reg;
reg signed [OUTBITS+1-1:0] firstproduct2_reg;
always @(posedge clk_i) begin
    firstproduct1_reg <= $signed(firstproduct1) + $signed(g2[GAINBITS-1:GAINBITS-OUTBITS]);
    firstproduct2_reg <= $signed(firstproduct2);
end
wire signed [OUTBITS+1+SINBITS-1-1:0] secondproduct1;
wire signed [OUTBITS+1+SINBITS-1-1:0] secondproduct2;
assign secondproduct1 = firstproduct1_reg * sin;
assign secondproduct2 = firstproduct2_reg * cos;
reg signed [OUTBITS+1+SINBITS-1:0] secondproduct_sum;
reg signed [OUTBITS-1:0] secondproduct_out;
wire signed [OUTBITS-1:0] secondproduct_sat;
always @(posedge clk_i) begin
    secondproduct_sum <= secondproduct1 + secondproduct2;
    secondproduct_out <= secondproduct_sat;
end
red_pitaya_saturate
    #( .BITS_IN(OUTBITS+SINBITS+1),
       .BITS_OUT(OUTBITS),
       .SHIFT(SINBITS-1)
    )
    sumsaturation
    (
    .input_i(secondproduct_sum),
    .output_o(secondproduct_sat)
    );
assign dat_o = secondproduct_out;
wire signed [OUTBITS-1:0] q1_product;
wire signed [OUTBITS-1:0] q2_product;
red_pitaya_product_sat  #(
	.BITS_IN1(INBITS),
	.BITS_IN2(GAINBITS),
	.SHIFT(SHIFTBITS+2),
	.BITS_OUT(OUTBITS))
i0_product_and_sat (
  .factor1_i(signal1_i),
  .factor2_i(g3),
  .product_o(q1_product),
  .overflow ()
);
red_pitaya_product_sat  #(
	.BITS_IN1(INBITS),
	.BITS_IN2(GAINBITS),
	.SHIFT(SHIFTBITS+2),
	.BITS_OUT(OUTBITS))
q0_product_and_sat (
  .factor1_i(signal2_i),
  .factor2_i(g3),
  .product_o(q2_product),
  .overflow ()
);
reg signed [OUTBITS-1:0] q1_product_reg;
reg signed [OUTBITS-1:0] q2_product_reg;
always @(posedge clk_i) begin
    q1_product_reg <= q1_product;
    q2_product_reg <= q2_product;
end
assign signal_q1_o = q1_product_reg;
assign signal_q2_o = q2_product_reg;
endmodule
