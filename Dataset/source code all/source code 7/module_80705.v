module acl_embedded_workgroup_issuer_complex (clock, resetn, valid_in, stall_out, valid_entry, stall_entry,
  valid_exit, stall_exit, workgroup_size, linear_local_id_out, hw_wg_id_out, done_hw_wg_id_in,
  global_id_in, local_id_in, group_id_in, global_id_out, local_id_out, group_id_out);
  parameter unsigned MAX_SIMULTANEOUS_WORKGROUPS = 2;    
  parameter unsigned MAX_WORKGROUP_SIZE = 2147483648;    
  parameter unsigned WG_SIZE_BITS = $clog2({1'b0, MAX_WORKGROUP_SIZE} + 1);
  localparam unsigned LLID_BITS = (MAX_WORKGROUP_SIZE > 1 ? $clog2(MAX_WORKGROUP_SIZE) : 1);
  localparam unsigned WG_ID_BITS = (MAX_SIMULTANEOUS_WORKGROUPS > 1 ? $clog2(MAX_SIMULTANEOUS_WORKGROUPS) : 1);
  input clock;
  input resetn;
  input valid_in;
  output stall_out;
  output valid_entry;
  input stall_entry;
  input valid_exit;
  input stall_exit;
  input [WG_SIZE_BITS-1:0] workgroup_size;
  output [LLID_BITS - 1:0] linear_local_id_out;
  output [WG_ID_BITS - 1:0] hw_wg_id_out;
  input [WG_ID_BITS - 1:0] done_hw_wg_id_in;
  input [31:0] global_id_in[2:0];
  input [31:0] local_id_in[2:0];
  input [31:0] group_id_in[2:0];
  output [31:0] global_id_out[2:0];
  output [31:0] local_id_out[2:0];
  output [31:0] group_id_out[2:0];
localparam [2:0] wg_STATE_NEW=3'd0;
localparam [2:0] wg_STATE_ISSUE=3'd1;
localparam [2:0] wg_STATE_WAIT=3'd2;
reg  [2:0] present_state;
reg  [2:0] next_state;
reg  [WG_ID_BITS-1:0] hw_group_sel;
reg  [LLID_BITS-1:0] num_issued_in_wg; 
wire retire = valid_exit & ~stall_exit;
reg  [WG_SIZE_BITS-1:0] num_items_not_done[MAX_SIMULTANEOUS_WORKGROUPS-1:0];
generate
if (MAX_SIMULTANEOUS_WORKGROUPS > 1)
begin
   always @(posedge clock or negedge resetn)
   begin
    if (~(resetn)) 
      hw_group_sel <= '0;
    else if (present_state==wg_STATE_ISSUE && next_state==wg_STATE_WAIT)
    begin
      if (hw_group_sel == MAX_SIMULTANEOUS_WORKGROUPS - 1)
        hw_group_sel <= '0;
      else
        hw_group_sel <= hw_group_sel + 'd1;
    end
   end
end
else
begin
   always @(posedge clock) hw_group_sel=1'b0;
end
endgenerate
wire begin_group = (present_state == wg_STATE_NEW)    & valid_in & (~stall_entry);
wire issue       = (present_state == wg_STATE_ISSUE)  & valid_in & (~stall_entry);
assign stall_out = ~(present_state == wg_STATE_ISSUE) | stall_entry;
assign valid_entry = (present_state == wg_STATE_ISSUE) & valid_in;
wire last_item_in_workgroup = (num_issued_in_wg == (workgroup_size - 'd1));
wire workgroup_sent = (present_state==wg_STATE_ISSUE) && issue && last_item_in_workgroup;
assign linear_local_id_out = num_issued_in_wg;
assign hw_wg_id_out = hw_group_sel;
assign global_id_out = global_id_in;
assign local_id_out = local_id_in;
assign group_id_out = group_id_in;
always @(posedge clock or negedge resetn) begin
   if ( ~resetn )
      num_issued_in_wg <= '0;
   else if ( begin_group )
      num_issued_in_wg <= '0;
   else if ( issue )
      num_issued_in_wg <= num_issued_in_wg + 1'b1;
   else
      num_issued_in_wg <= num_issued_in_wg;
end
wire next_hw_group_free = ~(|num_items_not_done[hw_group_sel]);
always@*
begin
  next_state = wg_STATE_NEW;
  case (present_state)
    wg_STATE_NEW:
      next_state = (begin_group) ? wg_STATE_ISSUE : wg_STATE_NEW;
    wg_STATE_ISSUE:
      next_state = (workgroup_sent) ? wg_STATE_WAIT : wg_STATE_ISSUE;
    wg_STATE_WAIT:
      next_state = (next_hw_group_free) ? wg_STATE_NEW : wg_STATE_WAIT;
  endcase
end
always @(posedge clock or negedge resetn)
begin
  if (~(resetn))
    present_state <= wg_STATE_NEW;
  else
    present_state <= next_state;
end
generate
genvar i;
  for (i=0; i<MAX_SIMULTANEOUS_WORKGROUPS; i=i+1)
  begin : numdone_gen
    always @(posedge clock or negedge resetn)
    begin
      if (~(resetn))
        num_items_not_done[i] <= '0;
      else 
        case (present_state)
          wg_STATE_NEW:
            if ( retire && (done_hw_wg_id_in==i) ) 
              num_items_not_done[i] <= (num_items_not_done[i] - 2'b01);
          wg_STATE_ISSUE:
            if (       ( issue  && (hw_group_sel==i) )          
                  &&  ~( retire && (done_hw_wg_id_in==i) )  
               )
               num_items_not_done[i] <= (num_items_not_done[i] + 2'b01);
            else if ( ~( issue  && (hw_group_sel==i) )          
                  &&   ( retire && (done_hw_wg_id_in==i) )  
               )
               num_items_not_done[i] <= (num_items_not_done[i] - 2'b01);
          wg_STATE_WAIT: 
            if ( retire && done_hw_wg_id_in==i ) 
              num_items_not_done[i] <= (num_items_not_done[i] - 2'b01);
        endcase
    end
  end
endgenerate
endmodule
