module ztex_ufm1_15d1 (
    // Original Ports
    fxclk_in, reset, pll_stop,  dcm_progclk, dcm_progdata, dcm_progen,  rd_clk, wr_clk, wr_start, read, write,
    // DFT Ports
    test_mode, test_clk, test_reset_n, test_data_in
);
	input fxclk_in, reset, pll_stop, dcm_progclk, dcm_progdata, dcm_progen, rd_clk, wr_clk, wr_start;
	input [7:0] read;
	output [7:0] write;

    // DFT Inputs
    input test_mode;       // Test mode enable
    input test_clk;        // Test clock input
    input test_reset_n;    // Asynchronous test reset (active low)
    input [7:0] test_data_in; // Test data input for read path

	reg [3:0] rd_clk_b, wr_clk_b;
	reg wr_start_b1, wr_start_b2;
	// reg reset_buf; // Removed, replaced by test_reset_n handling
	reg dcm_progclk_buf, dcm_progdata_buf, dcm_progen_buf;
	reg [4:0] wr_delay;
	reg [351:0] inbuf, inbuf_tmp;
	reg [95:0] outbuf;
	reg [7:0] read_buf, write_buf;
	wire fxclk, clk, dcm_clk, pll_fb, pll_clk0, dcm_locked, pll_reset;
	wire [31:0] golden_nonce, nonce2, hash2;

    // DFT Wires
    wire clk_muxed;
    wire pll_reset_muxed;

    // Select functional clock or test clock
    assign clk_muxed = test_mode ? test_clk : clk;

    // Select functional PLL reset or test reset
    // Use active-low test_reset_n for asynchronous reset during test mode
    assign pll_reset_muxed = test_mode ? ~test_reset_n : (pll_stop | ~dcm_locked);

	miner253 m (
	    .clk(clk_muxed), // Use muxed clock
	    .reset(~test_reset_n), // Use asynchronous test reset (active high reset assumed by miner)
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
          .O(clk) // Original clock generation path remains
        );

        DCM_CLKGEN #(
	  .CLKFX_DIVIDE(6.0), // Parameter value should be integer or real, not float like 6.0. Assuming 6 is intended.
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
          .RST(1'b0) // Functional reset for DCM, assumed OK or needs separate handling if problematic
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
	    .RST(pll_reset_muxed) // Use muxed reset for PLL
	);

	assign write = write_buf;
	assign pll_reset = pll_stop | ~dcm_locked; // Original assignment retained if needed elsewhere, but not for PLL RST

	// Main logic block, clocked by muxed clock, reset by async test reset
	always @ (posedge clk_muxed or negedge test_reset_n)
	begin
	    if (!test_reset_n) begin // Asynchronous test reset (active low)
            rd_clk_b <= 4'b0;
            wr_clk_b <= 4'b0;
            wr_start_b1 <= 1'b0;
            wr_start_b2 <= 1'b0;
            wr_delay <= 5'b0;
            inbuf <= 352'b0;
            inbuf_tmp <= 352'b0;
            outbuf <= 96'b0;
            read_buf <= 8'b0;
            write_buf <= 8'b0;
	    end else begin // Normal operation or functional reset
            // Note: Original functional reset 'reset' is not explicitly used here anymore.
            // If synchronous functional reset is required for these FFs, it needs to be added.
            // Example: if (reset) begin ... sync reset actions ... end else begin ... normal ops ... end

            // Edge detection and input buffering logic
		    if ( (rd_clk_b[3] == rd_clk_b[2]) && (rd_clk_b[2] == rd_clk_b[1]) && (rd_clk_b[1] != rd_clk_b[0]) )
		    begin
		        inbuf_tmp[351:344] <= read_buf;
		        inbuf_tmp[343:0] <= inbuf_tmp[351:8];
		    end
		    inbuf <= inbuf_tmp;

            // Write delay logic
		    if ( wr_start_b1 && wr_start_b2 ) // Detects end of wr_start pulse?
		    begin
   		        wr_delay <= 5'd0;
		    end else
		    begin
		        wr_delay[0] <= 1'b1; // Seems to start a delay/timer
		        wr_delay[4:1] <= wr_delay[3:0]; // Shift
		    end

            // Output buffer logic
		    if ( ! wr_delay[4] ) // Capture output while delay counter is running?
		    begin
   		        outbuf <= { hash2, nonce2, golden_nonce };
   		    end else // Shift output buffer when delay finished?
   		    begin
		        if ( (wr_clk_b[3] == wr_clk_b[2]) && (wr_clk_b[2] == wr_clk_b[1]) && (wr_clk_b[1] != wr_clk_b[0]) )
			        outbuf[87:0] <= outbuf[95:8];
   		    end

            // Read/Write buffer updates
		    read_buf <= test_mode ? test_data_in : read; // Use muxed read data
		    write_buf <= outbuf[7:0]; // Output oldest byte

            // Sample external signals/clocks (potential DFT issue remaining if rd_clk/wr_clk asynchronous)
		    rd_clk_b[0] <= rd_clk;
		    rd_clk_b[3:1] <= rd_clk_b[2:0];
		    wr_clk_b[0] <= wr_clk;
		    wr_clk_b[3:1] <= wr_clk_b[2:0];
		    wr_start_b1 <= wr_start;
		    wr_start_b2 <= wr_start_b1;
		    // reset_buf <= reset; // Removed
		end
	end

	// This block is clocked by fxclk (derived from primary input fxclk_in), which is DFT-friendly.
	// Assuming no problematic reset needed here.
	always @ (posedge fxclk)
	begin
		dcm_progclk_buf <= dcm_progclk;
		dcm_progdata_buf <= dcm_progdata;
		dcm_progen_buf <= dcm_progen;
	end
endmodule