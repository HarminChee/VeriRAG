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
        input test_mode // Added DFT test mode input
    );
    wire ifclk_inbuf, ifclk_fbin, ifclk_fbout, ifclk_out, locked;
    wire dft_clk; // DFT clock signal
    wire dft_reset_condition; // DFT reset condition signal

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
        .O(ifclk)
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
       .RST(reset), // MMCM reset connected to primary reset
       .CLKFBIN(ifclk_fbin),
       .LOCKED(locked)
    );

    // DFT clock selection: Use primary input clock during test mode, otherwise use generated clock
    assign dft_clk = test_mode ? ifclk_in : ifclk;

    reg reset_ifclk = 1;
    reg if_out, if_in;
    reg [4:0] if_out_buf;
    reg [15:0] fd_buf;
    reg resend;
    reg SLRD_buf, pktend_req, pktend_en;
    reg [31:0] pktend_cnt;

    // DFT reset condition selection: Use primary reset during test mode, otherwise use internal condition
    assign dft_reset_condition = test_mode ? reset : reset_ifclk;

    assign SLOE = if_out;
    assign FIFOADDR = if_out ? OUTEP/2-1 : INEP/2-1;
    assign fd = if_out ? fd_buf : {16{1'bz}};
    assign SLRD = SLRD_buf || !DO_ready;
    assign status = { !SLRD_buf, !SLWR, resend, if_out };
    assign DI_ready = !reset_ifclk && FULL_FLAG && if_out & if_out_buf[4] && !resend; // DI_ready logic depends on internal reset_ifclk state
    assign reset_out = reset || reset_ifclk; // Output reset depends on internal reset_ifclk state

    // Changed sensitivity list to use dft_clk
    always @ (posedge dft_clk)
    begin
        // Internal reset generation logic remains, driven by primary reset and MMCM locked status
	reset_ifclk <= reset || !locked;

        // Changed reset condition check to use dft_reset_condition
        if ( dft_reset_condition )
        begin
	    SLWR <= 1'b1;
	    if_out <= DI_enable;
	    resend <= 1'b0;
	    SLRD_buf <= 1'b1;
	    if_out_buf = {5{!DI_enable}};
            // Reset pktend logic as well
            pktend_req <= 1'b0;
            pktend_en <= 1'b0; // Don't enable pktend counter in reset
            pktend_cnt <= 32'd0;
            PKTEND <= 1'b1;
            DO_valid <= 1'b0; // Ensure DO_valid is deasserted in reset
            DO <= 16'd0; // Optional: Reset DO value
	end else // Normal operation
	begin
	    // Existing logic using internal reset_ifclk for DI_ready etc. is maintained for functional mode
	    // but the primary reset path for FFs uses dft_reset_condition
            if ( FULL_FLAG && if_out && if_out_buf[4] && ( resend || DI_valid) )
            begin
                SLWR <= 1'b0;
                SLRD_buf <= 1'b1;
                resend <= 1'b0;
                if ( !resend ) fd_buf <= DI;
            end else if ( EMPTY_FLAG && !if_out && !if_out_buf[4] && DO_ready )
            begin
                SLWR <= 1'b1;
                DO <= fd;
                SLRD_buf <= 1'b0;
            end else if (if_out == if_out_buf[4])
            begin
                if ( !SLWR && !FULL_FLAG ) resend <= 1'b1;
                SLRD_buf <= 1'b1;
                SLWR <= 1'b1;
                if_out <= DI_enable && (!DO_ready || !EMPTY_FLAG);
            end

            if_out_buf <= { if_out_buf[3:0], if_out };
            if ( DO_ready ) DO_valid <= !if_out && !if_out_buf[4] && EMPTY_FLAG && !SLRD_buf;
            else DO_valid <= 1'b0; // Deassert if DO_ready is low

            // Packet End Logic - Needs careful check relative to reset condition
            if ( DI_valid ) // Reset pktend logic on new DI_valid, not just on main reset
            begin
                pktend_req <= 1'b0;
                pktend_en <= 1'b1; // Enable counter when DI becomes valid (outside reset)
                pktend_cnt <= 32'd0;
                PKTEND <= 1'b1;
            end else
            begin
                if (pktend_en) begin // Only increment and check if enabled
                   pktend_cnt <= pktend_cnt + 1;
                   // Check timeout condition (ensure pktend_timeout is not zero)
                   if ( (pktend_timeout != 16'd0) && (pktend_cnt[31:16] == pktend_timeout) ) begin
                       pktend_req <= 1'b1; // Request pktend assertion
                   end
                end

                if ( pktend_req && if_out && if_out_buf[4] && SLWR == 1'b1 ) // Assert PKTEND when requested, in output mode, stable, and not writing
                begin
                    PKTEND <= 1'b0; // Assert PKTEND low
                    pktend_req <= 1'b0; // Clear request
                    pktend_en <= 1'b0; // Disable counter until next DI_valid
                end else
                begin
                    PKTEND <= 1'b1; // Keep PKTEND high otherwise
                    // Re-check timeout condition in case it was missed due to other conditions
                    if ( pktend_en && (pktend_timeout != 16'd0) && (pktend_cnt[31:16] == pktend_timeout) ) begin
                         pktend_req <= 1'b1;
                    end
                end
            end
	end // end normal operation
    end // end always block
endmodule