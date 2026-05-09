`timescale 1ns / 1ps
// File: 1_corrected_cdf.v
module UART_loop(
	input UartRx,
	output UartTx,
	input clk100,
	output [7:0]LED,
    input test_mode,    // Added for DFT
    input scan_in_tog   // Added Scan input for tog FF
    // Assuming scan output for 'tog' and scan I/O for other FFs
    // are handled by DFT insertion tools or are outside the scope
    // of fixing this specific violation.
	);

    wire [7:0]Rx_D;
    reg [7:0]Tx_D;
    reg WR = 1'b0;
    reg RD = 1'b0;
    reg RST = 1'b0; // Note: RST is declared but never driven/used within this module? Assuming it's driven externally or should be removed.
    wire RXNE;
    wire TXE;

    UART_Rx # (
         .CLOCK(100_000_000),
         .BAUD_RATE(115200)
    )rx_module (
        .CLK(clk100),
        .D(Rx_D),
        .RD(RD),
        .RST(RST), // If RST is unused locally, ensure it's properly handled.
        .RX(UartRx),
        .RXNE(RXNE)
        );

    UART_Tx # (
         .CLOCK(100_000_000),
         .BAUD_RATE(115200)
    ) tx_module (
        .CLK(clk100),
        .D(Tx_D),
        .WR(WR),
        .RST(RST), // If RST is unused locally, ensure it's properly handled.
        .TX(UartTx),
        .TXE(TXE)
        );

    assign LED = Rx_D;

    reg tog = 1'b0;
    reg prevRXNE = 1'b0;

    // Next state logic calculation
    wire condition = (prevRXNE == 1'b0 && RXNE == 1'b1); // Detect rising edge of RXNE

    wire RD_next = condition ? 1'b1 : 1'b0;
    wire WR_next = condition ? 1'b1 : 1'b0;
    // Tx_D should hold its value if not updated
    wire [7:0] Tx_D_next = condition ? Rx_D : Tx_D;
    // prevRXNE always takes the current RXNE
    wire prevRXNE_next = RXNE;
    // Functional next state for tog (toggle on condition)
    wire tog_func_next = condition ? !tog : tog;

    // DFT MUX for 'tog' flip-flop input
    // In test_mode, the flip-flop input is controllable via scan_in_tog.
    // Otherwise, it uses the functional next state logic.
    // This resolves potential issues with the toggle behavior during scan testing.
    wire tog_d_input = test_mode ? scan_in_tog : tog_func_next;

    // Registers update block
    always @(posedge clk100) begin
        // Update registers based on next state logic
        // Note: A full DFT implementation would add scan MUXes for all FFs (RD, WR, Tx_D, prevRXNE).
        // Here, only 'tog' is modified based on the assumption that its toggle behavior
        // was flagged as the CDFDAT violation source.
        RD <= RD_next;
        WR <= WR_next;
        Tx_D <= Tx_D_next;
        prevRXNE <= prevRXNE_next;
        tog <= tog_d_input; // Use the muxed input for 'tog' FF
    end

endmodule