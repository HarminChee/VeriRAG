module main (input clk,
             input rst,
             input test_mode,
             output c0,
             output c1, 
             output c2,
             output c3,
             output c4,
             output c5,
             output c6,
             output c7);

wire clk_in, clk2;
wire rst_in, rst2;
wire rst_sync;
wire clk_gated;

SB_IO #(
    .PIN_TYPE(6'b 1010_01),
    .PULLUP(1'b 1)
) io_pin (
    .PACKAGE_PIN(clk),
    .D_IN_0(clk2)
);

SB_IO #(
    .PIN_TYPE(6'b 1010_01),
    .PULLUP(1'b 1)
) io_pin2 (
    .PACKAGE_PIN(rst),
    .D_IN_0(rst2)
);

assign rst_in = ~rst2;
assign clk_in = ~clk2;

sync_rst #(
    .act(1),
    .sync(1)
) u_sync_rst (
    .clk_r(clk_in),
    .rst_i(rst_in),
    .rst_o(rst_sync)
);

wire rst_dft;
assign rst_dft = test_mode ? rst_in : rst_sync;

ccgc u_ccgc (
    .clk_i(clk_in),
    .clk_o(clk_gated),
    .enable_i(1'b1),
    .test_i(test_mode)
);

wire clk_dft;
assign clk_dft = test_mode ? clk_in : clk_gated;

reg [7:0] counter;
always @(posedge clk_dft or posedge rst_dft) begin
    if (rst_dft)
        counter <= 8'b0;
    else
        counter <= counter + 1;
end

assign c0 = counter[0];
assign c1 = counter[1];
assign c2 = counter[2];
assign c3 = counter[3];
assign c4 = counter[4];
assign c5 = counter[5];
assign c6 = counter[6];
assign c7 = counter[7];

endmodule

module sync_rst (
    input clk_r,
    input rst_i,
    output rst_o
);
parameter act = 1;
parameter sync = 1;
endmodule

module ccgc(
    input clk_i,
    output clk_o,
    input enable_i,
    input test_i
);
parameter cgtransp = 0;
endmodule