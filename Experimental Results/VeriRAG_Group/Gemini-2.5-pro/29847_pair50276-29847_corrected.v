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
    input wire ir_in,
    output wire uartTXD_out,
    input  wire uartRXD_in,
    input wire test_i // Added test input
    );
parameter DIVISIONREGSIZE = 18;
reg[DIVISIONREGSIZE-1 : 0] adder = {DIVISIONREGSIZE{1'b0}};
always @ (posedge clk)
    adder <= adder + 1'b1;

wire[3:0] led;
wire[3:0] tubeDig;
wire[7:0] tubeSeg;
wire uartTXD;
wire[3:0] switch = ~switch_in;
wire rst = ~rst_in;
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

// DFT modification for dig clock
wire dft_clk_adder17;
assign dft_clk_adder17 = test_i ? clk : adder[17];

always @ (posedge dft_clk_adder17) // Use DFT clock
    dig <= dig + 2'b1;

wire[10:0] lcdPins;
assign {lcdRS, lcdRW, lcdE, lcdData} = lcdPins;
wire bttnClk;
wire irq;
// Assuming PushButton_Debouncer is a combinational or synchronous block clocked by clk
PushButton_Debouncer debouncer (clk, switch_in[3], bttnClk);
wire[1:0] cpuClkMode;
wire func_cpuClk =   cpuClkMode[1] == 1'b0 ? bttnClk :
                     cpuClkMode[0] == 1'b0 ? adder[15] : adder[6];

// DFT modification for cpuClk
wire dft_cpuClk;
assign dft_cpuClk = test_i ? clk : func_cpuClk;

// Declare missing internal wires for Rintaro outputs if they are not ports
wire err;          // Assuming err is an output wire from Rintaro
wire [7:0] stateOut; // Assuming stateOut is an output wire from Rintaro

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
    .err (err),           // Connect declared wire
    .stateOut (stateOut), // Connect declared wire
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
    .txData (rs232Data), // Assuming loopback or intended connection
    .txStart (rs232Ready) // Assuming ready triggers send
    );
assign led = {lcdRS, lcdRW, lcdE, lcdData[0]};
endmodule