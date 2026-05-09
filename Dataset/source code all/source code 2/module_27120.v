`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module Gameover
(
    input wire gameover,
    input wire [9:0] hcount_in,
    input wire hsync_in,
    input wire [9:0] vcount_in,
    input wire vsync_in,
    input wire [23:0] rgb_in,
    input wire blnk_in,
    input wire clk,
    input wire rst,
    output reg [9:0] hcount_out,
    output reg hsync_out,
    output reg [9:0] vcount_out,
    output reg vsync_out,
    output reg [23:0] rgb_out,
    output reg blnk_out
    );
    localparam LETTER_XS = 11;
    localparam LETTER_YS = 10;
    localparam X1_CENTER = 170;
    localparam Y1_CENTER = 180;
    localparam SIZE1 = 9;
    localparam X1_OFFSET = X1_CENTER + LETTER_XS*SIZE1/2;
    localparam Y1_OFFSET = Y1_CENTER + LETTER_YS*SIZE1/2;
    localparam X2_CENTER = 270;
    localparam Y2_CENTER = 180;
    localparam SIZE2 = 9;
    localparam X2_OFFSET = X2_CENTER + LETTER_XS*SIZE2/2;
    localparam Y2_OFFSET = Y2_CENTER + LETTER_YS*SIZE2/2;
    localparam X3_CENTER = 370;
    localparam Y3_CENTER = 180;
    localparam SIZE3 = 9;
    localparam X3_OFFSET = X3_CENTER + LETTER_XS*SIZE3/2;
    localparam Y3_OFFSET = Y3_CENTER + LETTER_YS*SIZE3/2;
    localparam X4_CENTER = 470;
    localparam Y4_CENTER = 180;
    localparam SIZE4 = 9;
    localparam X4_OFFSET = X4_CENTER + LETTER_XS*SIZE4/2;
    localparam Y4_OFFSET = Y4_CENTER + LETTER_YS*SIZE4/2;
    localparam X5_CENTER = 170;
    localparam Y5_CENTER = 300;
    localparam SIZE5 = 9;
    localparam X5_OFFSET = X5_CENTER + LETTER_XS*SIZE5/2;
    localparam Y5_OFFSET = Y5_CENTER + LETTER_YS*SIZE5/2;
    localparam X6_CENTER = 270;
    localparam Y6_CENTER = 300;
    localparam SIZE6 = 9;
    localparam X6_OFFSET = X6_CENTER + LETTER_XS*SIZE6/2;
    localparam Y6_OFFSET = Y6_CENTER + LETTER_YS*SIZE6/2;
    localparam X7_CENTER = 370;
    localparam Y7_CENTER = 300;
    localparam SIZE7 = 9;
    localparam X7_OFFSET = X7_CENTER + LETTER_XS*SIZE7/2;
    localparam Y7_OFFSET = Y7_CENTER + LETTER_YS*SIZE7/2;
    localparam X8_CENTER = 470;
    localparam Y8_CENTER = 300;
    localparam SIZE8 = 9;
    localparam X8_OFFSET = X8_CENTER + LETTER_XS*SIZE8/2;
    localparam Y8_OFFSET = Y8_CENTER + LETTER_YS*SIZE8/2;
    localparam reg [10:0] V_LETTER [9:0] ={
        11'b10000000001,
        11'b01000000010,
        11'b01000000010,
        11'b00100000100,
        11'b00100000100,
        11'b00010001000,
        11'b00010001000,
        11'b00001010000,
        11'b00001010000,
        11'b00000100000};
    localparam reg [10:0] A_LETTER [9:0] ={
        11'b00111111100,
        11'b01000000010,
        11'b01000000010,
        11'b01000000010,
        11'b01111111110,
        11'b01000000010,
        11'b01000000010,
        11'b01000000010,
        11'b01000000010,
        11'b01000000010};
    localparam reg [10:0] M_LETTER [9:0] ={
        11'b10000000001,
        11'b11000000011,
        11'b10100000101,
        11'b10010001001,
        11'b10001010001,
        11'b10000100001,
        11'b10000000001,
        11'b10000000001,
        11'b10000000001,
        11'b10000000001};
    localparam reg [10:0] E_LETTER [9:0] ={
        11'b01111111110,
        11'b01000000000,
        11'b01000000000,
        11'b01000000000,
        11'b01111111110,
        11'b01000000000,
        11'b01000000000,
        11'b01000000000,
        11'b01000000000,
        11'b01111111110};
    localparam reg [10:0] O_LETTER [9:0] ={
        11'b00111111100,
        11'b01000000010,
        11'b01000000010,
        11'b01000000010,
        11'b01000000010,
        11'b01000000010,
        11'b01000000010,
        11'b01000000010,
        11'b01000000010,
        11'b00111111100};
    localparam reg [10:0] R_LETTER [9:0] ={
        11'b01111111100,
        11'b01000000010,
        11'b01000000010,
        11'b01000000010,
        11'b01111111100,
        11'b01000100000,
        11'b01000010000,
        11'b01000001000,
        11'b01000000100,
        11'b01000000010};
    localparam reg [10:0] G_LETTER [9:0] ={
        11'b00011111000,
        11'b00100000100,
        11'b01000000010,
        11'b01000000010,
        11'b01000000000,
        11'b01000011110,
        11'b01000000010,
        11'b01000000010,
        11'b00100000100,
        11'b00011111000};
    localparam YRES = 480;
    localparam BLACK = 24'h00_00_00;
    localparam WHITE = 24'hff_ff_ff;
    reg [23:0] rgb_nxt = 0;
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            hcount_out  <= #1 0;
            hsync_out   <= #1 0;  
            vcount_out  <= #1 0;
            vsync_out   <= #1 0;
            rgb_out     <= #1 0;
            blnk_out    <= #1 0;
        end
        else begin 
            hcount_out  <= #1 hcount_in;
            hsync_out   <= #1 hsync_in;
            vcount_out  <= #1 vcount_in;
            vsync_out   <= #1 vsync_in;
            rgb_out     <= #1 rgb_nxt;
            blnk_out    <= #1 blnk_in;
        end
    end
    always @* begin
        if(gameover) begin
            if(((Y1_OFFSET - vcount_in) <= LETTER_YS*SIZE1 - 1) && ((Y1_OFFSET - vcount_in) >= 0) && ((X1_OFFSET - hcount_in) <= LETTER_XS * SIZE1 - 1) && ((X1_OFFSET - hcount_in) >= 0)) begin
                if(G_LETTER[(Y1_OFFSET - vcount_in)/SIZE1][(X1_OFFSET - hcount_in)/SIZE1] == 1) 
                    begin
                        rgb_nxt = WHITE;
                    end
                else rgb_nxt = BLACK;
            end
            else if(((Y2_OFFSET - vcount_in) <= LETTER_YS*SIZE2 - 1) && ((Y2_OFFSET - vcount_in) >= 0) && ((X2_OFFSET - hcount_in) <= LETTER_XS * SIZE2 - 1) && ((X2_OFFSET - hcount_in) >= 0)) begin
                if(A_LETTER[(Y2_OFFSET - vcount_in)/SIZE2][(X2_OFFSET - hcount_in)/SIZE2] == 1) 
                    begin
                        rgb_nxt = WHITE;
                        end
                    else rgb_nxt = BLACK;
            end
            else if(((Y3_OFFSET - vcount_in) <= LETTER_YS*SIZE3 - 1) && ((Y3_OFFSET - vcount_in) >= 0) && ((X3_OFFSET - hcount_in) <= LETTER_XS * SIZE3 - 1) && ((X3_OFFSET - hcount_in) >= 0)) begin
                if(M_LETTER[(Y3_OFFSET - vcount_in)/SIZE3][(X3_OFFSET - hcount_in)/SIZE3] == 1) 
                    begin
                        rgb_nxt = WHITE;
                        end
                    else rgb_nxt = BLACK;
            end
            else if(((Y4_OFFSET - vcount_in) <= LETTER_YS*SIZE4 - 1) && ((Y4_OFFSET - vcount_in) >= 0) && ((X4_OFFSET - hcount_in) <= LETTER_XS * SIZE4 - 1) && ((X4_OFFSET - hcount_in) >= 0)) begin
                if(E_LETTER[(Y4_OFFSET - vcount_in)/SIZE4][(X4_OFFSET - hcount_in)/SIZE4] == 1) 
                    begin
                        rgb_nxt = WHITE;
                        end
                    else rgb_nxt = BLACK;
            end
            else if(((Y5_OFFSET - vcount_in) <= LETTER_YS*SIZE5 - 1) && ((Y5_OFFSET - vcount_in) >= 0) && ((X5_OFFSET - hcount_in) <= LETTER_XS * SIZE5 - 1) && ((X5_OFFSET - hcount_in) >= 0)) begin
                if(O_LETTER[(Y5_OFFSET - vcount_in)/SIZE5][(X5_OFFSET - hcount_in)/SIZE5] == 1) 
                   begin
                        rgb_nxt = WHITE;
                       end
                   else rgb_nxt = BLACK;
            end
            else if(((Y6_OFFSET - vcount_in) <= LETTER_YS*SIZE6 - 1) && ((Y6_OFFSET - vcount_in) >= 0) && ((X6_OFFSET - hcount_in) <= LETTER_XS * SIZE6 - 1) && ((X6_OFFSET - hcount_in) >= 0)) begin
                if(V_LETTER[(Y6_OFFSET - vcount_in)/SIZE6][(X6_OFFSET - hcount_in)/SIZE6] == 1) 
                    begin
                        rgb_nxt = WHITE;
                        end
                    else rgb_nxt = BLACK;
            end
            else if(((Y7_OFFSET - vcount_in) <= LETTER_YS*SIZE7 - 1) && ((Y7_OFFSET - vcount_in) >= 0) && ((X7_OFFSET - hcount_in) <= LETTER_XS * SIZE7 - 1) && ((X7_OFFSET - hcount_in) >= 0)) begin
                if(E_LETTER[(Y7_OFFSET - vcount_in)/SIZE7][(X7_OFFSET - hcount_in)/SIZE7] == 1) 
                    begin
                        rgb_nxt = WHITE;
                        end
                    else rgb_nxt = BLACK;
            end
            else if(((Y8_OFFSET - vcount_in) <= LETTER_YS*SIZE8 - 1) && ((Y8_OFFSET - vcount_in) >= 0) && ((X8_OFFSET - hcount_in) <= LETTER_XS * SIZE8 - 1) && ((X8_OFFSET - hcount_in) >= 0)) begin
                if(R_LETTER[(Y8_OFFSET - vcount_in)/SIZE8][(X8_OFFSET - hcount_in)/SIZE8] == 1) 
                   begin
                        rgb_nxt = WHITE;
                       end
                   else rgb_nxt = BLACK;
            end
            else begin
                rgb_nxt = BLACK;
            end
        end
        else begin
            rgb_nxt = rgb_in;
        end
    end
endmodule
