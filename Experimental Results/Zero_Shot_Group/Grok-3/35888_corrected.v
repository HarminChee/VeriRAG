`timescale 1ns/1ns
module sequencer (reset, rtcal_expired, oscclk, m, dr, docrc, trext, trcal, 
                  databitsrc, datadone, dataclk, modout, txsetupdone, txdone);
input reset, rtcal_expired, trext, dr, docrc, databitsrc, datadone, oscclk;
input [9:0] trcal;
input [1:0] m;
output dataclk, modout, txsetupdone, txdone;
reg done;
reg tx_stop;
reg dataclk, modout, txsetupdone, txdone;
reg txclk, txbitclk;
reg violation;
reg crcdone, preambledone; 
reg crcinclk, crcbitin;
reg txbitsrc, crcbitsrc, preamblebitsrc; 
reg crcoutclk, preambleclk;
txclkdivide U_DIV (reset, oscclk, trcal, dr, txclk);
tx          U_TX0 (reset, rtcal_expired, tx_stop, 
                   txclk, txbitsrc, violation, m, 
                   modout, txbitclk, txsetupdone, txdone);
preamble    U_PRE (reset, preambleclk, m, trext, preamblebitsrc, violation, preambledone);
crc16       U_CRC (reset, crcinclk, crcbitin, crcoutclk, crcbitsrc, crcdone);
reg [1:0] state;
parameter STATE_PRE  = 2'd0;
parameter STATE_DATA = 2'd1;
parameter STATE_CRC  = 2'd2;
parameter STATE_END  = 2'd3;
reg [3:0] bitsrc;
assign bitsrc[0] = preamblebitsrc;
assign bitsrc[1] = databitsrc;
assign bitsrc[2] = crcbitsrc;
assign bitsrc[3] = 1'b1;
assign txbitsrc  = bitsrc[state];
reg bit_transition;
assign crcbitin  = databitsrc;
assign crcinclk  = txbitclk & (state == STATE_DATA) & docrc;
assign preambleclk = txbitclk & (state == STATE_PRE) & (!done);
assign dataclk = txbitclk & (state == STATE_DATA | (state == STATE_PRE & bit_transition & !done));
assign crcoutclk = txbitclk & (state == STATE_CRC); 
always @ (negedge txbitclk or posedge reset) begin
  if (reset) begin
    state      <= 2'b00;
    done       <= 1'b0;
    bit_transition <= 1'b0;
    tx_stop    <= 1'b0;
  end else if (done) begin
  end else if (state == STATE_PRE) begin
    if (bit_transition) begin
      state      <= STATE_DATA;
      bit_transition <= 1'b0;
    end else if (preambledone) begin
      bit_transition <= 1'b1;
    end
  end else if (state == STATE_DATA) begin
    if (bit_transition) begin
      if (datadone && docrc) state <= STATE_CRC;
      else if (datadone)     state <= STATE_END;
      bit_transition <= 1'b0;
    end else if (datadone) begin
      bit_transition <= 1'b1;
    end
  end else if (state == STATE_CRC) begin
    if (bit_transition) begin
      state      <= STATE_END;
      bit_transition <= 1'b0;
    end else if (crcdone) begin
      bit_transition <= 1'b1;
    end
  end else if (state == STATE_END) begin
    if (txdone) begin
      state <= STATE_PRE;
      done  <= 1'b1;
    end else begin
      tx_stop <= 1'b1;
    end
  end 
end
endmodule