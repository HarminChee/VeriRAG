`timescale 1ns/100ps
`timescale 1ns/100ps
module splitter #(
  parameter NUM_M = 2)(
  input clk,
  input resetn,
  input s_valid,
  output s_ready,
  output [NUM_M-1:0] m_valid,
  input [NUM_M-1:0] m_ready
);
reg [NUM_M-1:0] acked;
assign s_ready = &(m_ready | acked);
assign m_valid = s_valid ? ~acked : {NUM_M{1'b0}};
always @(posedge clk)
begin
  if (resetn == 1'b0) begin
    acked <= {NUM_M{1'b0}};
  end else begin
    if (s_valid & s_ready)
      acked <= {NUM_M{1'b0}};
    else
      acked <= acked | (m_ready & m_valid);
  end
end
endmodule
