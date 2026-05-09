module ztex_ufm1_15d4 (
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
    read_data, // Renamed from 'read'
    write_data // Renamed from 'write'
);
	input fxclk_in;
	input reset;
	input clk_reset;
	input pll_stop;
	input dcm_progclk;
	input dcm_progdata;
	input dcm_progen;
	input rd_clk;
	input wr_clk;
	input wr_start;
	input [7:0] read_data; // Renamed from 'read'
	output [7:0] write_data; // Renamed from 'write'

	reg [3:0] rd_clk_b;
	reg [3:0] wr_clk_b;
	reg wr_start_b1;
	reg wr_start_b2;
	reg reset_buf;
	reg dcm_progclk_buf;
	reg dcm_progdata_buf;
	reg dcm_progen_buf;
	reg [4:0] wr_delay;
	reg [351:0] inbuf;
	reg [351:0] inbuf_tmp; // Temporary buffer for input assembly
	reg [127:0] outbuf;
	reg [7:0] read_buf;
	reg [7:0] write_buf;
	reg [31:0] golden_nonce1;
	reg [31:0] golden_nonce2;

	wire fxclk;
	wire clk;
	wire dcm_clk;
	wire pll_fb;
	wire pll_clk0;
	wire dcm_locked;
	wire pll_reset;
	wire [2:1] dcm_status;
	wire [31:0] golden_nonce;
	wire [31:0] nonce2;
	wire [31:0] hash2;

	// Instantiate the miner core
	miner253 m (
	    .clk(clk),
	    .reset(reset_buf),
	    .midstate(inbuf[351:96]), // Assuming midstate is upper 256 bits
	    .data(inbuf[95:0]),      // Assuming data is lower 96 bits
	    .golden_nonce(golden_nonce),
	    .nonce2(nonce2),
	    .hash2(hash2)
	);

	// Input clock buffer
	BUFG bufg_fxclk (
          .I(fxclk_in),
          .O(fxclk)
        );

	// Main clock buffer
	BUFG bufg_clk (
          .I(pll_clk0),
          .O(clk)
        );

    // DCM for initial clock conditioning (Example parameters)
    DCM_CLKGEN #(
      .CLKFX_DIVIDE(4),         // Check if real is allowed, otherwise adjust
      .CLKFX_MULTIPLY(32),
      .CLKFXDV_DIVIDE(2),
      .CLKIN_PERIOD(20.8333)    // Check if real is allowed, otherwise adjust
    )
    dcm0 (
      .CLKIN(fxclk),
      .CLKFXDV(dcm_clk),         // Output clock for PLL
      .FREEZEDCM(1'b0),
      .PROGCLK(dcm_progclk_buf),
      .PROGDATA(dcm_progdata_buf),
      .PROGEN(dcm_progen_buf),
      .LOCKED(dcm_locked),
      .STATUS(dcm_status),       // Status bits [2:1]
      .RST(clk_reset)            // Reset for DCM
    );

    // PLL for final clock generation (Example parameters)
    PLL_BASE #(
        .BANDWIDTH("LOW"),
        .CLKFBOUT_MULT(4),       // Example multiplier
        .CLKOUT0_DIVIDE(4),      // Example divider for CLKOUT0
        .CLKOUT0_DUTY_CYCLE(0.5),
        .CLK_FEEDBACK("CLKFBOUT"),
        .COMPENSATION("INTERNAL"),
        .DIVCLK_DIVIDE(1),       // Input divider
        .REF_JITTER(0.10),
        .RESET_ON_LOSS_OF_LOCK("FALSE")
   )
   pll0 (
        .CLKFBOUT(pll_fb),       // Feedback output
        .CLKOUT0(pll_clk0),      // Main clock output (buffered to 'clk')
        .CLKFBIN(pll_fb),        // Feedback input
        .CLKIN(dcm_clk),         // Clock input from DCM
        .RST(pll_reset)          // Reset for PLL
    );

	// Assign output data
	assign write_data = write_buf; // Renamed from 'write'

	// Generate PLL reset based on various conditions
	assign pll_reset = pll_stop | ~dcm_locked | clk_reset | dcm_status[2]; // Index 2 is valid for [2:1]

	// Main logic clocked by the generated 'clk'
	always @ (posedge clk)
	begin
	    // Input data handling - Capture on rd_clk rising edge (synchronized)
	    // Detect rising edge of rd_clk (synchronized to clk)
		if ( (rd_clk_b[3] == 1'b0 && rd_clk_b[2] == 1'b0 && rd_clk_b[1] == 1'b0 && rd_clk_b[0] == 1'b1) || // Simple edge detect
             (rd_clk_b[3] == 1'b0 && rd_clk_b[2] == 1'b0 && rd_clk_b[1] == 1'b1 && rd_clk_b[0] == 1'b1) || // Glitch filter
             (rd_clk_b[3] == 1'b0 && rd_clk_b[2] == 1'b1 && rd_clk_b[1] == 1'b1 && rd_clk_b[0] == 1'b1) ) // Allow longer pulses
		begin
		    // Shift in the new byte read from read_buf into inbuf_tmp LSBs
		    inbuf_tmp[351:344] <= read_buf;
		    // Shift the rest of the data from the *current* inbuf state
		    inbuf_tmp[343:0] <= inbuf[351:8]; // Corrected: Source is 'inbuf'
		end
		// Update inbuf outside the edge detect, maybe should be inside? Check requirement.
		// Assuming inbuf updates only when new data arrives based on original structure:
		// If the above 'if' condition was met, inbuf_tmp holds the new shifted value.
		// If not, inbuf_tmp holds its previous value (undesired?).
		// Let's change to update inbuf only when read happens:
		/* // Original logic implied this:
		if ( (rd_clk_b[3] == 1'b0 && rd_clk_b[2] == 1'b0 && rd_clk_b[1] == 1'b0 && rd_clk_b[0] == 1'b1) || ... ) begin
		    inbuf <= {read_buf, inbuf[351:8]}; // Direct shift into inbuf
		end
		*/
		// Sticking closer to original structure, assuming inbuf_tmp is intermediate:
		// If read edge detected, update inbuf with the new data assembled in inbuf_tmp
		if ( (rd_clk_b[3] == 1'b0 && rd_clk_b[2] == 1'b0 && rd_clk_b[1] == 1'b0 && rd_clk_b[0] == 1'b1) ||
             (rd_clk_b[3] == 1'b0 && rd_clk_b[2] == 1'b0 && rd_clk_b[1] == 1'b1 && rd_clk_b[0] == 1'b1) ||
             (rd_clk_b[3] == 1'b0 && rd_clk_b[2] == 1'b1 && rd_clk_b[1] == 1'b1 && rd_clk_b[0] == 1'b1) )
        begin
             inbuf <= inbuf_tmp; // Update inbuf only when new data is assembled
        end


		// Write start and delay logic
		// Check if wr_start was high for the previous two cycles (original logic)
		if ( wr_start_b1 && wr_start_b2 )
		begin
   		    wr_delay <= 5'd0; // Reset delay counter
		end else
		begin
		    // Implement shift register for delay - fills with 1s from LSB
		    wr_delay[0] <= 1'b1;
		    wr_delay[4:1] <= wr_delay[3:0];
		end

		// Output data handling
		// If delay is not complete (!wr_delay[4] is true), load results into outbuf
		if ( !wr_delay[4] )
		begin
   		    // Concatenate results from the miner core
   		    outbuf <= { golden_nonce2, hash2, nonce2, golden_nonce1 }; // 32*4 = 128 bits
   		end
   		// If delay is complete (wr_delay[4] is true), shift data out on wr_clk edge
   		else // wr_delay[4] == 1'b1
   		begin
   		    // Detect rising edge of wr_clk (synchronized to clk)
		    if ( (wr_clk_b[3] == 1'b0 && wr_clk_b[2] == 1'b0 && wr_clk_b[1] == 1'b0 && wr_clk_b[0] == 1'b1) || // Simple edge detect
                 (wr_clk_b[3] == 1'b0 && wr_clk_b[2] == 1'b0 && wr_clk_b[1] == 1'b1 && wr_clk_b[0] == 1'b1) || // Glitch filter
                 (wr_clk_b[3] == 1'b0 && wr_clk_b[2] == 1'b1 && wr_clk_b[1] == 1'b1 && wr_clk_b[0] == 1'b1) ) // Allow longer pulses
            begin
			    // Shift outbuf data by 8 bits (upper bits become undefined/shifted out)
			    outbuf[119:0] <= outbuf[127:8];
			end
   		end

   		// Golden nonce update logic
   		if ( reset_buf ) // On reset
   		begin
   		    golden_nonce2 <= 32'd0;
   		    golden_nonce1 <= 32'd0;
   		end
   		// If a new golden nonce is found by the miner core
   		else if ( golden_nonce != golden_nonce1 )
   		begin
   		    golden_nonce2 <= golden_nonce1; // Shift previous nonce
   		    golden_nonce1 <= golden_nonce;  // Store new nonce
   		end

		// Latch input data and update output buffer
		read_buf <= read_data; // Renamed from 'read'
		write_buf <= outbuf[7:0]; // Output the least significant byte of outbuf

		// Update synchronizer registers for edge detection
		rd_clk_b[0] <= rd_clk;
		rd_clk_b[3:1] <= rd_clk_b[2:0];

		wr_clk_b[0] <= wr_clk;
		wr_clk_b[3:1] <= wr_clk_b[2:0];

		// Update state for wr_start check
		wr_start_b1 <= wr_start;
		wr_start_b2 <= wr_start_b1;

		// Update reset buffer
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