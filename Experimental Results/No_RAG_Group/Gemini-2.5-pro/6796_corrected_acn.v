`timescale 1ns / 1ps
`define DLY #1

module data_vio (
    input [35:0] control,
    input clk,
    input [31:0] async_in,
    input [31:0] async_out,
    input [31:0] sync_in,
    input [31:0] sync_out
);
endmodule

module icon (
    input [35:0] control0,
    input [35:0] control1, 
    input [35:0] control2,
    input [35:0] control3
);
endmodule

module ila (
    input [35:0] control,
    input clk,
    input [163:0] trig0
);
endmodule

module mgtTop #(
    parameter EXAMPLE_CONFIG_INDEPENDENT_LANES = 1,
    parameter EXAMPLE_LANE_WITH_START_CHAR = 0,
    parameter EXAMPLE_WORDS_IN_BRAM = 512,
    parameter EXAMPLE_SIM_GTRESET_SPEEDUP = "TRUE",
    parameter EXAMPLE_USE_CHIPSCOPE = 0
)(
    input wire Q0_CLK0_GTREFCLK_PAD_N_IN,
    input wire Q0_CLK0_GTREFCLK_PAD_P_IN,
    input wire Q0_CLK1_GTREFCLK_PAD_N_IN,
    input wire Q0_CLK1_GTREFCLK_PAD_P_IN,
    input wire Q1_CLK0_GTREFCLK_PAD_N_IN,
    input wire Q1_CLK0_GTREFCLK_PAD_P_IN,
    input wire Q1_CLK1_GTREFCLK_PAD_N_IN,
    input wire Q1_CLK1_GTREFCLK_PAD_P_IN,
    input wire SYSCLK_IN,
    input wire GTTXRESET_IN,
    input wire GTRXRESET_IN,
    output wire TRACK_DATA_OUT,
    input wire [7:0] RXN_IN,
    input wire [7:0] RXP_IN,
    output wire [7:0] TXN_OUT,
    output wire [7:0] TXP_OUT,
    input wire wb_clk,
    input wire wb_reset,
    input wire wb_stb_i,
    output reg [31:0] wb_dat_o,
    input wire [31:0] wb_dat_i,
    output reg wb_ack_o,
    input wire [31:0] wb_adr_i,
    input wire wb_we_i,
    input wire wb_cyc_i,
    input wire [3:0] wb_sel_i,
    output wire wb_err_o,
    output reg wb_rty_o
);

// ... existing code ...

// Fix for ACNCPI - Add primary input reset ports
input wire gt0_async_reset,
input wire gt1_async_reset,
input wire gt2_async_reset,
input wire gt3_async_reset,
input wire gt4_async_reset,
input wire gt5_async_reset,
input wire gt6_async_reset,
input wire gt7_async_reset;

// Use primary input resets instead of internal signals
assign gt0_gtrxreset_i = gt0_async_reset;
assign gt0_gttxreset_i = gt0_async_reset;
assign gt0_cpllreset_i = gt0_async_reset;

assign gt1_gtrxreset_i = gt1_async_reset;
assign gt1_gttxreset_i = gt1_async_reset;
assign gt1_cpllreset_i = gt1_async_reset;

assign gt2_gtrxreset_i = gt2_async_reset;
assign gt2_gttxreset_i = gt2_async_reset;
assign gt2_cpllreset_i = gt2_async_reset;

assign gt3_gtrxreset_i = gt3_async_reset;
assign gt3_gttxreset_i = gt3_async_reset;
assign gt3_cpllreset_i = gt3_async_reset;

assign gt4_gtrxreset_i = gt4_async_reset;
assign gt4_gttxreset_i = gt4_async_reset;
assign gt4_cpllreset_i = gt4_async_reset;

assign gt5_gtrxreset_i = gt5_async_reset;
assign gt5_gttxreset_i = gt5_async_reset;
assign gt5_cpllreset_i = gt5_async_reset;

assign gt6_gtrxreset_i = gt6_async_reset;
assign gt6_gttxreset_i = gt6_async_reset;
assign gt6_cpllreset_i = gt6_async_reset;

assign gt7_gtrxreset_i = gt7_async_reset;
assign gt7_gttxreset_i = gt7_async_reset;
assign gt7_cpllreset_i = gt7_async_reset;

// ... rest of existing code ...

endmodule