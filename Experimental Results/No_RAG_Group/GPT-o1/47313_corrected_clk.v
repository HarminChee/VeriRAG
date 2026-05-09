(1)_corrected_clk.v

`default_nettype none
module Location(
    input wire a,
    input wire b,
    input wire e,
    input wire clk_in,
    output wire c,
    output wire d,
    output wire f
);

    wire por_done;
    GP_POR #(
        .POR_TIME(500)
    ) por (
        .RST_DONE(por_done)
    );

    localparam COUNT_MAX = 31;
    wire led_lfosc_raw;
    GP_COUNT8 #(
        .RESET_MODE("LEVEL"),
        .COUNT_TO(COUNT_MAX),
        .CLKIN_DIVIDE(1)
    ) lfosc_cnt (
        .CLK(clk_in),
        .RST(1'b0),
        .OUT(led_lfosc_raw)
    );

    reg led_out = 1'b0;
    assign c = led_out;
    always @(posedge clk_in) begin
        if(por_done) begin
            if(led_lfosc_raw)
                led_out <= ~led_out;
        end
    end

    wire d_int = (a & b & e);
    assign d = d_int;
    assign f = ~d_int;

endmodule