`timescale 1ns / 1ps
`timescale 1ns / 1ps
module MM_to_ST_Adapter (
  clk,
  reset,
  length,
  length_counter,
  address,
  reads_pending,
  start,
  readdata,
  readdatavalid,
  fifo_data,
  fifo_write,
  fifo_empty,
  fifo_sop,
  fifo_eop
);
  parameter DATA_WIDTH = 32;                   
  parameter LENGTH_WIDTH = 32;
  parameter ADDRESS_WIDTH = 32;
  parameter BYTE_ADDRESS_WIDTH = 2;            
  parameter READS_PENDING_WIDTH = 5;
  parameter EMPTY_WIDTH = 2;                   
  parameter PACKET_SUPPORT = 1;                
  parameter UNALIGNED_ACCESS_ENABLE = 1;       
  parameter FULL_WORD_ACCESS_ONLY = 0;         
  input clk;
  input reset;
  input [LENGTH_WIDTH-1:0] length;
  input [LENGTH_WIDTH-1:0] length_counter;
  input [ADDRESS_WIDTH-1:0] address;
  input [READS_PENDING_WIDTH-1:0] reads_pending;
  input start;   
  input [DATA_WIDTH-1:0] readdata;
  input readdatavalid;
  output wire [DATA_WIDTH-1:0] fifo_data;
  output wire fifo_write;
  output wire [EMPTY_WIDTH-1:0] fifo_empty;
  output wire fifo_sop;
  output wire fifo_eop;
  reg [DATA_WIDTH-1:0] readdata_d1;
  reg readdatavalid_d1;
  wire [DATA_WIDTH-1:0] data_in;            
  wire valid_in;                            
  reg valid_in_d1;
  wire [DATA_WIDTH-1:0] barrelshifter_A;    
  wire [DATA_WIDTH-1:0] barrelshifter_B;
  reg [DATA_WIDTH-1:0] barrelshifter_B_d1;  
  wire [DATA_WIDTH-1:0] combined_word;  
  wire [DATA_WIDTH-1:0] barrelshifter_input_A [0:((DATA_WIDTH/8)-1)];  
  wire [DATA_WIDTH-1:0] barrelshifter_input_B [0:((DATA_WIDTH/8)-1)];  
  wire extra_access_enable;
  reg extra_access;
  wire last_unaligned_fifo_write;
  reg first_access_seen;
  reg second_access_seen;
  wire first_access_seen_rising_edge;
  wire second_access_seen_rising_edge;
  reg [BYTE_ADDRESS_WIDTH-1:0] byte_address;
  reg [EMPTY_WIDTH-1:0] last_empty;  
  reg start_and_end_same_cycle;  
  generate
    if (UNALIGNED_ACCESS_ENABLE == 1)  
    begin
      assign data_in = readdata_d1;
      assign valid_in = readdatavalid_d1;
    end
    else
    begin
      assign data_in = readdata;       
      assign valid_in = readdatavalid;
    end
  endgenerate
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      readdata_d1 <= 0;
    end
    else
    begin
      if (readdatavalid == 1)
      begin
        readdata_d1 <= readdata;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      readdatavalid_d1 <= 0;
      valid_in_d1 <= 0;
    end
    else
    begin
      readdatavalid_d1 <= readdatavalid;
      valid_in_d1 <= valid_in;  
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      barrelshifter_B_d1 <= 0;
    end
    else
    begin
      if (valid_in == 1)
      begin
        barrelshifter_B_d1 <= barrelshifter_B;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      first_access_seen <= 0;
    end
    else
    begin
      if (start == 1)
      begin
        first_access_seen <= 0;
      end
      else if (valid_in == 1)
      begin
        first_access_seen <= 1;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      second_access_seen <= 0;
    end
    else
    begin
      if (start == 1)
      begin
        second_access_seen <= 0;
      end
      else if ((first_access_seen == 1) & (valid_in == 1))
      begin
        second_access_seen <= 1;
      end
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      byte_address <= 0;
    end
    else if (start == 1)
    begin
      byte_address <= address[BYTE_ADDRESS_WIDTH-1:0];
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      last_empty <= 0;
    end
    else if (start == 1)
    begin
      last_empty <= ((DATA_WIDTH/8) - length[EMPTY_WIDTH-1:0]) & {EMPTY_WIDTH{1'b1}};  
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      extra_access <= 0;
    end
    else if (start == 1)
    begin
      extra_access <= extra_access_enable;  
    end
  end
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      start_and_end_same_cycle <= 0;
    end
    else if (start == 1)
    begin
      start_and_end_same_cycle <= (length <= (DATA_WIDTH/8));
    end
  end
  generate
    genvar input_offset;
    for(input_offset = 0; input_offset < (DATA_WIDTH/8); input_offset = input_offset + 1)
    begin:  barrel_shifter_inputs
      assign barrelshifter_input_A[input_offset] = data_in << (8 * ((DATA_WIDTH/8) - input_offset)); 
      assign barrelshifter_input_B[input_offset] = data_in >> (8 * input_offset);
    end
  endgenerate
  assign barrelshifter_A = barrelshifter_input_A[byte_address];   
  assign barrelshifter_B = barrelshifter_input_B[byte_address];   
  assign combined_word = (barrelshifter_A | barrelshifter_B_d1);  
  assign first_access_seen_rising_edge = (valid_in == 1) & (first_access_seen == 0);
  assign second_access_seen_rising_edge = ((first_access_seen == 1) & (valid_in == 1)) & (second_access_seen == 0);
  assign extra_access_enable = (((DATA_WIDTH/8) - length[EMPTY_WIDTH-1:0]) & {EMPTY_WIDTH{1'b1}}) >= address[BYTE_ADDRESS_WIDTH-1:0];  
  assign last_unaligned_fifo_write = (reads_pending == 0) & (length_counter == 0) &
                                     (  ((extra_access == 0) & (valid_in == 1)) |                         
                                        ((extra_access == 1) & (valid_in_d1 == 1) & (valid_in == 0))  );  
  generate
  if (PACKET_SUPPORT == 1)
  begin
    if (UNALIGNED_ACCESS_ENABLE == 1)
    begin
      assign fifo_sop = (second_access_seen_rising_edge == 1) | ((start_and_end_same_cycle == 1) & (last_unaligned_fifo_write == 1));
      assign fifo_eop = last_unaligned_fifo_write;
      assign fifo_empty = (fifo_eop == 1)? last_empty : 0;  
    end
    else
    begin
      assign fifo_sop = first_access_seen_rising_edge;
      assign fifo_eop = (length_counter == 0) & (reads_pending == 1) & (valid_in == 1);  
      if (FULL_WORD_ACCESS_ONLY == 1)
      begin
        assign fifo_empty = 0;  
      end
      else
      begin
        assign fifo_empty = (fifo_eop == 1)? last_empty : 0;  
      end
    end
  end
  else
  begin
    assign fifo_eop = 0;
    assign fifo_sop = 0;
    assign fifo_empty = 0;
  end
  if (UNALIGNED_ACCESS_ENABLE == 1)
  begin
    assign fifo_data = combined_word;
    assign fifo_write = (first_access_seen == 1) & ((valid_in == 1) | (last_unaligned_fifo_write == 1));  
  end
  else
  begin  
    assign fifo_data = data_in;   
    assign fifo_write = valid_in; 
  end
  endgenerate
endmodule
