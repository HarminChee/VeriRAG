`timescale 1ps/1ps
`timescale 1ps/1ps
module serdes_1_to_n_clk_pll_s8_diff (test_i, clkin_p, clkin_n, rxioclk, pattern1, pattern2, rx_serdesstrobe, reset, rx_bufg_pll_x1, rx_pll_lckd, rx_pllout_xs, bitslip, rx_bufpll_lckd, datain) ;
parameter integer S = 8 ;   			
parameter         BS = "FALSE" ;   		
parameter         PLLX = 7 ;   			
parameter         PLLD = 1 ;   			
parameter real 	  CLKIN_PERIOD = 6.000 ;	
parameter         DIFF_TERM = "FALSE" ; 	
input            test_i;
input 		clkin_p ;			
input 		clkin_n ;			
input 		reset ;				
input 	[S-1:0]	pattern1 ;	 		
input 	[S-1:0]	pattern2 ;	 		
output 		rxioclk ;			
output 		rx_serdesstrobe ;		
output 		rx_bufg_pll_x1 ;		
output 		rx_pll_lckd ; 			
output 		rx_pllout_xs ;			
output 		bitslip ;			
output 		rx_bufpll_lckd ; 		
output 	[S-1:0]	datain ;	 		
wire 		P_clk ;       		
wire 		buf_pll_fb_clk ;	
wire 		ddly_m ;     		
wire 		ddly_s ;     		
wire	[7:0]	mdataout ;		
wire		busys ;			
wire		busym ;			
wire		rx_clk_in ;		
wire		buf_P_clk ;		
wire		iob_datain ;		
reg	[3:0]	state ;
reg 		bslip ;
reg	[2:0]	count ;
reg 		busyd ;
reg	[11:0]	counter ;
wire 	[S-1:0] clk_iserdes_data ;
reg 		cal_clk ;
reg 		rst_clk ;
wire		rx_bufplllckd ;
wire		not_rx_bufpll_lckd ;
reg 		enable ;
reg 		flag1 ;
reg 		flag2 ;
parameter  	RX_SWAP_CLK  = 1'b0 ;	
wire        dft_rxioclk;
wire        dft_rx_serdesstrobe;
assign dft_rxioclk = test_i ? rx_bufg_pll_x1 : rxioclk;
assign dft_rx_serdesstrobe = test_i ? 1'b0 : rx_serdesstrobe;
assign busy_clk = busym ;
assign datain = clk_iserdes_data ;
assign 	bitslip = bslip ;
// ... existing code ...
ISERDES2 #(
	.DATA_WIDTH     	(S), 				
	.DATA_RATE      	("SDR"), 			
	.BITSLIP_ENABLE 	("TRUE"), 			
	.SERDES_MODE    	("MASTER"), 			
	.INTERFACE_TYPE 	("RETIMED")) 			
iserdes_m (
	.D       		(ddly_m),
	.CE0     		(1'b1),
	.CLK0    		(dft_rxioclk),
	.CLK1    		(1'b0),
	.IOCE    		(dft_rx_serdesstrobe),
	.RST     		(not_rx_bufpll_lckd),
	.CLKDIV  		(rx_bufg_pll_x1),
	.SHIFTIN 		(pd_edge),
	.BITSLIP 		(bslip),
	.FABRICOUT 		(),
	.DFB 			(),
	.CFB0 			(),
	.CFB1 			(),
	.Q4 			(mdataout[7]),
	.Q3 			(mdataout[6]),
	.Q2 			(mdataout[5]),
	.Q1 			(mdataout[4]),
	.VALID    		(),
	.INCDEC   		(),
	.SHIFTOUT 		(cascade));
ISERDES2 #(
	.DATA_WIDTH     	(S), 				
	.DATA_RATE      	("SDR"), 			
	.BITSLIP_ENABLE 	("TRUE"), 			
	.SERDES_MODE    	("SLAVE"), 			
	.INTERFACE_TYPE 	("RETIMED")) 			
iserdes_s (
	.D       		(ddly_s),
	.CE0     		(1'b1),
	.CLK0    		(dft_rxioclk),
	.CLK1    		(1'b0),
	.IOCE    		(dft_rx_serdesstrobe),
	.RST     		(not_rx_bufpll_lckd),
	.CLKDIV  		(rx_bufg_pll_x1),
	.SHIFTIN 		(cascade),
	.BITSLIP 		(bslip),
	.FABRICOUT 		(),
	.DFB 			(P_clk),
	.CFB0 			(feedback),
	.CFB1 			(),
	.Q4  			(mdataout[3]),
	.Q3  			(mdataout[2]),
	.Q2  			(mdataout[1]),
	.Q1  			(mdataout[0]),
	.VALID 			(),
	.INCDEC 		(),
	.SHIFTOUT 		(pd_edge));
// ... rest of existing code ...
endmodule