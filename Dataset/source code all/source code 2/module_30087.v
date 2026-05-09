`timescale 1ns/1ps
`timescale 1ns/1ps
module shifter #(
  parameter integer DW = 32
)(
  input  wire          clk,
  input  wire          rst,
  input  wire          ctl_clr,
  input  wire          ctl_ena,
  input  wire [DW-1:0] cfg_mask,
  input  wire          sti_valid,
  output wire          sti_ready,
  input  wire [DW-1:0] sti_data,
  output wire          sto_valid,
  input  wire          sto_ready,
  output wire [DW-1:0] sto_data
);
localparam DL = $clog2(DW);
wire sti_transfer;
assign sti_transfer = sti_valid & sti_ready;
reg  [DL-1:0] [DW-1:0] pipe_data;
reg  [DL-1:0]          pipe_valid = {DL{1'b0}};
wire [DL-1:0]          pipe_ready;
reg  [DW-1:0] [DL-1:0] shift;
always @ (posedge clk, posedge rst)
if (rst) begin
  pipe_valid <= {DL{1'b0}};
end else if (ctl_ena) begin
  pipe_valid <= {pipe_valid [DL-2:0], sti_valid};
end
genvar l, b;
generate
  for (l=0; l<DL; l=l+1) begin: layer
    for (b=0; b<DW; b=b+1) begin: dbit
      always @ (posedge clk)
      if (ctl_ena)  pipe_data[l][b] <= shift[b][l] ? pipe_data[l-1][(b+l)%DW] : pipe_data[l-1][b];
    end
  end
endgenerate
assign sto_valid = !ctl_ena ? sti_valid : pipe_valid[DL-1];
assign sto_data  = !ctl_ena ? sti_data  : pipe_data [DL-1];
assign sti_ready = !ctl_ena ? sto_ready : pipe_ready[0] | ~pipe_valid[0];
endmodule
