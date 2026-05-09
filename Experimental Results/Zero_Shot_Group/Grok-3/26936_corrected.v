`timescale 1ns/1ns
module ym2i2s(
    input nRESET,
    input CLK_I2S,
    input [5:0] ANA,
    input SH1, SH2, OP0, PHI_M,
    output I2S_MCLK, I2S_BICK, I2S_SDTI, I2S_LRCK
);
    wire [23:0] I2S_SAMPLE;
    reg [23:0] I2S_SR;
    reg [4:0] SR_CNT; // Changed to 5 bits to count up to 24
    reg [7:0] CLKDIV;
    
    assign I2S_SAMPLE = {18'b000000000000000000, ANA};          
    assign I2S_MCLK = CLK_I2S;
    assign I2S_LRCK = CLKDIV[7];     
    assign I2S_BICK = CLKDIV[4];     
    assign I2S_SDTI = I2S_SR[23];
    
    always @(negedge I2S_BICK or negedge nRESET)
    begin
        if (!nRESET)
        begin
            SR_CNT <= 5'b0;
            I2S_SR <= 24'b0;
        end
        else
        begin
            if (SR_CNT == 5'd0)
            begin
                I2S_SR <= I2S_SAMPLE;
                SR_CNT <= SR_CNT + 1'b1;
            end
            else if (SR_CNT < 5'd24)
            begin
                I2S_SR <= {I2S_SR[22:0], 1'b0};
                SR_CNT <= SR_CNT + 1'b1;
            end
        end
    end
    
    always @(posedge I2S_MCLK or negedge nRESET)
    begin
        if (!nRESET)
            CLKDIV <= 8'b0;
        else
            CLKDIV <= CLKDIV + 1'b1;
    end
endmodule