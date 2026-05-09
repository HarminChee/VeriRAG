module egen(
   done, access_out, packet_out,
   clk, reset, start, wait_in
   );
   parameter PW      = 104;
   parameter AW      = 32;
   parameter DW      = 32;
   parameter MODE    = 0;    
   parameter SRC_ID  = 12'h0;
   parameter DST_ID  = 12'h0;
   parameter COUNT   = 16;
   input           clk;
   input           reset;         
   input           start;        
   output 	   done;
   output          access_out;
   output [PW-1:0] packet_out;
   input           wait_in;
   reg 	           access_reg;
   reg 	           write_reg;
   reg [1:0] 	   datamode_reg;
   reg [3:0] 	   ctrlmode_reg;
   reg [AW-1:0]    dstaddr_reg;
   reg [DW-1:0]    data_reg;
   reg [AW-1:0]    srcaddr_reg;
   reg [31:0] 	   count;   
   reg [1:0] 	   state;
   wire 	   go;
   wire 	   idle;
`define IDLE  2'b00
`define DONE  2'b10
`define GO    2'b01
   assign done = (state[1:0]==`DONE);
   assign go   = (state[1:0]==`GO);
   assign idle = (state[1:0]==`IDLE);
   always @ (posedge clk or posedge reset)
     if(reset)
       state[1:0] <= 2'b00;
     else if(start & idle)
       state[1:0] <= 2'b01;
     else if( ~(|count) & go)
       state[1:0] <= 2'b10;
   always @ (posedge clk or posedge reset)
     if(reset)
       count <= COUNT;
     else if(state[1:0]==`GO)
       count <= count - 1'b1;
   always @ (posedge clk or posedge reset)
     if(reset)
       begin
	  srcaddr_reg[31:0]  <= SRC_ID<<20;
	  data_reg[31:0]     <= 0;
	  dstaddr_reg[31:0]  <= DST_ID<<20;	  
	  ctrlmode_reg[3:0]  <= 4'b0;
	  datamode_reg[1:0]  <= 2'b10;
	  write_reg          <= MODE;
	  access_reg         <= 1'b0;
       end
     else if (~wait_in & go)	  
       begin
	  access_reg         <= 1'b1;
	  dstaddr_reg[31:0]  <= (dstaddr_reg[31:0]+ (1<<datamode_reg[1:0])) &
	                        32'hFFF07FFF;
	  srcaddr_reg[31:0]  <= (srcaddr_reg[31:0]+ (1<<datamode_reg[1:0])) & 
				 32'hFFF07FFF;
	  data_reg[31:0]     <= (data_reg[31:0]+1'b1) & 
				32'hFFF07FFF;
       end 
     else
       begin
	  access_reg         <= 1'b0;
       end
   assign access_out = access_reg;
   emesh2packet e2p (
		     .packet_out	(packet_out[PW-1:0]),
		     .access_in		(access_reg),
		     .write_in		(write_reg),
		     .datamode_in	(datamode_reg[1:0]),
		     .ctrlmode_in	(ctrlmode_reg[3:0]),
		     .dstaddr_in	(dstaddr_reg[AW-1:0]),
		     .data_in		(data_reg[DW-1:0]),
		     .srcaddr_in	(srcaddr_reg[AW-1:0]));
endmodule 
