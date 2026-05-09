module lsu_top
(
    clock, clock2x, resetn, stream_base_addr, stream_size, stream_reset, i_atomic_op, o_stall, 
    i_valid, i_address, i_writedata, i_cmpdata, i_predicate, i_bitwiseor, i_stall, o_valid, o_readdata, avm_address, 
    avm_read, avm_readdata, avm_write, avm_writeack, avm_writedata, avm_byteenable, 
    avm_waitrequest, avm_readdatavalid, avm_burstcount,
    o_active,
    o_input_fifo_depth,
    o_writeack,
    i_byteenable,
    flush,
    profile_bw, profile_bw_incr,
    profile_total_ivalid,
    profile_total_req,
    profile_i_stall_count,
    profile_o_stall_count,
    profile_avm_readwrite_count,
    profile_avm_burstcount_total, profile_avm_burstcount_total_incr,
    profile_req_cache_hit_count,
    profile_extra_unaligned_reqs,
    profile_avm_stall
);
parameter STYLE="PIPELINED"; 
parameter AWIDTH=32;         
parameter ATOMIC_WIDTH=6;    
parameter WIDTH_BYTES=4;     
parameter MWIDTH_BYTES=32;   
parameter WRITEDATAWIDTH_BYTES=32;  
parameter ALIGNMENT_BYTES=2; 
parameter READ=1;            
parameter ATOMIC=0;          
parameter BURSTCOUNT_WIDTH=6;
parameter KERNEL_SIDE_MEM_LATENCY=1;  
parameter MEMORY_SIDE_MEM_LATENCY=1;  
parameter USE_WRITE_ACK=0;   
parameter USECACHING=0;
parameter USE_BYTE_EN=0;
parameter CACHESIZE=1024;
parameter PROFILE_ADDR_TOGGLE=0;
parameter USEINPUTFIFO=1;        
parameter USEOUTPUTFIFO=1;       
parameter FORCE_NOP_SUPPORT=0;   
parameter HIGH_FMAX=1;       
parameter ACL_PROFILE=0;      
parameter ACL_PROFILE_INCREMENT_WIDTH=32;
parameter ADDRSPACE=0;
parameter ENABLE_BANKED_MEMORY=0;
parameter ABITS_PER_LMEM_BANK=0; 
parameter NUMBER_BANKS=1;        
parameter LMEM_ADDR_PERMUTATION_STYLE=0; 
localparam BANK_SELECT_BITS = (ENABLE_BANKED_MEMORY==1) ? $clog2(NUMBER_BANKS) : 1; 
localparam HACKED_ABITS_PER_LMEM_BANK = (ENABLE_BANKED_MEMORY==1) ? ABITS_PER_LMEM_BANK : $clog2(MWIDTH_BYTES)+1;
parameter WIDTH=8*WIDTH_BYTES;                      
parameter MWIDTH=8*MWIDTH_BYTES;                    
parameter WRITEDATAWIDTH=8*WRITEDATAWIDTH_BYTES;              
localparam ALIGNMENT_ABITS=$clog2(ALIGNMENT_BYTES); 
localparam LSU_CAPACITY=256;   
localparam WIDE_LSU = (WIDTH > MWIDTH); 
parameter INPUTFIFO_USEDW_MAXBITS=8;
localparam ATOMIC_PIPELINED_LSU=(STYLE=="ATOMIC-PIPELINED");
localparam PIPELINED_LSU=( (STYLE=="PIPELINED") || (STYLE=="BASIC-COALESCED") || (STYLE=="BURST-COALESCED") || (STYLE=="BURST-NON-ALIGNED") );
localparam SUPPORTS_NOP= (STYLE=="STREAMING") || (STYLE=="SEMI-STREAMING") || (STYLE=="BURST-NON-ALIGNED") || (STYLE=="BURST-COALESCED") ||  (FORCE_NOP_SUPPORT==1);
localparam SUPPORTS_BURSTS=( (STYLE=="STREAMING") || (STYLE=="BURST-COALESCED") || (STYLE=="SEMI-STREAMING") || (STYLE=="BURST-NON-ALIGNED") );
input clock;
input clock2x;
input resetn;
input flush;
input [AWIDTH-1:0] stream_base_addr;
input [31:0] stream_size;
input stream_reset;
input [WIDTH-1:0] i_cmpdata; 
input [ATOMIC_WIDTH-1:0] i_atomic_op;
output o_stall;
input i_valid;
input [AWIDTH-1:0] i_address;
input [WIDTH-1:0] i_writedata;
input i_predicate;
input [AWIDTH-1:0] i_bitwiseor;
input [WIDTH_BYTES-1:0] i_byteenable;
input i_stall;
output o_valid;
output [WIDTH-1:0] o_readdata;
output [AWIDTH-1:0] avm_address;
output avm_read;
input [WRITEDATAWIDTH-1:0] avm_readdata;
output avm_write;
input avm_writeack;
output o_writeack;
output [WRITEDATAWIDTH-1:0] avm_writedata;
output [WRITEDATAWIDTH_BYTES-1:0] avm_byteenable;
input avm_waitrequest;
input avm_readdatavalid;
output [BURSTCOUNT_WIDTH-1:0] avm_burstcount;
output reg o_active;
output [INPUTFIFO_USEDW_MAXBITS-1:0] o_input_fifo_depth;
output logic profile_bw;
output logic [ACL_PROFILE_INCREMENT_WIDTH-1:0] profile_bw_incr;
output logic profile_total_ivalid;
output logic profile_total_req;
output logic profile_i_stall_count;
output logic profile_o_stall_count;
output logic profile_avm_readwrite_count;
output logic profile_avm_burstcount_total;
output logic [ACL_PROFILE_INCREMENT_WIDTH-1:0] profile_avm_burstcount_total_incr;
output logic profile_req_cache_hit_count;
output logic profile_extra_unaligned_reqs;
output logic profile_avm_stall;
reg [1:0]     sync_rstn_MS  ;
wire          sync_rstn;
assign sync_rstn = sync_rstn_MS[1];
always @(posedge clock or negedge resetn) begin
  if(!resetn) sync_rstn_MS <= 2'b00;
  else sync_rstn_MS <= {sync_rstn_MS[0], 1'b1};
end
generate
if(WIDE_LSU) begin
  lsu_wide_wrapper lsu_wide (
	.clock(clock),
	.clock2x(clock2x),
	.resetn(sync_rstn),
	.flush(flush),
	.stream_base_addr(stream_base_addr),
	.stream_size(stream_size),
	.stream_reset(stream_reset),
	.o_stall(o_stall),
	.i_valid(i_valid),
	.i_address(i_address),
	.i_writedata(i_writedata),
	.i_cmpdata(i_cmpdata),
	.i_predicate(i_predicate),
	.i_bitwiseor(i_bitwiseor),
	.i_byteenable(i_byteenable),
	.i_stall(i_stall),
	.o_valid(o_valid),
	.o_readdata(o_readdata),
	.o_input_fifo_depth(o_input_fifo_depth),
	.o_writeack(o_writeack),
	.i_atomic_op(i_atomic_op),
	.o_active(o_active),
	.avm_address(avm_address),
	.avm_read(avm_read),
	.avm_readdata(avm_readdata),
	.avm_write(avm_write),
	.avm_writeack(avm_writeack),
	.avm_burstcount(avm_burstcount),
	.avm_writedata(avm_writedata),
	.avm_byteenable(avm_byteenable),
	.avm_waitrequest(avm_waitrequest),
	.avm_readdatavalid(avm_readdatavalid),
	.profile_req_cache_hit_count(profile_req_cache_hit_count),
	.profile_extra_unaligned_reqs(profile_extra_unaligned_reqs)
);
  defparam lsu_wide.STYLE = STYLE;
  defparam lsu_wide.AWIDTH = AWIDTH;
  defparam lsu_wide.ATOMIC_WIDTH = ATOMIC_WIDTH;
  defparam lsu_wide.WIDTH_BYTES = WIDTH_BYTES;
  defparam lsu_wide.MWIDTH_BYTES = MWIDTH_BYTES;
  defparam lsu_wide.WRITEDATAWIDTH_BYTES = WRITEDATAWIDTH_BYTES;
  defparam lsu_wide.ALIGNMENT_BYTES = ALIGNMENT_BYTES;
  defparam lsu_wide.READ = READ;
  defparam lsu_wide.ATOMIC = ATOMIC;
  defparam lsu_wide.BURSTCOUNT_WIDTH = BURSTCOUNT_WIDTH;
  defparam lsu_wide.KERNEL_SIDE_MEM_LATENCY = KERNEL_SIDE_MEM_LATENCY;
  defparam lsu_wide.MEMORY_SIDE_MEM_LATENCY = MEMORY_SIDE_MEM_LATENCY;
  defparam lsu_wide.USE_WRITE_ACK = USE_WRITE_ACK;
  defparam lsu_wide.USECACHING = USECACHING;
  defparam lsu_wide.USE_BYTE_EN = USE_BYTE_EN;
  defparam lsu_wide.CACHESIZE = CACHESIZE;
  defparam lsu_wide.PROFILE_ADDR_TOGGLE = PROFILE_ADDR_TOGGLE;
  defparam lsu_wide.USEINPUTFIFO = USEINPUTFIFO;
  defparam lsu_wide.USEOUTPUTFIFO = USEOUTPUTFIFO;
  defparam lsu_wide.FORCE_NOP_SUPPORT = FORCE_NOP_SUPPORT;
  defparam lsu_wide.HIGH_FMAX = HIGH_FMAX;
  defparam lsu_wide.ACL_PROFILE = ACL_PROFILE;
  defparam lsu_wide.ACL_PROFILE_INCREMENT_WIDTH = ACL_PROFILE_INCREMENT_WIDTH;
  defparam lsu_wide.ENABLE_BANKED_MEMORY = ENABLE_BANKED_MEMORY;
  defparam lsu_wide.ABITS_PER_LMEM_BANK = ABITS_PER_LMEM_BANK;
  defparam lsu_wide.NUMBER_BANKS = NUMBER_BANKS;
  defparam lsu_wide.WIDTH = WIDTH;
  defparam lsu_wide.MWIDTH = MWIDTH;  
  defparam lsu_wide.WRITEDATAWIDTH = WRITEDATAWIDTH;
  defparam lsu_wide.INPUTFIFO_USEDW_MAXBITS = INPUTFIFO_USEDW_MAXBITS;
  defparam lsu_wide.LMEM_ADDR_PERMUTATION_STYLE = LMEM_ADDR_PERMUTATION_STYLE;
  defparam lsu_wide.ADDRSPACE = ADDRSPACE;
  if(ACL_PROFILE==1)
  begin
   reg [BURSTCOUNT_WIDTH-1:0] profile_remaining_writeburst_count;
   wire active_write_burst;
   assign active_write_burst = (profile_remaining_writeburst_count != {BURSTCOUNT_WIDTH{1'b0}});
   always@(posedge clock or negedge sync_rstn)
     if (!sync_rstn)
        profile_remaining_writeburst_count <= {BURSTCOUNT_WIDTH{1'b0}};
     else if(avm_write & ~avm_waitrequest & ~active_write_burst)
        profile_remaining_writeburst_count <= avm_burstcount - 1;
     else if(~avm_waitrequest & active_write_burst)
        profile_remaining_writeburst_count <= profile_remaining_writeburst_count - 1;      
     assign profile_bw = (READ==1) ? avm_readdatavalid : (avm_write & ~avm_waitrequest);
     assign profile_bw_incr = MWIDTH_BYTES;
     assign profile_total_ivalid = (i_valid & ~o_stall);
     assign profile_total_req = (i_valid & ~i_predicate & ~o_stall);
     assign profile_i_stall_count = (i_stall & o_valid);
     assign profile_o_stall_count = (o_stall & i_valid);
     assign profile_avm_readwrite_count = ((avm_read | avm_write) & ~avm_waitrequest & ~active_write_burst);
     assign profile_avm_burstcount_total = ((avm_read | avm_write) & ~avm_waitrequest & ~active_write_burst);
     assign profile_avm_burstcount_total_incr = avm_burstcount;
     assign profile_avm_stall = ((avm_read | avm_write) & avm_waitrequest);
  end
  else begin
     assign profile_bw = 1'b0;
     assign profile_bw_incr = {ACL_PROFILE_INCREMENT_WIDTH{1'b0}};
     assign profile_total_ivalid = 1'b0;
     assign profile_total_req = 1'b0;
     assign profile_i_stall_count = 1'b0;
     assign profile_o_stall_count = 1'b0;
     assign profile_avm_readwrite_count = 1'b0;
     assign profile_avm_burstcount_total = 1'b0;
     assign profile_avm_burstcount_total_incr = {ACL_PROFILE_INCREMENT_WIDTH{1'b0}};
     assign profile_avm_stall = 1'b0;
  end
end
else begin 
wire lsu_active;
assign o_writeack = avm_writeack;
localparam MWIDTH_BYTES_CLIP = (MWIDTH_BYTES==1) ? 2 : MWIDTH_BYTES; 
function [AWIDTH-1:0] permute_addr ( input [AWIDTH-1:0] addr);
  if (ENABLE_BANKED_MEMORY==1)
  begin
    if (MWIDTH_BYTES==1) begin
      permute_addr= {
        addr[(AWIDTH-1) : (HACKED_ABITS_PER_LMEM_BANK+BANK_SELECT_BITS)], 
        addr[($clog2(MWIDTH_BYTES)+BANK_SELECT_BITS-1) : $clog2(MWIDTH_BYTES)], 
        addr[(HACKED_ABITS_PER_LMEM_BANK + BANK_SELECT_BITS-1) : ($clog2(MWIDTH_BYTES) + BANK_SELECT_BITS)]
        };
    end
    else begin
      permute_addr= {
        addr[(AWIDTH-1) : (HACKED_ABITS_PER_LMEM_BANK+BANK_SELECT_BITS)], 
        addr[($clog2(MWIDTH_BYTES)+BANK_SELECT_BITS-1) : $clog2(MWIDTH_BYTES)], 
        addr[(HACKED_ABITS_PER_LMEM_BANK + BANK_SELECT_BITS-1) : ($clog2(MWIDTH_BYTES) + BANK_SELECT_BITS)],
        addr[($clog2(MWIDTH_BYTES_CLIP)-1) : 0]         
        };
    end
   end
   else
   begin
     permute_addr= addr;
   end
endfunction
wire [AWIDTH-1:0] avm_address_raw;
assign avm_address=permute_addr(avm_address_raw);
if(ATOMIC==0) begin
  if(READ==1)
  begin
     assign avm_write = 1'b0;
     assign avm_writedata = {MWIDTH{1'b0}}; 
  end
  else 
  begin
    assign avm_read = 1'b0;
  end
end
else begin 
  assign avm_write = 1'b0;
end
wire lsu_writeack;  
if(USE_WRITE_ACK==1)
begin
   assign lsu_writeack = avm_writeack;
end
else
begin
   assign lsu_writeack = avm_write && !avm_waitrequest;
end
wire lsu_i_valid;
wire lsu_o_valid;
wire lsu_i_stall;
wire lsu_o_stall;
wire [AWIDTH-1:0] address;
wire nop;
if(SUPPORTS_NOP)
begin
   assign lsu_i_valid = i_valid;
   assign lsu_i_stall = i_stall;
   assign o_valid = lsu_o_valid;
   assign o_stall = lsu_o_stall;
   assign address = i_address | i_bitwiseor;
end
else if(PIPELINED_LSU || ATOMIC_PIPELINED_LSU)
begin
   wire nop_fifo_empty;
   wire nop_fifo_full;
   wire nop_next;
   assign nop = i_predicate;
   assign address = i_address | i_bitwiseor;
   if(KERNEL_SIDE_MEM_LATENCY <= 64)
   begin
      acl_ll_fifo #(
         .WIDTH(1),
         .DEPTH(KERNEL_SIDE_MEM_LATENCY+1)
      ) nop_fifo (
         .clk(clock),
         .reset(~sync_rstn),
         .data_in(nop),
         .write(i_valid && !o_stall),
         .data_out(nop_next),
         .read(o_valid && !i_stall),
         .full(nop_fifo_full),
         .empty(nop_fifo_empty)
      );
   end
   else
   begin
      scfifo #(
         .add_ram_output_register( "OFF" ),
         .intended_device_family( "Stratix IV" ),
         .lpm_numwords( KERNEL_SIDE_MEM_LATENCY+1 ),
         .lpm_showahead( "ON" ),
         .lpm_type( "scfifo" ),
         .lpm_width( 1 ),
         .lpm_widthu( $clog2(KERNEL_SIDE_MEM_LATENCY+1) ),
         .overflow_checking( "OFF" ),
         .underflow_checking( "OFF" )
      ) nop_fifo (
         .clock(clock),
         .data(nop),
         .rdreq(o_valid && !i_stall),
         .wrreq(i_valid && !o_stall),
         .empty(nop_fifo_empty),
         .full(nop_fifo_full),
         .q(nop_next),
         .aclr(!sync_rstn),
         .almost_full(),
         .almost_empty(),
         .usedw(),
         .sclr()
      );
   end
   assign lsu_i_valid = !nop && i_valid && !nop_fifo_full;
   assign lsu_i_stall = nop_fifo_empty || nop_next || i_stall;
   assign o_valid = (lsu_o_valid || nop_next) && !nop_fifo_empty;
   assign o_stall = nop_fifo_full || lsu_o_stall;
end
else
begin
   reg pending;
   always@(posedge clock or negedge sync_rstn)
   begin
      if(sync_rstn == 1'b0)
         pending <= 1'b0;
      else
         pending <= pending ? ((lsu_i_valid && !lsu_o_stall) || !(lsu_o_valid && !lsu_i_stall)) :
                              ((lsu_i_valid && !lsu_o_stall) && !(lsu_o_valid && !lsu_i_stall));
   end
   assign nop = i_predicate;
   assign address = i_address | i_bitwiseor;
   assign lsu_i_valid = i_valid && !nop;
   assign lsu_i_stall = i_stall;
   assign o_valid = lsu_o_valid || (!pending && i_valid && nop);
   assign o_stall = lsu_o_stall || (pending && nop);
end
if(!SUPPORTS_BURSTS)
begin
   assign avm_burstcount = 1;
end
wire req_cache_hit_count;
wire extra_unaligned_reqs;
if(READ==0 || STYLE!="BURST-NON-ALIGNED")
assign extra_unaligned_reqs = 1'b0;
if(READ==0 || (STYLE!="BURST-COALESCED" && STYLE!="BURST-NON-ALIGNED" && STYLE!="SEMI-STREAMING"))
assign req_cache_hit_count = 1'b0;
if(STYLE=="SIMPLE")
begin
    if(READ == 1)
    begin
        lsu_simple_read #(
            .AWIDTH(AWIDTH),
            .WIDTH_BYTES(WIDTH_BYTES),
            .MWIDTH_BYTES(MWIDTH_BYTES),
            .ALIGNMENT_ABITS(ALIGNMENT_ABITS),
            .HIGH_FMAX(HIGH_FMAX)
        ) simple_read (
            .clk(clock),
            .reset(!sync_rstn),
            .o_stall(lsu_o_stall),
            .i_valid(lsu_i_valid),
            .i_address(address),
            .i_stall(lsu_i_stall),
            .o_valid(lsu_o_valid),
            .o_active(lsu_active),
            .o_readdata(o_readdata),
            .avm_address(avm_address_raw),
            .avm_read(avm_read),
            .avm_readdata(avm_readdata),
            .avm_waitrequest(avm_waitrequest),
            .avm_byteenable(avm_byteenable),
            .avm_readdatavalid(avm_readdatavalid)
        );
    end
    else
    begin
        lsu_simple_write #(
            .AWIDTH(AWIDTH),
            .WIDTH_BYTES(WIDTH_BYTES),
            .MWIDTH_BYTES(MWIDTH_BYTES),
            .USE_BYTE_EN(USE_BYTE_EN),
            .ALIGNMENT_ABITS(ALIGNMENT_ABITS)
        ) simple_write (
            .clk(clock),
            .reset(!sync_rstn),
            .o_stall(lsu_o_stall),
            .i_valid(lsu_i_valid),
            .i_address(address),
            .i_writedata(i_writedata),
            .i_stall(lsu_i_stall),
            .o_valid(lsu_o_valid),
            .i_byteenable(i_byteenable),
            .o_active(lsu_active),
            .avm_address(avm_address_raw),
            .avm_write(avm_write),
            .avm_writeack(lsu_writeack),
            .avm_writedata(avm_writedata),
            .avm_byteenable(avm_byteenable),
            .avm_waitrequest(avm_waitrequest)
        );
    end
end
else if(STYLE=="PIPELINED")
begin
    wire sub_o_stall;
    if(USEINPUTFIFO == 0) begin : GEN_0
      assign lsu_o_stall = sub_o_stall & !i_predicate;
    end
    else begin : GEN_1
      assign lsu_o_stall = sub_o_stall;
    end 
    if(READ == 1)
    begin
        lsu_pipelined_read #(
            .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
            .AWIDTH(AWIDTH),
            .WIDTH_BYTES(WIDTH_BYTES),
            .MWIDTH_BYTES(MWIDTH_BYTES),
            .ALIGNMENT_ABITS(ALIGNMENT_ABITS),
            .USEINPUTFIFO(USEINPUTFIFO),
            .USEOUTPUTFIFO(USEOUTPUTFIFO)
        ) pipelined_read (
            .clk(clock),
            .reset(!sync_rstn),
            .o_stall(sub_o_stall),
            .i_valid(lsu_i_valid),
            .i_address(address),
            .i_stall(lsu_i_stall),
            .o_valid(lsu_o_valid),
            .o_readdata(o_readdata),
            .o_input_fifo_depth(o_input_fifo_depth),
            .o_active(lsu_active),
            .avm_address(avm_address_raw),
            .avm_read(avm_read),
            .avm_readdata(avm_readdata),
            .avm_waitrequest(avm_waitrequest),
            .avm_byteenable(avm_byteenable),
            .avm_readdatavalid(avm_readdatavalid)
        );
    end
    else
    begin
        lsu_pipelined_write #(
            .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
            .AWIDTH(AWIDTH),
            .WIDTH_BYTES(WIDTH_BYTES),
            .MWIDTH_BYTES(MWIDTH_BYTES),
            .USE_BYTE_EN(USE_BYTE_EN),
            .ALIGNMENT_ABITS(ALIGNMENT_ABITS),
            .USEINPUTFIFO(USEINPUTFIFO)
        ) pipelined_write (
            .clk(clock),
            .reset(!sync_rstn),
            .o_stall(sub_o_stall),
            .i_valid(lsu_i_valid),
            .i_address(address),
            .i_byteenable(i_byteenable),
            .i_writedata(i_writedata),
            .i_stall(lsu_i_stall),
            .o_valid(lsu_o_valid),
            .o_input_fifo_depth(o_input_fifo_depth),
            .o_active(lsu_active),
            .avm_address(avm_address_raw),
            .avm_write(avm_write),
            .avm_writeack(lsu_writeack),
            .avm_writedata(avm_writedata),
            .avm_byteenable(avm_byteenable),
            .avm_waitrequest(avm_waitrequest)
        );
    end
end
else if(STYLE=="ATOMIC-PIPELINED")
begin
    lsu_atomic_pipelined #(
           .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
           .AWIDTH(AWIDTH),
           .WIDTH_BYTES(WIDTH_BYTES),
           .MWIDTH_BYTES(MWIDTH_BYTES),
           .WRITEDATAWIDTH_BYTES(WRITEDATAWIDTH_BYTES),
           .ALIGNMENT_ABITS(ALIGNMENT_ABITS),
           .USEINPUTFIFO(USEINPUTFIFO),
           .USEOUTPUTFIFO(USEOUTPUTFIFO),
           .ATOMIC_WIDTH(ATOMIC_WIDTH)
    ) atomic_pipelined (
           .clk(clock),
           .reset(!sync_rstn),
           .o_stall(lsu_o_stall),
           .i_valid(lsu_i_valid),
           .i_address(address),
           .i_stall(lsu_i_stall),
           .o_valid(lsu_o_valid),
           .o_readdata(o_readdata),
           .o_input_fifo_depth(o_input_fifo_depth),
           .o_active(lsu_active),
           .avm_address(avm_address_raw),
           .avm_read(avm_read),
           .avm_readdata(avm_readdata),
           .avm_waitrequest(avm_waitrequest),
           .avm_byteenable(avm_byteenable),
           .avm_readdatavalid(avm_readdatavalid),
           .i_atomic_op(i_atomic_op),
           .i_writedata(i_writedata),
           .i_cmpdata(i_cmpdata),
           .avm_writeack(lsu_writeack),
           .avm_writedata(avm_writedata)
    );
end
else if(STYLE=="BASIC-COALESCED")
begin
    if(READ == 1)
    begin
        lsu_basic_coalesced_read #(
            .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
            .AWIDTH(AWIDTH),
            .WIDTH_BYTES(WIDTH_BYTES),
            .MWIDTH_BYTES(MWIDTH_BYTES),
            .ALIGNMENT_ABITS(ALIGNMENT_ABITS)
        ) basic_coalesced_read (
            .clk(clock),
            .reset(!sync_rstn),
            .o_stall(lsu_o_stall),
            .i_valid(lsu_i_valid),
            .i_address(address),
            .i_stall(lsu_i_stall),
            .o_valid(lsu_o_valid),
            .o_readdata(o_readdata),
            .avm_address(avm_address_raw),
            .avm_read(avm_read),
            .avm_readdata(avm_readdata),
            .avm_waitrequest(avm_waitrequest),
            .avm_byteenable(avm_byteenable),
            .avm_readdatavalid(avm_readdatavalid)
        );
    end
    else
    begin
        lsu_basic_coalesced_write #(
            .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
            .AWIDTH(AWIDTH),
            .WIDTH_BYTES(WIDTH_BYTES),
            .USE_BYTE_EN(USE_BYTE_EN),
            .MWIDTH_BYTES(MWIDTH_BYTES),
            .ALIGNMENT_ABITS(ALIGNMENT_ABITS)
        ) basic_coalesced_write (
            .clk(clock),
            .reset(!sync_rstn),
            .o_stall(lsu_o_stall),
            .i_valid(lsu_i_valid),
            .i_address(address),
            .i_writedata(i_writedata),
            .i_byteenable(i_byteenable),
            .i_stall(lsu_i_stall),
            .o_valid(lsu_o_valid),
            .o_active(lsu_active),
            .avm_address(avm_address_raw),
            .avm_write(avm_write),
            .avm_writeack(lsu_writeack),
            .avm_writedata(avm_writedata),
            .avm_byteenable(avm_byteenable),
            .avm_waitrequest(avm_waitrequest)
        );
    end
end
else if(STYLE=="BURST-COALESCED")
begin
    if(READ == 1)
    begin
        lsu_bursting_read #(
            .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
            .MEMORY_SIDE_MEM_LATENCY(MEMORY_SIDE_MEM_LATENCY),
            .AWIDTH(AWIDTH),
            .WIDTH_BYTES(WIDTH_BYTES),
            .MWIDTH_BYTES(MWIDTH_BYTES),
            .ALIGNMENT_ABITS(ALIGNMENT_ABITS),
            .BURSTCOUNT_WIDTH(BURSTCOUNT_WIDTH),
            .USECACHING(USECACHING),
            .HIGH_FMAX(HIGH_FMAX),
            .ACL_PROFILE(ACL_PROFILE),
            .CACHE_SIZE_N(CACHESIZE)
        ) bursting_read (
            .clk(clock),
            .clk2x(clock2x),
            .reset(!sync_rstn),
            .flush(flush),
            .i_nop(i_predicate),
            .o_stall(lsu_o_stall),
            .i_valid(lsu_i_valid),            
            .i_address(address),
            .i_stall(lsu_i_stall),
            .o_valid(lsu_o_valid),
            .o_readdata(o_readdata),
            .o_active(lsu_active),
            .avm_address(avm_address_raw),
            .avm_read(avm_read),
            .avm_readdata(avm_readdata),
            .avm_waitrequest(avm_waitrequest),
            .avm_byteenable(avm_byteenable),
            .avm_burstcount(avm_burstcount),
            .avm_readdatavalid(avm_readdatavalid),
            .req_cache_hit_count(req_cache_hit_count)
        );
    end
    else
    begin
        lsu_bursting_write #(
            .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
            .MEMORY_SIDE_MEM_LATENCY(MEMORY_SIDE_MEM_LATENCY),
            .AWIDTH(AWIDTH),
            .WIDTH_BYTES(WIDTH_BYTES),
            .MWIDTH_BYTES(MWIDTH_BYTES),
            .ALIGNMENT_ABITS(ALIGNMENT_ABITS),
            .BURSTCOUNT_WIDTH(BURSTCOUNT_WIDTH),
            .USE_WRITE_ACK(USE_WRITE_ACK),
            .USE_BYTE_EN(USE_BYTE_EN),
            .HIGH_FMAX(HIGH_FMAX)
        ) bursting_write (
            .clk(clock),
            .clk2x(clock2x),
            .reset(!sync_rstn),
            .o_stall(lsu_o_stall),
            .i_valid(lsu_i_valid),
            .i_nop(i_predicate),
            .i_address(address),
            .i_writedata(i_writedata),
            .i_stall(lsu_i_stall),
            .o_valid(lsu_o_valid),
            .o_active(lsu_active),
            .i_byteenable(i_byteenable),
            .avm_address(avm_address_raw),
            .avm_write(avm_write),
            .avm_writeack(lsu_writeack),
            .avm_writedata(avm_writedata),
            .avm_byteenable(avm_byteenable),
            .avm_burstcount(avm_burstcount),
            .avm_waitrequest(avm_waitrequest)
        );
    end
end
else if(STYLE=="BURST-NON-ALIGNED")
begin
    if(READ == 1)
    begin
        lsu_bursting_read #(
            .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
            .MEMORY_SIDE_MEM_LATENCY(MEMORY_SIDE_MEM_LATENCY),
            .AWIDTH(AWIDTH),
            .WIDTH_BYTES(WIDTH_BYTES),
            .MWIDTH_BYTES(MWIDTH_BYTES),
            .ALIGNMENT_ABITS(ALIGNMENT_ABITS),
            .BURSTCOUNT_WIDTH(BURSTCOUNT_WIDTH),
            .USECACHING(USECACHING),
            .CACHE_SIZE_N(CACHESIZE),
            .HIGH_FMAX(HIGH_FMAX),
            .ACL_PROFILE(ACL_PROFILE),
            .UNALIGNED(1)
        ) bursting_non_aligned_read (
            .clk(clock),
            .clk2x(clock2x),
            .reset(!sync_rstn),
            .flush(flush),
            .o_stall(lsu_o_stall),
            .i_valid(lsu_i_valid),
            .i_address(address),
            .i_nop(i_predicate),
            .i_stall(lsu_i_stall),
            .o_valid(lsu_o_valid),
            .o_readdata(o_readdata),
            .o_active(lsu_active),
            .avm_address(avm_address_raw),
            .avm_read(avm_read),
            .avm_readdata(avm_readdata),
            .avm_waitrequest(avm_waitrequest),
            .avm_byteenable(avm_byteenable),
            .avm_burstcount(avm_burstcount),
            .avm_readdatavalid(avm_readdatavalid),
            .extra_unaligned_reqs(extra_unaligned_reqs),
            .req_cache_hit_count(req_cache_hit_count)
        );
    end
    else
    begin
        lsu_non_aligned_write #(
            .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
            .MEMORY_SIDE_MEM_LATENCY(MEMORY_SIDE_MEM_LATENCY),
            .AWIDTH(AWIDTH),
            .WIDTH_BYTES(WIDTH_BYTES),
            .MWIDTH_BYTES(MWIDTH_BYTES),
            .ALIGNMENT_ABITS(ALIGNMENT_ABITS),
            .BURSTCOUNT_WIDTH(BURSTCOUNT_WIDTH),
            .USE_WRITE_ACK(USE_WRITE_ACK),
            .USE_BYTE_EN(USE_BYTE_EN),
            .HIGH_FMAX(HIGH_FMAX)
        ) bursting_non_aligned_write (
            .clk(clock),
            .clk2x(clock2x),
            .reset(!sync_rstn),
            .o_stall(lsu_o_stall),
            .i_valid(lsu_i_valid),
            .i_address(address),
            .i_nop(i_predicate),
            .i_writedata(i_writedata),
            .i_stall(lsu_i_stall),
            .o_valid(lsu_o_valid),
            .o_active(lsu_active),
            .i_byteenable(i_byteenable),
            .avm_address(avm_address_raw),
            .avm_write(avm_write),
            .avm_writeack(lsu_writeack),
            .avm_writedata(avm_writedata),
            .avm_byteenable(avm_byteenable),
            .avm_burstcount(avm_burstcount),
            .avm_waitrequest(avm_waitrequest)
        );
    end
end
else if(STYLE=="STREAMING")
begin
   if(READ==1)
   begin
      lsu_streaming_read #(
         .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
         .MEMORY_SIDE_MEM_LATENCY(MEMORY_SIDE_MEM_LATENCY),
         .AWIDTH(AWIDTH),
         .WIDTH_BYTES(WIDTH_BYTES),
         .MWIDTH_BYTES(MWIDTH_BYTES),
         .ALIGNMENT_ABITS(ALIGNMENT_ABITS),
         .BURSTCOUNT_WIDTH(BURSTCOUNT_WIDTH)
      ) streaming_read (
         .clk(clock),
         .reset(!sync_rstn),
         .o_stall(lsu_o_stall),
         .i_valid(lsu_i_valid),
         .i_stall(lsu_i_stall),
         .o_valid(lsu_o_valid),
         .o_readdata(o_readdata),
         .o_active(lsu_active),
         .i_nop(i_predicate),
         .base_address(stream_base_addr),
         .size(stream_size),
         .avm_address(avm_address_raw),
         .avm_burstcount(avm_burstcount),
         .avm_read(avm_read),
         .avm_readdata(avm_readdata),
         .avm_waitrequest(avm_waitrequest),
         .avm_byteenable(avm_byteenable),
         .avm_readdatavalid(avm_readdatavalid)
      );
   end
   else
   begin
     lsu_streaming_write #(
         .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
         .MEMORY_SIDE_MEM_LATENCY(MEMORY_SIDE_MEM_LATENCY),
         .AWIDTH(AWIDTH),
         .WIDTH_BYTES(WIDTH_BYTES),
         .MWIDTH_BYTES(MWIDTH_BYTES),
         .ALIGNMENT_ABITS(ALIGNMENT_ABITS),
         .BURSTCOUNT_WIDTH(BURSTCOUNT_WIDTH),
         .USE_BYTE_EN(USE_BYTE_EN)
     ) streaming_write (
         .clk(clock),
         .reset(!sync_rstn),
         .o_stall(lsu_o_stall),
         .i_valid(lsu_i_valid),
         .i_stall(lsu_i_stall),
         .o_valid(lsu_o_valid),
         .o_active(lsu_active),
         .i_byteenable(i_byteenable),
         .i_writedata(i_writedata),
         .i_nop(i_predicate),
         .base_address(stream_base_addr),
         .size(stream_size),
         .avm_address(avm_address_raw),
         .avm_burstcount(avm_burstcount),
         .avm_write(avm_write),
         .avm_writeack(lsu_writeack),
         .avm_writedata(avm_writedata),
         .avm_byteenable(avm_byteenable),
         .avm_waitrequest(avm_waitrequest)
     );
   end
end
else if(STYLE=="SEMI-STREAMING")
begin
   if(READ==1)
   begin
      lsu_read_cache #(
         .KERNEL_SIDE_MEM_LATENCY(KERNEL_SIDE_MEM_LATENCY),
         .AWIDTH(AWIDTH),
         .WIDTH_BYTES(WIDTH_BYTES),
         .MWIDTH_BYTES(MWIDTH_BYTES),
         .ALIGNMENT_ABITS(ALIGNMENT_ABITS),
         .BURSTCOUNT_WIDTH(BURSTCOUNT_WIDTH),
         .ACL_PROFILE(ACL_PROFILE),
         .REQUESTED_SIZE(CACHESIZE)
      ) read_cache (
         .clk(clock),
         .reset(!sync_rstn),
         .flush(flush),
         .o_stall(lsu_o_stall),
         .i_valid(lsu_i_valid),
         .i_address(address),
         .i_stall(lsu_i_stall),
         .o_valid(lsu_o_valid),
         .o_readdata(o_readdata),
         .o_active(lsu_active),
         .i_nop(i_predicate),
         .avm_address(avm_address_raw),
         .avm_burstcount(avm_burstcount),
         .avm_read(avm_read),
         .avm_readdata(avm_readdata),
         .avm_waitrequest(avm_waitrequest),
         .avm_byteenable(avm_byteenable),
         .avm_readdatavalid(avm_readdatavalid),
         .req_cache_hit_count(req_cache_hit_count)
      );
   end
end
always@(posedge clock or negedge sync_rstn)
   if (!sync_rstn)
      o_active <= 1'b0;
    else
      o_active <= lsu_active;
if(ACL_PROFILE==1)
begin
   reg [BURSTCOUNT_WIDTH-1:0] profile_remaining_writeburst_count;
   wire active_write_burst;
   assign active_write_burst = (profile_remaining_writeburst_count != {BURSTCOUNT_WIDTH{1'b0}});
   always@(posedge clock or negedge sync_rstn)
     if (!sync_rstn)
        profile_remaining_writeburst_count <= {BURSTCOUNT_WIDTH{1'b0}};
     else if(avm_write & ~avm_waitrequest & ~active_write_burst)
        profile_remaining_writeburst_count <= avm_burstcount - 1;
     else if(~avm_waitrequest & active_write_burst)
        profile_remaining_writeburst_count <= profile_remaining_writeburst_count - 1;      
   assign profile_bw = (READ==1) ? avm_readdatavalid : (avm_write & ~avm_waitrequest);
   assign profile_bw_incr = MWIDTH_BYTES;
   assign profile_total_ivalid = (i_valid & ~o_stall);
   assign profile_total_req = (i_valid & ~i_predicate & ~o_stall);
   assign profile_i_stall_count = (i_stall & o_valid);
   assign profile_o_stall_count = (o_stall & i_valid);
   assign profile_avm_readwrite_count = ((avm_read | avm_write) & ~avm_waitrequest & ~active_write_burst);
   assign profile_avm_burstcount_total = ((avm_read | avm_write) & ~avm_waitrequest & ~active_write_burst);
   assign profile_avm_burstcount_total_incr = avm_burstcount;
   assign profile_req_cache_hit_count = req_cache_hit_count;
   assign profile_extra_unaligned_reqs = extra_unaligned_reqs;
   assign profile_avm_stall = ((avm_read | avm_write) & avm_waitrequest);
end
else begin
   assign profile_bw = 1'b0;
   assign profile_bw_incr = {ACL_PROFILE_INCREMENT_WIDTH{1'b0}};
   assign profile_total_ivalid = 1'b0;
   assign profile_total_req = 1'b0;
   assign profile_i_stall_count = 1'b0;
   assign profile_o_stall_count = 1'b0;
   assign profile_avm_readwrite_count = 1'b0;
   assign profile_avm_burstcount_total = 1'b0;
   assign profile_avm_burstcount_total_incr = {ACL_PROFILE_INCREMENT_WIDTH{1'b0}};
   assign profile_req_cache_hit_count = 1'b0;
   assign profile_extra_unaligned_reqs = 1'b0;
   assign profile_avm_stall = 1'b0;
end
reg  [31:0] bw_kernel;
reg  [31:0] bw_avalon;
always@(posedge clock or negedge sync_rstn)
begin
   if (!sync_rstn)
     bw_avalon <= 0;
   else 
     if (READ==1 && avm_readdatavalid)
       bw_avalon <= bw_avalon + MWIDTH_BYTES;
     else if (READ==0 && avm_write && ~avm_waitrequest)
       bw_avalon <= bw_avalon + MWIDTH_BYTES;
end
always@(posedge clock or negedge sync_rstn)
begin
   if (!sync_rstn)
     bw_kernel <= 0;
   else if (i_valid && !o_stall && ~nop)
     bw_kernel <= bw_kernel + WIDTH_BYTES;
end
if(PROFILE_ADDR_TOGGLE==1 && STYLE!="SIMPLE")
begin
  localparam COUNTERWIDTH=12;
  logic [COUNTERWIDTH-1:0] togglerate[AWIDTH-ALIGNMENT_ABITS+1];
  acl_toggle_detect 
    #(.WIDTH(AWIDTH-ALIGNMENT_ABITS), .COUNTERWIDTH(COUNTERWIDTH)) atd (
      .clk(clock),
      .resetn(sync_rstn),
      .valid(i_valid && ~o_stall && ~nop),
      .value({i_address >> ALIGNMENT_ABITS,{ALIGNMENT_ABITS{1'b0}}}),
      .count(togglerate));
  acl_debug_mem #(.WIDTH(COUNTERWIDTH), .SIZE(AWIDTH-ALIGNMENT_ABITS+1)) dbg_mem (
      .clk(clock),
      .resetn(sync_rstn),
      .write(i_valid && ~o_stall && ~nop),
      .data(togglerate));
end
end
endgenerate
endmodule
