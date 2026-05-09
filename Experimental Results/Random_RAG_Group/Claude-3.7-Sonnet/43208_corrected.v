`timescale 1ps/1ps
`timescale 1ps/1ps
module serdes_1_to_n_clk_pll_s8_diff (test_i, x_clk, rxioclk, pattern1, pattern2, rx_serdesstrobe, reset, rx_bufg_pll_x1, rx_pll_lckd, rx_pllout_xs, bitslip, rx_bufpll_lckd, datain) ;
parameter integer S = 8 ;   			
parameter         BS = "FALSE" ;   		
parameter         PLLX = 7 ;   			
parameter         PLLD = 1 ;   			
parameter real 	  CLKIN_PERIOD = 11.000 ;	
parameter         DIFF_TERM = "FALSE" ; 	
input            test_i;
input		x_clk ;		
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
wire		buf_P_clk ;		
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

wire clk_gated;
assign clk_gated = test_i ? rx_bufg_pll_x1 : rx_bufg_pll_x1;

assign busy_clk = busym ;
assign datain = mdataout[7:1] ;
assign 	bitslip = bslip ;

always @ (posedge clk_gated or negedge iRST_N)
begin
// ... existing code ...
end

// ... rest of existing code ...

endmodule