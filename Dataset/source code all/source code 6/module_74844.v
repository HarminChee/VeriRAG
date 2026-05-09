module tx_buffer
  ( 
    input usbclk,
    input bus_reset,  
    input [15:0] usbdata,
    input wire WR,
    output reg have_space,
    output reg tx_underrun,
    input clear_status,
    input txclk,
    input reset,  
    input wire [3:0] channels,
    output reg [15:0] tx_i_0,
    output reg [15:0] tx_q_0,
    output reg [15:0] tx_i_1,
    output reg [15:0] tx_q_1,
    input txstrobe,
    output wire tx_empty,
    output [31:0] debugbus
    );
   wire [11:0] 	  txfifolevel;
   wire [15:0] 	  fifodata;
   wire 	  rdreq;
   reg [3:0] 	  phase;
   wire 	  sop_f, iq_f;
   reg 		  sop;
   reg [15:0] 	  usbdata_reg;
   reg 		  wr_reg;
   reg [8:0] 	  write_count;
   always @(posedge usbclk)
     have_space <= (txfifolevel < (4092-256));  
   always @(posedge usbclk)
     begin
	wr_reg <= WR;
	usbdata_reg <= usbdata;
     end
   always @(posedge usbclk)
     if(bus_reset)
       write_count <= 0;
     else if(wr_reg)
       write_count <= write_count + 1;
     else
       write_count <= 0;
   always @(posedge usbclk)
     sop <= WR & ~wr_reg; 
   fifo_4k_18 txfifo 
     ( 
       .data ( {sop,write_count[0],usbdata_reg} ),
       .wrreq ( wr_reg & ~write_count[8] ),
       .wrclk ( usbclk ),
       .wrfull ( ),
       .wrempty ( ),
       .wrusedw ( txfifolevel ),
       .q ( {sop_f, iq_f, fifodata} ),			
       .rdreq ( rdreq ),
       .rdclk ( txclk ),
       .rdfull ( ),
       .rdempty ( tx_empty ),
       .rdusedw (  ),
       .aclr ( reset ) );
   always @(posedge txclk)
     if(reset)
       begin
	  {tx_i_0,tx_q_0,tx_i_1,tx_q_1} <= 64'h0;
	  phase <= 4'd0;
       end
     else if(phase == channels)
       begin
	  if(txstrobe)
	    phase <= 4'd0;
       end
     else
       if(~tx_empty)
	 begin
	    case(phase)
	      4'd0 : tx_i_0 <= fifodata;
	      4'd1 : tx_q_0 <= fifodata;
	      4'd2 : tx_i_1 <= fifodata;
	      4'd3 : tx_q_1 <= fifodata;
	    endcase 
	    phase <= phase + 4'd1;
	 end
   assign    rdreq = ((phase != channels) & ~tx_empty);
   reg clear_status_dsp, tx_underrun_dsp;
   always @(posedge txclk)
     clear_status_dsp <= clear_status;
   always @(posedge usbclk)
     tx_underrun <= tx_underrun_dsp;
   always @(posedge txclk)
     if(reset)
       tx_underrun_dsp <= 1'b0;
     else if(txstrobe & (phase != channels))
       tx_underrun_dsp <= 1'b1;
     else if(clear_status_dsp)
       tx_underrun_dsp <= 1'b0;
   assign debugbus[0]     = reset;
   assign debugbus[1]     = txstrobe;
   assign debugbus[2]     = rdreq;
   assign debugbus[6:3]   = phase;
   assign debugbus[7]     = tx_empty;
   assign debugbus[8]     = tx_underrun_dsp;
   assign debugbus[9]     = iq_f;
   assign debugbus[10]    = sop_f;
   assign debugbus[14:11] = 0;
   assign debugbus[15]    = txclk;
   assign debugbus[16]    = bus_reset;
   assign debugbus[17]    = WR;
   assign debugbus[18]    = wr_reg;
   assign debugbus[19]    = have_space;
   assign debugbus[20]    = write_count[8];
   assign debugbus[21]    = write_count[0];
   assign debugbus[22]    = sop;
   assign debugbus[23]    = tx_underrun;
   assign debugbus[30:24] = 0;
   assign debugbus[31]    = usbclk;
endmodule 
