module ztex_ufm1_15d3 (fxclk_in, reset, clk_reset, pll_stop,  dcm_progclk, dcm_progdata, dcm_progen,  rd_clk, wr_clk, wr_start, read, write);
	input fxclk_in, reset, clk_reset, pll_stop, dcm_progclk, dcm_progdata, dcm_progen, rd_clk, wr_clk, wr_start;
	input [7:0] read;
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
	  .CLKFX_DIVIDE(4), // Corrected: Changed 4.0 to 4
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

	always @ (posedge clk)
	begin
    		// Detect rising edge of rd_clk synchronized to clk
    		if ( (rd_clk_b[3] == 1'b0) && (rd_clk_b[2] == 1'b0) && (rd_clk_b[1] == 1'b0) && (rd_clk_b[0] == 1'b1) ) // More robust edge detection
		begin
		    inbuf_tmp[351:344] <= read_buf;
		    inbuf_tmp[343:0] <= inbuf[351:8]; // Corrected: Use 'inbuf' for shift source
		    inbuf <= inbuf_tmp; // Update inbuf only when new data is read
		end

		// Handle wr_start and delay logic
		if ( wr_start_b1 && !wr_start_b2 ) // Detect rising edge of wr_start (sync'd)
		begin
   		    wr_delay <= 5'b10000; // Start a 5-cycle delay marker (adjust if needed)
		end else if (|wr_delay) // Check if delay is active (any bit is 1)
		begin
		    wr_delay <= wr_delay >> 1; // Shift the marker right
		end
        // Note: Original wr_start logic kept for reference if needed:
		// if ( wr_start_b1 && wr_start_b2 ) // Original condition
		// begin
   	    // 	wr_delay <= 5'd0;
		// end else
		// begin
		//     wr_delay[0] <= 1'b1;
		//     wr_delay[4:1] <= wr_delay[3:0];
		// end


		// Output logic based on delay state (using wr_delay[0] as 'delay finished' signal)
		// Assuming the 5-cycle delay means load for 5 cycles, then shift
		// Let's assume loading happens when delay is NOT active (or finished)
		// A marker starting at 10000 shifted right means delay active until marker is 00000
		// So load when wr_delay == 5'b00000
		if ( wr_delay == 5'b00000 ) // Load result when delay is not active/finished
		begin
   		    outbuf <= { hash2, nonce2, golden_nonce };
   		end
   		else // Shift out data during delay period or when initiated by wr_clk
   		begin
            // Detect rising edge of wr_clk synchronized to clk
		    if ( (wr_clk_b[3] == 1'b0) && (wr_clk_b[2] == 1'b0) && (wr_clk_b[1] == 1'b0) && (wr_clk_b[0] == 1'b1) ) // More robust edge detection
			    outbuf[87:0] <= outbuf[95:8]; // Shift right by 8 bits
   		end

		// Update synchronous buffers
		read_buf <= read;           // Buffer input data
		write_buf <= outbuf[7:0];   // Output LSB of output buffer

		// Update shift registers for edge detection
		rd_clk_b[0] <= rd_clk;
		rd_clk_b[3:1] <= rd_clk_b[2:0];

		wr_clk_b[0] <= wr_clk;
		wr_clk_b[3:1] <= wr_clk_b[2:0];

		// Update synchronizers/delay line for wr_start
		wr_start_b1 <= wr_start;
		wr_start_b2 <= wr_start_b1;

		// Update reset synchronizer
		reset_buf <= reset;
	end

	// Synchronize DCM programming signals to fxclk
	always @ (posedge fxclk)
	begin
		dcm_progclk_buf <= dcm_progclk;
		dcm_progdata_buf <= dcm_progdata;
		dcm_progen_buf <= dcm_progen;
	end

endmodule