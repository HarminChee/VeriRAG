`timescale 1ns/1ns
`timescale 1ns/1ns
module clocks(
    input test_i,
    input CLK_24M,
    input nRESETP,
    output CLK_12M,
    output reg CLK_68KCLK = 1'b0,
    output CLK_68KCLKB,
    output CLK_6MB,
    output reg CLK_1MB
);
    reg [2:0] CLK_DIV;
    wire CLK_3M;
    wire dft_clk12m;

    always @(posedge CLK_24M or negedge nRESETP) begin
        if (!nRESETP)
            CLK_68KCLK <= 1'b0;
        else
            CLK_68KCLK <= ~CLK_68KCLK;
    end

    assign CLK_68KCLKB = ~CLK_68KCLK;

    always @(posedge CLK_24M or negedge nRESETP) begin
        if (!nRESETP)
            CLK_DIV <= 3'b100;
        else
            CLK_DIV <= CLK_DIV + 1'b1;
    end

    assign CLK_12M = CLK_DIV[0];
    assign CLK_6MB = ~CLK_DIV[1];
    assign CLK_3M = CLK_DIV[2];
    assign dft_clk12m = test_i ? CLK_24M : CLK_12M;

    always @(posedge dft_clk12m or negedge nRESETP) begin
        if (!nRESETP)
            CLK_1MB <= 1'b0;
        else
            CLK_1MB <= ~CLK_3M;
    end

endmodule