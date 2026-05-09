`default_nettype none
module Ethernet(txd, lcw, burst_start, link_up, test_i, rst, clk);
    output wire txd;
    output wire lcw;
    output wire burst_start;
    output wire link_up;
    input  wire test_i;
    input  wire rst;
    input  wire clk;
    
    wire por_done;
    GP_POR #(.POR_TIME(500)) por (.RST_DONE(por_done));
    
    wire clk_hardip;
    wire clk_fabric;
    wire dft_clk_hardip;
    wire dft_clk_fabric;
    GP_RCOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0),
        .OSC_FREQ("2M"),
        .HARDIP_DIV(1),
        .FABRIC_DIV(1)
    ) rcosc (
        .PWRDN(1'b0),
        .CLKOUT_HARDIP(clk_hardip),
        .CLKOUT_FABRIC(clk_fabric)
    );
    
    assign dft_clk_hardip = test_i ? clk : clk_hardip;
    assign dft_clk_fabric = test_i ? clk : clk_fabric;
    
    reg pulse_en = 0;
    GP_EDGEDET #(
        .DELAY_STEPS(1),
        .EDGE_DIRECTION("RISING"),
        .GLITCH_FILTER(0)
    ) delay(
        .IN(pulse_en),
        .OUT(txd)
    );
    
    localparam PULSE_INTERVAL = 124;
    reg[7:0] pulse_count = PULSE_INTERVAL;
    wire pulse_start = (pulse_count == 0);
    always @(posedge dft_clk_hardip or posedge rst) begin
        if (rst)
            pulse_count <= PULSE_INTERVAL;
        else if (pulse_count == 0)
            pulse_count <= PULSE_INTERVAL;
        else
            pulse_count <= pulse_count - 1'd1;
    end
    
    localparam BURST_INTERVAL = 15999;
    reg[13:0] interval_count = BURST_INTERVAL;
    wire burst_start_raw = (interval_count == 0);
    always @(posedge dft_clk_hardip or posedge rst) begin
        if (rst)
            interval_count <= BURST_INTERVAL;
        else if (interval_count == 0)
            interval_count <= BURST_INTERVAL;
        else
            interval_count <= interval_count - 1'd1;
    end
    
    reg burst_start_t = 0;
    reg burst_start = 0;
    always @(posedge dft_clk_fabric or posedge rst) begin
        if (rst) begin
            burst_start <= 0;
            burst_start_t <= 0;
        end else begin
            burst_start <= 0;
            if (burst_start_raw)
                burst_start_t <= !burst_start_t;
            if (burst_start_t && burst_start_raw)
                burst_start <= 1;
        end
    end
    
    wire linkup_en;
    GP_COUNT14_ADV #(
        .CLKIN_DIVIDE(1),
        .COUNT_TO(128),
        .RESET_MODE("RISING"),
        .RESET_VALUE("COUNT_TO")
    ) linkup_count (
        .CLK(dft_clk_hardip),
        .RST(rst),
        .UP(1'b0),
        .KEEP(!burst_start),
        .OUT(linkup_en)
    );
    
    reg pgen_reset = 1;
    reg lcw_advance = 0;
    GP_PGEN #(
        .PATTERN_DATA(16'h8602),
        .PATTERN_LEN(5'd16)
    ) pgen (
        .nRST(pgen_reset),
        .CLK(lcw_advance),
        .OUT(lcw)
    );
    
    wire burst_done;
    GP_COUNT8_ADV #(
        .CLKIN_DIVIDE(1),
        .COUNT_TO(33),
        .RESET_MODE("RISING"),
        .RESET_VALUE("COUNT_TO")
    ) burst_count (
        .CLK(dft_clk_hardip),
        .RST(burst_start | rst),
        .UP(1'b0),
        .KEEP(!pulse_start),
        .OUT(burst_done)
    );
    
    reg next_pulse_is_lcw = 0;
    reg burst_active = 0;
    reg pulse_start_gated = 0;
    reg link_up = 0;
    always @(posedge dft_clk_fabric or posedge rst) begin
        if (rst) begin
            lcw_advance <= 0;
            pulse_en <= 0;
            pgen_reset <= 1;
            link_up <= 0;
            burst_active <= 0;
            next_pulse_is_lcw <= 0;
            pulse_start_gated <= 0;
        end else begin
            lcw_advance <= 0;
            pulse_en <= 0;
            pgen_reset <= 1;
            if (linkup_en)
                link_up <= 1;
            if (burst_start) begin
                burst_active <= 1;
                next_pulse_is_lcw <= 0;
                lcw_advance <= 1;
            end
            else if (burst_done) begin
                burst_active <= 0;
                pgen_reset <= 0;
            end
            else if (link_up && pulse_start) begin
                burst_active <= 0;
            end
            pulse_start_gated <= burst_active && pulse_start;
            if (pulse_en && next_pulse_is_lcw)
                lcw_advance <= 1;
            if (pulse_start_gated) begin
                if (next_pulse_is_lcw)
                    pulse_en <= lcw;
                else
                    pulse_en <= 1'b1;
                next_pulse_is_lcw <= ~next_pulse_is_lcw;
            end
        end
    end
endmodule