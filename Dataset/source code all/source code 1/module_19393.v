`timescale 1ns / 1ps
`timescale 1ns / 1ps
module read_master (
  clk,
  reset,
  snk_command_data,
  snk_command_valid,
  snk_command_ready,
  src_response_data,
  src_response_valid,
  src_response_ready,
  src_data,
  src_valid,
  src_ready,
  src_sop,
  src_eop,
  src_empty,
  src_error,
  src_channel,
  master_address,
  master_read,
  master_byteenable,
  master_readdata,
  master_waitrequest,
  master_readdatavalid,
  master_burstcount
);
  parameter UNALIGNED_ACCESSES_ENABLE = 0;        
  parameter ONLY_FULL_ACCESS_ENABLE = 0;          
  parameter STRIDE_ENABLE = 0;                    
  parameter STRIDE_WIDTH = 1;                     
  parameter PACKET_ENABLE = 0;
  parameter ERROR_ENABLE = 0;
  parameter ERROR_WIDTH = 8;                      
  parameter CHANNEL_ENABLE = 0;
  parameter CHANNEL_WIDTH = 8;                    
  parameter DATA_WIDTH = 32;
  parameter BYTE_ENABLE_WIDTH = 4;                
  parameter BYTE_ENABLE_WIDTH_LOG2 = 2;           
  parameter ADDRESS_WIDTH = 32;                   
  parameter LENGTH_WIDTH = 32;                    
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
  localparam FIFO_WIDTH = DATA_WIDTH + NUMBER_OF_SYMBOLS_LOG2 + 2 + ERROR_WIDTH + CHANNEL_WIDTH;
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
  output wire [DATA_WIDTH-1:0] src_data;
  output wire src_valid;
  input src_ready;
  output wire src_sop;
  output wire src_eop;
  output wire [NUMBER_OF_SYMBOLS_LOG2-1:0] src_empty;
  output wire [ERROR_WIDTH-1:0] src_error;
  output wire [CHANNEL_WIDTH-1:0] src_channel;
  input master_waitrequest;
  output wire [ADDRESS_WIDTH-1:0] master_address;
  output wire master_read;
  output wire [BYTE_ENABLE_WIDTH-1:0] master_byteenable;
  input [DATA_WIDTH-1:0] master_readdata;
  input master_readdatavalid;
  output wire [MAX_BURST_COUNT_WIDTH-1:0] master_burstcount;
  wire [63:0] descriptor_address;
  wire [31:0] descriptor_length;
  wire [15:0] descriptor_stride;
  wire [7:0] descriptor_channel;
  wire descriptor_generate_sop;
  wire descriptor_generate_eop;
  wire [7:0] descriptor_error;
  wire [7:0] descriptor_programmable_burst_count;
  wire descriptor_early_done_enable;
  wire sw_stop_in;
  wire sw_reset_in;
  reg early_done_enable_d1;
  reg [ERROR_WIDTH-1:0] error_d1;
  reg [MAX_BURST_COUNT_WIDTH-1:0] programmable_burst_count_d1;
  wire [MAX_BURST_COUNT_WIDTH-1:0] maximum_burst_count;
  reg generate_sop_d1;
  reg generate_eop_d1;
  reg [ADDRESS_WIDTH-1:0] address_counter;
  reg [LENGTH_WIDTH-1:0] length_counter;
  reg [CHANNEL_WIDTH-1:0] channel_d1;
  reg [STRIDE_WIDTH-1:0] stride_d1;
  wire [STRIDE_WIDTH-1:0] stride_amount;  
  reg [BYTE_ENABLE_WIDTH_LOG2-1:0] start_byte_address;  
  reg first_access;  
  wire first_word_boundary_not_reached;  
  reg first_word_boundary_not_reached_d1;
  reg [FIFO_DEPTH_LOG2:0] pending_reads_counter;
  reg [FIFO_DEPTH_LOG2:0] pending_reads_mux;
  wire [FIFO_WIDTH-1:0] fifo_write_data;
  wire [FIFO_WIDTH-1:0] fifo_read_data;
  wire fifo_write;
  wire fifo_read;
  wire fifo_empty;
  wire fifo_full;
  wire [FIFO_DEPTH_LOG2-1:0] fifo_used;
  wire too_many_pending_reads;
  wire read_complete;  
  wire address_increment_enable;
  wire [ADDRESS_INCREMENT_WIDTH-1:0] address_increment;  
  wire [ADDRESS_INCREMENT_WIDTH-1:0] bytes_to_transfer;
  wire short_first_access_enable;           
  wire short_last_access_enable;            
  wire short_first_and_last_access_enable;  
  wire [ADDRESS_INCREMENT_WIDTH-1:0] short_first_access_size;
  wire [ADDRESS_INCREMENT_WIDTH-1:0] short_last_access_size;
  wire [ADDRESS_INCREMENT_WIDTH-1:0] short_first_and_last_access_size;
  reg [ADDRESS_INCREMENT_WIDTH-1:0] bytes_to_transfer_mux;
  wire go;
  wire done;  
  reg done_d1;
  wire done_strobe;
  wire all_reads_returned;  
  reg all_reads_returned_d1;
  wire all_reads_returned_strobe;
  reg all_reads_returned_strobe_d1;
  reg all_reads_returned_strobe_d2;  
  wire [DATA_WIDTH-1:0] MM_to_ST_adapter_dataout;
  wire [DATA_WIDTH-1:0] MM_to_ST_adapter_dataout_rearranged;
  wire MM_to_ST_adapter_sop;
  wire MM_to_ST_adapter_eop;
  wire [NUMBER_OF_SYMBOLS_LOG2-1:0] MM_to_ST_adapter_empty;
  wire masked_sop;
  wire masked_eop;
  reg flush;
  reg stopped;
  wire length_sync_reset;
  wire set_src_response_valid;
  reg master_read_reg;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      error_d1 <= 0;
      generate_sop_d1 <= 0;
      generate_eop_d1 <= 0;
      channel_d1 <= 0;
      stride_d1 <= 0;
      programmable_burst_count_d1 <= 0;
      early_done_enable_d1 <= 0;
    end
    else if (go == 1)
    begin
      error_d1 <= descriptor_error[ERROR_WIDTH-1:0];
      generate_sop_d1 <= descriptor_generate_sop;
      generate_eop_d1 <= descriptor_generate_eop;
      channel_d1 <= descriptor_channel[CHANNEL_WIDTH-1:0];
      stride_d1 <= descriptor_stride[STRIDE_WIDTH-1:0];
      programmable_burst_count_d1 <= (descriptor_programmable_burst_count == 0)? MAX_BURST_COUNT : descriptor_programmable_burst_count;
      early_done_enable_d1 <= ((UNALIGNED_ACCESSES_ENABLE == 1) | (PACKET_ENABLE == 1))? 0 : descriptor_early_done_enable;  
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
      else if (address_increment_enable == 1)
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
    if (reset == 1)
    begin
      first_access <= 0;
    end
    else
    begin
      if (go == 1)
      begin
        first_access <= 1;
      end
      else if ((first_access == 1) & (address_increment_enable == 1))
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
      else if (address_increment_enable == 1)
      begin
        length_counter <= length_counter - bytes_to_transfer;  
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      pending_reads_counter <= 0;
    end
    else
    begin
      pending_reads_counter <= pending_reads_mux;
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
      all_reads_returned_d1 <= 1;
    end
    else
    begin
      all_reads_returned_d1 <= all_reads_returned;
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      flush <= 0;
    end
    else
    begin
      if ((pending_reads_counter == 0) & (flush == 1))
      begin
        flush <= 0;
      end
      else if ((sw_reset_in == 1) & ((read_complete == 1) | (snk_command_ready == 1) | (master_read_reg == 0)))
      begin
        flush <= 1;  
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
      if ((sw_stop_in == 0) | (sw_reset_in == 1))
      begin
        stopped <= 0;
      end
      else if ((sw_stop_in == 1) & ((read_complete == 1) | (snk_command_ready == 1) | (master_read_reg == 0)))
      begin
        stopped <= 1;
      end
    end
  end
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
      else if ((src_response_ready == 1) & (src_response_valid == 1))  
      begin
        snk_command_ready <= 1;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      all_reads_returned_strobe_d1 <= 0;
      all_reads_returned_strobe_d2 <= 0;
    end
    else
    begin
      all_reads_returned_strobe_d1 <= all_reads_returned_strobe;
      all_reads_returned_strobe_d2 <= all_reads_returned_strobe_d1;
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
      if (flush == 1)
      begin
        src_response_valid <= 0;
      end
      else if (set_src_response_valid == 1)  
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
      master_read_reg <= 0;
    end
    else
    begin
      if ((done == 0) & (too_many_pending_reads == 0) & (sw_stop_in == 0) & (sw_reset_in == 0))
      begin
        master_read_reg <= 1;
      end
      else if ((done == 1) | ((read_complete == 1) & ((too_many_pending_reads == 1) | (sw_stop_in == 1))))
      begin
        master_read_reg <= 0;
      end 
    end
  end
  MM_to_ST_Adapter the_MM_to_ST_adapter (
    .clk (clk),
    .reset (reset),
    .length (descriptor_length[LENGTH_WIDTH-1:0]),
    .length_counter (length_counter),
    .address (descriptor_address[ADDRESS_WIDTH-1:0]),
    .reads_pending (pending_reads_counter),
    .start (go),
    .readdata (master_readdata),
    .readdatavalid (master_readdatavalid),
    .fifo_data (MM_to_ST_adapter_dataout),
    .fifo_write (fifo_write),
    .fifo_empty (MM_to_ST_adapter_empty),
    .fifo_sop (MM_to_ST_adapter_sop),
    .fifo_eop (MM_to_ST_adapter_eop)
  );
  defparam the_MM_to_ST_adapter.DATA_WIDTH = DATA_WIDTH;
  defparam the_MM_to_ST_adapter.LENGTH_WIDTH = LENGTH_WIDTH;
  defparam the_MM_to_ST_adapter.ADDRESS_WIDTH = ADDRESS_WIDTH;
  defparam the_MM_to_ST_adapter.BYTE_ADDRESS_WIDTH = BYTE_ENABLE_WIDTH_LOG2;
  defparam the_MM_to_ST_adapter.READS_PENDING_WIDTH = FIFO_DEPTH_LOG2 + 1;
  defparam the_MM_to_ST_adapter.EMPTY_WIDTH = NUMBER_OF_SYMBOLS_LOG2;
  defparam the_MM_to_ST_adapter.PACKET_SUPPORT = PACKET_ENABLE;
  defparam the_MM_to_ST_adapter.UNALIGNED_ACCESS_ENABLE = UNALIGNED_ACCESSES_ENABLE;
  defparam the_MM_to_ST_adapter.FULL_WORD_ACCESS_ONLY = ONLY_FULL_ACCESS_ENABLE;
  scfifo the_master_to_st_fifo (
    .aclr (reset),
    .clock (clk),
    .data (fifo_write_data),
    .full (fifo_full),
    .empty (fifo_empty),
    .usedw (fifo_used),
    .q (fifo_read_data),
    .rdreq (fifo_read),
    .wrreq (fifo_write)
  );
  defparam the_master_to_st_fifo.lpm_width = FIFO_WIDTH;
  defparam the_master_to_st_fifo.lpm_numwords = FIFO_DEPTH;
  defparam the_master_to_st_fifo.lpm_widthu = FIFO_DEPTH_LOG2;
  defparam the_master_to_st_fifo.lpm_showahead = "ON";  
  defparam the_master_to_st_fifo.use_eab = (FIFO_USE_MEMORY == 1)? "ON" : "OFF";
  defparam the_master_to_st_fifo.add_ram_output_register = (FIFO_SPEED_OPTIMIZATION == 1)? "ON" : "OFF";
  defparam the_master_to_st_fifo.underflow_checking = "OFF";
  defparam the_master_to_st_fifo.overflow_checking = "OFF";
  read_burst_control the_read_burst_control (
    .address (master_address),
    .length (length_counter),
    .maximum_burst_count (maximum_burst_count),
    .short_first_access_enable (short_first_access_enable),
    .short_last_access_enable (short_last_access_enable),
    .short_first_and_last_access_enable (short_first_and_last_access_enable),
    .burst_count (master_burstcount)
  );
  defparam the_read_burst_control.BURST_ENABLE = BURST_ENABLE;
  defparam the_read_burst_control.BURST_COUNT_WIDTH = MAX_BURST_COUNT_WIDTH;
  defparam the_read_burst_control.WORD_SIZE_LOG2 = (DATA_WIDTH == 8)? 0 : BYTE_ENABLE_WIDTH_LOG2;  
  defparam the_read_burst_control.ADDRESS_WIDTH = ADDRESS_WIDTH;
  defparam the_read_burst_control.LENGTH_WIDTH = LENGTH_WIDTH;
  defparam the_read_burst_control.BURST_WRAPPING_SUPPORT = BURST_WRAPPING_SUPPORT;
  assign descriptor_address = {snk_command_data[140:109], snk_command_data[31:0]};  
  assign descriptor_length = snk_command_data[63:32];
  assign descriptor_channel = snk_command_data[71:64];
  assign descriptor_generate_sop = snk_command_data[72];
  assign descriptor_generate_eop = snk_command_data[73];
  assign descriptor_programmable_burst_count = snk_command_data[83:76];
  assign descriptor_stride = snk_command_data[99:84];
  assign descriptor_error = snk_command_data[107:100];
  assign descriptor_early_done_enable = snk_command_data[108];
  assign sw_stop_in = snk_command_data[74];
  assign sw_reset_in = snk_command_data[75];
  assign stride_amount = (STRIDE_ENABLE == 1)? stride_d1[STRIDE_WIDTH-1:0] : FIXED_STRIDE;  
  assign maximum_burst_count = (PROGRAMMABLE_BURST_ENABLE == 1)? programmable_burst_count_d1 : MAX_BURST_COUNT;
  generate
    if (BIG_ENDIAN_ACCESS == 1)
    begin
      genvar j;
      for(j=0; j < DATA_WIDTH; j = j + 8)
      begin: byte_swap
        assign MM_to_ST_adapter_dataout_rearranged[j +8 -1: j] = MM_to_ST_adapter_dataout[DATA_WIDTH -j -1: DATA_WIDTH -j - 8];
      end
    end
    else
    begin
      assign MM_to_ST_adapter_dataout_rearranged = MM_to_ST_adapter_dataout;
    end
  endgenerate
  assign masked_sop = MM_to_ST_adapter_sop & generate_sop_d1;
  assign masked_eop = MM_to_ST_adapter_eop & generate_eop_d1;
  assign fifo_write_data = {error_d1, channel_d1, masked_sop, masked_eop, ((masked_eop == 1)? MM_to_ST_adapter_empty : {NUMBER_OF_SYMBOLS_LOG2{1'b0}} ), MM_to_ST_adapter_dataout_rearranged};
  generate
    genvar i;
    for(i = 0; i < DATA_WIDTH; i = i + SYMBOL_WIDTH)  
    begin: symbol_swap
      assign src_data[i +SYMBOL_WIDTH -1: i] = fifo_read_data[DATA_WIDTH -i -1: DATA_WIDTH -i - SYMBOL_WIDTH];
    end
  endgenerate
  assign src_empty = (PACKET_ENABLE == 1)? fifo_read_data[(DATA_WIDTH + NUMBER_OF_SYMBOLS_LOG2 - 1) : DATA_WIDTH] : 0;
  assign src_eop = (PACKET_ENABLE == 1)? fifo_read_data[DATA_WIDTH + NUMBER_OF_SYMBOLS_LOG2] : 0;
  assign src_sop = (PACKET_ENABLE == 1)? fifo_read_data[DATA_WIDTH + NUMBER_OF_SYMBOLS_LOG2 + 1] : 0;
  assign src_channel = (CHANNEL_ENABLE == 1)? fifo_read_data[(DATA_WIDTH + NUMBER_OF_SYMBOLS_LOG2 + ERROR_WIDTH + 1): (DATA_WIDTH + NUMBER_OF_SYMBOLS_LOG2 + 2)] : 0;
  assign src_error = (ERROR_ENABLE == 1)? fifo_read_data[(FIFO_WIDTH-1):(DATA_WIDTH + NUMBER_OF_SYMBOLS_LOG2 + ERROR_WIDTH + 2)] : 0;
  assign short_first_access_size = BYTE_ENABLE_WIDTH - (address_counter & LSB_MASK);
  assign short_last_access_size = length_counter & LSB_MASK;
  assign short_first_and_last_access_size = length_counter & LSB_MASK;
  generate
    if (UNALIGNED_ACCESSES_ENABLE == 1)
    begin
      assign short_first_access_enable = ((address_counter & LSB_MASK) != 0) & (first_access == 1) & (first_word_boundary_not_reached_d1 == 0);
      assign short_last_access_enable = (first_access == 0) & (length_counter < BYTE_ENABLE_WIDTH);
      assign short_first_and_last_access_enable = (first_access == 1) & (first_word_boundary_not_reached_d1 == 1);
      assign bytes_to_transfer = bytes_to_transfer_mux;
      assign address_increment = bytes_to_transfer_mux;  
    end
    else if (ONLY_FULL_ACCESS_ENABLE == 1)
    begin
      assign short_first_access_enable = 0;
      assign short_last_access_enable = 0;
      assign short_first_and_last_access_enable = 0;
      assign bytes_to_transfer = BYTE_ENABLE_WIDTH * master_burstcount;
      if (STRIDE_ENABLE == 1)
      begin
        assign address_increment = BYTE_ENABLE_WIDTH * stride_amount * master_burstcount;  
      end
      else
      begin
        assign address_increment = BYTE_ENABLE_WIDTH * master_burstcount;  
      end
    end
    else  
    begin
      assign short_first_access_enable = 0;
      assign short_last_access_enable = length_counter < BYTE_ENABLE_WIDTH;    
      assign short_first_and_last_access_enable = 0;
      assign bytes_to_transfer = bytes_to_transfer_mux;
      if (STRIDE_ENABLE == 1)
      begin
        assign address_increment = BYTE_ENABLE_WIDTH * stride_amount * master_burstcount;  
      end
      else
      begin
        assign address_increment = BYTE_ENABLE_WIDTH * master_burstcount;  
      end      
    end
  endgenerate
  always @ (short_first_access_enable or short_last_access_enable or short_first_and_last_access_enable or short_first_access_size or short_last_access_size or short_first_and_last_access_size or master_burstcount)
  begin
    case ({short_first_and_last_access_enable, short_last_access_enable, short_first_access_enable})
      3'b001: bytes_to_transfer_mux = short_first_access_size;
      3'b010: bytes_to_transfer_mux = short_last_access_size;
      3'b100: bytes_to_transfer_mux = short_first_and_last_access_size;
      default: bytes_to_transfer_mux = BYTE_ENABLE_WIDTH * master_burstcount;  
    endcase
  end
  always @ (master_readdatavalid or read_complete or pending_reads_counter or master_burstcount)
  begin
    case ({master_readdatavalid, read_complete})
      2'b00: pending_reads_mux = pending_reads_counter;                               
      2'b01: pending_reads_mux = (pending_reads_counter + master_burstcount);         
      2'b10: pending_reads_mux = (pending_reads_counter - 1'b1);                      
      2'b11: pending_reads_mux = (pending_reads_counter + master_burstcount - 1'b1);  
    endcase
  end
  assign src_valid = (fifo_empty == 0);
  assign first_word_boundary_not_reached = (descriptor_length < BYTE_ENABLE_WIDTH) & 
                    (((descriptor_length & LSB_MASK) + (descriptor_address & LSB_MASK)) < BYTE_ENABLE_WIDTH);  
  assign go = (snk_command_valid == 1) & (snk_command_ready == 1);  
  assign done = (length_counter == 0);  
  assign done_strobe = (done == 1) & (done_d1 == 0);
  assign fifo_read = (src_valid == 1) & (src_ready == 1);
  assign length_sync_reset = (flush == 1) & (pending_reads_counter == 0);  
  assign too_many_pending_reads = (({fifo_full,fifo_used} + pending_reads_counter) > (FIFO_DEPTH - (maximum_burst_count << 1)));  
  assign read_complete = (master_read == 1) & (master_waitrequest == 0);
  assign address_increment_enable = read_complete;
  assign master_byteenable = {BYTE_ENABLE_WIDTH{1'b1}};  
  generate if (DATA_WIDTH > 8)
  begin
    assign master_address = address_counter & { {(ADDRESS_WIDTH-BYTE_ENABLE_WIDTH_LOG2){1'b1}}, {BYTE_ENABLE_WIDTH_LOG2{1'b0}} };  
  end
  else
  begin
    assign master_address = address_counter;  
  end
  endgenerate
  assign master_read = master_read_reg & (done == 0);  
  assign all_reads_returned = (done == 1) & (pending_reads_counter == 0);
  assign all_reads_returned_strobe = (all_reads_returned == 1) & (all_reads_returned_d1 == 0);
  generate
  if (UNALIGNED_ACCESSES_ENABLE == 1)  
  begin
    assign src_response_data = {{252{1'b0}}, all_reads_returned_strobe_d2, done_strobe, stopped, flush};  
  end
  else
  begin
    assign src_response_data = {{252{1'b0}}, all_reads_returned_strobe, done_strobe, stopped, flush};  
  end
  endgenerate
  assign set_src_response_valid = (UNALIGNED_ACCESSES_ENABLE == 1)? all_reads_returned_strobe_d2 : 
                                  (early_done_enable_d1 == 1)? done_strobe : all_reads_returned_strobe; 
endmodule
