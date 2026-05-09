`default_nettype none
module Blinky(
    led_lfosc_ff, led_lfosc_count, led_lfosc_shreg1, led_lfosc_shreg1a, led_lfosc_shreg2, led_lfosc_shreg2a,
    led_rosc_ff, led_rcosc_ff,
    sys_rst, count_rst, osc_pwrdn);
    output reg led_lfosc_ff = 0;
    output reg led_lfosc_count = 0;
    output wire led_lfosc_shreg1;
    output wire led_lfosc_shreg1a;
    output wire led_lfosc_shreg2;
    output wire led_lfosc_shreg2a;
    output reg led_rosc_ff = 0;
    output reg led_rcosc_ff = 0;
    input wire sys_rst;            
    input wire count_rst;        
    input wire osc_pwrdn;        

    GP_SYSRESET #(
        .RESET_MODE("LEVEL")
    ) reset_ctrl (
        .RST(sys_rst)
    );

    wire por_done;
    GP_POR #(
        .POR_TIME(500)
    ) por (
        .RST_DONE(por_done)
    );

    wire clk_108hz;
    GP_LFOSC #(
        .PWRDN_EN(1),
        .AUTO_PWRDN(0),
        .OUT_DIV(16)
    ) lfosc (
        .PWRDN(osc_pwrdn),
        .CLKOUT(clk_108hz)
    );

    wire clk_1687khz_cnt;        
    wire clk_1687khz;            
    GP_RINGOSC #(
        .PWRDN_EN(1),
        .AUTO_PWRDN(0),
        .HARDIP_DIV(16),
        .FABRIC_DIV(1)
    ) ringosc (
        .PWRDN(osc_pwrdn),
        .CLKOUT_HARDIP(clk_1687khz_cnt),
        .CLKOUT_FABRIC(clk_1687khz)
    );

    wire clk_6khz_cnt;            
    wire clk_6khz;                
    GP_RCOSC #(
        .PWRDN_EN(1),
        .AUTO_PWRDN(0),
        .OSC_FREQ("25k"),        
        .HARDIP_DIV(4),
        .FABRIC_DIV(1)
    ) rcosc (
        .PWRDN(osc_pwrdn),
        .CLKOUT_HARDIP(clk_6khz_cnt),
        .CLKOUT_FABRIC(clk_6khz)
    );

    localparam COUNT_MAX = 31;
    reg[7:0] count = COUNT_MAX;
    always @(posedge clk_108hz, posedge count_rst) begin
        if(count_rst)
            count            <= 0;
        else begin
            if(count == 0)
                count        <= COUNT_MAX;
            else
                count        <= count - 1'd1;
        end
    end

    wire led_fabric_raw = (count == 0);
    wire led_lfosc_raw;
    GP_COUNT8 #(
        .RESET_MODE("LEVEL"),
        .COUNT_TO(COUNT_MAX),
        .CLKIN_DIVIDE(1)
    ) lfosc_cnt (
        .CLK(clk_108hz),
        .RST(count_rst),
        .OUT(led_lfosc_raw)
    );

    wire led_rosc_raw;
    GP_COUNT14 #(
        .RESET_MODE("LEVEL"),
        .COUNT_TO(16383),
        .CLKIN_DIVIDE(1)
    ) ringosc_cnt (
        .CLK(clk_1687khz_cnt),
        .RST(count_rst),
        .OUT(led_rosc_raw)
    );

    wire led_rcosc_raw;
    GP_COUNT14 #(
        .RESET_MODE("LEVEL"),
        .COUNT_TO(1023),
        .CLKIN_DIVIDE(1)
    ) rcosc_cnt (
        .CLK(clk_6khz_cnt),
        .RST(count_rst),
        .OUT(led_rcosc_raw)
    );

    always @(posedge clk_108hz) begin
        if(por_done) begin
            if(led_fabric_raw)
                led_lfosc_ff    <= ~led_lfosc_ff;
            if(led_lfosc_raw)
                led_lfosc_count <= ~led_lfosc_count;
        end
    end

    reg[3:0] pdiv = 0;
    always @(posedge clk_1687khz) begin
        if(led_rosc_raw) begin
            pdiv                <= pdiv + 1'd1;
            if(pdiv == 0)
                led_rosc_ff        <= ~led_rosc_ff;
        end
    end

    always @(posedge clk_6khz) begin
        if(led_rcosc_raw)
            led_rcosc_ff        <= ~led_rcosc_ff;
    end

    GP_SHREG #(
        .OUTA_TAP(8),
        .OUTA_INVERT(0),
        .OUTB_TAP(16)
    ) shreg (
        .nRST(1'b1),
        .CLK(clk_108hz),
        .IN(led_lfosc_ff),
        .OUTA(led_lfosc_shreg1),
        .OUTB(led_lfosc_shreg2)
    );

    reg[15:0] led_lfosc_infreg = 0;
    assign led_lfosc_shreg1a = led_lfosc_infreg[7];
    assign led_lfosc_shreg2a = led_lfosc_infreg[15];
    always @(posedge clk_108hz) begin
        led_lfosc_infreg    <= {led_lfosc_infreg[14:0], led_lfosc_ff};
    end
endmodule