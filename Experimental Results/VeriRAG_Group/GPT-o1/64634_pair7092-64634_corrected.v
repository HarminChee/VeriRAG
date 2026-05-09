`timescale 1ns / 1ps
`timescale 1ns / 1ps
module KeyBoard_ctrl(
    input  CLK,
    input  RESET,
    input  [3:0]  COLUMN,
    output [3:0]  ROW,
    output [3:0]  KEY_IN,
    input  test_i
);

reg    [3:0]  ROW;
reg    [3:0]  DEBOUNCE_COUNT;
reg    [3:0]  SCAN_CODE;
reg    [3:0]  SCAN_NUMBER;
reg    [3:0]  KEY_BUFFER;
reg    [14:0] DIVIDER;
reg           PRESS;
wire          PRESS_VALID;

reg           internal_clk;
wire          dft_clk;
assign dft_clk = test_i ? CLK : internal_clk;

always @(posedge CLK or negedge RESET)
begin 
    if (!RESET) 
    begin
        DIVIDER <= 15'b0;
        internal_clk <= 1'b0;
    end
    else
    begin
        DIVIDER <= DIVIDER + 1;
        internal_clk <= DIVIDER[14];
    end
end

always @(posedge dft_clk or negedge RESET)
begin
    if (!RESET)
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

always @(posedge dft_clk or negedge RESET)
begin
    if (!RESET)
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

always @(posedge dft_clk or negedge RESET)
begin
    if (!RESET)
        KEY_BUFFER <= 4'h0;
    else if (PRESS_VALID)
        KEY_BUFFER <= SCAN_NUMBER;
end

assign KEY_IN = KEY_BUFFER;

endmodule