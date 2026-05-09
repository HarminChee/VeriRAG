`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module image_filter_mul_8ns_6ns_13_3(
    clk,
    reset,
    ce,
    din0,
    din1,
    dout);
parameter ID = 32'd1;
parameter NUM_STAGE = 32'd1;
parameter din0_WIDTH = 32'd1;
parameter din1_WIDTH = 32'd1;
parameter dout_WIDTH = 32'd1;
input clk;
input reset;
input ce;
input[din0_WIDTH - 1:0] din0;
input[din1_WIDTH - 1:0] din1;
output[dout_WIDTH - 1:0] dout;
image_filter_mul_8ns_6ns_13_3_MAC3S_0 image_filter_mul_8ns_6ns_13_3_MAC3S_0_U(
    .clk( clk ),
    .ce( ce ),
    .a( din0 ),
    .b( din1 ),
    .p( dout ));
endmodule
`timescale 1 ns / 1 ps
module image_filter_mul_8ns_6ns_13_3_MAC3S_0(clk, ce, a, b, p);
input clk;
input ce;
input[8 - 1 : 0] a; 
input[6 - 1 : 0] b; 
output[13 - 1 : 0] p;
reg [8 - 1 : 0] a_reg0;
reg [6 - 1 : 0] b_reg0;
wire [13 - 1 : 0] tmp_product;
reg [13 - 1 : 0] buff0;
assign p = buff0;
assign tmp_product = a_reg0 * b_reg0;
always @ (posedge clk) begin
    if (ce) begin
        a_reg0 <= a;
        b_reg0 <= b;
        buff0 <= tmp_product;
    end
end
endmodule
`timescale 1 ns / 1 ps
module image_filter_mul_8ns_6ns_13_3(
    clk,
    reset,
    ce,
    din0,
    din1,
    dout);
parameter ID = 32'd1;
parameter NUM_STAGE = 32'd1;
parameter din0_WIDTH = 32'd1;
parameter din1_WIDTH = 32'd1;
parameter dout_WIDTH = 32'd1;
input clk;
input reset;
input ce;
input[din0_WIDTH - 1:0] din0;
input[din1_WIDTH - 1:0] din1;
output[dout_WIDTH - 1:0] dout;
image_filter_mul_8ns_6ns_13_3_MAC3S_0 image_filter_mul_8ns_6ns_13_3_MAC3S_0_U(
    .clk( clk ),
    .ce( ce ),
    .a( din0 ),
    .b( din1 ),
    .p( dout ));
endmodule
