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
    output TX,
    input [63:0] send_buffer_in,
    input [2:0] send_buffer_count_in,
    output [2:0] send_buffer_count_out,
    output LED1,
    output LED2
);
reg [63:0] send_buffer;
reg [2:0] send_buffer_count;
assign send_buffer_count_out = send_buffer_count;
reg clock = FALSE;
reg [15:0] clock_counter = 0;
always @(posedge CLOCK_50M) begin
    if (clock_counter < CLOCK_PER_BAUD_RATE - 1) begin
        clock <= FALSE;
        clock_counter <= clock_counter + 1;
    end
    else begin
        clock <= TRUE;
        clock_counter <= 0;
    end
end
reg [7:0] tx_buffer = "A";
reg [3:0] tx_counter = SERIAL_STATE_WAIT; 
reg tx_state = TRUE;
assign TX = tx_state;
assign LED1 = tx_state;
assign LED2 = TRUE;
always @(posedge clock) begin
    if (tx_counter == SERIAL_STATE_WAIT) begin
        if (send_buffer_count_in > 0) begin
            tx_buffer <= send_buffer_in[7:0];
            send_buffer <= send_buffer_in >> 8;
            send_buffer_count <= send_buffer_count_in - 1;
            tx_state <= FALSE;
            tx_counter <= 0;
        end
    end
    else if (tx_counter == SERIAL_STATE_LAST) begin
        tx_state <= TRUE;
        tx_counter <= SERIAL_STATE_SENT;
    end
    else if (tx_counter == SERIAL_STATE_SENT) begin
        tx_counter <= SERIAL_STATE_WAIT;
    end
    else begin
        tx_state <= tx_buffer[tx_counter];
        tx_counter <= tx_counter + 1;
    end
end
endmodule