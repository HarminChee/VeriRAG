module ezusb_io #(
    parameter OUTEP = 2,
    parameter INEP = 6
) (
    input  wire test_i,
    output wire ifclk,
    input  wire reset,
    output wire reset_out,
    input  wire ifclk_in,
    inout  wire [15:0] fd,
    output reg  SLWR,
    output reg  PKTEND,
    output wire SLRD,
    output wire SLOE,
    output wire [1:0] FIFOADDR,
    input  wire EMPTY_FLAG,
    input  wire FULL_FLAG,
    input  wire [15:0] DI,
    input  wire DI_valid,
    output wire DI_ready,
    input  wire DI_enable,
    input  wire [15:0] pktend_timeout,
    output reg  [15:0] DO,
    output reg  DO_valid,
    input  wire DO_ready,
    output wire [3:0] status
);

assign ifclk     = ifclk_in;
assign reset_out = reset;

reg reset_ifclk_reg;
wire reset_ifclk = reset_ifclk_reg;

assign DI_ready = !reset_ifclk && FULL_FLAG && (SLOE) && !SLWR;

assign SLRD     = (SLOE == 1'b0) || !DO_ready;
assign SLOE     = if_out;
assign FIFOADDR = if_out ? (OUTEP/2 - 1) : (INEP/2 - 1);
assign fd       = if_out ? fd_buf : 16'bz;
assign status   = { !SLRD_buf, !SLWR, resend, if_out };

reg if_out;
reg [4:0] if_out_buf;
reg [15:0] fd_buf;
reg resend;
reg SLRD_buf, pktend_req, pktend_en;
reg [31:0] pktend_cnt;

always @(posedge ifclk) begin
    if(!reset) begin
        reset_ifclk_reg <= 1'b1;
        SLWR            <= 1'b1;
        if_out          <= DI_enable;
        resend          <= 1'b0;
        SLRD_buf        <= 1'b1;
        if_out_buf      <= {5{!DI_enable}};
        DO              <= 16'b0;
        DO_valid        <= 1'b0;
        pktend_req      <= 1'b0;
        pktend_en       <= 1'b0;
        pktend_cnt      <= 32'd0;
        PKTEND          <= 1'b1;
    end else begin
        reset_ifclk_reg <= 1'b0;

        if(reset_ifclk_reg) begin
            SLWR       <= 1'b1;
            if_out     <= DI_enable;
            resend     <= 1'b0;
            SLRD_buf   <= 1'b1;
            if_out_buf <= {5{!DI_enable}};
            DO         <= 16'b0;
            DO_valid   <= 1'b0;
            pktend_req <= 1'b0;
            pktend_en  <= 1'b0;
            pktend_cnt <= 32'd0;
            PKTEND     <= 1'b1;
        end else begin
            if(FULL_FLAG && if_out && if_out_buf[4] && (resend || DI_valid)) begin
                SLWR     <= 1'b0;
                SLRD_buf <= 1'b1;
                resend   <= 1'b0;
                if(!resend) fd_buf <= DI;
            end else if(EMPTY_FLAG && !if_out && !if_out_buf[4] && DO_ready) begin
                SLWR     <= 1'b1;
                DO       <= fd;
                SLRD_buf <= 1'b0;
            end else if(if_out == if_out_buf[4]) begin
                if(!SLWR && !FULL_FLAG) resend <= 1'b1;
                SLRD_buf <= 1'b1;
                SLWR     <= 1'b1;
                if_out   <= DI_enable && (!DO_ready || !EMPTY_FLAG);
            end

            if_out_buf <= {if_out_buf[3:0], if_out};
            if(DO_ready) DO_valid <= (!if_out && !if_out_buf[4] && EMPTY_FLAG && !SLRD_buf);

            if(pktend_en && (pktend_timeout != 16'd0) && (pktend_timeout == pktend_cnt[31:16]))
                pktend_req <= 1'b1;
            pktend_cnt <= pktend_cnt + 1;

            if(reset_ifclk_reg || DI_valid) begin
                pktend_req <= 1'b0;
                pktend_en  <= !reset_ifclk_reg;
                pktend_cnt <= 32'd0;
                PKTEND     <= 1'b1;
            end else begin
                if(pktend_req && if_out && if_out_buf[4]) begin
                    PKTEND     <= 1'b0;
                    pktend_req <= 1'b0;
                    pktend_en  <= 1'b0;
                end else begin
                    PKTEND <= 1'b1;
                end
            end
        end
    end
end

endmodule