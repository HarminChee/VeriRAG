`default_nettype none
`timescale 1ns / 1ps
module JtagUserIdentifier_corrected_clk #(
    parameter IDCODE_VID = 24'h000000,
    parameter IDCODE_PID = 8'h00
)(
    input wire tck_in,  // Primary clock input
    input wire tms,
    input wire tdi,
    output wire tdo
);
    reg[31:0] tap_shreg = 0;
    wire tap_active;
    wire tap_shift;
    wire tap_clear;
    
    JtagTAP #(
        .USER_INSTRUCTION(1)
    ) tap_tap (
        .instruction_active(tap_active),
        .state_capture_dr(tap_clear),
        .state_reset(),
        .state_runtest(),
        .state_shift_dr(tap_shift),
        .state_update_dr(),
        .tck(tck_in),
        .tck_gated(),
        .tms(tms),
        .tdi(tdi),
        .tdo(tap_shreg[0])
    );

    always @(posedge tck_in) begin
        if(!tap_active) begin
        end
        else if(tap_clear)
            tap_shreg <= {IDCODE_VID, IDCODE_PID};
        else if(tap_shift)
            tap_shreg <= {1'b1, tap_shreg[31:1]};
    end
    
    assign tdo = tap_shreg[0];
endmodule
`default_nettype wire