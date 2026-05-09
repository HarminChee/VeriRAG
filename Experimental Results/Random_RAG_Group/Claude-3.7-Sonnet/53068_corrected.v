`default_nettype none
`default_nettype none
module RedundantFF(clear, clk_i, test_i, underflow);
    input wire clear;
    input wire clk_i;
    input wire test_i; 
    output wire underflow;
    wire clk_108hz;
    wire dft_clk;
    
    GP_LFOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0),
        .OUT_DIV(16)
    ) lfosc (
        .PWRDN(1'b0),
        .CLKOUT(clk_108hz)
    );

    assign dft_clk = test_i ? clk_i : clk_108hz;

    reg[7:0] count = 15;
    always @(posedge dft_clk) begin
        count <= count - 1'h1;
        if(count == 0)
            count <= 15;
    end
    assign underflow = (count == 0);
endmodule