module ztex_ufm1_15d1 (
	fxclk_in,
	reset,
	pll_stop,
	dcm_progclk,
	dcm_progdata,
	dcm_progen,
	rd_clk,
	wr_clk,
	wr_start,
	read,
	write
);
	input         fxclk_in;
	input         reset;
	input         pll_stop;
	input         dcm_progclk;
	input         dcm_progdata;
	input         dcm_progen;
	input         rd_clk;
	input         wr_clk;
	input         wr_start;
	input  [7:0]  read;
	output [7:0]  write;

	reg    [3:0]  rd_clk_b;
	reg    [3:0]  wr_clk_b;
	reg           wr_start_b1;
	reg           wr_start_b2;
	reg           reset_buf;
	reg           dcm_progclk_buf;
	reg           dcm_progdata_buf;
	reg           dcm_progen_buf;
	reg    [4:0]  wr_delay;
	reg    [351:0] inbuf;
	reg    [95:0] outbuf;
	reg    [7:0]  read_buf;
	reg    [7:0]  write_buf;

	wire          fxclk;
	wire          clk;
	wire          dcm_clk;
	wire          pll_fb;
	wire          pll_clk0;
	wire          dcm_locked;
	wire          pll_reset;
	wire   [31:0] golden_nonce;
	wire   [31:0] nonce2;
	wire   [31:0] hash2;

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
	  .CLKFX_DIVIDE(6.0), // synthesis tools might prefer integer, but often handle real for clocking
          .CLKFX_MULTIPLY(24),
          .CLKFXDV_DIVIDE(2)
	)
	dcm0 (
    	  .CLKIN(fxclk),
          .CLKFX(dcm_clk),
          .FREEZEDCM(1'b0),
          .PROGCLK(dcm_progclk_buf),
          .PROGDATA(dcm_progdata_buf),
          .PROGEN(dcm_progen_buf),
          .LOCKED(dcm_locked),
          .RST(1'b0) // Assuming reset is handled externally or by PLL reset logic
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
	    .RST(pll_reset)
	);

	assign write = write_buf;
	assign pll_reset = pll_stop | ~dcm_locked | reset; // Added global reset to PLL reset


	always @ (posedge clk)
	begin
		// Synchronize inputs
		read_buf <= read;
		rd_clk_b[0] <= rd_clk;
		rd_clk_b[3:1] <= rd_clk_b[2:0];
		wr_clk_b[0] <= wr_clk;
		wr_clk_b[3:1] <= wr_clk_b[2:0];
		wr_start_b1 <= wr_start;
		wr_start_b2 <= wr_start_b1;
		reset_buf <= reset;

    		// Detect positive edge of rd_clk (synchronized)
		if ( (rd_clk_b[3:1] == 3'b011) ) // Checks for 0 -> 1 transition pattern 011 -> 111 or 001 -> 011
		begin
		    // Shift in new byte from read_buf into inbuf
		    inbuf <= {read_buf, inbuf[351:8]};
		end

		// Handle write start and delay logic
		if ( wr_start_b1 && !wr_start_b2 ) // Detect rising edge of wr_start (after 1 cycle delay)
		begin
   		    wr_delay <= 5'd0; // Reset delay on write start edge
		end
		else if (!wr_delay[4]) // Only increment/shift delay if not finished
		begin
		    // This shift logic fills wr_delay with 1s over 5 cycles.
            // If a simple counter is needed, replace with: wr_delay <= wr_delay + 1;
		    wr_delay[0] <= 1'b1;
		    wr_delay[4:1] <= wr_delay[3:0];
		end

		// Handle output buffer loading and shifting
		if ( !wr_delay[4] ) // Before delay completes
		begin
   		    // Load results from miner into outbuf when calculation is assumed complete
            // (This assumes miner provides results combinatorially or within one clk cycle after inputs are stable)
   		    // A more robust design might need a 'valid' signal from the miner.
   		    outbuf <= { hash2, nonce2, golden_nonce };
   		end
   		else // After delay completes, enable shifting out data
   		begin
		    // Detect positive edge of wr_clk (synchronized)
		    if ( (wr_clk_b[3:1] == 3'b011) ) // Checks for 0 -> 1 transition pattern
		    begin
			    // Shift outbuf down by 8 bits
			    outbuf <= {8'b0, outbuf[95:8]}; // Shift with zeros or keep MSBs? Assuming shift out
                // Update write_buf only when data is shifted
                write_buf <= outbuf[15:8]; // Data shifted from [15:8] will be at [7:0] *next* cycle
                                           // To output the byte shifted *out* this cycle, use previous value's LSBs
                                           // Let's assume we output the LSB *before* the shift:
                // write_buf <= outbuf[7:0]; // Update before shift?
                // Let's stick to the common pattern: output LSB after shift becomes available
                // The previous cycle's outbuf[15:8] is now at outbuf[7:0]
                write_buf <= outbuf[7:0];
            end
   		end

        // If not shifting out this cycle, hold the write_buf value
        // If the initial load should also update write_buf immediately:
        // if (!wr_delay[4]) begin
        //    write_buf <= { hash2, nonce2, golden_nonce }[7:0]; // Update immediately with LSB of result
        // end else if ( (wr_clk_b[3:1] == 3'b011) ) begin
        //    write_buf <= outbuf[7:0]; // Update on shift
        // end
        // The original code updated write_buf every cycle, let's refine based on context:
        // Update write_buf when outbuf LSBs are valid: either initial load or after shift.
        if (!wr_delay[4]) begin
             // Assuming initial load is valid data for LSB output
             write_buf <= { hash2, nonce2, golden_nonce }[7:0];
        end else if ( (wr_clk_b[3:1] == 3'b011) ) begin
             // Update based on the shifted value (which was previously at [15:8])
             // To output the byte that *was* at [7:0] before the shift:
             // Need to latch outbuf[7:0] before it gets shifted, or use outbuf[15:8] from *before* the shift.
             // Let's assume the intent is to output the LSBs currently available in outbuf[7:0]
             write_buf <= outbuf[7:0];
        end
        // This logic ensures write_buf only updates when new data is available at the LSB position.

	end

	// Synchronize DCM programming signals to fxclk
	always @ (posedge fxclk)
	begin
		dcm_progclk_buf <= dcm_progclk;
		dcm_progdata_buf <= dcm_progdata;
		dcm_progen_buf <= dcm_progen;
	end

endmodule