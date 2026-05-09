`timescale 1ns / 1ps
`timescale 1ns / 1ps
module clock
(
    input wire test_mode,
    input wire reset_in,
    input wire clk_10mhz_int,
    input wire clk_10mhz_ext,
    output wire clk_250mhz_int,
    output wire rst_250mhz_int,
    output wire clk_250mhz,
    output wire rst_250mhz,
    output wire clk_10mhz,
    output wire rst_10mhz,
    output wire ext_clock_selected
);

wire clk_10mhz_int_ibufg;
wire clk_10mhz_int_bufg;
wire clk_10mhz_ext_ibufg;
wire clk_10mhz_ext_bufg;
wire clk_250mhz_int_dcm;
wire clk_250mhz_ext_dcm;
wire clk_250mhz_ext;
wire clk_250mhz_to_pll;
wire clk_250mhz_pll;
wire clk_10mhz_pll;
wire pll_clkfb;
wire pll_reset;
wire pll_locked;
wire rst_10mhz_int;
wire rst_10mhz_ext;
wire rst_250mhz_ext;
wire clk_250mhz_int_dcm_reset;
wire clk_250mhz_int_dcm_locked;
wire [7:0] clk_250mhz_int_dcm_status;
wire clk_250mhz_int_dcm_clkfx_stopped = clk_250mhz_int_dcm_status[1];
wire clk_250mhz_ext_dcm_reset;
wire clk_250mhz_ext_dcm_locked;
wire [7:0] clk_250mhz_ext_dcm_status;
wire clk_250mhz_ext_dcm_clkfx_stopped = clk_250mhz_ext_dcm_status[1];
wire ref_freq_valid;
wire clk_out_select;

wire test_clk_250mhz_int = test_mode ? clk_10mhz_int_bufg : clk_250mhz_int_dcm;
wire test_clk_250mhz_ext = test_mode ? clk_10mhz_ext_bufg : clk_250mhz_ext_dcm;
wire test_clk_250mhz = test_mode ? clk_10mhz_int_bufg : clk_250mhz_pll;
wire test_clk_10mhz = test_mode ? clk_10mhz_int_bufg : clk_10mhz_pll;

assign ext_clock_selected = clk_out_select;

reg reset_output = 0;

reset_stretch #(.N(4)) rst_10mhz_int_inst (
    .clk(clk_10mhz_int_bufg),
    .rst_in(reset_in),
    .rst_out(rst_10mhz_int)
);

// ... existing code ...

BUFGCE
clk_250mhz_bufg_inst
(
    .I(test_clk_250mhz),
    .O(clk_250mhz),
    .CE(pll_locked)
);

BUFGCE
clk_10mhz_bufg_inst
(
    .I(test_clk_10mhz),
    .O(clk_10mhz),
    .CE(pll_locked)
);

endmodule