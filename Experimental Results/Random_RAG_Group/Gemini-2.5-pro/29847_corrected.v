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
reg adder_17_prev = 1'b0; // Register to detect edge
wire adder_17_posedge;
wire rst = ~rst_in; // Primary input derived reset

// Adder logic clocked by primary clock 'clk'
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        adder <= {DIVISIONREGSIZE{1'b0}};
        adder_17_prev <= 1'b0;
    end else begin
        adder <= adder + 18'b1;
        adder_17_prev <= adder[17]; // Store previous value for edge detection
    end
end
assign adder_17_posedge = (adder[17] == 1'b1) && (adder_17_prev == 1'b0); // Detect rising edge

wire[3:0] led;
wire[3:0] tubeDig;
wire[7:0] tubeSeg;
wire uartTXD;
wire[3:0] switch = ~switch_in;

wire ps2Inhibit; // Assuming ps2Inhibit is driven by logic within Rintaro or elsewhere
reg ps2InhibitPrev = 0;
reg[10:0] inhibitCounter = 11'h7FF;

// ps2Inhibit logic clocked by primary clock 'clk'
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        ps2InhibitPrev <= 1'b0;
        inhibitCounter <= 11'h7FF;
    end else begin
        ps2InhibitPrev <= ps2Inhibit;
        if (ps2Inhibit && !ps2InhibitPrev) begin
             inhibitCounter <= 11'h000;
        end else if (inhibitCounter != 11'h7FF) begin
             inhibitCounter <= inhibitCounter + 1;
        end
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

// Corrected dig update - Clocked by clk, enabled by adder_17_posedge, reset by rst
always @ (posedge clk or posedge rst) begin
    if (rst) begin
        dig <= 2'b0;
    end else if (adder_17_posedge) begin
        dig <= dig + 2'b1;
    end
end

wire[10:0] lcdPins;
assign {lcdRS, lcdRW, lcdE, lcdData} = lcdPins;
wire bttnClk;
wire irq;
wire err;       // Declared wire for err output from Rintaro
wire [7:0] stateOut; // Declared wire for stateOut output from Rintaro

// Assuming PushButton_Debouncer is DFT-friendly (uses clk, rst)
// Need to add rst connection if debouncer requires it
PushButton_Debouncer debouncer (
    .clk(clk),
    .rst(rst), // Assuming debouncer has a reset input
    .button_in(switch_in[3]), // Assuming input name
    .button_out(bttnClk)    // Assuming output name
);

wire[1:0] cpuClkMode;
wire cpuClk_internal = cpuClkMode[1] == 1'b0 ? bttnClk :
                       cpuClkMode[0] == 1'b0 ? adder[15] : adder[6];

// DFT wrapper for Rintaro clocks
wire dft_clk1;
wire dft_clk2;

// During test mode (test_i=1), use primary clock 'clk'.
// Otherwise, use the original internally generated clocks.
// Using posedge clk as the test clock for both phases.
assign dft_clk1 = test_i ? clk : !cpuClk_internal;
assign dft_clk2 = test_i ? clk : cpuClk_internal;

Rintaro rintaro (
    .fastClk (clk),   // Primary clock
    .clk1 (dft_clk1), // Use DFT-muxed clock
    .clk2 (dft_clk2), // Use DFT-muxed clock
    .rst (rst),       // Primary input derived reset
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

// Assuming RS232Controller is DFT-friendly
RS232Controller rs232 (
    .clk (clk),       // Primary clock
    .rst (rst),       // Primary input derived reset
    .rs232RX (uartRXD),
    .rs232TX (uartTXD),
    .rxData (rs232Data),
    .rxReady (rs232Ready),
    .txData (rs232Data),
    .txStart (rs232Ready)
    );

assign led = {lcdRS, lcdRW, lcdE, lcdData[0]}; // Example assignment, may need adjustment

endmodule