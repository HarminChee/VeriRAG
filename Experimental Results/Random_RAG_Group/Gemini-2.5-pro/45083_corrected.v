`default_nettype none
module Dac(bg_ok, vout, vout2, wave_sync, test_i, rst, clk);
    output wire bg_ok;
    output wire vout;
    output wire vout2;
    output wire wave_sync;
    input wire test_i;
    input wire rst;
    input wire clk;
    
    wire por_done;
    wire dft_rst;
    GP_POR #(
        .POR_TIME(500)
    ) por (
        .RST_DONE(por_done)
    );
    
    wire clk_1730hz;
    wire dft_clk;
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
        .VIN(1'b0),
        .VOUT(vref_1v0)
    );
    
    localparam COUNT_MAX = 255;
    reg[7:0] count = COUNT_MAX;
    
    assign dft_rst = test_i ? rst : por_done;
    assign dft_clk = test_i ? clk : clk_1730hz;
    
    always @(posedge dft_clk or posedge dft_rst) begin
        if(dft_rst)
            count <= COUNT_MAX;
        else if(count == 0)
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
        .DIN(8'hff),
        .VOUT(vdac2),
        .VREF(vref_1v0)
    );
    
    GP_VREF #(
        .VIN_DIV(4'd1),
        .VREF(16'd00)
    ) vrdac (
        .VIN(vdac2),
        .VOUT(vout2)
    );
endmodule