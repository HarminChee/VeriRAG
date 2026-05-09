module vfabric_log(clock, resetn, 
  i_dataa, i_dataa_valid, o_dataa_stall, 
  o_dataout, o_dataout_valid, i_stall);
parameter DATA_WIDTH = 32;
parameter LATENCY = 21;
parameter FIFO_DEPTH = 64;
 input clock, resetn;
 input [DATA_WIDTH-1:0] i_dataa;
 input i_dataa_valid;
 output o_dataa_stall;
 output [DATA_WIDTH-1:0] o_dataout;
 output o_dataout_valid;
 input i_stall;
 reg [LATENCY-1:0] shift_reg_valid;
 wire [DATA_WIDTH-1:0] dataa;
 wire is_fifo_a_valid;
 wire is_stalled;
 wire is_fifo_stalled;
 vfabric_buffered_fifo fifo_a ( .clock(clock), .resetn(resetn), 
      .data_in(i_dataa), .data_out(dataa), .valid_in(i_dataa_valid),
      .valid_out( is_fifo_a_valid ), .stall_in(is_fifo_stalled), .stall_out(o_dataa_stall) );
 defparam fifo_a.DATA_WIDTH = DATA_WIDTH;
 defparam fifo_a.DEPTH = FIFO_DEPTH;
 always @(posedge clock or negedge resetn)
 begin
  if (~resetn)
    begin
    shift_reg_valid <= {LATENCY{1'b0}};
  end
  else
  begin
    if(~is_stalled)
      shift_reg_valid <= { is_fifo_a_valid, shift_reg_valid[LATENCY-1:1] };
  end
 end
 assign is_stalled = (shift_reg_valid[0] & i_stall);
 assign is_fifo_stalled = (shift_reg_valid[0] & i_stall) | !(is_fifo_a_valid);
 acl_fp_log_s5 log_unit(
	.enable(~is_stalled), .clock(clock), .dataa(dataa), .result(o_dataout));
 assign o_dataout_valid = shift_reg_valid[0];
endmodule
