`timescale 1ns / 1ps
`timescale 1ns / 1ps
module reset_stretch #(
    parameter N = 4
)(
    input  wire clk,
    input  wire rst_in,
    output wire rst_out
);
reg reset_reg = 1;
reg [N-1:0] count_reg = 0;
assign rst_out = reset_reg;
always @(posedge clk or posedge rst_in) begin
    if (rst_in) begin
        count_reg <= 0;
        reset_reg <= 1;
    end else begin
        if (&count_reg) begin
            reset_reg <= 0;
        end else begin
            reset_reg <= 1;
            count_reg <= count_reg + 1;
        end
    end
end
endmodule
