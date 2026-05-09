module EBABWrapper
  (
   bus_byte_enable, bus_read, bus_write, bus_write_data, bus_addr,
   clk, rst, out_sel, delta_mode_left, delta_mode_right, bus_ack,
   bus_read_data, delta_left, delta_right, triangle_wave_max_left,
   triangle_wave_max_right
   );
   input clk, rst, out_sel, delta_mode_left, delta_mode_right;
   input bus_ack;              
   input [31:0] bus_read_data; 
   input [31:0] delta_left, delta_right;
   input [9:0]  triangle_wave_max_left, triangle_wave_max_right;
   output reg [3:0] bus_byte_enable; 
   output reg       bus_read;        
   output reg       bus_write;       
   output reg [31:0] bus_write_data; 
   output reg [31:0] bus_addr;       
   wire [31:0]       audio_base_address       = 32'h00003040; 
   wire [31:0]       audio_fifo_address       = 32'h00003044; 
   wire [31:0]       audio_data_left_address  = 32'h00003048; 
   wire [31:0]       audio_data_right_address = 32'h0000304c; 
   reg [3:0]         state;
   reg [7:0]         fifo_space; 
   reg [31:0]        right_audio_input, left_audio_input;
   reg               audio_input_valid;
   wire [31:0]       right_audio_output, left_audio_output, pitch_shift_out[0:1], filter_out[0:1];
   wire              pitch_shift_val[0:1], audio_out_val[0:1];
   assign left_audio_output  = (audio_out_val[0]) ? filter_out[0] : left_audio_output;
   assign right_audio_output = (audio_out_val[1]) ? filter_out[1] : right_audio_output;
   buffer #(1024) left_buffer
     (
      .clk(clk),
      .rst(rst),
      .delta(delta_left),
      .new_sample_val(audio_input_valid),
      .new_sample_data(right_audio_input),
      .out_sel(1'b1),
      .delta_mode(delta_mode_left),
      .triangle_wave_max(triangle_wave_max_left),
      .pitch_shift_out(pitch_shift_out[0]),
      .pitch_shift_val(pitch_shift_val[0])
      );
   buffer #(1024) right_buffer
     (
      .clk(clk),
      .rst(rst),
      .delta(delta_right),
      .new_sample_val(audio_input_valid),
      .new_sample_data(right_audio_input),
      .out_sel(1'b1),
      .delta_mode(delta_mode_right),
      .triangle_wave_max(triangle_wave_max_right),
      .pitch_shift_out(pitch_shift_out[1]),
      .pitch_shift_val(pitch_shift_val[1])
      );
   IIR6_32bit_fixed filter_left(
                                .audio_out (filter_out[0]),
                                .audio_in (pitch_shift_out[0]),
                                .scale (3'd3),
                                .b1 (32'h226C),
                                .b2 (32'hCE8B),
                                .b3 (32'h2045B),
                                .b4 (32'h2B07A),
                                .b5 (32'h2045B),
                                .b6 (32'hCE8B),
                                .b7 (32'h226C),
                                .a2 (32'h21DC9D38),
                                .a3 (32'hC2BABD8C),
                                .a4 (32'h3C58991F),
                                .a5 (32'hDDFDB62D),
                                .a6 (32'hA5FA11C),
                                .a7 (32'hFEAA19B2),
                                .clk(clk),
                                .data_val(pitch_shift_val[0]),
                                .rst(rst),
                                .audio_out_val(audio_out_val[0])
                                ) ; 
   IIR6_32bit_fixed filter_right(
                                 .audio_out (filter_out[1]),
                                 .audio_in (pitch_shift_out[1]),
                                 .scale (3'd3),
                                 .b1 (32'h226C),
                                 .b2 (32'hCE8B),
                                 .b3 (32'h2045B),
                                 .b4 (32'h2B07A),
                                 .b5 (32'h2045B),
                                 .b6 (32'hCE8B),
                                 .b7 (32'h226C),
                                 .a2 (32'h21DC9D38),
                                 .a3 (32'hC2BABD8C),
                                 .a4 (32'h3C58991F),
                                 .a5 (32'hDDFDB62D),
                                 .a6 (32'hA5FA11C),
                                 .a7 (32'hFEAA19B2),
                                 .clk(clk),
                                 .data_val(pitch_shift_val[1]),
                                 .rst(rst),
                                 .audio_out_val(audio_out_val[1])
                                 ) ; 
   always @(posedge clk) begin 
      if (rst) begin
         state     <= 0;
         bus_read  <= 0; 
         bus_write <= 0; 
      end
      if (state==4'd0) begin
         bus_addr        <= audio_fifo_address;
         bus_read        <= 1'b1;
         bus_byte_enable <= 4'b1111;
         state           <= 4'd1; 
      end
      if (state==4'd1 && bus_ack==1) begin
         state      <= 4'd2; 
         fifo_space <= (bus_read_data>>24);
         bus_read   <= 1'b0;
      end
      if (state==4'd2 && fifo_space>8'd2) begin 
         state           <= 4'd3;
         bus_write_data  <= left_audio_output;
         bus_addr        <= audio_data_left_address;
         bus_byte_enable <= 4'b1111;
         bus_write       <= 1'b1;
      end
      else if (state==4'd2 && fifo_space<=8'd2) begin
         state <= 4'b0;
      end
      if (state==4'd3 && bus_ack==1) begin
         state     <= 4'd4; 
         bus_write <= 0;
      end
      if (state==4'd4) begin 
         state          <= 4'd5;
         bus_write_data <= right_audio_output;
         bus_addr       <= audio_data_right_address;
         bus_write      <= 1'b1;
      end
      if (state==4'd5 && bus_ack==1) begin
         state     <= 4'd6; 
         bus_write <= 0;
      end
      if (state==4'd6 ) begin
         bus_addr        <= audio_fifo_address;
         bus_read        <= 1'b1;
         bus_byte_enable <= 4'b1111;
         state           <= 4'd7; 
      end
      if (state==4'd7 && bus_ack==1) begin
         state      <= 4'd8; 
         fifo_space <= bus_read_data & 8'hff;
         bus_read   <= 1'b0;
      end
      if (state==4'd8 && fifo_space>8'd0) begin 
         state           <= 4'd9;
         bus_addr        <= audio_data_left_address;
         bus_byte_enable <= 4'b1111;
         bus_read        <= 1'b1;
      end
      else if (state==4'd8 && fifo_space<=8'd0) begin
         state <= 4'b0;
      end
      if (state==4'd9 && bus_ack==1) begin
         state            <= 4'd10; 
         left_audio_input <= bus_read_data;
         bus_read         <= 0;
      end
      if (state==4'd10) begin 
         state           <= 4'd11;
         bus_addr        <= audio_data_right_address;
         bus_byte_enable <= 4'b1111;
         bus_read        <= 1'b1;
      end
      if (state==4'd11 && bus_ack==1) begin
         state             <= 4'd12; 
         right_audio_input <= bus_read_data;
         audio_input_valid <= 1'b1;
         bus_read          <= 0;
      end
      if (state==4'd12) begin
         state             <= 4'd0; 
         audio_input_valid <= 1'b0;
      end
   end 
endmodule 
