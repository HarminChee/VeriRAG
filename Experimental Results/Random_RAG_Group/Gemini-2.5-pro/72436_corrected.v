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
        input wire test_mode, // DFT input
        input wire test_clk,  // DFT input
        input wire test_reset // DFT input (active high)
    );
    wire ifclk_inbuf, ifclk_fbin, ifclk_fbout, ifclk_out, locked;
    wire dft_clk;
    wire mmcm_reset;
    wire dft_reset_condition;

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

    assign mmcm_reset = test_mode ? test_reset : reset; // MUX for MMCM reset

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
       .RST(mmcm_reset), // Use multiplexed reset
       .CLKFBIN(ifclk_fbin),
       .LOCKED(locked)
    );

    // DFT Clock MUX: Use test_clk in test_mode, otherwise functional ifclk
    assign dft_clk = test_mode ? test_clk : ifclk;

    // DFT Reset Condition MUX: Use test_reset in test_mode, otherwise functional reset condition
    assign dft_reset_condition = test_mode ? test_reset : (reset || !locked);

    // reg reset_ifclk = 1; // Removed, replaced by dft_reset_condition wire
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
    assign DI_ready = !dft_reset_condition && FULL_FLAG && if_out & if_out_buf[4] && !resend; // Use dft_reset_condition
    assign reset_out = reset || !locked; // Functional reset out based on original logic (or could be just 'reset')

    always @ (posedge dft_clk) // Use multiplexed DFT clock
    begin
	// reset_ifclk <= reset || !locked; // Removed
        if ( dft_reset_condition ) // Use multiplexed DFT reset condition
        begin
	    SLWR <= 1'b1;
	    if_out <= DI_enable;  // Reset state might need review based on actual requirements
	    resend <= 1'b0;
	    SLRD_buf <= 1'b1;
	    if_out_buf <= {5{!DI_enable}}; // Reset state might need review
        DO <= 16'b0;
        DO_valid <= 1'b0;
        pktend_req <= 1'b0;
        pktend_en <= 1'b0; // Initialize pktend_en low in reset
        pktend_cnt <= 32'd0;
        PKTEND <= 1'b1;
        fd_buf <= 16'b0;
	end else 
    begin 
        // Non-reset synchronous logic
        pktend_en <= 1'b1; // Enable pktend logic outside reset (original logic implicitly did this via !reset_ifclk)

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
        
        // Pktend logic section
        // if ( DI_valid ) // Original logic reset pktend on DI_valid - keep this?
        // begin
    	//     pktend_req <= 1'b0;
    	//     pktend_en <= 1'b1; // Already set above
    	//     pktend_cnt <= 32'd0;
    	//     PKTEND <= 1'b1;
    	// end else 
    	// begin // This else corresponds to the removed DI_valid check
            // Update pktend_req based on timeout condition
            pktend_req <= pktend_req || ( pktend_en && (pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]) );
            
            // Increment counter only if enabled and timeout is configured
            if (pktend_en && (pktend_timeout != 16'd0)) begin
                pktend_cnt <= pktend_cnt + 1;
            end

            // Check if PKTEND should be asserted (driven low)
            if ( pktend_req && if_out && if_out_buf[4] )
            begin
        		PKTEND <= 1'b0; // Assert PKTEND
        		pktend_req <= 1'b0; // Clear request
        		pktend_en <= 1'b0; // Disable further counting/requests until next reset/event
            end else 
            begin
        		PKTEND <= 1'b1; // Deassert PKTEND
                // Re-evaluate request in case it wasn't asserted this cycle but condition still met
        		// pktend_req <= pktend_req || ( pktend_en && (pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]) ); // This is redundant with the update above
            end
    	// end // End of removed DI_valid check else
    end // End of non-reset block
    end // End always block
endmodule