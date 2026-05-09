`timescale 1ns / 1ps

module TopLevel (
    input  wire clk,
    input  wire rst_in,
    input  wire[3:0] switch_in,
    output wire buzzer,
    output wire[3:0] led_out,
    input  wire ps2CLK_in,      // Changed from inout to input
    inout  wire ps2DATA_io,     // Changed from input to inout and renamed
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

always @ (posedge clk) begin
    adder <= adder + 18'b1;
end

wire[3:0] led;
wire[3:0] tubeDig;
wire[7:0] tubeSeg;
wire uartTXD;
wire[3:0] switch = ~switch_in; // Active high switches
wire rst = ~rst_in;           // Active high reset
wire ps2Inhibit;              // Declared wire for ps2Inhibit output from Rintaro
reg ps2InhibitPrev = 1'b0;
reg[10:0] inhibitCounter = 11'h7FF;

// This logic seems related to ps2Inhibit, ensure ps2Inhibit is driven (e.g., by Rintaro)
always @ (posedge clk) begin
    ps2InhibitPrev <= ps2Inhibit;
    if (ps2Inhibit && !ps2InhibitPrev) begin
        inhibitCounter <= 11'b0;
    end else if (inhibitCounter != 11'h7FF) begin
        inhibitCounter <= inhibitCounter + 1'b1;
    end
end

assign led_out = ~led;         // Assuming active low LEDs
assign tubeSeg_out = ~tubeSeg; // Assuming active low segments
assign tubeDig_out = ~tubeDig; // Assuming active low digit select
assign buzzer = 1'b0;          // Buzzer off
assign uartTXD_out = uartTXD;
wire uartRXD = uartRXD_in;
wire ir = ~ir_in;              // Assuming active high IR signal internally

reg[1:0] dig;
always @ (posedge adder[17]) begin // Clock divider for digit multiplexing
    dig <= dig + 2'b1;
end

wire[10:0] lcdPins;
assign {lcdRS, lcdRW, lcdE, lcdData} = lcdPins;

wire bttnClk;
wire irq;
wire err;                      // Declared wire for err output from Rintaro
wire [7:0] stateOut;           // Declared wire for stateOut output from Rintaro (assuming 8 bits)
wire [1:0] cpuClkMode;

// Instantiate Debouncer (assuming module definition exists elsewhere)
PushButton_Debouncer debouncer (
    .clk(clk),
    .button_in(switch_in[3]), // Debounce one switch
    .button_out(bttnClk)
    );

wire cpuClk =   (cpuClkMode == 2'b00) ? adder[6] :      // Slowest clock mode
                (cpuClkMode == 2'b01) ? adder[15] :     // Medium clock mode
                (cpuClkMode == 2'b10) ? bttnClk :       // Button clock mode (step)
                                        clk;            // Default/Fastest clock mode (e.g., for 2'b11) - Added default

// Instantiate Rintaro core (assuming module definition exists elsewhere)
Rintaro rintaro (
    .fastClk    (clk),
    .clk1       (!cpuClk),   // Inverted CPU clock phase
    .clk2       (cpuClk),    // Non-inverted CPU clock phase
    .rst        (rst),
    .dig        (dig),
    .switch     (switch[2:0]), // Use lower 3 switches for Rintaro input
    .tubeDig    (tubeDig),
    .tubeSeg    (tubeSeg),
    .lcdPins    (lcdPins),
    .ps2CLK     (ps2CLK_in),   // Connect to input port
    .ps2DATA    (ps2DATA_io),  // Connect to inout port
    .irqOut     (irq),
    .ir         (ir),
    .err        (err),
    .stateOut   (stateOut),
    .cpuClkMode (cpuClkMode),
    .ps2Inhibit (ps2Inhibit) // Added connection for ps2Inhibit output
    );

wire[7:0] rs232Data;
wire rs232Ready;

// Instantiate RS232 Controller (assuming module definition exists elsewhere)
// Note: Current configuration creates a loopback (RX data immediately sent to TX)
RS232Controller rs232 (
    .clk        (clk),
    .rst        (rst),
    .rs232RX    (uartRXD),
    .rs232TX    (uartTXD),
    .rxData     (rs232Data),
    .rxReady    (rs232Ready),
    .txData     (rs232Data), // Loopback data
    .txStart    (rs232Ready) // Loopback start trigger
    );

// Example LED assignment for debugging/status
assign led = {err, irq, ps2Inhibit, rs232Ready}; // Example: show status on LEDs

endmodule

// Dummy module definition for PushButton_Debouncer (replace with actual if available)
module PushButton_Debouncer (
    input wire clk,
    input wire button_in,
    output wire button_out
);
    // Simplified debouncer logic (replace with a proper one)
    reg [2:0] shift_reg;
    always @(posedge clk) begin
        shift_reg <= {shift_reg[1:0], button_in};
    end
    assign button_out = (shift_reg == 3'b111) || (shift_reg == 3'b000);
endmodule

// Dummy module definition for Rintaro (replace with actual)
// Port list must match instantiation
module Rintaro (
    input wire fastClk,
    input wire clk1,
    input wire clk2,
    input wire rst,
    input wire [1:0] dig,
    input wire [2:0] switch,
    output wire [3:0] tubeDig,
    output wire [7:0] tubeSeg,
    output wire [10:0] lcdPins,
    input wire ps2CLK,
    inout wire ps2DATA, // Should match TopLevel's inout
    output wire irqOut,
    input wire ir,
    output wire err,
    output wire [7:0] stateOut, // Ensure width matches TopLevel declaration
    output wire [1:0] cpuClkMode,
    output wire ps2Inhibit
);
    // Internal logic of Rintaro would be here
    assign tubeDig = 4'hF; // Example default output
    assign tubeSeg = 8'hFF; // Example default output
    assign lcdPins = 11'h7FF; // Example default output
    assign irqOut = 1'b0;   // Example default output
    assign err = 1'b0;      // Example default output
    assign stateOut = 8'h00; // Example default output
    assign cpuClkMode = 2'b00; // Example default output
    assign ps2Inhibit = 1'b0; // Example default output
    // Add tri-state buffer for ps2DATA if Rintaro drives it
    // Example: assign ps2DATA = (ps2_data_enable) ? ps2_data_out : 1'bz;
endmodule

// Dummy module definition for RS232Controller (replace with actual)
module RS232Controller (
    input wire clk,
    input wire rst,
    input wire rs232RX,
    output wire rs232TX,
    output wire [7:0] rxData,
    output wire rxReady,
    input wire [7:0] txData,
    input wire txStart
);
    // Internal logic of RS232Controller would be here
    assign rs232TX = rs232RX; // Simplistic loopback for dummy module
    assign rxData = 8'h00;    // Example default output
    assign rxReady = 1'b0;   // Example default output
endmodule