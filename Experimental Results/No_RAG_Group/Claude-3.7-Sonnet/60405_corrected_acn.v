module emaxi(
   wr_wait, rd_wait, rr_access, rr_packet, m_axi_awid, m_axi_awaddr,
   m_axi_awlen, m_axi_awsize, m_axi_awburst, m_axi_awlock,
   m_axi_awcache, m_axi_awprot, m_axi_awqos, m_axi_awvalid, m_axi_wid,
   m_axi_wdata, m_axi_wstrb, m_axi_wlast, m_axi_wvalid, m_axi_bready,
   m_axi_arid, m_axi_araddr, m_axi_arlen, m_axi_arsize, m_axi_arburst,
   m_axi_arlock, m_axi_arcache, m_axi_arprot, m_axi_arqos,
   m_axi_arvalid, m_axi_rready,
   wr_access, wr_packet, rd_access, rd_packet, rr_wait, m_axi_aclk,
   m_axi_aresetn_in, m_axi_awready, m_axi_wready, m_axi_bid, m_axi_bresp,
   m_axi_bvalid, m_axi_arready, m_axi_rid, m_axi_rdata, m_axi_rresp,
   m_axi_rlast, m_axi_rvalid
   );
   parameter M_IDW  = 12;
   parameter PW     = 104;
   parameter AW     = 32;
   parameter DW     = 32;
   input 	       wr_access;
   input [PW-1:0]      wr_packet;   
   output 	       wr_wait;
   input 	       rd_access;
   input [PW-1:0]      rd_packet;
   output 	       rd_wait;
   output 	       rr_access;
   output [PW-1:0]     rr_packet;
   input 	       rr_wait;
   input  	       m_axi_aclk;    
   input  	       m_axi_aresetn_in; // Changed from m_axi_aresetn to m_axi_aresetn_in
   output [M_IDW-1:0]  m_axi_awid;    
   output [31 : 0]     m_axi_awaddr;  
   output [7 : 0]      m_axi_awlen;   
   output [2 : 0]      m_axi_awsize;  
   output [1 : 0]      m_axi_awburst; 
   output              m_axi_awlock;  
   output [3 : 0]      m_axi_awcache; 
   output [2 : 0]      m_axi_awprot;  
   output [3 : 0]      m_axi_awqos;   
   output 	       m_axi_awvalid; 
   input 	       m_axi_awready; 
   output [M_IDW-1:0]  m_axi_wid;     
   output [63 : 0]     m_axi_wdata;   
   output [7 : 0]      m_axi_wstrb;   
   output 	       m_axi_wlast;   
   output 	       m_axi_wvalid;  
   input 	       m_axi_wready;  
   input [M_IDW-1:0]   m_axi_bid;
   input [1 : 0]       m_axi_bresp;   
   input 	       m_axi_bvalid;  
   output 	       m_axi_bready;  
   output [M_IDW-1:0]  m_axi_arid;    
   output [31 : 0]     m_axi_araddr;  
   output [7 : 0]      m_axi_arlen;   
   output [2 : 0]      m_axi_arsize;  
   output [1 : 0]      m_axi_arburst; 
   output              m_axi_arlock;  
   output [3 : 0]      m_axi_arcache; 
   output [2 : 0]      m_axi_arprot;  
   output [3 : 0]      m_axi_arqos;   
   output 	       m_axi_arvalid; 
   input 	       m_axi_arready; 
   input [M_IDW-1:0]   m_axi_rid;     
   input [63 : 0]      m_axi_rdata;   
   input [1 : 0]       m_axi_rresp;   
   input 	       m_axi_rlast;   
   input 	       m_axi_rvalid;  
   output 	       m_axi_rready;  

   // Internal reset signal derived from input reset
   wire m_axi_aresetn;
   assign m_axi_aresetn = m_axi_aresetn_in;

   reg [31 : 0]        m_axi_awaddr;
   reg [7:0] 	       m_axi_awlen;
   reg [2:0] 	       m_axi_awsize;
   reg 		       m_axi_awvalid;
   reg [63 : 0]        m_axi_wdata;
   reg [63 : 0]        m_axi_rdata_reg;
   reg [7 : 0] 	       m_axi_wstrb;
   reg 		       m_axi_wlast;
   reg 		       m_axi_wvalid;
   reg 		       awvalid_b;
   reg [31:0] 	       awaddr_b;
   reg [2:0] 	       awsize_b;
   reg [7:0] 	       awlen_b;
   reg 		       wvalid_b;
   reg [63:0] 	       wdata_b;
   reg [7:0] 	       wstrb_b;
   reg [63 : 0]        wdata_aligned;
   reg [7 : 0] 	       wstrb_aligned;
   reg 		       rr_access;
   reg [31:0] 	       rr_data;
   reg [31:0] 	       rr_srcaddr;
   reg [3:0] 	       rr_datamode;
   reg [3:0] 	       rr_ctrlmode;
   reg [31:0] 	       rr_dstaddr;
   reg [63:0] 	       m_axi_rdata_fifo;
   reg 		       rr_access_fifo;

   // Rest of the code remains unchanged
   // ... existing code ...

endmodule