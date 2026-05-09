module ztex_ufm1_15d4 (
	input test_mode, // Added for DFT
	input fxclk_in, 
	input reset, 
	input clk_reset, 
	input pll_stop,  
	input dcm_progclk, 
	input dcm_progdata, 
	input dcm_progen,  
	input rd_clk, 
	input wr_clk, 
	input wr_start, 
	input [7:0] read, 
	output [7:0] write
);
	reg [3:0] rd_clk_b, wr_clk_b;
	reg wr_start_b1, wr_start_b2, reset_buf;
	reg dcm_progclk_buf, dcm_progdata_buf, dcm_progen_buf;
	reg [4:0] wr_delay;
	reg [351:0] inbuf, inbuf_tmp;
	reg [127:0] outbuf;
	reg [7:0] read_buf, write_buf;
	reg [31:0] golden_nonce1, golden_nonce2;
	wire fxclk, clk, dcm_clk, pll_fb, pll_clk0, dcm_locked, pll_reset;
	wire [2:1] dcm_status;
	wire [31:0] golden_nonce, nonce2, hash2;

	wire dft_clk; // Added for DFT
	wire dft_pll_reset; // Added for DFT

	miner253 m (
	    .clk(dft_clk), // Modified for DFT
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

    // DFT Clock Mux: Selects test clock (fxclk) in test_mode, functional clock (clk) otherwise
    assign dft_clk = test_mode ? fxclk : clk;

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
          .RST(clk_reset) // clk_reset is primary input, OK for DFT
	);

	// Original PLL reset logic
	assign pll_reset = pll_stop | ~dcm_locked | clk_reset | dcm_status[2];

	// DFT PLL Reset Mux: Selects primary reset (reset) in test_mode, functional reset otherwise
	assign dft_pll_reset = test_mode ? reset : pll_reset; 

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
	    .CLKIN(dcm_clk), // Clock input is generated, but PLLs often handled separately or bypassed
	    .RST(dft_pll_reset) // Modified for DFT
	);

	assign write = write_buf;

	// Main logic clocked by dft_clk
	always @ (posedge dft_clk) // Modified for DFT
	begin
    		// Detect rising edge of rd_clk synchronized to dft_clk
    		if ( (rd_clk_b[3] == rd_clk_b[2]) && (rd_clk_b[2] == rd_clk_b[1]) && (rd_clk_b[1] != rd_clk_b[0]) )
		begin
		    inbuf_tmp[351:344] <= read_buf;
		    inbuf_tmp[343:0] <= inbuf_tmp[351:8];
		end
		// Note: Direct assignment like this might have timing issues if inbuf_tmp is used elsewhere combinatorially.
		// Assuming it's only used for sequential input to 'inbuf' FF.
		inbuf <= inbuf_tmp; 

		// Wr_delay logic
		if ( wr_start_b1 && wr_start_b2 )
		begin
   		    wr_delay <= 5'd0;
		end else 
		begin
		    // This creates a shift register for wr_delay, effectively delaying a '1'
		    wr_delay[0] <= 1'b1; 
		    wr_delay[4:1] <= wr_delay[3:0];
		end

		// Outbuf logic based on wr_delay and wr_clk edge
		if ( ! wr_delay[4] ) 
		begin
   		    // Latch results when not delaying
   		    outbuf <= { golden_nonce2, hash2, nonce2, golden_nonce1 };
   		end else
   		begin
		    // Shift outbuf data on detected wr_clk edge while delaying
		    if ( (wr_clk_b[3] == wr_clk_b[2]) && (wr_clk_b[2] == wr_clk_b[1]) && (wr_clk_b[1] != wr_clk_b[0]) ) 
			outbuf[119:0] <= outbuf[127:8];
   		end

   		// Golden nonce update logic (synchronous reset behavior)
   		if ( reset_buf ) // reset_buf is FF driven by primary 'reset'
   		begin
   		    golden_nonce2 <= 32'd0;
   		    golden_nonce1 <= 32'd0;
   		end else if ( golden_nonce != golden_nonce1 ) // Update if new golden_nonce found
   		begin
   		    golden_nonce2 <= golden_nonce1;
   		    golden_nonce1 <= golden_nonce;
   		end

		// Register inputs and internal signals
		read_buf <= read; // read is primary input
		write_buf <= outbuf[7:0]; // Driven by internal state outbuf

		// Synchronizers/Edge detectors for asynchronous inputs rd_clk and wr_clk
		rd_clk_b[0] <= rd_clk; // rd_clk is primary input
		rd_clk_b[3:1] <= rd_clk_b[2:0];
		wr_clk_b[0] <= wr_clk; // wr_clk is primary input
		wr_clk_b[3:1] <= wr_clk_b[2:0];

		// Synchronizer for wr_start
		wr_start_b1 <= wr_start; // wr_start is primary input
		wr_start_b2 <= wr_start_b1;

		// Register primary reset
		reset_buf <= reset; // reset is primary input
	end

	// Logic clocked by fxclk (derived directly from primary input fxclk_in) - OK for DFT
	always @ (posedge fxclk)
	begin
		dcm_progclk_buf <= dcm_progclk;   // dcm_progclk is primary input
		dcm_progdata_buf <= dcm_progdata; // dcm_progdata is primary input
		dcm_progen_buf <= dcm_progen;   // dcm_progen is primary input
	end
endmodule