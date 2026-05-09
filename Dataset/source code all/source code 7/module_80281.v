module acl_ic_local_mem_router_terminator #(    
    parameter integer DATA_W = 256
)
(
    input logic clock,
    input logic resetn,
    input logic b_arb_request,
    input logic b_arb_read,
    input logic b_arb_write,
    output logic b_arb_stall,
    output logic b_wrp_ack,
    output logic b_rrp_datavalid,
    output logic [DATA_W-1:0] b_rrp_data,
    output logic b_invalid_access
);
reg saw_unexpected_access;
reg first_unexpected_was_read;
assign b_arb_stall = 1'b0;
assign b_wrp_ack = 1'b0;
assign b_rrp_datavalid = 1'b0;
assign b_rrp_data = '0;
assign b_invalid_access = saw_unexpected_access;
always@(posedge clock or negedge resetn)
   begin
      if (~resetn)
      begin
         saw_unexpected_access <= 1'b0;
         first_unexpected_was_read <= 1'b0;
      end
      else
      begin
      if (b_arb_request && ~saw_unexpected_access)
         begin
            saw_unexpected_access <= 1'b1;
            first_unexpected_was_read <= b_arb_read;
            $fatal(0,"Local memory router: accessed bank that isn't connected.  Hardware will hang.");
         end
      end
   end
endmodule
