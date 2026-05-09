module ztex_ufm1_15d3_corrected_clk (
    fxclk_in,
    reset,
    clk_reset,
    pll_stop,
    dcm_progclk,
    dcm_progdata,
    dcm_progen,
    rd_clk,
    wr_clk,
    wr_start,
    read,
    // DFT inputs
    test_clk,
    test_mode,
    // Outputs
    write
);
	input fxclk_in, reset, clk_reset, pll_stop, dcm_progclk, dcm_progdata, dcm_progen, rd_clk, wr_clk, wr_start;
	input [7:0] read;
    // DFT inputs
    input test_clk;
    input test_mode; // High during scan test

	output [7:0] write;

	reg [3:0] rd_clk_b, wr_clk_b;
	reg wr_start_b1, wr_start_b2, reset_buf;
	reg dcm_progclk_buf, dcm_progdata_buf, dcm_progen_buf;
	reg [4:0] wr_delay;
	reg [351:0] inbuf, inbuf_tmp;
	reg [95:0] outbuf;
	reg [7:0] read_buf, write_buf;

	wire fxclk, clk, dcm_clk, pll_fb, pll_clk0, dcm_locked, pll_reset;
	wire [2:1] dcm_status;
	wire [31:0] golden_nonce, nonce2, hash2;

    // DFT clock selection mux
    wire scan_clk;
    assign scan_clk = test_mode ? test_clk : clk;

    wire scan_fxclk;
    assign scan_fxclk = test_mode ? test_clk : fxclk; // Use test_clk for all FFs in scan mode

	miner253 m (
	    .clk(scan_clk), // Use scan_clk for the miner core
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
          .O(clk) // Functional clock
        );

        DCM_CLKGEN #(
	  .CLKFX_DIVIDE(4.0),
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
	    .RESET_ON_LOSS_OF_LOCK("FALSE")
       )
       pll0 (
    	    .CLKFBOUT(pll_fb),
	    .CLKOUT0(pll_clk0),
	    .CLKFBIN(pll_fb),
	    .CLKIN(dcm_clk),
	    .RST(pll_reset)
	);

	assign write = write_buf;
	assign pll_reset = pll_stop | ~dcm_locked | clk_reset | dcm_status[2];

	// Main logic clocked by scan_clk (functional clk or test_clk)
	always @ (posedge scan_clk)
	begin
    		// Logic related to rd_clk - Assuming rd_clk is synchronous to the main clock domain
            // or properly handled by synchronizers if it's asynchronous.
            // For DFT, changes based on rd_clk edges might need careful handling.
            // This edge detection logic might be problematic for static timing analysis / DFT.
    		if ( (rd_clk_b[3] == rd_clk_b[2]) && (rd_clk_b[2] == rd_clk_b[1]) && (rd_clk_b[1] != rd_clk_b[0]) )
		begin
		    inbuf_tmp[351:344] <= read_buf;
		    inbuf_tmp[343:0] <= inbuf_tmp[351:8];
		end
		inbuf <= inbuf_tmp;

		if ( wr_start_b1 && wr_start_b2 )
		begin
   		    wr_delay <= 5'd0;
		end else
		begin
		    wr_delay[0] <= 1'b1;
		    wr_delay[4:1] <= wr_delay[3:0];
		end

		if ( ! wr_delay[4] )
		begin
   		    outbuf <= { hash2, nonce2, golden_nonce };
   		end else
   		begin
            // Logic related to wr_clk - Similar concerns as rd_clk logic.
		    if ( (wr_clk_b[3] == wr_clk_b[2]) && (wr_clk_b[2] == wr_clk_b[1]) && (wr_clk_b[1] != wr_clk_b[0]) )
			outbuf[87:0] <= outbuf[95:8];
   		end

		read_buf <= read;
		write_buf <= outbuf[7:0];

		// Sampling potentially asynchronous inputs - requires proper synchronization
		rd_clk_b[0] <= rd_clk;
		rd_clk_b[3:1] <= rd_clk_b[2:0];
		wr_clk_b[0] <= wr_clk;
		wr_clk_b[3:1] <= wr_clk_b[2:0];
		wr_start_b1 <= wr_start;
		wr_start_b2 <= wr_start_b1;
		reset_buf <= reset; // Synchronizing reset using scan_clk
	end

	// Logic clocked by scan_fxclk (functional fxclk or test_clk)
	always @ (posedge scan_fxclk)
	begin
		dcm_progclk_buf <= dcm_progclk;
		dcm_progdata_buf <= dcm_progdata;
		dcm_progen_buf <= dcm_progen;
	end

endmodule