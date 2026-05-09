`timescale 1ns / 1ps

module ssdCtrl(
    input            CLK,
    input            RST,
    input  [9:0]     DIN,
    output reg [3:0] AN,
    output reg [6:0] SEG,
    output           DOT,
    output wire [15:0] bcdData
);

    // 1 kHz Clock Divider
    parameter [15:0] cntEndVal = 16'hC350;
    reg [15:0]       clkCount;
    reg              DCLK;
    
    // 2 Bit Counter
    reg [1:0]        CNT;
    
    // Output Data Mux
    reg [3:0]        muxData;
    
    // Assign DOT when count is 2
    assign DOT = (CNT == 2'b11) ? 1'b0 : 1'b1;
    
    // Format Data
    Format_Data FDATA(
        .CLK(CLK),
        .DCLK(DCLK),
        .RST(RST),
        .DIN(DIN),
        .BCDOUT(bcdData)
    );
    
    // Output Data Mux
    always @(*) begin
        if (RST == 1'b1)
            muxData = 4'b0000;
        else begin
            case (CNT)
                2'b00: muxData = bcdData[3:0];
                2'b01: muxData = bcdData[7:4];
                2'b10: muxData = bcdData[11:8];
                2'b11: muxData = bcdData[15:12];
                default: muxData = 4'b0000;
            endcase
        end
    end
    
    // Segment Decoder
    always @(posedge DCLK or posedge RST) begin
        if (RST == 1'b1)
            SEG <= 7'b1000000;
        else begin
            case (muxData)
                4'h0 : SEG <= 7'b1000000; // 0
                4'h1 : SEG <= 7'b1111001; // 1
                4'h2 : SEG <= 7'b0100100; // 2
                4'h3 : SEG <= 7'b0110000; // 3
                4'h4 : SEG <= 7'b0011001; // 4
                4'h5 : SEG <= 7'b0010010; // 5
                4'h6 : SEG <= 7'b0000010; // 6
                4'h7 : SEG <= 7'b1111000; // 7
                4'h8 : SEG <= 7'b0000000; // 8
                4'h9 : SEG <= 7'b0010000; // 9
                4'hA : SEG <= 7'b0111111; // Minus
                4'hF : SEG <= 7'b1111111; // Off
                default : SEG <= 7'b1111111;
            endcase
        end
    end
    
    // Anode Decoder
    always @(posedge DCLK or posedge RST) begin
        if (RST == 1'b1)
            AN <= 4'b1111;
        else begin
            case (CNT)
                2'b00 : AN <= 4'b1110;
                2'b01 : AN <= 4'b1101;
                2'b10 : AN <= 4'b1011;
                2'b11 : AN <= 4'b0111;
                default : AN <= 4'b1111;
            endcase
        end
    end
    
    // 2 Bit Counter
    always @(posedge DCLK) begin
        CNT <= CNT + 1'b1;
    end
    
    // 1 kHz Clock Divider
    always @(posedge CLK) begin
        if (clkCount == cntEndVal) begin
            DCLK <= 1'b1;
            clkCount <= 16'h0000;
        end
        else begin
            DCLK <= 1'b0;
            clkCount <= clkCount + 1'b1;
        end
    end

endmodule