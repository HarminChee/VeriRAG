module lsu_streaming_write
(
   clk, reset, o_stall, i_valid, i_stall, i_writedata, i_nop, i_byteenable, o_valid, 
   o_active, 
   base_address, size, avm_address, avm_burstcount, avm_write, avm_writeack, avm_writedata,
   avm_byteenable, avm_waitrequest
);
parameter AWIDTH=32;
parameter WIDTH_BYTES=32;
parameter MWIDTH_BYTES=32;
parameter ALIGNMENT_ABITS=6;
parameter BURSTCOUNT_WIDTH=6;
parameter KERNEL_SIDE_MEM_LATENCY=1;
parameter MEMORY_SIDE_MEM_LATENCY=1;  
parameter USE_BYTE_EN=0;
localparam WIDTH=8*WIDTH_BYTES;
localparam MWIDTH=8*MWIDTH_BYTES;
localparam MBYTE_SELECT_BITS=$clog2(MWIDTH_BYTES);
localparam BYTE_SELECT_BITS=$clog2(WIDTH_BYTES);
localparam MAXBURSTCOUNT=2**(BURSTCOUNT_WIDTH-1);
localparam __FIFO_DEPTH=2*MAXBURSTCOUNT + (MEMORY_SIDE_MEM_LATENCY * WIDTH + MWIDTH - 1) / MWIDTH;
localparam _FIFO_DEPTH= ( __FIFO_DEPTH > MAXBURSTCOUNT+4 ) ? __FIFO_DEPTH : MAXBURSTCOUNT+5;
localparam FIFO_DEPTH= 2**($clog2(_FIFO_DEPTH));
localparam FIFO_DEPTH_LOG2=$clog2(FIFO_DEPTH);
localparam NUM_FIFOS = MWIDTH / WIDTH;
localparam FIFO_ID_WIDTH = (NUM_FIFOS == 1) ? 1 : $clog2(NUM_FIFOS);  
input clk;
input reset;
output o_stall;
input i_valid;
input [WIDTH-1:0] i_writedata;
input i_nop;
input [AWIDTH-1:0] base_address;
input [31:0] size;
input [WIDTH_BYTES-1:0] i_byteenable;
output reg o_valid;
input i_stall;
output o_active;
wire o_valid_int;
wire i_stall_int;
output [AWIDTH-1:0] avm_address;
output [BURSTCOUNT_WIDTH-1:0] avm_burstcount;
output avm_write;
input avm_writeack;
output [MWIDTH-1:0] avm_writedata;
output [MWIDTH_BYTES-1:0] avm_byteenable;
input avm_waitrequest;
wire f_avm_write;
wire [MWIDTH-1:0] f_avm_writedata;
wire [MWIDTH_BYTES-1:0] f_avm_byteenable;
wire f_avm_waitrequest;
wire [AWIDTH-1:0] f_avm_address;
wire [BURSTCOUNT_WIDTH-1:0] f_avm_burstcount;
acl_data_fifo #(
  .DATA_WIDTH(AWIDTH+BURSTCOUNT_WIDTH+MWIDTH+MWIDTH_BYTES),
  .DEPTH(2),
  .IMPL("ll_reg")
) avm_buffer (
  .clock(clk),
  .resetn(!reset),
  .data_in( {f_avm_address,f_avm_burstcount,f_avm_byteenable,f_avm_writedata} ),
  .valid_in( f_avm_write ),
  .data_out( {avm_address,avm_burstcount,avm_byteenable,avm_writedata} ),
  .valid_out( avm_write ),
  .stall_in( avm_waitrequest ),
  .stall_out( f_avm_waitrequest )
);
wire [AWIDTH-1:0] aligned_base_address;
wire [AWIDTH-1:0] last_word_address;
wire [AWIDTH-1:0] base_offset;
wire go;
wire [AWIDTH-1:0] a_base_address;
wire [31:0] a_size;
wire c_done;
reg [31:0] c_length;
reg [31:0] c_length_reenc;
reg [31:0] ack_counter;
reg wm_first_xfer;
reg [AWIDTH-1:0] wm_address;
reg [BURSTCOUNT_WIDTH-1:0] wm_burstcount;
reg [BURSTCOUNT_WIDTH-1:0] wm_burst_counter;
reg fw_in_enable;
reg fw_out_enable;
reg [MWIDTH_BYTES-1:0] fw_byteenable;
wire lw_out_enable;
reg [MWIDTH_BYTES-1:0] lw_byteenable;
wire [AWIDTH-1:0] fsb_boundary_offset;
wire fsb_enable;
wire [BURSTCOUNT_WIDTH-1:0] fsb_count;
wire fsb_ready;
wire lsb_enable;
wire [BURSTCOUNT_WIDTH-1:0] lsb_count;
wire lsb_ready;
wire b_ready;
wire burst_begin;
wire [BURSTCOUNT_WIDTH-1:0] burst_count;
wire write_accepted;
wire [FIFO_ID_WIDTH-1:0] fifo_next_word;
reg [FIFO_ID_WIDTH-1:0] fifo_next_word_reg;
wire fifo_full;
wire [FIFO_DEPTH_LOG2-1:0] fifo_used;
wire [MWIDTH-1:0] fifo_data_out;
wire [MWIDTH_BYTES-1:0] fifo_byteenable_out;
wire [NUM_FIFOS-1:0][FIFO_DEPTH_LOG2-1:0] fifo_used_n;
wire [NUM_FIFOS-1:0] fifo_full_n;
wire [MWIDTH_BYTES-1:0] fifo_byteenable;
wire [NUM_FIFOS-1:0] fifo_wrreq_n;
reg [2:0] valid_in_d;
reg [31:0] threads_remaining_to_be_serviced;
reg [31:0] threads_rem;
always@(posedge clk or posedge reset)
begin
   if(reset == 1'b1)
   begin
      valid_in_d <= 3'b000;
      threads_rem <= 0;
   end
   else
   begin
      valid_in_d <= { (i_valid && !o_stall && !i_nop), valid_in_d[2:1] };
      threads_rem <= (go ? size : threads_rem) - valid_in_d[0];
   end
end
assign aligned_base_address = ((base_address >> ALIGNMENT_ABITS) << ALIGNMENT_ABITS);
assign last_word_address = aligned_base_address + ((size - 1) << BYTE_SELECT_BITS);
assign a_base_address = ((aligned_base_address >> MBYTE_SELECT_BITS) << MBYTE_SELECT_BITS);
assign base_offset = (aligned_base_address[MBYTE_SELECT_BITS-1:0] >> BYTE_SELECT_BITS);
assign a_size = (((((size + base_offset) << BYTE_SELECT_BITS) + {MBYTE_SELECT_BITS{1'b1}}) >> MBYTE_SELECT_BITS) << MBYTE_SELECT_BITS);
assign go = i_valid && !o_stall && !i_nop && c_done;
always@(posedge clk or posedge reset)
begin
   if(reset == 1'b1)
   begin
      wm_first_xfer <= 1'b0;
      wm_address <= {AWIDTH{1'b0}};
      c_length <= {32{1'b0}};
      c_length_reenc <= {32{1'b1}};
      wm_burstcount <= {BURSTCOUNT_WIDTH{1'b0}};
      wm_burst_counter <= {BURSTCOUNT_WIDTH{1'b0}};
      fw_byteenable <= {MWIDTH_BYTES{1'b0}};
      lw_byteenable <= {MWIDTH_BYTES{1'b0}};
      fw_in_enable <= 1'b0;
      fw_out_enable <= 1'b0;
      threads_remaining_to_be_serviced <= {32{1'b0}};
   end
   else
   begin
      wm_burstcount <= burst_begin ? burst_count : wm_burstcount;
      lw_byteenable <= (fifo_byteenable[0] ? {MWIDTH_BYTES{1'b0}} : lw_byteenable) | fifo_byteenable;
      if(go == 1'b1)
      begin
         wm_first_xfer <= 1'b1;
         wm_address <= a_base_address;
         c_length <= a_size;
         c_length_reenc <= a_size-1;
         wm_burst_counter <= {BURSTCOUNT_WIDTH{1'b0}};
         fw_byteenable <= fifo_byteenable;
         if(NUM_FIFOS > 1)
         begin
            fw_in_enable <= (!(i_valid && !o_stall && !i_nop) || (fifo_next_word != {FIFO_ID_WIDTH{1'b1}}));
            fw_out_enable <= 1'b1;
         end
         threads_remaining_to_be_serviced <= size-2;
      end
      else
      begin
         wm_first_xfer <= !burst_begin && wm_first_xfer;
         wm_address <= (!wm_first_xfer && burst_begin) ? (wm_address + (wm_burstcount << MBYTE_SELECT_BITS)) : (wm_address);
         c_length <= write_accepted ? c_length - MWIDTH_BYTES : c_length;
         c_length_reenc <= write_accepted ? c_length_reenc - MWIDTH_BYTES : c_length_reenc;
         wm_burst_counter <= burst_begin ? burst_count : (wm_burst_counter - write_accepted);
         fw_byteenable <= fw_byteenable | ({MWIDTH_BYTES{fw_in_enable}} & fifo_byteenable);
         fw_in_enable <= fw_in_enable && (!(i_valid && !o_stall && !i_nop) || (fifo_next_word != {FIFO_ID_WIDTH{1'b1}}));
         fw_out_enable <= fw_out_enable && !write_accepted;
         threads_remaining_to_be_serviced <= (i_valid && !o_stall && !i_nop) ? (threads_remaining_to_be_serviced - 1) : threads_remaining_to_be_serviced;
      end
   end
end
assign lw_out_enable = (c_length <= MWIDTH_BYTES);
assign c_done = c_length_reenc[31];
assign fsb_boundary_offset = (wm_address >> MBYTE_SELECT_BITS) & (MAXBURSTCOUNT-1);
assign fsb_enable = (fsb_boundary_offset != 0) && wm_first_xfer;
assign fsb_count = (fsb_boundary_offset[0]) ? 1 : 
                   (((MAXBURSTCOUNT - fsb_boundary_offset) < (c_length >> MBYTE_SELECT_BITS)) ?
                   (MAXBURSTCOUNT - fsb_boundary_offset) : lsb_count);
assign fsb_ready = (fifo_used > fsb_count) || (fifo_used == fsb_count) && (wm_burst_counter == 0);
assign lsb_enable = (c_length <= (MAXBURSTCOUNT << MBYTE_SELECT_BITS));
assign lsb_count = (c_length >> MBYTE_SELECT_BITS);
assign lsb_ready = (threads_rem == 0);
assign b_ready = (fifo_used > MAXBURSTCOUNT) || ((fifo_used == MAXBURSTCOUNT) && (wm_burst_counter == 0));
assign burst_begin = ((fsb_enable && fsb_ready) || (lsb_enable && lsb_ready) || (b_ready)) &&
                     !c_done && ((wm_burst_counter == 0) || ((wm_burst_counter == 1) && 
                     !f_avm_waitrequest && (c_length > (MAXBURSTCOUNT << MBYTE_SELECT_BITS))));
assign burst_count = fsb_enable ? fsb_count :
                     lsb_enable ? lsb_count : MAXBURSTCOUNT;
assign write_accepted = f_avm_write && !f_avm_waitrequest;
assign fifo_next_word = go ? base_offset : fifo_next_word_reg;
always@(posedge clk or posedge reset)
begin
   if(reset == 1'b1)
   begin
      fifo_next_word_reg <= {FIFO_ID_WIDTH{1'b0}};
   end
   else
   begin
      if(NUM_FIFOS > 1)
         fifo_next_word_reg <= (i_valid && !o_stall) ? fifo_next_word + 1 : fifo_next_word;
   end
end
wire [NUM_FIFOS-1:0] fifo_empty;
wire [NUM_FIFOS-1:0] fifo_read_enable;
genvar n;
generate
   for(n=0; n<NUM_FIFOS; n++)
   begin : fifo_n
      if (USE_BYTE_EN)
      begin
         scfifo #(
           .lpm_width( WIDTH+WIDTH_BYTES ),
           .lpm_widthu( FIFO_DEPTH_LOG2 ),
           .lpm_numwords( FIFO_DEPTH ),
           .lpm_showahead( "ON" ),
           .almost_full_value( FIFO_DEPTH - 2 ),
           .use_eab( "ON" ),
           .add_ram_output_register( "OFF" ),
           .underflow_checking( "OFF" ),
           .overflow_checking( "OFF" )
        ) data_fifo (
           .clock( clk ),
           .aclr( reset ),
           .usedw( fifo_used_n[n] ),
           .data( {i_writedata,i_byteenable }),
           .almost_full( fifo_full_n[n] ),
           .q( { fifo_data_out[n*WIDTH +: WIDTH],fifo_byteenable_out[n*WIDTH_BYTES +: WIDTH_BYTES]} ),
           .rdreq( write_accepted &&  fifo_read_enable[n] ),
           .wrreq( fifo_wrreq_n[n] ),
           .almost_empty(),
           .empty(fifo_empty[n]),
           .full(),
           .sclr()
        );
      end else begin
        scfifo #(
           .lpm_width( WIDTH ),
           .lpm_widthu( FIFO_DEPTH_LOG2 ),
           .lpm_numwords( FIFO_DEPTH ),
           .lpm_showahead( "ON" ),
           .almost_full_value( FIFO_DEPTH - 2 ),
           .use_eab( "ON" ),
           .add_ram_output_register( "OFF" ),
           .underflow_checking( "OFF" ),
           .overflow_checking( "OFF" )
        ) data_fifo (
           .clock( clk ),
           .aclr( reset ),
           .usedw( fifo_used_n[n] ),
           .data( i_writedata ),
           .almost_full( fifo_full_n[n] ),
           .q( fifo_data_out[n*WIDTH +: WIDTH] ),
           .rdreq( write_accepted &&  fifo_read_enable[n] ),
           .wrreq( fifo_wrreq_n[n] ),
           .almost_empty(),
           .empty(fifo_empty[n]),
           .full(),
           .sclr()
        );
        assign fifo_byteenable_out[n*WIDTH_BYTES +: WIDTH_BYTES] = {WIDTH_BYTES{ 1'b1}};     
      end
      assign fifo_wrreq_n[n] = i_valid && !o_stall && !i_nop && (fifo_next_word == n);
      assign fifo_byteenable[n*WIDTH_BYTES +: WIDTH_BYTES] = {WIDTH_BYTES{ fifo_wrreq_n[n] }};
      assign fifo_read_enable[n] = fw_out_enable ? fw_byteenable[n*WIDTH_BYTES] : (lw_out_enable ? lw_byteenable[n*WIDTH_BYTES] :1'b1);
   end
endgenerate
assign fifo_full = fifo_full_n[NUM_FIFOS-1];
assign fifo_used = fifo_used_n[NUM_FIFOS-1];
assign f_avm_write = !c_done && (wm_burst_counter != 0);
assign f_avm_address = wm_address;
assign f_avm_burstcount = wm_burstcount;
assign f_avm_writedata = fifo_data_out;
assign f_avm_byteenable = fw_out_enable ? fw_byteenable & fifo_byteenable_out:
                       (lw_out_enable ? lw_byteenable : {MWIDTH_BYTES{1'b1}}) & fifo_byteenable_out ;
assign o_stall = fifo_full || i_stall_int || (!c_done && threads_remaining_to_be_serviced[31]);
assign o_valid_int = i_valid && !fifo_full && !o_stall;
assign i_stall_int = o_valid && i_stall;
always@(posedge clk or posedge reset)
begin
   if(reset == 1'b1)
      o_valid <= {1'b0};
   else if (!i_stall_int)
      o_valid = o_valid_int;
   else
      o_valid = o_valid;
end
assign o_active = |(~fifo_empty);
endmodule
module lsu_streaming_read 
(
   clk, reset, o_stall, i_valid, i_stall, i_nop, o_valid, o_readdata, 
   o_active, 
   base_address, size, avm_address, avm_burstcount, avm_read, 
   avm_readdata, avm_waitrequest, avm_byteenable, avm_readdatavalid
);
parameter AWIDTH=32;
parameter WIDTH_BYTES=32;
parameter MWIDTH_BYTES=32;
parameter ALIGNMENT_ABITS=6;
parameter BURSTCOUNT_WIDTH=6;
parameter KERNEL_SIDE_MEM_LATENCY=1;
parameter MEMORY_SIDE_MEM_LATENCY=1;
localparam WIDTH=8*WIDTH_BYTES;
localparam MWIDTH=8*MWIDTH_BYTES;
localparam MBYTE_SELECT_BITS=$clog2(MWIDTH_BYTES);
localparam BYTE_SELECT_BITS=$clog2(WIDTH_BYTES);
localparam MAXBURSTCOUNT=2**(BURSTCOUNT_WIDTH-1);
localparam _FIFO_DEPTH = MAXBURSTCOUNT + 10 + ((MEMORY_SIDE_MEM_LATENCY * WIDTH_BYTES + MWIDTH_BYTES - 1) / MWIDTH_BYTES);
localparam FIFO_DEPTH = 2**$clog2(_FIFO_DEPTH);
localparam FIFO_DEPTH_LOG2=$clog2(FIFO_DEPTH);
input clk;
input reset;
output o_stall;
input i_valid;
input i_nop;
input [AWIDTH-1:0] base_address;
input [31:0] size;
input i_stall;
output o_valid;
output [WIDTH-1:0] o_readdata;
output o_active;
output [AWIDTH-1:0] avm_address;
output [BURSTCOUNT_WIDTH-1:0] avm_burstcount;
output avm_read;
input [MWIDTH-1:0] avm_readdata;
input avm_waitrequest;
output [MWIDTH_BYTES-1:0] avm_byteenable;
input avm_readdatavalid;
wire f_avm_read;
wire f_avm_waitrequest;
wire [AWIDTH-1:0] f_avm_address;
wire [BURSTCOUNT_WIDTH-1:0] f_avm_burstcount;
acl_data_fifo #(
  .DATA_WIDTH(AWIDTH+BURSTCOUNT_WIDTH),
  .DEPTH(2),
  .IMPL("ll_reg")
) avm_buffer (
  .clock(clk),
  .resetn(!reset),
  .data_in( {f_avm_address,f_avm_burstcount} ),
  .valid_in( f_avm_read ),
  .data_out( {avm_address,avm_burstcount} ),
  .valid_out( avm_read ),
  .stall_in( avm_waitrequest ),
  .stall_out( f_avm_waitrequest )
);
wire [AWIDTH-1:0] aligned_base_address;
wire [AWIDTH-1:0] base_offset;
wire rm_done;
wire rm_valid;
wire rm_go;
wire [MWIDTH-1:0] rm_data;
wire [AWIDTH-1:0] rm_base_address;
wire [AWIDTH-1:0] rm_last_address;
wire [31:0] rm_size;
wire rm_ack;
reg [31:0] threads_rem;
reg i_reg_valid;
reg i_reg_nop;
reg [AWIDTH-1:0] reg_base_address;
reg [31:0] reg_size;
reg [31:0] reg_rm_size_partial;
wire [AWIDTH-1:0] aligned_base_address_partial;
wire [AWIDTH-1:0] base_offset_partial;
assign aligned_base_address_partial = ((base_address >> ALIGNMENT_ABITS) << ALIGNMENT_ABITS);
assign base_offset_partial = aligned_base_address_partial[MBYTE_SELECT_BITS-1:0];
always@(posedge clk or posedge reset)
begin
   if (reset == 1'b1)
   begin
      i_reg_valid <= 1'b0;
      reg_base_address <= 'x;
      reg_size <= 'x;
      reg_rm_size_partial <= 'x; 
      i_reg_nop <= 'x;
   end
   else
   begin
      if (!o_stall) 
      begin
         i_reg_nop <= i_nop;
         i_reg_valid <= i_valid;
         reg_base_address <= base_address;
         reg_size <= size;
         reg_rm_size_partial = (size << BYTE_SELECT_BITS) + base_offset_partial;
      end
   end
end
always@(posedge clk or posedge reset)
begin
   if(reset == 1'b1)
   begin
      threads_rem <= 0;
   end
   else
   begin
      threads_rem <= (rm_go ? reg_size : threads_rem) - (o_valid && !i_stall && !i_reg_nop);
   end
end
assign aligned_base_address = ((reg_base_address >> ALIGNMENT_ABITS) << ALIGNMENT_ABITS);
assign rm_base_address = ((aligned_base_address >> MBYTE_SELECT_BITS) << MBYTE_SELECT_BITS);
assign base_offset = aligned_base_address[MBYTE_SELECT_BITS-1:0];
assign rm_size = ((reg_rm_size_partial + MWIDTH_BYTES - 1) >> MBYTE_SELECT_BITS) << MBYTE_SELECT_BITS;
assign rm_go = i_reg_valid && (threads_rem == 0) && !rm_valid && !i_reg_nop;
lsu_burst_read_master #(
   .DATAWIDTH( MWIDTH ),
   .MAXBURSTCOUNT( MAXBURSTCOUNT ),
   .BURSTCOUNTWIDTH( BURSTCOUNT_WIDTH ),
   .BYTEENABLEWIDTH( MWIDTH_BYTES ),
   .ADDRESSWIDTH( AWIDTH ),
   .FIFODEPTH( FIFO_DEPTH ),
   .FIFODEPTH_LOG2( FIFO_DEPTH_LOG2 ),
   .FIFOUSEMEMORY( 1 )
) read_master (
   .clk(clk),
   .reset(reset),
   .o_active(o_active),
   .control_fixed_location( 1'b0 ),
   .control_read_base( rm_base_address ),
   .control_read_length( rm_size ),
   .control_go( rm_go ),
   .control_done( rm_done ),
   .control_early_done(),
   .user_read_buffer( rm_ack ),
   .user_buffer_data( rm_data ),
   .user_data_available( rm_valid ),
   .master_address( f_avm_address ),
   .master_read( f_avm_read ),
   .master_byteenable( avm_byteenable ),
   .master_readdata( avm_readdata ),
   .master_readdatavalid( avm_readdatavalid ),
   .master_burstcount( f_avm_burstcount ),
   .master_waitrequest( f_avm_waitrequest )
);
generate
if(MBYTE_SELECT_BITS != BYTE_SELECT_BITS)
begin
   reg [MBYTE_SELECT_BITS-BYTE_SELECT_BITS-1:0] wa_word_counter;
   always@(posedge clk or posedge reset)
   begin
      if(reset == 1'b1)
         wa_word_counter <= 0;
      else
         wa_word_counter <= rm_go ? aligned_base_address[MBYTE_SELECT_BITS-1:BYTE_SELECT_BITS] : wa_word_counter + (o_valid && !i_reg_nop && !i_stall);
   end
   assign rm_ack = (threads_rem==1 || &wa_word_counter) && (o_valid && !i_stall);
   assign o_readdata = rm_data[wa_word_counter * WIDTH +: WIDTH];
end
else
begin
   assign rm_ack = o_valid && !i_stall;
   assign o_readdata = rm_data;
end
endgenerate
assign o_valid = (i_reg_valid && (rm_valid || i_reg_nop));
assign o_stall = ((!rm_valid && !i_reg_nop) || i_stall) && i_reg_valid;
endmodule
module lsu_streaming_write
(
   clk, reset, o_stall, i_valid, i_stall, i_writedata, i_nop, i_byteenable, o_valid, 
   o_active, 
   base_address, size, avm_address, avm_burstcount, avm_write, avm_writeack, avm_writedata,
   avm_byteenable, avm_waitrequest
);
parameter AWIDTH=32;
parameter WIDTH_BYTES=32;
parameter MWIDTH_BYTES=32;
parameter ALIGNMENT_ABITS=6;
parameter BURSTCOUNT_WIDTH=6;
parameter KERNEL_SIDE_MEM_LATENCY=1;
parameter MEMORY_SIDE_MEM_LATENCY=1;  
parameter USE_BYTE_EN=0;
localparam WIDTH=8*WIDTH_BYTES;
localparam MWIDTH=8*MWIDTH_BYTES;
localparam MBYTE_SELECT_BITS=$clog2(MWIDTH_BYTES);
localparam BYTE_SELECT_BITS=$clog2(WIDTH_BYTES);
localparam MAXBURSTCOUNT=2**(BURSTCOUNT_WIDTH-1);
localparam __FIFO_DEPTH=2*MAXBURSTCOUNT + (MEMORY_SIDE_MEM_LATENCY * WIDTH + MWIDTH - 1) / MWIDTH;
localparam _FIFO_DEPTH= ( __FIFO_DEPTH > MAXBURSTCOUNT+4 ) ? __FIFO_DEPTH : MAXBURSTCOUNT+5;
localparam FIFO_DEPTH= 2**($clog2(_FIFO_DEPTH));
localparam FIFO_DEPTH_LOG2=$clog2(FIFO_DEPTH);
localparam NUM_FIFOS = MWIDTH / WIDTH;
localparam FIFO_ID_WIDTH = (NUM_FIFOS == 1) ? 1 : $clog2(NUM_FIFOS);  
input clk;
input reset;
output o_stall;
input i_valid;
input [WIDTH-1:0] i_writedata;
input i_nop;
input [AWIDTH-1:0] base_address;
input [31:0] size;
input [WIDTH_BYTES-1:0] i_byteenable;
output reg o_valid;
input i_stall;
output o_active;
wire o_valid_int;
wire i_stall_int;
output [AWIDTH-1:0] avm_address;
output [BURSTCOUNT_WIDTH-1:0] avm_burstcount;
output avm_write;
input avm_writeack;
output [MWIDTH-1:0] avm_writedata;
output [MWIDTH_BYTES-1:0] avm_byteenable;
input avm_waitrequest;
wire f_avm_write;
wire [MWIDTH-1:0] f_avm_writedata;
wire [MWIDTH_BYTES-1:0] f_avm_byteenable;
wire f_avm_waitrequest;
wire [AWIDTH-1:0] f_avm_address;
wire [BURSTCOUNT_WIDTH-1:0] f_avm_burstcount;
acl_data_fifo #(
  .DATA_WIDTH(AWIDTH+BURSTCOUNT_WIDTH+MWIDTH+MWIDTH_BYTES),
  .DEPTH(2),
  .IMPL("ll_reg")
) avm_buffer (
  .clock(clk),
  .resetn(!reset),
  .data_in( {f_avm_address,f_avm_burstcount,f_avm_byteenable,f_avm_writedata} ),
  .valid_in( f_avm_write ),
  .data_out( {avm_address,avm_burstcount,avm_byteenable,avm_writedata} ),
  .valid_out( avm_write ),
  .stall_in( avm_waitrequest ),
  .stall_out( f_avm_waitrequest )
);
wire [AWIDTH-1:0] aligned_base_address;
wire [AWIDTH-1:0] last_word_address;
wire [AWIDTH-1:0] base_offset;
wire go;
wire [AWIDTH-1:0] a_base_address;
wire [31:0] a_size;
wire c_done;
reg [31:0] c_length;
reg [31:0] c_length_reenc;
reg [31:0] ack_counter;
reg wm_first_xfer;
reg [AWIDTH-1:0] wm_address;
reg [BURSTCOUNT_WIDTH-1:0] wm_burstcount;
reg [BURSTCOUNT_WIDTH-1:0] wm_burst_counter;
reg fw_in_enable;
reg fw_out_enable;
reg [MWIDTH_BYTES-1:0] fw_byteenable;
wire lw_out_enable;
reg [MWIDTH_BYTES-1:0] lw_byteenable;
wire [AWIDTH-1:0] fsb_boundary_offset;
wire fsb_enable;
wire [BURSTCOUNT_WIDTH-1:0] fsb_count;
wire fsb_ready;
wire lsb_enable;
wire [BURSTCOUNT_WIDTH-1:0] lsb_count;
wire lsb_ready;
wire b_ready;
wire burst_begin;
wire [BURSTCOUNT_WIDTH-1:0] burst_count;
wire write_accepted;
wire [FIFO_ID_WIDTH-1:0] fifo_next_word;
reg [FIFO_ID_WIDTH-1:0] fifo_next_word_reg;
wire fifo_full;
wire [FIFO_DEPTH_LOG2-1:0] fifo_used;
wire [MWIDTH-1:0] fifo_data_out;
wire [MWIDTH_BYTES-1:0] fifo_byteenable_out;
wire [NUM_FIFOS-1:0][FIFO_DEPTH_LOG2-1:0] fifo_used_n;
wire [NUM_FIFOS-1:0] fifo_full_n;
wire [MWIDTH_BYTES-1:0] fifo_byteenable;
wire [NUM_FIFOS-1:0] fifo_wrreq_n;
reg [2:0] valid_in_d;
reg [31:0] threads_remaining_to_be_serviced;
reg [31:0] threads_rem;
always@(posedge clk or posedge reset)
begin
   if(reset == 1'b1)
   begin
      valid_in_d <= 3'b000;
      threads_rem <= 0;
   end
   else
   begin
      valid_in_d <= { (i_valid && !o_stall && !i_nop), valid_in_d[2:1] };
      threads_rem <= (go ? size : threads_rem) - valid_in_d[0];
   end
end
assign aligned_base_address = ((base_address >> ALIGNMENT_ABITS) << ALIGNMENT_ABITS);
assign last_word_address = aligned_base_address + ((size - 1) << BYTE_SELECT_BITS);
assign a_base_address = ((aligned_base_address >> MBYTE_SELECT_BITS) << MBYTE_SELECT_BITS);
assign base_offset = (aligned_base_address[MBYTE_SELECT_BITS-1:0] >> BYTE_SELECT_BITS);
assign a_size = (((((size + base_offset) << BYTE_SELECT_BITS) + {MBYTE_SELECT_BITS{1'b1}}) >> MBYTE_SELECT_BITS) << MBYTE_SELECT_BITS);
assign go = i_valid && !o_stall && !i_nop && c_done;
always@(posedge clk or posedge reset)
begin
   if(reset == 1'b1)
   begin
      wm_first_xfer <= 1'b0;
      wm_address <= {AWIDTH{1'b0}};
      c_length <= {32{1'b0}};
      c_length_reenc <= {32{1'b1}};
      wm_burstcount <= {BURSTCOUNT_WIDTH{1'b0}};
      wm_burst_counter <= {BURSTCOUNT_WIDTH{1'b0}};
      fw_byteenable <= {MWIDTH_BYTES{1'b0}};
      lw_byteenable <= {MWIDTH_BYTES{1'b0}};
      fw_in_enable <= 1'b0;
      fw_out_enable <= 1'b0;
      threads_remaining_to_be_serviced <= {32{1'b0}};
   end
   else
   begin
      wm_burstcount <= burst_begin ? burst_count : wm_burstcount;
      lw_byteenable <= (fifo_byteenable[0] ? {MWIDTH_BYTES{1'b0}} : lw_byteenable) | fifo_byteenable;
      if(go == 1'b1)
      begin
         wm_first_xfer <= 1'b1;
         wm_address <= a_base_address;
         c_length <= a_size;
         c_length_reenc <= a_size-1;
         wm_burst_counter <= {BURSTCOUNT_WIDTH{1'b0}};
         fw_byteenable <= fifo_byteenable;
         if(NUM_FIFOS > 1)
         begin
            fw_in_enable <= (!(i_valid && !o_stall && !i_nop) || (fifo_next_word != {FIFO_ID_WIDTH{1'b1}}));
            fw_out_enable <= 1'b1;
         end
         threads_remaining_to_be_serviced <= size-2;
      end
      else
      begin
         wm_first_xfer <= !burst_begin && wm_first_xfer;
         wm_address <= (!wm_first_xfer && burst_begin) ? (wm_address + (wm_burstcount << MBYTE_SELECT_BITS)) : (wm_address);
         c_length <= write_accepted ? c_length - MWIDTH_BYTES : c_length;
         c_length_reenc <= write_accepted ? c_length_reenc - MWIDTH_BYTES : c_length_reenc;
         wm_burst_counter <= burst_begin ? burst_count : (wm_burst_counter - write_accepted);
         fw_byteenable <= fw_byteenable | ({MWIDTH_BYTES{fw_in_enable}} & fifo_byteenable);
         fw_in_enable <= fw_in_enable && (!(i_valid && !o_stall && !i_nop) || (fifo_next_word != {FIFO_ID_WIDTH{1'b1}}));
         fw_out_enable <= fw_out_enable && !write_accepted;
         threads_remaining_to_be_serviced <= (i_valid && !o_stall && !i_nop) ? (threads_remaining_to_be_serviced - 1) : threads_remaining_to_be_serviced;
      end
   end
end
assign lw_out_enable = (c_length <= MWIDTH_BYTES);
assign c_done = c_length_reenc[31];
assign fsb_boundary_offset = (wm_address >> MBYTE_SELECT_BITS) & (MAXBURSTCOUNT-1);
assign fsb_enable = (fsb_boundary_offset != 0) && wm_first_xfer;
assign fsb_count = (fsb_boundary_offset[0]) ? 1 : 
                   (((MAXBURSTCOUNT - fsb_boundary_offset) < (c_length >> MBYTE_SELECT_BITS)) ?
                   (MAXBURSTCOUNT - fsb_boundary_offset) : lsb_count);
assign fsb_ready = (fifo_used > fsb_count) || (fifo_used == fsb_count) && (wm_burst_counter == 0);
assign lsb_enable = (c_length <= (MAXBURSTCOUNT << MBYTE_SELECT_BITS));
assign lsb_count = (c_length >> MBYTE_SELECT_BITS);
assign lsb_ready = (threads_rem == 0);
assign b_ready = (fifo_used > MAXBURSTCOUNT) || ((fifo_used == MAXBURSTCOUNT) && (wm_burst_counter == 0));
assign burst_begin = ((fsb_enable && fsb_ready) || (lsb_enable && lsb_ready) || (b_ready)) &&
                     !c_done && ((wm_burst_counter == 0) || ((wm_burst_counter == 1) && 
                     !f_avm_waitrequest && (c_length > (MAXBURSTCOUNT << MBYTE_SELECT_BITS))));
assign burst_count = fsb_enable ? fsb_count :
                     lsb_enable ? lsb_count : MAXBURSTCOUNT;
assign write_accepted = f_avm_write && !f_avm_waitrequest;
assign fifo_next_word = go ? base_offset : fifo_next_word_reg;
always@(posedge clk or posedge reset)
begin
   if(reset == 1'b1)
   begin
      fifo_next_word_reg <= {FIFO_ID_WIDTH{1'b0}};
   end
   else
   begin
      if(NUM_FIFOS > 1)
         fifo_next_word_reg <= (i_valid && !o_stall) ? fifo_next_word + 1 : fifo_next_word;
   end
end
wire [NUM_FIFOS-1:0] fifo_empty;
wire [NUM_FIFOS-1:0] fifo_read_enable;
genvar n;
generate
   for(n=0; n<NUM_FIFOS; n++)
   begin : fifo_n
      if (USE_BYTE_EN)
      begin
         scfifo #(
           .lpm_width( WIDTH+WIDTH_BYTES ),
           .lpm_widthu( FIFO_DEPTH_LOG2 ),
           .lpm_numwords( FIFO_DEPTH ),
           .lpm_showahead( "ON" ),
           .almost_full_value( FIFO_DEPTH - 2 ),
           .use_eab( "ON" ),
           .add_ram_output_register( "OFF" ),
           .underflow_checking( "OFF" ),
           .overflow_checking( "OFF" )
        ) data_fifo (
           .clock( clk ),
           .aclr( reset ),
           .usedw( fifo_used_n[n] ),
           .data( {i_writedata,i_byteenable }),
           .almost_full( fifo_full_n[n] ),
           .q( { fifo_data_out[n*WIDTH +: WIDTH],fifo_byteenable_out[n*WIDTH_BYTES +: WIDTH_BYTES]} ),
           .rdreq( write_accepted &&  fifo_read_enable[n] ),
           .wrreq( fifo_wrreq_n[n] ),
           .almost_empty(),
           .empty(fifo_empty[n]),
           .full(),
           .sclr()
        );
      end else begin
        scfifo #(
           .lpm_width( WIDTH ),
           .lpm_widthu( FIFO_DEPTH_LOG2 ),
           .lpm_numwords( FIFO_DEPTH ),
           .lpm_showahead( "ON" ),
           .almost_full_value( FIFO_DEPTH - 2 ),
           .use_eab( "ON" ),
           .add_ram_output_register( "OFF" ),
           .underflow_checking( "OFF" ),
           .overflow_checking( "OFF" )
        ) data_fifo (
           .clock( clk ),
           .aclr( reset ),
           .usedw( fifo_used_n[n] ),
           .data( i_writedata ),
           .almost_full( fifo_full_n[n] ),
           .q( fifo_data_out[n*WIDTH +: WIDTH] ),
           .rdreq( write_accepted &&  fifo_read_enable[n] ),
           .wrreq( fifo_wrreq_n[n] ),
           .almost_empty(),
           .empty(fifo_empty[n]),
           .full(),
           .sclr()
        );
        assign fifo_byteenable_out[n*WIDTH_BYTES +: WIDTH_BYTES] = {WIDTH_BYTES{ 1'b1}};     
      end
      assign fifo_wrreq_n[n] = i_valid && !o_stall && !i_nop && (fifo_next_word == n);
      assign fifo_byteenable[n*WIDTH_BYTES +: WIDTH_BYTES] = {WIDTH_BYTES{ fifo_wrreq_n[n] }};
      assign fifo_read_enable[n] = fw_out_enable ? fw_byteenable[n*WIDTH_BYTES] : (lw_out_enable ? lw_byteenable[n*WIDTH_BYTES] :1'b1);
   end
endgenerate
assign fifo_full = fifo_full_n[NUM_FIFOS-1];
assign fifo_used = fifo_used_n[NUM_FIFOS-1];
assign f_avm_write = !c_done && (wm_burst_counter != 0);
assign f_avm_address = wm_address;
assign f_avm_burstcount = wm_burstcount;
assign f_avm_writedata = fifo_data_out;
assign f_avm_byteenable = fw_out_enable ? fw_byteenable & fifo_byteenable_out:
                       (lw_out_enable ? lw_byteenable : {MWIDTH_BYTES{1'b1}}) & fifo_byteenable_out ;
assign o_stall = fifo_full || i_stall_int || (!c_done && threads_remaining_to_be_serviced[31]);
assign o_valid_int = i_valid && !fifo_full && !o_stall;
assign i_stall_int = o_valid && i_stall;
always@(posedge clk or posedge reset)
begin
   if(reset == 1'b1)
      o_valid <= {1'b0};
   else if (!i_stall_int)
      o_valid = o_valid_int;
   else
      o_valid = o_valid;
end
assign o_active = |(~fifo_empty);
endmodule
