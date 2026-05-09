`timescale 1ns/1ns
module sequencer (
    input  wire        test_i,
    input  wire        reset,
    input  wire        rtcal_expired,
    input  wire        oscclk,
    input  wire [1:0]  m,
    input  wire        dr,
    input  wire        docrc,
    input  wire        trext,
    input  wire [9:0]  trcal,
    input  wire        databitsrc,
    input  wire        datadone,
    output wire        dataclk,
    output wire        modout,
    output wire        txsetupdone,
    output wire        txdone
);

reg done;
reg tx_stop;
wire txsetupdone, txdone;
wire txclk, txbitclk;
wire violation;
wire crcdone, preambledone;
wire crcinclk, crcbitin;
wire txbitsrc, crcbitsrc, preamblebitsrc;
wire crcoutclk, preambleclk, dataclk;
wire dft_txclk;

assign dft_txclk = test_i ? oscclk : txclk;

txclkdivide U_DIV (
    .reset(reset),
    .oscclk(oscclk),
    .trcal(trcal),
    .dr(dr),
    .txclk(txclk)
);

tx U_TX0 (
    .reset(reset),
    .rtcal_expired(rtcal_expired),
    .tx_stop(tx_stop),
    .txclk(dft_txclk),
    .txbitsrc(txbitsrc),
    .violation(violation),
    .m(m),
    .modout(modout),
    .txbitclk(txbitclk),
    .txsetupdone(txsetupdone),
    .txdone(txdone)
);

preamble U_PRE (
    .reset(reset),
    .preambleclk(preambleclk),
    .m(m),
    .trext(trext),
    .preamblebitsrc(preamblebitsrc),
    .violation(violation),
    .preambledone(preambledone)
);

crc16 U_CRC (
    .reset(reset),
    .crcinclk(crcinclk),
    .crcbitin(crcbitin),
    .crcoutclk(crcoutclk),
    .crcbitsrc(crcbitsrc),
    .crcdone(crcdone)
);

reg [1:0] state;
parameter STATE_PRE  = 2'd0;
parameter STATE_DATA = 2'd1;
parameter STATE_CRC  = 2'd2;
parameter STATE_END  = 2'd3;

wire [3:0] bitsrc;
assign bitsrc[0] = preamblebitsrc;
assign bitsrc[1] = databitsrc;
assign bitsrc[2] = crcbitsrc;
assign bitsrc[3] = 1'b1;
assign txbitsrc  = bitsrc[state];

reg bit_transition;
assign crcbitin   = databitsrc;
assign crcinclk   = txbitclk & (state == STATE_DATA) & docrc;
assign preambleclk = txbitclk & (state == STATE_PRE) & (~done);
assign dataclk    = txbitclk & (state == STATE_DATA | (state == STATE_PRE & bit_transition & ~done));
assign crcoutclk  = txbitclk & (state == STATE_CRC);

always @ (negedge txbitclk or posedge reset) begin
    if (reset) begin
        state          <= 2'd0;
        done           <= 1'b0;
        bit_transition <= 1'b0;
        tx_stop        <= 1'b0;
    end else if (done) begin
        state          <= 2'd0;
        done           <= 1'b1;
        bit_transition <= 1'b0;
        tx_stop        <= 1'b0;
    end else if (state == STATE_PRE) begin
        if (bit_transition) begin
            state          <= STATE_DATA;
            bit_transition <= 1'b0;
        end else if (preambledone) begin
            bit_transition <= 1'b1;
        end
    end else if (state == STATE_DATA) begin
        if (bit_transition) begin
            if (datadone & docrc) state <= STATE_CRC;
            else if (datadone)    state <= STATE_END;
            bit_transition <= 1'b0;
        end else if (datadone) begin
            bit_transition <= 1'b1;
        end
    end else if (state == STATE_CRC) begin
        if (bit_transition) begin
            state          <= STATE_END;
            bit_transition <= 1'b0;
        end else if (crcdone) begin
            bit_transition <= 1'b1;
        end
    end else if (state == STATE_END) begin
        if (txdone) begin
            state   <= STATE_PRE;
            done    <= 1'b1;
        end else begin
            tx_stop <= 1'b1;
        end
    end 
end

endmodule