module sha2_sec_ti2_rm0_ti2_and_l0 #(
    parameter NOTA = 1'b0,
    parameter NOTB = 1'b0,
    parameter NOTY = 1'b0
    )(
    input wire [1:0] i_a,   
    input wire [1:0] i_b,   
    output reg [1:0] o_y    
    );
wire [1:0] a = i_a^ NOTA[0];
wire [1:0] b = i_b^ NOTB[0];
wire n00,n10,n01;
wire n11;
sha2_sec_ti2_rm0_plain_nand nand00_ITK(.a(a[0]), .b(b[0]), .q(n00));
sha2_sec_ti2_rm0_plain_nand nand10_ITK(.a(a[1]), .b(b[0]), .q(n10));
sha2_sec_ti2_rm0_plain_nand nand01_ITK(.a(a[0]), .b(b[1]), .q(n01));
sha2_sec_ti2_rm0_plain_nand nand11_ITK(.a(a[1]), .b(b[1]), .q(n11));
always @* begin
    o_y[0] = n00 ^ n11 ^ NOTY[0];
    o_y[1] = n10 ^ n01;
end
endmodule
module sha2_sec_ti2_rm0_plain_nand(
    input wire a,
    input wire b,
    output reg q
    );
wire tmp;
assign tmp = ~(a&b);
wire tmp2 = tmp;
reg tmp3;
always @*tmp3 = tmp2;
always @* q = tmp3;
endmodule
module sha2_sec_ti2_rm0_ti2_and_l0 #(
    parameter NOTA = 1'b0,
    parameter NOTB = 1'b0,
    parameter NOTY = 1'b0
    )(
    input wire [1:0] i_a,   
    input wire [1:0] i_b,   
    output reg [1:0] o_y    
    );
wire [1:0] a = i_a^ NOTA[0];
wire [1:0] b = i_b^ NOTB[0];
wire n00,n10,n01;
wire n11;
sha2_sec_ti2_rm0_plain_nand nand00_ITK(.a(a[0]), .b(b[0]), .q(n00));
sha2_sec_ti2_rm0_plain_nand nand10_ITK(.a(a[1]), .b(b[0]), .q(n10));
sha2_sec_ti2_rm0_plain_nand nand01_ITK(.a(a[0]), .b(b[1]), .q(n01));
sha2_sec_ti2_rm0_plain_nand nand11_ITK(.a(a[1]), .b(b[1]), .q(n11));
always @* begin
    o_y[0] = n00 ^ n11 ^ NOTY[0];
    o_y[1] = n10 ^ n01;
end
endmodule
