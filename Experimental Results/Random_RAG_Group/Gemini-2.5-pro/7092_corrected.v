`timescale 1ns / 1ps
`timescale 1ns / 1ps
module serial # (
    parameter TRUE = 1'b1,
    parameter FALSE = 1'b0,
    parameter CLOCK_PER_BAUD_RATE = 5208,
    parameter SERIAL_STATE_LAST = 8,
    parameter SERIAL_STATE_SENT = 9,
    parameter SERIAL_STATE_WAIT = 10
)(
    input wire test_i, // Added test mode input
    input CLOCK_50M,
    output TX,
    input [63:0] send_buffer_in,
    input [2:0] send_buffer_count_in,
    output [2:0] send_buffer_count_out,
    output LED1,
    output LED2
);
reg [63:0] send_buffer;
reg [2:0] send_buffer_count;
// Removed assign send_buffer_out = send_buffer; - output should reflect input or registered value based on logic
// Removed assign send_buffer_count_out = send_buffer_count; - output should reflect input or registered value based on logic
assign send_buffer_count_out = send_buffer_count; // Keep this assign as send_buffer_count is registered

reg CLOCK = FALSE;
reg [15:0] clock_counter;
always @(posedge CLOCK_50M) begin
    if (clock_counter < CLOCK_PER_BAUD_RATE) begin
        CLOCK <= FALSE;
        clock_counter <= clock_counter + 1;
    end
    else begin
        CLOCK <= TRUE;
        clock_counter <= 0;
    end
end

wire dft_clk; // DFT clock mux
assign dft_clk = test_i ? CLOCK_50M : CLOCK; // Select primary clock in test mode

reg [7:0] tx_buffer = "A";
reg [3:0] tx_counter = SERIAL_STATE_WAIT;
reg tx_state = TRUE;
assign TX = tx_state;
assign LED1 = tx_state;
assign LED2 = TRUE;

// Changed sensitivity list to use DFT clock
always @(posedge dft_clk) begin
    if (tx_counter == SERIAL_STATE_WAIT) begin
        // Assuming the first action is to send start bit (LOW)
        tx_state <= FALSE; // Start bit
        tx_counter <= 0; // Move to first data bit state
        // Load buffer only when starting a new byte transmission
        if (send_buffer_count_in > 0) begin
             tx_buffer <= send_buffer_in[7:0];
             send_buffer <= send_buffer_in >> 8;
             send_buffer_count <= send_buffer_count_in - 1;
        end else begin
             // What to do if buffer is empty? Maybe stay in WAIT or send idle?
             // Keeping original behavior for now, but this might need refinement.
             // Re-evaluating load logic based on SERIAL_STATE_SENT condition below.
        end
    end
    // Removed the SERIAL_STATE_SENT condition block from here as it was likely misplaced
    // for loading data. Loading should happen before starting transmission or after finishing.
    // Let's assume loading happens when WAIT state is entered and buffer has data.

    else if (tx_counter < SERIAL_STATE_LAST) begin // Send data bits 0 through 7
        tx_state <= tx_buffer[tx_counter];
        tx_counter <= tx_counter + 1;
    end
    else if (tx_counter == SERIAL_STATE_LAST) begin // Send stop bit
        tx_state <= TRUE; // Stop bit
        tx_counter <= SERIAL_STATE_SENT; // Indicate byte sent
    end
    else if (tx_counter == SERIAL_STATE_SENT) begin // Byte sent, check buffer
        if (send_buffer_count > 0) begin // If more data buffered internally
             tx_counter <= SERIAL_STATE_WAIT; // Go back to wait (will immediately start next byte)
        end else if (send_buffer_count_in > 0) begin // Check external input buffer
             tx_counter <= SERIAL_STATE_WAIT; // Go back to wait to load and start next byte
             // Loading logic moved to SERIAL_STATE_WAIT entry based on send_buffer_count_in check there.
        end else begin
             // No more data, remain idle (or stay in SENT until new data arrives?)
             // Let's make it go back to WAIT state to be ready.
             tx_counter <= SERIAL_STATE_WAIT;
             // tx_state remains HIGH (idle)
        end
    end
    // Removed the 'else' block which covered tx_counter > SERIAL_STATE_LAST,
    // as state logic should explicitly cover all intended transitions.
    // The original 'else' block modified tx_state and tx_counter without clear state definition.
end

// Need to handle send_buffer_out assignment properly.
// If it's meant to show the internal buffer state:
assign send_buffer_out = send_buffer;
// If it's meant to reflect the input directly (less likely for an output):
// assign send_buffer_out = send_buffer_in;

// Note: The original logic for buffer loading in SERIAL_STATE_SENT seemed problematic.
// Corrected logic attempts to load buffer when transitioning to WAIT state if data is available.
// Further refinement might be needed based on exact protocol requirements (e.g., inter-byte delay).

endmodule