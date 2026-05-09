`timescale 1ns / 1ns
`default_nettype none
`timescale 1ns / 1ns
`default_nettype none
module tld_zxuno (
   input wire clk50mhz,
   input wire test_i, // Added test input
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
   wire wssclk,sysclk;
   wire clk14 = divs[0]; // This signal itself isn't a violation unless used as a clock
   wire clk7 = divs[1];  // This signal itself isn't a violation unless used as a clock

   // Clock divider clocked by sysclk (derived from primary input clk50mhz via relojes)
   // This FF itself is DFT-friendly regarding its clock source.
   always @(posedge sysclk)
      divs <= divs + 1;

   // Clock generator instance (assumed DFT-friendly, generates clocks from primary input)
   relojes los_relojes_del_sistema (
    .CLKIN_IN(clk50mhz),
    .CLKDV_OUT(wssclk),
    .CLKFX_OUT(sysclk),
    .CLKIN_IBUFG_OUT(),
    .CLK0_OUT(),
    .LOCKED_OUT()
    );

   // Instance using the generated clock
   // Corrected: Use sysclk (derived from primary input) instead of clk7 (derived from FF)
   zxuno la_maquina (
    .clk(sysclk), // Changed from clk7 to sysclk to fix FFCKNP/CLKNPI
    .wssclk(wssclk),
    .r(r),
    .g(g),
    .b(b),
    .csync(csync)
    );

endmodule