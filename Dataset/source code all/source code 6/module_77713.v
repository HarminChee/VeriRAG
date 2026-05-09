module credit_producer (
    clk,
    reset_n,
    in_valid,
    in_ready,
    in_endofpacket,
    symbol_credits,
    packet_credits
);
    parameter SYMBOLS_PER_CREDIT    = 1;
    parameter SYMBOLS_PER_BEAT      = 1;
    parameter USE_SYMBOL_CREDITS    = 1;
    parameter USE_PACKET_CREDITS    = 1;
    parameter USE_PACKETS           = 1;
    input clk;
    input reset_n;
    input in_valid;
    input in_ready;
    input in_endofpacket;
    output reg [15 : 0] symbol_credits;
    output reg [15 : 0] packet_credits;
    reg beat;
    reg eop_beat;
    reg [15 : 0] sym_count;
    reg [15 : 0] next_sym_count;
    reg rollover;
    always @* begin
        beat = in_valid && in_ready;
        if (USE_PACKETS)
            eop_beat = beat && in_endofpacket;
        else
            eop_beat = 0;
    end
generate
    if (SYMBOLS_PER_BEAT % SYMBOLS_PER_CREDIT == 0) begin
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n)
                symbol_credits <= 0;
            else if (beat)
                symbol_credits <= symbol_credits + SYMBOLS_PER_BEAT/SYMBOLS_PER_CREDIT;
        end
    end
    else if (SYMBOLS_PER_CREDIT % SYMBOLS_PER_BEAT == 0) begin
        always @* begin
            next_sym_count = sym_count;
            if (beat)
                next_sym_count = sym_count + SYMBOLS_PER_BEAT;
        end
        always @* begin
            rollover =  (next_sym_count == SYMBOLS_PER_CREDIT) || eop_beat;
        end
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n)
                sym_count <= 0;
            else if (rollover)
                sym_count <= 0;
            else
                sym_count <= next_sym_count;
        end
        always @(posedge clk or negedge reset_n) begin
            if (!reset_n)
                symbol_credits <= 0;
            else if (rollover)
                symbol_credits <= symbol_credits + 1;
        end
    end
endgenerate
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            packet_credits <= 0;
        else if (eop_beat)
            packet_credits <= packet_credits + 1;
    end
endmodule
