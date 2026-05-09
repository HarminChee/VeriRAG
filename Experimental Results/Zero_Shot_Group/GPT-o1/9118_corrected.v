`timescale 1ns / 1ns
`default_nettype none

module tld_zxuno (
    input wire clk50mhz,
    output wire [2:0] r,
    output wire [2:0] g,
    output wire [2:0] b,
    output wire csync,
    output wire stdn,
    output wire stdnb
);
    assign stdn = 1'b0;
    assign stdnb = 1'b1;

    reg [1:0] divs = 2'b00;
    wire wssclk, sysclk;
    wire clk14 = divs[0];
    wire clk7 = divs[1];

    always @(posedge sysclk) begin
        divs <= divs + 1;
    end

    relojes los_relojes_del_sistema (
        .CLKIN_IN(clk50mhz),
        .CLKDV_OUT(wssclk),
        .CLKFX_OUT(sysclk),
        .CLKIN_IBUFG_OUT(),
        .CLK0_OUT(),
        .LOCKED_OUT()
    );

    zxuno la_maquina (
        .clk(clk7),
        .wssclk(wssclk),
        .r(r),
        .g(g),
        .b(b),
        .csync(csync)
    );
endmodule

module relojes(
    input wire CLKIN_IN,
    output wire CLKDV_OUT,
    output wire CLKFX_OUT,
    output wire CLKIN_IBUFG_OUT,
    output wire CLK0_OUT,
    output wire LOCKED_OUT
);
    assign CLKDV_OUT = 1'b0;
    assign CLKFX_OUT = 1'b0;
    assign CLKIN_IBUFG_OUT = 1'b0;
    assign CLK0_OUT = 1'b0;
    assign LOCKED_OUT = 1'b0;
endmodule

module zxuno(
    input wire clk,
    input wire wssclk,
    output wire [2:0] r,
    output wire [2:0] g,
    output wire [2:0] b,
    output wire csync
);
    assign r = 3'b000;
    assign g = 3'b000;
    assign b = 3'b000;
    assign csync = 1'b0;
endmodule

`default_nettype wire