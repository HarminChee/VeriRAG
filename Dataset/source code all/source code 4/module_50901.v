module emesh_readback (
   wait_out, access_out, packet_out,
   nreset, clk, access_in, packet_in, read_data, wait_in
   );
   parameter  AW  = 32;    
   parameter  PW  = 104;   
   input           nreset;      
   input 	   clk;         
   input 	   access_in;   
   input [PW-1:0]  packet_in;   
   output 	   wait_out;    
   input [63:0]    read_data;   
   output 	   access_out;  
   output [PW-1:0] packet_out;  
   input 	   wait_in;     
   wire [4:0]		ctrlmode_in;		
   wire [AW-1:0]	data_in;		
   wire [1:0]		datamode_in;		
   wire [AW-1:0]	dstaddr_in;		
   wire [AW-1:0]	srcaddr_in;		
   wire			write_in;		
   reg [1:0] 		datamode_out;
   reg [4:0] 		ctrlmode_out;
   reg [AW-1:0] 	dstaddr_out; 	
   wire [AW-1:0] 	data_out;
   wire [AW-1:0] 	srcaddr_out;
   reg 			access_out;
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
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       access_out <= 1'b0;
     else if(~wait_in)
       access_out <= access_in & ~write_in;
   always @ (posedge clk)
     if(~wait_in & access_in & ~write_in)
       begin	  
	  datamode_out[1:0]   <= datamode_in[1:0];
	  ctrlmode_out[4:0]   <= ctrlmode_in[4:0];
	  dstaddr_out[AW-1:0] <= srcaddr_in[AW-1:0]; 
       end
   assign data_out[AW-1:0]    = read_data[31:0];
   assign srcaddr_out[AW-1:0] = read_data[63:32];
   assign wait_out = wait_in;
   emesh2packet #(.AW(AW),
		  .PW(PW))
   e2p (.write_out   (1'b1),
	.packet_out			(packet_out[PW-1:0]),
	.datamode_out			(datamode_out[1:0]),
	.ctrlmode_out			(ctrlmode_out[4:0]),
	.dstaddr_out			(dstaddr_out[AW-1:0]),
	.data_out			(data_out[AW-1:0]),
	.srcaddr_out			(srcaddr_out[AW-1:0]));
endmodule 
