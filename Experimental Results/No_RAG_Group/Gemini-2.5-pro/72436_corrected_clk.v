module ezusb_io_corrected_clk #(
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
        input test_mode // Added test_mode input for DFT
    );

    wire ifclk_inbuf, ifclk_fbin, ifclk_fbout, ifclk_out, locked;
    wire clk_mux_out; // Mux output for clock selection
    wire internal_reset; // Internal reset conditioned by test_mode

    IBUFG ifclkin_buf (
	.I(ifclk_in),
	.O(ifclk_inbuf)
    );

    BUFG ifclk_fb_buf (
        .I(ifclk_fbout),
        .O(ifclk_fbin)
     );

    // Clock MUX for DFT: Selects MMCM clock in functional mode, primary clock in test mode
    assign clk_mux_out = test_mode ? ifclk_inbuf : ifclk_out;

    BUFG ifclk_out_buf (
        .I(clk_mux_out), // Driven by the clock mux
        .O(ifclk)
     );

    MMCME2_BASE #(
       .BANDWIDTH("OPTIMIZED"),
       .CLKFBOUT_MULT_F(20.0),
       .CLKFBOUT_PHASE(0.0),
       .CLKIN1_PERIOD(0.0), // Should ideally be set based on actual input clock period
       .CLKOUT0_DIVIDE_F(20.0),
       .CLKOUT1_DIVIDE(1), // Not used
       .CLKOUT2_DIVIDE(1), // Not used
       .CLKOUT3_DIVIDE(1), // Not used
       .CLKOUT4_DIVIDE(1), // Not used
       .CLKOUT5_DIVIDE(1), // Not used
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
       .STARTUP_WAIT("FALSE") // Set to TRUE if MMCM needs startup stabilization time
    )  isclk_mmcm_inst (
       .CLKOUT0(ifclk_out),
       //.CLKOUT1(), .CLKOUT2(), .CLKOUT3(), .CLKOUT4(), .CLKOUT5(), // Unused outputs
       .CLKFBOUT(ifclk_fbout),
       .CLKIN1(ifclk_inbuf),
       .PWRDWN(1'b0), // Consider controllability for test/low power
       .RST(reset), // Use primary reset; ensure it's active high/low as needed
       .CLKFBIN(ifclk_fbin),
       .LOCKED(locked)
       //.DO(), .DRDY() // Unused dynamic reconfiguration ports
    );

    // Internal reset logic conditioned by test_mode
    // In test mode, use primary reset directly.
    // In functional mode, use primary reset ORed with !locked.
    assign internal_reset = test_mode ? reset : (reset || !locked);

    // Internal signals
    reg if_out; // Direction control: 1 for output (DI->FD), 0 for input (FD->DO)
    // reg if_in; // Seems unused
    reg [4:0] if_out_buf; // Pipeline stages for if_out synchronization/delay
    reg [15:0] fd_buf; // Buffer for data being written to FX2 FIFO
    reg resend; // Flag to indicate data needs resending (e.g., if FIFO was full)
    reg SLRD_buf; // Internal buffer for SLRD signal generation
    reg pktend_req; // Internal flag requesting PKTEND assertion
    reg pktend_en; // Enable for PKTEND timeout counter
    reg [31:0] pktend_cnt; // Counter for PKTEND timeout

    // Output assignments
    assign SLOE = if_out; // Slave Output Enable tied to direction
    assign FIFOADDR = if_out ? OUTEP/2-1 : INEP/2-1; // Select EP address based on direction
    assign fd = if_out ? fd_buf : {16{1'bz}}; // Drive fd bus only when outputting data
    assign SLRD = SLRD_buf || !DO_ready; // Assert SLRD (read) when buffer active or downstream not ready
    assign status = { !SLRD_buf, !SLWR, resend, if_out }; // Status bits
    assign DI_ready = !internal_reset && FULL_FLAG && if_out & if_out_buf[4] && !resend; // Ready to accept DI when not reset, FIFO not full, outputting, stable, and not resending
    assign reset_out = internal_reset; // Export the conditioned internal reset

    // Main sequential logic block
    always @ (posedge ifclk)
    begin
        if ( internal_reset ) // Synchronous reset logic
        begin
	    SLWR <= 1'b1; // Deassert SLWR (active low write strobe)
	    if_out <= DI_enable; // Initialize direction based on DI_enable
	    resend <= 1'b0;
	    SLRD_buf <= 1'b1; // Deassert SLRD_buf (active low read strobe buffer)
	    if_out_buf <= {5{DI_enable}}; // Initialize pipeline based on DI_enable
            fd_buf <= 16'd0; // Reset data buffer
            DO <= 16'd0; // Reset output data register
            DO_valid <= 1'b0; // Reset output valid signal
            pktend_req <= 1'b0;
            pktend_en <= 1'b0; // Disable counter during reset
            pktend_cnt <= 32'd0;
            PKTEND <= 1'b1; // Deassert PKTEND (active low packet end strobe)
	end
        else // Functional logic when not in reset
	begin
            // Manage SLWR, SLRD_buf, resend based on FIFO status and data flow
            if ( FULL_FLAG && if_out && if_out_buf[4] && ( resend || DI_valid) ) // Data write cycle (DI -> FD)
            begin
                SLWR <= 1'b0; // Assert SLWR to write to FIFO
                SLRD_buf <= 1'b1; // Keep SLRD deasserted
                resend <= 1'b0; // Clear resend flag as we are attempting write
                if ( !resend ) fd_buf <= DI; // Latch new data if not a resend attempt
            end
            else if ( EMPTY_FLAG && !if_out && !if_out_buf[4] && DO_ready ) // Data read cycle (FD -> DO)
            begin
                SLWR <= 1'b1; // Keep SLWR deasserted
                // DO <= fd; // Combinational read, data appears on fd when SLRD is low
                SLRD_buf <= 1'b0; // Assert SLRD_buf to read from FIFO
            end
            else if (if_out == if_out_buf[4]) // Stable state, check for state changes or resend condition
            begin
                // If we were writing (!SLWR) but FIFO became full, set resend flag
                if ( !SLWR && !FULL_FLAG ) resend <= 1'b1;
                SLRD_buf <= 1'b1; // Deassert SLRD_buf
                SLWR <= 1'b1; // Deassert SLWR
                // Update direction based on DI_enable and downstream/FIFO status
                if_out <= DI_enable && (!DO_ready || !EMPTY_FLAG);
            end
            // Default assignments if no condition met (maintain state)
            // SLWR <= SLWR;
            // SLRD_buf <= SLRD_buf;
            // resend <= resend;

            // Update direction pipeline
            if_out_buf <= { if_out_buf[3:0], if_out };

            // Manage output data valid signal
            // DO_valid is asserted one cycle after SLRD_buf goes low (read starts) if conditions are met
            DO_valid <= !if_out && !if_out_buf[4] && EMPTY_FLAG && !SLRD_buf && DO_ready;

            // Latch data read from FIFO when SLRD was asserted
            if (!SLRD_buf) begin // If SLRD_buf was asserted in the previous cycle (combinational read)
                DO <= fd; // Latch the data currently on fd bus (read from FIFO)
            end

            // PKTEND Timeout Logic
            if (DI_valid) // Reset timeout logic when new valid data arrives
            begin
                pktend_req <= 1'b0;
                pktend_en <= !internal_reset; // Enable counter if not in reset
                pktend_cnt <= 32'd0;
                PKTEND <= 1'b1; // Keep PKTEND deasserted
            end
            else // No new data, manage timeout counter
            begin
                if (pktend_en) // If timeout counting is enabled
                begin
                    pktend_cnt <= pktend_cnt + 1; // Increment counter
                    // Check if timeout value reached
                    if ((pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16])) begin
                       pktend_req <= 1'b1; // Request PKTEND assertion
                    end

                    // Assert PKTEND if requested, in output mode, and direction is stable
                    if ( pktend_req && if_out && if_out_buf[4] )
                    begin
                        PKTEND <= 1'b0; // Assert PKTEND
                        pktend_req <= 1'b0; // Clear request
                        pktend_en <= 1'b0; // Disable counter until next DI_valid
                    end else
                    begin
                         PKTEND <= 1'b1; // Keep PKTEND deasserted
                    end
                end else // If timeout counting is disabled
                begin
                    PKTEND <= 1'b1; // Keep PKTEND deasserted
                    // pktend_cnt remains unchanged
                end
            end // end else (!DI_valid)

	end // end else (!internal_reset)
    end // end always @ (posedge ifclk)

endmodule