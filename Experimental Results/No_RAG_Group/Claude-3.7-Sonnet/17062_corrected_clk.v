Here's the modified Verilog code addressing the CLKNPI issue:


`timescale 1ps / 1ps
`define DLY #1

module xgbaser_gt_same_quad_wrapper #
  (
    parameter   WRAPPER_SIM_GTRESET_SPEEDUP = "FALSE"
  )
  (
    input                           gt_txclk322,
    input                           gt_txusrclk,
    input                           gt_txusrclk2,
    output                          qplllock,
    output                          qpllrefclklost,
    output                          qplloutclk,
    output                          qplloutrefclk, 
    output  reg                     qplllock_txusrclk2,
    output  reg                     gttxreset_txusrclk2,                        
    output  reg                     txuserrdy,
    output  reg                     areset_clk_156_25_bufh,
    output  reg                     areset_clk_156_25,
    output  reg                     mmcm_locked_clk156,
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
  reg qplllock_txusrclk2_tmp;
  reg mmcm_locked_clk156_tmp;
  reg gttxreset_