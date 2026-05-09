module edma_dp (
   count, srcaddr, dstaddr, wait_out, access_out, packet_out,
   clk, nreset, master_active, update2d, datamode, ctrlmode,
   stride_reg, count_reg, srcaddr_reg, dstaddr_reg, access_in,
   packet_in, wait_in
   );
   parameter  AW   = 8;            
   parameter  PW  = 2*AW+40;      
   input           clk;           
   input 	   nreset;        
   input 	   master_active; 
   input 	   update2d;      
   input [1:0] 	   datamode;      
   input [4:0] 	   ctrlmode;      
   input [31:0]    stride_reg;    
   input [31:0]    count_reg;     
   input [AW-1:0]  srcaddr_reg;   
   input [AW-1:0]  dstaddr_reg;   
   output [31:0]   count;         
   output [AW-1:0] srcaddr;       
   output [AW-1:0] dstaddr;       
   input 	   access_in;   
   input [PW-1:0]  packet_in;     
   output 	   wait_out;
   output 	   access_out;        
   output [PW-1:0] packet_out;    
   input 	   wait_in;       
   reg [PW-1:0]    packet_out;
   reg 		   access_out;
   wire [4:0] 	   ctrlmode_out;
   wire [AW-1:0]   data_out;	
   wire [1:0] 	   datamode_out;
   wire [AW-1:0]   dstaddr_out;	
   wire [AW-1:0]   srcaddr_out;	
   wire 	   write_out;	
   wire [PW-1:0]   packet;
   wire [4:0]		ctrlmode_in;		
   wire [AW-1:0]	data_in;		
   wire [1:0]		datamode_in;		
   wire [AW-1:0]	dstaddr_in;		
   wire [AW-1:0]	srcaddr_in;		
   wire			write_in;		
   assign count[31:0] = update2d ? {(count_reg[31:16] - 1'b1),count_reg[15:0]} :
		                     count_reg[31:0] - 1'b1;
   assign srcaddr[AW-1:0] = srcaddr_reg[AW-1:0] + 
			    {{(AW-16){stride_reg[15]}},stride_reg[15:0]};
   assign dstaddr[AW-1:0] = dstaddr_reg[AW-1:0] + 
			    {{(AW-16){stride_reg[31]}},stride_reg[31:16]};
   packet2emesh #(.AW(AW),
		  .PW(PW))
   p2e (
	.write_in			(write_in),
	.datamode_in			(datamode_in[1:0]),
	.ctrlmode_in			(ctrlmode_in[4:0]),
	.dstaddr_in			(dstaddr_in[AW-1:0]),
	.srcaddr_in			(srcaddr_in[AW-1:0]),
	.data_in			(data_in[AW-1:0]),
	.packet_in			(packet_in[PW-1:0]));
   assign write_out           = master_active ? 1'b0          : 1'b1;
   assign datamode_out[1:0]   = master_active ? datamode[1:0] : datamode_in[1:0];
   assign ctrlmode_out[4:0]   = master_active ? ctrlmode[4:0] : ctrlmode_in[4:0];
   assign dstaddr_out[AW-1:0] = dstaddr[AW-1:0];
   assign data_out[AW-1:0]    = master_active ? {(AW){1'b0}}  : data_in[31:0];
   assign srcaddr_out[AW-1:0] = master_active ? {(AW){1'b0}}  : srcaddr_in[31:0];
   emesh2packet #(.AW(AW),
		  .PW(PW))
   e2p (.packet_out			(packet[PW-1:0]),
	.write_out			(write_out),
	.datamode_out			(datamode_out[1:0]),
	.ctrlmode_out			(ctrlmode_out[4:0]),
	.dstaddr_out			(dstaddr_out[AW-1:0]),
	.data_out			(data_out[AW-1:0]),
	.srcaddr_out			(srcaddr_out[AW-1:0]));
   always @ (posedge clk)
     if(~wait_in)
       packet_out[PW-1:0] <= packet[PW-1:0];
   always @ (posedge clk)
     if(~wait_in)
       access_out <= access_in | master_active;
   assign wait_out = wait_in;
endmodule 
