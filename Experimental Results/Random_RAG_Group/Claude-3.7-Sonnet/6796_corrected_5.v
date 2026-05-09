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
  assign async_out = async_in;
  assign sync_out = sync_in;
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

assign wb_err_o = 1'b0;

//WB
reg [31:0] mem [0:EXAMPLE_WORDS_IN_BRAM-1];
reg        mem_we;
reg [8:0]   mem_addr;

always @(posedge wb_clk) begin
    if (wb_reset) begin
        wb_dat_o <= 0;
        wb_ack_o <= 0;
        wb_rty_o <= 0;
        mem_we   <= 0;
        mem_addr <= 0;
    end else begin
        wb_ack_o <= 0;
        wb_rty_o <= 0;
        if (wb_stb_i && wb_cyc_i) begin
            wb_ack_o <= 1;
            wb_rty_o <= 0;
            if (wb_we_i) begin
                mem_we   <= 1;
                mem_addr <= wb_adr_i[10:2];
                wb_dat_o <= 0;
                mem[wb_adr_i[10:2]] <= wb_dat_i;
            end else begin
                mem_we   <= 0;
                mem_addr <= wb_adr_i[10:2];
                wb_dat_o <= mem[wb_adr_i[10:2]];
            end
        end else begin
            mem_we <= 0;
        end
    end
end

//assign wb_err_o = 1'b0;

// ... existing code ...
assign TXP_OUT[0] = 1'b0;
assign TXP_OUT[1] = 1'b0;
assign TXP_OUT[2] = 1'b0;
assign TXP_OUT[3] = 1'b0;
assign TXP_OUT[4] = 1'b0;
assign TXP_OUT[5] = 1'b0;
assign TXP_OUT[6] = 1'b0;
assign TXP_OUT[7] = 1'b0;

assign TXN_OUT[0] = 1'b0;
assign TXN_OUT[1] = 1'b0;
assign TXN_OUT[2] = 1'b0;
assign TXN_OUT[3] = 1'b0;
assign TXN_OUT[4] = 1'b0;
assign TXN_OUT[5] = 1'b0;
assign TXN_OUT[6] = 1'b0;
assign TXN_OUT[7] = 1'b0;

assign TRACK_DATA_OUT = 1'b0;

endmodule