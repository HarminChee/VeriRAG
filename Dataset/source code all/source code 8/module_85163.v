module acl_embedded_workgroup_issuer_fifo #(
  parameter unsigned MAX_SIMULTANEOUS_WORKGROUPS = 2,    
  parameter unsigned MAX_WORKGROUP_SIZE = 2147483648,    
  parameter unsigned WG_SIZE_BITS = $clog2({1'b0, MAX_WORKGROUP_SIZE} + 1),
  parameter unsigned LLID_BITS = (MAX_WORKGROUP_SIZE > 1 ? $clog2(MAX_WORKGROUP_SIZE) : 1),
  parameter unsigned WG_ID_BITS = (MAX_SIMULTANEOUS_WORKGROUPS > 1 ? $clog2(MAX_SIMULTANEOUS_WORKGROUPS) : 1)
)
(
  input logic clock, 
  input logic resetn, 
  input logic valid_in, 
  output logic stall_out, 
  output logic valid_entry, 
  input logic stall_entry,
  input logic valid_exit, 
  input logic stall_exit, 
  input logic [WG_SIZE_BITS - 1:0] workgroup_size, 
  output logic [LLID_BITS - 1:0] linear_local_id_out,
  output logic [WG_ID_BITS - 1:0] hw_wg_id_out,
  input logic [WG_ID_BITS - 1:0] done_hw_wg_id_in,
  input logic [31:0] global_id_in[2:0],
  input logic [31:0] local_id_in[2:0],
  input logic [31:0] group_id_in[2:0],
  output logic [31:0] global_id_out[2:0],
  output logic [31:0] local_id_out[2:0],
  output logic [31:0] group_id_out[2:0]
);
  acl_work_group_limiter #(
    .WG_LIMIT(MAX_SIMULTANEOUS_WORKGROUPS),
    .KERNEL_WG_LIMIT(MAX_SIMULTANEOUS_WORKGROUPS),
    .MAX_WG_SIZE(MAX_WORKGROUP_SIZE),
    .WG_FIFO_ORDER(1),
    .IMPL("kernel")   
  )
  limiter(
    .clock(clock),
    .resetn(resetn),
    .wg_size(workgroup_size),
    .entry_valid_in(valid_in),
    .entry_k_wgid(),
    .entry_stall_out(stall_out),
    .entry_valid_out(valid_entry),
    .entry_l_wgid(hw_wg_id_out),
    .entry_stall_in(stall_entry),
    .exit_valid_in(valid_exit & ~stall_exit),
    .exit_l_wgid(done_hw_wg_id_in),
    .exit_stall_out(),
    .exit_valid_out(),
    .exit_stall_in(1'b0)
  );
  always @(posedge clock)
    if( ~stall_entry ) 
    begin
      global_id_out <= global_id_in;
      local_id_out <= local_id_in;
      group_id_out <= group_id_in;
    end
  always @(posedge clock or negedge resetn)
    if( ~resetn )
      linear_local_id_out <= '0;
    else if( valid_entry & ~stall_entry )
    begin
      if( linear_local_id_out == workgroup_size - 'd1 )
        linear_local_id_out <= '0;
      else
        linear_local_id_out <= linear_local_id_out + 'd1;
    end
endmodule
