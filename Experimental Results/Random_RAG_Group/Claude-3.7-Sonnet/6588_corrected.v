`timescale 1ps/1ps
`timescale 1ps/1ps
module serdes_1_to_n_clk_pll_s16_diff (test_i, clkin_p, clkin_n, rxioclk, rx_serdesstrobe, reset, pattern1, rx_bufg_pll_x1, rx_bufg_pll_x2, bitslip, rx_toggle, rx_bufpll_lckd, datain) ;
parameter integer S = 16 ;   			
parameter integer BS = "FALSE" ;   		
parameter         PLLX = 2 ;   		
parameter         PLLD = 1 ;   		
parameter real 	  CLKIN_PERIOD = 6.000 ;
parameter         DIFF_TERM = "FALSE" ; 	
input            test_i;
input 		clkin_p ;			
input 		clkin_n ;			
output 		rxioclk ;			
output 		rx_serdesstrobe ;		
input 		reset ;				
input 	[S-1:0]	pattern1 ;	 		
output 		rx_bufg_pll_x1 ;		
output 		rx_bufg_pll_x2 ;		
output 		bitslip ;			
output 		rx_toggle ;			
output 		rx_bufpll_lckd ; 		
output 	[S-1:0] datain ;			
wire 		P_clk;       			
wire 		pll_fb_clk;  			
wire 		ddly_m;     			
wire 		ddly_s;     			
wire	[7:0]	mdataout ;			
wire		busys ;				
wire		busym ;				
wire		feedback ;			
wire		rx_clk_in ;			
reg		bslip ;				
reg	[S-1:0]	clk_iserdes_data ;		
wire	[S/2-1:0] clk_iserdes_data_int ;	
reg	[3:0]	state ;				
reg		cal_clk ;			
reg		rst_clk ;			
wire		not_rx_bufpll_lckd ;		
reg	[11:0]	counter ;
reg	[S/2-1:0] clkh ;
reg		busyd ;				
reg	[3:0]	count ;
reg		rx_toggle_int ;			
reg		enable ;			
parameter  	RX_SWAP_CLK  = 1'b0 ;		
wire        dft_clk;
assign dft_clk = test_i ? rx_bufg_pll_x1 : rx_clk_in;
assign busy_clk = busym ;
assign datain = clk_iserdes_data ;
assign rx_toggle = rx_toggle_int ;
assign bitslip = bslip ;

// ... existing code ...

IBUFGDS #(
	.DIFF_TERM 		(DIFF_TERM)) 
iob_clk_in (
	.I    			(clkin_p),
	.IB       		(clkin_n),
	.O         		(rx_clk_in));

assign iob_data_in = dft_clk ^ RX_SWAP_CLK ;

// ... rest of existing code ...

endmodule