module emaxi(
   test_i,
   wr_wait, rd_wait, rr_access, rr_packet, m_axi_awid, m_axi_awaddr,
   m_axi_awlen, m_axi_awsize, m_axi_awburst, m_axi_awlock,
   m_axi_awcache, m_axi_awprot, m_axi_awqos, m_axi_awvalid, m_axi_wid,
   m_axi_wdata, m_axi_wstrb, m_axi_wlast, m_axi_wvalid, m_axi_bready,
   m_axi_arid, m_axi_araddr, m_axi_arlen, m_axi_arsize, m_axi_arburst,
   m_axi_arlock, m_axi_arcache, m_axi_arprot, m_axi_arqos,
   m_axi_arvalid, m_axi_rready,
   wr_access, wr_packet, rd_access, rd_packet, rr_wait, m_axi_aclk,
   m_axi_aresetn, m_axi_awready, m_axi_wready, m_axi_bid, m_axi_bresp,
   m_axi_bvalid, m_axi_arready, m_axi_rid, m_axi_rdata, m_axi_rresp,
   m_axi_rlast, m_axi_rvalid
   );

input test_i;
input m_axi_aclk;
input m_axi_aresetn;
input wr_wait;
input rd_wait;
input rr_access;
input [127:0] rr_packet;
output [3:0] m_axi_awid;
output [31:0] m_axi_awaddr;
output [7:0] m_axi_awlen;
output [2:0] m_axi_awsize;
output [1:0] m_axi_awburst;
output [1:0] m_axi_awlock;
output [3:0] m_axi_awcache;
output [2:0] m_axi_awprot;
output [3:0] m_axi_awqos;
output m_axi_awvalid;
output [3:0] m_axi_wid;
output [63:0] m_axi_wdata;
output [7:0] m_axi_wstrb;
output m_axi_wlast;
output m_axi_wvalid;
output m_axi_bready;
output [3:0] m_axi_arid;
output [31:0] m_axi_araddr;
output [7:0] m_axi_arlen;
output [2:0] m_axi_arsize;
output [1:0] m_axi_arburst;
output [1:0] m_axi_arlock;
output [3:0] m_axi_arcache;
output [2:0] m_axi_arprot;
output [3:0] m_axi_arqos;
output m_axi_arvalid;
output m_axi_rready;
input wr_access;
input [127:0] wr_packet;
input rd_access;
input [127:0] rd_packet;
output rr_wait;
input m_axi_awready;
input m_axi_wready;
input [3:0] m_axi_bid;
input [1:0] m_axi_bresp;
input m_axi_bvalid;
input m_axi_arready;
input [3:0] m_axi_rid;
input [63:0] m_axi_rdata;
input [1:0] m_axi_rresp;
input m_axi_rlast;
input m_axi_rvalid;

reg [3:0] SEL_Cont;
reg oAUD_BCK;

always @(posedge m_axi_aclk or negedge m_axi_aresetn)
begin
    if(!m_axi_aresetn)
        SEL_Cont <= 0;
    else
        SEL_Cont <= SEL_Cont+1;
end

endmodule