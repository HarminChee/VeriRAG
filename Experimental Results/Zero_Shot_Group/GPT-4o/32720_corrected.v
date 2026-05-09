`timescale 1ns / 1ps

module mem_inf #(
    parameter C0_SIMULATION = "FALSE",
    parameter C1_SIMULATION = "FALSE",
    parameter C0_SIM_BYPASS_INIT_CAL = "OFF",
    parameter C1_SIM_BYPASS_INIT_CAL = "OFF"
)(
    input clk156_25,
    input reset156_25_n,
    input c0_sys_clk_p,
    input c0_sys_clk_n,
    input clk_ref_p,
    input clk_ref_n,
    input c1_sys_clk_p,
    input c1_sys_clk_n,
    input sys_rst,
    
    inout [71:0] c0_ddr3_dq,
    inout [8:0] c0_ddr3_dqs_n,
    inout [8:0] c0_ddr3_dqs_p,
    output [15:0] c0_ddr3_addr,
    output [2:0] c0_ddr3_ba,
    output c0_ddr3_ras_n,
    output c0_ddr3_cas_n,
    output c0_ddr3_we_n,
    output c0_ddr3_reset_n,
    output [1:0] c0_ddr3_ck_p,
    output [1:0] c0_ddr3_ck_n,
    output [1:0] c0_ddr3_cke,
    output [1:0] c0_ddr3_cs_n,
    output [1:0] c0_ddr3_odt,
    output c0_ui_clk,
    output c0_init_calib_complete,

    inout [71:0] c1_ddr3_dq,
    inout [8:0] c1_ddr3_dqs_n,
    inout [8:0] c1_ddr3_dqs_p,
    output [15:0] c1_ddr3_addr,
    output [2:0] c1_ddr3_ba,
    output c1_ddr3_ras_n,
    output c1_ddr3_cas_n,
    output c1_ddr3_we_n,
    output c1_ddr3_reset_n,
    output [1:0] c1_ddr3_ck_p,
    output [1:0] c1_ddr3_ck_n,
    output [1:0] c1_ddr3_cke,
    output [1:0] c1_ddr3_cs_n,
    output [1:0] c1_ddr3_odt,
    output c1_ui_clk,
    output c1_init_calib_complete
);

reg c0_aresetn_r, c1_aresetn_r;
wire c0_ui_clk_sync_rst, c0_mmcm_locked;
wire c1_ui_clk_sync_rst, c1_mmcm_locked;

always @(posedge c0_ui_clk)
    c0_aresetn_r <= ~c0_ui_clk_sync_rst & c0_mmcm_locked;

always @(posedge c1_ui_clk)
    c1_aresetn_r <= ~c1_ui_clk_sync_rst & c1_mmcm_locked;

mig_7series_0 u_mig_7series_0 (
    .c0_ddr3_addr(c0_ddr3_addr),
    .c0_ddr3_ba(c0_ddr3_ba),
    .c0_ddr3_cas_n(c0_ddr3_cas_n),
    .c0_ddr3_ck_n(c0_ddr3_ck_n),
    .c0_ddr3_ck_p(c0_ddr3_ck_p),
    .c0_ddr3_cke(c0_ddr3_cke),
    .c0_ddr3_ras_n(c0_ddr3_ras_n),
    .c0_ddr3_reset_n(c0_ddr3_reset_n),
    .c0_ddr3_we_n(c0_ddr3_we_n),
    .c0_ddr3_dq(c0_ddr3_dq),
    .c0_ddr3_dqs_n(c0_ddr3_dqs_n),
    .c0_ddr3_dqs_p(c0_ddr3_dqs_p),
    .c0_init_calib_complete(c0_init_calib_complete),
    .c0_ddr3_cs_n(c0_ddr3_cs_n),
    .c0_ddr3_odt(c0_ddr3_odt),
    .c0_ui_clk(c0_ui_clk),
    .c0_ui_clk_sync_rst(c0_ui_clk_sync_rst),
    .c0_mmcm_locked(c0_mmcm_locked),
    .c0_aresetn(c0_aresetn_r),
    .c0_sys_clk_p(c0_sys_clk_p),
    .c0_sys_clk_n(c0_sys_clk_n),
    .clk_ref_p(clk_ref_p),
    .clk_ref_n(clk_ref_n),
    .sys_rst(sys_rst),

    .c1_ddr3_addr(c1_ddr3_addr),
    .c1_ddr3_ba(c1_ddr3_ba),
    .c1_ddr3_cas_n(c1_ddr3_cas_n),
    .c1_ddr3_ck_n(c1_ddr3_ck_n),
    .c1_ddr3_ck_p(c1_ddr3_ck_p),
    .c1_ddr3_cke(c1_ddr3_cke),
    .c1_ddr3_ras_n(c1_ddr3_ras_n),
    .c1_ddr3_reset_n(c1_ddr3_reset_n),
    .c1_ddr3_we_n(c1_ddr3_we_n),
    .c1_ddr3_dq(c1_ddr3_dq),
    .c1_ddr3_dqs_n(c1_ddr3_dqs_n),
    .c1_ddr3_dqs_p(c1_ddr3_dqs_p),
    .c1_init_calib_complete(c1_init_calib_complete),
    .c1_ddr3_cs_n(c1_ddr3_cs_n),
    .c1_ddr3_odt(c1_ddr3_odt),
    .c1_ui_clk(c1_ui_clk),
    .c1_ui_clk_sync_rst(c1_ui_clk_sync_rst),
    .c1_mmcm_locked(c1_mmcm_locked),
    .c1_aresetn(c1_aresetn_r),
    .c1_sys_clk_p(c1_sys_clk_p),
    .c1_sys_clk_n(c1_sys_clk_n)
);

endmodule