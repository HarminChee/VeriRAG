`default_nettype none
module RedundantFF_corrected_clk(
    input wire clear,
    input wire clk_108hz,
    output wire underflow
);
    reg [7:0] count = 8'd15;

    always @(posedge clk_108hz) begin
        count <= count - 1'b1;
        if(count == 8'd0)
            count <= 8'd15;
    end

    assign underflow = (count == 8'd0);
endmodule