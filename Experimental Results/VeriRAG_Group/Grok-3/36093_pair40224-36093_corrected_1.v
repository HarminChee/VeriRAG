module main (
    input clk,
    input rst,
    input test_i,
    output c0,
    output c1,
    output c2,
    output c3,
    output c4,
    output c5,
    output c6,
    output c7
);
wire clk_in, clk2;
wire rst_in, rst2, rst_in_dft;
wire rst_sync_out;

   SB_IO #(
       .PIN_TYPE(6'b101001),
       .PULLUP(1'b1)
   ) io_pin (
       .PACKAGE_PIN(clk),
       .D_IN_0(clk2)
   );
   SB_IO #(
       .PIN_TYPE(6'b101001),
       .PULLUP(1'b1)
   ) io_pin2 (
       .PACKAGE_PIN(rst),
       .D_IN_0(rst2)
   );
assign rst_in = ~rst2;
assign clk_in = ~clk2;
assign rst_in_dft = test_i ? rst_in : rst_sync_out;

reg [7:0] counter;
always @(posedge clk_in or posedge rst_in_dft) begin
    if (rst_in_dft == 1'b1)
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

sync_rst #(
    .act(0),
    .sync(1)
) rst_sync (
    .clk_r(clk_in),
    .rst_i(rst_in),
    .rst_o(rst_sync_out)
);

endmodule

module sync_rst (
    input clk_r,
    input rst_i,
    output reg rst_o
);
parameter act = 1;
parameter sync = 1;

reg rst_ff;

always @(posedge clk_r or negedge rst_i) begin
    if (!rst_i) begin
        rst_ff <= 1'b0;
        rst_o <= 1'b0;
    end else begin
        rst_ff <= 1'b1;
        rst_o <= rst_ff;
    end
end

endmodule