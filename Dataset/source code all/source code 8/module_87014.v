module acl_id_iterator
#(
  parameter WIDTH = 32    
)
(
  input clock,
  input resetn,
  input start,
  input valid_in,
  output stall_out,
  input stall_in,
  output valid_out,
  input [WIDTH-1:0] group_id_in[2:0],
  input [WIDTH-1:0] global_id_base_in[2:0],
  input [WIDTH-1:0] local_size[2:0],
  input [WIDTH-1:0] global_size[2:0],
  output [WIDTH-1:0] local_id[2:0],
  output [WIDTH-1:0] global_id[2:0],
  output [WIDTH-1:0] group_id[2:0]
);
  localparam FIFO_WIDTH = 2 * 3 * WIDTH;
  localparam FIFO_DEPTH = 4;
  wire last_in_group;
  wire issue = valid_out & !stall_in;
  reg just_seen_last_in_group;
  wire [WIDTH-1:0] global_id_from_iter[2:0];
  reg [WIDTH-1:0] global_id_base[2:0];
  wire use_base = just_seen_last_in_group;
  assign global_id[0] = use_base ? global_id_base[0] : global_id_from_iter[0];
  assign global_id[1] = use_base ? global_id_base[1] : global_id_from_iter[1];
  assign global_id[2] = use_base ? global_id_base[2] : global_id_from_iter[2];
  acl_fifo #(
    .DATA_WIDTH(FIFO_WIDTH),
    .DEPTH(FIFO_DEPTH)
  ) group_id_fifo (
    .clock(clock),
    .resetn(resetn),
    .data_in ( {group_id_in[2], group_id_in[1], group_id_in[0], 
                global_id_base_in[2], global_id_base_in[1], global_id_base_in[0]} ),
    .data_out( {group_id[2], group_id[1], group_id[0], 
                global_id_base[2], global_id_base[1], global_id_base[0]} ),
    .valid_in(valid_in),
    .stall_out(stall_out),
    .valid_out(valid_out),
    .stall_in(!last_in_group | !issue)
  );
  acl_work_item_iterator #(
    .WIDTH(WIDTH)
  ) work_item_iterator (
    .clock(clock),
    .resetn(resetn),
    .start(start),
    .issue(issue),
    .local_size(local_size),
    .global_size(global_size),
    .global_id_base(global_id_base),
    .local_id(local_id),
    .global_id(global_id_from_iter),
    .last_in_group(last_in_group)
  );
  always @(posedge clock or negedge resetn) begin
    if ( ~resetn )
      just_seen_last_in_group <= 1'b1;
    else if ( start )
      just_seen_last_in_group <= 1'b1;
    else if (last_in_group & issue)
      just_seen_last_in_group <= 1'b1;
    else if (issue)
      just_seen_last_in_group <= 1'b0;
    else
      just_seen_last_in_group <= just_seen_last_in_group;
  end
endmodule
