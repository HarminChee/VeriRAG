`timescale 1ns/1ns
module ym2i2s(
    input nRESET,
    input CLK_I2S,
    input [5:0] ANA,
    input SH1, SH2, OP0, PHI_M,
    output I2S_MCLK,
    output I2S_BICK,
    output I2S_SDTI,
    output I2S_LRCK
);

    wire [23:0] I2S_SAMPLE;
    reg [23:0] I2S_SR;
    reg [3:0] SR_CNT;
    reg [7:0] CLKDIV;
    reg LRCK_reg;
    reg BICK_reg;

    assign I2S_SAMPLE = {18'b000000000000000000, ANA};
    assign I2S_MCLK = CLK_I2S;
    assign I2S_LRCK = LRCK_reg;
    assign I2S_BICK = BICK_reg;
    assign I2S_SDTI = I2S_SR[23];

    always @(negedge BICK_reg)
    begin
        if (!nRESET)
            SR_CNT <= 0;
        else
        begin
            if (!SR_CNT)
            begin
                I2S_SR <= I2S_SAMPLE;
                SR_CNT <= SR_CNT + 1'b1;
            end
            else
            begin
                I2S_SR <= {I2S_SR[22:0], 1'b0};
                SR_CNT <= SR_CNT + 1'b1;
            end

        end
    end

    always @(posedge CLK_I2S)
    begin
        if (!nRESET)
            CLKDIV <= 0;
        else
            CLKDIV <= CLKDIV + 1'b1;
    end

    always @(posedge CLK_I2S)
    begin
        if (!nRESET)
        begin
            LRCK_reg <= 1'b0;
            BICK_reg <= 1'b0;
        end
        else
        begin
            LRCK_reg <= CLKDIV[7];
            BICK_reg <= CLKDIV[4];
        end
    end

endmodule