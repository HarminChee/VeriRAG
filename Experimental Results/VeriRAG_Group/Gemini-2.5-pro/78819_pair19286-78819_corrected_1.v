module ezusb_io #(
	parameter OUTEP = 2,
	parameter INEP = 6
    ) (
        output ifclk,
        input reset,
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
        output [3:0] status,
        // DFT Inputs
        input scan_clk,
        input scan_en // Test mode signal
    );
    wire ifclk_inbuf, ifclk_fbin, ifclk_fbout, ifclk_out, locked;
    wire func_clk; // Functional clock from MMCM
    wire dft_clk;  // Muxed clock for FFs

    // DFT Clock Mux
    assign dft_clk = scan_en ? scan_clk : func_clk;

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
        .O(func_clk) // Drive internal functional clock wire
     );
    assign ifclk = func_clk; // Assign to output port

    MMCME2_BASE #(
       .BANDWIDTH("OPTIMIZED"),
       .CLKFBOUT_MULT_F(20.0),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(0.0), // Set appropriately if known, 0.0 allows synthesis tool inference
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
       .STARTUP_WAIT("FALSE") // Set to TRUE if startup stability is needed before LOCKED asserts
    )  isclk_mmcm_inst (
       .CLKOUT0(ifclk_out),
       .CLKOUT1(), // Unused outputs
       .CLKOUT2(),
       .CLKOUT3(),
       .CLKOUT4(),
       .CLKOUT5(),
       .CLKOUT0B(),
       .CLKOUT1B(),
       .CLKOUT2B(),
       .CLKOUT3B(),
       .CLKFBOUT(ifclk_fbout),
       .CLKFBOUTB(),
       .CLKFBSTOPPED(),
       .CLKINSTOPPED(),
       .CLKIN1(ifclk_inbuf),
       .CLKIN2(1'b0), // Unused clock input
       .CLKINSEL(1'b1), // Select CLKIN1
       .DADDR(7'b0), // Dynamic reconfig ports - tie off if unused
       .DCLK(1'b0),
       .DEN(1'b0),
       .DI(16'b0),
       .DWE(1'b0),
       .DRDY(),
       .DO(),
       .PSCLK(1'b0), // Phase shift ports - tie off if unused
       .PSEN(1'b0),
       .PSINCDEC(1'b0),
       .PSDONE(),
       .PWRDWN(1'b0),
       .RST(reset), // Use primary reset
       .CLKFBIN(ifclk_fbin),
       .LOCKED(locked)
    );

    reg reset_ifclk = 1;
    reg if_out;
    reg [4:0] if_out_buf;
    reg [15:0] fd_buf;
    reg resend;
    reg SLRD_buf, pktend_req, pktend_en;
    reg [31:0] pktend_cnt;
    wire [15:0] fd_read_data; // Internal wire to read fd

    assign SLOE = if_out;
    assign FIFOADDR = if_out ? OUTEP/2-1 : INEP/2-1;
    assign fd = if_out ? fd_buf : 16'hZZZZ; // Use ZZZZ for tristate
    assign fd_read_data = fd; // Assign inout to internal wire for reading
    assign SLRD = SLRD_buf || !DO_ready;
    assign status = { !SLRD_buf, !SLWR, resend, if_out };
    assign DI_ready = !reset_ifclk && FULL_FLAG && if_out && if_out_buf[4] && !resend;
    assign reset_out = reset || reset_ifclk; // Combine primary reset and internal reset

    always @ (posedge dft_clk) // Use muxed clock
    begin
	reset_ifclk <= reset || !locked; // This FF is now clocked by dft_clk

        if ( reset_ifclk )
        begin
	    SLWR <= 1'b1;
	    if_out <= DI_enable;
	    resend <= 1'b0;
	    SLRD_buf <= 1'b1;
	    if_out_buf <= {5{!DI_enable}}; // Non-blocking assignment
            // Pktend reset logic
    	    pktend_req <= 1'b0;
    	    pktend_en <= 1'b1; // Enable counter after reset (or based on DI_enable?) Let's assume start enabled.
    	    pktend_cnt <= 32'd0;
    	    PKTEND <= 1'b1; // Deassert PKTEND (active low)
            DO <= 16'b0; // Reset output data
            DO_valid <= 1'b0; // Reset output valid
        end else begin // Non-reset operation
            // Main state logic
    	    if ( FULL_FLAG && if_out && if_out_buf[4] && ( resend || DI_valid) )
	    begin
	        SLWR <= 1'b0; // Start write
	        SLRD_buf <= 1'b1; // Stop read
	        resend <= 1'b0;
	        if ( !resend ) fd_buf <= DI; // Latch input data
	    end else if ( EMPTY_FLAG && !if_out && !if_out_buf[4] && DO_ready )
	    begin
	        SLWR <= 1'b1; // Stop write
	        DO <= fd_read_data; // Output data read from fd
	        SLRD_buf <= 1'b0; // Start read
	    end else if (if_out == if_out_buf[4]) // Stable state condition
	    begin
	        if ( !SLWR && !FULL_FLAG ) resend <= 1'b1; // If write was active (!SLWR) but FIFO became not full, need resend
	        SLRD_buf <= 1'b1; // Stop read
	        SLWR <= 1'b1; // Stop write
	        if_out <= DI_enable && (!DO_ready || !EMPTY_FLAG); // Decide next direction based on DI_enable and downstream status
	    end
            // Implicitly hold register values if none of the above conditions are met

	    // Update shift register unconditionally outside reset
            if_out_buf <= { if_out_buf[3:0], if_out };

            // Update DO_valid outside reset
            // Assert DO_valid when data is read from FIFO and downstream is ready
            if ( DO_ready ) DO_valid <= !if_out && !if_out_buf[4] && EMPTY_FLAG && !SLRD_buf;
            else DO_valid <= 1'b0; // Deassert if downstream not ready


            // Pktend logic update section
            if ( DI_valid && if_out && !resend ) // Reset pktend state/counter on NEW DI_valid when writing
            begin
                pktend_req <= 1'b0;
                pktend_en <= 1'b1; // Re-enable counting
                pktend_cnt <= 32'd0;
                PKTEND <= 1'b1; // Default: De-assert PKTEND
            end else // Normal pktend counting and triggering
            begin
                logic pktend_timeout_match;
                // Check timeout condition only if enabled and timeout value is non-zero
                pktend_timeout_match = pktend_en && (pktend_timeout != 16'd0) && (pktend_cnt[31:16] == pktend_timeout);

                // Update request flag if timeout matches (make it sticky until cleared)
                if (pktend_timeout_match) begin
                    pktend_req <= 1'b1;
                    pktend_en <= 1'b0; // Disable counter once timeout is reached
                end

                // Increment counter only if enabled and we are in output mode
                if (pktend_en && if_out) begin
                    pktend_cnt <= pktend_cnt + 1;
                end

                // Control PKTEND signal (active low pulse)
                if (pktend_req && SLWR) begin // Condition to start asserting PKTEND low (when idle/ready to send pktend)
                    PKTEND <= 1'b0;
                    pktend_req <= 1'b0; // Clear request now that PKTEND is asserted
                end else begin // Condition to de-assert PKTEND high
                    PKTEND <= 1'b1;
                end
            end
        end
    end

endmodule