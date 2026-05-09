module TopLevel (
    input  wire clk,
    input  wire rst_in,
    input  wire[3:0] switch_in,
    input  wire test_i, // Added test mode input
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

// Adder clocked by primary clock 'clk' - OK
always @ (posedge clk)
    adder <= adder + 18'b1;

wire[3:0] led;
wire[3:0] tubeDig;
wire[7:0] tubeSeg;
wire uartTXD;
wire[3:0] switch = ~switch_in;
wire rst = ~rst_in; // Reset derived from primary input - OK for async reset
wire ps2Inhibit;
reg ps2InhibitPrev = 0;
reg[10:0] inhibitCounter = 11'h7FF;

// These registers clocked by primary clock 'clk' - OK
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

// Original clock for 'dig' register: adder[17] (Internal Clock - FFCKNP/CLKNPI Violation)
// Create muxed clock for 'dig' register
wire dig_clk_mux = test_i ? clk : adder[17];

// Use muxed clock for 'dig' register
always @ (posedge dig_clk_mux)
    dig <= dig + 2'b1;

wire[10:0] lcdPins;
assign {lcdRS, lcdRW, lcdE, lcdData} = lcdPins;
wire bttnClk;
wire irq;

// Debouncer clocked by primary clock 'clk' - OK (assuming internal FFs are clocked by clk)
PushButton_Debouncer debouncer (clk, switch_in[3], bttnClk);

wire[1:0] cpuClkMode;
wire err;        // Added wire declaration for err
wire[3:0] stateOut; // Added wire declaration for stateOut

// Original cpuClk generation uses internal signals (bttnClk, adder[15], adder[6]) - CLKNPI/FFCKNP Violation for Rintaro
wire func_cpuClk =   cpuClkMode[1] == 1'b0 ? bttnClk :
                     (cpuClkMode[0] == 1'b0 ? adder[15] : adder[6]);

// Create muxed clock for Rintaro instance
wire dft_cpuClk = test_i ? clk : func_cpuClk;


Rintaro rintaro (
    .fastClk (clk), // Clocked by primary clock 'clk' - OK
    .clk1 (!dft_cpuClk), // Use muxed clock
    .clk2 (dft_cpuClk), // Use muxed clock
    .rst (rst), // Reset derived from primary input - OK
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

// RS232Controller clocked by primary clock 'clk' and reset by 'rst' - OK
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