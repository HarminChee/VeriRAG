module TopLevel (
    input  wire clk,
    input  wire rst_in,
    input  wire test_i, // Added test mode input
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
always @ (posedge clk) // Assuming rst is synchronous to clk for adder, original code didn't show reset logic here
    adder <= adder + 18'b1;
wire[3:0] led;
wire[3:0] tubeDig;
wire[7:0] tubeSeg;
wire uartTXD;
wire[3:0] switch = ~switch_in;
wire rst = ~rst_in; // Asynchronous reset derived from primary input - OK for DFT reset control
wire ps2Inhibit;
reg ps2InhibitPrev = 0;
reg[10:0] inhibitCounter = 11'h7FF;
always @ (posedge clk) begin // Assuming rst is synchronous to clk, original code didn't show reset logic here
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
wire adder_17_clk = adder[17]; // Original internal clock
wire dft_dig_clk;             // DFT clock for dig register
assign dft_dig_clk = test_i ? clk : adder_17_clk; // MUX for dig clock

// Modified dig register to use DFT clock and add synchronous reset
always @ (posedge dft_dig_clk or posedge rst) // Use DFT clock and primary reset
    if (rst)
        dig <= 2'b0;
    else
        dig <= dig + 2'b1;

wire[10:0] lcdPins;
assign {lcdRS, lcdRW, lcdE, lcdData} = lcdPins;
wire bttnClk;
wire irq;
PushButton_Debouncer debouncer (clk, switch_in[3], bttnClk); // Assumes debouncer uses clk and is DFT friendly internally
wire[1:0] cpuClkMode;
wire cpuClk_internal =   cpuClkMode[1] == 1'b0 ? bttnClk :
                         cpuClkMode[0] == 1'b0 ? adder[15] : adder[6]; // Original internal clock

wire dft_clk1; // DFT clock for rintaro clk1
wire dft_clk2; // DFT clock for rintaro clk2
assign dft_clk1 = test_i ? !clk : !cpuClk_internal; // MUX for rintaro clk1
assign dft_clk2 = test_i ? clk : cpuClk_internal;  // MUX for rintaro clk2

// Forward declarations for signals used before definition (if synthesis tool requires)
wire err;
wire [7:0] stateOut;

Rintaro rintaro (
    .fastClk (clk),      // Primary clock - OK
    .clk1 (dft_clk1),    // Use DFT controllable clock
    .clk2 (dft_clk2),    // Use DFT controllable clock
    .rst (rst),          // Reset derived from primary input - OK
    .dig (dig),
    .switch (switch[2:0]),
    .tubeDig (tubeDig),
    .tubeSeg (tubeSeg),
    .lcdPins (lcdPins),
    .ps2CLK (ps2CLK_in),
    .ps2DATA (ps2DATA_in),
    .irqOut (irq),
    .ir (ir),
    .err (err),
    .stateOut (stateOut),
    .cpuClkMode (cpuClkMode)
    );
wire[7:0] rs232Data;
wire rs232Ready;
RS232Controller rs232 (
    .clk (clk),          // Primary clock - OK
    .rst (rst),          // Reset derived from primary input - OK
    .rs232RX (uartRXD),
    .rs232TX (uartTXD),
    .rxData (rs232Data),
    .rxReady (rs232Ready),
    .txData (rs232Data), // Loopback in example
    .txStart (rs232Ready) // Start TX when RX ready in example
    );
assign led = {lcdRS, lcdRW, lcdE, lcdData[0]}; // Combinational - OK
endmodule