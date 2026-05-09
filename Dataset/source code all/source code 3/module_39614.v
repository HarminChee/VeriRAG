`timescale 1ps/1ps
`timescale 1ps/1ps
module serdes_n_to_1_s16_diff (txioclk, txserdesstrobe, reset, tx_bufg_pll_x2, tx_bufg_pll_x1, datain, clkin, dataout_p, dataout_n, clkout_p, clkout_n) ;
parameter integer S = 10 ;   		
parameter integer D = 16 ;		
input 			txioclk ;		
input 			txserdesstrobe ;	
input 			reset ;			
input 			tx_bufg_pll_x2 ;	
input 			tx_bufg_pll_x1 ;	
input 	[(D*S)-1:0]	datain ;  		
input 	[S-1:0]		clkin ;  		
output 	[D-1:0]		dataout_p ;		
output 	[D-1:0]		dataout_n ;		
output 			clkout_p ;		
output 			clkout_n ;		
wire	[D-1:0]	cascade_di ;		
wire	[D-1:0]	cascade_do ;		
wire	[D-1:0]	cascade_ti ;		
wire	[D-1:0]	cascade_to ;		
wire	[D-1:0]	tx_data_out ;		
wire	[D*8:0]	mdatain ;
reg		tx_toggle ;		
reg		old_tx_toggle ;		
reg	[7:0] 	tx_clk_int ;		
reg	[(D*S/2)-1:0] txd_int ;		
parameter [D-1:0] TX_SWAP_MASK = 16'h0000 ;	
genvar i ;
genvar j ;
always @ (posedge tx_bufg_pll_x1 or posedge reset)
if (reset == 1'b1) begin
	tx_toggle <= 1'b0 ;
end
else begin
	tx_toggle <= ~tx_toggle ;
end
always @ (posedge tx_bufg_pll_x2)
begin
	old_tx_toggle <= tx_toggle ;
	if (tx_toggle != old_tx_toggle) begin
		txd_int <= datain[(D*S/2)-1:0] ;
		tx_clk_int <= clkin[S/2-1:0] ;
	end
	else begin
		txd_int <= datain[(D*S)-1:D*S/2] ;
		tx_clk_int <= clkin[S-1:S/2] ;
	end
end
OBUFDS io_data_out (
	.O    			(clkout_p),
	.OB       		(clkout_n),
	.I         		(tx_clk_out));
generate
for (i = 0 ; i <= (D-1) ; i = i+1)
begin : loop0
OBUFDS #(
	.IOSTANDARD     	("DEFAULT" ))
io_data_out (
	.O    			(dataout_p[i]),
	.OB       		(dataout_n[i]),
	.I         		(tx_data_out[i]));
for (j = 0 ; j <= (S/2-1) ; j = j+1)
begin : loop1
assign mdatain[(8*i)+j] = txd_int[(i)+(D*j)] ^ TX_SWAP_MASK[i] ;
end
OSERDES2 #(
	.DATA_WIDTH     	(S/2), 			
	.DATA_RATE_OQ      	("SDR"), 		
	.DATA_RATE_OT      	("SDR"), 		
	.SERDES_MODE    	("MASTER"), 		
	.OUTPUT_MODE 		("DIFFERENTIAL"))
oserdes_m (
	.OQ       		(tx_data_out[i]),
	.OCE     		(1'b1),
	.CLK0    		(txioclk),
	.CLK1    		(1'b0),
	.IOCE    		(txserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(tx_bufg_pll_x2),
	.D4  			(mdatain[(8*i)+7]),
	.D3  			(mdatain[(8*i)+6]),
	.D2  			(mdatain[(8*i)+5]),
	.D1  			(mdatain[(8*i)+4]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3 			(1'b0),
	.T4 			(1'b0),
	.TRAIN    		(1'b0),
	.TCE	   		(1'b1),
	.SHIFTIN1 		(1'b1),			
	.SHIFTIN2 		(1'b1),			
	.SHIFTIN3 		(cascade_do[i]),	
	.SHIFTIN4 		(cascade_to[i]),	
	.SHIFTOUT1 		(cascade_di[i]),	
	.SHIFTOUT2 		(cascade_ti[i]),	
	.SHIFTOUT3 		(),			
	.SHIFTOUT4 		()) ;			
OSERDES2 #(
	.DATA_WIDTH     	(S/2), 			
	.DATA_RATE_OQ      	("SDR"), 		
	.DATA_RATE_OT      	("SDR"), 		
	.SERDES_MODE    	("SLAVE"), 		
	.OUTPUT_MODE 		("DIFFERENTIAL"))
oserdes_s (
	.OQ       		(),
	.OCE     		(1'b1),
	.CLK0    		(txioclk),
	.CLK1    		(1'b0),
	.IOCE    		(txserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(tx_bufg_pll_x2),
	.D4  			(mdatain[(8*i)+3]),
	.D3  			(mdatain[(8*i)+2]),
	.D2  			(mdatain[(8*i)+1]),
	.D1  			(mdatain[(8*i)+0]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3  			(1'b0),
	.T4  			(1'b0),
	.TRAIN 			(1'b0),
	.TCE	 		(1'b1),
	.SHIFTIN1 		(cascade_di[i]),	
	.SHIFTIN2 		(cascade_ti[i]),	
	.SHIFTIN3 		(1'b1),			
	.SHIFTIN4 		(1'b1),			
	.SHIFTOUT1 		(),			
	.SHIFTOUT2 		(),			
	.SHIFTOUT3 		(cascade_do[i]),   	
	.SHIFTOUT4 		(cascade_to[i])) ; 	
end
endgenerate
OSERDES2 #(
	.DATA_WIDTH     	(S/2), 			
	.DATA_RATE_OQ      	("SDR"), 		
	.DATA_RATE_OT      	("SDR"), 		
	.SERDES_MODE    	("MASTER"), 		
	.OUTPUT_MODE 		("DIFFERENTIAL"))
oserdes_cm (
	.OQ       		(tx_clk_out),
	.OCE     		(1'b1),
	.CLK0    		(txioclk),
	.CLK1    		(1'b0),
	.IOCE    		(txserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(tx_bufg_pll_x2),
	.D4  			(tx_clk_int[7]),
	.D3  			(tx_clk_int[6]),
	.D2  			(tx_clk_int[5]),
	.D1  			(tx_clk_int[4]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3 			(1'b0),
	.T4 			(1'b0),
	.TRAIN    		(1'b0),
	.TCE	   		(1'b1),
	.SHIFTIN1 		(1'b1),			
	.SHIFTIN2 		(1'b1),			
	.SHIFTIN3 		(cascade_dco),		
	.SHIFTIN4 		(cascade_tco),		
	.SHIFTOUT1 		(cascade_dci),		
	.SHIFTOUT2 		(cascade_tci),		
	.SHIFTOUT3 		(),			
	.SHIFTOUT4 		()) ;			
OSERDES2 #(
	.DATA_WIDTH     	(S/2), 			
	.DATA_RATE_OQ      	("SDR"), 		
	.DATA_RATE_OT      	("SDR"), 		
	.SERDES_MODE    	("SLAVE"), 		
	.OUTPUT_MODE 		("DIFFERENTIAL"))
oserdes_cs (
	.OQ       		(),
	.OCE     		(1'b1),
	.CLK0    		(txioclk),
	.CLK1    		(1'b0),
	.IOCE    		(txserdesstrobe),
	.RST     		(reset),
	.CLKDIV  		(tx_bufg_pll_x2),
	.D4  			(tx_clk_int[3]),
	.D3  			(tx_clk_int[2]),
	.D2  			(tx_clk_int[1]),
	.D1  			(tx_clk_int[0]),
	.TQ  			(),
	.T1 			(1'b0),
	.T2 			(1'b0),
	.T3  			(1'b0),
	.T4  			(1'b0),
	.TRAIN 			(1'b0),
	.TCE	 		(1'b1),
	.SHIFTIN1 		(cascade_dci),		
	.SHIFTIN2 		(cascade_tci),		
	.SHIFTIN3 		(1'b1),			
	.SHIFTIN4 		(1'b1),			
	.SHIFTOUT1 		(),			
	.SHIFTOUT2 		(),			
	.SHIFTOUT3 		(cascade_dco),   	
	.SHIFTOUT4 		(cascade_tco)) ; 	
endmodule
