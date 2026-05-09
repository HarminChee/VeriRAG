module acl_push (
	clock,
	resetn,
	dir,
	data_in,
    valid_in,
    stall_out,
    predicate,
    valid_out,
    stall_in,
    data_out,
    feedback_out,
    feedback_valid_out,
    feedback_stall_in
);
    parameter DATA_WIDTH = 32;
    parameter FIFO_DEPTH = 1;
    parameter MIN_FIFO_LATENCY = 0;
    parameter string STYLE = "REGULAR";     
    parameter STALLFREE = 0;
input clock, resetn, stall_in, valid_in, feedback_stall_in;
output stall_out, valid_out, feedback_valid_out;
input [DATA_WIDTH-1:0] data_in;
input dir;
input predicate;
output [DATA_WIDTH-1:0] data_out, feedback_out;
wire [DATA_WIDTH-1:0] feedback;
wire data_downstream, data_upstream;
wire push_upstream;
assign push_upstream = dir & ~predicate;
assign data_upstream = valid_in & push_upstream;
assign data_downstream = valid_in;
wire feedback_stall, feedback_valid;
reg consumed_downstream, consumed_upstream;
assign valid_out = data_downstream & !consumed_downstream;
assign feedback_valid = data_upstream & !consumed_upstream;
assign data_out = data_in;
assign feedback = data_in;
assign stall_out = stall_in | (feedback_stall & push_upstream );
always @(posedge clock or negedge resetn) begin
   if (!resetn) begin
      consumed_downstream <= 1'b0;
      consumed_upstream <= 1'b0;
   end else begin
      if (consumed_downstream)
        consumed_downstream <= stall_out;
      else  
        consumed_downstream <= stall_out & (data_downstream & ~stall_in);
      if (consumed_upstream)
        consumed_upstream <= stall_out;
      else  
        consumed_upstream <= stall_out & (data_upstream & ~feedback_stall);
   end
end
localparam TYPE = MIN_FIFO_LATENCY < 1 ? (FIFO_DEPTH < 8 ? "zl_reg" : "zl_ram") : (MIN_FIFO_LATENCY < 3 ? (FIFO_DEPTH < 8 ? "ll_reg" : "ll_ram") : (FIFO_DEPTH < 8 ? "ll_reg" : "ram"));
  generate
    if ( STYLE == "TOKEN" )
    begin
      acl_token_fifo_counter 
      #(
        .DEPTH(FIFO_DEPTH)
       )
      fifo (
        .clock(clock),
        .resetn(resetn),
        .data_out(feedback_out),
        .valid_in(feedback_valid),
        .valid_out(feedback_valid_out),
        .stall_in(feedback_stall_in),
        .stall_out(feedback_stall)
      );
    end
    else if (FIFO_DEPTH == 0) begin
      assign feedback_out = feedback;
      assign feedback_valid_out = feedback_valid;
      assign feedback_stall = feedback_stall_in;
    end
    else if (FIFO_DEPTH == 1 && MIN_FIFO_LATENCY == 0) begin
      acl_staging_reg #(
      .WIDTH(DATA_WIDTH)
      ) staging_reg (
      .clk(clock), 
      .reset(~resetn), 
      .i_data(feedback),
      .i_valid(feedback_valid),
      .o_stall(feedback_stall),
      .o_data(feedback_out), 
      .o_valid(feedback_valid_out), 
      .i_stall(feedback_stall_in)
      );
    end
    else
    begin
      localparam OFFSET = ( (TYPE == "ll_reg") && !STALLFREE ) ? 1 : 0;
      localparam ALLOW_FULL_WRITE = ( (TYPE == "ll_reg") && !STALLFREE ) ? 0 : 1;
      acl_data_fifo #(
       .DATA_WIDTH(DATA_WIDTH),
       .DEPTH(((TYPE == "ram")  || (TYPE == "ll_ram") || (TYPE == "zl_ram")) ? FIFO_DEPTH + 1 : FIFO_DEPTH + OFFSET),
       .IMPL(TYPE),
       .ALLOW_FULL_WRITE(ALLOW_FULL_WRITE)
       )
      fifo (
      .clock(clock),
      .resetn(resetn),
      .data_in(feedback),
      .data_out(feedback_out),
      .valid_in(feedback_valid),
      .valid_out(feedback_valid_out),
      .stall_in(feedback_stall_in),
      .stall_out(feedback_stall)
      );
    end
  endgenerate
endmodule
