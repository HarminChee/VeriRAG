`timescale 1ns / 1ps
module VideoSync_corrected_ffc (
    input CLOCK,
    output PIXEL_CLOCK,
    output V_SYNC,
    output H_SYNC,
    output C_SYNC,
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

    // Calculate horizontal timing edges and period
    parameter H_FP_EDGE = H_FP_DURATION;
    parameter H_SYNC_EDGE = H_FP_EDGE + H_SYNC_DURATION;
    parameter H_BP_EDGE = H_SYNC_EDGE + H_BP_DURATION;
    parameter H_PERIOD = H_BP_EDGE + H_PIXELS; // Total horizontal pixels per line

    // Calculate vertical timing edges and period
    parameter V_FP_EDGE = V_FP_DURATION;
    parameter V_SYNC_EDGE = V_FP_EDGE + V_SYNC_DURATION;
    parameter V_BP_EDGE = V_SYNC_EDGE + V_BP_DURATION;
    parameter V_PERIOD = V_BP_EDGE + V_PIXELS; // Total vertical lines per frame

    reg [3:0] clock_divider = 0;
    wire pixel_clock_enable;

    // Clock divider logic driven by the primary clock
    always @(posedge CLOCK) begin
        clock_divider <= clock_divider + 1;
    end

    // Generate the pixel clock output signal (not used as internal clock)
    assign PIXEL_CLOCK = clock_divider[3];

    // Generate enable signal for counter updates, active once per PIXEL_CLOCK cycle
    // Active when clock_divider transitions from 7 to 8 (rising edge of clock_divider[3])
    assign pixel_clock_enable = (clock_divider == 4'd7);

    // Counters driven by the primary clock, enabled by pixel_clock_enable
    initial begin
        H_COUNTER = 0;
        V_COUNTER = 0;
    end

    always @(posedge CLOCK) begin
        if (pixel_clock_enable) begin
            if (H_COUNTER == H_PERIOD - 1) begin
                H_COUNTER <= 0; // Reset horizontal counter at the end of the line
                if (V_COUNTER == V_PERIOD - 1) begin
                    V_COUNTER <= 0; // Reset vertical counter at the end of the frame
                end else begin
                    V_COUNTER <= V_COUNTER + 1; // Increment vertical counter
                end
            end else begin
                H_COUNTER <= H_COUNTER + 1; // Increment horizontal counter
            end
        end
    end

    // Sync signal generation based on counter values
    assign V_SYNC = (V_COUNTER >= V_FP_EDGE && V_COUNTER < V_SYNC_EDGE) ? 1'b0 : 1'b1; // Active low during V_SYNC_DURATION
    assign H_SYNC = (H_COUNTER >= H_FP_EDGE && H_COUNTER < H_SYNC_EDGE) ? 1'b0 : 1'b1; // Active low during H_SYNC_DURATION
    assign C_SYNC = !(H_SYNC ^ V_SYNC); // Composite sync (often XOR, but depends on standard)

endmodule