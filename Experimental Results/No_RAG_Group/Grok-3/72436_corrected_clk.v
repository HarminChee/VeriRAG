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
        output [3:0] status
    );
    wire ifclk_inbuf;
    IBUFG ifclkin_buf (
	.I(ifclk_in),
	.O(ifclk_inbuf) 
    );
    assign ifclk = ifclk_inbuf;
    reg reset_ifclk = 1;
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
    assign DI_ready = !reset_ifclk && FULL_FLAG && if_out & if_out_buf[4] && !resend;
    assign reset_out = reset || reset_ifclk;
    always @ (posedge ifclk_inbuf)
    begin
	reset_ifclk <= reset;
        if ( reset_ifclk )
        begin
	    SLWR <= 1'b1;
	    if_out <= DI_enable;  
	    resend <= 1'b0;
	    SLRD_buf <= 1'b1;
	    if_out_buf = {5{!DI_enable}};
	end else if ( FULL_FLAG && if_out && if_out_buf[4] && ( resend || DI_valid) )  	
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
        if ( reset_ifclk || DI_valid )
        begin
    	    pktend_req <= 1'b0;
    	    pktend_en <= !reset_ifclk;
    	    pktend_cnt <= 32'd0;
    	    PKTEND <= 1'b1;
    	end else 
    	begin
    	    pktend_req <= pktend_req || ( pktend_en && (pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]) );
    	    pktend_cnt <= pktend_cnt + 1;
    	    if ( pktend_req && if_out && if_out_buf[4] )
    	    begin
    		PKTEND <= 1'b0;
    		pktend_req <= 1'b0;
    		pktend_en <= 1'b0;
    	    end else 
    	    begin
    		PKTEND <= 1'b1;
    		pktend_req <= pktend_req || ( pktend_en && (pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]) );
    	    end
    	end
    end
endmodule