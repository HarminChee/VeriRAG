`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_7_b2s_wrap_cmd #
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
reg                         sel_first;
wire [11:0]                 axaddr_i;
wire [3:0]                  axlen_i;
reg  [11:0]                 wrap_boundary_axaddr;
reg  [3:0]                  axaddr_offset;
reg  [3:0]                  wrap_second_len;
reg  [11:0]                 wrap_boundary_axaddr_r;
reg  [3:0]                  axaddr_offset_r;
reg  [3:0]                  wrap_second_len_r;
reg  [4:0]                  axlen_cnt;
reg  [4:0]                  wrap_cnt_r;
wire [4:0]                  wrap_cnt;
reg  [11:0]                 axaddr_wrap;
reg                         next_pending_r;
localparam    L_AXI_ADDR_LOW_BIT = (C_AXI_ADDR_WIDTH >= 12) ? 12 : 11;
generate
  if (C_AXI_ADDR_WIDTH > 12) begin : ADDR_GT_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : {axaddr[C_AXI_ADDR_WIDTH-1:L_AXI_ADDR_LOW_BIT],axaddr_wrap[11:0]};
  end else begin : ADDR_4K
    assign cmd_byte_addr = (sel_first) ? axaddr : axaddr_wrap[11:0];
  end
endgenerate
assign axaddr_i = axaddr[11:0];
assign axlen_i = axlen[3:0];
always @( * ) begin
  if(axhandshake) begin
    wrap_boundary_axaddr = axaddr_i & ~(axlen_i << axsize[1:0]);
    axaddr_offset = axaddr_i[axsize[1:0] +: 4] & axlen_i;
  end else begin
    wrap_boundary_axaddr = wrap_boundary_axaddr_r;
    axaddr_offset = axaddr_offset_r; 
  end
end
always @( * ) begin
  if(axhandshake) begin
    wrap_second_len = (axaddr_offset >0) ? axaddr_offset - 1 : 0;
  end else begin
    wrap_second_len = wrap_second_len_r;
  end
end
always @(posedge clk) begin
  wrap_boundary_axaddr_r <= wrap_boundary_axaddr;
  axaddr_offset_r <= axaddr_offset;
  wrap_second_len_r <= wrap_second_len;
end
assign wrap_cnt = {1'b0, wrap_second_len + {3'b000, (|axaddr_offset)}}; 
always @(posedge clk)
  wrap_cnt_r <= wrap_cnt;
always @(posedge clk) begin
  if (axhandshake) begin
    axaddr_wrap <= axaddr[11:0];
  end if(next)begin
    if(axlen_cnt == wrap_cnt_r) begin
      axaddr_wrap <= wrap_boundary_axaddr_r;
    end else begin
      axaddr_wrap <= axaddr_wrap + (1 << axsize[1:0]);
    end
  end
end 
always @(posedge clk) begin
  if (axhandshake)begin
    axlen_cnt <= axlen_i;
    next_pending_r <= axlen_i >= 1;
  end else if (next) begin
    if (axlen_cnt > 1) begin
      axlen_cnt <= axlen_cnt - 1;
      next_pending_r <= (axlen_cnt - 1) >= 1;
    end else begin
      axlen_cnt <= 5'd0;
      next_pending_r <= 1'b0;
    end
  end  
end  
always @( * ) begin
  if (axhandshake)begin
    next_pending = axlen_i >= 1;
  end else if (next) begin
    if (axlen_cnt > 1) begin
      next_pending = (axlen_cnt - 1) >= 1;
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
