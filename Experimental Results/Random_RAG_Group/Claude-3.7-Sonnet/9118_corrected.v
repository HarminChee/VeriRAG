`timescale 1ns / 1ns
`default_nettype none
`timescale 1ns / 1ns
`default_nettype none
module tld_zxuno (
   input wire clk50mhz,
   input wire test_i,
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
   wire wssclk_unbuf,sysclk_unbuf;
   wire clk14_unbuf = divs[0];
   wire clk7_unbuf = divs[1];
   wire wssclk,sysclk,clk14,clk7;

   assign wssclk = test_i ? clk50mhz : wssclk_unbuf;
   assign sysclk = test_i ? clk50mhz : sysclk_unbuf;
   assign clk14 = test_i ? clk50mhz : clk14_unbuf;
   assign clk7  = test_i ? clk50mhz : clk7_unbuf;

   always @(posedge sysclk)
      divs <= divs + 1;
   relojes los_relojes_del_sistema (
    .CLKIN_IN(clk50mhz), 
    .CLKDV_OUT(wssclk_unbuf), 
    .CLKFX_OUT(sysclk_unbuf), 
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