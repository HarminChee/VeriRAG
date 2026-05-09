`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_crossbar_v2_1_10_splitter #
  (
   parameter integer C_NUM_M = 2  
   )
  (
   input  wire                             ACLK,
   input  wire                             ARESET,
   input  wire                             S_VALID,
   output wire                             S_READY,
   output wire [C_NUM_M-1:0]               M_VALID,
   input  wire [C_NUM_M-1:0]               M_READY
   );
   reg  [C_NUM_M-1:0] m_ready_d;
   wire               s_ready_i;
   wire [C_NUM_M-1:0] m_valid_i;
   always @(posedge ACLK) begin
      if (ARESET | s_ready_i) m_ready_d <= {C_NUM_M{1'b0}};
      else                    m_ready_d <= m_ready_d | (m_valid_i & M_READY);
   end
   assign s_ready_i = &(m_ready_d | M_READY);
   assign m_valid_i = {C_NUM_M{S_VALID}} & ~m_ready_d;
   assign M_VALID = m_valid_i;
   assign S_READY = s_ready_i;
endmodule
