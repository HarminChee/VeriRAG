`timescale 1ns / 1ps

module test(
    input CLK_IN,
    output [7:0] LEDS,
    output reg [7:0] DEBUG,
    output WS, // Changed from output reg
    output OPEN,
    input [2:0] COL,
    inout [3:0] ROW,
    input [3:0] SW
    );

    localparam CLKDIV = 20;

    wire CLK; // (* BUFG = "clk" *) // Synthesis attribute - keep if needed for target FPGA
    reg RESET; // Initial value set in initial block
    wire [255:0] W;
    reg [255:0] W2; // Initial value set in initial block
    wire WS_asic;
    wire ERROR;
    reg [15:0] startup; // Widened from [8:0] for comparison, initial value set in initial block
    reg [CLKDIV:0] counter = 0; // Initial value okay here
    wire [3:0] ROW_asic;
    wire OPENER; // Added wire declaration
    wire CLK2;

    initial begin
        RESET = 1;
        W2 = 256'b0;
        startup = 0;
        DEBUG = 8'b0; // Initialize output reg
    end

    custom challenge (
        .RESET(SW[0]),
        .CLK(CLK),
        .COL(COL),
        .ROW(ROW_asic), // Input from keypad internal wire
        .OPEN(OPEN),
        .W(W),
        .DEBUG(DEBUG[6:0]) // Drives lower 7 bits of DEBUG (handled in always block below)
    );

    ws2812b display (
        .RESET(RESET),
        .W(W2),
        .CLK50(CLK_IN),
        .WS(WS_asic),
        .OPENER(OPENER),
        .ERROR(ERROR)
    );

    sr_timer #(200) success (
        .S(OPEN),
        .R(RESET),
        .CLK(CLK),
        .OUT(OPENER)
    );

    keypad keypad (
        .COL(COL),
        .ROW(ROW),       // Connects to the physical inout pins
        .ROW_asic(ROW_asic), // Drives the internal state wire read by 'custom'
        .ERROR(ERROR)
    );

    // Clock divider
    always @(posedge CLK_IN) begin
        counter <= counter + 1;
    end

    assign CLK = counter[CLKDIV-1];
    assign CLK2 = counter[CLKDIV-3]; // Used for W2 latching edge

    // Latch challenge output W on negedge of CLK2
    always @(negedge CLK2) begin
        W2 <= W;
    end

    // Startup sequence to deassert RESET
    always @(posedge CLK_IN) begin
        if (startup < 16'hFFFF) begin // Corrected comparison value
            startup <= startup + 1;
        end else begin
            RESET <= 0;
        end
    end

    // Combine assignments to DEBUG output register
    // Note: 'custom' instance drives DEBUG[6:0]. This implies DEBUG[6:0] should reflect W[6:0] or similar.
    // Assuming 'custom' module has an output port named DEBUG driving these bits.
    // The direct connection in the instantiation handles this implicitly if DEBUG port in 'custom' is output [6:0].
    // However, assigning DEBUG[7] requires combining logic.
    // Let's assume 'custom' instance implicitly drives the lower bits and we assign the top bit here.
    // A cleaner way might be to have 'custom' output a wire for its debug bits, then combine here.
    // Sticking to the original structure's implied intent:
    wire [6:0] custom_debug; // Assume 'custom' drives this implicitly via port connection
    assign custom_debug = DEBUG[6:0]; // This reads the value driven by the instance, which is unusual.
                                      // More likely: custom instance should output to a wire, e.g., custom_debug_out
                                      // Let's assume the instance connection `.DEBUG(DEBUG[6:0])` works like Verilog 2001+ port connection rules
                                      // where the instance drives these bits of the 'reg'.

    // This always block is problematic as 'custom' instance also drives DEBUG[6:0]
    // A better approach:
    // 1. Declare `wire [6:0] custom_debug_out;`
    // 2. Connect `custom challenge ( ... .DEBUG(custom_debug_out) ...);`
    // 3. Use an always block or assign to drive the final DEBUG reg:
    //    `always @(*) begin`
    //    `   DEBUG[6:0] = custom_debug_out;`
    //    `   DEBUG[7] = WS_asic; // Use WS_asic directly`
    //    `end`
    // Let's implement the better approach:

    wire [6:0] custom_debug_out; // New wire for custom's debug output

    // Re-instantiate custom challenge with the new wire
    custom challenge challenge_inst ( // Added instance name for clarity
        .RESET(SW[0]),
        .CLK(CLK),
        .COL(COL),
        .ROW(ROW_asic),
        .OPEN(OPEN),
        .W(W),
        .DEBUG(custom_debug_out) // Connect to the new wire
    );

    // Combine custom debug output and WS_asic into the DEBUG register
    always @(*) begin
        DEBUG[6:0] = custom_debug_out;
        DEBUG[7] = WS_asic; // Drive the top bit based on WS_asic
    end

    // Assign LEDS based on combined DEBUG and OPENER status
    assign LEDS = DEBUG | {8{OPENER}};

    // Pass WS_asic signal to the top-level WS output port
    assign WS = WS_asic; // Changed from always@(*) block

endmodule