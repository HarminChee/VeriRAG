`timescale 1ns / 1ps

module UART_loop(
    input UartRx,
    output UartTx,
    input clk100,
    output [7:0] LED
);

    // Internal signals
    wire [7:0] Rx_D;       // Data output from UART_Rx module
    reg  [7:0] Tx_D;       // Data input to UART_Tx module
    reg  WR = 1'b0;        // Write enable pulse for UART_Tx
    reg  RD = 1'b0;        // Read enable pulse for UART_Rx
    reg  RST = 1'b0;       // Reset (kept low in this example)
    wire RXNE;             // Receiver Not Empty flag from UART_Rx
    wire TXE;              // Transmitter Empty flag from UART_Tx

    // Internal state registers
    reg  prevRXNE = 1'b0;        // Previous state of RXNE for edge detection
    reg  [7:0] latched_Rx_D;   // Register to hold the last received byte stably
    reg  data_ready_to_tx = 1'b0;// Flag: latched data is waiting for transmission

    // Instantiate UART Receiver
    // Assuming UART_Rx module exists with these parameters and ports
    UART_Rx # (
        .CLOCK(100_000_000), // System clock frequency in Hz
        .BAUD_RATE(115200)   // Desired baud rate
    ) rx_module (
        .CLK(clk100),        // System clock input
        .D(Rx_D),            // Received data output
        .RD(RD),             // Read enable input (pulse high to read)
        .RST(RST),           // Reset input
        .RX(UartRx),         // Serial data input
        .RXNE(RXNE)          // Receiver Not Empty output flag
    );

    // Instantiate UART Transmitter
    // Assuming UART_Tx module exists with these parameters and ports
    UART_Tx # (
        .CLOCK(100_000_000), // System clock frequency in Hz
        .BAUD_RATE(115200)   // Desired baud rate
    ) tx_module (
        .CLK(clk100),        // System clock input
        .D(Tx_D),            // Data to transmit input
        .WR(WR),             // Write enable input (pulse high to start tx)
        .RST(RST),           // Reset input
        .TX(UartTx),         // Serial data output
        .TXE(TXE)            // Transmitter Empty output flag
    );

    // Control logic for reading data, latching it, and triggering transmission
    always @(posedge clk100) begin
        // Default assignments for control signals (ensure they are pulses)
        RD <= 1'b0;
        WR <= 1'b0;

        // Store previous RXNE state for rising edge detection
        prevRXNE <= RXNE;

        // --- Receive and Latch Logic ---
        // Detect rising edge of RXNE (new byte received)
        // Ensure RD is asserted only when RXNE is detected high for the first time
        if (!prevRXNE && RXNE) begin
            RD <= 1'b1;                 // Assert Read Data strobe for one cycle
            latched_Rx_D <= Rx_D;       // Latch the received data from Rx module
            data_ready_to_tx <= 1'b1;   // Set flag indicating data is ready for TX
        end

        // --- Transmit Logic ---
        // Check if data is waiting to be sent AND the transmitter is ready (TXE is high)
        if (data_ready_to_tx && TXE) begin
            Tx_D <= latched_Rx_D;       // Load the latched data into the Tx data register
            WR <= 1'b1;                 // Assert Write strobe for one cycle to start transmission
            data_ready_to_tx <= 1'b0;   // Clear the flag, as data transfer is initiated
        end
    end

    // Display the latched received data on LEDs
    assign LED = latched_Rx_D;

endmodule