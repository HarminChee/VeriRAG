module TopLevel (
    test_i,
    clk,
    rst_in,
    switch_in,
    buzzer,
    led_out,
    ps2CLK_in,
    ps2DATA_in,
    tubeDig_out,
    tubeSeg_out,
    lcdData,
    lcdRS,
    lcdRW,
    lcdE,
    ir_in,
    uartTXD_out,
    uartRXD_in
    );

parameter DIVISIONREGSIZE = 18;
reg[DIVISIONREGSIZE-1 : 0] adder = {DIVISIONREGSIZE{1'b0}};

// Test Mode Logic
wire dft_clk;
assign dft_clk = test_i ? clk : 1'b0;

always @ (posedge dft_clk)
    adder <= adder + 18'b1;

wire[3:0] led;
wire[3:0] tubeDig;
wire[7:0] tubeSeg;
wire uartTXD;
wire[3:0] switch = ~switch_in;
wire rst = ~rst_in;
wire ps2Inhibit;
reg ps2InhibitPrev = 0;
reg[10:0] inhibitCounter = 11'h7FF;

always @ (posedge dft_clk) begin
    ps2InhibitPrev <= ps2Inhibit;
    if (ps2Inhibit && !ps2InhibitPrev) inhibitCounter <= 0;
    else if (inhibitCounter != 11'h7FF) inhibitCounter <= inhibitCounter + 1;
end

assign led_out = ~led;
assign tubeSeg_out = ~tubeSeg;
assign tubeDig_out = ~tubeDig;
assign buzzer = 0;
assign uartTXD_out = uartTXD;
wire uartRXD = uartRXD_in;
wire ir = ~ir_in;
reg[1:0] dig;

always @ (posedge dft_clk)
    dig <= dig + 2'b1;

wire[10:0] lcdPins;
assign {lcdRS, lcdRW, lcdE, lcdData} = lcdPins;
wire bttnClk;
wire irq;
PushButton_Debouncer debouncer (dft_clk, switch_in[3], bttnClk);

wire[1:0] cpuClkMode;
wire cpuClk =   cpuClkMode[1] == 1'b0 ? bttnClk :
                cpuClkMode[0] == 1'b0 ? adder[15] : adder[6];

Rintaro rintaro (
    .fastClk (dft_clk),
    .clk1 (!cpuClk),
    .clk2 (cpuClk),
    .rst (rst),
    .dig (dig),
    .switch (switch[2:0]),
    .tubeDig (tubeDig),
    .tubeSeg (tubeSeg),
    .lcdPins (lcdPins),
    .ps2CLK (ps2CLK_in),
    .ps2DATA (ps2DATA_in),
    .irqOut (irq),
    .ir (ir),
    .cpuClkMode (cpuClkMode)
    );

wire[7:0] rs232Data;
wire rs232Ready;
RS232Controller rs232 (
    .clk (dft_clk),
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