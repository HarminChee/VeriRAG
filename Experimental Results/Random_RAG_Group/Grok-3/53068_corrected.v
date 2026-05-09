`default_nettype none
module RedundantFF(clear, underflow, test_i, clk_in, rst_in);
    input wire clear;
    input wire test_i;
    input wire clk_in;
    input wire rst_in;
    output wire underflow;
    wire clk_108hz;
    wire dft_clk;
    wire dft_rst;
    GP_LFOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0),
        .OUT_DIV(16)
    ) lfosc (
        .PWRDN(1'b0),
        .CLKOUT(clk_108hz)
    );
    assign dft_clk = test_i ? clk_in : clk_108hz;
    assign dft_rst = test_i ? rst_in : clear;
    reg[7:0] count = 15;
    always @(posedge dft_clk or posedge dft_rst) begin
        if (dft_rst) begin
            count <= 15;
        end else begin
            count <= count - 1'h1;
            if (count == 0)
                count <= 15;
        end
    end
    assign underflow = (count == 0);
endmodule