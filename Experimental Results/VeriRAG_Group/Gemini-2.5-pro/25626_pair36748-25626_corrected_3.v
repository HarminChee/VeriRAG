`timescale 1ns / 1ps
module dram_inf
(
input clk156_25,
input reset156_25_n,
input sys_rst, // Assuming this is the functional system reset source
input				c0_sys_clk_p,
input				c0_sys_clk_n,
input				c1_sys_clk_p,
input				c1_sys_clk_n,
input				clk_ref_p,
input				clk_ref_n,
input test_i,       // DFT test mode enable
input scan_clk,     // DFT scan clock
input dft_reset,    // DFT synchronous reset input (active high)
inout [71:0]       c0_ddr3_dq,
inout [8:0]        c0_ddr3_dqs_n,
inout [8:0]        c0_ddr3_dqs_p,
output [15:0]     c0_ddr3_addr,
output [2:0]      c0_ddr3_ba,
output            c0_ddr3_ras_n,
output            c0_ddr3_cas_n,
output            c0_ddr3_we_n,
output            c0_ddr3_reset_n,
output[1:0]       c0_ddr3_ck_p,
output[1:0]       c0_ddr3_ck_n,
output[1:0]       c0_ddr3_cke,
output[1:0]       c0_ddr3_cs_n,
output[1:0]       c0_ddr3_odt,
output            c0_ui_clk,             // Original clock from DDR controller 0
output            c0_init_calib_complete, // Calibration signal from DDR controller 0
inout [71:0]      c1_ddr3_dq,
inout [8:0]       c1_ddr3_dqs_n,
inout [8:0]       c1_ddr3_dqs_p,
output [15:0]    c1_ddr3_addr,
output [2:0]     c1_ddr3_ba,
output           c1_ddr3_ras_n,
output           c1_ddr3_cas_n,
output           c1_ddr3_we_n,
output           c1_ddr3_reset_n,
output[1:0]      c1_ddr3_ck_p,
output[1:0]      c1_ddr3_ck_n,
output[1:0]      c1_ddr3_cke,
output[1:0]      c1_ddr3_cs_n,
output[1:0]      c1_ddr3_odt,
output           c1_ui_clk,             // Original clock from DDR controller 1
output           c1_init_calib_complete, // Calibration signal from DDR controller 1
input           ht_s_axis_read_cmd_tvalid,
output          ht_s_axis_read_cmd_tready,
input[71:0]     ht_s_axis_read_cmd_tdata,
output          ht_m_axis_read_sts_tvalid,
input           ht_m_axis_read_sts_tready,
output[7:0]     ht_m_axis_read_sts_tdata,
output[511:0]    ht_m_axis_read_tdata,
output[63:0]     ht_m_axis_read_tkeep,
output          ht_m_axis_read_tlast,
output          ht_m_axis_read_tvalid,
input           ht_m_axis_read_tready,
input           ht_s_axis_write_cmd_tvalid,
output          ht_s_axis_write_cmd_tready,
input[71:0]     ht_s_axis_write_cmd_tdata,
output          ht_m_axis_write_sts_tvalid,
input           ht_m_axis_write_sts_tready,
output[7:0]     ht_m_axis_write_sts_tdata,
input[511:0]     ht_s_axis_write_tdata,
input[63:0]      ht_s_axis_write_tkeep,
input           ht_s_axis_write_tlast,
input           ht_s_axis_write_tvalid,
output          ht_s_axis_write_tready,
input           vs_s_axis_read_cmd_tvalid,
output          vs_s_axis_read_cmd_tready,
input[71:0]     vs_s_axis_read_cmd_tdata,
output          vs_m_axis_read_sts_tvalid,
input           vs_m_axis_read_sts_tready,
output[7:0]     vs_m_axis_read_sts_tdata,
output[511:0]    vs_m_axis_read_tdata,
output[63:0]     vs_m_axis_read_tkeep,
output          vs_m_axis_read_tlast,
output          vs_m_axis_read_tvalid,
input           vs_m_axis_read_tready,
input           vs_s_axis_write_cmd_tvalid,
output          vs_s_axis_write_cmd_tready,
input[71:0]     vs_s_axis_write_cmd_tdata,
output          vs_m_axis_write_sts_tvalid,
input           vs_m_axis_write_sts_tready,
output[7:0]     vs_m_axis_write_sts_tdata,
input[511:0]     vs_s_axis_write_tdata,
input[63:0]      vs_s_axis_write_tkeep,
input            vs_s_axis_write_tlast,
input            vs_s_axis_write_tvalid,
output           vs_s_axis_write_tready
);

// Internal signals from DDR controllers (assuming these exist)
wire                   c0_ui_clk_sync_rst; // Synchronous reset derived from sys_rst for c0_ui_clk domain
wire                   c0_mmcm_locked;     // Lock signal for c0 clock generation
wire                   c1_ui_clk_sync_rst; // Synchronous reset derived from sys_rst for c1_ui_clk domain
wire                   c1_mmcm_locked;     // Lock signal for c1 clock generation

// Placeholder logic for reset derivation (replace with actual logic if available)
// Assuming active high sys_rst generates active high sync resets
assign c0_ui_clk_sync_rst = sys_rst; // Example: Direct connection or synchronized version
assign c1_ui_clk_sync_rst = sys_rst; // Example: Direct connection or synchronized version
// Assuming lock signals are available from MIG/MMCM
assign c0_mmcm_locked = c0_init_calib_complete; // Example: Using calib complete as proxy for lock
assign c1_mmcm_locked = c1_init_calib_complete; // Example: Using calib complete as proxy for lock


// DFT Clock Muxing
wire dft_c0_ui_clk;
wire dft_c1_ui_clk;
assign dft_c0_ui_clk = test_i ? scan_clk : c0_ui_clk;
assign dft_c1_ui_clk = test_i ? scan_clk : c1_ui_clk;

// DFT Reset Logic (Synchronous Reset)
reg                    c0_aresetn_r;
reg                    c1_aresetn_r;

// Combinational logic for functional reset (active high)
wire c0_areset_comb = c0_ui_clk_sync_rst | ~c0_mmcm_locked;
wire c1_areset_comb = c1_ui_clk_sync_rst | ~c1_mmcm_locked;

// Select between functional reset and DFT reset (active high)
wire c0_areset_final = test_i ? dft_reset : c0_areset_comb;
wire c1_areset_final = test_i ? dft_reset : c1_areset_comb;

// Register the reset synchronously to the respective DFT clock domain
// Generates active-low reset (aresetn)
always @(posedge dft_c0_ui_clk or posedge c0_areset_final) begin
    if (c0_areset_final)
        c0_aresetn_r <= 1'b0;
    else
        c0_aresetn_r <= 1'b1;
end

always @(posedge dft_c1_ui_clk or posedge c1_areset_final) begin
    if (c1_areset_final)
        c1_aresetn_r <= 1'b0;
    else
        c1_aresetn_r <= 1'b1;
end


// Internal AXI signals
wire[511:0]    c0_m_axis_read_tdata;
wire[63:0]     c0_m_axis_read_tkeep;
wire          c0_m_axis_read_tlast;
wire          c0_m_axis_read_tvalid;
wire           c0_m_axis_read_tready;
wire[511:0]     c0_s_axis_write_tdata;
wire[63:0]      c0_s_axis_write_tkeep;
wire            c0_s_axis_write_tlast;
wire            c0_s_axis_write_tvalid;
wire           c0_s_axis_write_tready;
wire[511:0]    c1_m_axis_read_tdata;
wire[63:0]     c1_m_axis_read_tkeep;
wire          c1_m_axis_read_tlast;
wire          c1_m_axis_read_tvalid;
wire           c1_m_axis_read_tready;
wire[511:0]     c1_s_axis_write_tdata;
wire[63:0]      c1_s_axis_write_tkeep;
wire            c1_s_axis_write_tlast;
wire            c1_s_axis_write_tvalid;
wire           c1_s_