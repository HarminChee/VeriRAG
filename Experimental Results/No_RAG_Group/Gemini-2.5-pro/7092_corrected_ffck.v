`timescale 1ns / 1ps
module serial_corrected_ffc # (
    parameter TRUE = 1'b1,
    parameter FALSE = 1'b0,
    parameter CLOCK_PER_BAUD_RATE = 5208,
    parameter SERIAL_STATE_LAST = 8,
    parameter SERIAL_STATE_SENT = 9,
    parameter SERIAL_STATE_WAIT = 10
)(
    input CLOCK_50M,
    output TX,
    input [63:0] send_buffer_in,
    input [2:0] send_buffer_count_in,
    output reg [2:0] send_buffer_count_out, // Made reg for direct assignment
    output LED1,
    output LED2
);

reg [63:0] send_buffer;
reg [2:0] send_buffer_count;

// Assign outputs directly where possible or use registers clocked by primary clock
assign send_buffer_count_out = send_buffer_count;

reg [15:0] clock_counter;
reg clock_enable; // Signal to enable logic at the slower rate

// Counter to generate the enable signal
always @(posedge CLOCK_50M) begin
    if (clock_counter < CLOCK_PER_BAUD_RATE) begin
        clock_counter <= clock_counter + 1;
        clock_enable <= FALSE;
    end
    else begin
        clock_counter <= 0;
        clock_enable <= TRUE; // Generate enable pulse
    end
end

reg [7:0] tx_buffer = "A";
reg [3:0] tx_counter = SERIAL_STATE_WAIT;
reg tx_state = TRUE;

assign TX = tx_state;
assign LED1 = tx_state;
assign LED2 = TRUE; // Assuming LED2 indicates power or activity

// Main state machine logic, clocked by the primary clock and enabled by clock_enable
always @(posedge CLOCK_50M) begin
    if (clock_enable) begin // Only update state on the enable pulse
        if (tx_counter == SERIAL_STATE_WAIT) begin
            tx_state <= FALSE; // Start bit
            tx_counter <= 0;
        end
        else if (tx_counter == SERIAL_STATE_LAST) begin
            tx_state <= TRUE; // Stop bit
            tx_counter <= SERIAL_STATE_SENT;
        end
        else if (tx_counter == SERIAL_STATE_SENT) begin
             // Check if there is data to send *before* updating buffer/count
             // Use the input directly here as it reflects the state *before* this clock edge
             // Or, register the inputs if timing requires it, but ensure they are clocked by CLOCK_50M
            if (send_buffer_count_in > 0) begin
                tx_buffer <= send_buffer_in[7:0];
                send_buffer <= send_buffer_in >> 8; // Use input buffer directly
                send_buffer_count <= send_buffer_count_in - 1; // Use input count directly
                tx_counter <= SERIAL_STATE_WAIT; // Ready to send the loaded byte
            end else begin
                // No data to send, remain in SENT state or move to WAIT?
                // Assuming we wait for new data, stay in SENT or move to another idle state
                 tx_counter <= SERIAL_STATE_SENT; // Or potentially SERIAL_STATE_WAIT if preferred
            end
        end
        else begin // Sending data bits
            tx_state <= tx_buffer[tx_counter]; // Send current bit
            tx_counter <= tx_counter + 1;
        end
    end
    // If inputs need registering (e.g., due to timing or if they change asynchronously)
    // Add registers clocked by CLOCK_50M for send_buffer_in and send_buffer_count_in
    // For this correction, assume inputs are stable around the posedge CLOCK_50M when clock_enable is high.
    // If send_buffer and send_buffer_count are meant to hold the state *after* loading,
    // their assignments inside the 'if (clock_enable)' are correct.
    // The output assignment `assign send_buffer_out = send_buffer;` was removed as send_buffer_out is not an output port in the corrected code.
    // send_buffer_count_out is now assigned directly from the register send_buffer_count.
end

// Initialize registers if necessary (e.g., using initial block or reset logic)
// Adding a simple initialization for simulation purposes, assuming no reset signal
initial begin
    send_buffer = 0;
    send_buffer_count = 0;
    clock_counter = 0;
    clock_enable = 0;
    tx_buffer = "A"; // Default initial value
    tx_counter = SERIAL_STATE_WAIT;
    tx_state = TRUE; // Idle high
end

endmodule