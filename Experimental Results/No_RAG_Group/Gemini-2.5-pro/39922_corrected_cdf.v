`timescale 1ns/1ns
module c1_regs_corrected (
    input nICOM_ZONE,
    input RW,
    inout [15:8] M68K_DATA,
    inout [7:0] SDD,
    input nSDZ80R, nSDZ80W, nSDZ80CLR,
    output nSDW,
    // DFT specific signals added for correction
    input test_mode,       // Test mode enable signal
    input [7:0] scan_in_cmd, // Scan input for SDD_LATCH_CMD
    input [7:0] scan_in_rep  // Scan input for SDD_LATCH_REP
    // Scan outputs can be added if needed, typically flop outputs
    // output [7:0] scan_out_cmd,
    // output [7:0] scan_out_rep
);

    reg [7:0] SDD_LATCH_CMD_q; // Renamed register for clarity (output of flop)
    reg [7:0] SDD_LATCH_REP_q; // Renamed register for clarity (output of flop)

    // Wires for next state logic (inputs to flops)
    wire [7:0] SDD_LATCH_CMD_next;
    wire [7:0] SDD_LATCH_REP_next;

    // Combinational logic for next state and outputs

    // Output logic for SDD (Tristate based on nSDZ80R)
    assign SDD = nSDZ80R ? 8'bzzzzzzzz : SDD_LATCH_CMD_q;

    // Next state logic for SDD_LATCH_REP
    // Data source is SDD in functional mode, scan_in_rep in test mode
    // Note: SDD depends on SDD_LATCH_CMD_q, creating dependency between the two paths.
    // This assumes SDD is stable when nSDZ80W rises.
    assign SDD_LATCH_REP_next = test_mode ? scan_in_rep : SDD;

    // Internal representation of M68K_DATA logic used to feed SDD_LATCH_CMD
    // This path includes nICOM_ZONE, which is also the clock for SDD_LATCH_CMD, causing CDFDAT.
    wire [7:0] M68K_DATA_internal = (RW & ~nICOM_ZONE) ? SDD_LATCH_REP_q : SDD_LATCH_CMD_q; // Use previous CMD value if not writing

    // Output logic for M68K_DATA (Tristate based on RW and nICOM_ZONE)
    assign M68K_DATA = (RW & ~nICOM_ZONE) ? SDD_LATCH_REP_q : 8'bzzzzzzzz;

    // Next state logic for SDD_LATCH_CMD
    // In test mode, use scan_in_cmd to break the CDFDAT path.
    // In functional mode, load M68K_DATA_internal if !RW, otherwise hold.
    assign SDD_LATCH_CMD_next = test_mode ? scan_in_cmd :
                                (!RW ? M68K_DATA_internal : SDD_LATCH_CMD_q);

    // Output logic for nSDW
    assign nSDW = (RW | nICOM_ZONE);

    // Sequential logic (Flip-Flops)

    // Flip-Flop for SDD_LATCH_REP (Positive edge clock, no reset)
    always @(posedge nSDZ80W) begin
        SDD_LATCH_REP_q <= SDD_LATCH_REP_next;
    end

    // Flip-Flop for SDD_LATCH_CMD (Negative edge clock, Asynchronous active-low reset)
    // The data input SDD_LATCH_CMD_next is now muxed by test_mode
    // This prevents nICOM_ZONE from affecting the data input during test mode.
    always @(negedge nICOM_ZONE or negedge nSDZ80CLR) begin
        if (!nSDZ80CLR) begin // Asynchronous reset
            SDD_LATCH_CMD_q <= 8'b00000000;
        end else begin // Clocked behavior
            SDD_LATCH_CMD_q <= SDD_LATCH_CMD_next;
        end
    end

    // Removed $display statements as they are non-synthesizable

endmodule