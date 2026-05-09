module main (
    input clk,
    input rst_n, // Changed rst to rst_n to indicate active low reset
    output c0,
    output c1, 
    output c2,
    output c3,
    output c4,
    output c5,
    output c6,
    output c7
);

reg [7:0] counter;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
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