`timescale 1ns / 1ps
module video_counters(
    input clk,
    output reg video_vsync = 1,
    output reg video_hsync = 1,
    output video_on,
    output reg [10:0] hpos = 0,
    output reg [9:0] vpos = 0
);

    reg [9:0] hcnt = 0;
    reg [9:0] vcnt = 0;
    reg video_von = 0, video_hon = 0;

    assign video_on = video_von & video_hon;

    always @(posedge clk) begin
        if (hcnt == 799) begin
            hcnt <= 0;
            vcnt <= vcnt + 1;
            if (vcnt == 524) begin
                vcnt <= 0;
            end
        end else begin
            hcnt <= hcnt + 1;
        end
    end

    always @(posedge clk) begin
        // Horizontal timing
        if (hcnt == 0) begin
            video_hsync <= 0;
        end else if (hcnt == 96) begin
            video_hsync <= 1;
        end

        // Horizontal display
        if (hcnt == 144) begin
            video_hon <= 1;
            hpos <= 0;
        end else if (hcnt == 784) begin
            video_hon <= 0;
        end

        if (video_hon) begin
            hpos <= hpos + 1;
        end

        // Vertical timing
        if (vcnt == 0) begin
            video_vsync <= 0;
        end else if (vcnt == 2) begin
            video_vsync <= 1;
        end

        // Vertical display
        if (vcnt == 31) begin
            video_von <= 1;
            vpos <= 0;
        end else if (vcnt == 511) begin
            video_von <= 0;
        end

        if (video_von && hcnt == 799) begin
            vpos <= vpos + 1;
        end
    end

endmodule