module main (
    input wire clk,
    input wire rst,
    output wire c0,
    output wire c1, 
    output wire c2,
    output wire c3,
    output wire c4,
    output wire c5,
    output wire c6,
    output wire c7
);

wire clk_in;
wire rst_in;

SB_IO #(
    .PIN_TYPE(6'b101001),
    .PULLUP(1'b1)
) io_pin (
    .PACKAGE_PIN(clk),
    .D_IN_0(clk_in)
);

SB_IO #(
    .PIN_TYPE(6'b101001), 
    .PULLUP(1'b1)
) io_pin2 (
    .PACKAGE_PIN(rst),
    .D_IN_0(rst_in)
);

reg [7:0] counter;

always @(posedge clk_in) begin
    if (rst_in)
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