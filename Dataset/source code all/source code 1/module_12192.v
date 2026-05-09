`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module pcie_mem_alloc
   #(parameter REVISION=1)
   (
        input ACLK,
        input Axi_resetn,
        input [31:0] stats0_data,
        input [31:0] stats1_data,
        input [31:0] stats2_data,
        input [31:0] stats3_data,
      input  [31: 0] pcie_axi_AWADDR,
      input  pcie_axi_AWVALID,
      output pcie_axi_AWREADY,
      input  [31: 0]   pcie_axi_WDATA,
      input  [3: 0] pcie_axi_WSTRB,
      input  pcie_axi_WVALID,
      output pcie_axi_WREADY,
      output [1:0] pcie_axi_BRESP,
      output pcie_axi_BVALID,
      input  pcie_axi_BREADY,
      input  [31: 0] pcie_axi_ARADDR,
      input  pcie_axi_ARVALID,
      output pcie_axi_ARREADY,
      output [31: 0] pcie_axi_RDATA,
      output [1:0] pcie_axi_RRESP,
      output pcie_axi_RVALID,
      input  pcie_axi_RREADY,
      input pcieClk,
      input pcie_user_lnk_up,
        input [31:0] memcached2memAllocation_data,	
        input memcached2memAllocation_valid,
        output memcached2memAllocation_ready,
        output[31:0] memAllocation2memcached_dram_data,	
        output memAllocation2memcached_dram_valid,
        input memAllocation2memcached_dram_ready,
        output[31:0] memAllocation2memcached_flash_data,	
        output memAllocation2memcached_flash_valid,
        input memAllocation2memcached_flash_ready,
        input flushReq,                                               
        output flushAck,                                              
        input flushDone 
        );
    wire  [31:0]  free1_pcie;
    wire  free1_wr_pcie;
    wire   free1_full_pcie;    
    wire  [31:0]  free2_pcie;
    wire  free2_wr_pcie;
    wire   free2_full_pcie;               
    wire  [31:0]  free3_pcie;            
    wire  free3_wr_pcie;
    wire   free3_full_pcie;  
    wire  [31:0]  free4_pcie;
    wire  free4_wr_pcie;
    wire   free4_full_pcie;
    wire   [31:0]  del1_pcie;
    wire  del1_rd_pcie;
    wire   del1_ety_pcie;
    wire free1_fifo_ety;
    assign memAllocation2memcached_dram_valid=~free1_fifo_ety;
    wire pipereset;
    assign pipereset=~Axi_resetn|flushReq;
    memMgmt_async_fifo free1_fifo (
        .rst(pipereset),        
        .wr_clk(pcieClk),  
        .rd_clk(ACLK),  
        .din(free1_pcie),        
        .wr_en(free1_wr_pcie),    
        .rd_en(memAllocation2memcached_dram_ready),    
        .dout(memAllocation2memcached_dram_data),      
        .full(free1_full_pcie),      
        .empty(free1_fifo_ety)    
    );
    wire free2_fifo_ety;
    assign memAllocation2memcached_flash_valid=~free2_fifo_ety;
    memMgmt_async_fifo free2_fifo (
        .rst(pipereset),        
        .wr_clk(pcieClk),  
        .rd_clk(ACLK),  
        .din(free2_pcie),        
        .wr_en(free2_wr_pcie),    
        .rd_en(memAllocation2memcached_flash_ready),    
        .dout(memAllocation2memcached_flash_data),      
        .full(free2_full_pcie),      
        .empty(free2_fifo_ety)    
    );
    wire del1_fifo_full;
    assign memcached2memAllocation_ready=~del1_fifo_full;
    memMgmt_async_fifo del_fifo (
        .rst(pipereset),        
        .wr_clk(ACLK),  
        .rd_clk(pcieClk),  
        .din(memcached2memAllocation_data),        
        .wr_en(memcached2memAllocation_valid),    
        .rd_en(del1_rd_pcie),    
        .dout(del1_pcie),      
        .full(del1_fifo_full),      
        .empty(del1_ety_pcie)    
    );
        wire P_flushack,P_flushreq,P_flushdone; 
        wire A_flushack, A_flushackn, A_flushreq, A_flushdone; 
        localparam STATS_WIDTH=32;
        wire [STATS_WIDTH-1:0] P_stats0,P_stats1,P_stats2,P_stats3;
        (* ASYNC_REG="TRUE"*) reg  flushreqR, flushreqR2;
        (* ASYNC_REG="TRUE"*) reg  flushdoneR,flushdoneR2;
        (* ASYNC_REG="TRUE"*) reg  [STATS_WIDTH-1:0] stats0R,stats0R2;
        (* ASYNC_REG="TRUE"*) reg  [STATS_WIDTH-1:0] stats1R,stats1R2;
        (* ASYNC_REG="TRUE"*) reg  [STATS_WIDTH-1:0] stats2R,stats2R2;
        (* ASYNC_REG="TRUE"*) reg  [STATS_WIDTH-1:0] stats3R,stats3R2;
      assign A_flushreq=flushReq;
      assign A_flushdone=flushDone;
      assign flushAck=A_flushack; 
    assign A_flushack=~A_flushackn;
    singleSignalCDC flushAckCrosser (
        .wr_clk(pcieClk),  
        .rd_clk(ACLK),  
        .din(1'b0),        
        .wr_en(P_flushack),    
        .rd_en(1'b1),    
        .dout(),      
        .full(),      
        .empty(A_flushackn)    
      );
      always @(posedge pcieClk) begin 
            flushreqR<=A_flushreq;
            flushreqR2<=flushreqR;
            flushdoneR<=A_flushdone;
            flushdoneR2<=flushdoneR;
      end
      assign P_flushreq  = flushreqR2;
      assign P_flushdone = flushdoneR2;
        always@(posedge pcieClk) begin
            stats0R <=stats0_data;
            stats0R2<=stats0R;
            stats1R <=stats1_data;
            stats1R2<=stats1R;
            stats2R <=stats2_data;
            stats2R2<=stats2R;
            stats3R <=stats3_data;
            stats3R2<=stats3R;
        end
        assign P_stats0=stats0R2;
        assign P_stats1=stats1R2;
        assign P_stats2=stats2R2;
        assign P_stats3=stats3R2;
  stats_to_axi #(.REVISION(REVISION))  stats_to_axi_i
         (.ACLK(pcieClk),
          .ARESETN(pcie_user_lnk_up),
          .ARADDR(pcie_axi_ARADDR),
          .ARREADY(pcie_axi_ARREADY),
          .ARVALID(pcie_axi_ARVALID),
          .AWADDR(pcie_axi_AWADDR),
          .AWREADY(pcie_axi_AWREADY),
          .AWVALID(pcie_axi_AWVALID),
          .RDATA(pcie_axi_RDATA),
          .RREADY(pcie_axi_RREADY),
          .RRESP(pcie_axi_RRESP),
          .RVALID(pcie_axi_RVALID),
          .WDATA(pcie_axi_WDATA),
          .WREADY(pcie_axi_WREADY),
          .WSTRB(pcie_axi_WSTRB),
          .WVALID(pcie_axi_WVALID),
          .BREADY(pcie_axi_BREADY),
          .BRESP(pcie_axi_BRESP),
          .BVALID(pcie_axi_BVALID),
          .stats0_in(stats0_data),
          .stats1_in(stats1_data),
          .stats2_in(stats2_data),
          .stats3_in(stats3_data),
          .free1(free1_pcie),
          .free1_wr(free1_wr_pcie),
          .free1_full(free1_full_pcie),    
          .free2(free2_pcie),
          .free2_wr(free2_wr_pcie),
          .free2_full(free2_full_pcie),               
          .free3(free3_pcie),            
          .free3_wr(free3_wr_pcie),
          .free3_full(free3_full_pcie),  
          .icap(),
          .icap_wr(),
          .icap_full(),
          .del1(del1_pcie),
          .del1_rd(del1_rd_pcie),
          .del1_ety(del1_ety_pcie),
          .flushreq(P_flushreq),
          .flushack(P_flushack),
          .flushdone(P_flushdone),
          .SC_reset()
);
endmodule
