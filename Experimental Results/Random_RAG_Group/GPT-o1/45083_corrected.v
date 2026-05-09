`timescale 1ns/1ps
`default_nettype none
module Dac(
    input  wire test_i,
    input  wire scan_clk,
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

   wire dft_clk;
   assign dft_clk = test_i ? scan_clk : clk_1730hz;

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

   localparam COUNT_MAX = 8'd255;
   reg [7:0] count = COUNT_MAX;

   always @(posedge dft_clk) begin
      if(count == 8'd0)
         count <= COUNT_MAX;
      else
         count <= count - 8'd1;
   end

   assign wave_sync = (count == 8'd0);

   GP_DAC dac (
      .DIN(count),
      .VOUT(vout),
      .VREF(vref_1v0)
   );

   wire vdac2;
   GP_DAC dac2 (
      .DIN(8'hff),
      .VOUT(vdac2),
      .VREF(vref_1v0)
   );

   GP_VREF #(
      .VIN_DIV(4'd1),
      .VREF(16'd0)
   ) vrdac (
      .VIN(vdac2),
      .VOUT(vout2)
   );
endmodule