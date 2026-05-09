`timescale 1ns / 1ps
module dram_inf
(
input clk156_25,
input reset156_25_n, // DFT controllable reset
input sys_rst,       // System reset for DDR PHY/Controller internals
input				c0_sys_clk_p,
input				c0_sys_clk_n,
input				c1_sys_clk_p,
input				c1_sys_clk_n,
input				clk_ref_p,
input				clk_ref_n,
input               test_mode, // Added for DFT
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
output            c0_ui_clk,
output            c0_init_calib_complete,
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
output           c1_ui_clk,
output           c1_init_calib_complete,
input           ht_s_axis_read_cmd_tvalid,
output          ht_s_axis_read_cmd_tready,
input[71:0]     ht_s_axis_read_cmd_tdata, // Includes address, length etc. for datamover command
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
input[71:0]     ht_s_axis_write_cmd_tdata, // Includes address, length etc. for datamover command
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
input[71:0]     vs_s_axis_read_cmd_tdata, // Includes address, length etc. for datamover command
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
input[71:0]     vs_s_axis_write_cmd_tdata, // Includes address, length etc. for datamover command
output          vs_m_axis_write_sts_tvalid,
input           vs_m_axis_write_sts_tready,
output[7:0]     vs_m_axis_write_sts_tdata,
input[511:0]     vs_s_axis_write_tdata,
input[63:0]      vs_s_axis_write_tkeep,
input            vs_s_axis_write_tlast,
input            vs_s_axis_write_tvalid,
output           vs_s_axis_write_tready
);

// Internal wires from DDR controllers
wire                   c0_ui_clk_sync_rst;
wire                   c0_mmcm_locked;
wire                   c1_ui_clk_sync_rst;
wire                   c1_mmcm_locked;

// Internal AXI signals for DDR controllers (Assume 32-bit Address)
wire  [4:0]            c0_s_axi_awid;
wire  [31:0]           c0_s_axi_awaddr; // Changed width to 32
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
wire  [31:0]          c0_s_axi_araddr; // Changed width to 32
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
wire [31:0]     c1_s_axi_awaddr; // Changed width to 32
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
wire [31:0]     c1_s_axi_araddr; // Changed width to 32
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

// Internal functional reset signals (active high representation of reset release)
reg                    c0_aresetn_r;
reg                    c1_aresetn_r;

// DFT Signals
wire             dft_c0_ui_clk;
wire             dft_c1_ui_clk;
wire             dft_c0_aresetn; // Active low reset for AXI interfaces
wire             dft_c1_aresetn; // Active low reset for AXI interfaces

// DFT Clock Muxing (Fixes CLKNPI)
// Selects primary clock clk156_25 in test_mode, otherwise internal c0/1_ui_clk
assign dft_c0_ui_clk = test_mode ? clk156_25 : c0_ui_clk;
assign dft_c1_ui_clk = test_mode ? clk156_25 : c1_ui_clk;

// Functional Reset Generation (Synchronized to DFT clock)
// c0/1_aresetn_r goes high when reset is released and clock is stable
always @(posedge dft_c0_ui_clk or negedge reset156_25_n) begin
  if (!reset156_25_n) begin // Active low asynchronous reset
    c0_aresetn_r <= 1'b0;
  end else begin // Synchronous deassertion path
    // Assumes c0_ui_clk_sync_rst is the reset synchronized to c0_ui_clk domain inside DDR IP
    // c0_aresetn_r reflects the state AFTER the synchronizer and lock condition
    c0_aresetn_r <= ~c0_ui_clk_sync_rst & c0_mmcm_locked;
  end
end

always @(posedge dft_c1_ui_clk or negedge reset156_25_n) begin
  if (!reset156_25_n) begin // Active low asynchronous reset
    c1_aresetn_r <= 1'b0;
  end else begin // Synchronous deassertion path
    c1_aresetn_r <= ~c1_ui_clk_sync_rst & c1_mmcm_locked;
  end
end

// DFT Reset Muxing (Fixes ACNCPI for AXI interfaces)
// Provides active low reset: primary reset reset156_25_n in test_mode,
// or inverted functional reset status !c0/1_aresetn_r in functional mode.
assign dft_c0_aresetn = test_mode ? reset156_25_n : !c0_aresetn_r;
assign dft_c1_aresetn = test_mode ? reset156_25_n : !c1_aresetn_r;


// Instantiate DDR3 Controller 0
ddr3_0 ddr3_inst_0 (
  .c0_sys_clk_p(c0_sys_clk_p),
  .c0_sys_clk_n(c0_sys_clk_n),
  .c0_clk_ref_p(clk_ref_p),
  .c0_clk_ref_n(clk_ref_n),
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
  // AXI Slave Interface (Driven by Datamover)
  .c0_s_axi_awid(c0_s_axi_awid),
  .c0_s_axi_awaddr(c0_s_axi_awaddr), // Connected 32 bits
  .c0_s_axi_awlen(c0_s_axi_awlen),
  .c0_s_axi_awsize(c0_s_axi_awsize),
  .c0_s_axi_awburst(c0_s_axi_awburst),
  .c0_s_axi_awlock(), // Tie off optional/unused ports if they are inputs
  .c0_s_axi_awcache(),
  .c0_s_axi_awprot(),
  .c0_s_axi_awqos(),
  .c0_s_axi_awregion(),
  .c0_s_axi_awuser(),
  .c0_s_axi_awvalid(c0_s_axi_awvalid),
  .c0_s_axi_awready(c0_s_axi_awready),
  .c0_s_axi_wdata(c0_s_axi_wdata),
  .c0_s_axi_wstrb(c0_s_axi_wstrb),
  .c0_s_axi_wlast(c0_s_axi_wlast),
  .c0_s_axi_wuser(),
  .c0_s_axi_wvalid(c0_s_axi_wvalid),
  .c0_s_axi_wready(c0_s_axi_wready),
  .c0_s_axi_bid(c0_s_axi_bid),
  .c0_s_axi_bresp(c0_s_axi_bresp),
  .c0_s_axi_buser(),
  .c0_s_axi_bvalid(c0_s_axi_bvalid),
  .c0_s_axi_bready(c0_s_axi_bready),
  .c0_s_axi_arid(c0_s_axi_arid),
  .c0_s_axi_araddr(c0_s_axi_araddr), // Connected 32 bits
  .c0_s_axi_arlen(c0_s_axi_arlen),
  .c0_s_axi_arsize(c0_s_axi_arsize),
  .c0_s_axi_arburst(c0_s_axi_arburst),
  .c0_s_axi_arlock(), // Tie off optional/unused ports if they are inputs
  .c0_s_axi_arcache(),
  .c0_s_axi_arprot(),
  .c0_s_axi_arqos(),
  .c0_s_axi_arregion(),
  .c0_s_axi_aruser(),
  .c0_s_axi_arvalid(c0_s_axi_arvalid),
  .c0_s_axi_arready(c0_s_axi_arready),
  .c0_s_axi_rid(c0_s_axi_rid),
  .c0_s_axi_rdata(c0_s_axi_rdata),
  .c0_s_axi_rresp(c0_s_axi_rresp),
  .c0_s_axi_rlast(c0_s_axi_rlast),
  .c0_s_axi_ruser(),
  .c0_s_axi_rvalid(c0_s_axi_rvalid),
  .c0_s_axi_rready(c0_s_axi_rready),
  .c0_sys_rst(sys_rst), // Use primary system reset for PHY/Core
  // Use DFT clock and reset for the AXI interface
  .c0_s_axi_aclk(dft_c0_ui_clk),
  .c0_s_axi_aresetn(dft_c0_aresetn) // Connect DFT controlled reset
);


// Instantiate DDR3 Controller 1
ddr3_1 ddr3_inst_1 (
  // Note: IP instance port names might be c0_* even for controller 1 instance
  .c0_sys_clk_p(c1_sys_clk_p),
  .c0_sys_clk_n(c1_sys_clk_n),
  .c0_clk_ref_p(clk_ref_p),
  .c0_clk_ref_n(clk_ref_n),
  .c0_ddr3_dq(c1_ddr3_dq),
  .c0_ddr3_dqs_n(c1_ddr3_dqs_n),
  .c0_ddr3_dqs_p(c1_ddr3_dqs_p),
  .c0_ddr3_addr(c1_ddr3_addr),
  .c0_ddr3_ba(c1_ddr3_ba),
  .c0_ddr3_ras_n(c1_ddr3_ras_n),
  .c0_ddr3_cas_n(c1_ddr3_cas_n),
  .c0_ddr3_we_n(c1_ddr3_we_n),
  .c0_ddr3_reset_n(c1_ddr3_reset_n),
  .c0_ddr3_ck_p(c1_ddr3_ck_p),
  .c0_ddr3_ck_n(c1_ddr3_ck_n),
  .c0_ddr3_cke(c1_ddr3_cke),
  .c0_ddr3_cs_n(c1_ddr3_cs_n),
  .c0_ddr3_odt