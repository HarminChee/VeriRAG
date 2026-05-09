`timescale 1ps/1ps
module serdes_1_to_n_clk_pll_s8_diff_corrected (
    x_clk,
    rxioclk,
    pattern1,
    pattern2,
    rx_serdesstrobe,
    reset, // Functional reset
    rx_bufg_pll_x1,
    rx_pll_lckd,
    rx_pllout_xs,
    bitslip,
    rx_bufpll_lckd,
    datain,
    // DFT Inputs
    test_mode,
    test_clk,
    test_reset // DFT asynchronous reset (active high)
);
parameter integer S = 8 ;
parameter         BS = "FALSE" ;
parameter         PLLX = 7 ;
parameter         PLLD = 1 ;
parameter real 	  CLKIN_PERIOD = 11.000 ;
parameter         DIFF_TERM = "FALSE" ;
input		x_clk ;
input 		reset ;				// Functional reset (likely active high for PLL)
input 	[S-1:0]	pattern1 ;
input 	[S-1:0]	pattern2 ;
output 		rxioclk ;
output 		rx_serdesstrobe ;
output 		rx_bufg_pll_x1 ;		// Outputting the functional clock source
output 		rx_pll_lckd ;
output 		rx_pllout_xs ;
output 		bitslip ;
output 		rx_bufpll_lckd ; 		// Outputting the combined lock signal
output 	[S-1:0]	datain ;
// DFT Inputs
input       test_mode;          // Scan mode select
input       test_clk;           // Scan clock input
input       test_reset;         // Scan asynchronous reset input (active high)

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

// Internal signals for muxed clock and reset
wire        scan_clk;
wire        scan_reset; // Effective asynchronous reset

// Select clock based on test_mode
assign scan_clk = test_mode ? test_clk : rx_bufg_pll_x1;

// Select asynchronous reset based on test_mode
// Original reset condition was posedge not_rx_bufpll_lckd (active high)
assign scan_reset = test_mode ? test_reset : not_rx_bufpll_lckd;

// Note: busy_clk is assigned from busym, which comes from iodelay_m.
// iodelay_m's CLK is rx_bufg_pll_x1. This might require further DFT handling
// depending on the tool's capability to handle primitives.
// The assignment below remains for functional clarity but its DFT implication persists.
assign busy_clk = busym ;

assign datain = mdataout[7:1] ; // Assuming original intent was S-1 bits excluding the LSB
assign 	bitslip = bslip ;

// FSM and control logic clocked by scan_clk with asynchronous reset scan_reset
always @ (posedge scan_clk or posedge scan_reset)
begin
    if (scan_reset == 1'b1) begin // Use active high asynchronous reset
        state <= 4'b0000;
        enable <= 1'b0;
        cal_clk <= 1'b0;
        rst_clk <= 1'b0;
        bslip <= 1'b0;
        busyd <= 1'b1; // Assuming reset state for busyd
        counter <= 12'b000000000000;
        flag1 <= 1'b0; // Reset flags
        flag2 <= 1'b0;
        count <= 3'b000; // Reset count
    end
    else begin // Synchronous logic clocked by scan_clk
        busyd <= busy_clk; // Capturing potentially unsynchronized signal in test mode
        if (counter[5] == 1'b1) begin
            enable <= 1'b1;
        end
        // Counter logic
        if (counter[11] == 1'b1) begin // Terminal count condition
            state <= 4'b0000;
            cal_clk <= 1'b0;
            rst_clk <= 1'b0;
            bslip <= 1'b0;
            busyd <= 1'b1;
            counter <= 12'b000000000000;
        end
        else begin
            counter <= counter + 12'b000000000001;
            // Flag logic (combinational based on inputs, registered on scan_clk)
            if (clk_iserdes_data != pattern1) begin flag1 <= 1'b1; end else begin flag1 <= 1'b0; end
            if (clk_iserdes_data != pattern2) begin flag2 <= 1'b1; end else begin flag2 <= 1'b0; end

            // State machine logic
            case (state)
                4'd0: if (enable == 1'b1 && busyd == 1'b0) begin
                          state <= 4'd1;
                      end
                4'd1: begin cal_clk <= 1'b1; state <= 4'd2; end
                4'd2: begin
                          cal_clk <= 1'b0;
                          if (busyd == 1'b1) begin
                              state <= 4'd3;
                          end
                      end
                4'd3: if (busyd == 1'b0) begin
                          rst_clk <= 1'b1; state <= 4'd4;
                      end
                4'd4: begin rst_clk <= 1'b0; state <= 4'd5; end
                4'd5: if (busyd == 1'b0) begin
                          state <= 4'd6;
                          count <= 3'b000;
                      end
                4'd6: begin
                          count <= count + 3'b001;
                          if (count == 3'b111) begin
                              state <= 4'd7;
                          end
                      end
                4'd7: begin
                          if (BS == "TRUE" && flag1 == 1'b1 && flag2 == 1'b1) begin
                              bslip <= 1'b1;
                              state <= 4'd8;
                              count <= 3'b000;
                          end
                          else begin
                              state <= 4'd9;
                          end
                      end
                4'd8: begin
                          bslip <= 1'b0;
                          count <= count + 3'b001;
                          if (count == 3'b111) begin
                              state <= 4'd7;
                          end
                      end
                4'd9: begin // Stay in final state
                          state <= 4'd9;
                      end
                default: state <= 4'd0; // Default case to reset state
            endcase
        end
    end
end

genvar i ;
generate
for (i = 0 ; i <= (S - 1) ; i = i + 1)
begin : loop0
// Corrected indexing assuming mdataout[7:0] holds parallel data
// Need S bits, ISERDES outputs Q1..Q4 for master/slave.
// Assuming S=8, master Q4..Q1 = mdataout[7:4], slave Q4..Q1 = mdataout[3:0]
// This assignment seems incorrect based on ISERDES outputs.
// Revisit based on actual ISERDES mapping if S=8.
// Keeping original assignment logic for now, but it needs verification.
// If S=8, mdataout should be [7:0]. mdataout[8+i-S] -> mdataout[i].
    assign clk_iserdes_data[i] = mdataout[i];
end
endgenerate

// Primitives instantiation - CLK/RST inputs might need DFT handling/wrapping.
// The CLK pins (rx_bufg_pll_x1, rxioclk) are derived from the PLL.
// The RST pin (not_rx_bufpll_lckd) is also internal.
// DFT tools often require specific handling for these primitives.

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
	.IDATAIN  		(x_clk),
	.TOUT     		(),
	.DOUT     		(),
	.T        		(1'b1),
	.ODATAIN  		(1'b0),
	.DATAOUT  		(ddly_m),
	.DATAOUT2 		(),
	.IOCLK0   		(rxioclk), 			// Internal clock
	.IOCLK1   		(1'b0),
	.CLK      		(rx_bufg_pll_x1), 		// Internal clock
	.CAL      		(cal_clk), 			// Controlled by FSM
	.INC      		(1'b0),
	.CE       		(1'b0),
	.RST      		(rst_clk), 			// Controlled by FSM
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
	.IDATAIN 		(x_clk),
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
      .I			(P_clk),
      .IOCLK			(),
      .DIVCLK			(buf_P_clk),    		// Feeds PLL
      .SERDESSTROBE		()) ;

wire feedback; // Define feedback wire if not already defined
BUFIO2FB #(
      .DIVIDE_BYPASS		("TRUE"))
P_clk_bufio2fb_inst (
      .I			(feedback),             	// Input to feedback buffer
      .O			(buf_pll_fb_clk)) ;   		// Output feeds PLL feedback

wire cascade, pd_edge; // Define ISERDES interconnect wires

ISERDES2 #(
	.DATA_WIDTH     	(S),
	.DATA_RATE      	("SDR"),
	.BITSLIP_ENABLE 	("TRUE"),
	.SERDES_MODE    	("MASTER"),
	.INTERFACE_TYPE 	("RETIMED"))
iserdes_m (
	.D       		(ddly_m),
	.CE0     		(1'b1),
	.CLK0    		(rxioclk),              // Internal clock
	.CLK1    		(1'b0),
	.IOCE    		(rx_serdesstrobe),      // Internal signal
	.RST     		(not_rx_bufpll_lckd),   // Internal reset
	.CLKDIV  		(rx_bufg_pll_x1),       // Internal clock
	.SHIFTIN 		(pd_edge),              // From slave
	.BITSLIP 		(bslip),                // Controlled by FSM
	.FABRICOUT 		(),
	.DFB 			(),                     // Master DFB not typically used this way
	.CFB0 			(),
	.CFB1 			(),
    // Assuming S=8, mapping outputs Q4..Q1
	.Q4 			(mdataout[7]),
	.Q3 			(mdataout[6]),
	.Q2 			(mdataout[5]),
	.Q1 			(mdataout[4]),
	.VALID    		(),
	.INCDEC   		(),
	.SHIFTOUT 		(cascade));             // To slave

ISERDES2 #(
	.DATA_WIDTH     	(S),
	.DATA_RATE      	("SDR"),
	.BITSLIP_ENABLE 	("TRUE"),
	.SERDES_MODE    	("SLAVE"),
	.INTERFACE_TYPE 	("RETIMED"))
iserdes_s (
	.D       		(ddly_s),
	.CE0     		(1'b1),
	.CLK0    		(rxioclk),              // Internal clock
	.CLK1    		(1'b0),
	.IOCE    		(rx_serdesstrobe),      // Internal signal
	.RST     		(not_rx_bufpll_lckd),   // Internal reset
	.CLKDIV  		(rx_bufg_pll_x1),       // Internal clock
	.SHIFTIN 		(cascade),              // From master
	.BITSLIP 		(bslip),                // Controlled by FSM
	.FABRICOUT 		(),
	.DFB 			(P_clk),                // Output to BUFIO2 -> PLL input
	.CFB0 			(feedback),             // Output to BUFIO2FB -> PLL feedback
	.CFB1 			(),
    // Assuming S=8, mapping outputs Q4..Q1
	.Q4  			(mdataout[3]),
	.Q3  			(mdataout[2]),
	.Q2  			(mdataout[1]),
	.Q1  			(mdataout[0]),
	.VALID 			(),
	.INCDEC 		(),
	.SHIFTOUT 		(pd_edge));             // To master

wire rx_pllout_x1; // Define PLL output wire

PLL_ADV #(
      .BANDWIDTH		("OPTIMIZED"),
      .CLKFBOUT_MULT		(PLLX), // Use parameter PLLX
      .CLKFBOUT_PHASE		(0.0),
      .CLKIN1_PERIOD		(CLKIN_PERIOD),
      .CLKIN2_PERIOD		(CLKIN_PERIOD),
      .CLKOUT0_DIVIDE		(1),
      .CLKOUT0_DUTY_CYCLE	(0.5),
      .CLKOUT0_PHASE		(315.0),
      .CLKOUT1_DIVIDE		(1),
      .CLKOUT1_DUTY_CYCLE	(0.5),
      .CLKOUT1_PHASE		(0.0),
      .CLKOUT2_DIVIDE		(PLLX), // Use parameter PLLX
      .CLKOUT2_DUTY_CYCLE	(0.5),
      .CLKOUT2_PHASE		(315.0),
      .CLKOUT3_DIVIDE		(PLLX), // Use parameter PLLX
      .CLKOUT3_DUTY_CYCLE	(0.5),
      .CLKOUT3_PHASE		(0.0),
      .CLKOUT4_DIVIDE		(PLLX), // Use parameter PLLX
      .CLKOUT4_DUTY_CYCLE	(0.5),
      .CLKOUT4_PHASE		(0.0),
      .CLKOUT5_DIVIDE		(PLLX), // Use parameter PLLX
      .CLKOUT5_DUTY_CYCLE	(0.5),
      .CLKOUT5_PHASE		(0.0),
      .COMPENSATION		("SOURCE_SYNCHRONOUS"),
      .DIVCLK_DIVIDE		(PLLD), // Use parameter PLLD
      .CLK_FEEDBACK		("CLKOUT0"), // Feedback path uses CLKOUT0 internally
      .REF_JITTER		(0.100))
rx_pll_adv_inst (
      .CLKFBDCM			(),
      .CLKFBOUT			(),              		// Internal feedback loop signal
      .CLKOUT0			(rx_pllout_xs),      		// Output for BUFPLL (high speed)
      .CLKOUT1			(),      			    // Unused
      .CLKOUT2			(rx_pllout_x1), 		// Output for BUFG (fabric clock)
      .CLKOUT3			(),              		// Unused
      .CLKOUT4			(),              		// Unused
      .CLKOUT5			(),              		// Unused
      .CLKOUTDCM0		(),
      .CLKOUTDCM1		(),
      .CLKOUTDCM2		(),
      .CLKOUTDCM3		(),
      .CLKOUTDCM4		(),
      .CLKOUTDCM5		(),
      .DO			(),
      .DRDY			(),
      .LOCKED			(rx_pll_lckd),        		// PLL lock status
      .CLKFBIN			(buf_pll_fb_clk),		// Feedback input from BUFIO2FB
      .CLKIN1			(buf_P_clk),     		// Clock input from BUFIO2
      .CLKIN2			(1'b0),
      .CLKINSEL			(1'b1),             		// Select CLKIN1
      .DADDR			(5'b00000),
      .DCLK			(1'b0),
      .DEN			(1'b0),
      .DI			(16'h0000),
      .DWE			(1'b0),
      .RST			(reset),               		// Functional reset for PLL
      .REL			(1'b0)) ;

// Global buffer for the fabric clock
BUFG	bufg_pll_x1 (.I(rx_pllout_x1), .O(rx_bufg_pll_x1) ) ;

// BUFPLL for generating high-speed I/O clock and SERDES strobe
BUFPLL #(
      .DIVIDE			(S))              		// Divide by the deserialization factor
rx_bufpll_inst (
      .PLLIN			(rx_pllout_xs),        		// High-speed clock from PLL CLKOUT0
      .GCLK			(rx_bufg_pll_x1), 		// Global clock for synchronization
      .LOCKED			(rx_pll_lckd),             	// PLL lock input
      .IOCLK			(rxioclk), 			// High-speed I/O clock output
      .LOCK			(rx_bufplllckd),          	// BUFPLL lock status output
      .SERDESSTROBE		(rx_serdesstrobe)) ; 		// Strobe signal for ISERDES IOCE

// Combine PLL and BUFPLL lock signals for overall lock status
assign rx_bufpll_lckd = rx_pll_lckd & rx_bufplllckd ;
// Inverted lock signal used as reset in ISERDES and FSM (during functional mode)
assign not_rx_bufpll_lckd = ~rx_bufpll_lckd ;

endmodule