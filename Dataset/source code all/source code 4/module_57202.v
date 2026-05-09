module mrx_protocol (
   fifo_access, fifo_packet,
   rx_clk, nreset, datasize, lsbfirst, io_access, io_packet
   );
   parameter  PW   = 104;               
   parameter  NMIO = 8;                 
   parameter  CW   = $clog2(2*PW/NMIO); 
   input              rx_clk;        
   input 	      nreset;        
   input [7:0] 	      datasize;      
   input 	      lsbfirst;
   input 	      io_access;     
   input [2*NMIO-1:0] io_packet;     
   output 	      fifo_access;   
   output [PW-1:0]    fifo_packet;   
   reg [2:0] 	   mrx_state;
   reg [CW-1:0]    mrx_count;   
   reg 		   fifo_access;
   wire 	   shift;
   wire 	   transfer_done;
   `define MRX_IDLE     3'b000
   `define MRX_BUSY     3'b001
   always @ (posedge rx_clk or negedge nreset)
     if(!nreset)
       mrx_state[2:0] <= `MRX_IDLE;
     else
       case (mrx_state[2:0])
	 `MRX_IDLE:  mrx_state[2:0] <= io_access  ? `MRX_BUSY : `MRX_IDLE;
	 `MRX_BUSY:  mrx_state[2:0] <= ~io_access ? `MRX_IDLE : `MRX_BUSY;
	 default: mrx_state[2:0] <= 'b0;	 
       endcase 
   always @ (posedge rx_clk)    
     if((mrx_state[2:0]==`MRX_IDLE) | transfer_done)
       mrx_count[CW-1:0] <= datasize[CW-1:0];
     else if(mrx_state[2:0]==`MRX_BUSY)
       mrx_count[CW-1:0] <= mrx_count[CW-1:0] - 1'b1;   
   assign transfer_done = (mrx_count[CW-1:0]==1'b1) & (mrx_state[2:0]==`MRX_BUSY);
   assign shift         = (mrx_state[2:0]==`MRX_BUSY);
   always @ (posedge rx_clk or negedge nreset)
     if(!nreset)
       fifo_access <= 'b0;
     else
       fifo_access <= transfer_done;
   oh_ser2par #(.PW(PW),
		.SW(2*NMIO))
   ser2par (
	    .dout	(fifo_packet[PW-1:0]),
	    .clk	(rx_clk),
	    .din	(io_packet[2*NMIO-1:0]),
	    .lsbfirst	(lsbfirst),
	    .shift	(shift)
	    );
endmodule 
