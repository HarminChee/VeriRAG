`timescale 1ps/1ps
`timescale 1ps/1ps
module axi_protocol_converter_v2_1_8_axilite_conv #
  (
   parameter         C_FAMILY                    = "virtex6",
   parameter integer C_AXI_ID_WIDTH              = 1,
   parameter integer C_AXI_ADDR_WIDTH            = 32,
   parameter integer C_AXI_DATA_WIDTH            = 32,
   parameter integer C_AXI_SUPPORTS_WRITE        = 1,
   parameter integer C_AXI_SUPPORTS_READ         = 1,
   parameter integer C_AXI_RUSER_WIDTH                = 1,
   parameter integer C_AXI_BUSER_WIDTH                = 1
   )
  (
   input  wire                          ACLK,
   input  wire                          ARESETN,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_AWID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_AWADDR,
   input  wire [3-1:0]                  S_AXI_AWPROT,
   input  wire                          S_AXI_AWVALID,
   output wire                          S_AXI_AWREADY,
   input  wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_WDATA,
   input  wire [C_AXI_DATA_WIDTH/8-1:0] S_AXI_WSTRB,
   input  wire                          S_AXI_WVALID,
   output wire                          S_AXI_WREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     S_AXI_BID,
   output wire [2-1:0]                  S_AXI_BRESP,
   output wire [C_AXI_BUSER_WIDTH-1:0]  S_AXI_BUSER,    
   output wire                          S_AXI_BVALID,
   input  wire                          S_AXI_BREADY,
   input  wire [C_AXI_ID_WIDTH-1:0]     S_AXI_ARID,
   input  wire [C_AXI_ADDR_WIDTH-1:0]   S_AXI_ARADDR,
   input  wire [3-1:0]                  S_AXI_ARPROT,
   input  wire                          S_AXI_ARVALID,
   output wire                          S_AXI_ARREADY,
   output wire [C_AXI_ID_WIDTH-1:0]     S_AXI_RID,
   output wire [C_AXI_DATA_WIDTH-1:0]   S_AXI_RDATA,
   output wire [2-1:0]                  S_AXI_RRESP,
   output wire                          S_AXI_RLAST,    
   output wire [C_AXI_RUSER_WIDTH-1:0]  S_AXI_RUSER,    
   output wire                          S_AXI_RVALID,
   input  wire                          S_AXI_RREADY,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_AWADDR,
   output wire [3-1:0]                  M_AXI_AWPROT,
   output wire                          M_AXI_AWVALID,
   input  wire                          M_AXI_AWREADY,
   output wire [C_AXI_DATA_WIDTH-1:0]   M_AXI_WDATA,
   output wire [C_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
   output wire                          M_AXI_WVALID,
   input  wire                          M_AXI_WREADY,
   input  wire [2-1:0]                  M_AXI_BRESP,
   input  wire                          M_AXI_BVALID,
   output wire                          M_AXI_BREADY,
   output wire [C_AXI_ADDR_WIDTH-1:0]   M_AXI_ARADDR,
   output wire [3-1:0]                  M_AXI_ARPROT,
   output wire                          M_AXI_ARVALID,
   input  wire                          M_AXI_ARREADY,
   input  wire [C_AXI_DATA_WIDTH-1:0]   M_AXI_RDATA,
   input  wire [2-1:0]                  M_AXI_RRESP,
   input  wire                          M_AXI_RVALID,
   output wire                          M_AXI_RREADY
  );
  wire s_awvalid_i;
  wire s_arvalid_i;
  wire [C_AXI_ADDR_WIDTH-1:0] m_axaddr;
  reg read_active;
  reg write_active;
  reg busy;
  wire read_req;
  wire write_req;
  wire read_complete;
  wire write_complete;
  reg [1:0] areset_d; 
  always @(posedge ACLK) begin
    areset_d <= {areset_d[0], ~ARESETN};
  end
  assign s_awvalid_i = S_AXI_AWVALID & (C_AXI_SUPPORTS_WRITE != 0);
  assign s_arvalid_i = S_AXI_ARVALID & (C_AXI_SUPPORTS_READ != 0);
  assign read_req  = s_arvalid_i & ~busy & ~|areset_d & ~write_active;
  assign write_req = s_awvalid_i & ~busy & ~|areset_d & ((~read_active & ~s_arvalid_i) | write_active);
  assign read_complete  = M_AXI_RVALID & S_AXI_RREADY;
  assign write_complete = M_AXI_BVALID & S_AXI_BREADY;
  always @(posedge ACLK) begin : arbiter_read_ff
    if (|areset_d)
      read_active <= 1'b0;
    else if (read_complete)
      read_active <= 1'b0;
    else if (read_req)
      read_active <= 1'b1;
  end
  always @(posedge ACLK) begin : arbiter_write_ff
    if (|areset_d)
      write_active <= 1'b0;
    else if (write_complete)
      write_active <= 1'b0;
    else if (write_req)
      write_active <= 1'b1;
  end
  always @(posedge ACLK) begin : arbiter_busy_ff
    if (|areset_d)
      busy <= 1'b0;
    else if (read_complete | write_complete)
      busy <= 1'b0;
    else if ((write_req & M_AXI_AWREADY) | (read_req & M_AXI_ARREADY))
      busy <= 1'b1;
  end
  assign M_AXI_ARVALID = read_req;
  assign S_AXI_ARREADY = M_AXI_ARREADY & read_req;
  assign M_AXI_AWVALID = write_req;
  assign S_AXI_AWREADY = M_AXI_AWREADY & write_req;
  assign M_AXI_RREADY  = S_AXI_RREADY & read_active;
  assign S_AXI_RVALID  = M_AXI_RVALID & read_active;
  assign M_AXI_BREADY  = S_AXI_BREADY & write_active;
  assign S_AXI_BVALID  = M_AXI_BVALID & write_active;
  assign m_axaddr = (read_req | (C_AXI_SUPPORTS_WRITE == 0)) ? S_AXI_ARADDR : S_AXI_AWADDR;
  reg [C_AXI_ID_WIDTH-1:0] s_axid;
  always @(posedge ACLK) begin : axid
    if      (read_req)  s_axid <= S_AXI_ARID;
    else if (write_req) s_axid <= S_AXI_AWID;
  end
  assign S_AXI_BID = s_axid;
  assign S_AXI_RID = s_axid;
  assign M_AXI_AWADDR = m_axaddr;
  assign M_AXI_ARADDR = m_axaddr;
  assign S_AXI_WREADY   = M_AXI_WREADY & ~|areset_d;
  assign S_AXI_BRESP    = M_AXI_BRESP;
  assign S_AXI_RDATA    = M_AXI_RDATA;
  assign S_AXI_RRESP    = M_AXI_RRESP;
  assign S_AXI_RLAST    = 1'b1;
  assign S_AXI_BUSER    = {C_AXI_BUSER_WIDTH{1'b0}};
  assign S_AXI_RUSER    = {C_AXI_RUSER_WIDTH{1'b0}};
  assign M_AXI_AWPROT   = S_AXI_AWPROT;
  assign M_AXI_WVALID   = S_AXI_WVALID & ~|areset_d;
  assign M_AXI_WDATA    = S_AXI_WDATA;
  assign M_AXI_WSTRB    = S_AXI_WSTRB;
  assign M_AXI_ARPROT   = S_AXI_ARPROT;
endmodule
