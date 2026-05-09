`timescale 1ns / 1ps

module dram_inf (
    input clk156_25,
    input reset156_25_n,
    input sys_rst,

    // DDR3 Clock Inputs
    input c0_sys_clk_p,
    input c0_sys_clk_n,
    input c1_sys_clk_p,
    input c1_sys_clk_n,
    input clk_ref_p,
    input clk_ref_n,

    // DDR3 Interface for Channel 0
    inout [71:0] c0_ddr3_dq,
    inout [8:0]  c0_ddr3_dqs_n,
    inout [8:0]  c0_ddr3_dqs_p,
    output [15:0] c0_ddr3_addr,
    output [2:0]  c0_ddr3_ba,
    output        c0_ddr3_ras_n,
    output        c0_ddr3_cas_n,
    output        c0_ddr3_we_n,
    output        c0_ddr3_reset_n,
    output [1:0]  c0_ddr3_ck_p,
    output [1:0]  c0_ddr3_ck_n,
    output [1:0]  c0_ddr3_cke,
    output [1:0]  c0_ddr3_cs_n,
    output [1:0]  c0_ddr3_odt,
    output        c0_ui_clk,
    output        c0_init_calib_complete,

    // DDR3 Interface for Channel 1
    inout [71:0] c1_ddr3_dq,
    inout [8:0]  c1_ddr3_dqs_n,
    inout [8:0]  c1_ddr3_dqs_p,
    output [15:0] c1_ddr3_addr,
    output [2:0]  c1_ddr3_ba,
    output        c1_ddr3_ras_n,
    output        c1_ddr3_cas_n,
    output        c1_ddr3_we_n,
    output        c1_ddr3_reset_n,
    output [1:0]  c1_ddr3_ck_p,
    output [1:0]  c1_ddr3_ck_n,
    output [1:0]  c1_ddr3_cke,
    output [1:0]  c1_ddr3_cs_n,
    output [1:0]  c1_ddr3_odt,
    output        c1_ui_clk,
    output        c1_init_calib_complete,

    // Host Read Commands
    input           ht_s_axis_read_cmd_tvalid,
    output          ht_s_axis_read_cmd_tready,
    input [71:0]    ht_s_axis_read_cmd_tdata,
    output          ht_m_axis_read_sts_tvalid,
    input           ht_m_axis_read_sts_tready,
    output [7:0]    ht_m_axis_read_sts_tdata,
    output [511:0]  ht_m_axis_read_tdata,
    output [63:0]   ht_m_axis_read_tkeep,
    output          ht_m_axis_read_tlast,
    output          ht_m_axis_read_tvalid,
    input           ht_m_axis_read_tready,

    // Host Write Commands
    input           ht_s_axis_write_cmd_tvalid,
    output          ht_s_axis_write_cmd_tready,
    input [71:0]    ht_s_axis_write_cmd_tdata,
    output          ht_m_axis_write_sts_tvalid,
    input           ht_m_axis_write_sts_tready,
    output [7:0]    ht_m_axis_write_sts_tdata,
    input [511:0]   ht_s_axis_write_tdata,
    input [63:0]    ht_s_axis_write_tkeep,
    input           ht_s_axis_write_tlast,
    input           ht_s_axis_write_tvalid,
    output          ht_s_axis_write_tready
);

// Internal signals
wire c0_ui_clk_sync_rst, c1_ui_clk_sync_rst;
wire c0_mmcm_locked, c1_mmcm_locked;
reg  c0_aresetn_r, c1_aresetn_r;

// Reset logic
always @(posedge c0_ui_clk) 
    c0_aresetn_r <= ~c0_ui_clk_sync_rst & c0_mmcm_locked;

always @(posedge c1_ui_clk) 
    c1_aresetn_r <= ~c1_ui_clk_sync_rst & c1_mmcm_locked;

// DDR3 Memory Interface Instance
mig_7series_0 mig_dual_inst (
    .c0_sys_clk_p(c0_sys_clk_p),
    .c0_sys_clk_n(c0_sys_clk_n),
    .c1_sys_clk_p(c1_sys_clk_p),
    .c1_sys_clk_n(c1_sys_clk_n),
    .clk_ref_p(clk_ref_p),
    .clk_ref_n(clk_ref_n),

    .c0_ddr3_dq(c0_ddr3_dq),
    .c0_ddr3_dqs_n(c0_ddr3_dqs_n),
    .c0_ddr3_dqs_p(c0_ddr3_dqs_p),
    .c0_ddr3_addr(c0_ddr3_addr),
    .c0_ddr3_ba(c0_ddr3_ba),
    .c0_ddr3_ras_n(c0_ddr3_ras_n),
    .c0_ddr3_cas_n(c0_ddr3_cas_n),
    .c0_ddr3_we_n(c0_ddr3_we_n),
    .c0_ddr3_reset_n(c0_ddr3_reset_n),
    .c0_ddr3_ck_p(c0_ddr3_ck_p),
    .c0_ddr3_ck_n(c0_ddr3_ck_n),
    .c0_ddr3_cke(c0_ddr3_cke),
    .c0_ddr3_cs_n(c0_ddr3_cs_n),
    .c0_ddr3_odt(c0_ddr3_odt),
    .c0_ui_clk(c0_ui_clk),
    .c0_ui_clk_sync_rst(c0_ui_clk_sync_rst),
    .c0_mmcm_locked(c0_mmcm_locked),
    .c0_init_calib_complete(c0_init_calib_complete),

    .c1_ddr3_dq(c1_ddr3_dq),
    .c1_ddr3_dqs_n(c1_ddr3_dqs_n),
    .c1_ddr3_dqs_p(c1_ddr3_dqs_p),
    .c1_ddr3_addr(c1_ddr3_addr),
    .c1_ddr3_ba(c1_ddr3_ba),
    .c1_ddr3_ras_n(c1_ddr3_ras_n),
    .c1_ddr3_cas_n(c1_ddr3_cas_n),
    .c1_ddr3_we_n(c1_ddr3_we_n),
    .c1_ddr3_reset_n(c1_ddr3_reset_n),
    .c1_ddr3_ck_p(c1_ddr3_ck_p),
    .c1_ddr3_ck_n(c1_ddr3_ck_n),
    .c1_ddr3_cke(c1_ddr3_cke),
    .c1_ddr3_cs_n(c1_ddr3_cs_n),
    .c1_ddr3_odt(c1_ddr3_odt),
    .c1_ui_clk(c1_ui_clk),
    .c1_ui_clk_sync_rst(c1_ui_clk_sync_rst),
    .c1_mmcm_locked(c1_mmcm_locked),
    .c1_init_calib_complete(c1_init_calib_complete),
    .sys_rst(sys_rst)
);

endmodule