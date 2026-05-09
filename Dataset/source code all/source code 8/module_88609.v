`timescale 1ns / 1ps
`timescale 1ns / 1ps
module descriptor_buffers (
  clk,
  reset,
  writedata,
  write,
  byteenable,
  waitrequest,
  read_command_valid,
  read_command_ready,
  read_command_data,
  read_command_empty,
  read_command_full,
  read_command_used,
  write_command_valid,
  write_command_ready,
  write_command_data,
  write_command_empty,
  write_command_full,
  write_command_used,
  stop_issuing_commands,
  stop,
  sw_reset,
  sequence_number,
  transfer_complete_IRQ_mask,
  early_termination_IRQ_mask,
  error_IRQ_mask
);
  parameter MODE = 0;
  parameter DATA_WIDTH = 256;
  parameter BYTE_ENABLE_WIDTH = 32;
  parameter FIFO_DEPTH = 128;
  parameter FIFO_DEPTH_LOG2 = 7;  
  input clk;
  input reset;
  input [DATA_WIDTH-1:0] writedata;
  input write;
  input [BYTE_ENABLE_WIDTH-1:0] byteenable;
  output wire waitrequest;
  output wire read_command_valid;
  input read_command_ready;
  output wire [255:0] read_command_data;
  output wire read_command_empty;
  output wire read_command_full;
  output wire [FIFO_DEPTH_LOG2:0] read_command_used;
  output wire write_command_valid;
  input write_command_ready;
  output wire [255:0] write_command_data;
  output wire write_command_empty;
  output wire write_command_full;
  output wire [FIFO_DEPTH_LOG2:0] write_command_used;
  input stop_issuing_commands;
  input stop;
  input sw_reset;
  output wire [31:0] sequence_number;
  output wire transfer_complete_IRQ_mask;
  output wire early_termination_IRQ_mask;
  output wire [7:0] error_IRQ_mask;
  reg write_command_empty_d1;
  reg write_command_empty_d2;
  reg read_command_empty_d1;
  reg read_command_empty_d2;
  wire push_write_fifo;
  wire pop_write_fifo;
  wire push_read_fifo;
  wire pop_read_fifo;
  wire go_bit;
  wire read_park;
  wire read_park_enable;  
  wire write_park;
  wire write_park_enable;  
  wire [DATA_WIDTH-1:0] write_fifo_output;
  wire [DATA_WIDTH-1:0] read_fifo_output;
  wire [15:0] write_sequence_number;
  reg [15:0] write_sequence_number_d1;
  wire [15:0] read_sequence_number;
  reg [15:0] read_sequence_number_d1;
  wire read_transfer_complete_IRQ_mask;
  reg read_transfer_complete_IRQ_mask_d1;
  wire write_transfer_complete_IRQ_mask;
  reg write_transfer_complete_IRQ_mask_d1;
  wire write_early_termination_IRQ_mask;
  reg write_early_termination_IRQ_mask_d1;
  wire [7:0] write_error_IRQ_mask;
  reg [7:0] write_error_IRQ_mask_d1;
  wire issue_write_descriptor;  
  wire issue_read_descriptor;   
  wire [31:0] read_address;
  wire [31:0] read_length;
  wire [7:0] read_transmit_channel;
  wire read_generate_sop;
  wire read_generate_eop;
  wire [7:0] read_burst_count;
  wire [15:0] read_stride;
  wire [7:0] read_transmit_error;
  wire read_early_done_enable;
  wire [31:0] write_address;
  wire [31:0] write_length;
  wire write_end_on_eop;
  wire [7:0] write_burst_count;
  wire [15:0] write_stride;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      write_sequence_number_d1 <= 0;
      write_transfer_complete_IRQ_mask_d1 <= 0;
      write_early_termination_IRQ_mask_d1 <= 0;
      write_error_IRQ_mask_d1 <= 0;
    end
    else if (issue_write_descriptor)  
    begin
      write_sequence_number_d1 <= write_sequence_number;
      write_transfer_complete_IRQ_mask_d1 <= write_transfer_complete_IRQ_mask;
      write_early_termination_IRQ_mask_d1 <= write_early_termination_IRQ_mask;
      write_error_IRQ_mask_d1 <= write_error_IRQ_mask;
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      read_sequence_number_d1 <= 0;
      read_transfer_complete_IRQ_mask_d1 <= 0;
    end
    else if (issue_read_descriptor)  
    begin
      read_sequence_number_d1 <= read_sequence_number;
      read_transfer_complete_IRQ_mask_d1 <= read_transfer_complete_IRQ_mask;
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      write_command_empty_d1 <= 0;
      write_command_empty_d2 <= 0;
      read_command_empty_d1 <= 0;
      read_command_empty_d2 <= 0;
    end
    else
    begin
      write_command_empty_d1 <= write_command_empty;
      write_command_empty_d2 <= write_command_empty_d1;
      read_command_empty_d1 <= read_command_empty;
      read_command_empty_d2 <= read_command_empty_d1;
    end
  end
  write_signal_breakout the_write_signal_breakout (
    .write_command_data_in (write_fifo_output),
    .write_command_data_out (write_command_data),
    .write_address (write_address),
    .write_length (write_length),
    .write_park (write_park),
    .write_end_on_eop (write_end_on_eop),
    .write_transfer_complete_IRQ_mask (write_transfer_complete_IRQ_mask),
    .write_early_termination_IRQ_mask (write_early_termination_IRQ_mask),
    .write_error_IRQ_mask (write_error_IRQ_mask),
    .write_burst_count (write_burst_count),
    .write_stride (write_stride),
    .write_sequence_number (write_sequence_number),
    .write_stop (stop),
    .write_sw_reset (sw_reset)
  );
  defparam the_write_signal_breakout.DATA_WIDTH = DATA_WIDTH;
  read_signal_breakout the_read_signal_breakout (
    .read_command_data_in (read_fifo_output),
    .read_command_data_out (read_command_data),
    .read_address (read_address),
    .read_length (read_length),
    .read_transmit_channel (read_transmit_channel),
    .read_generate_sop (read_generate_sop),
    .read_generate_eop (read_generate_eop),
    .read_park (read_park),
    .read_transfer_complete_IRQ_mask (read_transfer_complete_IRQ_mask),
    .read_burst_count (read_burst_count),
    .read_stride (read_stride),
    .read_sequence_number (read_sequence_number),
    .read_transmit_error (read_transmit_error),
    .read_early_done_enable (read_early_done_enable),
    .read_stop (stop),
    .read_sw_reset (sw_reset)
  );
  defparam the_read_signal_breakout.DATA_WIDTH = DATA_WIDTH;
  fifo_with_byteenables the_read_command_FIFO (
    .clk (clk),
    .areset (reset),
    .sreset (sw_reset),
    .write_data (writedata),
    .write_byteenables (byteenable),
    .write (write),
    .push (push_read_fifo),
    .read_data (read_fifo_output),
    .pop (pop_read_fifo),
    .used (read_command_used),  
    .full (read_command_full),
    .empty (read_command_empty)
  );
  defparam the_read_command_FIFO.DATA_WIDTH = DATA_WIDTH;  
  defparam the_read_command_FIFO.FIFO_DEPTH = FIFO_DEPTH;
  defparam the_read_command_FIFO.FIFO_DEPTH_LOG2 = FIFO_DEPTH_LOG2;
  defparam the_read_command_FIFO.LATENCY = 2;
  fifo_with_byteenables the_write_command_FIFO (
    .clk (clk),
    .areset (reset),
    .sreset (sw_reset),
    .write_data (writedata),
    .write_byteenables (byteenable),
    .write (write),
    .push (push_write_fifo),
    .read_data (write_fifo_output),
    .pop (pop_write_fifo),
    .used (write_command_used),  
    .full (write_command_full),
    .empty (write_command_empty)
  );
  defparam the_write_command_FIFO.DATA_WIDTH = DATA_WIDTH;  
  defparam the_write_command_FIFO.FIFO_DEPTH = FIFO_DEPTH;
  defparam the_write_command_FIFO.FIFO_DEPTH_LOG2 = FIFO_DEPTH_LOG2;
  defparam the_write_command_FIFO.LATENCY = 2; 
  generate  
    if (MODE == 0)  
    begin
      assign waitrequest = (read_command_full == 1) | (write_command_full == 1);
      assign sequence_number = {write_sequence_number_d1, read_sequence_number_d1};
      assign transfer_complete_IRQ_mask = write_transfer_complete_IRQ_mask_d1;
      assign early_termination_IRQ_mask = 1'b0;
      assign error_IRQ_mask = 8'h00; 
      assign push_read_fifo = go_bit;
      assign read_park_enable = (read_park == 1) & (read_command_used == 1);  
      assign read_command_valid = (stop == 0) & (sw_reset == 0) & (stop_issuing_commands == 0) &
                                  (read_command_empty == 0) & (read_command_empty_d1 == 0) & (read_command_empty_d2 == 0);  
      assign issue_read_descriptor = (read_command_valid == 1) & (read_command_ready == 1);
      assign pop_read_fifo = (issue_read_descriptor == 1) & (read_park_enable == 0);  
      assign push_write_fifo = go_bit;
      assign write_park_enable = (write_park == 1) & (write_command_used == 1);  
      assign write_command_valid = (stop == 0) & (sw_reset == 0) & (stop_issuing_commands == 0) &
                                   (write_command_empty == 0) & (write_command_empty_d1 == 0) & (write_command_empty_d2 == 0);  
      assign issue_write_descriptor = (write_command_valid == 1) & (write_command_ready == 1);
      assign pop_write_fifo = (issue_write_descriptor == 1) & (write_park_enable == 0);  
    end
    else if (MODE == 1)  
    begin
      assign sequence_number = {16'h0000, read_sequence_number_d1};
      assign transfer_complete_IRQ_mask = read_transfer_complete_IRQ_mask_d1;
      assign early_termination_IRQ_mask = 1'b0;
      assign error_IRQ_mask = 8'h00;
      assign waitrequest = (read_command_full == 1);
      assign push_read_fifo = go_bit;
      assign read_park_enable = (read_park == 1) & (read_command_used == 1);  
      assign read_command_valid = (stop == 0) & (sw_reset == 0) & (stop_issuing_commands == 0) &
                                  (read_command_empty == 0) & (read_command_empty_d1 == 0) & (read_command_empty_d2 == 0);  
      assign issue_read_descriptor = (read_command_valid == 1) & (read_command_ready == 1);
      assign pop_read_fifo = (issue_read_descriptor == 1) & (read_park_enable == 0);  
      assign push_write_fifo = 0;
      assign write_park_enable = 0;
      assign write_command_valid = 0;
      assign issue_write_descriptor = 0;
      assign pop_write_fifo = 0;
    end
    else  
    begin
      assign sequence_number = {write_sequence_number_d1, 16'h0000};
      assign transfer_complete_IRQ_mask = write_transfer_complete_IRQ_mask_d1;
      assign early_termination_IRQ_mask = write_early_termination_IRQ_mask_d1; 
      assign error_IRQ_mask = write_error_IRQ_mask_d1;
      assign waitrequest = (write_command_full == 1);
      assign push_read_fifo = 0;
      assign read_park_enable = 0;
      assign read_command_valid = 0;
      assign issue_read_descriptor = 0;
      assign pop_read_fifo = 0;
      assign push_write_fifo = go_bit;
      assign write_park_enable = (write_park == 1) & (write_command_used == 1);  
      assign write_command_valid = (stop == 0) & (sw_reset == 0) & (stop_issuing_commands == 0) &
                                   (write_command_empty == 0) & (write_command_empty_d1 == 0) & (write_command_empty_d2 == 0);  
      assign issue_write_descriptor = (write_command_valid == 1) & (write_command_ready == 1);
      assign pop_write_fifo = (issue_write_descriptor == 1) & (write_park_enable == 0);  
    end
  endgenerate
  generate  
    if (DATA_WIDTH == 256)
    begin
      assign go_bit = (writedata[255] == 1) & (write == 1) & (byteenable[31] == 1) & (waitrequest == 0);
    end
    else
    begin
      assign go_bit = (writedata[127] == 1) & (write == 1) & (byteenable[15] == 1) & (waitrequest == 0);
    end
  endgenerate
endmodule
