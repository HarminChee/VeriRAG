`timescale 1ns / 1ps
module TopLevel (
    input  wire clk,
    input  wire rst_in,
    input  wire[3:0] switch_in,
    output wire buzzer,
    output wire[3:0] led_out,
    inout  wire ps2CLK_in,
    input  wire ps2DATA_in,
    output wire[3:0] tubeDig_out,
    output wire[7:0] tubeSeg_out,
    output wire[7:0] lcdData,
    output wire lcdRS,
    output wire lcdRW,
    output wire lcdE,
    input  wire ir_in,
    output wire uartTXD_out,
    input  wire uartRXD_in,
    input  wire test_i
    );

parameter DIVISIONREGSIZE = 18;
reg [DIVISIONREGSIZE-1 : 0] adder = {DIVISIONREGSIZE{1'b0}};
always @ (posedge clk)
    adder <= adder + 18'b1;

wire [3:0] switch = ~switch_in;
wire rst = ~rst_in;
assign buzzer = 1'b0;

reg ps2InhibitPrev = 1'b0;
reg [10:0] inhibitCounter = 11'h7FF;
wire ps2Inhibit;
always @ (posedge clk) begin
    ps2InhibitPrev <= ps2Inhibit;
    if (ps2Inhibit && !ps2InhibitPrev)
        inhibitCounter <= 0;
    else if (inhibitCounter != 11'h7FF)
        inhibitCounter <= inhibitCounter + 1;
end

wire [3:0] led;
assign led_out = ~led;
wire [3:0] tubeDig;
wire [7:0] tubeSeg;
assign tubeSeg_out = ~tubeSeg;
assign tubeDig_out = ~tubeDig;

wire uartTXD;
assign uartTXD_out = uartTXD;
wire uartRXD = uartRXD_in;
wire ir = ~ir_in;

reg [1:0] dig;
wire dft_digclk = test_i ? clk : adder[17];
always @ (posedge dft_digclk)
    dig <= dig + 2'b1;

wire [10:0] lcdPins;
assign {lcdRS, lcdRW, lcdE, lcdData} = lcdPins;

wire bttnClk;
PushButton_Debouncer debouncer (
    .clk(clk),
    .btn_in(switch_in[3]),
    .btn_out(bttnClk)
);

wire [1:0] cpuClkMode;
wire cpuClkSel = (cpuClkMode[1] == 1'b0) ? bttnClk :
                 (cpuClkMode[0] == 1'b0) ? adder[15] : adder[6];
wire realCpuClk = test_i ? clk : cpuClkSel;

wire err;
wire [7:0] stateOut;

Rintaro rintaro (
    .fastClk (clk),
    .clk1 (!realCpuClk),
    .clk2 (realCpuClk),
    .rst (rst),
    .dig (dig),
    .switch (switch[2:0]),
    .tubeDig (tubeDig),
    .tubeSeg (tubeSeg),
    .lcdPins (lcdPins),
    .ps2CLK (ps2CLK_in),
    .ps2DATA (ps2DATA_in),
    .irqOut (),
    .ir (ir),
    .err (err),
    .stateOut (stateOut),
    .cpuClkMode (cpuClkMode)
);

wire [7:0] rs232Data;
wire rs232Ready;

RS232Controller rs232 (
    .clk (clk),
    .rst (rst),
    .rs232RX (uartRXD),
    .rs232TX (uartTXD),
    .rxData (rs232Data),
    .rxReady (rs232Ready),
    .txData (rs232Data),
    .txStart (rs232Ready)
);

assign led = {lcdRS, lcdRW, lcdE, lcdData[0]};

endmodule