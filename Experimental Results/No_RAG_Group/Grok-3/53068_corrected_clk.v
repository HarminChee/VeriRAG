`default_nettype none
module RedundantFF_corrected_clk(clear, clk, underflow);
    input wire clear;
    input wire clk;
    output wire underflow;
    
    reg[7:0] count = 15;
    always @(posedge clk) begin
        count <= count - 1'h1;
        if(count == 0)
            count <= 15;
    end
    assign underflow = (count == 0);
endmodule