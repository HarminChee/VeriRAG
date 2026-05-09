`timescale 1ns / 1ps
`define DLY #1

module data_vio (
    inout  [35:0] control,
    input         clk,
    input  [31:0] async_in,
    output [31:0] async_out,
    input  [31:0] sync_in,
    output [31:0] sync_out
);
endmodule

module icon (
    inout [35:0] control0,
    inout [35:0] control1,
    inout [35:0] control2,
    inout [35:0] control3
);
endmodule

module ila (
    inout [35:0] control,
    input        clk,
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
    output reg          wb_rty_o
);
    reg [127:0] data_o;
    reg [31:0] control_reg;
    reg [127:0] data_reg;
    reg [127:0] data_i;
    reg         ready_i;

    always @(posedge wb_clk or posedge wb_reset) begin
        if (wb_reset) begin
            wb_ack_o    <= #1 0;
            wb_dat_o    <= #1 0;
            control_reg <= #1 32'h0;
            data_reg    <= #1 127'h0;
            data_o      <= #1 127'h0;
        end else begin
            if (ready_i) begin
                control_reg[1] <= #1 1'b1;  
                data_reg <= #1 data_i;
            end else if (wb_stb_i && wb_cyc_i && wb_we_i && ~wb_ack_o) begin
                wb_ack_o <= #1 1;
                case (wb_adr_i[7:0])
                    8'h0:  control_reg <= #1 wb_dat_i;
                    8'h4:  data_o[127:96] <= #1 wb_dat_i;
                    8'h8:  data_o[95:64] <= #1 wb_dat_i;
                    8'hC:  data_o[63:32] <= #1 wb_dat_i;
                    8'h10: data_o[31:0] <= #1 wb_dat_i;
                endcase
            end else if (wb_stb_i && wb_cyc_i && ~wb_we_i && ~wb_ack_o) begin
                wb_ack_o <= #1 1;
                case (wb_adr_i[7:0])
                    8'h0: begin
                        wb_dat_o <= #1 control_reg;
                        control_reg[1] <= 1'b0;
                    end
                    8'h24: wb_dat_o <= #1 data_reg[127:96];
                    8'h28: wb_dat_o <= #1 data_reg[95:64];
                    8'h2C: wb_dat_o <= #1 data_reg[63:32];
                    8'h30: wb_dat_o <= #1 data_reg[31:0];
                endcase
            end else begin
                wb_ack_o <= #1 0;
                control_reg[0] <= #1 1'b0;
            end
        end
    end

    always @(posedge wb_clk) begin
        wb_rty_o <= RXN_IN[0] & RXN_IN[1] & RXN_IN[2] & RXN_IN[3] & 
                    RXN_IN[4] & RXN_IN[5] & RXN_IN[6] & RXN_IN[7];
    end    

endmodule