`default_nettype none
module RedundantFF(clk, clear, underflow);
    input wire clk;
    input wire clear;
    output wire underflow;
    reg [7:0] count = 15;

    always @(posedge clk) begin
        count <= count - 1'h1;
        if (count == 0)
            count <= 15;
    end

    assign underflow = (count == 0);
endmodule