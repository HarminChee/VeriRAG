module mtx_fifo # ( parameter PW         = 136,           
		    parameter AW         = 64,            
		    parameter FIFO_DEPTH = 16,            
		    parameter TARGET     = "GENERIC"      
		    )
   (
    input 	   clk, 
    input 	   io_clk, 
    input 	   nreset, 
    input 	   tx_en,
    input 	   emode,
    input 	   access_in, 
    input [PW-1:0] packet_in, 
    output 	   wait_out, 
    output [63:0]  io_packet, 
    output [7:0]   io_valid, 
    input 	   io_wait 
    );
   reg [1:0] 	   emesh_cycle;
   reg [191:0] 	   packet_buffer;   
   wire 	   fifo_access_out;
   wire [71:0] 	   fifo_packet_out;
   wire 	   fifo_access_in;
   wire [71:0] 	   fifo_packet_in;
   wire [63:0] 	   data_wide;
   wire [7:0] 	   valid;
   wire 	   emesh_wait;
   wire [63:0] 	   fifo_data_in;
   wire 	   fifo_wait;
   wire [4:0]		ctrlmode_in;		
   wire [AW-1:0]	data_in;		
   wire [1:0]		datamode_in;		
   wire [AW-1:0]	dstaddr_in;		
   wire [AW-1:0]	srcaddr_in;		
   wire			write_in;		
   packet2emesh #(.AW(AW),
		  .PW(PW))
   p2e (.packet_in		(packet_in[PW-1:0]),
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]));
   assign data_wide[63:0]    =  {srcaddr_in[31:0],data_in[31:0]};
   always @ (posedge clk)
     if(~wait_out & access_in)
       packet_buffer[191:0] <= packet_in[PW-1:0];
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       emesh_cycle[1:0] <= 'b0;
     else if(emesh_cycle[0] && (AW==64))      
       emesh_cycle[1:0] <= 2'b10;
     else if(emode & access_in & ~fifo_wait)  
       emesh_cycle[1:0] <= 2'b01;
     else
       emesh_cycle[1:0] <= 2'b00;
   assign valid[7:0] = (emesh_cycle[0] && (AW==32))       ? 8'h3F : 
		       (emesh_cycle[1] && (AW==64))       ? 8'h03 : 
         	       (~emode & datamode_in[1:0]==2'b00) ? 8'h01 : 
        	       (~emode & datamode_in[1:0]==2'b01) ? 8'h03 : 
         	       (~emode & datamode_in[1:0]==2'b10) ? 8'h0F : 
                                                            8'hFF;  
   assign fifo_data_in[63:0] = ~emode          ? data_wide[63:0]       :
                                emesh_cycle[0] ? packet_buffer[127:64]   :
      		                emesh_cycle[1] ? packet_buffer[191:128]  :
		                                  packet_in[63:0];
   assign fifo_packet_in[71:0] = {fifo_data_in[63:0], valid[7:0]};
   assign fifo_access_in = access_in | (|emesh_cycle[1:0]);
   assign wait_out = fifo_wait  | (|emesh_cycle[1:0]);
   oh_fifo_cdc  #(.TARGET(TARGET),
		  .DW(72),
		  .DEPTH(FIFO_DEPTH))
   fifo  (.clk_in			(clk),
	  .clk_out			(io_clk),
	  .wait_in			(io_wait),
	  .prog_full			(),
	  .full				(),
	  .empty			(), 
	  .wait_out			(fifo_wait),
	  .access_in			(fifo_access_in),
	  .packet_in			(fifo_packet_in[71:0]),
	  .access_out			(fifo_access_out),
	  .packet_out			(fifo_packet_out[71:0]),
	  .nreset			(nreset));
   assign io_valid[7:0]    = {{(8){fifo_access_out}} & fifo_packet_out[7:0]};
   assign io_packet[63:0] = fifo_packet_out[71:8];
endmodule 
