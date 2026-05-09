`default_nettype none
module Dac(
    input wire clk_in,
    input wire test_mode,
    output wire bg_ok,
    output wire vout,
    output wire vout2,
    output wire wave_sync
);

    wire por_done;
    GP_POR #(
        .POR_TIME(500)
    ) por (
        .RST_DONE(por_done)
    );

    wire clk_1730hz;
    GP_LFOSC #(
        .PWRDN_EN(0),
        .AUTO_PWRDN(0),
        .OUT_DIV(1)
    ) lfosc (
        .PWRDN(1'b0),
        .CLKOUT(clk_1730hz)
    );

    GP_BANDGAP #(
        .AUTO_PWRDN(0),
        .CHOPPER_EN(1),
        .OUT_DELAY(550)
    ) bandgap (
        .OK(bg_ok)
    );

    wire vref_1v0;
    GP_VREF #(
        .VIN_DIV(4'd1),
        .VREF(16'd1000)
    ) vr1000 (
        .VIN(1'b0), // Assuming VIN should be tied low if unused
        .VOUT(vref_1v0)
    );

    localparam COUNT_MAX = 255;
    reg[7:0] count = COUNT_MAX;

    wire dft_clk;
    assign dft_clk = test_mode ? clk_in : clk_1730hz;

    // Assuming no reset is intended for this counter based on original code
    always @(posedge dft_clk) begin
        if(count == 0)
            count <= COUNT_MAX;
        else
            count <= count - 1'd1;
    end

    assign wave_sync = (count == 0);

    GP_DAC dac(
        .DIN(count),
        .VOUT(vout),
        .VREF(vref_1v0)
    );

    wire vdac2;
    GP_DAC dac2(
        .DIN(8'hff), // Constant input
        .VOUT(vdac2),
        .VREF(vref_1v0)
    );

    GP_VREF #(
        .VIN_DIV(4'd1),
        .VREF(16'd00) // VREF = 0
    ) vrdac (
        .VIN(vdac2),
        .VOUT(vout2)
    );

endmodule
`default_nettype wire