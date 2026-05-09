module emaxi_corrected_acn (
    // Outputs driven by this module (or bidirectional)
    wr_wait,
    rd_wait,
    rr_access,
    rr_packet,
    m_axi_awid,
    m_axi_awaddr,
    m_axi_awlen,
    m_axi_awsize,
    m_axi_awburst,
    m_axi_awlock,
    m_axi_awcache,
    m_axi_awprot,
    m_axi_awqos,
    m_axi_awvalid,
    m_axi_wid,
    m_axi_wdata,
    m_axi_wstrb,
    m_axi_wlast,
    m_axi_wvalid,
    m_axi_bready,
    m_axi_arid,
    m_axi_araddr,
    m_axi_arlen,
    m_axi_arsize,
    m_axi_arburst,
    m_axi_arlock,
    m_axi_arcache,
    m_axi_arprot,
    m_axi_arqos,
    m_axi_arvalid,
    m_axi_rready,

    // Inputs to this module
    wr_access,
    wr_packet,
    rd_access,
    rd_packet,
    rr_wait,
    m_axi_aclk,
    m_axi_aresetn,
    m_axi_awready,
    m_axi_wready,
    m_axi_bid,
    m_axi_bresp,
    m_axi_bvalid,
    m_axi_arready,
    m_axi_rid,
    m_axi_rdata,
    m_axi_rresp,
    m_axi_rlast,
    m_axi_rvalid
);
   parameter M_IDW  = 12;
   parameter PW     = 104;
   parameter AW     = 32;
   parameter DW     = 32;

   input 	       wr_access;
   input [PW-1:0]      wr_packet;
   output reg          wr_wait; // Made reg as assigned in assign wr_wait = awvalid_b | wvalid_b; - Correction: assign is fine.
   output wire         wr_wait; // Reverted to wire - combinatorial assignment exists

   input 	       rd_access;
   input [PW-1:0]      rd_packet;
   output wire         rd_wait; // Changed to wire as assigned combinationally

   output reg          rr_access; // Keep reg as assigned in always block
   output wire [PW-1:0]     rr_packet; // Assigned via e2p instance

   input 	       rr_wait;
   input  	       m_axi_aclk;
   input  	       m_axi_aresetn;

   output wire [M_IDW-1:0]  m_axi_awid;
   output reg [31 : 0]     m_axi_awaddr;
   output reg [7 : 0]      m_axi_awlen;
   output reg [2 : 0]      m_axi_awsize;
   output wire [1 : 0]      m_axi_awburst;
   output wire              m_axi_awlock;
   output wire [3 : 0]      m_axi_awcache;
   output wire [2 : 0]      m_axi_awprot;
   output wire [3 : 0]      m_axi_awqos;
   output reg 	       m_axi_awvalid;
   input 	       m_axi_awready;

   output wire [M_IDW-1:0]  m_axi_wid;
   output reg [63 : 0]     m_axi_wdata;
   output reg [7 : 0]      m_axi_wstrb;
   output reg 	       m_axi_wlast;
   output reg 	       m_axi_wvalid;
   input 	       m_axi_wready;

   input [M_IDW-1:0]   m_axi_bid;
   input [1 : 0]       m_axi_bresp;
   input 	       m_axi_bvalid;
   output wire         m_axi_bready;

   output wire [M_IDW-1:0]  m_axi_arid;
   output wire [31 : 0]     m_axi_araddr; // Changed to wire as assigned combinationally
   output wire [7 : 0]      m_axi_arlen; // Changed to wire as assigned combinationally
   output wire [2 : 0]      m_axi_arsize; // Changed to wire as assigned combinationally
   output wire [1 : 0]      m_axi_arburst;
   output wire              m_axi_arlock;
   output wire [3 : 0]      m_axi_arcache;
   output wire [2 : 0]      m_axi_arprot;
   output wire [3 : 0]      m_axi_arqos;
   output wire             m_axi_arvalid; // Changed to wire as assigned combinationally
   input 	       m_axi_arready;

   input [M_IDW-1:0]   m_axi_rid;
   input [63 : 0]      m_axi_rdata;
   input [1 : 0]       m_axi_rresp;
   input 	       m_axi_rlast;
   input 	       m_axi_rvalid;
   output wire         m_axi_rready; // Changed to wire as assigned combinationally

   // Internal signals
   reg [63 : 0]        m_axi_rdata_reg; // This seems unused - can be removed? Keeping for now.
   reg 		       awvalid_b;
   reg [31:0] 	       awaddr_b;
   reg [2:0] 	       awsize_b;
   reg [7:0] 	       awlen_b;
   reg 		       wvalid_b;
   reg [63:0] 	       wdata_b;
   reg [7:0] 	       wstrb_b;
   reg [63 : 0]        wdata_aligned;
   reg [7 : 0] 	       wstrb_aligned;

   reg [31:0] 	       rr_data;
   reg [31:0] 	       rr_srcaddr;
   reg [1:0] 	       rr_datamode; // Changed width based on assignment
   reg [3:0] 	       rr_ctrlmode;
   reg [31:0] 	       rr_dstaddr;
   reg [63:0] 	       m_axi_rdata_fifo;
   reg 		       rr_access_fifo;

   wire 	       aw_go;
   wire 	       w_go;
   // wire 	       readinfo_wren; // Seems unused
   // wire 	       readinfo_full; // Seems unused
   // wire [40:0] 	       readinfo_out; // Seems unused
   wire [40:0] 	       readinfo_in;
   wire 	       awvalid_in;
   wire [1:0] 	       wr_datamode;
   wire [AW-1:0]       wr_dstaddr;
   wire [DW-1:0]       wr_data;
   wire [AW-1:0]       wr_srcaddr;
   wire [1:0] 	       rd_datamode;
   wire [4:0] 	       rd_ctrlmode; // Width is 5 in p2e_rxrd instance
   wire [AW-1:0]       rd_dstaddr;
   wire [AW-1:0]       rd_srcaddr;
   wire [1:0] 	       rr_datamode_fifo;
   wire [3:0] 	       rr_ctrlmode_fifo;
   wire [31:0] 	       rr_dstaddr_fifo;
   wire [2:0] 	       rr_alignaddr_fifo;
   wire [103:0]        packet_out;
   wire 	       fifo_prog_full;
   wire 	       fifo_full;
   wire 	       fifo_rd_en;
   wire 	       fifo_wr_en;

   // Instantiations (assuming these modules exist and are correct)
   packet2emesh p2e_rxwr (
			  .write_in		(/* connect if needed */), // Assuming write_in is not used based on empty ()
			  .datamode_in		(wr_datamode[1:0]),
			  .ctrlmode_in		(/* connect if needed */), // Assuming ctrlmode_in is not used
			  .dstaddr_in		(wr_dstaddr[AW-1:0]),
			  .data_in		(wr_data[DW-1:0]),
			  .srcaddr_in		(wr_srcaddr[AW-1:0]),
			  .packet_in		(wr_packet[PW-1:0])
			  );

   packet2emesh p2e_rxrd (
			  .write_in		(/* connect if needed */), // Assuming write_in is not used
			  .datamode_in		(rd_datamode[1:0]),
			  .ctrlmode_in		(rd_ctrlmode[4:0]),
			  .dstaddr_in		(rd_dstaddr[AW-1:0]),
			  .data_in		(/* connect if needed */), // Assuming data_in is not used
			  .srcaddr_in		(rd_srcaddr[AW-1:0]),
			  .packet_in		(rd_packet[PW-1:0])
			  );

   emesh2packet e2p (
		     .packet_out	(rr_packet[PW-1:0]),
		     .write_out		(1'b1), // Fixed write_out connection
		     .datamode_out	(rr_datamode[1:0]),
		     .ctrlmode_out	({1'b0, rr_ctrlmode[3:0]}), // Corrected ctrlmode connection based on reg width
		     .dstaddr_out	(rr_dstaddr[AW-1:0]),
		     .data_out		(rr_data[DW-1:0]),
		     .srcaddr_out	(rr_srcaddr[AW-1:0])
		     );

   // AXI Constant Assignments
   assign m_axi_awid[M_IDW-1:0]  = {(M_IDW){1'b0}};
   assign m_axi_awburst[1:0]	= 2'b01; // INCR
   assign m_axi_awcache[3:0]	= 4'b0000; // Device Non-bufferable
   assign m_axi_awprot[2:0]	= 3'b000;  // Unprivileged, Secure, Data
   assign m_axi_awqos[3:0]	= 4'b0000;
   assign m_axi_awlock          = 1'b0;    // Normal access

   assign m_axi_arid[M_IDW-1:0] = {(M_IDW){1'b0}};
   assign m_axi_arburst[1:0]	= 2'b01; // INCR
   assign m_axi_arcache[3:0]	= 4'b0000; // Device Non-bufferable
   assign m_axi_arprot[2:0]	= 3'h0;    // Unprivileged, Secure, Data
   assign m_axi_arqos[3:0]	= 4'h0;
   assign m_axi_arlock          = 1'b0;    // Normal access

   assign m_axi_bready    	= 1'b1;    // Always ready to accept response
   assign m_axi_wid[M_IDW-1:0]  = {(M_IDW){1'b0}}; // Assuming single write ID

   // Control Signals
   assign aw_go       = m_axi_awvalid & m_axi_awready;
   assign w_go        = m_axi_wvalid  & m_axi_wready;
   assign wr_wait     = awvalid_b | wvalid_b; // Indicates if waiting for AW or W channel
   assign awvalid_in  = wr_access & ~awvalid_b & ~wvalid_b; // New write request can be accepted

   // AW Channel Logic
   always @( posedge m_axi_aclk or negedge m_axi_aresetn)
     if(!m_axi_aresetn)
       begin
          m_axi_awvalid      <= 1'b0;
          m_axi_awaddr[31:0] <= 32'd0;
          m_axi_awlen[7:0]   <= 8'd0;
          m_axi_awsize[2:0]  <= 3'd0;
          awvalid_b          <= 1'b0;
          awaddr_b[31:0]     <= 32'd0;
          awlen_b[7:0]       <= 8'd0;
          awsize_b[2:0]      <= 3'd0;
       end
     else
       begin
          // Default assignments to avoid latches if conditions are not met
          m_axi_awvalid <= m_axi_awvalid;
          awvalid_b     <= awvalid_b;

          if( ~m_axi_awvalid | aw_go ) // If channel is free or current transfer completes
	    begin
               if( awvalid_b ) // Buffered transaction pending
		 begin
		    m_axi_awvalid       <= 1'b1;
		    m_axi_awaddr[31:0]  <= awaddr_b[31:0];
		    m_axi_awlen[7:0]    <= awlen_b[7:0];
		    m_axi_awsize[2:0]   <= awsize_b[2:0];
                    awvalid_b           <= 1'b0; // Clear buffer flag as it's now being sent
		 end
	       else // No buffered transaction, process new one if available
		 begin
		    m_axi_awvalid       <= awvalid_in; // Assert valid if new request arrives
		    if (awvalid_in) begin
                        m_axi_awaddr[31:0]  <= wr_dstaddr[31:0];
                        m_axi_awlen[7:0]    <= 8'b0; // Assuming single beat burst
                        m_axi_awsize[2:0]   <= { 1'b0, wr_datamode[1:0]}; // Size based on datamode
                    end else begin
                        // Deassert if no new request and channel free
                        m_axi_awaddr[31:0] <= 32'd0; // Optional: clear address when idle
                        m_axi_awlen[7:0]   <= 8'd0;