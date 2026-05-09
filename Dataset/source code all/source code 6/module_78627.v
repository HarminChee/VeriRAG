`timescale 1ps/1ps
`timescale 1ps/1ps
module processing_system7_v5_3_aw_atc #
  (
   parameter         C_FAMILY                         = "rtl", 
   parameter integer C_AXI_ID_WIDTH                   = 4, 
   parameter integer C_AXI_ADDR_WIDTH                 = 32, 
   parameter integer C_AXI_AWUSER_WIDTH               = 1,
   parameter integer C_FIFO_DEPTH_LOG                 = 4
   )
  (
   input  wire                                  ARESET,
   input  wire                                  ACLK,
   output reg                                   cmd_w_valid,
   output wire                                  cmd_w_check,
   output wire [C_AXI_ID_WIDTH-1:0]             cmd_w_id,
   input  wire                                  cmd_w_ready,
   input  wire [C_FIFO_DEPTH_LOG-1:0]           cmd_b_addr,
   input  wire                                  cmd_b_ready,
   input  wire [C_AXI_ID_WIDTH-1:0]             S_AXI_AWID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]           S_AXI_AWADDR,
   input  wire [4-1:0]                          S_AXI_AWLEN,
   input  wire [3-1:0]                          S_AXI_AWSIZE,
   input  wire [2-1:0]                          S_AXI_AWBURST,
   input  wire [2-1:0]                          S_AXI_AWLOCK,
   input  wire [4-1:0]                          S_AXI_AWCACHE,
   input  wire [3-1:0]                          S_AXI_AWPROT,
   input  wire [C_AXI_AWUSER_WIDTH-1:0]         S_AXI_AWUSER,
   input  wire                                  S_AXI_AWVALID,
   output wire                                  S_AXI_AWREADY,
   output wire [C_AXI_ID_WIDTH-1:0]             M_AXI_AWID,
   output wire [C_AXI_ADDR_WIDTH-1:0]           M_AXI_AWADDR,
   output wire [4-1:0]                          M_AXI_AWLEN,
   output wire [3-1:0]                          M_AXI_AWSIZE,
   output wire [2-1:0]                          M_AXI_AWBURST,
   output wire [2-1:0]                          M_AXI_AWLOCK,
   output wire [4-1:0]                          M_AXI_AWCACHE,
   output wire [3-1:0]                          M_AXI_AWPROT,
   output wire [C_AXI_AWUSER_WIDTH-1:0]         M_AXI_AWUSER,
   output wire                                  M_AXI_AWVALID,
   input  wire                                  M_AXI_AWREADY
   );
  localparam [2-1:0] C_FIX_BURST         = 2'b00;
  localparam [2-1:0] C_INCR_BURST        = 2'b01;
  localparam [2-1:0] C_WRAP_BURST        = 2'b10;
  localparam [3-1:0] C_OPTIMIZED_SIZE    = 3'b011;
  localparam [4-1:0] C_OPTIMIZED_LEN     = 4'b0011;
  localparam [4-1:0] C_NO_ADDR_OFFSET    = 5'b0;
  localparam C_FIFO_WIDTH                = C_AXI_ID_WIDTH + 1;
  localparam C_FIFO_DEPTH                = 2 ** C_FIFO_DEPTH_LOG;
  integer index;
  wire                                access_is_incr;
  wire                                access_is_wrap;
  wire                                access_is_coherent;
  wire                                access_optimized_size;
  wire                                incr_addr_boundary;
  wire                                incr_is_optimized;
  wire                                wrap_is_optimized;
  wire                                access_is_optimized;
  wire                                cmd_w_push;
  reg                                 cmd_full;
  reg  [C_FIFO_DEPTH_LOG-1:0]         addr_ptr;
  wire [C_FIFO_DEPTH_LOG-1:0]         all_addr_ptr;
  reg  [C_FIFO_WIDTH-1:0]             data_srl[C_FIFO_DEPTH-1:0];
  assign access_is_incr         = ( S_AXI_AWBURST == C_INCR_BURST );
  assign access_is_wrap         = ( S_AXI_AWBURST == C_WRAP_BURST );
  assign access_is_coherent     = ( S_AXI_AWUSER[0]  == 1'b1 ) &
                                  ( S_AXI_AWCACHE[1] == 1'b1 );
  assign incr_addr_boundary     = ( S_AXI_AWADDR[4:0] == C_NO_ADDR_OFFSET );
  assign access_optimized_size  = ( S_AXI_AWSIZE == C_OPTIMIZED_SIZE ) & 
                                  ( S_AXI_AWLEN  == C_OPTIMIZED_LEN  );
  assign incr_is_optimized      = access_is_incr & access_is_coherent & access_optimized_size & incr_addr_boundary;
  assign wrap_is_optimized      = access_is_wrap & access_is_coherent & access_optimized_size;
  assign access_is_optimized    = ( incr_is_optimized | wrap_is_optimized );
  assign cmd_w_push = S_AXI_AWVALID & M_AXI_AWREADY & ~cmd_full;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      addr_ptr <= {C_FIFO_DEPTH_LOG{1'b1}};
    end else begin
      if ( cmd_w_push & ~cmd_w_ready ) begin
        addr_ptr <= addr_ptr + 1;
      end else if ( ~cmd_w_push & cmd_w_ready ) begin
        addr_ptr <= addr_ptr - 1;
      end
    end
  end
  assign all_addr_ptr = addr_ptr + cmd_b_addr + 2;
  always @ (posedge ACLK) begin
    if (ARESET) begin
      cmd_full    <= 1'b0;
      cmd_w_valid <= 1'b0;
    end else begin
      if ( cmd_w_push & ~cmd_w_ready ) begin
        cmd_w_valid <= 1'b1;
      end else if ( ~cmd_w_push & cmd_w_ready ) begin
        cmd_w_valid <= ( addr_ptr != 0 );
      end
      if ( cmd_w_push & ~cmd_b_ready ) begin
        cmd_full    <= ( all_addr_ptr == C_FIFO_DEPTH-3 );
      end else if ( ~cmd_w_push & cmd_b_ready ) begin
        cmd_full    <= ( all_addr_ptr == C_FIFO_DEPTH-2 );
      end
    end
  end
  always @ (posedge ACLK) begin
    if ( cmd_w_push ) begin
      for (index = 0; index < C_FIFO_DEPTH-1 ; index = index + 1) begin
        data_srl[index+1] <= data_srl[index];
      end
      data_srl[0]   <= {access_is_optimized, S_AXI_AWID};
    end
  end
  assign {cmd_w_check, cmd_w_id} = data_srl[addr_ptr];
  assign M_AXI_AWVALID   = S_AXI_AWVALID & ~cmd_full;
  assign S_AXI_AWREADY   = M_AXI_AWREADY & ~cmd_full;
  assign M_AXI_AWID      = S_AXI_AWID; 
  assign M_AXI_AWADDR    = S_AXI_AWADDR;
  assign M_AXI_AWLEN     = S_AXI_AWLEN;
  assign M_AXI_AWSIZE    = S_AXI_AWSIZE;
  assign M_AXI_AWBURST   = S_AXI_AWBURST;
  assign M_AXI_AWLOCK    = S_AXI_AWLOCK;
  assign M_AXI_AWCACHE   = S_AXI_AWCACHE;
  assign M_AXI_AWPROT    = S_AXI_AWPROT;
  assign M_AXI_AWUSER    = S_AXI_AWUSER;
endmodule
