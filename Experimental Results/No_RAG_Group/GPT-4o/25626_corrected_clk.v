`timescale 1ns / 1ps

module dram_inf
(
    input           clk156_25,
    input           reset156_25_n,
    input           sys_rst,
    input           c0_sys_clk_p,
    input           c0_sys_clk_n,
    input           c1_sys_clk_p,
    input           c1_sys_clk_n,
    input           clk_ref_p,
    input           clk_ref_n,
    output          c0_ui_clk,
    output          c0_init_calib_complete,
    output          c1_ui_clk,
    output          c1_init_calib_complete
);

    wire            c0_ui_clk_sync_rst;
    wire            c0_mmcm_locked;
    reg             c0_aresetn_r;
    wire            c1_ui_clk_sync_rst;
    wire            c1_mmcm_locked;
    reg             c1_aresetn_r;

    always @(posedge c0_ui_clk) begin
        c0_aresetn_r <= ~c0_ui_clk_sync_rst & c0_mmcm_locked;
    end

    always @(posedge c1_ui_clk) begin
        c1_aresetn_r <= ~c1_ui_clk_sync_rst & c1_mmcm_locked;
    end

    mig_7series_0 mig_dual_inst (
        .c0_ui_clk                 (c0_ui_clk),
        .c0_ui_clk_sync_rst        (c0_ui_clk_sync_rst),
        .c0_mmcm_locked            (c0_mmcm_locked),
        .c0_aresetn                (c0_aresetn_r),
        .c0_init_calib_complete    (c0_init_calib_complete),
        .c0_sys_clk_p              (c0_sys_clk_p),
        .c0_sys_clk_n              (c0_sys_clk_n),
        .clk_ref_p                 (clk_ref_p),
        .clk_ref_n                 (clk_ref_n),
        .c1_ui_clk                 (c1_ui_clk),
        .c1_ui_clk_sync_rst        (c1_ui_clk_sync_rst),
        .c1_mmcm_locked            (c1_mmcm_locked),
        .c1_aresetn                (c1_aresetn_r),
        .c1_init_calib_complete    (c1_init_calib_complete),
        .c1_sys_clk_p              (c1_sys_clk_p),
        .c1_sys_clk_n              (c1_sys_clk_n),
        .sys_rst                   (sys_rst)
    );

endmodule