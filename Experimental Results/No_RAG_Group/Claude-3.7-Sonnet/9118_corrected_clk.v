`timescale 1ns / 1ns
`default_nettype none
module tld_zxuno (
   input wire clk50mhz,
   input wire scan_clk,  // Added primary input clock for scan
   output wire [2:0] r,
   output wire [2:0] g,
   output wire [2:0] b,
   output wire csync,
   output wire stdn,
   output wire stdnb
   );
   assign stdn = 1'b0;
   assign stdnb = 1'b1;
   reg [1:0] divs;
   wire wssclk,sysclk;
   wire clk14, clk7;
   
   assign clk14 = scan_clk;  // Use primary input clock
   assign clk7 = scan_clk;   // Use primary input clock
   
   relojes los_relojes_del_sistema (
    .CLKIN_IN(clk50mhz), 
    .CLKDV_OUT(wssclk), 
    .CLKFX_OUT(sysclk), 
    .CLKIN_IBUFG_OUT(), 
    .CLK0_OUT(), 
    .LOCKED_OUT()
    );
   
   zxuno la_maquina (
    .clk(scan_clk),    // Use primary input clock
    .wssclk(wssclk),
    .r(r),
    .g(g),
    .b(b),
    .csync(csync)
    );
endmodule