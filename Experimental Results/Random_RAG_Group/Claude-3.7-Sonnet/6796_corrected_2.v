module data_vio
  (
    control,
    clk,
    async_in,
    async_out,
    sync_in,
    sync_out,
    test_mode
  );
  inout  [35:0] control;
  input         clk;
  input  [31:0] async_in;
  output [31:0] async_out;
  input  [31:0] sync_in;
  output [31:0] sync_out;
  input         test_mode;
endmodule

module icon
  (
      control0,
      control1,
      control2,
      control3,
      test_mode
  );
  inout [35:0] control0;
  inout [35:0] control1;
  inout [35:0] control2;
  inout [35:0] control3;
  input        test_mode;
endmodule

module ila
  (
    control,
    clk,
    trig0,
    test_mode
  );
  inout [35:0]  control;
  input         clk;
  input [163:0] trig0;
  input         test_mode;
endmodule

`timescale 1ns / 1ps
`define DLY #1
module mgtTop # 
(
    parameter EXAMPLE_CONFIG_INDEPENDENT_LANES     =   1,
    parameter EXAMPLE_LANE_WITH_START_CHAR         =   0,   
    parameter EXAMPLE_WORDS_IN_BRAM                =   512, 
    parameter EXAMPLE_SIM_GTRESET_SPEEDUP          =   "TRUE",   
    parameter EXAMPLE_USE_CHIPSCOPE                =   0    
)
(
    input wire  Q0_CLK0_GTREFCLK_PAD_N_IN,
    input wire  Q0_CLK0_GTREFCLK_PAD_P_IN,
    input wire  Q0_CLK1_GTREFCLK_PAD_N_IN,
    input wire  Q0_CLK1_GTREFCLK_PAD_P_IN,
    input wire  Q1_CLK0_GTREFCLK_PAD_N_IN,
    input wire  Q1_CLK0_GTREFCLK_PAD_P_IN,
    input wire  Q1_CLK1_GTREFCLK_PAD_N_IN,
    input wire  Q1_CLK1_GTREFCLK_PAD_P_IN,
    input wire  SYSCLK_IN,
    input wire  GTTXRESET_IN,
    input wire  GTRXRESET_IN,
    output wire TRACK_DATA_OUT,
    input  wire [7:0]   RXN_IN,
    input  wire [7:0]   RXP_IN,
    output wire [7:0]   TXN_OUT,
    output wire [7:0]   TXP_OUT,
    input wire          wb_clk,
    input wire          wb_reset,
    input wire          wb_stb_i,
    output reg [31:0]   wb_dat_o,
    input wire [31:0]   wb_dat_i,
    output reg          wb_ack_o,
    input wire [31:0]   wb_adr_i,
    input wire          wb_we_i,
    input wire          wb_cyc_i,
    input wire [3:0]    wb_sel_i,
    output wire         wb_err_o,
    output reg          wb_rty_o,
    input wire          test_mode
);

// ... existing code ...

endmodule