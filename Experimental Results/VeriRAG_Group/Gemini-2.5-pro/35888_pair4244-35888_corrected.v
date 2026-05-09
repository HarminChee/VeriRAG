`timescale 1ns/1ns
`timescale 1ns/1ns
module sequencer (test_i, reset, rtcal_expired, oscclk, m, dr, docrc, trext, trcal,
                  databitsrc, datadone, dataclk, modout, txsetupdone, txdone);
input test_i;
input reset, rtcal_expired, trext, dr, docrc, databitsrc, datadone, oscclk;
input [9:0] trcal;
input [1:0] m;
output dataclk, modout, txsetupdone, txdone;
reg done;
reg tx_stop;
wire txsetupdone, txdone;
wire txclk, txbitclk;
wire violation;
wire crcdone, preambledone;
wire crcinclk, crcbitin;
wire txbitsrc, crcbitsrc, preamblebitsrc;
wire crcoutclk, preambleclk, dataclk;
wire dft_txbitclk, dft_crcinclk, dft_preambleclk; // DFT clock signals

txclkdivide U_DIV (reset, oscclk, trcal, dr, txclk);
tx          U_TX0 (reset, rtcal_expired, tx_stop,
                   txclk, txbitsrc, violation, m,
                   modout, txbitclk, txsetupdone, txdone);
preamble    U_PRE (reset, dft_preambleclk, m, trext, preamblebitsrc, violation, preambledone); // Use DFT clock
crc16       U_CRC (reset, dft_crcinclk, crcbitin, crcoutclk, crcbitsrc, crcdone); // Use DFT clock
reg [1:0] state;
parameter STATE_PRE  = 2'd0;
parameter STATE_DATA = 2'd1;
parameter STATE_CRC  = 2'd2;
parameter STATE_END  = 2'd3;
wire [3:0] bitsrc;
assign bitsrc[0] = preamblebitsrc;
assign bitsrc[1] = databitsrc;
assign bitsrc[2] = crcbitsrc;
assign bitsrc[3] = 1;
assign txbitsrc  = bitsrc[state];
reg bit_transition;
assign crcbitin  = databitsrc;

// Original gated clock logic (used for functional mode)
assign crcinclk  = txbitclk & (state == STATE_DATA) & docrc;
assign preambleclk = txbitclk  && (state == STATE_PRE) && (!done);

// DFT clock muxing: Use oscclk during test_i, otherwise use functional clock
assign dft_txbitclk = test_i ? oscclk : txbitclk;
assign dft_crcinclk = test_i ? oscclk : crcinclk;
assign dft_preambleclk = test_i ? oscclk : preambleclk;

// Muxed dataclk output
assign dataclk = test_i ? oscclk : (txbitclk && (state == STATE_DATA ||(state == STATE_PRE && bit_transition && !done)));

// Remove conflicting assignment if crcoutclk is an output of U_CRC
// assign crcoutclk = txbitclk && (state == STATE_CRC);

// State machine logic clocked by DFT-muxed clock
always @ (negedge dft_txbitclk or posedge reset) begin // Use DFT clock
  if (reset) begin
    state      <= 0;
    done       <= 0;
    bit_transition <= 0;
    tx_stop    <= 0;
  end else if (done) begin
  end else if (state == STATE_PRE) begin
    if (bit_transition) begin
      state      <= STATE_DATA;
      bit_transition <= 0;
    end else if (preambledone) begin
      bit_transition <= 1;
    end
  end else if (state == STATE_DATA) begin
    if (bit_transition) begin
      if (datadone && docrc) state <= STATE_CRC;
      else if (datadone)     state <= STATE_END;
      bit_transition <= 0;
    end else if (datadone) begin
      bit_transition <= 1;
    end
  end else if (state == STATE_CRC) begin
    if (bit_transition) begin
      state      <= STATE_END;
      bit_transition <= 0;
    end else if (crcdone) begin
      bit_transition <= 1;
    end
  end else if (state == STATE_END) begin
    if (txdone) begin
      state <= STATE_PRE;
      done  <= 1;
    end else begin
      tx_stop <= 1;
    end
  end
end
endmodule