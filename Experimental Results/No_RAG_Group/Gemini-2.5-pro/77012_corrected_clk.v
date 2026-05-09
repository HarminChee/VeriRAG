`timescale 1ns / 1ps
module clkgen_corrected_clk ( // Renamed module slightly for clarity
    // Original Ports
	input sys_clk_i,
	input sys_rst_i,
	output wb_clk_o,
	output wb_clk2x_o,
	output wb_rst_o,

    // DFT Ports
    input test_mode_i, // Scan enable / Test mode select
    input test_clk_i   // Scan clock input
);

// Internal wires
wire sys_clk_ibufg;
wire clkout0;
wire clkout1;
wire LOCKED;
wire wb_clk_internal;
wire wb_clk2x_internal;
wire wb_rst_internal_unbuf;

// Unused MMCM signals (wires declared for tool linting/synthesis)
wire [15:0] do_unused;
wire drdy_unused;
wire psdone_unused;
wire clkfbout;
wire clkfbout_buf;
wire clkfboutb_unused;
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


// Input Buffer for System Clock
IBUFG sys_clk_in_ibufg(
	.I(sys_clk_i),
	.O(sys_clk_ibufg)
);

// MMCM Instance
MMCME2_ADV #(
	.BANDWIDTH("OPTIMIZED"),
	.CLKOUT4_CASCADE("FALSE"),
	.COMPENSATION("ZHOLD"),
	.STARTUP_WAIT("FALSE"),
	.DIVCLK_DIVIDE(1),
	.CLKFBOUT_MULT_F(10.000),
	.CLKFBOUT_PHASE(0.000),
	.CLKFBOUT_USE_FINE_PS ("FALSE"),
	.CLKOUT0_DIVIDE_F(20.000), // Generates wb_clk_o freq
	.CLKOUT0_PHASE(0.000),
	.CLKOUT0_DUTY_CYCLE(0.500),
	.CLKOUT0_USE_FINE_PS("FALSE"),
	.CLKOUT1_DIVIDE(10),       // Generates wb_clk2x_o freq
	.CLKOUT1_PHASE(0.000),
	.CLKOUT1_DUTY_CYCLE(0.500),
	.CLKOUT1_USE_FINE_PS("FALSE"),
	.CLKIN1_PERIOD(10.000),    // Input clock period (e.g., 100MHz)
	.REF_JITTER1(0.010)
) mmcm_adv_inst(
	.CLKFBOUT(clkfbout),
	.CLKFBOUTB(clkfboutb_unused),
	.CLKOUT0(clkout0),           // Output for wb_clk_o
	.CLKOUT0B(clkout0b_unused),
	.CLKOUT1(clkout1),           // Output for wb_clk2x_o
	.CLKOUT1B(clkout1b_unused),
	.CLKOUT2(clkout2_unused),
	.CLKOUT2B(clkout2b_unused),
	.CLKOUT3(clkout3_unused),
	.CLKOUT3B(clkout3b_unused),
	.CLKOUT4(clkout4_unused),
	.CLKOUT5(clkout5_unused),
	.CLKOUT6(clkout6_unused),
	// Inputs
	.CLKFBIN(clkfbout_buf),
	.CLKIN1(sys_clk_ibufg),     // Clock input
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
	.LOCKED(LOCKED),           // MMCM Lock signal
	.CLKINSTOPPED(clkinstopped_unused),
	.CLKFBSTOPPED(clkfbstopped_unused),
	.PWRDWN(1'b0),             // Power down (could be controlled by test_mode_i if needed)
	.RST(sys_rst_i)            // Reset input
);

// Feedback Buffer for MMCM
BUFG clkf_buf(
	.O(clkfbout_buf),
	.I(clkfbout)
);

// Internal Buffers for Generated Clocks
BUFG wb_clk_buf(
	.O(wb_clk_internal),
	.I(clkout0)
);

BUFG wb_clk2x_buf(
	.O(wb_clk2x_internal),
	.I(clkout1)
);

// DFT Clock Muxing: Select between functional clock and test clock
// In test mode, bypass the MMCM-generated clocks with the test clock.
assign wb_clk_o   = test_mode_i ? test_clk_i : wb_clk_internal;
assign wb_clk2x_o = test_mode_i ? test_clk_i : wb_clk2x_internal; // Assumes same test clock for both domains

// Reset Synchronizer (Functional Mode)
// Synchronizes the reset signal to the functional wb_clk domain
// based on system reset and MMCM lock status.
reg [15:0] wb_rst_shr;
always @(posedge wb_clk_internal or posedge sys_rst_i) // Use internal functional clock
begin
	if(sys_rst_i)
		wb_rst_shr <= 16'hFFFF; // Assert reset when sys_rst_i is high
	else
		wb_rst_shr <= {wb_rst_shr[14:0], ~LOCKED}; // Deassert reset only after MMCM locks
end
assign wb_rst_internal_unbuf = wb_rst_shr[15]; // Output of functional reset logic

// DFT Reset Muxing: Select between functional reset and test reset (sys_rst_i)
// In test mode, bypass the synchronized reset and use the primary reset directly.
assign wb_rst_o = test_mode_i ? sys_rst_i : wb_rst_internal_unbuf;

endmodule