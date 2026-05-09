module perspective_params(input clk,
                input[9:0] x1,
                input[8:0] y1,
                input[9:0] x2,
                input[8:0] y2,
                input[9:0] x3,
                input[8:0] y3,
                input[9:0] x4,
                input[8:0] y4,
                output reg signed[67:0] p1_inv,
                output reg signed[68:0] p2_inv,
                output reg signed[78:0] p3_inv,
                output reg signed[67:0] p4_inv,
                output reg signed[68:0] p5_inv,
                output reg signed[78:0] p6_inv,
                output reg signed[58:0] p7_inv,
                output reg signed[59:0] p8_inv,
                output reg signed[70:0] p9_inv,
                output reg signed[78:0] dec_numx_horiz,
                output reg signed[78:0] dec_numy_horiz,
                output reg signed[70:0] dec_denom_horiz);
wire signed[10:0] sx1, sx2, sx3, sx4;
wire signed[9:0] sy1, sy2, sy3, sy4;
assign sx1 = {1'b0, x1};
assign sx2 = {1'b0, x2};
assign sx3 = {1'b0, x3};
assign sx4 = {1'b0, x4};
assign sy1 = {1'b0, y1};
assign sy2 = {1'b0, y2};
assign sy3 = {1'b0, y3};
assign sy4 = {1'b0, y4};
wire signed[10:0] d_x1_x2,d_x2_x3,d_x3_x4,d_x4_x1;
wire signed[9:0] d_y1_y2, d_y2_y3, d_y3_y4, d_y4_y1, d_y4_y2;
assign d_x1_x2 = sx1 - sx2;
assign d_x2_x3 = sx2 - sx3;
assign d_x3_x4 = sx3 - sx4;
assign d_x4_x1 = sx4 - sx1;
assign d_y1_y2 = sy1 - sy2;
assign d_y2_y3 = sy2 - sy3;
assign d_y3_y4 = sy3 - sy4;
assign d_y4_y1 = sy4 - sy1;
assign d_y4_y2 = sy4 - sy2;
wire signed[20:0] num0, num1, num2, num3;
wire signed[21:0] p7_temp, p8_temp;
wire signed[23:0] p7, p8;
assign num0 = -(d_x4_x1 * d_y2_y3);
assign num1 = d_y4_y1 * d_x2_x3;
assign num2 = d_x1_x2 * d_y3_y4;
assign num3 = -(d_x3_x4 * d_y1_y2);
assign p7_temp = num0 + num1;
assign p8_temp = num2 + num3;
assign p7 = (p7_temp <<< 1) + p7_temp;
assign p8 = (p8_temp <<< 2);
wire signed[20:0] denom0, denom1, denom2;
wire signed[21:0] denom;
assign denom0 = sx4 * d_y2_y3;
assign denom1 = sx2 * d_y3_y4;
assign denom2 = sx3 * d_y4_y2;
assign denom = denom0 + denom1 + denom2;
wire signed[25:0] denom_15;
wire signed[32:0] p9;
wire signed[32:0] x1_denom;
wire signed[36:0] x1_denom_15;
wire signed[43:0] p3;
wire signed[31:0] y1_denom;
wire signed[35:0] y1_denom_15;
wire signed[42:0] p6;
assign denom_15 = (denom <<< 4) - denom; 
assign p9 = denom_15 <<< 7; 
assign x1_denom = sx1 * denom; 
assign x1_denom_15 = (x1_denom <<< 4) - x1_denom; 
assign p3 = x1_denom_15 <<< 7; 
assign y1_denom = sy1 * denom; 
assign y1_denom_15 = (y1_denom <<< 4) - y1_denom; 
assign p6 = y1_denom_15 <<< 7; 
wire signed[32:0] d_x1_x2_denom;
wire signed[32:0] d_x4_x1_denom;
wire signed[31:0] d_y4_y1_denom;
wire signed[31:0] d_y1_y2_denom;
wire signed[34:0] d_x1_x2_denom_scale;
wire signed[34:0] d_x4_x1_denom_scale;
wire signed[33:0] d_y4_y1_denom_scale;
wire signed[33:0] d_y1_y2_denom_scale;
wire signed[34:0] x4_p7;
wire signed[34:0] x2_p8;
wire signed[33:0] y4_p7;
wire signed[33:0] y2_p8;
wire signed[35:0] p1, p2;
wire signed[34:0] p4, p5;
assign d_x1_x2_denom = d_x1_x2 * denom;
assign d_x4_x1_denom = d_x4_x1 * denom;
assign d_y4_y1_denom = d_y4_y1 * denom;
assign d_y1_y2_denom = d_y1_y2 * denom;
assign d_x4_x1_denom_scale = (d_x4_x1_denom <<< 1) + d_x4_x1_denom; 
assign d_x1_x2_denom_scale = (d_x1_x2_denom <<< 2); 
assign d_y4_y1_denom_scale = (d_y4_y1_denom <<< 1) + d_y4_y1_denom; 
assign d_y1_y2_denom_scale = (d_y1_y2_denom <<< 2); 
assign x4_p7 = sx4 * p7;
assign x2_p8 = sx2 * p8;
assign y4_p7 = sy4 * p7;
assign y2_p8 = sy2 * p8;
assign p1 = x4_p7 + d_x4_x1_denom_scale;
assign p2 = x2_p8 - d_x1_x2_denom_scale;
assign p4 = y4_p7 + d_y4_y1_denom_scale;
assign p5 = y2_p8 - d_y1_y2_denom_scale;
wire signed[67:0] p1_inv_wire;
wire signed[68:0] p2_inv_wire;
wire signed[78:0] p3_inv_wire;
wire signed[67:0] p4_inv_wire;
wire signed[68:0] p5_inv_wire;
wire signed[78:0] p6_inv_wire;
wire signed[58:0] p7_inv_wire;
wire signed[59:0] p8_inv_wire;
wire signed[70:0] p9_inv_wire;
assign p1_inv_wire = p6*p8 - p5*p9;
assign p2_inv_wire = p2*p9 - p3*p8;
assign p3_inv_wire = p3*p5 - p2*p6;
assign p4_inv_wire = p4*p9 - p6*p7;
assign p5_inv_wire = p3*p7 - p1*p9;
assign p6_inv_wire = p1*p6 - p3*p4;
assign p7_inv_wire = p5*p7 - p4*p8;
assign p8_inv_wire = p1*p8 - p2*p7;
assign p9_inv_wire = p2*p4 - p1*p5;
wire signed[78:0] dec_numx_horiz_wire;
wire signed[78:0] dec_numy_horiz_wire;
wire signed[70:0] dec_denom_horiz_wire;
assign dec_numx_horiz_wire = (p1_inv_wire <<< 9) + (p1_inv_wire <<< 7) - p1_inv_wire;
assign dec_numy_horiz_wire = (p4_inv_wire <<< 9) + (p4_inv_wire <<< 7) - p4_inv_wire;
assign dec_denom_horiz_wire = (p7_inv_wire <<< 9) + (p7_inv_wire <<< 7) - p7_inv_wire;
always @(posedge clk) begin
    p1_inv <= p1_inv_wire;
    p2_inv <= p2_inv_wire;
    p3_inv <= p3_inv_wire;
    p4_inv <= p4_inv_wire;
    p5_inv <= p5_inv_wire;
    p6_inv <= p6_inv_wire;
    p7_inv <= p7_inv_wire;
    p8_inv <= p8_inv_wire;
    p9_inv <= p9_inv_wire;
    dec_numx_horiz <= dec_numx_horiz_wire;
    dec_numy_horiz <= dec_numy_horiz_wire;
    dec_denom_horiz <= dec_denom_horiz_wire;
end
endmodule
