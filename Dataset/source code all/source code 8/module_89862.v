`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module sync_signal #(
    parameter WIDTH=1, 
    parameter N=2 
)(
    input wire clk,
    input wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);
reg [WIDTH-1:0] sync_reg[N-1:0];
assign out = sync_reg[N-1];
integer k;
always @(posedge clk) begin
    sync_reg[0] <= in;
    for (k = 1; k < N; k = k + 1) begin
        sync_reg[k] <= sync_reg[k-1];
    end
end
endmodule
