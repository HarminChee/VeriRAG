module ezusb_io_corrected_clk #(
	parameter OUTEP = 2,
	parameter INEP = 6
    ) (
        output ifclk,
        input reset,
        output reset_out,
        input ifclk_in,
        // DFT Ports
        input test_clk,          // Test clock input
        input test_mode,         // Test mode enable

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
    wire ifclk_inbuf, ifclk_fbin, ifclk_fbout, ifclk_out, locked;
    wire func_clk; // Functional clock from MMCM
    wire dft_clk;  // Clock used by the sequential logic (muxed)
    wire dft_reset; // Reset used by the sequential logic (muxed)

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
       .RST(reset), // Use primary reset for MMCM reset
       .CLKFBIN(ifclk_fbin),
       .LOCKED(locked)
    );

    // DFT Clock Mux: Selects test_clk in test_mode, otherwise functional clock
    // Note: Use vendor-specific clock mux for synthesis (e.g., BUFGMUX)
    assign dft_clk = test_mode ? test_clk : func_clk;

    // Assign functional clock to output port if needed (may need buffering)
    assign ifclk = func_clk;

    // DFT Reset Logic: Use primary reset in test_mode, combine with !locked in functional mode
    assign dft_reset = test_mode ? reset : (reset || !locked);

    reg reset_ifclk = 1; // Internal reset signal driven by dft_reset
    reg if_out, if_in;
    reg [4:0] if_out_buf;
    reg [15:0] fd_buf;
    reg resend;
    reg SLRD_buf, pktend_req, pktend_en;
    reg [31:0] pktend_cnt;

    assign SLOE = if_out;
    assign FIFOADDR = if_out ? OUTEP/2-1 : INEP/2-1;
    assign fd = if_out ? fd_buf : {16{1'bz}};
    assign SLRD = SLRD_buf || !DO_ready;
    assign status = { !SLRD_buf, !SLWR, resend, if_out };
    // DI_ready depends on internal reset state reset_ifclk
    assign DI_ready = !reset_ifclk && FULL_FLAG && if_out & if_out_buf[4] && !resend;
    // reset_out reflects the actual reset used by the core logic
    assign reset_out = reset_ifclk;

    // Use the muxed clock 'dft_clk' for the sequential logic
    always @ (posedge dft_clk)
    begin
        // Drive internal reset flop using the combined dft_reset
	reset_ifclk <= dft_reset;

        // Use the flopped internal reset 'reset_ifclk' for synchronous logic reset
        if ( reset_ifclk )
        begin
	    SLWR <= 1'b1;
	    if_out <= DI_enable;
	    resend <= 1'b0;
	    SLRD_buf <= 1'b1;
	    if_out_buf <= {5{!DI_enable}}; // Use correct reset value
            DO <= 16'b0; // Reset output data
            DO_valid <= 1'b0; // Reset output valid
            pktend_req <= 1'b0;
            pktend_en <= 1'b0; // Correct reset value for pktend_en
            pktend_cnt <= 32'd0;
            PKTEND <= 1'b1;
	end else // Non-reset behavior
        begin
	    // Existing logic clocked by dft_clk
            if ( FULL_FLAG && if_out && if_out_buf[4] && ( resend || DI_valid) )
            begin
                SLWR <= 1'b0;
                SLRD_buf <= 1'b1;
                resend <= 1'b0;
                if ( !resend ) fd_buf <= DI;
            end else if ( EMPTY_FLAG && !if_out && !if_out_buf[4] && DO_ready )
            begin
                SLWR <= 1'b1;
                DO <= fd; // Data is driven out here
                SLRD_buf <= 1'b0;
            end else if (if_out == if_out_buf[4])
            begin
                if ( !SLWR && !FULL_FLAG ) resend <= 1'b1;
                SLRD_buf <= 1'b1;
                SLWR <= 1'b1;
                if_out <= DI_enable && (!DO_ready || !EMPTY_FLAG);
            end

            if_out_buf <= { if_out_buf[3:0], if_out };

            // DO_valid logic
            if ( DO_ready ) begin
                 DO_valid <= !if_out && !if_out_buf[4] && EMPTY_FLAG && !SLRD_buf;
            end else begin
                 DO_valid <= DO_valid && !reset_ifclk; // Deassert if not ready or reset
            end

            // PKTEND logic - check reset condition first within the non-reset block is redundant
            // Reset handled by the main if(reset_ifclk)
            if ( DI_valid ) // Reset condition for pktend section if DI becomes valid
            begin
                pktend_req <= 1'b0;
                pktend_en <= !reset_ifclk; // Should be enabled only when not in reset
                pktend_cnt <= 32'd0;
                PKTEND <= 1'b1;
            end else
            begin
                // Update pktend_cnt only when enabled
                if (pktend_en) begin
                    pktend_cnt <= pktend_cnt + 1;
                    pktend_req <= pktend_req || ((pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]));
                end else begin
                     pktend_cnt <= pktend_cnt; // Hold value if not enabled
                end


                if ( pktend_req && if_out && if_out_buf[4] )
                begin
                    PKTEND <= 1'b0;
                    pktend_req <= 1'b0;
                    pktend_en <= 1'b0;
                end else
                begin
                    PKTEND <= 1'b1;
                    // Update pktend_req again? Redundant if already done above based on pktend_en
                    // Let's assume the intent is to check condition regardless of pktend_en state for this assignment
                    // However, typically req would only be set if enabled. Let's refine:
                    // pktend_req <= pktend_req || ( pktend_en && (pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]) );
                    // This line seems redundant based on the update within if(pktend_en) block above. Removing redundant update.
                end
            end // end else DI_valid
	end // end else not reset_ifclk
    end // end always
endmodule