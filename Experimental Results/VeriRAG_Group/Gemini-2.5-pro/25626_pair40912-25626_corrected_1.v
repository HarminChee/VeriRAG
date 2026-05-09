`timescale 1ns / 1ps
module dram_inf
(
input clk156_25,
input reset156_25_n,
input sys_rst, // General system reset, might be used for MIG
input				c0_sys_clk_p,
input				c0_sys_clk_n,
input				c1_sys_clk_p,
input				c1_sys_clk_n,
input				clk_ref_p,
input				clk_ref_n,
//DFT Ports
input test_i,
input scan_clk,
input dft_reset, // Added DFT reset input
//
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
output           c0_ui_clk, // Output from MIG
output           c0_init_calib_complete, // Output from MIG
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
output           c1_ui_clk, // Output from MIG
output           c1_init_calib_complete, // Output from MIG
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

// Internal signals from MIG (placeholders, assuming MIG drives them)
wire                   c0_ui_clk_sync_rst;
wire                   c0_mmcm_locked;
wire                   c1_ui_clk_sync_rst;
wire                   c1_mmcm_locked;

// Wires for AXI interfaces connected to MIG
wire  [4:0]            c0_s_axi_awid;
wire  [32:0]           c0_s_axi_awaddr;
wire  [7:0]            c0_s_axi_awlen;
wire  [2:0]            c0_s_axi_awsize;
wire  [1:0]            c0_s_axi_awburst;
wire                   c0_s_axi_awvalid;
wire                   c0_s_axi_awready;
wire  [511:0]          c0_s_axi_wdata;
wire  [63:0]           c0_s_axi_wstrb;
wire                   c0_s_axi_wlast;
wire                   c0_s_axi_wvalid;
wire                   c0_s_axi_wready;
wire [4:0]             c0_s_axi_bid;
wire [1:0]             c0_s_axi_bresp;
wire                   c0_s_axi_bvalid;
wire                   c0_s_axi_bready;
wire  [4:0]           c0_s_axi_arid;
wire  [32:0]          c0_s_axi_araddr;
wire  [7:0]           c0_s_axi_arlen;
wire  [2:0]           c0_s_axi_arsize;
wire  [1:0]           c0_s_axi_arburst;
wire                  c0_s_axi_arvalid;
wire                  c0_s_axi_arready;
wire [4:0]       c0_s_axi_rid;
wire [511:0]     c0_s_axi_rdata;
wire [1:0]       c0_s_axi_rresp;
wire             c0_s_axi_rlast;
wire             c0_s_axi_rvalid;
wire             c0_s_axi_rready;

wire [4:0]      c1_s_axi_awid;
wire [32:0]     c1_s_axi_awaddr;
wire [7:0]      c1_s_axi_awlen;
wire [2:0]      c1_s_axi_awsize;
wire [1:0]      c1_s_axi_awburst;
wire            c1_s_axi_awvalid;
wire            c1_s_axi_awready;
wire [511:0]    c1_s_axi_wdata;
wire [63:0]     c1_s_axi_wstrb;
wire            c1_s_axi_wlast;
wire            c1_s_axi_wvalid;
wire            c1_s_axi_wready;
wire [4:0]      c1_s_axi_bid;
wire [1:0]      c1_s_axi_bresp;
wire            c1_s_axi_bvalid;
wire            c1_s_axi_bready;
wire [4:0]      c1_s_axi_arid;
wire [32:0]     c1_s_axi_araddr;
wire [7:0]      c1_s_axi_arlen;
wire [2:0]      c1_s_axi_arsize;
wire [1:0]      c1_s_axi_arburst;
wire            c1_s_axi_arvalid;
wire            c1_s_axi_arready;
wire [4:0]      c1_s_axi_rid;
wire [511:0]    c1_s_axi_rdata;
wire [1:0]      c1_s_axi_rresp;
wire            c1_s_axi_rlast;
wire            c1_s_axi_rvalid;
wire            c1_s_axi_rready;

// Wires for AXIS interfaces between datamovers and converters
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
wire           c1_s_axis_write_tready;

// Registered reset signals
reg                    c0_aresetn_r;
reg                    c1_aresetn_r;

//DFT Signals: Clock Muxing
wire dft_c0_ui_clk;
wire dft_c1_ui_clk;
assign dft_c0_ui_clk = test_i ? scan_clk : c0_ui_clk;
assign dft_c1_ui_clk = test_i ? scan_clk : c1_ui_clk;

// DFT Reset Logic: Combine functional reset condition with DFT reset
wire c0_func_reset = c0_ui_clk_sync_rst | ~c0_mmcm_locked; // Active high functional reset condition
wire c1_func_reset = c1_ui_clk_sync_rst | ~c1_mmcm_locked; // Active high functional reset condition
wire dft_reset_sel = test_i ? dft_reset : 1'b0; // Select test reset (active high) only in test mode

always @(posedge dft_c0_ui_clk) begin
    if (dft_reset_sel) begin // Test reset overrides functional
        c0_aresetn_r <= 1'b0; // Assert reset (active low)
    end else begin
        c0_aresetn_r <= ~c0_func_reset; // Assign functional reset condition (active low)
    end
end

always @(posedge dft_c1_ui_clk) begin
     if (dft_reset_sel) begin // Test reset overrides functional
        c1_aresetn_r <= 1'b0; // Assert reset (active low)
    end else begin
        c1_aresetn_r <= ~c1_func_reset; // Assign functional reset condition (active low)
    end
end

// AXI Address MSB assignments (assuming lower 32 bits used)
assign c0_s_axi_awaddr[32] = 1'b0;
assign c0_s_axi_araddr[32] = 1'b0;
assign c1_s_axi_awaddr[32] = 1'b0;
assign c1_s_axi_araddr[32] = 1'b0;

//--------------------------------------------------------------------------
// Placeholder MIG Instance 0
//--------------------------------------------------------------------------
// This is a placeholder. Replace with the actual MIG instance.
// It drives the outputs needed by the rest of the logic.
mig_7series_0_placeholder mig_inst_0 (
    .ddr3_dq(c0_ddr3_dq),
    .ddr3_dqs_n(c0_ddr3_dqs_n),
    .ddr3_dqs_p(c0_ddr3_dqs_p),
    .ddr3_addr(c0_ddr3_addr),
    .ddr3_ba(c0_ddr3_ba),
    .ddr3_ras_n(c0_ddr3_ras_n),
    .ddr3_cas_n(c0_ddr3_cas_n),
    .ddr3_we_n(c0_ddr3_we_n),
    .ddr3_reset_n(c0_ddr3_reset_n),
    .ddr3_ck_p(c0_ddr3_ck_p),
    .ddr3_ck_n(c0_ddr3_ck_n),
    .ddr3_cke(c0_ddr3_cke),
    .ddr3_cs_n(c0_ddr3_cs_n),
    .ddr3_odt(c0_ddr3_odt),
    .sys_clk_p(c0_sys_clk_p),
    .sys_clk_n(c0_sys_clk_n),
    .clk_ref_p(clk_ref_p),
    .clk_ref_n(clk_ref_n),
    .ui_clk(c0_ui_clk), // MIG Output Clock
    .ui_clk_sync_rst(c0_ui_clk_sync_rst), // MIG Output Reset
    .mmcm_locked(c0_mmcm_locked), // MIG Output Lock Status
    .aresetn(~sys_rst), // Assuming sys_rst is active high reset
    .app_sr_req(1'b0), // Placeholder connections
    .app_ref_req(1'b0),
    .app_zq_req(1'b0),
    .app_sr_active(),
    .app_ref_ack(),
    .app_zq_ack(),
    .init_calib_complete(c0_init_calib_complete), // MIG Output Calibration Status
    // AXI Interface (Connected to Datamover via internal wires)
    .s_axi_awid      (c0_s_axi_awid      ),
    .s_axi_awaddr    (c0_s_axi_awaddr    ), // Connect full 33 bits if MIG uses it
    .s_axi_awlen     (c0_s_axi_awlen     ),
    .s_axi_awsize    (