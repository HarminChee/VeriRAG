module spi_master_io
  (
   input 	    clk, 
   input 	    nreset, 
   input 	    cpol, 
   input 	    cpha, 
   input 	    lsbfirst, 
   input 	    manual_mode,
   input 	    send_data, 
   input [7:0] 	    clkdiv_reg, 
   output reg [2:0] spi_state, 
   input [7:0] 	    fifo_dout, 
   input 	    fifo_empty, 
   output 	    fifo_read, 
   output [63:0]    rx_data, 
   output 	    rx_access, 
   output reg 	    sclk, 
   output 	    mosi, 
   output 	    ss, 
   input 	    miso       
   );
   reg 		   fifo_empty_reg;
   reg 		   load_byte;
   reg 		   ss_reg;   
   wire [7:0] 	   data_out;
   wire [15:0] 	   clkphase0;
   wire 	   period_match;
   wire 	   phase_match;
   wire 	   clkout;
   wire 	   clkchange;
   wire 	   data_done;
   wire 	   spi_wait;
   wire 	   shift;
   wire 	   spi_active;
   wire 	   tx_shift;
   wire 	   rx_shift;
   assign clkphase0[7:0]  = 'b0;
   assign clkphase0[15:8] = (clkdiv_reg[7:0]+1'b1)>>1;
   oh_clockdiv 
   oh_clockdiv (.clkdiv		(clkdiv_reg[7:0]),
		.clken		(1'b1),	
		.clkrise0	(period_match),
		.clkfall0	(phase_match),	
		.clkphase1	(16'b0),
		.clkout0	(clkout),
		.clkout1	(),
		.clkrise1	(),
		.clkfall1	(),
		.clkstable	(),
		.clkchange	(1'b0),
		.clk			(clk),
		.nreset			(nreset),
		.clkphase0		(clkphase0[15:0]));
`define SPI_IDLE    3'b000  
`define SPI_SETUP   3'b001  
`define SPI_DATA    3'b010  
`define SPI_HOLD    3'b011  
`define SPI_MARGIN  3'b100  
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       spi_state[2:0] <=  `SPI_IDLE;
   else
     case (spi_state[2:0])
       `SPI_IDLE : 
	 spi_state[2:0] <= fifo_read   ? `SPI_SETUP :  `SPI_IDLE;
       `SPI_SETUP :
	 spi_state[2:0] <= phase_match ? `SPI_DATA   : `SPI_SETUP;       
       `SPI_DATA : 
	 spi_state[2:0] <= data_done   ? `SPI_HOLD   : `SPI_DATA;
       `SPI_HOLD : 
	 spi_state[2:0] <= phase_match ? `SPI_MARGIN : `SPI_HOLD;
       `SPI_MARGIN : 
	 spi_state[2:0] <= phase_match ? `SPI_IDLE   : `SPI_MARGIN;
     endcase 
   assign fifo_read = ~fifo_empty & ~spi_wait & phase_match;
   assign data_done = fifo_empty & ~spi_wait & phase_match;
   always @ (posedge clk)
     load_byte <= fifo_read;
   assign spi_active = ~(spi_state[2:0]==`SPI_IDLE | spi_state[2:0]==`SPI_MARGIN);      
   assign ss    = ~((spi_active & ~manual_mode) | (send_data & manual_mode));
   always @ (posedge clk or negedge nreset)
     if(~nreset)
       sclk <= 1'b0;
     else if (period_match & (spi_state[2:0]==`SPI_DATA))
       sclk <= 1'b1;   
     else if (phase_match & (spi_state[2:0]==`SPI_DATA))	       
       sclk <= 1'b0;
   assign tx_shift     = phase_match & (spi_state[2:0]==`SPI_DATA);
   oh_par2ser  #(.PW(8),
		 .SW(1))
   par2ser (
	    .dout	(mosi),           
	    .access_out	(),
	    .wait_out	(spi_wait),
	    .clk	(clk),
	    .nreset	(nreset),         
	    .din	(fifo_dout[7:0]), 
	    .shift	(tx_shift),          
	    .datasize	(8'd7),           
	    .load	(load_byte),      
	    .lsbfirst	(lsbfirst),       
	    .fill	(1'b0),           
	    .wait_in	(1'b0));          
   assign rx_shift = (spi_state[2:0] == `SPI_DATA) & period_match;
   oh_ser2par #(.PW(64),
		.SW(1))
   ser2par (
	    .dout	(rx_data[63:0]),  
	    .din	(miso),           
	    .clk	(clk),            
	    .lsbfirst	(lsbfirst),       
	    .shift	(rx_shift));         
   always @ (posedge clk or negedge nreset)
     if(!nreset)
       ss_reg <= 1'b1;
     else
       ss_reg <= ss;
   assign rx_access = ss & ~ss_reg;
endmodule 
