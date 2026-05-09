`timescale 1ps/1ps
`timescale 1ps/1ps
module serdes_1_to_n_data_s8_se (use_phase_detector, datain, rxioclk, rxserdesstrobe, reset, gclk, bitslip, debug_in, data_out, debug) ;
parameter integer S = 8 ;   			
parameter integer D = 16 ;			
parameter  	  USE_PD = "FALSE" ;		
input 			use_phase_detector ;	
input 	[D-1:0]		datain ;		
input 			rxioclk ;		
input 			rxserdesstrobe ;	
input 			reset ;			
input 			gclk ;			
input 			bitslip ;		
input 	[1:0]		debug_in ;		
output 	[(D*S)-1:0]	data_out ;		
output 	[2*D+6:0] 	debug ;			
wire 	[D-1:0]		ddly_m;     		
wire 	[D-1:0]		ddly_s;     		
wire	[D-1:0]		busys ;			
wire	[D-1:0]		busym ;			
wire 	[D-1:0]		rx_data_in ;		
wire 	[D-1:0]		rx_data_in_fix ;	
wire 	[D-1:0]		cascade ;		
wire 	[D-1:0]		pd_edge ;		
reg	[8:0]		counter ;
reg	[3:0]		state ;
reg			cal_data_sint ;
wire 	[D-1:0]		busy_data ;
reg 			busy_data_d ;
wire			cal_data_slave ;
reg			enable ;
reg			cal_data_master ;
reg			rst_data ;
reg 			inc_data_int ;
wire 			inc_data ;
reg 	[D-1:0]		ce_data ;
reg 			valid_data_d ;
reg 			incdec_data_d ;
wire	[(8*D)-1:0] 	mdataout ;		
reg	[4:0] 		pdcounter ;
wire 	[D-1:0]		valid_data ;
wire 	[D-1:0]		incdec_data ;
reg 	[D-1:0]		mux ;
reg			ce_data_inta ;
reg			flag ;
wire	[D:0]		incdec_data_or ;
wire	[D-1:0]		incdec_data_im ;
wire	[D:0]		valid_data_or ;
wire	[D-1:0]		valid_data_im ;
wire	[D:0]		busy_data_or ;
wire	[D-1:0]		all_ce ;
parameter	SIM_TAP_DELAY = 49 ;		
parameter [D-1:0] RX_SWAP_MASK = 16'h0000 ;	
assign cal_data_slave = cal_data_sint ;
assign debug = {mux, cal_data_master, rst_data, cal_data_slave, busy_data_d, inc_data, ce_data, valid_data_d, incdec_data_d};
genvar i ;
genvar j ;
always @ (posedge gclk or posedge reset)
begin
if (reset == 1'b1) begin
	state <= 0 ;
	cal_data_master <= 1'b0 ;
	cal_data_sint <= 1'b0 ;
	counter <= 9'b000000000 ;
	enable <= 1'b0 ;
	mux <= 16'h0001 ;
end
else begin
   	counter <= counter + 9'b000000001 ;
   	if (counter[8] == 1'b1) begin
		counter <= 9'b000000000 ;
   	end
   	if (counter[5] == 1'b1) begin
		enable <= 1'b1 ;
   	end
  	if (state == 0 && enable == 1'b1) begin				
		cal_data_master <= 1'b0 ;
		cal_data_sint <= 1'b0 ;
		rst_data <= 1'b0 ;
   		if (busy_data_d == 1'b0) begin
			state <= 1 ;
		end
   	end
   	else if (state == 1) begin					
   		cal_data_master <= 1'b1 ;
   		cal_data_sint <= 1'b1 ;
   		if (busy_data_d == 1'b1) begin				
   			state <= 2 ;
   		end
   	end
   	else if (state == 2) begin					
   		cal_data_master <= 1'b0 ;
   		cal_data_sint <= 1'b0 ;
   		if (busy_data_d == 1'b0) begin
   			rst_data <= 1'b1 ;
   			state <= 3 ;
   		end
   	end
   	else if (state == 3) begin					
   		rst_data <= 1'b0 ;
   		if (busy_data_d == 1'b0) begin
   			state <= 4 ;
   		end
   	end
   	else if (state == 4) begin					
   		if (counter[8] == 1'b1) begin
  		 	state <= 5 ;
   		end
    	end
    	else if (state == 5) begin					
   		if (busy_data_d == 1'b0) begin
   			cal_data_sint <= 1'b1 ;
   			state <= 6 ;
   			if (D != 1) begin
   				mux <= {mux[D-2:0], mux[D-1]} ;
   			end
   		end
   	end
    	else if (state == 6) begin					
   		if (busy_data_d == 1'b1) begin
   			cal_data_sint <= 1'b0 ;
   			state <= 7 ;
   		end
   	end
   	else if (state == 7) begin					
    		cal_data_sint <= 1'b0 ;
  		if (busy_data_d == 1'b0) begin
   			state <= 4 ;
   		end
   	end
end
end
always @ (posedge gclk or posedge reset)				
begin
if (reset == 1'b1) begin
	pdcounter <= 5'h10 ;
	ce_data_inta <= 1'b0 ;
	flag <= 1'b0 ;							
end
else begin
	busy_data_d <= busy_data_or[D] ;
   	if (use_phase_detector == 1'b1 && USE_PD == "TRUE") begin	
		incdec_data_d <= incdec_data_or[D] ;
		valid_data_d <= valid_data_or[D] ;
		if (ce_data_inta == 1'b1) begin
			ce_data = mux ;
		end
		else begin
			ce_data = mux ^ mux ;
		end
   		if (state == 7) begin
 			flag <= 1'b0 ;
		end
   		else if (state != 4 || busy_data_d == 1'b1) begin	
			pdcounter <= 5'b10000 ;
   			ce_data_inta <= 1'b0 ;
   		end
   		else if (pdcounter == 5'b11111 && flag == 1'b0) begin	
   			ce_data_inta <= 1'b1 ;
   			inc_data_int <= 1'b1 ;
 			pdcounter <= 5'b10000 ;
 			flag <= 1'b1 ;
 		end
    		else if (pdcounter == 5'b00000 && flag == 1'b0) begin	
   			ce_data_inta <= 1'b1 ;
   			inc_data_int <= 1'b0 ;
 			pdcounter <= 5'b10000 ;
 			flag <= 1'b1 ;
   		end
		else if (valid_data_d == 1'b1) begin			
   			ce_data_inta <= 1'b0 ;
			if (incdec_data_d == 1'b1 && pdcounter != 5'b11111) begin
				pdcounter <= pdcounter + 5'b00001 ;
			end
			else if (incdec_data_d == 1'b0 && pdcounter != 5'b00000) begin	
				pdcounter <= pdcounter + 5'b11111 ;
			end
   		end
   		else begin
   			ce_data_inta <= 1'b0 ;
   		end
   	end
   	else begin
		ce_data = all_ce ;
		inc_data_int = debug_in[1] ;
   	end
end
end
assign inc_data = inc_data_int ;
assign incdec_data_or[0] = 1'b0 ;							
assign valid_data_or[0] = 1'b0 ;
assign busy_data_or[0] = 1'b0 ;
generate
for (i = 0 ; i <= (D-1) ; i = i+1)
begin : loop0
assign incdec_data_im[i] = incdec_data[i] & mux[i] ;					
assign incdec_data_or[i+1] = incdec_data_im[i] | incdec_data_or[i] ;			
assign valid_data_im[i] = valid_data[i] & mux[i] ;					
assign valid_data_or[i+1] = valid_data_im[i] | valid_data_or[i] ;			
assign busy_data_or[i+1] = busy_data[i] | busy_data_or[i] ;				
assign all_ce[i] = debug_in[0] ;
assign rx_data_in_fix[i] = rx_data_in[i] ^ RX_SWAP_MASK[i] ;	
IBUF data_in (
	.I    		(datain[i]),
	.O         	(rx_data_in[i]));
if (USE_PD == "TRUE" || S > 4) begin 			
assign busy_data[i] = busys[i] ;
IODELAY2 #(
	.DATA_RATE      	("SDR"), 		
	.IDELAY_VALUE  		(0), 			
	.IDELAY2_VALUE 		(0), 			
	.IDELAY_MODE  		("NORMAL" ), 		
	.ODELAY_VALUE  		(0), 			
	.IDELAY_TYPE   		("DIFF_PHASE_DETECTOR"),
	.COUNTER_WRAPAROUND 	("WRAPAROUND" ), 	
	.DELAY_SRC     		("IDATAIN" ), 		
	.SERDES_MODE   		("MASTER"), 		
	.SIM_TAPDELAY_VALUE   	(SIM_TAP_DELAY)) 	
iodelay_m (
	.IDATAIN  		(rx_data_in_fix[i]), 	
	.TOUT     		(), 			
	.DOUT     		(), 			
	.T        		(1'b1), 		
	.ODATAIN  		(1'b0), 		
	.DATAOUT  		(ddly_m[i]), 		
	.DATAOUT2 		(),	 		
	.IOCLK0   		(rxioclk), 		
	.IOCLK1   		(1'b0), 		
	.CLK      		(gclk), 		
	.CAL      		(cal_data_master),	
	.INC      		(inc_data), 		
	.CE       		(ce_data[i]), 		
	.RST      		(rst_data),		
	.BUSY      		()) ; 			
IODELAY2 #(
	.DATA_RATE      	("SDR"), 		
	.IDELAY_VALUE  		(0), 			
	.IDELAY2_VALUE 		(0), 			
	.IDELAY_MODE  		("NORMAL" ), 		
	.ODELAY_VALUE  		(0), 			
	.IDELAY_TYPE   		("DIFF_PHASE_DETECTOR"),
	.COUNTER_WRAPAROUND 	("WRAPAROUND" ), 	
	.DELAY_SRC     		("IDATAIN" ), 		
	.SERDES_MODE   		("SLAVE"), 		
	.SIM_TAPDELAY_VALUE   	(SIM_TAP_DELAY)) 	
iodelay_s (
	.IDATAIN 		(rx_data_in_fix[i]), 	
	.TOUT     		(), 			
	.DOUT     		(), 			
	.T        		(1'b1), 		
	.ODATAIN  		(1'b0), 		
	.DATAOUT  		(ddly_s[i]), 		
	.DATAOUT2 		(),	 		
	.IOCLK0   		(rxioclk), 		
	.IOCLK1   		(1'b0), 		
	.CLK      		(gclk), 		
	.CAL      		(cal_data_slave),	
	.INC      		(inc_data), 		
	.CE       		(ce_data[i]), 		
	.RST      		(rst_data),		
	.BUSY      		(busys[i])) ;		
ISERDES2 #(
	.DATA_WIDTH     	(S), 			
	.DATA_RATE      	("SDR"), 		
	.BITSLIP_ENABLE 	("TRUE"), 		
	.SERDES_MODE    	("MASTER"), 		
	.INTERFACE_TYPE 	("RETIMED")) 		
iserdes_m (
	.D       		(ddly_m[i]),
	.CE0     		(1'b1),
	.CLK0    		(rxioclk),
	.CLK1    		(1'b0),
	.IOCE    		(rxserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(gclk),
	.SHIFTIN 		(pd_edge[i]),
	.BITSLIP 		(bitslip),
	.FABRICOUT 		(),
	.Q4  			(mdataout[(8*i)+7]),
	.Q3  			(mdataout[(8*i)+6]),
	.Q2  			(mdataout[(8*i)+5]),
	.Q1  			(mdataout[(8*i)+4]),
	.DFB  			(),
	.CFB0 			(),
	.CFB1 			(),
	.VALID    		(valid_data[i]),
	.INCDEC   		(incdec_data[i]),
	.SHIFTOUT 		(cascade[i]));
ISERDES2 #(
	.DATA_WIDTH     	(S), 			
	.DATA_RATE      	("SDR"), 		
	.BITSLIP_ENABLE 	("TRUE"), 		
	.SERDES_MODE    	("SLAVE"), 		
	.INTERFACE_TYPE 	("RETIMED")) 		
iserdes_s (
	.D       		(ddly_s[i]),
	.CE0     		(1'b1),
	.CLK0    		(rxioclk),
	.CLK1    		(1'b0),
	.IOCE    		(rxserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(gclk),
	.SHIFTIN 		(cascade[i]),
	.BITSLIP 		(bitslip),
	.FABRICOUT 		(),
	.Q4  			(mdataout[(8*i)+3]),
	.Q3  			(mdataout[(8*i)+2]),
	.Q2  			(mdataout[(8*i)+1]),
	.Q1  			(mdataout[(8*i)+0]),
	.DFB  			(),
	.CFB0 			(),
	.CFB1 			(),
	.VALID 			(),
	.INCDEC 		(),
	.SHIFTOUT 		(pd_edge[i]));
end
if (USE_PD != "TRUE" && S < 5) begin 	
assign busy_data[i] = busym[i] ;
IODELAY2 #(
	.DATA_RATE      	("SDR"), 		
	.IDELAY_VALUE  		(0), 			
	.IDELAY2_VALUE 		(0), 			
	.IDELAY_MODE  		("NORMAL" ), 		
	.ODELAY_VALUE  		(0), 			
	.IDELAY_TYPE   		("VARIABLE_FROM_HALF_MAX"),
	.COUNTER_WRAPAROUND 	("WRAPAROUND" ), 	
	.DELAY_SRC     		("IDATAIN" ), 		
	.SERDES_MODE   		("MASTER"), 		
	.SIM_TAPDELAY_VALUE   	(SIM_TAP_DELAY)) 	
iodelay_m (
	.IDATAIN  		(rx_data_in_fix[i]), 	
	.TOUT     		(), 			
	.DOUT     		(), 			
	.T        		(1'b1), 		
	.ODATAIN  		(1'b0), 		
	.DATAOUT  		(ddly_m[i]), 		
	.DATAOUT2 		(),	 		
	.IOCLK0   		(rxioclk), 		
	.IOCLK1   		(1'b0), 		
	.CLK      		(gclk), 		
	.CAL      		(cal_data_master),	
	.INC      		(1'b0), 		
	.CE       		(1'b0), 		
	.RST      		(rst_data),		
	.BUSY      		(busym[i])) ; 		
ISERDES2 #(
	.DATA_WIDTH     	(S), 			
	.DATA_RATE      	("SDR"), 		
	.BITSLIP_ENABLE 	("TRUE"), 		
	.INTERFACE_TYPE 	("RETIMED")) 		
iserdes_m (
	.D       		(ddly_m[i]),
	.CE0     		(1'b1),
	.CLK0    		(rxioclk),
	.CLK1    		(1'b0),
	.IOCE    		(rxserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(gclk),
	.SHIFTIN 		(1'b0),
	.BITSLIP 		(bitslip),
	.FABRICOUT 		(),
	.Q4  			(mdataout[(8*i)+7]),
	.Q3  			(mdataout[(8*i)+6]),
	.Q2  			(mdataout[(8*i)+5]),
	.Q1  			(mdataout[(8*i)+4]),
	.DFB  			(),
	.CFB0 			(),
	.CFB1 			(),
	.VALID    		(),
	.INCDEC   		(),
	.SHIFTOUT 		());
end
for (j = 7 ; j >= (8-S) ; j = j-1)			
begin : loop2
assign data_out[((D*(j+S-8))+i)] = mdataout[(8*i)+j] ;
end
end
endgenerate
endmodule
