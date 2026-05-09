`timescale 1ps/1ps
`timescale 1ps/1ps
module top_nto1_pll_diff_tx (
input		reset,				
input		refclkin_p,  refclkin_n,	
input		test_i, // Added for DFT
input		test_clk, // Added for DFT
output	[5:0]	dataout_p, dataout_n,		
output		clkout_p,  clkout_n) ;		
parameter integer     S = 7 ;			
parameter integer     D = 6 ;			
parameter integer     DS = (D*S)-1 ;		
wire       	rst ;
reg	[DS:0] 	txd ;				
parameter [S-1:0] TX_CLK_GEN   = 7'b1100001 ;	

wire tx_bufpll_clk_xn;
wire tx_serdesstrobe;
wire tx_bufg_x1;
wire tx_bufpll_lckd;

assign rst = reset ; 					
clock_generator_pll_s8_diff #(
	.S 			(S),
	.PLLX			(7),
	.PLLD			(1),
	.CLKIN_PERIOD 		(7.000))
inst_clkgen(
	.reset			(rst), // Controlled by primary input 'reset'
	.clkin_p		(refclkin_p), 
	.clkin_n		(refclkin_n),
	.ioclk			(tx_bufpll_clk_xn), // Internally generated clock
	.serdesstrobe		(tx_serdesstrobe),
	.gclk			(tx_bufg_x1), // Internally generated clock
	.bufpll_lckd		(tx_bufpll_lckd)) ;

// DFT Clock Muxing
wire dft_txd_clk = test_i ? test_clk : tx_bufg_x1;
wire dft_serdes_txioclk = test_i ? test_clk : tx_bufpll_clk_xn;
wire dft_serdes_gclk = test_i ? test_clk : tx_bufg_x1;

// Flip-flop block using muxed clock
always @ (posedge dft_txd_clk or posedge rst) // Use muxed clock, reset is controllable			
begin
if (rst == 1'b1) begin
	txd <= 42'h00000000001 ;
end
else begin
	txd <= {txd[40:0], txd[41]} ;
end
end

// SERDES instance using muxed clocks
serdes_n_to_1_s8_diff #(
      	.S			(S),
      	.D			(1))
inst_clkout (
	.dataout_p  		(clkout_p),
	.dataout_n  		(clkout_n),
	.txioclk    		(dft_serdes_txioclk), // Use muxed clock
	.txserdesstrobe 	(tx_serdesstrobe), // Strobe - may need DFT handling
	.gclk    		(dft_serdes_gclk), // Use muxed clock
	.reset     		(rst), // Controlled by primary input 'reset'
	.datain  		(TX_CLK_GEN));			

// SERDES instance using muxed clocks
serdes_n_to_1_s8_diff #(
      	.S			(S),
      	.D			(D))
inst_dataout (
	.dataout_p  		(dataout_p),
	.dataout_n  		(dataout_n),
	.txioclk    		(dft_serdes_txioclk), // Use muxed clock
	.txserdesstrobe 	(tx_serdesstrobe), // Strobe - may need DFT handling
	.gclk    		(dft_serdes_gclk), // Use muxed clock
	.reset   		(rst), // Controlled by primary input 'reset'
	.datain  		(txd)); // Data input from FF with muxed clock
endmodule