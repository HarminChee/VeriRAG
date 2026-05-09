module ezusb_io #(
	parameter OUTEP = 2,
	parameter INEP = 6
    ) (
        // DFT Inputs
        input wire test_mode,           // DFT test mode enable
        input wire test_clk,            // DFT test clock

        // Original Ports
        output ifclk,
        input reset,                    // Primary reset
        output reset_out,
        input ifclk_in,
        inout [15:0] fd,
	output reg SLWR, PKTEND,
	output SLRD, SLOE,
	output [1:0] FIFOADDR,
	input EMPTY_FLAG, FULL_FLAG,
        input [15:0] DI,
        input DI_valid,
        output DI_ready,
        input DI_enable,
        input [15:0] pktend_timeout,
        output reg [15:0] DO,
        output reg DO_valid,
        input DO_ready,
        output [3:0] status
    );

    // Internal wires for clock generation
    wire ifclk_inbuf, ifclk_fbin, ifclk_fbout, ifclk_out, locked;
    wire func_clk; // Functional clock output from BUFG

    // DFT MUXed clock and reset
    wire dft_clk;
    wire dft_reset;

    IBUFG ifclkin_buf (
	.I(ifclk_in),
	.O(ifclk_inbuf)
    );

    BUFG ifclk_fb_buf (
        .I(ifclk_fbout),
        .O(ifclk_fbin)
     );

    BUFG ifclk_out_buf (
        .I(ifclk_out),
        .O(func_clk) // Output functional clock
     );

    // Assign output clock (usually functional clock, might need review if test_clk needs to be output)
    assign ifclk = func_clk;

    MMCME2_BASE #(
       .BANDWIDTH("OPTIMIZED"),
       .CLKFBOUT_MULT_F(20.0),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(0.0),
       .CLKOUT0_DIVIDE_F(20.0),
       .CLKOUT1_DIVIDE(1),
       .CLKOUT2_DIVIDE(1),
       .CLKOUT3_DIVIDE(1),
       .CLKOUT4_DIVIDE(1),
       .CLKOUT5_DIVIDE(1),
       .CLKOUT0_DUTY_CYCLE(0.5),
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(0.0),
       .CLKOUT2_PHASE(0.0),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(0.0),
       .CLKOUT5_PHASE(0.0),
       .CLKOUT4_CASCADE("FALSE"),
       .DIVCLK_DIVIDE(1),
       .REF_JITTER1(0.0),
       .STARTUP_WAIT("FALSE")
    )  isclk_mmcm_inst (
       .CLKOUT0(ifclk_out),
       .CLKFBOUT(ifclk_fbout),
       .CLKIN1(ifclk_inbuf),
       .PWRDWN(1'b0),
       .RST(reset), // MMCM reset by primary reset
       .CLKFBIN(ifclk_fbin),
       .LOCKED(locked)
    );

    // DFT Clock MUX: Select test_clk in test_mode, otherwise functional clock
    assign dft_clk = test_mode ? test_clk : func_clk;

    // DFT Reset Logic: Use primary reset in test_mode, otherwise functional condition
    // The functional reset depends on MMCM lock status.
    assign dft_reset = test_mode ? reset : (reset || !locked);

    // Internal logic signals
    reg if_out;
    reg [4:0] if_out_buf;
    reg [15:0] fd_buf;
    reg resend;
    reg SLRD_buf;
    reg pktend_req;
    reg pktend_en;
    reg [31:0] pktend_cnt;

    // Output assignments
    assign SLOE = if_out;
    assign FIFOADDR = if_out ? OUTEP/2-1 : INEP/2-1;
    assign fd = if_out ? fd_buf : {16{1'bz}}; // Tristate control
    assign SLRD = SLRD_buf || !DO_ready;
    assign status = { !SLRD_buf, !SLWR, resend, if_out };
    // DI_ready depends on the effective reset state (dft_reset)
    assign DI_ready = !dft_reset && FULL_FLAG && if_out & if_