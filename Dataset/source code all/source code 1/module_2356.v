module WcaLimeIF
(
	input					 clock_dsp, 
	input              clock_rx,  
	input              clock_tx,  
	input              reset,		
	input					 aclr,      
	input  wire [23:0] tx_iq,			
	output reg  [23:0] rx_iq,			
	output wire 		 rx_strobe,    
	output wire			 tx_strobe,		
	output wire         rf_rxclk,           
	input  wire         rf_rxiqsel,
	output wire         rf_rxen,
	input wire [11:0]   rf_rxdata,
	output wire         rf_txclk,           
	output wire         rf_txiqsel,
	output wire         rf_txen,
	output wire [11:0]   rf_txdata,
	input   wire  [11:0] rbusCtrl,  
	inout   wire  [7:0]  rbusData	
);
parameter CTRL_ADDR = 0;
parameter RSSI_ADDR = 0;
parameter RXBIAS_ADDR = 0;
	wire [7:0] rf_ctrl;
	WcaWriteByteReg #(CTRL_ADDR) wr_rf_ctrl
	(.reset(reset), .out( rf_ctrl), .rbusCtrl(rbusCtrl), .rbusData(rbusData) );
	WcaSynchEdgeDetect synchRxEnable ( .clk(clock_rx), .in(rf_ctrl[4]),  .out(rf_rxen));
	WcaSynchEdgeDetect synchTxEnable ( .clk(clock_rx), .in(rf_ctrl[4]),  .out(rf_txen));
   ODDR2 oddr2_rxclk	( .D0(1'b1), .D1(1'b0), .CE(rf_ctrl[6]),	.C0(clock_rx),	.C1(~clock_rx), .Q(rf_rxclk) );
	ODDR2 oddr2_txclk ( .D0(1'b1), .D1(1'b0),	.CE(rf_ctrl[7]),	.C0(clock_tx),	.C1(~clock_tx), .Q(rf_txclk) );
	wire  clearState = reset | aclr;
	wire  [11:0] rx_DciBiasRemoved; 
	reg   [1:0] reg_rxstrobe;
	always @(posedge clock_dsp)
	begin
		if( clearState)
			begin
				reg_rxstrobe[0] <= 1'b0;
				reg_rxstrobe[1] <= 1'b0;
			end
		else	
			begin
				reg_rxstrobe[0] <= ~rf_rxiqsel & ~reg_rxstrobe[1] &~reg_rxstrobe[0];
				reg_rxstrobe[1] <= reg_rxstrobe[0];
			end
	end
	assign rx_strobe = reg_rxstrobe[1] & rf_ctrl[6];
	always @(posedge clock_dsp)
	begin
	  case( { rf_ctrl[1:0]} )
		2'b00 : 
		 begin
			rx_iq <= #1 tx_iq;
		 end
		2'b01 : 
		 begin
			if( rf_rxiqsel )
				 rx_iq[11:0] <= #1 rx_DciBiasRemoved;
			else
				 rx_iq[23:12]  <= #1 rx_DciBiasRemoved;		 
		 end
		2'b10 :  
		 begin
			if( rf_rxiqsel )
				 rx_iq[11:0] <= #1 rf_rxdata;
			else
				 rx_iq[23:12]  <= #1 rf_rxdata;
		 end
		default: 
		 begin
			 rx_iq <= #1 24'hF00100; 
		 end
	  endcase
	end
	reg   [1:0] reg_txstrobe; 
	reg [23:0] txdata;
	reg   txiqsel; 
	always @(posedge clock_tx)
	begin
		if( clearState) 
			txiqsel <= 1'h0;
		else
			txiqsel <= ~txiqsel;
	end
	assign rf_txiqsel = txiqsel & rf_ctrl[7];
	always @(posedge clock_dsp)
	begin
		if( clearState)
			begin
				reg_txstrobe[0] <= 1'b0;
				reg_txstrobe[1] <= 1'b0;
				txdata <= 24'h0;
			end
		else	
			begin
				reg_txstrobe[0] <= ~rf_txiqsel & ~reg_txstrobe[1] &~reg_txstrobe[0];
				reg_txstrobe[1] <= reg_txstrobe[0];		
				txdata <= (reg_txstrobe[0])  ? tx_iq : txdata;
			end
	end
	assign tx_strobe  = reg_txstrobe[1] & rf_ctrl[7];
	assign rf_txdata = ( rf_ctrl[3:2] == 2'b00) 
						   ? rf_rxdata 
							: ((rf_ctrl[3:2] == 2'b01) 
								? ((txiqsel)? txdata[11:00]  :  txdata[23:12] ) 
								: ((rf_ctrl[3:2] == 2'b10) 
									? ((txiqsel) ? 12'h100 : 12'hF00)
									: 12'h0)); 
	wire [7:0] rssi_q;
	wire [7:0] rssi_i;
	WcaRssi RssiInphase(
	  .clock(clock_dsp), .reset(clearState), .strobe(rx_strobe), .adc(rx_iq[11:00]), .rssi(rssi_i) );
	WcaRssi RssiQuadrature(
	  .clock(clock_dsp), .reset(clearState), .strobe(rx_strobe), .adc(rx_iq[23:12]), .rssi(rssi_q) );
	WcaReadWordReg #(RSSI_ADDR) RxRssiReadReg
	( .reset(reset), .clock(clock_dsp), .enableIn(rx_strobe), .in( {rssi_q, rssi_i} ), .rbusCtrl(rbusCtrl), .rbusData(rbusData) );
	wire  [11:0] dcOffset;
	WcaDcOffset DcOffsetRemove(
	  .clock(clock_rx),   .reset(clearState), .strobe(1'h1), .iqSel(rf_rxiqsel), .sig_in(rf_rxdata), .dcoffset( dcOffset), .sigout(rx_DciBiasRemoved));
endmodule 
