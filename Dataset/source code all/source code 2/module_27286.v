module erx_disty (
   emesh_rd_wait, emesh_wr_wait, emwr_wr_en, emrq_wr_en, emrr_wr_en,
   erx_write, erx_datamode, erx_ctrlmode, erx_dstaddr, erx_srcaddr,
   erx_data,
   clk, mmu_en, emmu_access, emmu_write, emmu_datamode, emmu_ctrlmode,
   emmu_dstaddr, emmu_srcaddr, emmu_data, emwr_progfull,
   emrq_progfull, emrr_progfull, ecfg_rx_enable
   );
   parameter [11:0]  C_READ_TAG_ADDR = 12'h810;
   parameter         C_REMAP_BITS    = 7;
   parameter [31:0]  C_REMAP_ADDR    = 32'h3E000000;
   input         clk;
   input 	 mmu_en;
   input          emmu_access;
   input          emmu_write;
   input [1:0]    emmu_datamode;
   input [3:0]    emmu_ctrlmode;
   input [31:0]   emmu_dstaddr;
   input [31:0]   emmu_srcaddr;
   input [31:0]   emmu_data;
   output         emesh_rd_wait;
   output         emesh_wr_wait;
   output         emwr_wr_en;
   input          emwr_progfull;
   output         emrq_wr_en;
   input          emrq_progfull;
   output         emrr_wr_en;
   input          emrr_progfull;
   output            erx_write;
   output [1:0]      erx_datamode;
   output [3:0]      erx_ctrlmode;
   output [31:0]     erx_dstaddr;
   output [31:0]     erx_srcaddr;
   output [31:0]     erx_data;
   input 	     ecfg_rx_enable;
   reg            erx_write;
   reg [1:0]      erx_datamode;
   reg [3:0]      erx_ctrlmode;
   reg [31:0]     erx_dstaddr;
   reg [31:0]     erx_srcaddr;
   reg [31:0]     erx_data;
   reg            emwr_wr_en;
   reg            emrq_wr_en;
   reg            emrr_wr_en;
   always @ (posedge clk) 
     begin
	erx_write          <= emmu_write;
        erx_datamode[1:0]  <= emmu_datamode[1:0];
        erx_ctrlmode[3:0]  <= emmu_ctrlmode[3:0];
        erx_dstaddr[31:0]  <= mmu_en ? emmu_dstaddr[31:0] : {C_REMAP_ADDR[31:(32-C_REMAP_BITS)], 
							    emmu_dstaddr[(31-C_REMAP_BITS):0]};
        erx_srcaddr[31:0]  <= emmu_srcaddr[31:0];
        erx_data[31:0]     <= emmu_data[31:0];
     end
   always @ (posedge clk) 
     if(emmu_access) 
       begin
	  emrq_wr_en <= ~emmu_write;
          emrr_wr_en <= emmu_write & (emmu_dstaddr[31:20] == C_READ_TAG_ADDR);
          emwr_wr_en <= emmu_write & (emmu_dstaddr[31:20] != C_READ_TAG_ADDR);
       end
     else
       begin
	  emrq_wr_en  <= 1'b0;
	  emrr_wr_en  <= 1'b0;
	  emwr_wr_en  <= 1'b0;	  
       end
   assign        emesh_rd_wait = emrq_progfull;
   assign        emesh_wr_wait = emwr_progfull | emrr_progfull;
endmodule 
