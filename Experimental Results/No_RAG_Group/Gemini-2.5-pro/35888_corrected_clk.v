// 1_corrected_clk.v
`timescale 1ns/1ns
module sequencer (reset, rtcal_expired, oscclk, m, dr, docrc, trext, trcal,
                  databitsrc, datadone, data_valid, modout, txsetupdone, txdone); // Modified port list: removed dataclk, added data_valid
input reset, rtcal_expired, trext, dr, docrc, databitsrc, datadone, oscclk;
input [9:0] trcal;
input [1:0] m;
output data_valid, modout, txsetupdone, txdone; // Modified port list
reg done;
reg tx_stop;
wire txsetupdone, txdone;
wire txclk, txbitclk;
wire violation; // Note: violation output from U_TX0 and U_PRE are not used/connected externally
wire crcdone, preambledone;
wire crcbitin;
wire txbitsrc, crcbitsrc, preamblebitsrc;
// Removed gated clock wires: crcinclk, preambleclk, crcoutclk, dataclk

// Added enable signals
wire preamble_en;
wire crc_in_en;
wire crc_out_en; // Assuming CRC module needs separate enables or one combined enable. Let's assume separate for input/output based on original signals.
wire data_valid; // Replaces dataclk output


txclkdivide U_DIV (reset, oscclk, trcal, dr, txclk);

// Pass ungated clock txbitclk to submodules. Enable signals control operation.
// Assuming tx module interface remains the same regarding clocks it uses/generates internally.
tx          U_TX0 (reset, rtcal_expired, tx_stop,
                   txclk, txbitsrc, violation, m,
                   modout, txbitclk, txsetupdone, txdone);

// Assuming preamble module is modified to accept clk (txbitclk) and en (preamble_en)
preamble    U_PRE ( .clk(txbitclk), .en(preamble_en), // Changed clock input, added enable
                    .reset(reset), .m(m), .trext(trext),
                    .preamblebitsrc(preamblebitsrc), .violation(violation), .preambledone(preambledone) );

// Assuming crc16 module is modified to accept clk (txbitclk) and enables (crc_in_en, crc_out_en)
crc16       U_CRC ( .clk(txbitclk), .in_en(crc_in_en), .out_en(crc_out_en), // Changed clock inputs to single clock + enables
                    .reset(reset), .crcbitin(crcbitin),
                    .crcbitsrc(crcbitsrc), .crcdone(crcdone) );

reg [1:0] state;
parameter STATE_PRE  = 2'd0;
parameter STATE_DATA = 2'd1;
parameter STATE_CRC  = 2'd2;
parameter STATE_END  = 2'd3;

wire [3:0] bitsrc;
assign bitsrc[0] = preamblebitsrc;
assign bitsrc[1] = databitsrc;
assign bitsrc[2] = crcbitsrc;
assign bitsrc[3] = 1; // Ensure state_end provides a defined bit source if needed by txbitsrc logic, though tx_stop should prevent transmission.
assign txbitsrc  = bitsrc[state];

reg bit_transition;

assign crcbitin  = databitsrc;

// Generate enable signals based on original clock gating conditions
assign preamble_en = (state == STATE_PRE) && (!done);
assign crc_in_en   = (state == STATE_DATA) & docrc; // Enable for CRC input processing
assign crc_out_en  = (state == STATE_CRC);          // Enable for CRC output generation/usage
assign data_valid  = (state == STATE_DATA || (state == STATE_PRE && bit_transition && !done)); // Data valid signal replacing dataclk


// State machine logic remains the same, clocked by negedge of txbitclk
always @ (negedge txbitclk or posedge reset) begin
  if (reset) begin
    state      <= STATE_PRE; // Initialize to PRE state
    done       <= 0;
    bit_transition <= 0;
    tx_stop    <= 0;
  end else if (done) begin
      // Hold state when done? Or reset? Assuming hold based on original code.
      // Consider adding reset for tx_stop if needed: tx_stop <= 0;
  end else begin // Add begin/end for clarity
    tx_stop <= 0; // Generally running, stop only in END state before txdone
    case (state)
      STATE_PRE: begin
        if (bit_transition) begin
          state      <= STATE_DATA;
          bit_transition <= 0;
        end else if (preambledone) begin
          bit_transition <= 1;
        end
      end
      STATE_DATA: begin
        if (bit_transition) begin
          if (datadone && docrc) state <= STATE_CRC;
          else if (datadone)     state <= STATE_END;
          bit_transition <= 0;
        end else if (datadone) begin
          bit_transition <= 1;
        end
      end
      STATE_CRC: begin
        if (bit_transition) begin
          state      <= STATE_END;
          bit_transition <= 0;
        end else if (crcdone) begin
          bit_transition <= 1;
        end
      end
      STATE_END: begin
        if (txdone) begin
          state <= STATE_PRE; // Cycle back to PRE state
          done  <= 1;
          tx_stop <= 0; // Stop asserting tx_stop
        end else begin
          tx_stop <= 1; // Assert stop signal to TX module
        end
      end
      default: state <= STATE_PRE; // Default case for safety
    endcase
  end // End outer else
end // End always block

endmodule