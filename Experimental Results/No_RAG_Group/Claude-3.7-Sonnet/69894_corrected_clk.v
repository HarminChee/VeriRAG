module ztex_ufm1_15d4 (
    input fxclk_in,
    input reset,
    input clk_reset,
    input pll_stop,
    input dcm_progclk,
    input dcm_progdata, 
    input dcm_progen,
    input rd_clk,
    input wr_clk,
    input wr_start,
    input [7:0] read,
    output [7:0] write
);

    reg [3:0] rd_clk_b, wr_clk_b;
    reg wr_start_b1, wr_start_b2, reset_buf;
    reg dcm_progclk_buf, dcm_progdata_buf, dcm_progen_buf;
    reg [4:0] wr_delay;
    reg [351:0] inbuf, inbuf_tmp;
    reg [127:0] outbuf;
    reg [7:0] read_buf, write_buf;
    reg [31:0] golden_nonce1, golden_nonce2;

    wire fxclk;
    wire dcm_locked;
    wire [2:1] dcm_status;
    wire [31:0] golden_nonce, nonce2, hash2;
    wire pll_reset;

    // Primary clock input buffer
    BUFG bufg_fxclk (
        .I(fxclk_in),
        .O(fxclk)
    );

    // Main clock generation using single DCM
    wire main_clk;
    DCM_CLKGEN #(
        .CLKFX_DIVIDE(4.0),
        .CLKFX_MULTIPLY(32),
        .CLKFXDV_DIVIDE(2),
        .CLKIN_PERIOD(20.8333)
    ) dcm0 (
        .CLKIN(fxclk),
        .CLKFXDV(main_clk),
        .FREEZEDCM(1'b0),
        .PROGCLK(dcm_progclk_buf),
        .PROGDATA(dcm_progdata_buf),
        .PROGEN(dcm_progen_buf),
        .LOCKED(dcm_locked),
        .STATUS(dcm_status),
        .RST(clk_reset)
    );

    // Buffer for main clock
    wire clk;
    BUFG bufg_main_clk (
        .I(main_clk),
        .O(clk)
    );

    miner253 m (
        .clk(clk),
        .reset(reset_buf),
        .midstate(inbuf[351:96]),
        .data(inbuf[95:0]),
        .golden_nonce(golden_nonce),
        .nonce2(nonce2),
        .hash2(hash2)
    );

    assign write = write_buf;
    assign pll_reset = pll_stop | ~dcm_locked | clk_reset | dcm_status[2];

    always @(posedge clk) begin
        if ((rd_clk_b[3] == rd_clk_b[2]) && (rd_clk_b[2] == rd_clk_b[1]) && (rd_clk_b[1] != rd_clk_b[0])) begin
            inbuf_tmp[351:344] <= read_buf;
            inbuf_tmp[343:0] <= inbuf_tmp[351:8];
        end
        inbuf <= inbuf_tmp;

        if (wr_start_b1 && wr_start_b2) begin
            wr_delay <= 5'd0;
        end else begin
            wr_delay[0] <= 1'b1;
            wr_delay[4:1] <= wr_delay[3:0];
        end

        if (!wr_delay[4]) begin
            outbuf <= {golden_nonce2, hash2, nonce2, golden_nonce1};
        end else begin
            if ((wr_clk_b[3] == wr_clk_b[2]) && (wr_clk_b[2] == wr_clk_b[1]) && (wr_clk_b[1] != wr_clk_b[0]))
                outbuf[119:0] <= outbuf[127:8];
        end

        if (reset_buf) begin
            golden_nonce2 <= 32'd0;
            golden_nonce1 <= 32'd0;
        end else if (golden_nonce != golden_nonce1) begin
            golden_nonce2 <= golden_nonce1;
            golden_nonce1 <= golden_nonce;
        end

        read_buf <= read;
        write_buf <= outbuf[7:0];
        rd_clk_b[0] <= rd_clk;
        rd_clk_b[3:1] <= rd_clk_b[2:0];
        wr_clk_b[0] <= wr_clk;
        wr_clk_b[3:1] <= wr_clk_b[2:0];
        wr_start_b1 <= wr_start;
        wr_start_b2 <= wr_start_b1;
        reset_buf <= reset;
    end

    always @(posedge fxclk) begin
        dcm_progclk_buf <= dcm_progclk;
        dcm_progdata_buf <= dcm_progdata;
        dcm_progen_buf <= dcm_progen;
    end

endmodule