`timescale 1ns / 1ps
module serial #(
    parameter TRUE = 1'b1,
    parameter FALSE = 1'b0,
    parameter CLOCK_PER_BAUD_RATE = 5208,
    parameter SERIAL_STATE_LAST = 8,
    parameter SERIAL_STATE_SENT = 9,
    parameter SERIAL_STATE_WAIT = 10
)(
    input reset,
    input test_i,
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

   reg [15:0] clock_counter;
   reg internal_baudclock = FALSE;
   wire dft_clock;
   assign dft_clock = test_i ? CLOCK_50M : internal_baudclock;

   always @(posedge CLOCK_50M) begin
      if (reset) begin
         clock_counter <= 0;
         internal_baudclock <= FALSE;
      end
      else if (clock_counter < CLOCK_PER_BAUD_RATE) begin
         internal_baudclock <= FALSE;
         clock_counter <= clock_counter + 1;
      end
      else begin
         internal_baudclock <= TRUE;
         clock_counter <= 0;
      end
   end

   reg [7:0] tx_buffer = "A";
   reg [3:0] tx_counter = SERIAL_STATE_WAIT;
   reg tx_state = TRUE;
   assign TX = tx_state;
   assign LED1 = tx_state;
   assign LED2 = TRUE;

   always @(posedge dft_clock) begin
      if (reset) begin
         tx_counter <= SERIAL_STATE_WAIT;
         tx_state <= TRUE;
         send_buffer <= 64'h0;
         send_buffer_count <= 3'h0;
         tx_buffer <= "A";
      end
      else begin
         if (tx_counter == SERIAL_STATE_WAIT) begin
            tx_state <= FALSE;
            tx_counter <= 0;
         end
         else if (tx_counter == SERIAL_STATE_LAST) begin
            tx_state <= TRUE;
            tx_counter <= SERIAL_STATE_SENT;
         end
         else if (tx_counter == SERIAL_STATE_SENT && send_buffer_count_in > 0) begin
            tx_buffer <= send_buffer_in[7:0];
            send_buffer <= send_buffer_in >> 8;
            send_buffer_count <= send_buffer_count_in - 1;
         end
         else begin
            tx_state <= tx_buffer[tx_counter];
            tx_counter <= tx_counter + 1;
         end
      end
   end
endmodule