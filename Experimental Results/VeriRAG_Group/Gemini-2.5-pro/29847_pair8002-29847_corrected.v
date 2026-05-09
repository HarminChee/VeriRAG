module TopLevel (
    input  wire clk,
    input  wire rst_in,
    input  wire test_mode, // Added for DFT
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
    input wire ir_in,
    output wire uartTXD_out,
    input  wire uartRXD_in
    );
parameter DIVISIONREGSIZE = 18;
reg[DIVISIONREGSIZE-1 : 0] adder = {DIVISIONREGSIZE{1'b0}};
always @ (posedge clk) // Assuming rst is synchronous reset for this FF
    if (rst)
        adder <= {DIVISIONREGSIZE{1'b0}};
    else
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
always @ (posedge clk) begin // Assuming rst is synchronous reset for these FFs
    if (rst) begin
        ps2InhibitPrev <= 1'b0;
        inhibitCounter <= 11'h7FF;
    end else begin
        ps2InhibitPrev <= ps2Inhibit;
        if (ps2Inhibit && !ps2InhibitPrev) inhibitCounter <= 0;
        else if (inhibitCounter != 11'h7FF) inhibitCounter <= inhibitCounter + 1;
    end
end
assign led_out = ~led;
assign tubeSeg_out = ~tubeSeg;
assign tubeDig_out = ~tubeDig;
assign buzzer = 0;
assign uartTXD_out = uartTXD;
wire uartRXD = uartRXD_in;
wire ir = ~ir_in;
reg[1:0] dig;

// DFT modification for dig clock
wire dig_clk_source = adder[17];
wire dft_dig_clk;
assign dft_dig_clk = test_mode ? clk : dig_clk_source;

always @ (posedge dft_dig_clk) // Use DFT clock, add synchronous reset
    if (rst)
        dig <= 2'b0;
    else
        dig <= dig + 2'b1;

wire[10:0] lcdPins;
assign {lcdRS, lcdRW, lcdE, lcdData} = lcdPins;
wire bttnClk;
wire irq;
PushButton_Debouncer debouncer (clk, switch_in[3], bttnClk);
wire[1:0] cpuClkMode;

// DFT modification for Rintaro clock
wire func_cpuClk =   cpuClkMode[1] == 1'b0 ? bttnClk :
                cpuClkMode[0] == 1'b0 ? adder[15] : adder[6];
wire dft_rintaro_clk1, dft_rintaro_clk2;
assign dft_rintaro_clk1 = test_mode ? !clk : !func_cpuClk;
assign dft_rintaro_clk2 = test_mode ? clk  : func_cpuClk;

Rintaro rintaro (
    .fastClk (clk),
    .clk1 (dft_rintaro_clk1), // Use DFT clock
    .clk2 (dft_rintaro_clk2), // Use DFT clock
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
    .err (err), // Assuming err is defined elsewhere or within Rintaro
    .stateOut (stateOut), // Assuming stateOut is defined elsewhere or within Rintaro
    .cpuClkMode (cpuClkMode)
    );
wire[7:0] rs232Data;
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
assign led = {lcdRS, lcdRW, lcdE, lcdData[0]}; // Example assignment, may need review based on actual LCD pins usage
endmodule