`timescale 1ns / 1ps
module video_counters(
    input clk,
    output reg video_vsync,
    output reg video_hsync,
    output video_on,
    output reg [9:0] hpos,
    output reg [8:0] vpos
);
    reg video_von, video_hon;
    reg [9:0] hcnt, vcnt;

    assign video_on = video_von & video_hon;

    initial begin
        video_vsync = 1;
        video_hsync = 1;
        hpos = 0;
        vpos = 0;
        hcnt = 0;
        vcnt = 0;
        video_von = 0;
        video_hon = 0;
    end

    always @(posedge video_hsync) begin
        vcnt <= vcnt + 1;
        vpos <= video_von ? (vpos + 1) : 0;
        case (vcnt)
            2   : video_vsync <= 1;
            31  : video_von <= 1;
            511 : video_von <= 0;
            521 : begin
                vcnt <= 0;
                video_vsync <= 0;
            end
        endcase
    end

    always @(posedge clk) begin
        if (!video_hon)
            hcnt <= hcnt - 1;
        else
            hpos <= hpos + 1;

        if (hpos == 639)
            video_hon <= 0;

        if (hpos == 640) begin
            if (!hcnt) begin
                hcnt <= 96;
                video_hsync <= 0;
                hpos <= 0;
            end
        end
        else if (!hcnt) begin
            if (!video_hsync) begin
                video_hsync <= 1;
                hcnt <= 48;
            end
            else if (!video_hon) begin
                video_hon <= 1;
                hcnt <= 16;
            end
        end
    end
endmodule