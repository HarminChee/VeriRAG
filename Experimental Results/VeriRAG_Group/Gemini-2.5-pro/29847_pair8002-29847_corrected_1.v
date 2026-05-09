module TopLevel (
    input  wire clk,
    input  wire rst_in,
    input  wire test_mode, // Added for DFT
    input  wire[3:0] switch_in,
    output wire buzzer,
    output wire[3:0] led_out,
    inout  wire ps2CLK_in, // Kept as inout, potential DFT issue if not handled properly in DFT flow/tools
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

// Clock Divider
reg[DIVISIONREGSIZE-1 : 0] adder = {DIVISIONREGSIZE{1'b0}};
wire rst = ~rst_in; // Active high reset derived from primary input

always @ (posedge clk) // Use primary clock 'clk'
    if (rst) // Use synchronous reset 'rst'
        adder <= {DIVISIONREGSIZE{1'b0}};
    else
        adder <= adder + 18'b1;

// Internal signals
wire[3:0] led;
wire[3:0] tubeDig;
wire[7:0] tubeSeg;
wire uartTXD;
wire[3:0] switch = ~switch_in;

// Declare signals connecting to submodules
wire ps2Inhibit;
wire irq;
wire err;
wire [7:0] stateOut;   // Assuming 8-bit width for Rintaro state output
wire [1:0] cpuClkMode; // Assuming 2-bit width for Rintaro clock mode output
wire [10:0] lcdPins;
wire bttnClk;
wire[7:0] rs232Data;
wire rs232Ready;
wire uartRXD = uartRXD_in;
wire ir = ~ir_in;


// PS2 Inhibit Logic (Uses primary clk and rst)
reg ps2InhibitPrev = 0;
reg[10:0] inhibitCounter = 11'h7FF;
always @ (posedge clk) begin
    if (rst) begin
        ps2InhibitPrev <= 1'b0;
        inhibitCounter <= 11'h7FF;
    end else begin
        ps2InhibitPrev <= ps2Inhibit; // ps2Inhibit comes from Rintaro
        if (ps2Inhibit && !ps2InhibitPrev) inhibitCounter <= 0;
        else if (inhibitCounter != 11'h7FF) inhibitCounter <= inhibitCounter + 1;
    end
end

// Output assignments
assign led_out = ~led;
assign tubeSeg_out = ~tubeSeg;
assign tubeDig_out = ~tubeDig;
assign buzzer = 1'b0; // Assign constant value
assign uartTXD_out = uartTXD;
assign {lcdRS, lcdRW, lcdE, lcdData} = lcdPins; // Connect LCD pins

// Dig counter
reg[1:0] dig;
wire dig_clk_source = adder[17]; // Internally generated clock source
wire dft_dig_clk;
assign dft_dig_clk = test_mode ? clk : dig_clk_source; // MUX for DFT

always @ (posedge dft_dig_clk) // Use muxed clock
    if (rst) // Use synchronous reset 'rst'
        dig <= 2'b0;
    else
        dig <= dig + 2'b1;


// Debouncer Instantiation (Assuming PushButton_Debouncer module is defined elsewhere)
PushButton_Debouncer debouncer (
    .clk(clk),
    .button_in(switch_in[3]), // Connect to the correct switch bit
    .button_out(bttnClk)
);


// DFT modification for Rintaro clock inputs
wire func_cpuClk =   cpuClkMode[1] == 1'b0 ? bttnClk :
                (cpuClkMode[0] == 1'b0 ? adder[15] : adder[6]); // cpuClkMode comes from Rintaro
wire dft_rintaro_clk1, dft_rintaro_clk2;
assign dft_rintaro_clk1 = test_mode ? (!clk) : (!func_cpuClk); // Use NOT primary clk in test mode - potential DFT issue
assign dft_rintaro_clk2 = test_mode ? clk    : func_cpuClk;    // Use primary clk in test mode

// Rintaro Instantiation (Assuming Rintaro module is defined elsewhere)
Rintaro rintaro (
    .fastClk (clk),
    .clk1 (dft_rintaro_clk1), // Use DFT muxed clock
    .clk2 (dft_rintaro_clk2), // Use DFT muxed clock
    .rst (rst),
    .dig (dig),
    .switch (switch[2:0]),
    .tubeDig (tubeDig),       // Output
    .tubeSeg (tubeSeg),       // Output
    .lcdPins (lcdPins),       // Output
    .ps2CLK (ps2CLK_in),      // Inout
    .ps2DATA (ps2DATA_in),    // Input
    .irqOut (irq),            // Output
    .ir (ir),                 // Input
    .err (err),               // Output
    .stateOut (stateOut),       // Output
    .cpuClkMode (cpuClkMode),   // Output
    .ps2Inhibit(ps2Inhibit)   // Output
    );

// RS232 Controller Instantiation (Assuming RS232Controller module is defined elsewhere)
RS232Controller rs232 (
    .clk (clk),
    .rst (rst),
    .rs232RX (uartRXD),       // Input
    .rs232TX (uartTXD),       // Output
    .rxData (rs232Data),      // Output
    .rxReady (rs232Ready),    // Output
    .txData (rs232Data),      // Input - Loopback from rxData? Check intended use
    .txStart (rs232Ready)     // Input - Start TX when RX ready? Check intended use
    );

// LED Assignment (Example: Assign some status signals to LEDs)
// Modify this based on actual intended LED functionality
assign led = {irq, err, rs232Ready, uartTXD};

endmodule