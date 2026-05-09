`default_nettype none
`timescale 1ns / 1ps
module JtagUserIdentifier #(
    parameter IDCODE_VID = 24'h000000,
    parameter IDCODE_PID = 8'h00
) (
    input wire tck,
    input wire tms,
    input wire tdi,
    output wire tdo
);
    reg [31:0] tap_shreg = 0;
    wire tap_active;
    wire tap_shift;
    wire tap_clear;
    wire tap_tck_raw;
    wire tap_tck_bufh;

    JtagTAP #(
        .USER_INSTRUCTION(1)
    ) tap_tap (
        .instruction_active(tap_active),
        .state_capture_dr(tap_clear),
        .state_reset(),
        .state_runtest(),
        .state_shift_dr(tap_shift),
        .state_update_dr(),
        .tck(tap_tck_raw),
        .tck_gated(),
        .tms(tms),
        .tdi(tdi),
        .tdo(tap_shreg[0])
    );

    ClockBuffer #(
        .TYPE("LOCAL"),
        .CE("NO")
    ) tap_tck_clkbuf (
        .clkin(tap_tck_raw),
        .clkout(tap_tck_bufh),
        .ce(1'b1)
    );

    always @(posedge tap_tck_bufh) begin
        if (!tap_active) begin
            tap_shreg <= 32'h00000000;
        end
        else if (tap_clear)
            tap_shreg <= {IDCODE_VID, IDCODE_PID};
        else if (tap_shift)
            tap_shreg <= {tdi, tap_shreg[31:1]};
    end

    assign tdo = tap_shreg[0];
endmodule