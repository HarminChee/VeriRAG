module eproto_tx (
   emtx_rd_wait, emtx_wr_wait, emtx_ack, txframe_p, txdata_p,
   reset, emtx_access, emtx_write, emtx_datamode, emtx_ctrlmode,
   emtx_dstaddr, emtx_srcaddr, emtx_data, txlclk_p, tx_rd_wait,
   tx_wr_wait
   );
   input         reset;
   input         emtx_access;
   input         emtx_write;
   input [1:0]   emtx_datamode;
   input [3:0]   emtx_ctrlmode;
   input [31:0]  emtx_dstaddr;
   input [31:0]  emtx_srcaddr;
   input [31:0]  emtx_data;
   output        emtx_rd_wait;
   output        emtx_wr_wait;
   output        emtx_ack;
   input         txlclk_p; 
   output [7:0]  txframe_p;
   output [63:0] txdata_p;
   input         tx_rd_wait;  
   input         tx_wr_wait;  
   reg           emtx_ack;  
   reg [7:0]     txframe_p;
   reg [63:0]    txdata_p;
   always @( posedge txlclk_p or posedge reset ) begin
      if( reset ) begin
         emtx_ack    <= 1'b0;
         txframe_p   <= 'd0;
         txdata_p    <= 'd0;
      end else begin
         if( emtx_access & ~emtx_ack ) begin
            emtx_ack  <= 1'b1;
            txframe_p <= 8'h3F;
            txdata_p  <=
               { 8'd0,  
                 8'd0,
                 ~emtx_write, 7'd0,   
                 emtx_ctrlmode, emtx_dstaddr[31:28], 
                 emtx_dstaddr[27:4],  
                 emtx_dstaddr[3:0], emtx_datamode, emtx_write, emtx_access 
                 };
         end else if( emtx_ack ) begin 
            emtx_ack  <= 1'b0;
            txframe_p <= 8'hFF;
            txdata_p  <= { emtx_data, emtx_srcaddr };
         end else begin
            emtx_ack    <= 1'b0;
            txframe_p <= 8'h00;
            txdata_p  <= 64'd0;
         end
      end 
   end 
   reg     rd_wait_sync;
   reg     wr_wait_sync;
   reg     emtx_rd_wait;
   reg     emtx_wr_wait;
   always @( posedge txlclk_p ) begin
      rd_wait_sync <= tx_rd_wait;
      emtx_rd_wait <= rd_wait_sync;
      wr_wait_sync <= tx_wr_wait;
      emtx_wr_wait <= wr_wait_sync;
   end
endmodule 
