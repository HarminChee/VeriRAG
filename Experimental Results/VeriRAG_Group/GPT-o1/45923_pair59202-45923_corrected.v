`timescale 1ps/1ps
module DemoInterconnect_clk_wiz_0_0_clk_wiz
(
  output        aclk,
  output        uart,
  input         reset,
  output        locked,
  input         clk_in1
);
  wire clk_in1_DemoInterconnect_clk_wiz_0_0;
  wire clk_in2_DemoInterconnect_clk_wiz_0_0;
  IBUF clkin1_ibufg
   (
    .O (clk_in1_DemoInterconnect_clk_wiz_0_0),
    .I (clk_in1)
   );
  wire        aclk_DemoInterconnect_clk_wiz_0_0;
  wire        uart_DemoInterconnect_clk_wiz_0_0;
  wire [15:0] do_unused;
  wire        drdy_unused;
  wire        psdone_unused;
  wire        locked_int;
  wire        clkfbout_DemoInterconnect_clk_wiz_0_0;
  wire        clkfbout_buf_DemoInterconnect_clk_wiz_0_0;
  wire        clkfboutb_unused;
  wire        clkout0b_unused;
  wire        clkout1b_unused;
  wire        clkout2_unused;
  wire        clkout2b_unused;
  wire        clkout3_unused;
  wire        clkout3b_unused;
  wire        clkout4_unused;
  wire        clkout5_unused;
  wire        clkout6_unused;
  wire        clkfbstopped_unused;
  wire        clkinstopped_unused;
  wire        reset_high;
  MMCME2_ADV
  #(
    .BANDWIDTH            ("HIGH"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("ZHOLD"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (63.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (10.500),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_DIVIDE       (63),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (83.333)
  )
  mmcm_adv_inst
   (
    .CLKFBOUT            (clkfbout_DemoInterconnect_clk_wiz_0_0),
    .CLKFBOUTB           (clkfboutb_unused),
    .CLKOUT0             (aclk_DemoInterconnect_clk_wiz_0_0),
    .CLKOUT0B            (clkout0b_unused),
    .CLKOUT1             (uart_DemoInterconnect_clk_wiz_0_0),
    .CLKOUT1B            (clkout1b_unused),
    .CLKOUT2             (clkout2_unused),
    .CLKOUT2B            (clkout2b_unused),
    .CLKOUT3             (clkout3_unused),
    .CLKOUT3B            (clkout3b_unused),
    .CLKOUT4             (clkout4_unused),
    .CLKOUT5             (clkout5_unused),
    .CLKOUT6             (clkout6_unused),
    .CLKFBIN             (clkfbout_buf_DemoInterconnect_clk_wiz_0_0),
    .CLKIN1              (clk_in1_DemoInterconnect_clk_wiz_0_0),
    .CLKIN2              (1'b0),
    .CLKINSEL            (1'b1),
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (do_unused),
    .DRDY                (drdy_unused),
    .DWE                 (1'b0),
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (psdone_unused),
    .LOCKED              (locked_int),
    .CLKINSTOPPED        (clkinstopped_unused),
    .CLKFBSTOPPED        (clkfbstopped_unused),
    .PWRDWN              (1'b0),
    .RST                 (reset_high)
   );
  assign reset_high = reset;
  assign locked = locked_int;
  BUFG clkf_buf
   (
    .O (clkfbout_buf_DemoInterconnect_clk_wiz_0_0),
    .I (clkfbout_DemoInterconnect_clk_wiz_0_0)
   );
  BUFG clkout1_buf
   (
    .O (aclk),
    .I (aclk_DemoInterconnect_clk_wiz_0_0)
   );
  BUFG clkout2_buf
   (
    .O (uart),
    .I (uart_DemoInterconnect_clk_wiz_0_0)
   );
endmodule