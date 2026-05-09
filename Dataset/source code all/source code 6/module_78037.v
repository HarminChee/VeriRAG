module st_read (
        clock,
        resetn,
        i_init,
        i_predicate,
        i_valid,
        o_stall,
        o_valid,
        i_stall,
        o_data,
	o_datavalid, 
        i_fifodata,
        i_fifovalid,
        o_fifoready,
        i_fifosize,
        profile_i_valid,
        profile_i_stall,
        profile_o_stall,
        profile_total_req,
        profile_fifo_stall,
        profile_total_fifo_size, profile_total_fifo_size_incr
        );
parameter DATA_WIDTH = 32;
parameter INIT = 0;
parameter INIT_VAL = 64'h0000000000000000;
parameter NON_BLOCKING = 1'b0;
parameter FIFOSIZE_WIDTH=32;
parameter ACL_PROFILE=0;      
parameter ACL_PROFILE_INCREMENT_WIDTH=32;
input clock, resetn, i_stall, i_valid, i_fifovalid;
input i_init;
output o_stall, o_valid, o_fifoready;
input i_predicate;
output o_datavalid;
output [DATA_WIDTH-1:0] o_data;
input [DATA_WIDTH-1:0] i_fifodata;
input [FIFOSIZE_WIDTH-1:0] i_fifosize;
output profile_i_valid;
output profile_i_stall;
output profile_o_stall;
output profile_total_req;
output profile_fifo_stall;
output profile_total_fifo_size;
output [ACL_PROFILE_INCREMENT_WIDTH-1:0] profile_total_fifo_size_incr;
wire feedback_downstream, data_downstream;
wire nop = i_predicate;
wire initvalid;
wire initready;
assign feedback_downstream = i_valid & ~nop & initvalid;
assign data_downstream = i_valid & nop;
assign o_datavalid = feedback_downstream;
wire init_reset;
wire r_o_stall;
wire init_val;
generate
if ( INIT ) begin
assign init_reset = ~resetn;
assign init_val   = i_init;
init_reg
  #( .WIDTH    ( DATA_WIDTH   ),
     .INIT     ( INIT     ),
     .INIT_VAL ( INIT_VAL ) )
reg_data ( 
      .clk     ( clock ),
      .reset   ( init_reset ),
      .i_init  ( init_val   ),
      .i_data  ( i_fifodata ),
      .i_valid ( i_fifovalid ), 
      .o_valid ( initvalid ),
      .o_data  ( o_data ),
      .o_stall ( r_o_stall ),
      .i_stall ( ~initready ) 
      );
end
else begin
assign init_reset = ~resetn;
assign init_val   = 1'b0;
assign o_data = i_fifodata;
assign initvalid = i_fifovalid;
assign r_o_stall = ~initready;
end
endgenerate
assign o_fifoready = ~r_o_stall;
assign o_valid = feedback_downstream | data_downstream | ( i_valid & NON_BLOCKING );
assign o_data_valid = feedback_downstream;
assign o_stall = ( i_valid & ~nop & ~initvalid & ~NON_BLOCKING) | i_stall;
assign initready = ~(i_stall  | data_downstream | ~i_valid); 
generate
if(ACL_PROFILE==1)
begin
  assign profile_i_valid = ( i_valid & ~o_stall );
  assign profile_i_stall = ( o_valid & i_stall );
  assign profile_o_stall = ( i_valid & o_stall );
  assign profile_total_req = ( i_valid & ~o_stall & ~nop );
  assign profile_fifo_stall = ( i_valid & ~nop & ~initvalid );
  assign profile_total_fifo_size = ( i_fifovalid & o_fifoready );
  assign profile_total_fifo_size_incr = i_fifosize;
end
else
begin
  assign profile_i_valid = 1'b0;
  assign profile_i_stall = 1'b0;
  assign profile_o_stall = 1'b0;
  assign profile_total_req = 1'b0;
  assign profile_fifo_stall = 1'b0;
  assign profile_total_fifo_size = 1'b0;
  assign profile_total_fifo_size_incr = {ACL_PROFILE_INCREMENT_WIDTH{1'b0}};
end
endgenerate
endmodule
module st_write (
        clock,
        resetn,
        i_predicate,
        i_data,
        i_valid,
        o_stall,
        o_valid,
	o_ack,
        i_stall,
        o_fifodata,
        o_fifovalid,
        i_fifoready,
        i_fifosize,
        profile_i_valid,
        profile_i_stall,
        profile_o_stall,
        profile_total_req,
        profile_fifo_stall,
        profile_total_fifo_size, profile_total_fifo_size_incr
        );
parameter DATA_WIDTH = 32;
parameter NON_BLOCKING = 1'b0;
parameter FIFOSIZE_WIDTH=32;
parameter EFI_LATENCY = 1;
parameter ACL_PROFILE=0;      
parameter ACL_PROFILE_INCREMENT_WIDTH=32;
input clock, resetn, i_stall, i_valid, i_fifoready;
output o_stall, o_valid, o_fifovalid;
input [DATA_WIDTH-1:0] i_data;
input i_predicate;
output [DATA_WIDTH-1:0] o_fifodata;
output o_ack;
input [FIFOSIZE_WIDTH-1:0] i_fifosize;
output profile_i_valid;
output profile_i_stall;
output profile_o_stall;
output profile_total_req;
output profile_fifo_stall;
output profile_total_fifo_size;
output [ACL_PROFILE_INCREMENT_WIDTH-1:0] profile_total_fifo_size_incr;
wire nop;
assign nop = i_predicate;
wire fifo_stall;
generate 
if (EFI_LATENCY == 0) begin
  assign o_valid       = i_valid;
  assign o_stall       = (nop & i_stall) | ( (fifo_stall & (~nop) & i_valid & !NON_BLOCKING) );
  assign o_fifovalid   = i_valid & ~nop;
end
else begin
  assign o_valid       = i_valid & (i_fifoready | nop | NON_BLOCKING);
  assign o_stall       = i_stall | (fifo_stall & (~nop) & i_valid & !NON_BLOCKING) ;
  assign o_fifovalid   = i_valid & ~nop & ~i_stall;
end
endgenerate
assign o_ack        = o_fifovalid & i_fifoready;
assign fifo_stall = ~i_fifoready;
assign o_fifodata = i_data;
generate
if(ACL_PROFILE==1)
begin
  assign profile_i_valid = ( i_valid & ~o_stall );
  assign profile_i_stall = ( o_valid & i_stall );
  assign profile_o_stall = ( i_valid & o_stall );
  assign profile_total_req = ( i_valid & ~o_stall & ~nop );
  assign profile_fifo_stall = (fifo_stall & (~nop) & i_valid) ;
  assign profile_total_fifo_size = ( o_fifovalid & i_fifoready );
  assign profile_total_fifo_size_incr = i_fifosize;
end
else
begin
  assign profile_i_valid = 1'b0;
  assign profile_i_stall = 1'b0;
  assign profile_o_stall = 1'b0;
  assign profile_total_req = 1'b0;
  assign profile_fifo_stall = 1'b0;
  assign profile_total_fifo_size = 1'b0;
  assign profile_total_fifo_size_incr = {ACL_PROFILE_INCREMENT_WIDTH{1'b0}};
end
endgenerate
endmodule
module init_reg
(
    clk, reset, i_init, i_data, i_valid, o_stall, o_data, o_valid, i_stall
);
parameter WIDTH    = 32;
parameter INIT     = 0;
parameter INIT_VAL = 32'h0000000000000000;
input clk;
input reset;
input i_init;
input [WIDTH-1:0] i_data;
input i_valid;
output o_stall;
output [WIDTH-1:0] o_data;
output o_valid;
input i_stall;
reg [WIDTH-1:0] r_data;
reg r_valid;
assign o_stall = r_valid;
assign o_data = (r_valid) ? r_data : i_data;
assign o_valid = (r_valid) ? r_valid : i_valid;
always@(posedge clk or posedge reset)
begin
    if(reset == 1'b1)
    begin
        r_valid <= INIT;
        r_data  <= INIT_VAL;
    end
    else if (i_init) 
    begin
        r_valid <= INIT;
        r_data  <= INIT_VAL;
    end
    else
    begin
        if (~r_valid) r_data <= i_data;
        r_valid <= i_stall && (r_valid || i_valid);
    end
end
endmodule
module st_read (
        clock,
        resetn,
        i_init,
        i_predicate,
        i_valid,
        o_stall,
        o_valid,
        i_stall,
        o_data,
	o_datavalid, 
        i_fifodata,
        i_fifovalid,
        o_fifoready,
        i_fifosize,
        profile_i_valid,
        profile_i_stall,
        profile_o_stall,
        profile_total_req,
        profile_fifo_stall,
        profile_total_fifo_size, profile_total_fifo_size_incr
        );
parameter DATA_WIDTH = 32;
parameter INIT = 0;
parameter INIT_VAL = 64'h0000000000000000;
parameter NON_BLOCKING = 1'b0;
parameter FIFOSIZE_WIDTH=32;
parameter ACL_PROFILE=0;      
parameter ACL_PROFILE_INCREMENT_WIDTH=32;
input clock, resetn, i_stall, i_valid, i_fifovalid;
input i_init;
output o_stall, o_valid, o_fifoready;
input i_predicate;
output o_datavalid;
output [DATA_WIDTH-1:0] o_data;
input [DATA_WIDTH-1:0] i_fifodata;
input [FIFOSIZE_WIDTH-1:0] i_fifosize;
output profile_i_valid;
output profile_i_stall;
output profile_o_stall;
output profile_total_req;
output profile_fifo_stall;
output profile_total_fifo_size;
output [ACL_PROFILE_INCREMENT_WIDTH-1:0] profile_total_fifo_size_incr;
wire feedback_downstream, data_downstream;
wire nop = i_predicate;
wire initvalid;
wire initready;
assign feedback_downstream = i_valid & ~nop & initvalid;
assign data_downstream = i_valid & nop;
assign o_datavalid = feedback_downstream;
wire init_reset;
wire r_o_stall;
wire init_val;
generate
if ( INIT ) begin
assign init_reset = ~resetn;
assign init_val   = i_init;
init_reg
  #( .WIDTH    ( DATA_WIDTH   ),
     .INIT     ( INIT     ),
     .INIT_VAL ( INIT_VAL ) )
reg_data ( 
      .clk     ( clock ),
      .reset   ( init_reset ),
      .i_init  ( init_val   ),
      .i_data  ( i_fifodata ),
      .i_valid ( i_fifovalid ), 
      .o_valid ( initvalid ),
      .o_data  ( o_data ),
      .o_stall ( r_o_stall ),
      .i_stall ( ~initready ) 
      );
end
else begin
assign init_reset = ~resetn;
assign init_val   = 1'b0;
assign o_data = i_fifodata;
assign initvalid = i_fifovalid;
assign r_o_stall = ~initready;
end
endgenerate
assign o_fifoready = ~r_o_stall;
assign o_valid = feedback_downstream | data_downstream | ( i_valid & NON_BLOCKING );
assign o_data_valid = feedback_downstream;
assign o_stall = ( i_valid & ~nop & ~initvalid & ~NON_BLOCKING) | i_stall;
assign initready = ~(i_stall  | data_downstream | ~i_valid); 
generate
if(ACL_PROFILE==1)
begin
  assign profile_i_valid = ( i_valid & ~o_stall );
  assign profile_i_stall = ( o_valid & i_stall );
  assign profile_o_stall = ( i_valid & o_stall );
  assign profile_total_req = ( i_valid & ~o_stall & ~nop );
  assign profile_fifo_stall = ( i_valid & ~nop & ~initvalid );
  assign profile_total_fifo_size = ( i_fifovalid & o_fifoready );
  assign profile_total_fifo_size_incr = i_fifosize;
end
else
begin
  assign profile_i_valid = 1'b0;
  assign profile_i_stall = 1'b0;
  assign profile_o_stall = 1'b0;
  assign profile_total_req = 1'b0;
  assign profile_fifo_stall = 1'b0;
  assign profile_total_fifo_size = 1'b0;
  assign profile_total_fifo_size_incr = {ACL_PROFILE_INCREMENT_WIDTH{1'b0}};
end
endgenerate
endmodule
module st_write (
        clock,
        resetn,
        i_predicate,
        i_data,
        i_valid,
        o_stall,
        o_valid,
	o_ack,
        i_stall,
        o_fifodata,
        o_fifovalid,
        i_fifoready,
        i_fifosize,
        profile_i_valid,
        profile_i_stall,
        profile_o_stall,
        profile_total_req,
        profile_fifo_stall,
        profile_total_fifo_size, profile_total_fifo_size_incr
        );
parameter DATA_WIDTH = 32;
parameter NON_BLOCKING = 1'b0;
parameter FIFOSIZE_WIDTH=32;
parameter EFI_LATENCY = 1;
parameter ACL_PROFILE=0;      
parameter ACL_PROFILE_INCREMENT_WIDTH=32;
input clock, resetn, i_stall, i_valid, i_fifoready;
output o_stall, o_valid, o_fifovalid;
input [DATA_WIDTH-1:0] i_data;
input i_predicate;
output [DATA_WIDTH-1:0] o_fifodata;
output o_ack;
input [FIFOSIZE_WIDTH-1:0] i_fifosize;
output profile_i_valid;
output profile_i_stall;
output profile_o_stall;
output profile_total_req;
output profile_fifo_stall;
output profile_total_fifo_size;
output [ACL_PROFILE_INCREMENT_WIDTH-1:0] profile_total_fifo_size_incr;
wire nop;
assign nop = i_predicate;
wire fifo_stall;
generate 
if (EFI_LATENCY == 0) begin
  assign o_valid       = i_valid;
  assign o_stall       = (nop & i_stall) | ( (fifo_stall & (~nop) & i_valid & !NON_BLOCKING) );
  assign o_fifovalid   = i_valid & ~nop;
end
else begin
  assign o_valid       = i_valid & (i_fifoready | nop | NON_BLOCKING);
  assign o_stall       = i_stall | (fifo_stall & (~nop) & i_valid & !NON_BLOCKING) ;
  assign o_fifovalid   = i_valid & ~nop & ~i_stall;
end
endgenerate
assign o_ack        = o_fifovalid & i_fifoready;
assign fifo_stall = ~i_fifoready;
assign o_fifodata = i_data;
generate
if(ACL_PROFILE==1)
begin
  assign profile_i_valid = ( i_valid & ~o_stall );
  assign profile_i_stall = ( o_valid & i_stall );
  assign profile_o_stall = ( i_valid & o_stall );
  assign profile_total_req = ( i_valid & ~o_stall & ~nop );
  assign profile_fifo_stall = (fifo_stall & (~nop) & i_valid) ;
  assign profile_total_fifo_size = ( o_fifovalid & i_fifoready );
  assign profile_total_fifo_size_incr = i_fifosize;
end
else
begin
  assign profile_i_valid = 1'b0;
  assign profile_i_stall = 1'b0;
  assign profile_o_stall = 1'b0;
  assign profile_total_req = 1'b0;
  assign profile_fifo_stall = 1'b0;
  assign profile_total_fifo_size = 1'b0;
  assign profile_total_fifo_size_incr = {ACL_PROFILE_INCREMENT_WIDTH{1'b0}};
end
endgenerate
endmodule
