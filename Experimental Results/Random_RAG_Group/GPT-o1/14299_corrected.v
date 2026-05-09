`timescale 1ns / 1ps
module clk_reset(
    input clk_in,
    input reset_in_n,
    output sdram_clk,
    input sdram_fb,
    output clk,
    output clk_ok,
    output reset
);
  wire clk_in_buf;
  wire int_clk;
  wire int_locked;
  wire ext_fb;
  wire ext_locked;

  IBUFG clk_in_buffer(
    .I(clk_in),
    .O(clk_in_buf)
  );

  DCM int_dcm(
    .CLKIN(clk_in_buf),
    .CLKFB(clk),
    .RST(~reset_in_n),
    .CLK0(int_clk),
    .LOCKED(int_locked)
  );

  BUFG int_clk_buffer(
    .I(int_clk),
    .O(clk)
  );

  IBUFG ext_fb_buffer(
    .I(sdram_fb),
    .O(ext_fb)
  );

  DCM ext_dcm(
    .CLKIN(clk_in_buf),
    .CLKFB(ext_fb),
    .RST(~reset_in_n),
    .CLK0(sdram_clk),
    .LOCKED(ext_locked)
  );

  assign clk_ok = int_locked & ext_locked;
  assign reset  = ~reset_in_n | ~clk_ok;

endmodule