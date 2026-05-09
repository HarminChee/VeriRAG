module timing(
    input clk,
    output pixclk,
    output [4:0] txtrow,
    output [6:0] txtcol,
    output [3:0] chrrow,
    output [2:0] chrcol,
    output blank,
    output hsync,
    output vsync,
    output reg blink
);
    reg pclk = 0;
    reg [9:0] hcnt = 0;
    reg hblank = 0, hsynch = 1;
    reg [9:0] vcnt = 0;
    reg vblank = 0, vsynch = 1;
    reg [5:0] bcnt = 0;

    always @(posedge clk) begin
        pclk <= ~pclk;
    end

    assign pixclk = pclk;

    always @(posedge clk) begin
        if (pclk) begin
            if (hcnt == 10'd799) begin
                hcnt <= 10'd0;
            end
            else begin
                hcnt <= hcnt + 1;
            end
            if (hcnt == 10'd639) begin
                hblank <= 1;
            end
            if (hcnt == 10'd799) begin
                hblank <= 0;
            end
            if (hcnt == 10'd655) begin
                hsynch <= 0;
            end
            if (hcnt == 10'd751) begin
                hsynch <= 1;
            end
        end
    end

    always @(posedge clk) begin
        if (pclk && (hcnt == 10'd799)) begin
            if (vcnt == 10'd524) begin
                vcnt <= 10'd0;
            end
            else begin
                vcnt <= vcnt + 1;
            end
            if (vcnt == 10'd479) begin
                vblank <= 1;
            end
            if (vcnt == 10'd524) begin
                vblank <= 0;
            end
            if (vcnt == 10'd489) begin
                vsynch <= 0;
            end
            if (vcnt == 10'd491) begin
                vsynch <= 1;
            end
        end
    end

    always @(posedge clk) begin
        if (pclk && (hcnt == 10'd799) && (vcnt == 10'd524)) begin
            if (bcnt == 6'd59) begin
                bcnt <= 6'd0;
                blink <= 1;
            end
            else begin
                bcnt <= bcnt + 1;
            end
            if (bcnt == 6'd29) begin
                blink <= 0;
            end
        end
    end

    assign blank = hblank | vblank;
    assign hsync = hsynch;
    assign vsync = vsynch;
    assign txtrow = vcnt[8:4];
    assign txtcol = hcnt[9:3];
    assign chrrow = vcnt[3:0];
    assign chrcol = hcnt[2:0];
endmodule