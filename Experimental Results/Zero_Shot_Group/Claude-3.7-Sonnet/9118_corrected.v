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
   wire wssclk,sysclk;
   wire clk14 = divs[0];
   wire clk7 = divs[1];
   always @(posedge sysclk)
      divs <= divs + 1;
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

module relojes (
    input CLKIN_IN,
    output CLKDV_OUT,
    output CLKFX_OUT,
    output CLKIN_IBUFG_OUT,
    output CLK0_OUT,
    output LOCKED_OUT
);

    // Clocking PRIMITIVE
    // Input clock buffering / modification 
   wire clkin1_buf;
   IBUFG clkin1_ibufg (.I(CLKIN_IN), .O(clkin1_buf));
   defparam clkin1_ibufg.IOSTANDARD = "DEFAULT";

   wire clkfbout_buf;
   wire clkfbout;
   BUFG clkfbout_buf_i (.I(clkfbout), .O(clkfbout_buf));
   defparam clkfbout_buf_i.IOSTANDARD = "DEFAULT";

   wire clkout0_buf;
   BUFG clkout0_buf_i (.I(CLK0_OUT), .O(clkout0_buf));
   defparam clkout0_buf_i.IOSTANDARD = "DEFAULT";

   wire clkoutdv_buf;
   BUFG clkoutdv_buf_i (.I(CLKDV_OUT), .O(clkoutdv_buf));
   defparam clkoutdv_buf_i.IOSTANDARD = "DEFAULT";

   wire clkoutfx_buf;
   BUFG clkoutfx_buf_i (.I(CLKFX_OUT), .O(clkoutfx_buf));
   defparam clkoutfx_buf_i.IOSTANDARD = "DEFAULT";

   // Clock generator
   wire locked;
  
   CLK_WIZ_V3_6 #(
      .BANDWIDTH("OPTIMIZED"),
      .CLKOUT1_JITTER(0.098),
      .CLKOUT1_NAME("CLK0"),
      .CLKOUT2_JITTER(0.283),
      .CLKOUT2_NAME("CLKDV"),
      .CLKOUT3_JITTER(0.283),
      .CLKOUT3_NAME("CLKFX"),
      .CLK_IN1_BOARD_INTERFACE(""),
      .CLK_IN1_JITTER(0.000),
      .CLK_IN1_NAME("clk50mhz"),
      .CLK_IN1_PERIOD(20.000),
      .CLK_OUT1_DIVIDE(1),
      .CLK_OUT1_DUTY_CYCLE(0.500),
      .CLK_OUT1_PHASE(0.000),
      .CLK_OUT2_DIVIDE(10),
      .CLK_OUT2_DUTY_CYCLE(0.500),
      .CLK_OUT2_PHASE(0.000),
      .CLK_OUT3_DIVIDE(3),
      .CLK_OUT3_DUTY_CYCLE(0.500),
      .CLK_OUT3_PHASE(0.000),
      .CLK_OUT4_DIVIDE(1),
      .CLK_OUT4_DUTY_CYCLE(0.500),
      .CLK_OUT4_PHASE(0.000),
      .CLK_OUT5_DIVIDE(1),
      .CLK_OUT5_DUTY_CYCLE(0.500),
      .CLK_OUT5_PHASE(0.000),
      .CLK_OUT6_DIVIDE(1),
      .CLK_OUT6_DUTY_CYCLE(0.500),
      .CLK_OUT6_PHASE(0.000),
      .CLK_OUT7_DIVIDE(1),
      .CLK_OUT7_DUTY_CYCLE(0.500),
      .CLK_OUT7_PHASE(0.000),
      .CLK_USE_FINE_PS("FALSE"),
      .DESKEW_ADJUST(0),
      .DIVCLK_DIVIDE(1),
      .IS_CASCADE("FALSE"),
      .MMCM_CLKFX_DIVIDE_BY_4(FALSE),
      .MMCM_COMPENSATION("AUTO"),
      .MMCM_DIVCLK_DIVIDE(1),
      .MMCM_MULT_INT(6),
      .MMCM_MULT_FRAC(0.000),
      .MMCM_CLKOUT0_DIVIDE_F(1.000),
      .MMCM_CLKOUT1_DIVIDE(5.0),
      .MMCM_CLKOUT2_DIVIDE(1.5),
      .MMCM_CLKOUT3_DIVIDE(1),
      .MMCM_CLKOUT4_DIVIDE(1),
      .MMCM_CLKOUT5_DIVIDE(1),
      .MMCM_CLKOUT6_DIVIDE(1),
      .MMCM_CLKOUTDRIVES("4"),
      .MMCM_CLKOUTPHASE(0.000),
      .MMCM_CLKOUTPHASE_FINE(0.000),
      .MMCM_CLKFBOUT_MULT_F(6.000),
      .MMCM_CLKFBOUT_PHASE(0.000),
      .MMCM_CLKFBOUT_USE_FINE_PS("FALSE"),
      .MMCM_CLKIN1_PERIOD(20.000),
      .MMCM_REF_JITTER1(0.010),
      .MMCM_SS_EN("FALSE"),
      .MMCM_SS_MODE("CENTER_HIGH"),
      .MMCM_SS_MOD_PERIOD(10000),
      .MMCM_STARTUP_WAIT("FALSE"),
      .NUM_OUT_PORTS(3),
      .OVERRIDE_MMCM(""),
      .REF_JITTER1(0.010),
      .SS_EN("FALSE"),
      .SS_MODE("CENTER_HIGH"),
      .SS_MOD_PERIOD(10000),
      .STARTUP_WAIT("FALSE")
   )
   clk_wiz_inst (
      .CLK_IN1(clkin1_buf),
      .CLK_FBIN(clkfbout_buf),
      .CLK_OUT1(CLK0_OUT),
      .CLK_OUT2(CLKDV_OUT),
      .CLK_OUT3(CLKFX_OUT),
      .CLK_OUT4(),
      .CLK_OUT5(),
      .CLK_OUT6(),
      .CLK_OUT7(),
      .LOCKED(locked),
      .CLK_FBIN_BUF(clkfbout_buf),
      .CLK_IN1_BUF(clkin1_buf)
   );
   defparam clk_wiz_inst.BANDWIDTH = "OPTIMIZED";
   defparam clk_wiz_inst.CLKOUT1_JITTER = 0.098;
   defparam clk_wiz_inst.CLKOUT1_NAME = "CLK0";
   defparam clk_wiz_inst.CLKOUT2_JITTER = 0.283;
   defparam clk_wiz_inst.CLKOUT2_NAME = "CLKDV";
   defparam clk_wiz_inst.CLKOUT3_JITTER = 0.283;
   defparam clk_wiz_inst.CLKOUT3_NAME = "CLKFX";
   defparam clk_wiz_inst.CLK_IN1_BOARD_INTERFACE = "";
   defparam clk_wiz_inst.CLK_IN1_JITTER = 0.000;
   defparam clk_wiz_inst.CLK_IN1_NAME = "clk50mhz";
   defparam clk_wiz_inst.CLK_IN1_PERIOD = 20.000;
   defparam clk_wiz_inst.CLK_OUT1_DIVIDE = 1;
   defparam clk_wiz_inst.CLK_OUT1_DUTY_CYCLE = 0.500;
   defparam clk_wiz_inst.CLK_OUT1_PHASE = 0.000;
   defparam clk_wiz_inst.CLK_OUT2_DIVIDE = 10;
   defparam clk_wiz_inst.CLK_OUT2_DUTY_CYCLE = 0.500;
   defparam clk_wiz_inst.CLK_OUT2_PHASE = 0.000;
   defparam clk_wiz_inst.CLK_OUT3_DIVIDE = 3;
   defparam clk_wiz_inst.CLK_OUT3_DUTY_CYCLE = 0.500;
   defparam clk_wiz_inst.CLK_OUT3_PHASE = 0.000;
   defparam clk_wiz_inst.CLK_OUT4_DIVIDE = 1;
   defparam clk_wiz_inst.CLK_OUT4_DUTY_CYCLE = 0.500;
   defparam clk_wiz_inst.CLK_OUT4_PHASE = 0.000;
   defparam clk_wiz_inst.CLK_OUT5_DIVIDE = 1;
   defparam clk_wiz_inst.CLK_OUT5_DUTY_CYCLE = 0.500;
   defparam clk_wiz_inst.CLK_OUT5_PHASE = 0.000;
   defparam clk_wiz_inst.CLK_OUT6_DIVIDE = 1;
   defparam clk_wiz_inst.CLK_OUT6_DUTY_CYCLE = 0.500;
   defparam clk_wiz_inst.CLK_OUT6_PHASE = 0.000;
   defparam clk_wiz_inst.CLK_OUT7_DIVIDE = 1;
   defparam clk_wiz_inst.CLK_OUT7_DUTY_CYCLE = 0.500;
   defparam clk_wiz_inst.CLK_OUT7_PHASE = 0.000;
   defparam clk_wiz_inst.CLK_USE_FINE_PS = "FALSE";
   defparam clk_wiz_inst.DESKEW_ADJUST = 0;
   defparam clk_wiz_inst.DIVCLK_DIVIDE = 1;
   defparam clk_wiz_inst.IS_CASCADE = "FALSE";
   defparam clk_wiz_inst.MMCM_CLKFX_DIVIDE_BY_4 = FALSE;
   defparam clk_wiz_inst.MMCM_COMPENSATION = "AUTO";
   defparam clk_wiz_inst.MMCM_DIVCLK_DIVIDE = 1;
   defparam clk_wiz_inst.MMCM_MULT_INT = 6;
   defparam clk_wiz_inst.MMCM_MULT_FRAC = 0.000;
   defparam clk_wiz_inst.MMCM_CLKOUT0_DIVIDE_F = 1.000;
   defparam clk_wiz_inst.MMCM_CLKOUT1_DIVIDE = 5.0;
   defparam clk_wiz_inst.MMCM_CLKOUT2_DIVIDE = 1.5;
   defparam clk_wiz_inst.MMCM_CLKOUT3_DIVIDE = 1;
   defparam clk_wiz_inst.MMCM_CLKOUT4_DIVIDE = 1;
   defparam clk_wiz_inst.MMCM_CLKOUT5_DIVIDE = 1;
   defparam clk_wiz_inst.MMCM_CLKOUT6_DIVIDE = 1;
   defparam clk_wiz_inst.MMCM_CLKOUTDRIVES = "4";
   defparam clk_wiz_inst.MMCM_CLKOUTPHASE = 0.000;
   defparam clk_wiz_inst.MMCM_CLKOUTPHASE_FINE = 0.000;
   defparam clk_wiz_inst.MMCM_CLKFBOUT_MULT_F = 6.000;
   defparam clk_wiz_inst.MMCM_CLKFBOUT_PHASE = 0.000;
   defparam clk_wiz_inst.MMCM_CLKFBOUT_USE_FINE_PS = "FALSE";
   defparam clk_wiz_inst.MMCM_CLKIN1_PERIOD = 20.000;
   defparam clk_wiz_inst.MMCM_REF_JITTER1 = 0.010;
   defparam clk_wiz_inst.MMCM_SS_EN = "FALSE";
   defparam clk_wiz_inst.MMCM_SS_MODE = "CENTER_HIGH";
   defparam clk_wiz_inst.MMCM_SS_MOD_PERIOD = 10000;
   defparam clk_wiz_inst.MMCM_STARTUP_WAIT = "FALSE";
   defparam clk_wiz_inst.NUM_OUT_PORTS = 3;
   defparam clk_wiz_inst.OVERRIDE_MMCM = "";
   defparam clk_wiz_inst.REF_JITTER1 = 0.010;
   defparam clk_wiz_inst.SS_EN = "FALSE";
   defparam clk_wiz_inst.SS_MODE = "CENTER_HIGH";
   defparam clk_wiz_inst.SS_MOD_PERIOD = 10000;
   defparam clk_wiz_inst.STARTUP_WAIT = "FALSE";

   assign CLKIN_IBUFG_OUT = clkin1_buf;
   assign LOCKED_OUT = locked;

endmodule

module zxuno (
    input clk,
    input wssclk,
    output [2:0] r,
    output [2:0] g,
    output [2:0] b,
    output csync
);

  // Add your ZX Uno logic here
  assign r = 3'b000;
  assign g = 3'b000;
  assign b = 3'b000;
  assign csync = 1'b0;

endmodule