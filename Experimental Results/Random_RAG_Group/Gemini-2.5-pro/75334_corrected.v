`timescale 1ns / 1ps
`timescale 1ns / 1ps
module clkgen(
	input test_mode_i, // Added for DFT
	input sys_clk_i,
	input sys_rst_i,
	output wb_clk_o,
	output wb_clk2x_o,
	output wb_rst_o
);
// Existing IBUFG for input clock buffering
IBUFG sys_clk_in_ibufg(
	.I(sys_clk_i),
	.O(sys_clk_ibufg)
);

// Wires for MMCM connections and outputs
wire [15:0] do_unused;
wire drdy_unused;
wire psdone_unused;
wire clkfbout;
wire clkfbout_buf;
wire clkfboutb_unused;
wire clkout0; // Internal wire for wb_clk_o source
wire clkout1; // Internal wire for wb_clk2x_o source
wire clkout0b_unused;
wire clkout1b_unused;
wire clkout2_unused;
wire clkout2b_unused;
wire clkout3_unused;
wire clkout3b_unused;
wire clkout4_unused;
wire clkout5_unused;
wire clkout6_unused;
wire clkfbstopped_unused;
wire clkinstopped_unused;
wire LOCKED; // Declare LOCKED wire from MMCM

// MMCM instance for clock generation
MMCME2_ADV #(
	.BANDWIDTH("OPTIMIZED"),
	.CLKOUT4_CASCADE("FALSE"),
	.COMPENSATION("ZHOLD"),
	.STARTUP_WAIT("FALSE"),
	.DIVCLK_DIVIDE(1),
	.CLKFBOUT_MULT_F(10.000),
	.CLKFBOUT_PHASE(0.000),
	.CLKFBOUT_USE_FINE_PS ("FALSE"),
	.CLKOUT0_DIVIDE_F(20.000),
	.CLKOUT0_PHASE(0.000),
	.CLKOUT0_DUTY_CYCLE(0.500),
	.CLKOUT0_USE_FINE_PS("FALSE"),
	.CLKOUT1_DIVIDE(10),
	.CLKOUT1_PHASE(0.000),
	.CLKOUT1_DUTY_CYCLE(0.500),
	.CLKOUT1_USE_FINE_PS("FALSE"),
	.CLKIN1_PERIOD(10.000),
	.REF_JITTER1(0.010)
) mmcm_adv_inst(
	.CLKFBOUT(clkfbout),
	.CLKFBOUTB(clkfboutb_unused),
	.CLKOUT0(clkout0), // Connect internal wire
	.CLKOUT0B(clkout0b_unused),
	.CLKOUT1(clkout1), // Connect internal wire
	.CLKOUT1B(clkout1b_unused),
	.CLKOUT2(clkout2_unused),
	.CLKOUT2B(clkout2b_unused),
	.CLKOUT3(clkout3_unused),
	.CLKOUT3B(clkout3b_unused),
	.CLKOUT4(clkout4_unused),
	.CLKOUT5(clkout5_unused),
	.CLKOUT6(clkout6_unused),
	.CLKFBIN(clkfbout_buf),
	.CLKIN1(sys_clk_ibufg),
	.CLKIN2(1'b0),
	.CLKINSEL(1'b1),
	.DADDR(7'h0),
	.DCLK(1'b0),
	.DEN(1'b0),
	.DI(16'h0),
	.DO(do_unused),
	.DRDY(drdy_unused),
	.DWE(1'b0),
	.PSCLK(1'b0),
	.PSEN(1'b0),
	.PSINCDEC(1'b0),
	.PSDONE(psdone_unused),
	.LOCKED(LOCKED), // Connect to wire
	.CLKINSTOPPED(clkinstopped_unused),
	.CLKFBSTOPPED(clkfbstopped_unused),
	.PWRDWN(1'b0),
	.RST(sys_rst_i) // MMCM reset is primary reset
);

// BUFG for feedback clock
BUFG clkf_buf(
	.O(clkfbout_buf),
	.I(clkfbout)
);

// Internal wires for generated clocks before final output BUFGs
wire wb_clk_o_internal;
wire wb_clk2x_o_internal;

// BUFG for wb_clk_o output
BUFG wb_clk_buf(
	.O(wb_clk_o_internal), // Output to internal wire
	.I(clkout0)
);
assign wb_clk_o = wb_clk_o_internal; // Assign to output port

// BUFG for wb_clk2x_o output
BUFG wb_clk2x_buf(
	.O(wb_clk2x_o_internal), // Output to internal wire
	.I(clkout1)
);
assign wb_clk2x_o = wb_clk2x_o_internal; // Assign to output port

// DFT Clock Mux: Selects primary clock (sys_clk_i) in test mode, functional clock otherwise
wire dft_clk;
assign dft_clk = test_mode_i ? sys_clk_i : wb_clk_o_internal;

// Reset synchronizer register
reg [15:0] wb_rst_shr;

// DFT Rule CLKNPI Fix: Use the muxed clock 'dft_clk' for the synchronizer flip-flop.
// DFT Rule ACNCPI Check: Asynchronous reset 'sys_rst_i' is a primary input, which is compliant.
always @(posedge dft_clk or posedge sys_rst_i)
begin
	if(sys_rst_i)
		wb_rst_shr <= 16'hffff; // Asynchronous reset using primary input
	else
		wb_rst_shr <= {wb_rst_shr[14:0], ~(LOCKED)}; // Synchronous update
end

// Assign the synchronized reset bit to the output port
assign wb_rst_o = wb_rst_shr[15];

endmodule