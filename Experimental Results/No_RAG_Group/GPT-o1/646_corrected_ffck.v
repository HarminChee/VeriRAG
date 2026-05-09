`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////////
// (1)_corrected_ffc.v
///////////////////////////////////////////////////////////////////////////////////

module ssdCtrl(
    CLK,
    RST,
    DIN,
    AN,
    SEG,
    DOT,
    bcdData
);

// Port Declarations
input            CLK;
input            RST;
input  [9:0]     DIN;
output [3:0]     AN;
reg    [3:0]     AN;
output [6:0]     SEG;
reg    [6:0]     SEG;
output           DOT;
output wire [15:0] bcdData;

// Parameters, Registers, and Wires
parameter [15:0] cntEndVal = 16'hC350;
reg  [15:0] clkCount;
wire        dclk_enable;
reg  [1:0]  CNT;
reg  [3:0]  muxData;

// Generate a 1 kHz enable signal instead of an internal clock
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        clkCount <= 16'h0000;
    end
    else begin
        if (clkCount == cntEndVal)
            clkCount <= 16'h0000;
        else
            clkCount <= clkCount + 1'b1;
    end
end

assign dclk_enable = (clkCount == cntEndVal);

// Format Data
Format_Data FDATA(
    .CLK   (CLK),
    .DCLK  (dclk_enable),
    .RST   (RST),
    .DIN   (DIN),
    .BCDOUT(bcdData)
);

// Assign DOT when count is 3
assign DOT = (CNT == 2'b11) ? 1'b0 : 1'b1;

// Select data to display on SSD
always @(*) begin
    if (RST)
        muxData = 4'b0000;
    else begin
        case (CNT)
            2'b00 : muxData = bcdData[3:0];
            2'b01 : muxData = bcdData[7:4];
            2'b10 : muxData = bcdData[11:8];
            2'b11 : muxData = bcdData[15:12];
            default : muxData = 4'b0000;
        endcase
    end
end

// 2 Bit Counter using enable
always @(posedge CLK or posedge RST) begin
    if (RST)
        CNT <= 2'b00;
    else if (dclk_enable)
        CNT <= CNT + 1'b1;
end

// Segment Decoder
always @(posedge CLK or posedge RST) begin
    if (RST)
        SEG <= 7'b1000000;
    else if (dclk_enable) begin
        case (muxData)
            4'h0 : SEG <= 7'b1000000;	  // 0
            4'h1 : SEG <= 7'b1111001;	  // 1
            4'h2 : SEG <= 7'b0100100;	  // 2
            4'h3 : SEG <= 7'b0110000;	  // 3
            4'h4 : SEG <= 7'b0011001;	  // 4
            4'h5 : SEG <= 7'b0010010;	  // 5
            4'h6 : SEG <= 7'b0000010;	  // 6
            4'h7 : SEG <= 7'b1111000;	  // 7
            4'h8 : SEG <= 7'b0000000;	  // 8
            4'h9 : SEG <= 7'b0010000;	  // 9
            4'hA : SEG <= 7'b0111111;	  // Minus
            4'hF : SEG <= 7'b1111111;	  // Off
            default : SEG <= 7'b1111111;
        endcase
    end
end

// Anode Decoder
always @(posedge CLK or posedge RST) begin
    if (RST)
        AN <= 4'b1111;
    else if (dclk_enable) begin
        case (CNT)
            2'b00 : AN <= 4'b1110; // Digit 0
            2'b01 : AN <= 4'b1101; // Digit 1
            2'b10 : AN <= 4'b1011; // Digit 2
            2'b11 : AN <= 4'b0111; // Digit 3
            default : AN <= 4'b1111;
        endcase
    end
end

endmodule

`timescale 1ns / 1ps

///////////////////////////////////////////////////////////////////////////////////
// (2)_corrected_ffc.v
///////////////////////////////////////////////////////////////////////////////////

module ssdCtrl_2(
    CLK,
    RST,
    DIN,
    AN,
    SEG,
    DOT,
    bcdData
);

// Port Declarations
input            CLK;
input            RST;
input  [9:0]     DIN;
output [3:0]     AN;
reg    [3:0]     AN;
output [6:0]     SEG;
reg    [6:0]     SEG;
output           DOT;
output wire [15:0] bcdData;

// Parameters, Registers, and Wires
parameter [15:0] cntEndVal = 16'hC350;
reg  [15:0] clkCount;
wire        dclk_enable;
reg  [1:0]  CNT;
reg  [3:0]  muxData;

// Generate a 1 kHz enable signal instead of an internal clock
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        clkCount <= 16'h0000;
    end
    else begin
        if (clkCount == cntEndVal)
            clkCount <= 16'h0000;
        else
            clkCount <= clkCount + 1'b1;
    end
end

assign dclk_enable = (clkCount == cntEndVal);

// Format Data
Format_Data FDATA(
    .CLK   (CLK),
    .DCLK  (dclk_enable),
    .RST   (RST),
    .DIN   (DIN),
    .BCDOUT(bcdData)
);

// Assign DOT when count is 3
assign DOT = (CNT == 2'b11) ? 1'b0 : 1'b1;

// Select data to display on SSD
always @(*) begin
    if (RST)
        muxData = 4'b0000;
    else begin
        case (CNT)
            2'b00 : muxData = bcdData[3:0];
            2'b01 : muxData = bcdData[7:4];
            2'b10 : muxData = bcdData[11:8];
            2'b11 : muxData = bcdData[15:12];
            default : muxData = 4'b0000;
        endcase
    end
end

// 2 Bit Counter using enable
always @(posedge CLK or posedge RST) begin
    if (RST)
        CNT <= 2'b00;
    else if (dclk_enable)
        CNT <= CNT + 1'b1;
end

// Segment Decoder
always @(posedge CLK or posedge RST) begin
    if (RST)
        SEG <= 7'b1000000;
    else if (dclk_enable) begin
        case (muxData)
            4'h0 : SEG <= 7'b1000000;	  // 0
            4'h1 : SEG <= 7'b1111001;	  // 1
            4'h2 : SEG <= 7'b0100100;	  // 2
            4'h3 : SEG <= 7'b0110000;	  // 3
            4'h4 : SEG <= 7'b0011001;	  // 4
            4'h5 : SEG <= 7'b0010010;	  // 5
            4'h6 : SEG <= 7'b0000010;	  // 6
            4'h7 : SEG <= 7'b1111000;	  // 7
            4'h8 : SEG <= 7'b0000000;	  // 8
            4'h9 : SEG <= 7'b0010000;	  // 9
            4'hA : SEG <= 7'b0111111;	  // Minus
            4'hF : SEG <= 7'b1111111;	  // Off
            default : SEG <= 7'b1111111;
        endcase
    end
end

// Anode Decoder
always @(posedge CLK or posedge RST) begin
    if (RST)
        AN <= 4'b1111;
    else if (dclk_enable) begin
        case (CNT)
            2'b00 : AN <= 4'b1110; // Digit 0
            2'b01 : AN <= 4'b1101; // Digit 1
            2'b10 : AN <= 4'b1011; // Digit 2
            2'b11 : AN <= 4'b0111; // Digit 3
            default : AN <= 4'b1111;
        endcase
    end
end

endmodule