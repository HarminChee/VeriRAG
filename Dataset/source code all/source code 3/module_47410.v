`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module sync_reset #(
    parameter N=2 
)(
    input wire clk,
    input wire rst,
    output wire sync_reset_out
);
reg [N-1:0] sync_reg = {N{1'b1}};
assign sync_reset_out = sync_reg[N-1];
always @(posedge clk or posedge rst) begin
    if (rst)
        sync_reg <= {N{1'b1}};
    else
        sync_reg <= {sync_reg[N-2:0], 1'b0};
end
endmodule
