`timescale 1ns / 1ps

module video_counters (
    input clk,
    output reg video_vsync,
    output reg video_hsync,
    output video_on,
    output reg [10:1] hpos,
    output reg [9:1] vpos
);

    // VGA 640x480 @ 60Hz Timing Constants
    localparam H_DISPLAY     = 640; // Horizontal display area
    localparam H_FRONT_PORCH = 16;  // Front porch
    localparam H_SYNC_PULSE  = 96;  // Sync pulse
    localparam H_BACK_PORCH  = 48;  // Back porch
    localparam H_TOTAL       = H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH; // Total horizontal pixels (800)

    localparam V_DISPLAY     = 480; // Vertical display area
    localparam V_FRONT_PORCH = 10;  // Front porch
    localparam V_SYNC_PULSE  = 2;   // Sync pulse
    localparam V_BACK_PORCH  = 33;  // Back porch
    localparam V_TOTAL       = V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH; // Total vertical lines (525)

    // Counters
    reg [9:0] h_count = 0; // Horizontal counter (0 to H_TOTAL-1)
    reg [9:0] v_count = 0; // Vertical counter (0 to V_TOTAL-1)

    // Internal video on signals
    reg video_h_on = 0;
    reg video_v_on = 0;

    assign video_on = video_h_on && video_v_on;

    // Initialize outputs (optional, good for simulation)
    initial begin
        video_vsync = 1'b1; // Vsync normally high
        video_hsync = 1'b1; // Hsync normally high
        hpos = 1;           // Default position
        vpos = 1;           // Default position
    end

    always @(posedge clk) begin
        // Horizontal Counter Logic
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            // Vertical Counter Logic (increments at the end of each line)
            if (v_count == V_TOTAL - 1) begin
                v_count <= 0;
            end else begin
                v_count <= v_count + 1;
            end
        end else begin
            h_count <= h_count + 1;
        end

        // Horizontal Sync Logic (active low)
        if (h_count >= (H_DISPLAY + H_FRONT_PORCH) && h_count < (H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE)) begin
            video_hsync <= 1'b0;
        end else begin
            video_hsync <= 1'b1;
        end

        // Vertical Sync Logic (active low)
        if (v_count >= (V_DISPLAY + V_FRONT_PORCH) && v_count < (V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE)) begin
            video_vsync <= 1'b0;
        end else begin
            video_vsync <= 1'b1;
        end

        // Video On Logic
        video_h_on <= (h_count < H_DISPLAY);
        video_v_on <= (v_count < V_DISPLAY);

        // Position Counters (1-based for output)
        if (video_h_on) begin
            hpos <= h_count + 1;
        end else begin
            hpos <= 1; // Or hold last value, reset to 1 seems reasonable
        end

        if (video_v_on) begin
            vpos <= v_count + 1;
        end else begin
            vpos <= 1; // Or hold last value, reset to 1 seems reasonable
        end
    end

endmodule