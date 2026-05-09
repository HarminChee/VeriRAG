`timescale 1ns / 1ps
`default_nettype none

module ethernet2BlockMem #(
	parameter INMEM_USER_BYTE_WIDTH = 1,
	parameter OUTMEM_USER_BYTE_WIDTH = 1,
	parameter INMEM_USER_ADDRESS_WIDTH = 17,
	parameter OUTMEM_USER_ADDRESS_WIDTH = 13,
	parameter INMEM_USER_REGISTER = 1,
	parameter MAC_ADDRESS = 48'hAAAAAAAAAAAA
)(
	input		wire 			refClock,																		
	input		wire 			clockLock,     																
	input		wire 			hardResetLow,    																
	input		wire 			ethClock,																		
	output	wire [7:0] 	GMII_TXD,																		
	output	wire 			GMII_TX_EN,																		
	output	wire 			GMII_TX_ER,																		
	output	wire 			GMII_GTX_CLK,																	
	input		wire [7:0] 	GMII_RXD,																		
	input		wire 			GMII_RX_DV,																		
	input		wire 			GMII_RX_ER,																		
	input		wire 			GMII_RX_CLK,																	
	output	wire 			GMII_RESET_B,																	
	input		wire 			sysACE_CLK,																		
	output	wire [6:0]	sysACE_MPADD,																	
	inout		wire [15:0]	sysACE_MPDATA,																	
	output	wire 			sysACE_MPCE,																	
	output	wire 			sysACE_MPWE,																	
	output	wire 			sysACE_MPOE,																	
	input 	wire 			userInterfaceClk,																
	output 	wire 			userLogicReset,																
	output 	wire 			userRunValue,																	
	input 	wire 			userRunClear,																	
	input 	wire 			register32CmdReq,																
	output	wire 			register32CmdAck,																
	input		wire [31:0] register32WriteData,															
	input 	wire [7:0] 	register32Address,															
	input 	wire 			register32WriteEn,															
	output 	wire 			register32ReadDataValid,													
	output 	wire [31:0] register32ReadData,															
	input 	wire 														inputMemoryReadReq,				
	output	wire 														inputMemoryReadAck,				
	input		wire [(INMEM_USER_ADDRESS_WIDTH - 1):0] 		inputMemoryReadAdd,				
	output 	wire 														inputMemoryReadDataValid,		
	output	wire [((INMEM_USER_BYTE_WIDTH * 8) - 1):0] 	inputMemoryReadData,				
	input 	wire 														outputMemoryWriteReq,			
	output 	wire 														outputMemoryWriteAck,			
	input		wire [(OUTMEM_USER_ADDRESS_WIDTH - 1):0] 		outputMemoryWriteAdd,			
	input		wire [((OUTMEM_USER_BYTE_WIDTH * 8) - 1):0] 	outputMemoryWriteData,			
	input 	wire [(OUTMEM_USER_BYTE_WIDTH - 1):0]			outputMemoryWriteByteMask		
);
	wire				hardResetClockLockLow;
	wire				hardResetClockLockLong;
	reg [12:0] 	delayCtrl0Reset;
	wire 				gmii_rx_clk_delay;
    wire                idelayctrl_rdy; // Declare wire for RDY

	assign			hardResetClockLockLow = hardResetLow & clockLock; // Use bitwise AND

	always @(posedge refClock, negedge hardResetClockLockLow) begin
	  if (hardResetClockLockLow == 1'b0) begin
			delayCtrl0Reset <= 13'b1111111111111;
	  end
	  else begin
			delayCtrl0Reset <= {delayCtrl0Reset[11:0], 1'b0};
	  end
	end

	assign hardResetClockLockLong = ~delayCtrl0Reset[12]; // Correct reset polarity assumption (active low typical)

	IDELAYCTRL delayCtrl0(
	  .RDY(idelayctrl_rdy), // Connect RDY port
	  .REFCLK(refClock),
	  .RST(~hardResetClockLockLow) // Reset IDELAYCTRL when hardResetLow or clockLock is low
	);

	// Assuming IDELAY is for input clock conditioning, ensure reset logic is correct
	// Usually IDELAY reset is tied to the same logic reset as the fabric
	IDELAYE2 #(
        .IDELAY_TYPE("FIXED"),       // Use IDELAYE2 for 7-series/newer, IDELAY for older
        .IDELAY_VALUE(0),
        .REFCLK_FREQUENCY(200.0), // Example: Specify reference clock frequency if needed
        .SIGNAL_PATTERN("CLOCK")  // Specify if delaying clock or data
    ) delayRXClk (
        .DATAIN(1'b0), // Data input not used when delaying clock typically
        .IDATAIN(GMII_RX_CLK), // Input clock connects here
        .C(userInterfaceClk), // Control clock (can be userInterfaceClk or another stable clock)
        .CE(1'b0), // Clock Enable for delay adjustment (tied low for fixed)
        .INC(1'b0), // Increment/decrement control (tied low for fixed)
        .LD(1'b0), // Load new delay value (tied low for fixed)
        .CINVCTRL(1'b0), // Clock inversion control
        .CNTVALUEIN(5'b0), // Input delay value (not used for fixed)
        .LDPIPEEN(1'b0), // Load pipeline enable
        .REGRST(1'b0), // Register reset (usually tied low)
        .DATAOUT(), // Data output (not used)
        .CNTVALUEOUT(), // Output delay value
        .DOUT(gmii_rx_clk_delay) // Delayed clock output
    );

	assign GMII_RESET_B = hardResetClockLockLow; // Corrected reset assignment if active low needed

	// Internal Locallink Signals
	wire 	[7:0] 	tx_ll_data_out;
	wire       		tx_ll_sof_out_n; // Use _n suffix consistent with emac primitive
	wire        	tx_ll_eof_out_n; // Use _n suffix consistent with emac primitive
	wire				tx_ll_src_rdy_out_n; // Use _n suffix consistent with emac primitive
	wire				tx_ll_dst_rdy_in_n; // Use _n suffix consistent with emac primitive

	wire [7:0] 	rx_ll_data_in;
	wire   	     	rx_ll_sof_in_n; // Use _n suffix consistent with emac primitive
	wire        	rx_ll_eof_in_n; // Use _n suffix consistent with emac primitive
	wire        	rx_ll_src_rdy_in_n; // Use _n suffix consistent with emac primitive
	wire        	rx_ll_dst_rdy_out_n; // Use _n suffix consistent with emac primitive

    // Connect controller signals to intermediate locallink signals (handle potential inversion)
    // Assuming controller uses active high and emac uses active low (_n)
    assign rx_ll_dst_rdy_out = ~rx_ll_dst_rdy_out_n;
    assign tx_ll_dst_rdy_in_n = ~tx_ll_dst_rdy_in;

    assign rx_ll_data_in = rx_ll_data_in; // Pass through data
    assign rx_ll_sof_in = ~rx_ll_sof_in_n;
    assign rx_ll_eof_in = ~rx_ll_eof_in_n;
    assign rx_ll_src_rdy_in = ~rx_ll_src_rdy_in_n;

    assign tx_ll_data_out = tx_ll_data_out; // Pass through data
    assign tx_ll_sof_out_n = ~tx_ll_sof_out;
    assign tx_ll_eof_out_n = ~tx_ll_eof_out;
    assign tx_ll_src_rdy_out_n = ~tx_ll_src_rdy_out;


	// Instantiate the EMAC core - Assuming 'emac_single_locallink' is the correct module name
	// Port names might differ based on the actual core generator (e.g., Xilinx TEMAC)
	// Check the generated core's documentation for exact port names and polarity.
	emac_single_locallink emac_ll( // Check this module name and port names
 		.TX_CLK_OUT                          (),				// Unused output clock
		.TX_CLK_0                            (ethClock),      // Transmit Clock Input
		.RX_LL_CLOCK_0                       (ethClock),      // Locallink Receive Clock
		.RX_LL_RESET_0                       (hardResetClockLockLong), // Locallink Receive Reset
		.RX_LL_DATA_0                        (rx_ll_data_in),
		.RX_LL_SOF_N_0                       (rx_ll_sof_in_n), // Note _N suffix (active low)
		.RX_LL_EOF_N_0                       (rx_ll_eof_in_n), // Note _N suffix (active low)
		.RX_LL_SRC_RDY_N_0                   (rx_ll_src_rdy_in_n),// Note _N suffix (active low)
		.RX_LL_DST_RDY_N_0                   (rx_ll_dst_rdy_out_n),// Note _N suffix (active low)
		.RX_LL_FIFO_STATUS_0                 (),              // Unused FIFO status
		.TX_LL_CLOCK_0                       (ethClock),      // Locallink Transmit Clock
		.TX_LL_RESET_0                       (hardResetClockLockLong), // Locallink Transmit Reset
		.TX_LL_DATA_0                        (tx_ll_data_out),
		.TX_LL_SOF_N_0                       (tx_ll_sof_out_n), // Note _N suffix (active low)
		.TX_LL_EOF_N_0                       (tx_ll_eof_out_n), // Note _N suffix (active low)
		.TX_LL_SRC_RDY_N_0                   (tx_ll_src_rdy_out_n),// Note _N suffix (active low)
		.TX_LL_DST_RDY_N_0                   (tx_ll_dst_rdy_in_n),// Note _N suffix (active low)
		.CLIENTEMAC0TXIFGDELAY               (8'd0),			// Inter-frame gap delay
		.CLIENTEMAC0PAUSEREQ                 (1'b0),			// Pause request (driven low)
		.CLIENTEMAC0PAUSEVAL                 (16'd0),			// Pause value (driven low)
		.GTX_CLK_0                           (ethClock),      // Clock for GMII TX - confirm source
		.GMII_TXD_0                          (GMII_TXD),
		.GMII_TX_EN_0                        (GMII_TX_EN),
		.GMII_TX_ER_0                        (GMII_TX_ER),
		.GMII_TX_CLK_0                       (GMII_GTX_CLK),	// Output GTX Clock from PHY
		.GMII_RXD_0                          (GMII_RXD),
		.GMII_RX_DV_0                        (GMII_RX_DV),
		.GMII_RX_ER_0                        (GMII_RX_ER),
		.GMII_RX_CLK_0                       (gmii_rx_clk_delay), // Use delayed RX clock
		.RESET                               (hardResetClockLockLong) // Global Reset for EMAC core
	);

	// Instantiate the Ethernet Controller Logic
	ethernetController #(
		.INMEM_USER_BYTE_WIDTH(INMEM_USER_BYTE_WIDTH),
		.OUTMEM_USER_BYTE_WIDTH(OUTMEM_USER_BYTE_WIDTH),
		.INMEM_USER_ADDRESS_WIDTH(INMEM_USER_ADDRESS_WIDTH),
		.OUTMEM_USER_ADDRESS_WIDTH(OUTMEM_USER_ADDRESS_WIDTH),
		.INMEM_USER_REGISTER(INMEM_USER_REGISTER),
		.MAC_ADDRESS(MAC_ADDRESS)
	)	EC(
		.controllerSideClock(ethClock),									// Clock for controller logic
		.reset(hardResetClockLockLong),									// Reset for controller logic
		.rx_ll_data_in(rx_ll_data_in),       						// Connect to intermediate wires
		.rx_ll_sof_in(rx_ll_sof_in),     								// Connect to intermediate wires (active high)
		.rx_ll_eof_in(rx_ll_eof_in),     								// Connect to intermediate wires (active high)
		.rx_ll_src_rdy_in(rx_ll_src_rdy_in),  						// Connect to intermediate wires (active high)
		.rx_ll_dst_rdy_out(rx_ll_dst_rdy_out), 						// Connect to intermediate wires (active high)
		.tx_ll_data_out(tx_ll_data_out),      						// Connect to intermediate wires
		.tx_ll_sof_out(tx_ll_sof_out), 			   					// Connect to intermediate wires (active high)
		.tx_ll_eof_out(tx_ll_eof_out),     							// Connect to intermediate wires (active high)
		.tx_ll_src_rdy_out(tx_ll_src_rdy_out), 						// Connect to intermediate wires (active high)
		.tx_ll_dst_rdy_in(tx_ll_dst_rdy_in),		  					// Connect to intermediate wires (active high)
		.sysACE_CLK(sysACE_CLK),											// Pass through System ACE signals
		.sysACE_MPADD(sysACE_MPADD),
		.sysACE_MPDATA(sysACE_MPDATA),
		.sysACE_MPCE(sysACE_MPCE),
		.sysACE_MPWE(sysACE_MPWE),
		.sysACE_MPOE(sysACE_MPOE),
		.userInterfaceClock(userInterfaceClk),						// User interface clock
		.userLogicReset(userLogicReset),								// User logic reset output
		.userRunValue(userRunValue),										// User run value output
		.userRunClear(userRunClear),										// User run clear input
		.register32CmdReq(register32CmdReq),							// Pass through register interface
		.register32CmdAck(register32CmdAck),
		.register32WriteData(register32WriteData),
		.register32Address(register32Address),
		.register32WriteEn(register32WriteEn),
		.register32ReadDataValid(register32ReadDataValid),
		.register32ReadData(register32ReadData),
		.inputMemoryReadReq(inputMemoryReadReq),						// Pass through memory interface
		.inputMemoryReadAck(inputMemoryReadAck),
		.inputMemoryReadAdd(inputMemoryReadAdd),
		.inputMemoryReadDataValid(inputMemoryReadDataValid),
		.inputMemoryReadData(inputMemoryReadData),
		.outputMemoryWriteReq(outputMemoryWriteReq),
		.outputMemoryWriteAck(outputMemoryWriteAck),
		.outputMemoryWriteAdd(outputMemoryWriteAdd),
		.outputMemoryWriteData(outputMemoryWriteData),
		.outputMemoryWriteByteMask(outputMemoryWriteByteMask)
	);

endmodule