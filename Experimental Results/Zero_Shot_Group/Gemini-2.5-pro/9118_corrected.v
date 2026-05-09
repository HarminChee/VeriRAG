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
   wire wssclk;
   wire sysclk; // Declare sysclk before use

   // Instantiate clock generator first
   relojes los_relojes_del_sistema (
    .CLKIN_IN(clk50mhz),
    .CLKDV_OUT(wssclk),
    .CLKFX_OUT(sysclk),
    .CLKIN_IBUFG_OUT(), // Assuming these outputs are not needed at this level
    .CLK0_OUT(),        // Assuming these outputs are not needed at this level
    .LOCKED_OUT()       // Assuming these outputs are not needed at this level
    );

   // Clock divider logic using the generated sysclk
   // Note: Generating clocks this way (combinational assignment from counter)
   // is generally discouraged due to potential glitches.
   // Consider using dedicated clock enables or clock management resources.
   wire clk14 = divs[0];
   wire clk7  = divs[1];

   always @(posedge sysclk) begin
      divs <= divs + 1;
   end

   // Instantiate the main core
   zxuno la_maquina (
    .clk(clk7),         // Using the divided clock
    .wssclk(wssclk),    // Using the clock from relojes
    .r(r),
    .g(g),
    .b(b),
    .csync(csync)
    );

endmodule