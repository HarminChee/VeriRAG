module ztex_ufm1_15d1_1_corrected_clk (
    // Added test_mode input for DFT
    input test_mode,
    // Original ports
    input fxclk_in, reset, pll_stop,  dcm_progclk, dcm_progdata, dcm_progen,  rd_clk, wr_clk, wr_start,
    input [7:0] read,
    output [7:0] write
);

    // Original registers and wires
	reg [3:0] rd_clk_b, wr_clk_b;
	reg wr_start_b1, wr_start_b2, reset_buf;
	reg dcm_progclk_buf, dcm_progdata_buf, dcm_progen_buf;
	reg [4:0] wr_delay;
	reg [351:0] inbuf, inbuf_tmp;
	reg [95:0] outbuf;
	reg [7:0] read_buf, write_buf;
	wire fxclk, clk, dcm_clk, pll_fb, pll_clk0, dcm_locked, pll_reset;
	wire [31:0] golden_nonce, nonce2, hash2;

    // DFT modification: Multiplexed clock
    // Selects functional clock (clk) in normal mode and test clock (fxclk) in test mode
    wire scan_clk;
    assign scan_clk = test_mode ? fxclk : clk;

    // DFT modification: Control PLL reset during test mode
    // Hold PLL in reset during test_mode or when pll_stop is asserted or DCM is not locked
    assign pll_reset = test_mode | pll_stop | ~dcm_locked;

	miner253 m (
        // DFT modification: Use multiplexed clock (scan_clk)
	    .clk(scan_clk),
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
	  .CLKFX_DIVIDE(6.0),
          .CLKFX_MULTIPLY(24),
          .CLKFXDV_DIVIDE(2)
	)
	dcm0 (
    	  .CLKIN(fxclk),
          .CLKFX(dcm_clk),
          .FREEZEDCM(1'b0), // Consider controlling FREEZEDCM based on test_mode if needed
          .PROGCLK(dcm_progclk_buf),
          .PROGDATA(dcm_progdata_buf),
          .PROGEN(dcm_progen_buf),
          .LOCKED(dcm_locked),
          .RST(1'b0) // Assuming DCM reset is handled externally or not needed for bypass
	);

	PLL_BASE #(
    	    .BANDWIDTH("LOW"),
    	    .CLKFBOUT_MULT(4),
    	    .CLKOUT0_DIVIDE(4),
    	    .CLKOUT0_DUTY_CYCLE(0.5),
    	    .CLK_FEEDBACK("CLKFBOUT"),
    	    .COMPENSATION("DCM2PLL"),
	    .DIVCLK_DIVIDE(1),
    	    .REF_JITTER(0.05),
	    .RESET_ON_LOSS_OF_LOCK("FALSE")
       )
       pll0 (
    	    .CLKFBOUT(pll_fb),
	    .CLKOUT0(pll_clk0),
	    .CLKFBIN(pll_fb),
	    .CLKIN(dcm_clk),
            // DFT modification: PLL reset controlled by test_mode, pll_stop, dcm_locked
	    .RST(pll_reset)
	);

	assign write = write_buf;

    // DFT modification: Use multiplexed clock (scan_clk) for all synchronous logic
	always @ (posedge scan_clk)
	begin
    		// Logic for handling read data based on rd_clk edge detection
    		if ( (rd_clk_b[3] == rd_clk_b[2]) && (rd_clk_b[2] == rd_clk_b[1]) && (rd_clk_b[1] != rd_clk_b[0]) )
		begin
		    inbuf_tmp[351:344] <= read_buf;
		    inbuf_tmp[343:0] <= inbuf_tmp[351:8];
		end
		inbuf <= inbuf_tmp;

        // Logic for handling write delay and start signal
		if ( wr_start_b1 && wr_start_b2 )
		begin
   		    wr_delay <= 5'd0;
		end else
		begin
		    wr_delay[0] <= 1'b1;
		    wr_delay[4:1] <= wr_delay[3:0];
		end

        // Logic for handling output buffer based on write delay and wr_clk edge detection
		if ( ! wr_delay[4] )
		begin
   		    outbuf <= { hash2, nonce2, golden_nonce };
   		end else
   		begin
		    if ( (wr_clk_b[3] == wr_clk_b[2]) && (wr_clk_b[2] == wr_clk_b[1]) && (wr_clk_b[1] != wr_clk_b[0]) )
			outbuf[87:0] <= outbuf[95:8];
   		end

        // Registering inputs and propagating internal signals
		read_buf <= read;
		write_buf <= outbuf[7:0];
		rd_clk_b[0] <= rd_clk;
		rd_clk_b[3:1] <= rd_clk_b[2:0];
		wr_clk_b[0] <= wr_clk;
		wr_clk_b[3:1] <= wr_clk_b[2:0];
		wr_start_b1 <= wr_start;
		wr_start_b2 <= wr_start_b1;
		reset_buf <= reset;
	end

    // DFT modification: Use multiplexed clock (scan_clk) for DCM programming registers
	always @ (posedge scan_clk)
	begin
		dcm_progclk_buf <= dcm_progclk;
		dcm_progdata_buf <= dcm_progdata;
		dcm_progen_buf <= dcm_progen;
	end

endmodule