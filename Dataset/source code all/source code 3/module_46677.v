module oh_fifo_sync #(parameter DW        = 104,      
		      parameter DEPTH     = 32,       
		      parameter PROG_FULL = (DEPTH/2),
		      parameter AW = $clog2(DEPTH)    
		      ) 
(
   input 	       clk, 
   input 	       nreset, 
   input [DW-1:0]      din, 
   input 	       wr_en, 
   input 	       rd_en, 
   output [DW-1:0]     dout, 
   output 	       full, 
   output 	       prog_full, 
   output 	       empty, 
   output reg [AW-1:0] rd_count     
 );
   reg [AW-1:0]        wr_addr;
   reg [AW-1:0]        rd_addr;
   wire 	       fifo_read;
   wire 	       fifo_write;
   assign empty       = (rd_count[AW-1:0] == 0);   
   assign prog_full   = (rd_count[AW-1:0] >= PROG_FULL);   
   assign full        = (rd_count[AW-1:0] == (DEPTH-1));
   assign fifo_read   = rd_en & ~empty;
   assign fifo_write  = wr_en & ~full;
   always @ ( posedge clk or negedge nreset) 
     if(!nreset) 
       begin	   
          wr_addr[AW-1:0]   <= 'd0;
          rd_addr[AW-1:0]   <= 'b0;
          rd_count[AW-1:0]  <= 'b0;
       end 
     else if(fifo_write & fifo_read) 
       begin
	  wr_addr[AW-1:0] <= wr_addr[AW-1:0] + 'd1;
	  rd_addr[AW-1:0] <= rd_addr[AW-1:0] + 'd1;	      
       end 
     else if(fifo_write) 
       begin
	  wr_addr[AW-1:0] <= wr_addr[AW-1:0]  + 'd1;
	  rd_count[AW-1:0]<= rd_count[AW-1:0] + 'd1;	
       end 
     else if(fifo_read) 
       begin	      
          rd_addr[AW-1:0] <= rd_addr[AW-1:0]  + 'd1;
          rd_count[AW-1:0]<= rd_count[AW-1:0] - 'd1;
       end
   oh_memory_dp 
     #(.DW(DW),
       .DEPTH(DEPTH))
   mem (
	.rd_dout	(dout[DW-1:0]),
	.rd_clk		(clk),
	.rd_en		(fifo_read),
	.rd_addr	(rd_addr[AW-1:0]),
	.wr_clk		(clk),
	.wr_en		(fifo_write),
  	.wr_wem		({(DW){1'b1}}),
	.wr_addr	(wr_addr[AW-1:0]),
	.wr_din	        (din[DW-1:0]));
endmodule 
