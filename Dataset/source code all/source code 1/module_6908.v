module mrx_io (
   io_access, io_packet,
   nreset, rx_clk, ddr_mode, lsbfirst, framepol, rx_packet, rx_access
   );
   parameter  NMIO  = 16;  
   input               nreset;        
   input 	       rx_clk;        
   input 	       ddr_mode;      
   input 	       lsbfirst;      
   input 	       framepol;      
   input [NMIO-1:0]    rx_packet;     
   input 	       rx_access;     
   output 	       io_access;     
   output [2*NMIO-1:0] io_packet;     
   reg 		       io_access;
   wire [2*NMIO-1:0]   ddr_data;
   reg [2*NMIO-1:0]    sdr_data;
   reg 		       byte0_sel;
   wire 	       io_nreset;
   wire 	       rx_frame;
   oh_rsync oh_rsync(.nrst_out	(io_nreset),
		     .clk	(rx_clk),
		     .nrst_in	(nreset)
		     );
   assign rx_frame =  framepol ^ rx_access;
   always @ (posedge rx_clk or negedge io_nreset)
     if(!io_nreset)
       io_access <= 1'b0;
     else
       io_access <= rx_frame;
   oh_iddr #(.DW(NMIO))
   data_iddr(.q1			(ddr_data[NMIO-1:0]),
	     .q2			(ddr_data[2*NMIO-1:NMIO]),
	     .clk			(rx_clk),
	     .ce			(rx_frame),
	     .din			(rx_packet[NMIO-1:0]));
   always @ (posedge rx_clk)
     if(~rx_frame)
       byte0_sel <= 1'b1;
     else if (~ddr_mode)
       byte0_sel <= rx_frame ^ byte0_sel;
   always @ (posedge rx_clk)
     if(byte0_sel)
       sdr_data[NMIO-1:0]  <= rx_packet[NMIO-1:0];
     else
       sdr_data[2*NMIO-1:NMIO] <= rx_packet[NMIO-1:0];
   assign io_packet[2*NMIO-1:0] =  ~ddr_mode             ? sdr_data[2*NMIO-1:0] :
			  	    ddr_mode & ~lsbfirst ? {ddr_data[NMIO-1:0],
				   		           ddr_data[2*NMIO-1:NMIO]} :
			                                   ddr_data[2*NMIO-1:0];
endmodule 
