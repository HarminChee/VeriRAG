`timescale 1ns / 1ps

module serial #(
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
    output [2:0] send_buffer_count_out,
    output LED1,
    output LED2
);

reg [63:0] send_buffer;
reg [2:0] send_buffer_count;
reg CLOCK = FALSE;
reg [15:0] clock_counter;
reg [7:0] tx_buffer;
reg [3:0] tx_counter;
reg tx_state;

assign send_buffer_count_out = send_buffer_count;
assign TX = tx_state;
assign LED1 = tx_state;
assign LED2 = TRUE;

always @(posedge CLOCK_50M) begin
    if (clock_counter < CLOCK_PER_BAUD_RATE - 1) begin
        CLOCK <= FALSE;
        clock_counter <= clock_counter + 1;
    end else begin
        CLOCK <= TRUE;
        clock_counter <= 0;
    end
end

always @(posedge CLOCK) begin
    if (tx_counter == SERIAL_STATE_WAIT) begin
        tx_state <= FALSE;
        tx_counter <= 0;
    end else if (tx_counter == SERIAL_STATE_LAST) begin
        tx_state <= TRUE;
        tx_counter <= SERIAL_STATE_SENT;
    end else if (tx_counter == SERIAL_STATE_SENT && send_buffer_count_in > 0) begin
        tx_buffer <= send_buffer_in[7:0];
        send_buffer <= send_buffer_in >> 8;
        send_buffer_count <= send_buffer_count_in - 1;
        tx_state <= 1'b0; // Start bit
        tx_counter <= 0;
    end else if (tx_counter < 8) begin
        tx_state <= tx_buffer[tx_counter];
        tx_counter <= tx_counter + 1;
    end else if (tx_counter == 8) begin
        tx_state <= 1'b1; // Stop bit
        tx_counter <= SERIAL_STATE_LAST;
    end
end

initial begin
    tx_buffer = 8'h41; // Initialize with 'A'
    tx_counter = SERIAL_STATE_WAIT;
    send_buffer = 64'h0;
    send_buffer_count = 3'b0;
end

endmodule