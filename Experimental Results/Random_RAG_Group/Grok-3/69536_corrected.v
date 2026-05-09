`timescale 1ns / 1ps
module video_counters(
    input wire test_i,
    input wire clk,
    input wire rst,
    output reg video_vsync = 1,
    output reg video_hsync = 1,
    output wire video_on,
    output reg [10:1] hpos = 0,
    output reg [9:1] vpos = 0
);
    integer hcnt = 0, vcnt = 0;
    reg video_von = 0, video_hon = 0;
    wire dft_clk, dft_rst;
    
    assign video_on = video_von & video_hon;
    assign dft_clk = test_i ? clk : video_hsync;
    assign dft_rst = rst;

    always @(posedge dft_clk or posedge dft_rst) begin
        if (dft_rst) begin
            vcnt <= 0;
            vpos <= 0;
            video_vsync <= 1;
            video_von <= 0;
        end else begin
            vcnt <= vcnt + 1;
            vpos <= video_von ? vpos + 1 : 0;
            case (vcnt)
                2: video_vsync <= 1;
                31: video_von <= 1;
                511: video_von <= 0;
                521: begin 
                    vcnt <= 0; 
                    video_vsync <= 0; 
                end
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hcnt <= 0;
            hpos <= 0;
            video_hsync <= 1;
            video_hon <= 0;
        end else begin
            if (!video_hon) hcnt <= hcnt - 1;
            else hpos <= hpos + 1;
            if (hpos == 639) video_hon <= 0;
            if (hpos == 640) begin
                if (!hcnt) begin
                    hcnt <= 96;
                    video_hsync <= 0;
                    hpos <= 0;
                end
            end else if (!hcnt) begin
                if (!video_hsync) begin
                    video_hsync <= 1;
                    hcnt <= 48;
                end else if (!video_hon) begin
                    video_hon <= 1;
                    hcnt <= 16;
                end
            end
        end
    end
endmodule