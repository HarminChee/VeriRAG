<xaiArtifact artifact_id="c29dfd7c-b5f1-405d-bd9e-ffc055a1a794" artifact_version_id="4ea1bde9-7424-4608-b0e2-14a428874b34" title="video_counters.v" contentType="text/verilog">
`timescale 1ns / 1ps
module video_counters(
    input clk,
    output reg video_vsync = 1,
    output reg video_hsync = 1,
    output video_on,
    output reg [9:0] hpos = 0,
    output reg [9:0] vpos = 0
);
    reg [9:0] hcnt = 0;
    reg [9:0] vcnt = 0;
    reg video_von = 0;
    reg video_hon = 0;

    assign video_on = video_von & video_hon;

    always @(posedge clk) begin
        // Horizontal counter
        hcnt <= hcnt + 1;
        if (hcnt < 640) begin
            hpos <= hcnt;
            video_hon <= 1;
            video_hsync <= 1;
        end
        else if (hcnt < 656) begin
            video_hon <= 0;
            video_hsync <= 1;
        end
        else if (hcnt < 752) begin
            video_hsync <= 0;
        end
        else if (hcnt < 800) begin
            video_hsync <= 1;
        end
        else begin
            hcnt <= 0;
            hpos <= 0;
            vcnt <= vcnt + 1;
        end

        // Vertical counter
        if (vcnt < 480) begin
            vpos <= vcnt;
            video_von <= 1;
            video_vsync <= 1;
        end
        else if (vcnt < 490) begin
            video_von <= 0;
            video_vsync <= 1;
        end
        else if (vcnt < 492) begin
            video_vsync <= 0;
        end
        else if (vcnt < 525) begin
            video_vsync <= 1;
        end
        else begin
            vcnt <= 0;
            vpos <= 0;
        end
    end
endmodule
</xaiArtifact>