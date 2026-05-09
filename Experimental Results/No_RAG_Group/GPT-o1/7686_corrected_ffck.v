(001_corrected_ffc.v)

`timescale 1ns / 1ps
module test(
    input CLK_IN,
    output [7:0] LEDS,
    output [7:0] DEBUG,
    output reg WS,
    output OPEN,
    input [2:0] COL,
    inout [3:0] ROW,
    input [3:0] SW
    );

localparam CLKDIV = 20;
reg RESET = 1;
wire [255:0] W;
reg [255:0] W2 = 256'b0;
wire WS_asic;
wire ERROR;
wire [3:0] ROW_asic;
wire OPENER;
reg [8:0] startup = 0;
reg [CLKDIV:0] counter = 0;
reg oldClk2 = 0;

custom challenge (
    .RESET(SW[0]),
    .CLK(CLK_IN),
    .COL(COL),
    .ROW(ROW_asic),
    .OPEN(OPEN),
    .W(W),
    .DEBUG(DEBUG[6:0])
);

ws2812b display (
    .RESET(RESET),
    .W(W2),
    .CLK50(CLK_IN),
    .WS(WS_asic),
    .OPENER(OPENER),
    .ERROR(ERROR)
);

sr_timer #(200) success (
    .S(OPEN),
    .R(RESET),
    .CLK(CLK_IN),
    .OUT(OPENER)
);

keypad keypad (
    .COL(COL),
    .ROW(ROW),
    .ROW_asic(ROW_asic),
    .ERROR(ERROR)
);

always @(posedge CLK_IN) begin
    counter <= counter + 1;
end

always @(posedge CLK_IN) begin
    oldClk2 <= counter[CLKDIV-3];
    if (oldClk2 && !counter[CLKDIV-3]) begin
        W2 <= W;
    end
end

always @(posedge CLK_IN) begin
    if (startup < 8'hffff)
        startup <= startup + 1;
    else
        RESET <= 0;
end

assign LEDS = DEBUG | {8{OPENER}};
assign DEBUG[7] = WS;

always @(*) begin
    WS = WS_asic;
end

endmodule