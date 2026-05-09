`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_7_b2s_incr_cmd #
(
  parameter integer C_AXI_ADDR_WIDTH            = 32
)
(
  input  wire                                 clk           ,
  input  wire                                 reset         ,
  input  wire [C_AXI_ADDR_WIDTH-1:0]          axaddr        ,
  input  wire [7:0]                           axlen         ,
  input  wire [2:0]                           axsize        ,
  input  wire                                 axhandshake   ,
  output wire [C_AXI_ADDR_WIDTH-1:0]          cmd_byte_addr ,
  input  wire                                 next          ,
  output reg                                  next_pending
);
reg                           sel_first;
reg  [11:0]                   axaddr_incr;
reg  [8:0]                    axlen_cnt;
reg                           next_pending_r;
wire [3:0]                    axsize_shift;
wire [11:0]                   axsize_mask;
localparam    L_AXI_ADDR_LOW_BIT = (C_AXI_ADDR_WIDTH >= 12) ? 12 : 11;
generate
  if (C_AXI_ADDR_WIDTH > 12) begin : ADDR_GT_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : {axaddr[C_AXI_ADDR_WIDTH-1:L_AXI_ADDR_LOW_BIT],axaddr_incr[11:0]};
  end else begin : ADDR_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : axaddr_incr[11:0];
  end
endgenerate
assign axsize_shift = (1 << axsize[1:0]);
assign axsize_mask  = ~(axsize_shift - 1'b1);
always @(posedge clk) begin
  if (sel_first) begin
    if(~next) begin
      axaddr_incr <= axaddr[11:0] & axsize_mask;
    end else begin
      axaddr_incr <= (axaddr[11:0] & axsize_mask) + axsize_shift;
    end
  end else if (next) begin
    axaddr_incr <= axaddr_incr + axsize_shift;
  end
end
always @(posedge clk) begin
  if (axhandshake)begin
     axlen_cnt <= axlen;
     next_pending_r <= (axlen >= 1);
  end else if (next) begin
    if (axlen_cnt > 1) begin
      axlen_cnt <= axlen_cnt - 1;
      next_pending_r <= ((axlen_cnt - 1) >= 1);
    end else begin
      axlen_cnt <= 9'd0;
      next_pending_r <= 1'b0;
    end
  end
end
always @( * ) begin
  if (axhandshake)begin
     next_pending = (axlen >= 1);
  end else if (next) begin
    if (axlen_cnt > 1) begin
      next_pending = ((axlen_cnt - 1) >= 1);
    end else begin
      next_pending = 1'b0;
    end
  end else begin
    next_pending = next_pending_r;
  end
end
always @(posedge clk) begin
  if (reset | axhandshake) begin
    sel_first <= 1'b1;
  end else if (next) begin
    sel_first <= 1'b0;
  end
end
endmodule
`default_nettype wire
