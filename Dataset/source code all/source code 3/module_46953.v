module ememory(
   wait_out, access_out, packet_out,
   clk, reset, access_in, packet_in, wait_in
   );
   parameter DW  = 32;   
   parameter AW  = 32;   
   parameter MAW = 10;
   parameter PW  = 104;
   input            clk;
   input 	    reset;  
   input 	    access_in;
   input [PW-1:0]   packet_in;      
   output 	    wait_out;   
   output 	    access_out;
   output [PW-1:0]  packet_out;        
   input 	    wait_in;   
   wire [MAW-1:0]   addr;
   wire [63:0]      din;
   wire [63:0] 	    dout;
   wire 	    en; 
   wire 	    mem_rd;
   wire 	    mem_wr;
   reg [7:0] 	    wen;
   reg 		    access_out;   
   reg 		    write_out;   
   reg [1:0] 	    datamode_out;
   reg [3:0] 	    ctrlmode_out;   
   reg [AW-1:0]     dstaddr_out;   
   wire [AW-1:0]    srcaddr_out;
   wire [AW-1:0]    data_out;   
   reg 		    hilo_sel;
   wire 	    write_in;   
   wire [1:0] 	    datamode_in;
   wire [3:0] 	    ctrlmode_in;   
   wire [AW-1:0]    dstaddr_in;
   wire [DW-1:0]    data_in;   
   wire [AW-1:0]    srcaddr_in;   
   packet2emesh p2e (
		     .access_out	(),
		     .write_out		(write_in),
		     .datamode_out	(datamode_in[1:0]),
		     .ctrlmode_out	(ctrlmode_in[3:0]),
		     .dstaddr_out	(dstaddr_in[AW-1:0]),
		     .data_out		(data_in[DW-1:0]),
		     .srcaddr_out	(srcaddr_in[AW-1:0]),
		     .packet_in		(packet_in[PW-1:0])
		     );
   assign mem_rd = (access_in & ~write_in & ~wait_in);
   assign mem_wr = (access_in & write_in );
   assign en =  mem_rd | mem_wr;
   assign wait_out = access_in & wait_in;
   assign addr[MAW-1:0] = dstaddr_in[MAW+2:3];     
   assign din[63:0] =(datamode_in[1:0]==2'b11) ? {srcaddr_in[31:0],data_in[31:0]}:
		                                 {data_in[31:0],data_in[31:0]};
   always@*
     casez({write_in, datamode_in[1:0],dstaddr_in[2:0]})
       6'b100000 : wen[7:0] = 8'b00000001;
       6'b100001 : wen[7:0] = 8'b00000010;
       6'b100010 : wen[7:0] = 8'b00000100;
       6'b100011 : wen[7:0] = 8'b00001000;
       6'b100100 : wen[7:0] = 8'b00010000;
       6'b100101 : wen[7:0] = 8'b00100000;
       6'b100110 : wen[7:0] = 8'b01000000;
       6'b100111 : wen[7:0] = 8'b10000000;
       6'b10100? : wen[7:0] = 8'b00000011;
       6'b10101? : wen[7:0] = 8'b00001100;
       6'b10110? : wen[7:0] = 8'b00110000;
       6'b10111? : wen[7:0] = 8'b11000000;
       6'b1100?? : wen[7:0] = 8'b00001111;
       6'b1101?? : wen[7:0] = 8'b11110000;       
       6'b111??? : wen[7:0] = 8'b11111111;
       default   : wen[7:0] = 8'b00000000;
     endcase 
   defparam mem.DW=2*DW;
   defparam mem.AW=MAW;		   
   memory_sp mem(
		 .clk	(clk),
		 .en	(en),
		 .wen	(wen[7:0]),
		 .addr	(addr[MAW-1:0]),
		 .din	(din[63:0]),
		 .dout	(dout[63:0])
		 );
   always @ (posedge  clk)
     access_out                    <= mem_rd;
   always @ (posedge clk)
     if(mem_rd)   
       begin
	  write_out           <= 1'b1;
          hilo_sel            <= dstaddr_in[2];
	  datamode_out[1:0]   <= datamode_in[1:0];
	  ctrlmode_out[3:0]   <= ctrlmode_in[3:0];                  
          dstaddr_out[AW-1:0] <= srcaddr_in[AW-1:0];
       end
   assign srcaddr_out[AW-1:0] = (datamode_out[1:0]==2'b11) ? dout[63:32] :
				                             32'b0;
   assign data_out[DW-1:0]     = hilo_sel ? dout[63:32] :
				            dout[31:0]; 
   emesh2packet e2p (.packet_out	(packet_out[PW-1:0]),
		     .access_in		(access_out),
		     .write_in		(write_out),
		     .datamode_in	(datamode_out[1:0]),
		     .ctrlmode_in	(ctrlmode_out[3:0]),
		     .dstaddr_in	(dstaddr_out[AW-1:0]),
		     .data_in		(data_out[DW-1:0]),
		     .srcaddr_in	(srcaddr_out[AW-1:0])
		     );
endmodule 
