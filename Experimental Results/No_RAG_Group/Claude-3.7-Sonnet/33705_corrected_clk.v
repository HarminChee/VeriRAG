`timescale 1ps/1ps
`timescale 1ps/1ps
module serdes_1_to_n_clk_pll_s8_diff (clkin_p, clkin_n, rxioclk, pattern1, pattern2, rx_serdesstrobe, reset, rx_bufg_pll_x1, rx_pll_lckd, rx_pllout_xs, bitslip, rx_bufpll_lckd, datain) ;
parameter integer S = 8 ;   			
parameter         BS = "FALSE" ;   		
parameter         PLLX = 7 ;   			
parameter         PLLD = 1 ;   			
parameter real 	  CLKIN_PERIOD = 6.000 ;	
parameter         DIFF_TERM = "FALSE" ; 	
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
// Primary input clock connection for P_clk signal
input           ext_feedback_clk;   // New primary input for feedback clock

assign busy_clk = busym ;
assign datain = clk_iserdes_data ;
assign 	bitslip = bslip ;
always @ (posedge rx_bufg_pll_x1 or posedge not_rx_bufpll_lckd)
begin
if (not_rx_bufpll_lckd == 1'b1) begin
	state <= 0 ;
	enable <= 1'b0 ;
	cal_clk <= 1'b0 ;
	rst_clk <= 1'b0 ;
	bslip <= 1'b0 ;
   	busyd <= 1'b1 ;
	counter <= 12'b000000000000 ;
end
else begin
   	busyd <= busy_clk ;
   	if (counter[5] == 1'b1) begin
		enable <= 1'b1 ;
   	end
   	if (counter[11] == 1'b1) begin					
		state <= 0 ;
		cal_clk <= 1'b0 ;
		rst_clk <= 1'b0 ;
		bslip <= 1'b0 ;
   		busyd <= 1'b1 ;
		counter <= 12'b000000000000 ;
   	end 
   	else begin
   		counter <= counter + 12'b000000000001 ;
   		if (clk_iserdes_data != pattern1) begin flag1 <= 1'b1 ; end else begin flag1 <= 1'b0 ; end
   		if (clk_iserdes_data != pattern2) begin flag2 <= 1'b1 ; end else begin flag2 <= 1'b0 ; end
   		if (state == 0 && enable == 1'b1 && busyd == 1'b0) begin
   			state <= 1 ;
   		end
   		else if (state == 1) begin				
   			cal_clk <= 1'b1 ; state <= 2 ;
   		end
   		else if (state == 2) begin
   			cal_clk <= 1'b0 ;				
   			if (busyd == 1'b1) begin			
   				state <= 3 ;
   			end	
   		end
   		else if (state == 3 && busyd == 1'b0) begin		
   			rst_clk <= 1'b1 ; state <= 4 ;			
   		end
   		else if (state == 4) begin				
   			rst_clk <= 1'b0 ; state <= 5 ;
   		end
   		else if (state == 5 && busyd == 1'b0) begin		
   			state <= 6 ;
   			count <= 3'b000 ;
   		end
   		else if (state == 6) begin				
   			count <= count + 3'b001 ;
   			if (count == 3'b111) begin
        			state <= 7 ;
        		end
       		end
     		else if (state == 7) begin
   			if (BS == "TRUE" && flag1 == 1'b1 && flag2 == 1'b1) begin
     		   		bslip <= 1'b1 ;				
     		   		state <= 8 ;
     		   		count <= 3'b000 ;
     		   	end
     		   	else begin
     		   		state <= 9 ;
     		   	end
		end
   		else if (state == 8) begin
     		   	bslip <= 1'b0 ;					
     		   	count <= count + 3'b001 ;
   			if (count == 3'b111) begin
     		   		state <= 7 ;
     		   	end
     		end
   		else if (state == 9) begin				
     		   	state <= 9 ;
   		end
   	end
end
end
IBUFGDS #(
	.DIFF_TERM 		(DIFF_TERM)) 
iob_clk_in (
	.I    			(clkin_p),
	.IB       		(clkin_n),
	.O         		(rx_clk_in));
assign iob_datain = rx_clk_in ^ RX_SWAP_CLK ;		
genvar i ;						
generate
for (i = 0 ; i <= (S - 1) ; i = i + 1)
begin : loop0
assign clk_iserdes_data[i] = mdataout[8+i-S] ;
end
endgenerate
IODELAY2 #(
	.DATA_RATE      	("SDR"), 			
	.SIM_TAPDELAY_VALUE	(49),  				
	.IDELAY_VALUE  		(0), 				
	.IDELAY2_VALUE 		(0), 				
	.ODELAY_VALUE  		(0), 				
	.IDELAY_MODE   		("NORMAL"), 			
	.SERDES_MODE   		("MASTER"), 			
	.IDELAY_TYPE   		("VARIABLE_FROM_HALF_MAX"), 	
	.COUNTER_WRAPAROUND 	("STAY_AT_LIMIT"), 		
	.DELAY_SRC     		("IDATAIN")) 			
iodelay_m (
	.IDATAIN  		(iob_datain), 			
	.TOUT     		(), 				
	.DOUT     		(), 				
	.T        		(1'b1), 			
	.ODATAIN  		(1'b0), 			
	.DATAOUT  		(ddly_m), 			
	.DATAOUT2 		(),	 			
	.IOCLK0   		(rxioclk), 			
	.IOCLK1   		(1'b0), 			
	.CLK      		(rx_bufg_pll_x1), 		
	.CAL      		(cal_clk), 			
	.INC      		(1'b0), 			
	.CE       		(1'b0), 			
	.RST      		(rst_clk), 			
	.BUSY      		(busym)) ;  			
IODELAY2 #(
	.DATA_RATE      	("SDR"), 			
	.SIM_TAPDELAY_VALUE	(49),  				
	.IDELAY_VALUE  		(0), 				
	.IDELAY2_VALUE 		(0), 				
	.ODELAY_VALUE  		(0), 				
	.IDELAY_MODE   		("NORMAL"), 			
	.SERDES_MODE   		("SLAVE"), 			
	.IDELAY_TYPE   		("FIXED"), 			
	.COUNTER_WRAPAROUND 	("STAY_AT_LIMIT"), 		
	.DELAY_SRC     		("IDATAIN")) 			
iodelay_s (
	.IDATAIN 		(iob_datain), 			
	.TOUT     		(), 				
	.DOUT     		(), 				
	.T        		(1'b1), 			
	.ODATAIN  		(1'b0), 			
	.DATAOUT 		(ddly_s), 			
	.DATAOUT2 		(),	 			
	.IOCLK0    		(1'b0), 			
	.IOCLK1   		(1'b0), 			
	.CLK      		(1'b0), 			
	.CAL      		(1'b0), 			
	.INC      		(1'b0), 			
	.CE       		(1'b0), 			
	.RST      		(1'b0), 			
	.BUSY      		()) ;				
BUFIO2 #(
      .DIVIDE			(1),               		
      .DIVIDE_BYPASS		("TRUE"))    			
P_clk_bufio2_inst (
      .I			(rx_clk_in),               	// Changed from P_clk to rx_clk_in
      .IOCLK			(),        			
      .DIVCLK			(buf_P_clk),    		
      .SERDESSTROBE		()) ;           		
BUFIO2FB #(
      .DIVIDE_BYPASS		("TRUE"))    			
P_clk_bufio2fb_inst (
      .I			(ext_feedback_clk),          	// Changed from feedback to ext_feedback_clk
      .O			(buf_pll_fb_clk)) ;   		
ISERDES2 #(
	.DATA_WIDTH     	(S), 				
	.DATA_RATE      	("SDR"), 			
	.BITSLIP_ENABLE 	("TRUE"), 			
	.SERDES_MODE    	("MASTER"), 			
	.INTERFACE_TYPE 	("RETIMED")) 			
iserdes_m (
	.D       		(ddly_m),
	.CE0     		(1'b1),
	.CLK0    		(rxioclk),
	.CLK1    		(1'b0),
	.IOCE    		(rx_serdesstrobe),
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
	.CLK0    		(rxioclk),
	.CLK1    		(1'b0),
	.IOCE    		(rx_serdesstrobe),
	.RST     		(not_rx_bufpll_lckd),
	.CLKDIV  		(rx_bufg_pll_x1),
	.SHIFTIN 		(cascade),
	.BITSLIP 		(bslip),
	.FABRICOUT 		(),
	.DFB 			(), // Removed P_clk output
	.CFB0 			(), // Removed feedback output
	.CFB1 			(),
	.Q4  			(mdataout[3]),
	.Q3  			(mdataout[2]),
	.Q2  			(mdataout[1]),
	.Q1  			(mdataout[0]),
	.VALID 			(),
	.INCDEC 		(),
	.SHIFTOUT 		(pd_edge));
PLL_ADV #(
      .BANDWIDTH		("OPTIMIZED"),  		
      .CLKFBOUT_MULT		(PLLX),       			
      .CLKFBOUT_PHASE		(0.0),     			
      .CLKIN1_PERIOD		(CLKIN_PERIOD),  		
      .CLKIN2_PERIOD		(CLKIN_PERIOD),  		
      .CLKOUT0_DIVIDE		(1),       			
      .CLKOUT0_DUTY_CYCLE	(0.5), 				
      .CLKOUT0_PHASE		(0.0), 				
      .CLKOUT1_DIVIDE		(1),   				
      .CLKOUT1_DUTY_CYCLE	(0.5), 				
      .CLKOUT1_PHASE		(0.0), 				
      .CLKOUT2_DIVIDE		(S),   				
      .CLKOUT2_DUTY_CYCLE	(0.5), 				
      .CLKOUT2_PHASE		(0.0), 				
      .CLKOUT3_DIVIDE		(7),   				
      .CLKOUT3_DUTY_CYCLE	(0.5), 				
      .CLKOUT3_PHASE		(0.0), 				
      .CLKOUT4_DIVIDE		(7),   				
      .CLKOUT4_DUTY_CYCLE	(0.5), 				
      .CLKOUT4_PHASE		(0.0),      			
      .CLKOUT5_DIVIDE		(7),       			
      .CLKOUT5_DUTY_CYCLE	(0.5), 				
      .CLKOUT5_PHASE		(0.0),      			
      .COMPENSATION		("SOURCE_SYNCHRONOUS"),		
      .DIVCLK_DIVIDE		(PLLD),        			
      .CLK_FEEDBACK		("CLKOUT0"),       		
      .REF_JITTER		(0.100))        		
rx_pll_adv_inst (
      .CLKFBDCM			(),              		
      .CLKFBOUT			(),              		
      .CLKOUT0			(rx_pllout_xs),      		
      .CLKOUT1			(),      			
      .CLKOUT2			(rx_pllout_x1), 		
      .CLKOUT3			(),              		
      .CLKOUT4			(),              		
      .CLKOUT5			(),              		
      .CLKOUTDCM0		(),            			
      .CLKOUTDCM1		(),            			
      .CLKOUTDCM2		(),            			
      .CLKOUTDCM3		(),            			
      .CLKOUTDCM4		(),            			
      .CLKOUTDCM5		(),            			
      .DO			(),                    		
      .DRDY			(),                  		
      .LOCKED			(rx_pll_lckd),        		
      .CLKFBIN			(buf_pll_fb_clk),		
      .CLKIN1			(buf_P_clk),     		
      .CLKIN2			(1'b0),		     		
      .CLKINSEL			(1'b1),             		
      .DADDR			(5'b00000),            		
      .DCLK			(1'b0),               		
      .DEN			(1'b0),                		
      .DI			(16'h0000),        		
      .DWE			(1'b0),                		
      .RST			(reset),               		
      .REL			(1'b0)) ;    			
BUFG	bufg_pll_x1 (.I(rx_pllout_x1), .O(rx_bufg_pll_x1) ) ;
BUFPLL #(
      .DIVIDE			(S))              		
rx_bufpll_inst (
      .PLLIN			(rx_pllout_xs),        		
      .GCLK			(rx_bufg_pll_x1), 		
      .LOCKED			(rx_pll_lckd),             	
      .IOCLK			(rxioclk), 			
      .LOCK			(rx_bufplllckd),          	
      .SERDESSTROBE		(rx_serdesstrobe)) ; 		
assign rx_bufpll_lckd = rx_pll_lckd & rx_bufplllckd ;
assign not_rx_bufpll_lckd = ~rx_bufpll_lckd ;
endmodule