module erx_protocol (
   erx_access, erx_packet,
   clk, test_mode, rx_packet, rx_burst, rx_access
   );
   parameter AW   = 32;
   parameter DW   = 32;
   parameter PW   = 104;
   parameter ID   = 12'h999; 
   input           clk;
   input 	   test_mode; 
   input [PW-1:0]  rx_packet;
   input 	   rx_burst;
   input 	   rx_access;
   output          erx_access;
   output [PW-1:0] erx_packet;
   reg [31:0] 	   dstaddr_reg;   
   wire [31:0] 	   dstaddr_next;
   wire [31:0] 	   dstaddr_mux;
   reg 		   erx_access;
   reg [PW-1:0]    erx_packet;
   wire [31:0] 	   rx_addr;
   assign        rx_addr[31:0]  = rx_packet[39:8];
   always @ (posedge clk)
     if(rx_access)
       dstaddr_reg[31:0]    <= dstaddr_mux[31:0];
   assign dstaddr_next[31:0] = dstaddr_reg[31:0] + 4'b1000;
   assign dstaddr_mux[31:0]  =  rx_burst ? dstaddr_next[31:0] :
			                   rx_addr[31:0];
   always @ (posedge clk)
     begin
	  erx_access          <= ~test_mode & rx_access;      	  
	  erx_packet[PW-1:0]  <= {rx_packet[PW-1:40],
				  dstaddr_mux[31:0],
				  {1'b0,rx_packet[7:1]} 
				  };                    
     end
endmodule 
