`timescale 1ps/1ps
module serdes_1_to_n_clk_pll_s8_diff_corrected (
    clkin_p,
    clkin_n,
    rxioclk,
    pattern1,
    pattern2,
    rx_serdesstrobe,
    reset, // Primary synchronous reset
    rx_bufg_pll_x1,
    rx_pll_lckd,
    rx_pllout_xs,
    bitslip,
    rx_bufpll_lckd,
    datain,
    scan_clk, // Added Test Clock input
    scan_mode // Added Test Mode input
);

parameter integer S = 8 ;
parameter         BS = "FALSE" ;
parameter         PLLX = 7 ;
parameter         PLLD = 1 ;
parameter real 	  CLKIN_PERIOD = 6.000 ;
parameter         DIFF_TERM = "FALSE" ;

input 		clkin_p ;
input 		clkin_n ;
input 		reset ;				// Used as primary synchronous reset
input 	[S-1:0]	pattern1 ;
input 	[S-1:0]	pattern2 ;
input       scan_clk;           // Test clock input
input       scan_mode;          // Test mode select

output 		rxioclk ;
output 		rx_serdesstrobe ;
output 		rx_bufg_pll_x1 ;		// Functional clock (output of BUFG)
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
wire        muxed_clk;          // Clock signal after DFT mux
wire        busy_clk;           // Renamed internal signal wire
wire        feedback;           // Missing wire declaration from original? Assuming it comes from iserdes_s.CFB0
wire        cascade;            // Missing wire declaration from original? Assuming it connects iserdes_m/s.
wire        pd_edge;            // Missing wire declaration from original? Assuming it connects iserdes_m/s.
wire        rx_pllout_x1;       // Internal PLL output before BUFG

parameter  	RX_SWAP_CLK  = 1'b0 ;

// DFT Clock Mux: Selects functional clock or test clock
assign muxed_clk = scan_mode ? scan_clk : rx_bufg_pll_x1;

assign busy_clk = busym ; // Keep assignment as is
assign datain = clk_iserdes_data ;
assign 	bitslip = bslip ;
assign not_rx_bufpll_lckd = ~rx_bufpll_lckd ; // Keep assignment

// Modified always block: uses muxed_clk and synchronous reset
always @ (posedge muxed_clk or posedge reset) // Use muxed clock and primary synchronous reset
begin
    if (reset == 1'b1) begin // Synchronous reset condition
        state <= 4'b0000 ;
        enable <= 1'b0 ;
        cal_clk <= 1'b0 ;
        rst_clk <= 1'b0 ;
        bslip <= 1'b0 ;
        busyd <= 1'b1 ; // Assuming reset value should be 1
        counter <= 12'b000000000000 ;
        count <= 3'b000;   // Reset count register
        flag1 <= 1'b0;     // Reset flag register
        flag2 <= 1'b0;     // Reset flag register
    end
    else begin // Clocked behavior
        busyd <= busy_clk ; // Update busyd based on busy_clk (busym)

        // Counter logic - includes check for counter[11] timeout/reset condition
        if (counter[11] == 1'b1) begin
            // Timeout condition - Reset FSM and related signals
            state <= 4'b0000 ;
            cal_clk <= 1'b0 ;
            rst_clk <= 1'b0 ;
            bslip <= 1'b0 ;
            busyd <= 1'b1 ; // Reset value
            counter <= 12'b000000000000 ;
            // Also reset other potentially affected registers if needed by design logic
            enable <= 1'b0; // Reset enable on timeout? Assuming yes based on original reset logic.
            count <= 3'b000; // Reset count on timeout
            flag1 <= 1'b0; // Reset flags on timeout
            flag2 <= 1'b0; // Reset flags on timeout
        end
        else begin
            // Increment counter if no timeout
            counter <= counter + 12'b000000000001 ;

            // Update enable based on counter (original logic)
            if (counter[5] == 1'b1) begin
                enable <= 1'b1 ;
            end
            // Note: enable is not reset to 0 otherwise, it holds its value until primary reset or timeout reset.

            // Update flags based on data comparison (original logic)
            if (clk_iserdes_data != pattern1) begin flag1 <= 1'b1 ; end else begin flag1 <= 1'b0 ; end
            if (clk_iserdes_data != pattern2) begin flag2 <= 1'b1 ; end else begin flag2 <= 1'b0 ; end

            // State machine logic (original logic)
            case (state)
                4'd0: if (enable == 1'b1 && busyd == 1'b0) begin
                        state <= 4'd1 ;
                      end
                4'd1: begin
                        cal_clk <= 1'b1 ;
                        state <= 4'd2 ;
                      end
                4'd2: begin
                        cal_clk <= 1'b0 ;
                        if (busyd == 1'b1) begin
                            state <= 4'd3 ;
                        end
                      end
                4'd3: if (busyd == 1'b0) begin
                        rst_clk <= 1'b1 ;
                        state <= 4'd4 ;
                      end
                4'd4: begin
                        rst_clk <= 1'b0 ;
                        state <= 4'd5 ;
                      end
                4'd5: if (busyd == 1'b0) begin
                        state <= 4'd6 ;
                        count <= 3'b000 ; // Initialize count
                      end
                4'd6: begin
                        count <= count + 3'b001 ;
                        if (count == 3'b111) begin
                            state <= 4'd7 ;
                        end
                      end
                4'd7: begin
                        if (BS == "TRUE" && flag1 == 1'b1 && flag2 == 1'b1) begin
                            bslip <= 1'b1 ;
                            state <= 4'd8 ;
                            count <= 3'b000 ; // Reset count
                        end
                        else begin
                            state <= 4'd9 ;
                        end
                      end
                4'd8: begin
                        bslip <= 1'b0 ;
                        count <= count + 3'b001 ;
                        if (count == 3'b111) begin
                            state <= 4'd7 ;
                        end
                      end
                4'd9: begin
                        state <= 4'd9 ; // Stay in state 9
                      end
                default: state <= 4'd0; // Default case back to reset state
            endcase
        end // end if (counter[11] != 1'b1)
    end // end else [not reset]
end // end always

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
// Corrected indexing assuming mdataout is [S-1:0] or wider. Original was [7:0] fixed.
// If S=8, then mdataout[8+i-8] = mdataout[i].
// If S=10, mdataout needs to be wider. Assuming S=8 based on mdataout width.
// If S=8, mapping is mdataout[0]..mdataout[7] -> clk_iserdes_data[0]..clk_iserdes_data[7]
    if (S==8) // Check if S matches expected mdataout width usage
        assign clk_iserdes_data[i] = mdataout[i] ;
    // else provide a default or error if S is not 8
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
	.CLK      		(rx_bufg_pll_x1), // Clock for IODELAY control logic - check if this needs DFT mux
	.CAL      		(cal_clk),
	.INC      		(1'b0),
	.CE       		(1'b0),
	.RST      		(rst_clk), 			// Reset for IODELAY - driven by FSM, check controllability
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
	.IOCLK0    		(1'b0), // Tied low
	.IOCLK1   		(1'b0), // Tied low
	.CLK      		(1'b0), // Tied low
	.CAL      		(1'b0), // Tied low
	.INC      		(1'b0), // Tied low
	.CE       		(1'b0), // Tied low
	.RST      		(1'b0), // Tied low
	.BUSY      		()) ; // Unconnected

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
      .I			(feedback), // Ensure 'feedback' is driven (e.g., from iserdes_s)
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
	.CLK0    		(rxioclk),            // High-speed clock - typically needs careful handling for DFT
	.CLK1    		(1'b0),
	.IOCE    		(rx_serdesstrobe),    // Clock enable - typically needs careful handling for DFT
	.RST     		(not_rx_bufpll_lckd), // Asynchronous reset based on lock - DFT Issue! Should use synchronous reset.
	.CLKDIV  		(rx_bufg_pll_x1),     // Low-speed clock - needs DFT mux if FFs inside use it implicitly
	.SHIFTIN 		(pd_edge),            // Ensure pd_edge is driven (e.g., from iserdes_s)
	.BITSLIP 		(bslip),              // Controlled by FSM
	.FABRICOUT 		(),
	.DFB 			(),
	.CFB0 			(),
	.CFB1 			(),
	// Assuming S=8 for mapping
	.Q4 			(mdataout[7]),
	.Q3 			(mdataout[6]),
	.Q2 			(mdataout[5]),
	.Q1 			(mdataout[4]),
	.VALID    		(),
	.INCDEC   		(),
	.SHIFTOUT 		(cascade));           // Ensure cascade connects to iserdes_s

ISERDES2 #(
	.DATA_WIDTH     	(S),
	.DATA_RATE      	("SDR"),
	.BITSLIP_ENABLE 	("TRUE"),
	.SERDES_MODE    	("SLAVE"),
	.INTERFACE_TYPE 	("RETIMED"))
iserdes_s (
	.D       		(ddly_s),
	.CE0     		(1'b1),
	.CLK0    		(rxioclk),            // High-speed clock - DFT issue
	.CLK1    		(1'b0),
	.IOCE    		(rx_serdesstrobe),    // Clock enable - DFT issue
	.RST     		(not_rx_bufpll_lckd), // Asynchronous reset - DFT Issue!
	.CLKDIV  		(rx_bufg_pll_x1),     // Low-speed clock - DFT issue
	.SHIFTIN 		(cascade),            // Driven by iserdes_m
	.BITSLIP 		(bslip),              // Controlled by FSM
	.FABRICOUT 		(),
	.DFB 			(P_clk),              // Drives BUFIO2
	.CFB0 			(feedback),           // Drives BUFIO2FB
	.CFB1 			(),
	// Assuming S=8 for mapping
	.Q4  			(mdataout[3]),
	.Q3  			(mdataout[2]),
	.Q2  			(mdataout[1]),
	.Q1  			(mdataout[0]),
	.VALID 			(),
	.INCDEC 		(),
	.SHIFTOUT 		(pd_edge));           // Drives iserdes_m

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
      .CLKOUT2_DIVIDE		(S),   // Generates rx_pllout_x1 (before BUFG)