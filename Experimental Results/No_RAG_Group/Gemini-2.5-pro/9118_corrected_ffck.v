`timescale 1ns / 1ns
`default_nettype none
// File: 1_corrected_ffc.v
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

   // Clock enable signal generated synchronously to sysclk
   // This enable controls the logic previously clocked by the divided clock (clk7)
   wire clk7_en = (divs == 2'b11); // Example: enable once every 4 sysclk cycles

   // Counter for generating clock enable
   always @(posedge sysclk) begin
      divs <= divs + 1;
   end

   // Instantiate clock generator (PLL/DCM)
   relojes los_relojes_del_sistema (
    .CLKIN_IN(clk50mhz),
    .CLKDV_OUT(wssclk),
    .CLKFX_OUT(sysclk), // Use this primary-derived clock
    .CLKIN_IBUFG_OUT(),
    .CLK0_OUT(),
    .LOCKED_OUT()
    );

   // Instantiate the core logic
   // It is assumed that the 'zxuno' module has been modified to accept
   // 'sysclk' as its clock input and 'clk7_en' as a clock enable signal.
   zxuno la_maquina (
    .clk(sysclk),        // Connect to primary-derived clock 'sysclk'
    .clk_en(clk7_en),    // Provide the synchronous clock enable
    .wssclk(wssclk),
    .r(r),
    .g(g),
    .b(b),
    .csync(csync)
    );

endmodule