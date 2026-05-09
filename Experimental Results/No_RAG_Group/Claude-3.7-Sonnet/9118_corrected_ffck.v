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

   wire wssclk, sysclk;
   wire clk14, clk7;

   relojes los_relojes_del_sistema (
    .CLKIN_IN(clk50mhz),
    .CLKDV_OUT(wssclk),
    .CLKFX_OUT(sysclk),
    .CLK14_OUT(clk14),
    .CLK7_OUT(clk7),
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