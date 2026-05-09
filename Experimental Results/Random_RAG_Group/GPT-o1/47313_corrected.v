`default_nettype none
module Location(
    input wire scan_clk,
    input wire test_i,
    input wire a,
    input wire b,
    input wire e,
    output wire c,
    output wire d,
    output wire f
);
    wire clk_108hz;
    GP_LFOSC #(
        .PWRDN_EN(1),
        .AUTO_PWRDN(0),
        .OUT_DIV(16)
    ) lfosc (
        .PWRDN(1'b0),
        .CLKOUT(clk_108hz)
    );

    wire por_done;
    GP_POR #(
        .POR_TIME(500)
    ) por (
        .RST_DONE(por_done)
    );

    localparam COUNT_MAX = 'd31;
    wire led_lfosc_raw;

    wire dft_clk;
    assign dft_clk = test_i ? scan_clk : clk_108hz;

    GP_COUNT8 #(
        .RESET_MODE("LEVEL"),
        .COUNT_TO(COUNT_MAX),
        .CLKIN_DIVIDE(1)
    ) lfosc_cnt (
        .CLK(dft_clk),
        .RST(1'b0),
        .OUT(led_lfosc_raw)
    );

    reg led_out = 0;
    assign c = led_out;
    always @(posedge dft_clk) begin
        if(por_done) begin
            if(led_lfosc_raw)
                led_out <= ~led_out;
        end
    end

    wire d_int = (a & b & e);
    assign d = d_int;
    assign f = ~d_int;
endmodule