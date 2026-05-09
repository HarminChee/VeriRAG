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
    input test_i
);
    wire ifclk_inbuf, ifclk_fbin, ifclk_fbout, ifclk_out, locked;
    wire dft_ifclk, dft_locked;

    IBUFG ifclkin_buf (
        .I(ifclk_in),
        .O(ifclk_inbuf)
    );

    BUFG ifclk_fb_buf (
        .I(ifclk_fbout),
        .O(ifclk_fbin)
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
    ) isclk_mmcm_inst (
       .CLKOUT0(ifclk_out),
       .CLKFBOUT(ifclk_fbout),
       .CLKIN1(ifclk_inbuf),
       .PWRDWN(1'b0),
       .RST(reset),
       .CLKFBIN(ifclk_fbin),
       .LOCKED(locked)
    );

    assign dft_locked = test_i ? 1'b1 : locked;
    assign dft_ifclk = test_i ? ifclk_inbuf : ifclk_out;

    BUFG ifclk_out_buf (
        .I(dft_ifclk),
        .O(ifclk)
    );

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

    always @ (posedge ifclk)
    begin
        reset_ifclk <= reset || !dft_locked;
        if ( reset_ifclk )
        begin
            SLWR <= 1'b1;
            if_out <= DI_enable;
            resend <= 1'b0;
            SLRD_buf <= 1'b1;
            if_out_buf <= {5{!DI_enable}};
        end
        else if ( FULL_FLAG && if_out && if_out_buf[4] && ( resend || DI_valid) )
        begin
            SLWR <= 1'b0;
            SLRD_buf <= 1'b1;
            resend <= 1'b0;
            if ( !resend ) fd_buf <= DI;
        end
        else if ( EMPTY_FLAG && !if_out && !if_out_buf[4] && DO_ready )
        begin
            SLWR <= 1'b1;
            DO <= fd;
            SLRD_buf <= 1'b0;
        end
        else if (if_out == if_out_buf[4])
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
        end
        else
        begin
            pktend_req <= pktend_req || ( pktend_en && (pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]) );
            pktend_cnt <= pktend_cnt + 1;
            if ( pktend_req && if_out && if_out_buf[4] )
            begin
                PKTEND <= 1'b0;
                pktend_req <= 1'b0;
                pktend_en <= 1'b0;
            end
            else
            begin
                PKTEND <= 1'b1;
                pktend_req <= pktend_req || ( pktend_en && (pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]) );
            end
        end
    end
endmodule