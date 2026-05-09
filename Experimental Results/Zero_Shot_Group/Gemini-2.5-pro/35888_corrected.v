`timescale 1ns/1ns

module sequencer (
    input        reset,
    input        rtcal_expired,
    input        oscclk,
    input [1:0]  m,
    input        dr,
    input        docrc,
    input        trext,
    input [9:0]  trcal,
    input        databitsrc,
    input        datadone,
    output       dataclk,
    output       modout,
    output       txsetupdone,
    output       txdone
);

    // Internal signals
    reg         done;
    reg         tx_stop;
    wire        txclk;
    wire        txbitclk;
    wire        violation;
    wire        crcdone;
    wire        preambledone;
    wire        crcinclk;
    wire        crcbitin;
    wire        txbitsrc;
    wire        crcbitsrc;
    wire        preamblebitsrc;
    wire        crcoutclk;
    wire        preambleclk;

    // Output wires driven by submodules or assignments
    wire        dataclk_internal;
    wire        modout_internal;
    wire        txsetupdone_internal;
    wire        txdone_internal;

    assign dataclk     = dataclk_internal;
    assign modout      = modout_internal;
    assign txsetupdone = txsetupdone_internal;
    assign txdone      = txdone_internal;

    // Submodule Instantiations
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
        .txclk(txclk),
        .txbitsrc(txbitsrc),
        .violation(violation), // Output from tx
        .m(m),
        .modout(modout_internal), // Output from tx
        .txbitclk(txbitclk),     // Output from tx
        .txsetupdone(txsetupdone_internal), // Output from tx
        .txdone(txdone_internal)      // Output from tx
    );

    preamble U_PRE (
        .reset(reset),
        .preambleclk(preambleclk),
        .m(m),
        .trext(trext),
        .preamblebitsrc(preamblebitsrc), // Output from preamble
        .violation(violation),           // Input to preamble
        .preambledone(preambledone)      // Output from preamble
    );

    crc16 U_CRC (
        .reset(reset),
        .crcinclk(crcinclk),
        .crcbitin(crcbitin),
        .crcoutclk(crcoutclk),
        .crcbitsrc(crcbitsrc), // Output from crc16
        .crcdone(crcdone)      // Output from crc16
    );

    // State Machine
    reg [1:0] state;
    parameter STATE_PRE  = 2'd0;
    parameter STATE_DATA = 2'd1;
    parameter STATE_CRC  = 2'd2;
    parameter STATE_END  = 2'd3;

    // Bit Source Multiplexer
    wire [3:0] bitsrc_options;
    assign bitsrc_options[0] = preamblebitsrc;
    assign bitsrc_options[1] = databitsrc;
    assign bitsrc_options[2] = crcbitsrc;
    assign bitsrc_options[3] = 1'b0; // Default/End state source (e.g., idle low)
    assign txbitsrc  = bitsrc_options[state];

    // Intermediate signal for state transition delay
    reg bit_transition;

    // Clock/Enable Generation
    assign crcbitin    = databitsrc;
    assign crcinclk    = txbitclk && (state == STATE_DATA) && docrc;
    assign preambleclk = txbitclk && (state == STATE_PRE) && (!done);
    assign dataclk_internal = txbitclk && (state == STATE_DATA || (state == STATE_PRE && bit_transition && !done));
    assign crcoutclk   = txbitclk && (state == STATE_CRC);

    // State Machine Logic
    always @ (negedge txbitclk or posedge reset) begin
        if (reset) begin
            state          <= STATE_PRE;
            done           <= 1'b0;
            bit_transition <= 1'b0;
            tx_stop        <= 1'b0;
        end else if (!done) begin // Only operate if not done
            case (state)
                STATE_PRE: begin
                    if (bit_transition) begin
                        state          <= STATE_DATA;
                        bit_transition <= 1'b0;
                    end else if (preambledone) begin
                        bit_transition <= 1'b1;
                    end
                end
                STATE_DATA: begin
                    if (bit_transition) begin
                        if (datadone && docrc) begin
                            state <= STATE_CRC;
                        end else if (datadone) begin
                            state <= STATE_END;
                        end
                        bit_transition <= 1'b0;
                    end else if (datadone) begin
                        bit_transition <= 1'b1;
                    end
                end
                STATE_CRC: begin
                    if (bit_transition) begin
                        state          <= STATE_END;
                        bit_transition <= 1'b0;
                    end else if (crcdone) begin
                        bit_transition <= 1'b1;
                    end
                end
                STATE_END: begin
                     // Wait for txdone signal from TX module before stopping
                    if (txdone_internal) begin
                        done  <= 1'b1; // Mark sequence as done
                        // state <= STATE_PRE; // Optionally loop back or stay done
                        tx_stop <= 1'b1; // Stop transmission after txdone asserted
                    end else begin
                        // Keep tx_stop low until txdone is high in END state
                        // Or assert tx_stop immediately upon entering STATE_END if needed
                        // Current logic waits for txdone before asserting tx_stop
                         tx_stop <= 1'b0; // Example: Assert stop earlier if needed
                                          // If tx should stop *before* txdone, set tx_stop here.
                                          // If tx should stop *after* txdone, set tx_stop when done is set.
                    end
                end
                default: begin
                    state          <= STATE_PRE;
                    bit_transition <= 1'b0;
                    tx_stop        <= 1'b0; // Ensure stop is low on unexpected state
                end
            endcase
        // No 'else' for the 'if (!done)' condition, meaning once 'done' is set,
        // the state machine freezes until the next reset.
        // If tx_stop needs to be managed after done, add logic here or outside the !done block.
        // If tx_stop should be deasserted on reset, it is handled by the reset condition.
        end else begin
             // Actions to take when 'done' is true (e.g., hold tx_stop high)
             tx_stop <= 1'b1; // Keep transmission stopped
        end
    end

endmodule