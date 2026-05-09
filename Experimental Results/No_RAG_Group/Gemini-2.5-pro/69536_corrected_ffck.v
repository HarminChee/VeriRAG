`timescale 1ns / 1ps
module video_counters_corrected_ffc (
    input clk,
    // No reset in original, maintaining structure but reset is recommended
    output reg video_vsync = 1'b1, // Initial value for simulation
    output reg video_hsync = 1'b1, // Initial value for simulation
    output video_on,
    output reg [10:0] hpos = 11'b0, // Width adjusted for 640 (0..640 needs 11 bits)
    output reg [9:0] vpos = 10'b0  // Width for 0..511 needs 10 bits
);

    // Internal counters and state registers using reg type
    reg [6:0] hcnt = 7'b0; // Counts up to 96, needs 7 bits
    reg [9:0] vcnt = 10'b0; // Counts up to 521 (0..520), needs 10 bits
    reg video_von = 1'b0;
    reg video_hon =