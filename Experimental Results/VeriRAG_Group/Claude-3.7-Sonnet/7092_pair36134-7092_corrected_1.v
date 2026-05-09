`timescale 1ns / 1ps
module serial # (
    parameter TRUE = 1'b1,
    parameter FALSE = 1'b0,
    parameter CLOCK_PER_BAUD_RATE = 5208,
    parameter SERIAL_STATE_LAST = 8,
    parameter SERIAL_STATE_SENT = 9,
    parameter SERIAL_STATE_WAIT = 10
)(
    input wire CLOCK_50M,
    output reg TX,
    input [63:0] send_buffer_in,
    input [2:0] send_buffer_count_in,
    output [2:0] send_buffer_count_out,
    output reg LED1,
    output reg LED2
);

reg [63:0] send_buffer;
reg [2:0] send_buffer_count;
assign send_buffer_count_out = send_buffer_count;

reg CLOCK;
reg [15:0] clock_counter;

always @(posedge CLOCK_50M) begin
    if (CLOCK_50M == 1'b0) begin
        CLOCK <= FALSE;
        clock_counter <= 16'h0;
    end
    else if (clock_counter < CLOCK_PER_BAUD_RATE) begin
        CLOCK <= FALSE;
        clock_counter <= clock_counter + 16'h1;
    end
    else begin
        CLOCK <= TRUE;
        clock_counter <= 16'h0;
    end
end

reg [7:0] tx_buffer;
reg [3:0] tx_counter;

always @(posedge CLOCK_50M) begin
    if (CLOCK_50M == 1'b0) begin
        TX <= TRUE;
        LED1 <= TRUE;
        LED2 <= TRUE;
        tx_counter <= SERIAL_STATE_WAIT;
        tx_buffer <= 8'h41;
        send_buffer <= 64'h0;
        send_buffer_count <= 3'h0;
    end
    else if (CLOCK) begin
        if (tx_counter == SERIAL_STATE_WAIT) begin
            TX <= FALSE;
            LED1 <= FALSE;
            tx_counter <= 4'h0;
        end
        else if (tx_counter == SERIAL_STATE_LAST) begin
            TX <= TRUE;
            LED1 <= TRUE;
            tx_counter <= SERIAL_STATE_SENT;
        end
        else if ((tx_counter == SERIAL_STATE_SENT) && (send_buffer_count_in > 3'h0)) begin
            tx_buffer <= send_buffer_in[7:0];
            send_buffer <= {8'h0, send_buffer_in[63:8]};
            send_buffer_count <= send_buffer_count_in - 3'h1;
            tx_counter <= SERIAL_STATE_WAIT;
        end
        else begin
            TX <= tx_buffer[tx_counter[2:0]];
            LED1 <= tx_buffer[tx_counter[2:0]];
            tx_counter <= tx_counter + 4'h1;
        end
    end
end

endmodule