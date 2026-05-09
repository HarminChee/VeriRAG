`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module mig_7series_v4_0_axi_mc_wrap_cmd #
(
  parameter integer C_AXI_ADDR_WIDTH            = 32, 
  parameter integer C_MC_ADDR_WIDTH             = 30,
  parameter integer C_MC_BURST_LEN              = 1,
  parameter integer C_DATA_WIDTH                = 32,
  parameter integer C_AXSIZE                    = 2,
  parameter integer C_MC_RD_INST                = 0
)
(
  input  wire                                 clk           , 
  input  wire                                 reset         , 
  input  wire [C_AXI_ADDR_WIDTH-1:0]          axaddr        , 
  input  wire [7:0]                           axlen         , 
  input  wire [2:0]                           axsize        , 
  input  wire                                 axhandshake   , 
  output wire [C_AXI_ADDR_WIDTH-1:0]          cmd_byte_addr ,
  output wire                                 ignore_begin  ,
  output wire                                 ignore_end    ,
  input  wire                                 next          , 
  output wire                                 next_pending 
);
localparam P_AXLEN_WIDTH = 4;
reg                         sel_first_r;
reg  [3:0]                  axlen_cnt;
reg  [3:0]                  int_addr;
reg                         int_next_pending_r;
wire                        sel_first;
wire [3:0]                  axlen_i;
wire [3:0]                  axlen_cnt_i;
wire [3:0]                  axlen_cnt_t;
wire [3:0]                  axlen_cnt_p;
wire                        addr_offset;
wire  [C_AXI_ADDR_WIDTH-1:0] axaddr_wrap;
wire [3:0]                  int_addr_t;
wire [3:0]                  int_addr_p;
wire [3:0]                  int_addr_t_inc;
wire                        int_next_pending;
wire                        extra_cmd;
assign cmd_byte_addr = axaddr_wrap;
assign axlen_i = axlen[3:0];
assign axaddr_wrap = {axaddr[C_AXI_ADDR_WIDTH-1:C_AXSIZE+4], int_addr_t[3:0], axaddr[C_AXSIZE-1:0]};
generate
  if(C_MC_BURST_LEN == 1) begin
    assign addr_offset = 1'b0;
    assign int_addr_t = axhandshake ? (axaddr[C_AXSIZE+: 4]) : int_addr;
  end else begin
    assign addr_offset = axaddr[C_AXSIZE];
    if(C_MC_RD_INST == 0) 
      assign int_addr_t = int_addr;
    else
      assign int_addr_t = axhandshake ? (axaddr[C_AXSIZE+: 4]) : int_addr;
  end
endgenerate
assign int_addr_t_inc = int_addr_t + C_MC_BURST_LEN;
assign int_addr_p = ((int_addr_t & ~axlen_i) | (int_addr_t_inc & axlen_i));
always @(posedge clk) begin
  if(reset)
    int_addr <= 4'h0;
  else if (axhandshake & ~next)
    int_addr <= (axaddr[C_AXSIZE+: 4]);
  else if(next)
    int_addr <= int_addr_p;
end
assign axlen_cnt_i = (C_MC_BURST_LEN == 1) ? axlen_i : (axlen_i >> 1);
assign axlen_cnt_t = axhandshake ? axlen_cnt_i : axlen_cnt;
assign axlen_cnt_p = (axlen_cnt_t - 1'b1);
always @(posedge clk) begin
  if(reset)
    axlen_cnt <= 4'hf;
  else if (axhandshake & ~next)
    axlen_cnt <= axlen_cnt_i;
  else if(next)
    axlen_cnt <= axlen_cnt_p;
end  
assign extra_cmd = addr_offset;
assign next_pending = extra_cmd ? int_next_pending_r : int_next_pending;
assign int_next_pending = |axlen_cnt_t;
always @(posedge clk) begin
  if(reset)
    int_next_pending_r <= 1'b1;
  else if(extra_cmd & next)
    int_next_pending_r <= int_next_pending;
end
assign ignore_begin = sel_first ? addr_offset : 1'b0;
assign ignore_end = next_pending ? 1'b0 : addr_offset;
assign sel_first = (axhandshake | sel_first_r);
always @(posedge clk) begin
  if (reset)
    sel_first_r <= 1'b0;
  else if(axhandshake & ~next)
    sel_first_r <= 1'b1;
  else if(next)
    sel_first_r <= 1'b0;
end
endmodule
`default_nettype wire
