`timescale 1ps / 1ps
`define DLY #1
module xgbaser_gt_same_quad_wrapper_corrected_clk #
  (
    parameter   WRAPPER_SIM_GTRESET_SPEEDUP = "FALSE"
  )
  (
    input                           gt_txclk322,
    output                          gt_txusrclk,
    output                          gt_txusrclk2,
    output                          qplllock,
    output                          qpllrefclklost,
    output                          qplloutclk,
    output                          qplloutrefclk,
    output                          qplllock_txusrclk2, // Changed from reg
    output  reg                     gttxreset_txusrclk2,
    output  reg                     txuserrdy,
    output  reg                     areset_clk_156_25_bufh,
    output  reg                     areset_clk_156_25,
    output                          mmcm_locked_clk156, // Changed from reg
    output                          reset_counter_done,
    output reg                      core_reset,
    input                           gt0_tx_resetdone,
    input                           gt1_tx_resetdone,
    input                           gt2_tx_resetdone,
    input                           gt3_tx_resetdone,
    input                           tx_fault,
    output                          gttxreset,
    output                          gtrxreset,
    input                           gt_refclk,
    output                          clk156,
    output                          dclk,
    input                           areset
 );
  wire clk_156_25_bufh;
  wire clk156_buf;
  wire dclk_buf;
  wire clkfbout;
  wire mmcm_locked;
  wire qpllreset;
  reg [7:0] reset_counter = 8'd0;
  reg [3:0] reset_pulse;
  wire            tied_to_ground_i;
  wire    [63:0]  tied_to_ground_vec_i;
  wire            tied_to_vcc_i;
  wire    [7:0]   tied_to_vcc_vec_i;
  assign tied_to_ground_i             = 1'b0;
  assign tied_to_ground_vec_i         = 64'h0000000000000000;
  assign tied_to_vcc_i                = 1'b1;
  assign tied_to_vcc_vec_i            = 8'hff;

  reg core_reset_tmp;
  reg areset_clk_156_25_bufh_tmp;
  reg areset_clk156_25_tmp;
  // Removed tmp regs for signals handled by synchronizers or direct assignment
  // reg qplllock_txusrclk2_tmp;
  // reg mmcm_locked_clk156_tmp;
  // reg gttxreset_txusrclk2_tmp; // Removed as gttxreset_txusrclk2 is now directly assigned based on gttxreset

  MMCME2_BASE
  #(.BANDWIDTH            ("OPTIMIZED"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (6.500),
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE_F     (6.500),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT1_DIVIDE       (13),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (6.4),
    .REF_JITTER1          (0.010))
  clkgen_i
  (
    .CLKFBIN(clkfbout),
    .CLKIN1(clk_156_25_bufh), // Derived from gt_refclk (Primary Input)
    .PWRDWN(1'b0),
    .RST(!qplllock), // This reset is internal, potential issue but not a clock violation itself
    .CLKFBOUT(clkfbout),
    .CLKOUT0(clk156_buf),
    .CLKOUT1(dclk_buf),
    .LOCKED(mmcm_locked)
  );

  BUFG clk156_bufg_inst
  (
      .I                              (clk156_buf),
      .O                              (clk156) // Derived from gt_refclk -> OK
  );

  BUFG dclk_bufg_inst
  (