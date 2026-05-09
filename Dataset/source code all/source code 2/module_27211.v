`timescale 1ns / 1ps
`timescale 1ns / 1ps
module write_master (
  clk,
  reset,
  snk_command_data,
  snk_command_valid,
  snk_command_ready,
  src_response_data,
  src_response_valid,
  src_response_ready,
  snk_data,
  snk_valid,
  snk_ready,
  snk_sop,
  snk_eop,
  snk_empty,
  snk_error,
  master_address,
  master_write,
  master_byteenable,
  master_writedata,
  master_waitrequest,
  master_burstcount
);
  parameter UNALIGNED_ACCESSES_ENABLE = 0;        
  parameter ONLY_FULL_ACCESS_ENABLE = 0;          
  parameter STRIDE_ENABLE = 0;                    
  parameter STRIDE_WIDTH = 1;                     
  parameter PACKET_ENABLE = 0;
  parameter ERROR_ENABLE = 0;
  parameter ERROR_WIDTH = 8;                      
  parameter DATA_WIDTH = 32;
  parameter BYTE_ENABLE_WIDTH = 4;                
  parameter BYTE_ENABLE_WIDTH_LOG2 = 2;           
  parameter ADDRESS_WIDTH = 32;                   
  parameter LENGTH_WIDTH = 32;                    
  parameter ACTUAL_BYTES_TRANSFERRED_WIDTH = 32;  
  parameter FIFO_DEPTH = 32;
  parameter FIFO_DEPTH_LOG2 = 5;                  
  parameter FIFO_SPEED_OPTIMIZATION = 1;          
  parameter SYMBOL_WIDTH = 8;                     
  parameter NUMBER_OF_SYMBOLS = 4;                
  parameter NUMBER_OF_SYMBOLS_LOG2 = 2;           
  parameter BURST_ENABLE = 0;
  parameter MAX_BURST_COUNT = 2;                  
  parameter MAX_BURST_COUNT_WIDTH = 2;            
  parameter PROGRAMMABLE_BURST_ENABLE = 0;        
  parameter BURST_WRAPPING_SUPPORT = 1;           
  localparam FIFO_USE_MEMORY = 1;                 
  localparam BIG_ENDIAN_ACCESS = 0;               
  localparam LSB_MASK = {BYTE_ENABLE_WIDTH_LOG2{1'b1}};
  localparam FIFO_WIDTH = (DATA_WIDTH + 2 + NUMBER_OF_SYMBOLS_LOG2 + ERROR_WIDTH);  
  localparam ADDRESS_INCREMENT_WIDTH = (BYTE_ENABLE_WIDTH_LOG2 + MAX_BURST_COUNT_WIDTH + STRIDE_WIDTH);
  localparam FIXED_STRIDE = 1'b1;  
  input clk;
  input reset;
  input [255:0] snk_command_data;
  input snk_command_valid;
  output reg snk_command_ready;
  output wire [255:0] src_response_data;
  output reg src_response_valid;
  input src_response_ready;
  input [DATA_WIDTH-1:0] snk_data;
  input snk_valid;
  output wire snk_ready;
  input snk_sop;
  input snk_eop;
  input [NUMBER_OF_SYMBOLS_LOG2-1:0] snk_empty;
  input [ERROR_WIDTH-1:0] snk_error;
  input master_waitrequest;
  output wire [ADDRESS_WIDTH-1:0] master_address;
  output wire master_write;
  output wire [BYTE_ENABLE_WIDTH-1:0] master_byteenable;
  output wire [DATA_WIDTH-1:0] master_writedata;
  output wire [MAX_BURST_COUNT_WIDTH-1:0] master_burstcount;
  wire [63:0] descriptor_address;
  wire [31:0] descriptor_length;
  wire [15:0] descriptor_stride;
  wire descriptor_end_on_eop_enable;
  wire [7:0] descriptor_programmable_burst_count;
  reg [ADDRESS_WIDTH-1:0] address_counter;
  wire [ADDRESS_WIDTH-1:0] address;  
  wire write;  
  reg [LENGTH_WIDTH-1:0] length_counter;
  reg [STRIDE_WIDTH-1:0] stride_d1;
  wire [STRIDE_WIDTH-1:0] stride_amount;  
  reg descriptor_end_on_eop_enable_d1;
  reg [MAX_BURST_COUNT_WIDTH-1:0] programmable_burst_count_d1;
  wire [MAX_BURST_COUNT_WIDTH-1:0] maximum_burst_count;
  reg [BYTE_ENABLE_WIDTH_LOG2-1:0] start_byte_address;  
  reg first_access;  
  wire first_word_boundary_not_reached;   
  reg first_word_boundary_not_reached_d1;
  wire increment_address;  
  wire [ADDRESS_INCREMENT_WIDTH-1:0] address_increment;  
  wire [ADDRESS_INCREMENT_WIDTH-1:0] bytes_to_transfer;
  wire short_first_access_enable;           
  wire short_last_access_enable;            
  wire short_first_and_last_access_enable;  
  wire [ADDRESS_INCREMENT_WIDTH-1:0] short_first_access_size;
  wire [ADDRESS_INCREMENT_WIDTH-1:0] short_last_access_size;
  wire [ADDRESS_INCREMENT_WIDTH-1:0] short_first_and_last_access_size;
  reg [ADDRESS_INCREMENT_WIDTH-1:0] bytes_to_transfer_mux;  
  wire [FIFO_WIDTH-1:0] fifo_write_data;
  wire [FIFO_WIDTH-1:0] fifo_read_data;
  wire [FIFO_DEPTH_LOG2-1:0] fifo_used;
  wire fifo_write;
  wire fifo_read;
  wire fifo_empty;
  wire fifo_full;
  wire [DATA_WIDTH-1:0] fifo_read_data_rearranged;  
  wire go;
  wire done;
  reg done_d1;
  wire done_strobe;
  wire [DATA_WIDTH-1:0] buffered_data;
  wire [NUMBER_OF_SYMBOLS_LOG2-1:0] buffered_empty;
  wire buffered_eop;
  wire buffered_sop;  
  wire [ERROR_WIDTH-1:0] buffered_error;
  wire length_sync_reset;  
  reg [ACTUAL_BYTES_TRANSFERRED_WIDTH-1:0] actual_bytes_transferred_counter;  
  wire [31:0] response_actual_bytes_transferred;
  wire early_termination;
  reg early_termination_d1;
  wire eop_enable;
  reg [ERROR_WIDTH-1:0] error;    
  wire [7:0] response_error;      
  wire sw_stop_in;
  wire sw_reset_in;
  reg stopped;                    
  reg reset_taken;                
  wire reset_taken_from_write_burst_control;  
  wire stopped_from_write_burst_control;      
  wire stop_state;
  wire reset_delayed;
  wire write_complete;            
  wire write_stall_from_byte_enable_generator;  
  wire write_stall_from_write_burst_control;    
  wire [BYTE_ENABLE_WIDTH-1:0] byteenable_masks [0:BYTE_ENABLE_WIDTH-1];  
  wire [BYTE_ENABLE_WIDTH-1:0] unsupported_byteenable;  
  wire [BYTE_ENABLE_WIDTH-1:0] supported_byteenable;  
  wire extra_write;  
  wire st_to_mm_adapter_enable;
  wire [BYTE_ENABLE_WIDTH_LOG2:0] packet_beat_size;  
  wire [BYTE_ENABLE_WIDTH_LOG2:0] packet_bytes_buffered;
  reg [BYTE_ENABLE_WIDTH_LOG2:0] packet_bytes_buffered_d1;  
  reg eop_seen;  
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      stride_d1 <= 0;
    end
    else if (go == 1)
    begin
      stride_d1 <= descriptor_stride[STRIDE_WIDTH-1:0];
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      descriptor_end_on_eop_enable_d1 <= 1'b0;
    end
    else if (go == 1)
    begin
      descriptor_end_on_eop_enable_d1 <= descriptor_end_on_eop_enable;
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      programmable_burst_count_d1 <= 0;
    end
    else if (go == 1)
    begin
      programmable_burst_count_d1 <= ((descriptor_programmable_burst_count == 0) | (descriptor_programmable_burst_count > 128)) ? MAX_BURST_COUNT : descriptor_programmable_burst_count;
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      address_counter <= 0;
    end
    else
    begin
      if (go == 1)
      begin
        address_counter <= descriptor_address[ADDRESS_WIDTH-1:0];
      end
      else if (increment_address == 1)
      begin
        address_counter <= address_counter + address_increment;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      start_byte_address <= 0;
    end
    else if (go == 1)
    begin
      start_byte_address <= descriptor_address[BYTE_ENABLE_WIDTH_LOG2-1:0];
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      first_access <= 0;
    end
    else
    begin
      if (go == 1)
      begin
        first_access <= 1;
      end
      else if ((first_access == 1) & (increment_address == 1))
      begin
        first_access <= 0;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      first_word_boundary_not_reached_d1 <= 0;
    end
    else if (go == 1)
    begin
      first_word_boundary_not_reached_d1 <= first_word_boundary_not_reached;
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      length_counter <= 0;
    end
    else
    begin
      if (length_sync_reset == 1)  
      begin
        length_counter <= 0;  
      end
      else if (go == 1)
      begin
        length_counter <= descriptor_length[LENGTH_WIDTH-1:0];
      end
      else if (increment_address == 1)
      begin
        length_counter <= length_counter - bytes_to_transfer;  
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      actual_bytes_transferred_counter <= 0;
    end
    else
    begin
      if ((go == 1) | (reset_taken == 1))
      begin
        actual_bytes_transferred_counter <= 0;
      end
      else if(increment_address == 1)
      begin
        actual_bytes_transferred_counter <= actual_bytes_transferred_counter + bytes_to_transfer;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      done_d1 <= 1;     
    end
    else
    begin
      done_d1 <= done;
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      early_termination_d1 <= 0;
    end
    else
    begin
      early_termination_d1 <= early_termination;
    end
  end
  generate
  genvar l;
  for(l = 0; l < ERROR_WIDTH; l = l + 1)
  begin: error_SRFF
    always @ (posedge clk or posedge reset)
    begin
      if (reset)
      begin
        error[l] <= 0;
      end
      else
      begin
        if ((go == 1) | (reset_taken == 1))
        begin
          error[l] <= 0;
        end
        else if ((buffered_error[l] == 1) & (done == 0))
        begin
          error[l] <= 1;
        end
      end
    end
  end
  endgenerate
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      snk_command_ready <= 1;  
    end
    else
    begin
      if (go == 1)
      begin
        snk_command_ready <= 0;
      end
      else if (((done == 1) & (src_response_valid == 0)) | (reset_taken == 1))  
      begin
        snk_command_ready <= 1;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      src_response_valid <= 0;
    end
    else
    begin
      if (reset_taken == 1)
      begin
        src_response_valid <= 0;
      end
      else if (done_strobe == 1)
      begin
        src_response_valid <= 1;  
      end
      else if ((src_response_valid == 1) & (src_response_ready == 1))
      begin
        src_response_valid <= 0;  
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      stopped <= 0;
    end
    else
    begin
      if ((sw_stop_in == 0) | (reset_taken == 1))
      begin
        stopped <= 0;
      end
      else if ((sw_stop_in == 1) & (((write_complete == 1) & (stopped_from_write_burst_control == 1)) | ((snk_command_ready == 1) | (master_write == 0))))
      begin
        stopped <= 1;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      reset_taken <= 0;
    end
    else
    begin
      reset_taken <= (sw_reset_in == 1) & (((write_complete == 1) & (reset_taken_from_write_burst_control == 1)) | ((snk_command_ready == 1) | (master_write == 0)));
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      eop_seen <= 0;
    end
    else
    begin
      if (done == 1)
      begin
        eop_seen <= 0;
      end
      else if ((buffered_eop == 1) & (write_complete == 1))
      begin
        eop_seen <= 1;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      packet_bytes_buffered_d1 <= 0;
    end
    else
    begin
      if (go == 1)
      begin
        packet_bytes_buffered_d1 <= 0;
      end
      else if (write_complete == 1)
      begin
        packet_bytes_buffered_d1 <= packet_bytes_buffered; 
      end
    end
  end
  scfifo the_st_to_master_fifo (
    .aclr (reset),
    .sclr (reset_taken),
    .clock (clk),
    .data (fifo_write_data),
    .full (fifo_full),
    .empty (fifo_empty),
    .q (fifo_read_data),
    .rdreq (fifo_read),
    .usedw (fifo_used),
    .wrreq (fifo_write)
  );
  defparam the_st_to_master_fifo.lpm_width = FIFO_WIDTH;
  defparam the_st_to_master_fifo.lpm_widthu = FIFO_DEPTH_LOG2;
  defparam the_st_to_master_fifo.lpm_numwords = FIFO_DEPTH;
  defparam the_st_to_master_fifo.lpm_showahead = "ON";  
  defparam the_st_to_master_fifo.use_eab = (FIFO_USE_MEMORY == 1)? "ON" : "OFF";
  defparam the_st_to_master_fifo.add_ram_output_register = (FIFO_SPEED_OPTIMIZATION == 1)? "ON" : "OFF";
  defparam the_st_to_master_fifo.underflow_checking = "OFF";
  defparam the_st_to_master_fifo.overflow_checking = "OFF";
  ST_to_MM_Adapter the_ST_to_MM_Adapter (
    .clk (clk),
    .reset (reset),
    .enable (st_to_mm_adapter_enable),
    .address (descriptor_address[ADDRESS_WIDTH-1:0]),
    .start (go),
    .waitrequest (master_waitrequest),
    .stall (write_stall_from_byte_enable_generator | write_stall_from_write_burst_control),
    .write_data (master_writedata),
    .fifo_data (buffered_data),
    .fifo_empty (fifo_empty),
    .fifo_readack (fifo_read)
  );
  defparam the_ST_to_MM_Adapter.DATA_WIDTH = DATA_WIDTH;
  defparam the_ST_to_MM_Adapter.BYTEENABLE_WIDTH_LOG2 = BYTE_ENABLE_WIDTH_LOG2;
  defparam the_ST_to_MM_Adapter.ADDRESS_WIDTH = ADDRESS_WIDTH;
  defparam the_ST_to_MM_Adapter.UNALIGNED_ACCESS_ENABLE = UNALIGNED_ACCESSES_ENABLE;
  byte_enable_generator the_byte_enable_generator (
    .clk (clk),
    .reset (reset),
    .write_in (write),
    .byteenable_in (unsupported_byteenable),
    .waitrequest_out (write_stall_from_byte_enable_generator),
    .byteenable_out (supported_byteenable),
    .waitrequest_in (master_waitrequest | write_stall_from_write_burst_control)
  );
  defparam the_byte_enable_generator.BYTEENABLE_WIDTH = BYTE_ENABLE_WIDTH;
  write_burst_control the_write_burst_control (
    .clk (clk),
    .reset (reset),
    .sw_reset (sw_reset_in),
	  .sw_stop (sw_stop_in),
    .length (length_counter),
    .eop_enabled (descriptor_end_on_eop_enable_d1),
    .eop (snk_eop),
    .ready (snk_ready),
    .valid (snk_valid),
    .early_termination (early_termination),
    .address_in (address),
    .write_in (write),
    .max_burst_count (maximum_burst_count),
    .write_fifo_used ({fifo_full,fifo_used}),
    .waitrequest (master_waitrequest),
    .short_first_access_enable (short_first_access_enable),
    .short_last_access_enable (short_last_access_enable),
    .short_first_and_last_access_enable (short_first_and_last_access_enable),
    .address_out (master_address),
    .write_out (master_write),  
    .burst_count (master_burstcount),
    .stall (write_stall_from_write_burst_control),
    .reset_taken (reset_taken_from_write_burst_control),
	.stopped (stopped_from_write_burst_control)
  );
  defparam the_write_burst_control.BURST_ENABLE = BURST_ENABLE;
  defparam the_write_burst_control.BURST_COUNT_WIDTH = MAX_BURST_COUNT_WIDTH;
  defparam the_write_burst_control.WORD_SIZE = BYTE_ENABLE_WIDTH;
  defparam the_write_burst_control.WORD_SIZE_LOG2 = (DATA_WIDTH == 8)? 0 : BYTE_ENABLE_WIDTH_LOG2;  
  defparam the_write_burst_control.ADDRESS_WIDTH = ADDRESS_WIDTH;
  defparam the_write_burst_control.LENGTH_WIDTH = LENGTH_WIDTH;
  defparam the_write_burst_control.WRITE_FIFO_USED_WIDTH = FIFO_DEPTH_LOG2;
  defparam the_write_burst_control.BURST_WRAPPING_SUPPORT = BURST_WRAPPING_SUPPORT;
  assign descriptor_address = {snk_command_data[123:92], snk_command_data[31:0]};  
  assign descriptor_length = snk_command_data[63:32];
  assign descriptor_programmable_burst_count = snk_command_data[75:68];
  assign descriptor_stride = snk_command_data[91:76];
  assign descriptor_end_on_eop_enable = snk_command_data[64];
  assign sw_stop_in = snk_command_data[66];
  assign sw_reset_in = snk_command_data[67];
  assign stride_amount = (STRIDE_ENABLE == 1)? stride_d1[STRIDE_WIDTH-1:0] : FIXED_STRIDE;  
  assign maximum_burst_count = (PROGRAMMABLE_BURST_ENABLE == 1)? programmable_burst_count_d1 : MAX_BURST_COUNT;
  assign eop_enable = (PACKET_ENABLE == 1)? descriptor_end_on_eop_enable_d1 : 1'b0;  
  assign done_strobe = (done == 1) & (done_d1 == 0) & (reset_taken == 0);  
  assign response_error = (ERROR_ENABLE == 1)? error : 8'b00000000;
  assign response_actual_bytes_transferred = (PACKET_ENABLE == 1)? actual_bytes_transferred_counter : 32'h00000000;
  assign short_first_access_size = BYTE_ENABLE_WIDTH - start_byte_address;
  assign short_last_access_size = (eop_enable == 1)? (packet_beat_size + packet_bytes_buffered_d1) : (length_counter & LSB_MASK);
  assign short_first_and_last_access_size = (eop_enable == 1)? (BYTE_ENABLE_WIDTH - buffered_empty) : (length_counter & LSB_MASK);
  generate
    if (UNALIGNED_ACCESSES_ENABLE == 1)
    begin
      assign short_first_access_enable = (start_byte_address != 0) & (first_access == 1) & ((eop_enable == 1)? ((start_byte_address + BYTE_ENABLE_WIDTH - buffered_empty) >= BYTE_ENABLE_WIDTH) : (first_word_boundary_not_reached_d1 == 0));
      assign short_last_access_enable = (first_access == 0) & ((eop_enable == 1)? ((packet_beat_size + packet_bytes_buffered_d1) < BYTE_ENABLE_WIDTH): (length_counter < BYTE_ENABLE_WIDTH));
      assign short_first_and_last_access_enable = (first_access == 1) & ((eop_enable == 1)? ((start_byte_address + BYTE_ENABLE_WIDTH - buffered_empty) < BYTE_ENABLE_WIDTH) : (first_word_boundary_not_reached_d1 == 1));
      assign bytes_to_transfer = bytes_to_transfer_mux;
      assign address_increment = bytes_to_transfer_mux;  
    end
    else if (ONLY_FULL_ACCESS_ENABLE == 1)
    begin 
      assign short_first_access_enable = 0;
      assign short_last_access_enable = 0;
      assign short_first_and_last_access_enable = 0;
      assign bytes_to_transfer = BYTE_ENABLE_WIDTH;
      if (STRIDE_ENABLE == 1)
      begin
        assign address_increment = BYTE_ENABLE_WIDTH * stride_amount;  
      end
      else
      begin
        assign address_increment = BYTE_ENABLE_WIDTH;  
      end
    end
    else  
    begin 
      assign short_first_access_enable = 0;
      assign short_last_access_enable = (eop_enable == 1)? (buffered_eop == 1) : (length_counter < BYTE_ENABLE_WIDTH);    
      assign short_first_and_last_access_enable = 0;
      assign bytes_to_transfer = bytes_to_transfer_mux;
      if (STRIDE_ENABLE == 1)
      begin
        assign address_increment = BYTE_ENABLE_WIDTH * stride_amount;
      end
      else
      begin
        assign address_increment = BYTE_ENABLE_WIDTH;
      end
    end
  endgenerate
  always @ (short_first_access_enable or short_last_access_enable or short_first_and_last_access_enable or short_first_access_size or short_last_access_size or short_first_and_last_access_size)
  begin
    case ({short_first_and_last_access_enable, short_last_access_enable, short_first_access_enable})
      3'b001: bytes_to_transfer_mux = short_first_access_size;            
      3'b010: bytes_to_transfer_mux = short_last_access_size;             
      3'b100: bytes_to_transfer_mux = short_first_and_last_access_size;   
      default: bytes_to_transfer_mux = BYTE_ENABLE_WIDTH;                 
    endcase
  end
  generate
    genvar i;
    for(i = 0; i < DATA_WIDTH; i = i + SYMBOL_WIDTH)  
    begin: symbol_swap
      assign fifo_write_data[i +SYMBOL_WIDTH -1: i] = snk_data[DATA_WIDTH -i -1: DATA_WIDTH -i - SYMBOL_WIDTH];
    end
  endgenerate
  assign fifo_write_data[FIFO_WIDTH-1:DATA_WIDTH] = {snk_error, (snk_eop == 1)? snk_empty:{NUMBER_OF_SYMBOLS_LOG2{1'b0}}, snk_sop, snk_eop};
  generate
  if(BIG_ENDIAN_ACCESS == 1)
  begin
    genvar j;
    for(j=0; j < DATA_WIDTH; j = j + 8)
    begin: byte_swap
      assign fifo_read_data_rearranged[j +8 -1: j] = fifo_read_data[DATA_WIDTH -j -1: DATA_WIDTH -j - 8];
      assign master_byteenable[j/8] = supported_byteenable[(DATA_WIDTH -j -1)/8];
    end
  end
  else
  begin
    assign fifo_read_data_rearranged = fifo_read_data[DATA_WIDTH-1:0];  
    assign master_byteenable = supported_byteenable;    
  end
  endgenerate
  assign buffered_data = fifo_read_data_rearranged;
  assign buffered_error = fifo_read_data[DATA_WIDTH +2 +NUMBER_OF_SYMBOLS_LOG2 + ERROR_WIDTH -1: DATA_WIDTH +2 +NUMBER_OF_SYMBOLS_LOG2];
  generate
  if (PACKET_ENABLE == 1)
  begin
    assign buffered_eop = fifo_read_data[DATA_WIDTH];
    assign buffered_sop = fifo_read_data[DATA_WIDTH +1];
    if (ONLY_FULL_ACCESS_ENABLE == 1)
    begin
      assign buffered_empty = 0;  
    end
    else
    begin
      assign buffered_empty = fifo_read_data[DATA_WIDTH +2 +NUMBER_OF_SYMBOLS_LOG2 -1: DATA_WIDTH +2];  
    end
  end
  else
  begin
    assign buffered_empty = 0;
    assign buffered_eop = 0;
    assign buffered_sop = 0;
  end
  endgenerate
  generate if (BYTE_ENABLE_WIDTH > 1)
  begin
    genvar k;
    for (k = 0; k < BYTE_ENABLE_WIDTH; k = k + 1)
    begin: byte_enable_loop
      assign byteenable_masks[k] = { {(BYTE_ENABLE_WIDTH-k-1){1'b0}}, {(k+1){1'b1}} };  
    end
  end
  else
  begin
    assign byteenable_masks[0] = 1'b1;  
  end
  endgenerate
  generate if (ONLY_FULL_ACCESS_ENABLE == 1)
  begin
    assign unsupported_byteenable = {BYTE_ENABLE_WIDTH{1'b1}};  
  end
  else if (UNALIGNED_ACCESSES_ENABLE == 0)
  begin
    assign unsupported_byteenable = byteenable_masks[bytes_to_transfer_mux - 1];  
  end
  else  
  begin
    assign unsupported_byteenable = byteenable_masks[bytes_to_transfer_mux - 1] << (address_counter & LSB_MASK);  
  end
  endgenerate
  generate if (BYTE_ENABLE_WIDTH > 1)
  begin
    assign address = address_counter & { {(ADDRESS_WIDTH-BYTE_ENABLE_WIDTH_LOG2){1'b1}}, {BYTE_ENABLE_WIDTH_LOG2{1'b0}} };  
  end
  else
  begin
    assign address = address_counter;  
  end
  endgenerate
  assign done = (length_counter == 0) | ((PACKET_ENABLE == 1) & (eop_enable == 1) & (eop_seen == 1) & (extra_write == 0));
  assign packet_beat_size = (eop_seen == 1) ? 0 : (BYTE_ENABLE_WIDTH - buffered_empty);  
  assign packet_bytes_buffered = packet_beat_size + packet_bytes_buffered_d1 - bytes_to_transfer;
  assign extra_write = (UNALIGNED_ACCESSES_ENABLE == 1) & (((PACKET_ENABLE == 1) & (eop_enable == 1))? 
                       ((eop_seen == 1) & (packet_bytes_buffered_d1 != 0)) : 
                       ((first_access == 0) & (start_byte_address != 0) & (short_last_access_enable == 1) & (start_byte_address >= length_counter[BYTE_ENABLE_WIDTH_LOG2-1:0])));  
  assign first_word_boundary_not_reached = (descriptor_length < BYTE_ENABLE_WIDTH) &  
                                           (((descriptor_length & LSB_MASK) + (descriptor_address & LSB_MASK)) < BYTE_ENABLE_WIDTH);  
  assign write = ((fifo_empty == 0) | (extra_write == 1)) & (done == 0) & (stopped == 0);
  assign st_to_mm_adapter_enable = (done == 0) & (extra_write == 0);
  assign write_complete = (write == 1) & (master_waitrequest == 0) & (write_stall_from_byte_enable_generator == 0) & (write_stall_from_write_burst_control == 0);  
  assign increment_address = ((write == 1) & (write_complete == 1)) & (stopped == 0);
  assign go = (snk_command_valid == 1) & (snk_command_ready == 1);  
  assign snk_ready = (fifo_full == 0) & 
                     (((PACKET_ENABLE == 1) & (snk_sop == 1) & (fifo_empty == 0)) != 1);  
  assign length_sync_reset = (((reset_taken == 1) | (early_termination_d1 == 1)) & (done == 0)) | (done_strobe == 1); 
  assign fifo_write = (snk_ready == 1) & (snk_valid == 1);
  assign early_termination = (eop_enable == 1) & (write_complete == 1) & (length_counter < bytes_to_transfer);  
  assign stop_state = stopped;
  assign reset_delayed = (reset_taken == 0) & (sw_reset_in == 1);
  assign src_response_data = {{212{1'b0}}, done_strobe, early_termination_d1, response_error, stop_state, reset_delayed, response_actual_bytes_transferred};
endmodule
