module buffer
  #(parameter B=1024)
   (
    clk,
    rst,
    delta,
    new_sample_val,
    new_sample_data,
    out_sel,
    delta_mode, 
    triangle_wave_max,
    pitch_shift_out,
    pitch_shift_val
    );
   input clk, rst, new_sample_val, out_sel, delta_mode;
   input [9:0] triangle_wave_max;
   input [31:0] delta; 
   input signed [31:0] new_sample_data;
   reg signed [31:0]   new_sample_data_reg;
   reg                 rb1_rden, rb2_rden, rb1_wren, rb2_wren;
   reg [$clog2(B)+28:0] rb1_index; 
   reg [$clog2(B)+28:0] rb2_index;
   reg [$clog2(B)-1:0]  rb1_read_addr;
   reg [$clog2(B)-1:0]  rb2_read_addr;
   reg [$clog2(B)-1:0]  rb1_write_addr;
   reg [$clog2(B)-1:0]  rb2_write_addr;
   wire signed [31:0]   rb1_read_out;
   wire signed [31:0]   rb2_read_out;
   reg [2:0]            state;
   wire [31:0]          delta_effective; 
   reg [9:0]            delta_rom_addr;
   reg [9:0]            delta_counter;
   wire [31:0]          delta_rom_out;
   output signed [31:0] pitch_shift_out;
   output signed [31:0] pitch_shift_val;
   assign pitch_shift_out = (out_sel) ? rb1_read_out
                            : ((rb1_read_out >>> 1) + (rb2_read_out >>> 1));
   assign pitch_shift_val = (state == 3'd2) ? 1'b1 : 1'b0;
   assign delta_effective = (delta_mode) ? delta : delta_rom_out;
   RAM_512_18 #(B) rb1
     (
      .clock(clk),
      .q(rb1_read_out),
      .rdaddress(rb1_read_addr),
      .data(new_sample_data_reg),
      .wraddress(rb1_write_addr),
      .wren(rb1_wren),
      .rden(rb1_rden)
      );
   RAM_512_18 #(B) rb2
     (
      .clock(clk),
      .q(rb2_read_out),
      .rdaddress(rb2_read_addr),
      .data(new_sample_data_reg),
      .wraddress(rb1_write_addr),
      .wren(rb2_wren),
      .rden(rb2_rden)
      );
   delta_rom   d1   (.clock(clk),
                     .address(delta_rom_addr),
                     .delta_out(delta_rom_out));
   always @ (posedge clk) begin
      if (rst) begin
         state               <= 3'd0;
         rb1_index           <= 0;
         rb2_index           <= 0;
         rb1_write_addr      <= 0;
         rb2_write_addr      <= (B/2);
         rb1_read_addr       <= 0;
         rb2_read_addr       <= 0;
         new_sample_data_reg <= 0;
         rb1_rden            <= 0;
         rb2_rden            <= 0;
         rb1_wren            <= 0;
         rb2_wren            <= 0;
         delta_counter       <= 0;
         delta_rom_addr      <= 0;
      end
      else if ((state == 3'd0) && new_sample_val) begin
         new_sample_data_reg <= new_sample_data;
         rb1_write_addr <= (rb1_write_addr == (B - 1)) ?  0 : (rb1_write_addr + 1);
         rb2_write_addr <= (rb2_write_addr == (B - 1)) ?  0 : (rb2_write_addr + 1);
         rb1_index <= (rb1_index + delta_effective);
         rb2_index <= (rb2_index + delta_effective);
         rb1_read_addr <= rb1_index[$clog2(B)+28 : 29];
         rb2_read_addr <= rb2_index[$clog2(B)+28 : 29];
         rb1_rden <= 1;
         rb2_rden <= 1;
         rb1_wren <= 1;
         rb2_wren <= 1;
         state    <= 3'd1;
      end
      else if ((state == 3'd1)) begin
         rb1_wren <= 0;
         rb2_wren <= 0;
         state    <= 3'd2;
      end
      else if ((state == 3'd2)) begin
         rb1_rden <= 0;
         rb2_rden <= 0;
         state    <= 3'd0;
         delta_counter <= (delta_counter == triangle_wave_max) ? 10'd0
                          : (delta_counter + 10'd1);
         delta_rom_addr <= (delta_counter == triangle_wave_max) ?
                           ((delta_rom_addr == 10'd513 ) ? 10'd0
                            : (delta_rom_addr + 10'd1)) : delta_rom_addr;
      end
      else begin
         rb1_rden <= 0;
         rb2_rden <= 0;
         rb1_wren <= 0;
         rb2_wren <= 0;
      end
   end
endmodule
module RAM_512_18
  #(parameter B = 1024)
   (
    output signed [31:0]    q,
    input signed [31:0]     data,
    input [($clog2(B)-1):0] wraddress, rdaddress,
    input                   wren, rden, clock
    );
   reg [8:0]                read_address_reg;
   reg signed [31:0]        mem [(B-1):0] ;
   reg                      rden_reg;
   always @(posedge clock) begin
      if (wren)
        mem[wraddress] <= data;
   end
   always @(posedge clock) begin
      read_address_reg <= rdaddress;
      rden_reg <= rden;
   end
   assign q = (rden_reg) ? mem[read_address_reg] : 0;
endmodule
module buffer
  #(parameter B=1024)
   (
    clk,
    rst,
    delta,
    new_sample_val,
    new_sample_data,
    out_sel,
    delta_mode, 
    triangle_wave_max,
    pitch_shift_out,
    pitch_shift_val
    );
   input clk, rst, new_sample_val, out_sel, delta_mode;
   input [9:0] triangle_wave_max;
   input [31:0] delta; 
   input signed [31:0] new_sample_data;
   reg signed [31:0]   new_sample_data_reg;
   reg                 rb1_rden, rb2_rden, rb1_wren, rb2_wren;
   reg [$clog2(B)+28:0] rb1_index; 
   reg [$clog2(B)+28:0] rb2_index;
   reg [$clog2(B)-1:0]  rb1_read_addr;
   reg [$clog2(B)-1:0]  rb2_read_addr;
   reg [$clog2(B)-1:0]  rb1_write_addr;
   reg [$clog2(B)-1:0]  rb2_write_addr;
   wire signed [31:0]   rb1_read_out;
   wire signed [31:0]   rb2_read_out;
   reg [2:0]            state;
   wire [31:0]          delta_effective; 
   reg [9:0]            delta_rom_addr;
   reg [9:0]            delta_counter;
   wire [31:0]          delta_rom_out;
   output signed [31:0] pitch_shift_out;
   output signed [31:0] pitch_shift_val;
   assign pitch_shift_out = (out_sel) ? rb1_read_out
                            : ((rb1_read_out >>> 1) + (rb2_read_out >>> 1));
   assign pitch_shift_val = (state == 3'd2) ? 1'b1 : 1'b0;
   assign delta_effective = (delta_mode) ? delta : delta_rom_out;
   RAM_512_18 #(B) rb1
     (
      .clock(clk),
      .q(rb1_read_out),
      .rdaddress(rb1_read_addr),
      .data(new_sample_data_reg),
      .wraddress(rb1_write_addr),
      .wren(rb1_wren),
      .rden(rb1_rden)
      );
   RAM_512_18 #(B) rb2
     (
      .clock(clk),
      .q(rb2_read_out),
      .rdaddress(rb2_read_addr),
      .data(new_sample_data_reg),
      .wraddress(rb1_write_addr),
      .wren(rb2_wren),
      .rden(rb2_rden)
      );
   delta_rom   d1   (.clock(clk),
                     .address(delta_rom_addr),
                     .delta_out(delta_rom_out));
   always @ (posedge clk) begin
      if (rst) begin
         state               <= 3'd0;
         rb1_index           <= 0;
         rb2_index           <= 0;
         rb1_write_addr      <= 0;
         rb2_write_addr      <= (B/2);
         rb1_read_addr       <= 0;
         rb2_read_addr       <= 0;
         new_sample_data_reg <= 0;
         rb1_rden            <= 0;
         rb2_rden            <= 0;
         rb1_wren            <= 0;
         rb2_wren            <= 0;
         delta_counter       <= 0;
         delta_rom_addr      <= 0;
      end
      else if ((state == 3'd0) && new_sample_val) begin
         new_sample_data_reg <= new_sample_data;
         rb1_write_addr <= (rb1_write_addr == (B - 1)) ?  0 : (rb1_write_addr + 1);
         rb2_write_addr <= (rb2_write_addr == (B - 1)) ?  0 : (rb2_write_addr + 1);
         rb1_index <= (rb1_index + delta_effective);
         rb2_index <= (rb2_index + delta_effective);
         rb1_read_addr <= rb1_index[$clog2(B)+28 : 29];
         rb2_read_addr <= rb2_index[$clog2(B)+28 : 29];
         rb1_rden <= 1;
         rb2_rden <= 1;
         rb1_wren <= 1;
         rb2_wren <= 1;
         state    <= 3'd1;
      end
      else if ((state == 3'd1)) begin
         rb1_wren <= 0;
         rb2_wren <= 0;
         state    <= 3'd2;
      end
      else if ((state == 3'd2)) begin
         rb1_rden <= 0;
         rb2_rden <= 0;
         state    <= 3'd0;
         delta_counter <= (delta_counter == triangle_wave_max) ? 10'd0
                          : (delta_counter + 10'd1);
         delta_rom_addr <= (delta_counter == triangle_wave_max) ?
                           ((delta_rom_addr == 10'd513 ) ? 10'd0
                            : (delta_rom_addr + 10'd1)) : delta_rom_addr;
      end
      else begin
         rb1_rden <= 0;
         rb2_rden <= 0;
         rb1_wren <= 0;
         rb2_wren <= 0;
      end
   end
endmodule
