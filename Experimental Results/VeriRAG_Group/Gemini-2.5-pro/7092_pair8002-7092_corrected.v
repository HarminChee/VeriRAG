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
    input CLOCK_50M,
    input test_i, 
    output TX,
    input [63:0] send_buffer_in,
    input [2:0] send_buffer_count_in,
    output [2:0] send_buffer_count_out,
    output LED1,
    output LED2
);
reg [63:0] send_buffer;
reg [2:0] send_buffer_count;
//assign send_buffer_out = send_buffer; // Removed as send_buffer is internal state, not directly output
assign send_buffer_count_out = send_buffer_count;
reg CLOCK = FALSE;
reg [15:0] clock_counter;
wire dft_clock; 

assign dft_clock = test_i ? CLOCK_50M : CLOCK;

always @(posedge CLOCK_50M) begin
    // No explicit reset, assuming reset handled externally or implicitly
    if (clock_counter < CLOCK_PER_BAUD_RATE) begin
        CLOCK <= FALSE;
        clock_counter <= clock_counter + 1;
    end
    else begin
        CLOCK <= TRUE;
        clock_counter <= 0;
    end
end
reg [7:0] tx_buffer = "A";
reg [3:0] tx_counter = SERIAL_STATE_WAIT; 
reg tx_state = TRUE;
assign TX = tx_state;
assign LED1 = tx_state;
assign LED2 = TRUE; // Assuming LED2 indicates power or module active state

always @(posedge dft_clock) begin
    // No explicit reset, assuming reset handled externally or implicitly
    if (tx_counter == SERIAL_STATE_WAIT) begin
        tx_state <= FALSE; // Start bit
        tx_counter <= 0;
        // Check if there's data to send immediately
        if (send_buffer_count_in > 0) begin
            tx_buffer <= send_buffer_in[7:0];
            send_buffer <= send_buffer_in >> 8;
            send_buffer_count <= send_buffer_count_in - 1;
        end else begin
             // If no data initially, maybe load default or wait state?
             // Keep tx_buffer as is or load idle pattern if needed.
             // send_buffer and send_buffer_count remain unchanged until new data arrives.
        end
    end
    else if (tx_counter == SERIAL_STATE_LAST) begin
        tx_state <= TRUE; // Stop bit
        tx_counter <= SERIAL_STATE_SENT; // Move to check for next byte
    end
    else if (tx_counter == SERIAL_STATE_SENT) begin // After stop bit is sent
        if (send_buffer_count > 0) begin // Check internal count
            // Load next byte from internal buffer if available
            tx_buffer <= send_buffer[7:0];
            send_buffer <= send_buffer >> 8;
            send_buffer_count <= send_buffer_count - 1;
            tx_counter <= SERIAL_STATE_WAIT; // Prepare for next start bit
        end else if (send_buffer_count_in > 0) begin // Check input count if internal buffer empty
             tx_buffer <= send_buffer_in[7:0];
             send_buffer <= send_buffer_in >> 8;
             send_buffer_count <= send_buffer_count_in - 1;
             tx_counter <= SERIAL_STATE_WAIT; // Prepare for next start bit
        end
        else begin
            // No more data, stay idle (or could transition to a specific idle state)
            // tx_state remains TRUE (idle line)
             tx_counter <= SERIAL_STATE_SENT; // Remain in sent state until new data arrives
        end
    end
    else begin // Sending data bits (0 to 7)
        tx_state <= tx_buffer[tx_counter];
        tx_counter <= tx_counter + 1;
    end
end

// Assign send_buffer_out directly from the input buffer if needed for monitoring,
// or remove if it's purely internal state representation.
// If send_buffer_out is intended to show the *remaining* buffer content, it should be assigned from reg send_buffer.
// Let's assume it reflects the internal state:
assign send_buffer_out = send_buffer;

endmodule