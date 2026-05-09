module TopLevel (
    input  wire clk,
    input  wire rst_in,
    input  wire test_mode_i, // Added test mode input
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
always @ (posedge clk)
    adder <= adder + 18'b1;
wire[3:0] led;
wire[3:0] tubeDig;
wire[7:0] tubeSeg;
wire uartTXD;
wire[3:0] switch = ~switch_in;
wire rst = ~rst_in; // Assuming simple inversion of PI is acceptable for DFT tools
wire ps2Inhibit;
reg ps2InhibitPrev = 0;
reg[10:0] inhibitCounter = 11'h7FF;
always @ (posedge clk) begin
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
// DFT Fix: Mux for internally generated clock adder[17]
wire dft_dig_clk = test_mode_i ? clk : adder[17];
always @ (posedge dft_dig_clk) // Use DFT clock
    dig <= dig + 2'b1;
wire[10:0] lcdPins;
assign {lcdRS, lcdRW, lcdE, lcdData} = lcdPins;
wire bttnClk;
wire irq;
PushButton_Debouncer debouncer (clk, switch_in[3], bttnClk);
wire[1:0] cpuClkMode;
wire cpuClk_internal = cpuClkMode[1] == 1'b0 ? bttnClk :
                       cpuClkMode[0] == 1'b0 ? adder[15] : adder[6];
// DFT Fix: Mux for internally generated clock cpuClk
wire dft_cpuClk = test_mode_i ? clk : cpuClk_internal;

Rintaro rintaro (
    .fastClk (clk),
    .clk1 (!dft_cpuClk), // Use DFT clock
    .clk2 (dft_cpuClk),  // Use DFT clock
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
    .err (err), // Assuming err is defined within Rintaro or is an output not declared here
    .stateOut (stateOut), // Assuming stateOut is defined within Rintaro or is an output not declared here
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
assign led = {lcdRS, lcdRW, lcdE, lcdData[0]};
// Implicitly declared wires err, stateOut need actual declaration if outputs of Rintaro used elsewhere
// wire err; // Example declaration if needed
// wire [?] stateOut; // Example declaration if needed
endmodule