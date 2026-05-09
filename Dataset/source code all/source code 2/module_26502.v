`timescale 1ns/100ps
`timescale 1ns/100ps
module sync_bits #(
  parameter NUM_OF_BITS = 1,
  parameter ASYNC_CLK = 1)(
  input [NUM_OF_BITS-1:0] in,
  input out_resetn,
  input out_clk,
  output [NUM_OF_BITS-1:0] out);
generate if (ASYNC_CLK == 1) begin
  reg [NUM_OF_BITS-1:0] cdc_sync_stage1 = 'h0;
  reg [NUM_OF_BITS-1:0] cdc_sync_stage2 = 'h0;
  always @(posedge out_clk)
  begin
    if (out_resetn == 1'b0) begin
      cdc_sync_stage1 <= 'b0;
      cdc_sync_stage2 <= 'b0;
    end else begin
      cdc_sync_stage1 <= in;
      cdc_sync_stage2 <= cdc_sync_stage1;
    end
  end
  assign out = cdc_sync_stage2;
end else begin
  assign out = in;
end endgenerate
endmodule
