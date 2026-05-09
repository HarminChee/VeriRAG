`timescale 1ns / 1ps
`timescale 1ns / 1ps
module ssio_sdr_out #
(
    parameter TARGET = "GENERIC",
    parameter IODDR_STYLE = "IODDR2",
    parameter WIDTH = 1
)
(
    input  wire             clk,
    input  wire [WIDTH-1:0] input_d,
    output wire             output_clk,
    output wire [WIDTH-1:0] output_q
);
oddr #(
    .TARGET(TARGET),
    .IODDR_STYLE(IODDR_STYLE),
    .WIDTH(1)
)
clk_oddr_inst (
    .clk(clk),
    .d1(1'b0),
    .d2(1'b1),
    .q(output_clk)
);
(* IOB = "TRUE" *)
reg [WIDTH-1:0] output_q_reg = {WIDTH{1'b0}};
assign output_q = output_q_reg;
always @(posedge clk) begin
    output_q_reg <= input_d;
end
endmodule
