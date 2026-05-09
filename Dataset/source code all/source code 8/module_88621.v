`timescale 1ns / 1ps
module one_thousand_twenty_four_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [127:0] byteenable_in;
  output wire waitrequest_out;
  output wire [127:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[63:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[63:0] == 64'hFFFFFFFFFFFFFFFF);
  assign partial_upper_half_transfer = (byteenable_in[127:64] != 0);
  assign full_upper_half_transfer = (byteenable_in[127:64] == 64'hFFFFFFFFFFFFFFFF);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  five_hundred_twelve_bit_byteenable_FSM lower_five_hundred_twelve_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[63:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[63:0]),
    .waitrequest_in (waitrequest_in)
  );
  five_hundred_twelve_bit_byteenable_FSM upper_five_hundred_twelve_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[127:64]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[127:64]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module five_hundred_twelve_bit_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [63:0] byteenable_in;
  output wire waitrequest_out;
  output wire [63:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[31:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[31:0] == 32'hFFFFFFFF);
  assign partial_upper_half_transfer = (byteenable_in[63:32] != 0);
  assign full_upper_half_transfer = (byteenable_in[63:32] == 32'hFFFFFFFF);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  two_hundred_fifty_six_bit_byteenable_FSM lower_two_hundred_fifty_six_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[31:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[31:0]),
    .waitrequest_in (waitrequest_in)
  );
  two_hundred_fifty_six_bit_byteenable_FSM upper_two_hundred_fifty_six_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[63:32]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[63:32]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module two_hundred_fifty_six_bit_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [31:0] byteenable_in;
  output wire waitrequest_out;
  output wire [31:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[15:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[15:0] == 16'hFFFF);
  assign partial_upper_half_transfer = (byteenable_in[31:16] != 0);
  assign full_upper_half_transfer = (byteenable_in[31:16] == 16'hFFFF);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  one_hundred_twenty_eight_bit_byteenable_FSM lower_one_hundred_twenty_eight_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[15:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[15:0]),
    .waitrequest_in (waitrequest_in)
  );
  one_hundred_twenty_eight_bit_byteenable_FSM upper_one_hundred_twenty_eight_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[31:16]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[31:16]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module one_hundred_twenty_eight_bit_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [15:0] byteenable_in;
  output wire waitrequest_out;
  output wire [15:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[7:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[7:0] == 8'hFF);
  assign partial_upper_half_transfer = (byteenable_in[15:8] != 0);
  assign full_upper_half_transfer = (byteenable_in[15:8] == 8'hFF);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  sixty_four_bit_byteenable_FSM lower_sixty_four_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[7:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[7:0]),
    .waitrequest_in (waitrequest_in)
  );
  sixty_four_bit_byteenable_FSM upper_sixty_four_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[15:8]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[15:8]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module sixty_four_bit_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [7:0] byteenable_in;
  output wire waitrequest_out;
  output wire [7:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[3:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[3:0] == 4'hF);
  assign partial_upper_half_transfer = (byteenable_in[7:4] != 0);
  assign full_upper_half_transfer = (byteenable_in[7:4] == 4'hF);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  thirty_two_bit_byteenable_FSM lower_thirty_two_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[3:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[3:0]),
    .waitrequest_in (waitrequest_in)
  );
  thirty_two_bit_byteenable_FSM upper_thirty_two_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[7:4]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[7:4]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module thirty_two_bit_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [3:0] byteenable_in;
  output wire waitrequest_out;
  output wire [3:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[1:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[1:0] == 2'h3);
  assign partial_upper_half_transfer = (byteenable_in[3:2] != 0);
  assign full_upper_half_transfer = (byteenable_in[3:2] == 2'h3);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  sixteen_bit_byteenable_FSM lower_sixteen_bit_byteenable_FSM (
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[1:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[1:0]),
    .waitrequest_in (waitrequest_in)
  );
  sixteen_bit_byteenable_FSM upper_sixteen_bit_byteenable_FSM (
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[3:2]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[3:2]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module sixteen_bit_byteenable_FSM (
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input write_in;
  input [1:0] byteenable_in;
  output wire waitrequest_out;
  output wire [1:0] byteenable_out; 
  input waitrequest_in;
  assign byteenable_out = byteenable_in & {2{write_in}};          
  assign waitrequest_out = (write_in == 1) & (waitrequest_in == 1);  
endmodule
`timescale 1ns / 1ps
module byte_enable_generator (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  parameter BYTEENABLE_WIDTH = 4;   
  input clk;
  input reset;
  input write_in;                              
  input [BYTEENABLE_WIDTH-1:0] byteenable_in;  
  output wire waitrequest_out;                 
  output wire [BYTEENABLE_WIDTH-1:0] byteenable_out;   
  input waitrequest_in;                                
generate
  if (BYTEENABLE_WIDTH == 1)  
  begin
      assign byteenable_out = byteenable_in;
      assign waitrequest_out = waitrequest_in;
  end
  else if (BYTEENABLE_WIDTH == 2)
  begin
      sixteen_bit_byteenable_FSM the_sixteen_bit_byteenable_FSM (   
        .write_in (write_in),
        .byteenable_in (byteenable_in),
        .waitrequest_out (waitrequest_out),
        .byteenable_out (byteenable_out),
        .waitrequest_in (waitrequest_in)
      );  
  end
  else if (BYTEENABLE_WIDTH == 4)
  begin
      thirty_two_bit_byteenable_FSM the_thirty_two_bit_byteenable_FSM(
        .clk (clk),
        .reset (reset),
        .write_in (write_in),
        .byteenable_in (byteenable_in),
        .waitrequest_out (waitrequest_out),
        .byteenable_out (byteenable_out),
        .waitrequest_in (waitrequest_in)
      );  
  end
  else if (BYTEENABLE_WIDTH == 8)
  begin
      sixty_four_bit_byteenable_FSM the_sixty_four_bit_byteenable_FSM(
        .clk (clk),
        .reset (reset),
        .write_in (write_in),
        .byteenable_in (byteenable_in),
        .waitrequest_out (waitrequest_out),
        .byteenable_out (byteenable_out),
        .waitrequest_in (waitrequest_in)
      );  
  end
  else if (BYTEENABLE_WIDTH == 16)
  begin
      one_hundred_twenty_eight_bit_byteenable_FSM the_one_hundred_twenty_eight_bit_byteenable_FSM(
        .clk (clk),
        .reset (reset),
        .write_in (write_in),
        .byteenable_in (byteenable_in),
        .waitrequest_out (waitrequest_out),
        .byteenable_out (byteenable_out),
        .waitrequest_in (waitrequest_in)
      );  
  end
  else if (BYTEENABLE_WIDTH == 32)
  begin
      two_hundred_fifty_six_bit_byteenable_FSM the_two_hundred_fifty_six_bit_byteenable_FSM(
        .clk (clk),
        .reset (reset),
        .write_in (write_in),
        .byteenable_in (byteenable_in),
        .waitrequest_out (waitrequest_out),
        .byteenable_out (byteenable_out),
        .waitrequest_in (waitrequest_in)
      );
  end
  else if (BYTEENABLE_WIDTH == 64)
  begin
      five_hundred_twelve_bit_byteenable_FSM the_five_hundred_twelve_bit_byteenable_FSM (
        .clk (clk),
        .reset (reset),
        .write_in (write_in),
        .byteenable_in (byteenable_in),
        .waitrequest_out (waitrequest_out),
        .byteenable_out (byteenable_out),
        .waitrequest_in (waitrequest_in)
      );
  end
  else if (BYTEENABLE_WIDTH == 128)
  begin
      one_thousand_twenty_four_byteenable_FSM the_one_thousand_twenty_four_byteenable_FSM (
        .clk (clk),
        .reset (reset),
        .write_in (write_in),
        .byteenable_in (byteenable_in),
        .waitrequest_out (waitrequest_out),
        .byteenable_out (byteenable_out),
        .waitrequest_in (waitrequest_in)
      );
  end
endgenerate
endmodule
module one_thousand_twenty_four_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [127:0] byteenable_in;
  output wire waitrequest_out;
  output wire [127:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[63:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[63:0] == 64'hFFFFFFFFFFFFFFFF);
  assign partial_upper_half_transfer = (byteenable_in[127:64] != 0);
  assign full_upper_half_transfer = (byteenable_in[127:64] == 64'hFFFFFFFFFFFFFFFF);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  five_hundred_twelve_bit_byteenable_FSM lower_five_hundred_twelve_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[63:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[63:0]),
    .waitrequest_in (waitrequest_in)
  );
  five_hundred_twelve_bit_byteenable_FSM upper_five_hundred_twelve_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[127:64]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[127:64]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module five_hundred_twelve_bit_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [63:0] byteenable_in;
  output wire waitrequest_out;
  output wire [63:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[31:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[31:0] == 32'hFFFFFFFF);
  assign partial_upper_half_transfer = (byteenable_in[63:32] != 0);
  assign full_upper_half_transfer = (byteenable_in[63:32] == 32'hFFFFFFFF);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  two_hundred_fifty_six_bit_byteenable_FSM lower_two_hundred_fifty_six_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[31:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[31:0]),
    .waitrequest_in (waitrequest_in)
  );
  two_hundred_fifty_six_bit_byteenable_FSM upper_two_hundred_fifty_six_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[63:32]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[63:32]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module two_hundred_fifty_six_bit_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [31:0] byteenable_in;
  output wire waitrequest_out;
  output wire [31:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[15:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[15:0] == 16'hFFFF);
  assign partial_upper_half_transfer = (byteenable_in[31:16] != 0);
  assign full_upper_half_transfer = (byteenable_in[31:16] == 16'hFFFF);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  one_hundred_twenty_eight_bit_byteenable_FSM lower_one_hundred_twenty_eight_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[15:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[15:0]),
    .waitrequest_in (waitrequest_in)
  );
  one_hundred_twenty_eight_bit_byteenable_FSM upper_one_hundred_twenty_eight_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[31:16]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[31:16]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module one_hundred_twenty_eight_bit_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [15:0] byteenable_in;
  output wire waitrequest_out;
  output wire [15:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[7:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[7:0] == 8'hFF);
  assign partial_upper_half_transfer = (byteenable_in[15:8] != 0);
  assign full_upper_half_transfer = (byteenable_in[15:8] == 8'hFF);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  sixty_four_bit_byteenable_FSM lower_sixty_four_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[7:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[7:0]),
    .waitrequest_in (waitrequest_in)
  );
  sixty_four_bit_byteenable_FSM upper_sixty_four_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[15:8]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[15:8]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module sixty_four_bit_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [7:0] byteenable_in;
  output wire waitrequest_out;
  output wire [7:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[3:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[3:0] == 4'hF);
  assign partial_upper_half_transfer = (byteenable_in[7:4] != 0);
  assign full_upper_half_transfer = (byteenable_in[7:4] == 4'hF);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  thirty_two_bit_byteenable_FSM lower_thirty_two_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[3:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[3:0]),
    .waitrequest_in (waitrequest_in)
  );
  thirty_two_bit_byteenable_FSM upper_thirty_two_bit_byteenable_FSM (
    .clk (clk),
    .reset (reset),
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[7:4]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[7:4]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module thirty_two_bit_byteenable_FSM (
  clk,
  reset,
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input clk;
  input reset;
  input write_in;
  input [3:0] byteenable_in;
  output wire waitrequest_out;
  output wire [3:0] byteenable_out; 
  input waitrequest_in;
  wire partial_lower_half_transfer;
  wire full_lower_half_transfer;
  wire partial_upper_half_transfer;
  wire full_upper_half_transfer;
  wire full_word_transfer;
  reg state_bit;
  wire transfer_done;
  wire advance_to_next_state;
  wire lower_enable;
  wire upper_enable;
  wire lower_stall;
  wire upper_stall;
  wire two_stage_transfer;
  always @ (posedge clk or posedge reset)
  begin
    if (reset)
    begin
      state_bit <= 0;
    end
    else
    begin
      if (transfer_done == 1)
      begin
        state_bit <= 0;
      end
      else if (advance_to_next_state == 1)
      begin
        state_bit <= 1;
      end
    end
  end
  assign partial_lower_half_transfer = (byteenable_in[1:0] != 0);
  assign full_lower_half_transfer = (byteenable_in[1:0] == 2'h3);
  assign partial_upper_half_transfer = (byteenable_in[3:2] != 0);
  assign full_upper_half_transfer = (byteenable_in[3:2] == 2'h3);
  assign full_word_transfer = (full_lower_half_transfer == 1) & (full_upper_half_transfer == 1);
  assign two_stage_transfer = (full_word_transfer == 0) & (partial_lower_half_transfer == 1) & (partial_upper_half_transfer == 1);
  assign advance_to_next_state = (two_stage_transfer == 1) & (lower_stall == 0) & (write_in == 1) & (state_bit == 0) & (waitrequest_in == 0);  
  assign transfer_done = ((full_word_transfer == 1) & (waitrequest_in == 0) & (write_in == 1)) | 
                         ((two_stage_transfer == 0) & (lower_stall == 0) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0)) | 
                         ((two_stage_transfer == 1) & (state_bit == 1) & (upper_stall == 0) & (write_in == 1) & (waitrequest_in == 0));  
  assign lower_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_lower_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_lower_half_transfer == 1) & (state_bit == 0));  
  assign upper_enable = ((write_in == 1) & (full_word_transfer == 1)) |  
                        ((write_in == 1) & (two_stage_transfer == 0) & (partial_upper_half_transfer == 1)) | 
                        ((write_in == 1) & (two_stage_transfer == 1) & (partial_upper_half_transfer == 1) & (state_bit == 1));  
  sixteen_bit_byteenable_FSM lower_sixteen_bit_byteenable_FSM (
    .write_in (lower_enable),
    .byteenable_in (byteenable_in[1:0]),
    .waitrequest_out (lower_stall),    
    .byteenable_out (byteenable_out[1:0]),
    .waitrequest_in (waitrequest_in)
  );
  sixteen_bit_byteenable_FSM upper_sixteen_bit_byteenable_FSM (
    .write_in (upper_enable),
    .byteenable_in (byteenable_in[3:2]),
    .waitrequest_out (upper_stall),    
    .byteenable_out (byteenable_out[3:2]),
    .waitrequest_in (waitrequest_in)
  );
  assign waitrequest_out = (waitrequest_in == 1) | ((transfer_done == 0) & (write_in == 1));
endmodule
module sixteen_bit_byteenable_FSM (
  write_in,
  byteenable_in,
  waitrequest_out,
  byteenable_out,
  waitrequest_in
);
  input write_in;
  input [1:0] byteenable_in;
  output wire waitrequest_out;
  output wire [1:0] byteenable_out; 
  input waitrequest_in;
  assign byteenable_out = byteenable_in & {2{write_in}};          
  assign waitrequest_out = (write_in == 1) & (waitrequest_in == 1);  
endmodule
