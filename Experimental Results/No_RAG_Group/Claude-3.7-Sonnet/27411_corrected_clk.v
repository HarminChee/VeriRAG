Here's the corrected Verilog code:


`timescale 1ns / 1ps
module clock
(
    input wire reset_in,
    input wire clk_10mhz_int,
    input wire clk_10mhz_ext,
    input wire clk_250mhz_in,
    output wire clk_250mhz_int,
    output wire rst_250mhz_int,
    output wire clk_250mhz,
    output wire rst_250mhz,
    output wire clk_10mhz,
    output wire rst_10mhz,
    output wire ext_clock_selected
);

// ... existing code ...

wire clk_250mhz_int_dcm;
wire clk_250mhz_ext_dcm;
wire clk_250mhz_ext;
wire clk_250mhz_to_pll;
wire clk_250mhz_pll;
wire clk_10mhz_pll;
wire pll_clkfb;
wire pll_reset;
wire pll_locked;

// ... existing code ...

IBUFG
clk_250mhz_ibufg_inst
(
    .I(clk_250mhz_in),
    .O(clk_250mhz_to_pll)
);

// ... existing code ...

BUFGMUX #
(
    .CLK_SEL_TYPE("ASYNC")
)
clk_250mhz_bufgmux_inst
(
    .I0(clk_250mhz_int_dcm),
    .I1(clk_250mhz_to_pll),
    .S(clk_out_select),
    .O(clk_250mhz_to_pll)
);

PLL_ADV #
(
    .BANDWIDTH          ("LOW"),
    .CLKIN1_PERIOD      (4.0),
    .CLKIN2_PERIOD      (4.0),
    .CLKOUT0_DIVIDE     (2),
    .CLKOUT1_DIVIDE     (50),
    .CLKOUT2_DIVIDE     (1),
    .CLKOUT3_DIVIDE     (1),
    .CLKOUT4_DIVIDE     (1),
    .CLKOUT5_DIVIDE     (1),
    .CLKOUT0_PHASE      (0.000),
    .CLKOUT1_PHASE      (0.000),
    .CLKOUT2_PHASE      (0.000),
    .CLKOUT3_PHASE      (0.000),
    .CLKOUT4_PHASE      (0.000),
    .CLKOUT5_PHASE      (0.000),
    .CLKOUT0_DUTY_CYCLE (0.500),
    .CLKOUT1_DUTY_CYCLE (0.500),
    .CLKOUT2_DUTY_CYCLE (0.500),
    .CLKOUT3_DUTY_CYCLE (0.500),
    .CLKOUT4_DUTY_CYCLE (0.500),
    .CLKOUT5_DUTY_CYCLE (0.500),
    .SIM_DEVICE         ("SPARTAN6"),
    .COMPENSATION       ("SYSTEM_SYNCHRONOUS"),
    .DIVCLK_DIVIDE      (1),
    .CLKFBOUT_MULT      (2),
    .CLKFBOUT_PHASE     (0.0),
    .REF_JITTER         (0.025000)
)
clk_250mhz_pll_inst
(
    .CLKFBIN     (pll_clkfb),
    .CLKINSEL    (1'b1),
    .CLKIN1      (clk_250mhz_to_pll),
    .CLKIN2      (1'b0),
    .DADDR       (5'b0),
    .DCLK        (1'b0),
    .DEN         (1'b0),
    .DI          (16'b0),
    .DWE         (1'b0),
    .REL         (1'b0),
    .RST         (pll_reset),
    .CLKFBDCM    (),
    .CLKFBOUT    (pll_clkfb),
    .CLKOUTDCM0  (),
    .CLKOUTDCM1  (),
    .CLKOUTDCM2  (),
    .CLKOUTDCM3  (),
    .CLKOUTDCM4  (),
    .CLKOUTDCM5  (),
    .CLKOUT0     (clk_250mhz_pll),
    .CLKOUT1     (clk_10mhz_pll),
    .CLKOUT2     (),
    .CLKOUT3     (),
    .CLKOUT4     (),
    .CLKOUT5     (),
    .DO          (),
    .DRDY        (),
    .LOCKED      (pll_locked)
);

// ... existing code ...

endmodule