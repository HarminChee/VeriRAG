`timescale 1ns / 1ps
module KeyBoard_ctrl(
    input  wire        CLK,
    input  wire        RESET,
    input  wire [3:0]  COLUMN,
    output reg  [3:0]  ROW,
    output wire [3:0]  KEY_IN,
    input  wire        test_i
);
    reg    [3:0]  DEBOUNCE_COUNT;
    reg    [3:0]  SCAN_CODE;
    reg    [3:0]  SCAN_NUMBER;
    reg    [3:0]  KEY_BUFFER;
    reg    [14:0] DIVIDER;
    reg    PRESS;
    wire   PRESS_VALID;
    wire   DEBOUNCE_CLK;
    wire   SCAN_CLK;
    wire   dft_reset;
    wire   dft_clk;

    assign dft_reset = RESET;
    assign dft_clk = CLK;

    always @(posedge dft_clk or posedge dft_reset)
    begin 
        if (dft_reset) 
            DIVIDER <= 15'h0000;
        else
            DIVIDER <= DIVIDER + 1;
    end 

    assign DEBOUNCE_CLK = DIVIDER[14];
    assign SCAN_CLK     = DIVIDER[14];

    always @(posedge dft_clk or posedge dft_reset)
    begin
        if (dft_reset) 
            SCAN_CODE <= 4'h0;
        else if (PRESS)
            SCAN_CODE <= SCAN_CODE + 1;
    end

    always @(*)
    begin
        case (SCAN_CODE[3:2])
            2'b00 : ROW = 4'b1110;
            2'b01 : ROW = 4'b1101;
            2'b10 : ROW = 4'b1011;
            2'b11 : ROW = 4'b0111;
        endcase
        case (SCAN_CODE[1:0])
            2'b00 : PRESS = COLUMN[0];
            2'b01 : PRESS = COLUMN[1];
            2'b10 : PRESS = COLUMN[2];
            2'b11 : PRESS = COLUMN[3];
        endcase
    end

    always @(posedge DEBOUNCE_CLK or posedge dft_reset)
    begin
        if (dft_reset)
            DEBOUNCE_COUNT <= 4'h0;
        else if (PRESS)
            DEBOUNCE_COUNT <= 4'h0;
        else if (DEBOUNCE_COUNT <= 4'hE)
            DEBOUNCE_COUNT <= DEBOUNCE_COUNT + 1;
    end 

    assign PRESS_VALID = (DEBOUNCE_COUNT == 4'hD) ? 1'b1 : 1'b0;

    always @(*)
    begin
        case (SCAN_CODE)
            4'b0000 : SCAN_NUMBER = 4'hF;
            4'b0001 : SCAN_NUMBER = 4'hE;
            4'b0010 : SCAN_NUMBER = 4'hD;
            4'b0011 : SCAN_NUMBER = 4'hC;
            4'b0100 : SCAN_NUMBER = 4'hB;
            4'b0101 : SCAN_NUMBER = 4'h3;
            4'b0110 : SCAN_NUMBER = 4'h6;
            4'b0111 : SCAN_NUMBER = 4'h9;
            4'b1000 : SCAN_NUMBER = 4'hA;
            4'b1001 : SCAN_NUMBER = 4'h2;
            4'b1010 : SCAN_NUMBER = 4'h5;
            4'b1011 : SCAN_NUMBER = 4'h8;   
            4'b1100 : SCAN_NUMBER = 4'h0;
            4'b1101 : SCAN_NUMBER = 4'h1;
            4'b1110 : SCAN_NUMBER = 4'h4;
            4'b1111 : SCAN_NUMBER = 4'h7;   
        endcase
    end

    always @(negedge DEBOUNCE_CLK or posedge dft_reset)
    begin
        if (dft_reset)
            KEY_BUFFER <= 4'h0;
        else if (PRESS_VALID)
            KEY_BUFFER <= SCAN_NUMBER;
    end

    assign KEY_IN = KEY_BUFFER;

endmodule