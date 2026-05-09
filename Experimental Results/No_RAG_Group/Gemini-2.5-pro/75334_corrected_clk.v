`timescale 1ns / 1ps
module corrected_clk( // Renamed module, assuming '1' is the number
	input sys_clk_i,
	input sys_rst_i,
	input test_clk_i, // Added test clock input
	input test_mode_i, // Added test mode input
	output wb_clk_o,
	output wb_clk2x_o,
	output wb_rst_o
);

wire sys_clk_ibufg;
wire clkout0;
wire clkout1;
wire LOCKED;
wire wb_clk_gen;    // Internal generated clock
wire wb_clk2x_gen;  // Internal generated 2x clock
wire wb_rst_func;   // Internal functional reset

IBUFG sys_clk_in_ibufg(
	.I(sys_clk_i),
	.O(sys_clk_ibufg)
);

// Unused wires (kept for completeness of original structure)
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
	.CLKOUT0(clkout0),
	.CLKOUT0B(clkout0b_unused),
	.CLKOUT1(clkout1),
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
	.LOCKED(LOCKED),
	.CLKINSTOPPED(clkinstopped_unused),
	.CLKFBSTOPPED(clkfbstopped_unused),
	.PWRDWN(test_mode_i), // Power down MMCM in test mode if desired/possible
	.RST(sys_rst_i)
);

BUFG clkf_buf(
	.O(clkfbout_buf),
	.I(clkfbout)
);

// Drive internal generated clocks through BUFGs
BUFG wb_clk_buf(
	.O(wb_clk_gen),
	.I(clkout0)
);

BUFG wb_clk2x_buf(
	.O(wb_clk2x_gen),
	.I(clkout1)
);

// Clock MUXes for DFT: Select test clock in test mode
assign wb_clk_o   = test_mode_i ? test_clk_i : wb_clk_gen;
assign wb_clk2x_o = test_mode_i ? test_clk_i : wb_clk2x_gen; // Often use same test clk

// Functional Reset Generation Logic
reg [15:0] wb_rst_shr;
always @(posedge wb_clk_gen or posedge sys_rst_i) // Use internal clock for functional reset logic
begin
	if(sys_rst_i)
		wb_rst_shr <= 16'hffff;
	else
		wb_rst_shr <= {wb_rst_shr[14:0], ~(LOCKED)};
end
assign wb_rst_func = wb_rst_shr[15];

// Reset MUX for DFT: Select primary reset in test mode
assign wb_rst_o = test_mode_i ? sys_rst_i : wb_rst_func;

endmodule