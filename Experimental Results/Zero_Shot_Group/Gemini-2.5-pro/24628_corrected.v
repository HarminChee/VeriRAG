`timescale 1ns / 1ps

module VideoSync(
    input CLOCK,
    input RESET, // Added Reset signal
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

    // Calculate total horizontal period
    localparam H_ACTIVE_START = H_FP_DURATION + H_SYNC_DURATION + H_BP_DURATION;
    localparam H_PERIOD = H_ACTIVE_START + H_PIXELS; // Total clocks per line

    // Calculate total vertical period
    localparam V_ACTIVE_START = V_FP_DURATION + V_SYNC_DURATION + V_BP_DURATION;
    localparam V_PERIOD = V_ACTIVE_START + V_PIXELS; // Total lines per frame

    // Define sync pulse edges (start and end points)
    localparam H_SYNC_START = H_FP_DURATION;
    localparam H_SYNC_END   = H_FP_DURATION + H_SYNC_DURATION;

    localparam V_SYNC_START = V_FP_DURATION;
    localparam V_SYNC_END   = V_FP_DURATION + V_SYNC_DURATION;

    // Internal register for clock division
    reg [3:0] clock_divider;

    // Generate PIXEL_CLOCK (CLOCK / 16)
    always @(posedge CLOCK or posedge RESET) begin
        if (RESET) begin
            clock_divider <= 4'b0;
        end else begin
            clock_divider <= clock_divider + 1;
        end
    end
    assign PIXEL_CLOCK = clock_divider[3];

    // Counters logic
    always @(posedge PIXEL_CLOCK or posedge RESET) begin
        if (RESET) begin
            H_COUNTER <= 0;
            V_COUNTER <= 0;
        end else begin
            // Horizontal Counter Logic
            if (H_COUNTER == H_PERIOD - 1) begin
                H_COUNTER <= 0;
                // Vertical Counter Logic (increments at the end of a line)
                if (V_COUNTER == V_PERIOD - 1) begin
                    V_COUNTER <= 0; // Wrap around at the end of the frame
                end else begin
                    V_COUNTER <= V_COUNTER + 1;
                end
            end else begin
                H_COUNTER <= H_COUNTER + 1;
                // V_COUNTER remains unchanged during the line
            end
        end
    end

    // Sync Signal Generation (Assuming Active Low)
    // H_SYNC is low during the horizontal sync pulse duration
    assign H_SYNC = (H_COUNTER >= H_SYNC_START && H_COUNTER < H_SYNC_END) ? 1'b0 : 1'b1;

    // V_SYNC is low during the vertical sync pulse duration
    assign V_SYNC = (V_COUNTER >= V_SYNC_START && V_COUNTER < V_SYNC_END) ? 1'b0 : 1'b1;

    // C_SYNC (Composite Sync) - typically XOR of H/V sync, inverted for active low
    // Using XNOR because H_SYNC and V_SYNC outputs are active low
    assign C_SYNC = !(H_SYNC ^ V_SYNC); // Equivalent to H_SYNC ~^ V_SYNC

endmodule