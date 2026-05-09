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

// Declare missing wires
wire            busy_clk;
wire            feedback;
wire            cascade;
wire            pd_edge;
wire            rx_pllout_x1;


assign busy_clk = busym ;
assign datain = clk_iserdes_data ;
assign 	bitslip = bslip ;

always @ (posedge rx_bufg_pll_x1 or posedge not_rx_bufpll_lckd)
begin
if (not_rx_bufpll_lckd == 1'b1) begin
	state <= 4'd0 ; // Use sized literal
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
		state <= 4'd0 ; // Use sized literal
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

   		// Use sized literals for state comparison
   		if (state == 4'd0 && enable == 1'b1 && busyd == 1'b0) begin
   			state <= 4'd1 ;
   		end
   		else if (state == 4'd1) begin
   			cal_clk <= 1'b1 ; state <= 4'd2 ;
   		end
   		else if (state == 4'd2) begin
   			cal_clk <= 1'b0 ;
   			if (busyd == 1'b1) begin
   				state <= 4'd3 ;
   			end
   		end
   		else if (state == 4'd3 && busyd == 1'b0) begin
   			rst_clk <= 1'b1 ; state <= 4'd4 ;
   		end
   		else if (state == 4'd4) begin
   			rst_clk <= 1'b0 ; state <= 4'd5 ;
   		end
   		else if (state == 4'd5 && busyd == 1'b0) begin
   			state <= 4'd6 ;
   			count <= 3'b000 ;
   		end
   		else if (state == 4'd6) begin
   			count <= count + 3'b001 ;
   			if (count == 3'b111) begin
        			state <= 4'd7 ;
        		end
       		end
     		else if (state == 4'd7) begin
   			if (BS == "TRUE" && flag1 == 1'b1 && flag2 == 1'b1) begin
     		   		bslip <= 1'b1 ;
     		   		state <= 4'd8 ;
     		   		count <= 3'b000 ;
     		   	end
     		   	else begin
     		   		state <= 4'd9 ;
     		   	end
		end
   		else if (state == 4'd8) begin
     		   	bslip <= 1'b0 ;
     		   	count <= count + 3'b001 ;
   			if (count == 3'b111) begin
     		   		state <= 4'd7 ;
     		   	end
     		end
   		else if (state == 4'd9) begin
     		   	state <= 4'd9 ; // Stays in state 9
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
// This assigns the upper S bits of mdataout to datain
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
	.IDELAY_TYPE   		("FIXED"), // Typically slave delay is fixed or follows master
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
	.IOCLK0    		(rxioclk), // Slave needs IOCLK too
	.IOCLK1   		(1'b0),
	.CLK      		(1'b0), // Typically no separate CLK for slave IODELAY in this mode
	.CAL      		(1'b0),
	.INC      		(1'b0),
	.CE       		(1'b0),
	.RST      		(rst_clk), // Slave delay might need reset
	.BUSY      		()) ; // Slave busy usually not needed

BUFIO2 #(
      .DIVIDE			(1),
      .DIVIDE_BYPASS		("TRUE"))
P_clk_bufio2_inst (
      .I			(P_clk),
      .IOCLK			(),
      .DIVCLK			(buf_P_clk),
      .SERDESSTROBE		()) ;

BUFIO2FB #(
      .DIVIDE_BYPASS		("TRUE"))
P_clk_bufio2fb_inst (
      .I			(feedback),
      .O			(buf_pll_fb_clk)) ;

ISERDES2 #(
	.DATA_WIDTH     	(8), // Fixed to 8 based on Q1-Q4 connections
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
	.SHIFTIN 		(pd_edge), // Connect SHIFTOUT from slave
	.BITSLIP 		(bslip),
	.FABRICOUT 		(),
	.DFB 			(P_clk),      // Master drives DFB
	.CFB0 			(feedback),   // Master drives CFB0
	.CFB1 			(),
	.Q4 			(mdataout[7]),
	.Q3 			(mdataout[6]),
	.Q2 			(mdataout[5]),
	.Q1 			(mdataout[4]),
	.VALID    		(),
	.INCDEC   		(),
	.SHIFTOUT 		(cascade)); // Connect SHIFTIN to slave

ISERDES2 #(
	.DATA_WIDTH     	(8), // Fixed to 8 based on Q1-Q4 connections
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
	.SHIFTIN 		(cascade), // Connect SHIFTOUT from master
	.BITSLIP 		(bslip),
	.FABRICOUT 		(),
	.DFB 			(P_clk),      // Slave receives DFB
	.CFB0 			(feedback),   // Slave receives CFB0
	.CFB1 			(),
	.Q4  			(mdataout[3]),
	.Q3  			(mdataout[2]),
	.Q2  			(mdataout[1]),
	.Q1  			(mdataout[0]),
	.VALID 			(),
	.INCDEC 		(),
	.SHIFTOUT 		(pd_edge)); // Connect SHIFTIN to master

PLL_ADV #(
      .BANDWIDTH		("OPTIMIZED"),
      .CLKFBOUT_MULT		(PLLX),
      .CLKFBOUT_PHASE		(0.0),
      .CLKIN1_PERIOD		(CLKIN_PERIOD),
      .CLKIN2_PERIOD		(CLKIN_PERIOD), // Typically same as CLKIN1 or unused
      .CLKOUT0_DIVIDE		(1), // For feedback loop
      .CLKOUT0_DUTY_CYCLE	(0.5),
      .CLKOUT0_PHASE		(0.0),
      .CLKOUT1_DIVIDE		(S), // Should use S for CLKOUT related to ISERDES width? No, CLKOUT2 is used.
      .CLKOUT1_DUTY_CYCLE	(0.5),
      .CLKOUT1_PHASE		(0.0),
      .CLKOUT2_DIVIDE		(S), // CLKDIV input to ISERDES (Parallel Clock)
      .CLKOUT2_DUTY_CYCLE	(0.5),
      .CLKOUT2_PHASE		(0.0),
      .CLKOUT3_DIVIDE		(1), // Unused, set to 1
      .CLKOUT3_DUTY_CYCLE	(0.5),
      .CLKOUT3_PHASE		(0.0),
      .CLKOUT4_DIVIDE		(1), // Unused, set to 1
      .CLKOUT4_DUTY_CYCLE	(0.5),
      .CLKOUT4_PHASE		(0.0),
      .CLKOUT5_DIVIDE		(1), // Unused, set to 1
      .CLKOUT5_DUTY_CYCLE	(0.5),
      .CLKOUT5_PHASE		(0.0),
      .COMPENSATION		("SOURCE_SYNCHRONOUS"), // Check if appropriate for SERDES I/F
      .DIVCLK_DIVIDE		(PLLD),
      .CLK_FEEDBACK		("CLKFBOUT"), // Typically CLKFBOUT for external feedback via BUFIO2FB
      .REF_JITTER		(0.100))
rx_pll_adv_inst (
      .CLKFBDCM			(),
      .CLKFBOUT			(feedback_pll), // Internal PLL feedback signal
      .CLKOUT0			(rx_pllout_xs),      // High speed clock for BUFPLL -> IOCLK
      .CLKOUT1			(),      	     // Unused
      .CLKOUT2			(rx_pllout_x1), 	     // Parallel clock for BUFG -> CLKDIV
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
      .CLKFBIN			(buf_pll_fb_clk), // Feedback from BUFIO2FB
      .CLKIN1			(buf_P_clk),      // Clock from BUFIO2
      .CLKIN2			(1'b0),
      .CLKINSEL			(1'b1),           // Use CLKIN1
      .DADDR			(5'b00000),
      .DCLK			(1'b0),
      .DEN			(1'b0),
      .DI			(16'h0000),
      .DWE			(1'b0),
      .RST			(reset),
      .REL			(1'b0)) ;

// Declare the internal PLL feedback wire if CLK_FEEDBACK = "CLKFBOUT"
wire feedback_pll;

BUFG	bufg_pll_x1 (.I(rx_pllout_x1), .O(rx_bufg_pll_x1) ) ;

BUFPLL #(
      .DIVIDE			(S)) // Divides PLLIN (rx_pllout_xs) by S for SERDESSTROBE
rx_bufpll_inst (
      .PLLIN			(rx_pllout_xs),     // High-speed clock from PLL CLKOUT0
      .GCLK			(rx_bufg_pll_x1),   // Global clock buffer output (parallel clock)
      .LOCKED			(rx_pll_lckd),      // PLL lock signal input
      .IOCLK			(rxioclk),          // High-speed clock for I/O logic (ISERDES CLK0)
      .LOCK			(rx_bufplllckd),    // BUFPLL lock output
      .SERDESSTROBE		(rx_serdesstrobe)) ;// Strobe signal for ISERDES IOCE

assign rx_bufpll_lckd = rx_pll_lckd & rx_bufplllckd ;
assign not_rx_bufpll_lckd = ~rx_bufpll_lckd ;

endmodule