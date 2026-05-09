module ztex_ufm1_15d3 (fxclk_in, reset, clk_reset, pll_stop,  dcm_progclk, dcm_progdata, dcm_progen,  rd_clk, wr_clk, wr_start, read, write, test_i);
	input fxclk_in, reset, clk_reset, pll_stop, dcm_progclk, dcm_progdata, dcm_progen, rd_clk, wr_clk, wr_start;
	input [7:0] read;
	output wire [7:0] write; // Explicitly wire
	input test_i; // Added test mode input

	reg [3:0] rd_clk_b, wr_clk_b;
	reg wr_start_b1, wr_start_b2, reset_buf;
	reg dcm_progclk_buf, dcm_progdata_buf, dcm_progen_buf;
	reg [4:0] wr_delay;
	reg [351:0] inbuf, inbuf_tmp;
	reg [95:0] outbuf;
	reg [7:0] read_buf, write_buf;

	wire fxclk, clk, dcm_clk, pll_fb, pll_clk0, dcm_locked;
	wire [2:1] dcm_status;
	wire [31:0] golden_nonce, nonce2, hash2;
	wire dft_rd_clk; // Added for CDFDAT fix
	wire dft_wr_clk; // Added for CDFDAT fix
	wire func_pll_reset; // Added for ACNCPI fix
	wire dft_pll_reset; // Added for ACNCPI fix

	miner253 m (
	    .clk(clk),
	    .reset(reset_buf),
	    .midstate(inbuf[351:96]),
	    .data(inbuf[95:0]),
	    .golden_nonce(golden_nonce),
	    .nonce2(nonce2),
	    .hash2(hash2)
	);
	BUFG bufg_fxclk (
          .I(fxclk_in),
          .O(fxclk)
        );
	BUFG bufg_clk (
          .I(pll_clk0),
          .O(clk)
        );
        DCM_CLKGEN #(
	  .CLKFX_DIVIDE(4), // Changed from 4.0 to 4
          .CLKFX_MULTIPLY(32),
          .CLKFXDV_DIVIDE(2),
          .CLKIN_PERIOD(20.8333)
	)
	dcm0 (
    	  .CLKIN(fxclk),
          .CLKFXDV(dcm_clk),
          .FREEZEDCM(1'b0),
          .PROGCLK(dcm_progclk_buf),
          .PROGDATA(dcm_progdata_buf),
          .PROGEN(dcm_progen_buf),
          .LOCKED(dcm_locked),
          .STATUS(dcm_status),
          .RST(clk_reset)
	);
	PLL_BASE #(
    	    .BANDWIDTH("LOW"),
    	    .CLKFBOUT_MULT(4),
    	    .CLKOUT0_DIVIDE(4),
    	    .CLKOUT0_DUTY_CYCLE(0.5),
    	    .CLK_FEEDBACK("CLKFBOUT"),
    	    .COMPENSATION("INTERNAL"),
	    .DIVCLK_DIVIDE(1),
    	    .REF_JITTER(0.10),