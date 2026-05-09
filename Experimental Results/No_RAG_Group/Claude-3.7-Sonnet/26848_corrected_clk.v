`timescale 1ps/1ps

module clk_wiz_0_clk_wiz (
  input  clk_in1_p,
  input  clk_in1_n,
  output clk_out1,
  input  reset,
  output locked
);

  wire clk_in1_clk_wiz_0;
  wire clkfbout_clk_wiz_0;
  wire clkfbout_buf_clk_wiz_0;
  wire locked_int;
  wire clk_out1_clk_wiz_0;


  IBUFDS clkin1_ibufgds (
    .O  (clk_in1_clk_wiz_0),
    .I  (clk_in1_p),
    .IB (clk_in1_n)
  );

  PLLE2_ADV #(
    .BANDWIDTH            ("OPTIMIZED"),
    .COMPENSATION         ("ZHOLD"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT        (5),
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE       (4),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (5.0),
    .REF_JITTER1          (0.010)
  ) plle2_adv_inst (
    .CLKFBOUT            (clkfbout_clk_wiz_0),
    .CLKOUT0             (clk_out1_clk_wiz_0),
    .CLKOUT1             (), // Unused outputs must be connected
    .CLKOUT2             (),
    .CLKOUT3             (),
    .CLKOUT4             (),
    .CLKOUT5             (),
    .CLKFBIN             (clkfbout_buf_clk_wiz_0),
    .CLKIN1              (clk_in1_clk_wiz_0),
    .CLKIN2              (1'b0),
    .CLKINSEL            (1'b1),
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (), // Unused outputs must be connected
    .DRDY                (),
    .DWE                 (1'b0),
    .LOCKED              (locked_int),
    .PWRDWN              (1'b0),
    .RST                 (reset)
  );


  BUFG clkf_buf (
    .O (clkfbout_buf_clk_wiz_0),
    .I (clkfbout_clk_wiz_0)
  );

  BUFG clkout1_buf (
    .O   (clk_out1),
    .I   (clk_out1_clk_wiz_0)
  );


  assign locked = locked_int;

endmodule