`timescale 1ns / 1ps
module VideoSync(
    input wire test_i,
    input wire CLOCK,
    output wire PIXEL_CLOCK,
    output wire V_SYNC,
    output wire H_SYNC,
    output wire C_SYNC, 
    output reg [8:0] H_COUNTER,
    output reg [8:0] V_COUNTER
);
    parameter H_PIXELS = 320;
    parameter H_FP_DURATION   = 4;
    parameter H_SYNC_DURATION = 48;
    parameter H_BP_DURATION   = 28;
    parameter V_PIXELS = 240;
    parameter V_FP_DURATION   = 1;
    parameter V_SYNC_DURATION = 15;
    parameter V_BP_DURATION   = 4;
    parameter H_FP_EDGE = H_FP_DURATION;
    parameter H_SYNC_EDGE = H_FP_EDGE + H_SYNC_DURATION;
    parameter H_BP_EDGE = H_SYNC_EDGE + H_BP_DURATION;
    parameter H_PERIOD = H_BP_EDGE + H_PIXELS;
    parameter V_FP_EDGE = V_FP_DURATION;
    parameter V_SYNC_EDGE = V_FP_EDGE + V_SYNC_DURATION;
    parameter V_BP_EDGE = V_SYNC_EDGE + V_BP_DURATION;
    parameter V_PERIOD = V_BP_EDGE + V_PIXELS;

    reg [3:0] clock_divider = 0;
    wire dft_pixel_clock;

    always @(posedge CLOCK) begin
        clock_divider <= clock_divider + 1;
    end

    assign PIXEL_CLOCK = clock_divider[3];
    assign dft_pixel_clock = test_i ? CLOCK : PIXEL_CLOCK;

    always @(posedge dft_pixel_clock) begin
        H_COUNTER <= H_COUNTER + 1;
        if (H_COUNTER == H_PERIOD - 1) begin
            H_COUNTER <= 0;
            V_COUNTER <= V_COUNTER + 1;
        end
        if (V_COUNTER == V_PERIOD - 1) begin
            V_COUNTER <= 0;
            H_COUNTER <= 0;
        end
    end

    assign V_SYNC = (V_COUNTER < V_FP_EDGE || V_COUNTER > V_SYNC_EDGE);
    assign H_SYNC = (H_COUNTER < H_FP_EDGE || H_COUNTER > H_SYNC_EDGE);
    assign C_SYNC = !(H_SYNC ^ V_SYNC);
endmodule