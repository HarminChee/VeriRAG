`timescale 1ns / 1ps

module dram_inf
(
input test_i, // DFT test mode signal
input clk156_25,
input reset156_25_n,
input sys_rst, // Assuming this is connected to MIG reset
input				c0_sys_clk_p,
input				c0_sys_clk_n,
input				c1_sys_clk_p,
input				c1_sys_clk_n,
input				clk_ref_p,
input				clk_ref_n,
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
output           c0_ui_clk, // Driven by MIG 0
output           c0_init_calib_complete, // Driven by MIG 0
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
output           c1_ui_clk, // Driven by MIG 1
output           c1_init_calib_complete, // Driven by MIG 1
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

// Internal wires connecting datamovers to MIG AXI interfaces
wire                   c0_ui_clk_sync_rst; // Driven by MIG 0
wire                   c0_mmcm_locked;     // Driven by MIG 0
reg                    c0_aresetn_r;
wire  [4:0]            c0_s_axi_awid;
wire  [32:0]           c0_s_axi_awaddr;
wire  [7:0]            c0_s_axi_awlen;
wire  [2:0]            c0_s_axi_awsize;
wire  [1:0]            c0_s_axi_awburst;
wire                   c0_s_axi_awvalid;
wire                   c0_s_axi_awready; // Driven by MIG 0
wire  [511:0]          c0_s_axi_wdata;
wire  [63:0]           c0_s_axi_wstrb;
wire                   c0_s_axi_wlast;
wire                   c0_s_axi_wvalid;
wire                   c0_s_axi_wready;  // Driven by MIG 0
wire [4:0]             c0_s_axi_bid;     // Driven by MIG 0
wire [1:0]             c0_s_axi_bresp;   // Driven by MIG 0
wire                   c0_s_axi_bvalid;  // Driven by MIG 0
wire                   c0_s_axi_bready;
wire  [4:0]            c0_s_axi_arid;
wire  [32:0]           c0_s_axi_araddr;
wire  [7:0]            c0_s_axi_arlen;
wire  [2:0]            c0_s_axi_arsize;
wire  [1:0]            c0_s_axi_arburst;
wire                   c0_s_axi_arvalid;
wire                   c0_s_axi_arready; // Driven by MIG 0
wire [4:0]             c0_s_axi_rid;     // Driven by MIG 0
wire [511:0]           c0_s_axi_rdata;   // Driven by MIG 0
wire [1:0]             c0_s_axi_rresp;   // Driven by MIG 0
wire                   c0_s_axi_rlast;   // Driven by MIG 0
wire                   c0_s_axi_rvalid;  // Driven by MIG 0
wire                   c0_s_axi_rready;

wire                   c1_ui_clk_sync_rst; // Driven by MIG 1
wire                   c1_mmcm_locked;     // Driven by MIG 1
reg                    c1_aresetn_r;
wire [4:0]             c1_s_axi_awid;
wire [32:0]            c1_s_axi_awaddr;
wire [7:0]             c1_s_axi_awlen;
wire [2:0]             c1_s_axi_awsize;
wire [1:0]             c1_s_axi_awburst;
wire                   c1_s_axi_awvalid;
wire                   c1_s_axi_awready; // Driven by MIG 1
wire [511:0]           c1_s_axi_wdata;
wire [63:0]            c1_s_axi_wstrb;
wire                   c1_s_axi_wlast;
wire                   c1_s_axi_wvalid;
wire                   c1_s_axi_wready;  // Driven by MIG 1
wire [4:0]             c1_s_axi_bid;     // Driven by MIG 1
wire [1:0]             c1_s_axi_bresp;   // Driven by MIG 1
wire                   c1_s_axi_bvalid;  // Driven by MIG 1
wire                   c1_s_axi_bready;
wire [4:0]             c1_s_axi_arid;
wire [32:0]            c1_s_axi_araddr;
wire [7:0]             c1_s_axi_arlen;
wire [2:0]             c1_s_axi_arsize;
wire [1:0]             c1_s_axi_arburst;
wire                   c1_s_axi_arvalid;
wire                   c1_s_axi_arready; // Driven by MIG 1
wire [4:0]             c1_s_axi_rid;     // Driven by MIG 1
wire [511:0]           c1_s_axi_rdata;   // Driven by MIG 1
wire [1:0]             c1_s_axi_rresp;   // Driven by MIG 1
wire                   c1_s_axi_rlast;   // Driven by MIG 1
wire                   c1_s_axi_rvalid;  // Driven by MIG 1
wire                   c1_s_axi_rready;

// DFT Signals
wire dft_c0_ui_clk;
wire dft_c1_ui_clk;
wire dft_c0_aresetn;
wire dft_c1_aresetn;

// DFT Clock Muxes
assign dft_c0_ui_clk = test_i ? clk156_25 : c0_ui_clk;
assign dft_c1_ui_clk = test_i ? clk156_25 : c1_ui_clk;

// Internal reset generation (still needed for functional mode)
// Assumes c0_ui_clk_sync_rst and c0_mmcm_locked are properly generated by MIG
always @(posedge dft_c0_ui_clk) // Use DFT clock
    c0_aresetn_r <= ~c0_ui_clk_sync_rst & c0_mmcm_locked;

// Assumes c1_ui_clk_sync_rst and c1_mmcm_locked are properly generated by MIG
always @(posedge dft_c1_ui_clk) // Use DFT clock
    c1_aresetn_r <= ~c1_ui_clk_sync_rst & c1_mmcm_locked;

// DFT Reset Muxes
assign dft_c0_aresetn = test_i ? reset156_25_n : c0_aresetn_r;
assign dft_c1_aresetn = test_i ? reset156_25_n : c1_aresetn_r;

// Tie off upper address bits (assuming 32-bit address space for datamover/MIG)
assign c0_s_axi_awaddr[32] = 1'b0;
assign c0_s_axi_araddr[32] = 1'b0;
assign c1_s_axi_awaddr[32] = 1'b0;
assign c1_s_axi_araddr[32] = 1'b0;

// Datamover for HT interface (Channel 0)
axi_datamover_0 ht2dram_data_mover (
  .m_axi_mm2s_aclk(dft_c0_ui_clk),                   // DFT Clock
  .m_axi_mm2s_aresetn(dft_c0_aresetn),               // DFT Reset
  .mm2s_err(),
  .m_axis_mm2s_cmdsts_aclk(clk156_25),
  .m_axis_mm2s_cmdsts_aresetn(reset156_25_n),
  .s_axis_mm2s_cmd_tvalid(ht_s_axis_read_cmd_tvalid),
  .s_axis_mm2s_cmd_tready(ht_s_axis_read_cmd_tready),
  .s_axis_mm2s_cmd_tdata(ht_s_axis_read_cmd_tdata),
  .m_axis_mm2s_sts_tvalid(ht_m_axis_read_sts_tvalid),
  .m_axis_mm2s_sts_tready(ht_m_axis_read_sts_tready),
  .m_axis_mm2s_sts_tdata(ht_m_axis_read_sts_tdata),
  .m_axis_mm2s_sts_tkeep(), // Assuming unused
  .m_axis_mm2s_sts_tlast(), // Assuming unused
  .m_axi_mm2s_arid(c0_s_axi_arid),
  .m_axi_mm2s_araddr(c0_s_axi_araddr[31:0]), // Connect lower 32 bits
  .m_axi_mm2s_arlen(c0_s_axi_arlen),
  .m_axi_mm2s_arsize(c0_s_axi_arsize),
  .m_axi_mm2s_arburst(c0_s_axi_arburst),
  .m_axi_mm2s_arprot(), // Tie off if unused
  .m_axi_mm2s_arcache(), // Tie off if unused
  .m_axi_mm2s_aruser(), // Tie off if unused
  .m_axi_mm2s_arvalid(c0_s_axi_arvalid),
  .m_axi_mm2s_arready(c0_s_axi_arready), // From MIG
  .m_axi_mm2s_rdata(c0_s_axi_rdata),     // From MIG
  .m_axi_mm2s_rresp(c0_s_axi_rresp),     // From MIG
  .m_axi_mm2s_rlast(c0_s_axi_rlast),     // From MIG
  .m_axi_mm2s_rvalid(c0_s_axi_rvalid),   // From MIG
  .m_axi_mm2s_rready(c0_s_axi_rready),
  .m_axis_mm2s_tdata(ht_m_axis_read_tdata), // Output to top
  .m_axis_mm2s_tkeep(ht_m_axis_read_tkeep), // Output to top
  .m_axis_mm2s_tlast(ht_m_axis_read_tlast), // Output to top
  .m_axis_mm2s_tvalid(ht_m_axis_read_tvalid), // Output to top
  .m_axis_mm2s_tready(ht_m_axis_read_tready), // Input from top

  .m_axi_s2mm_aclk(dft_c0_ui_clk),                   // DFT Clock
  .m_axi_s2mm_aresetn(dft_c0_aresetn),               // DFT Reset
  .s2mm_err(),
  .m_axis_s2mm_cmdsts_awclk(clk156_25),
  .m_axis_s2mm_cmdsts_aresetn(reset156_25_n),
  .s_axis_s2mm_cmd_tvalid(ht_s_axis_write_cmd_tvalid),
  .s_axis_s2mm_cmd_tready(ht_s_axis_write_cmd_tready),
  .s_axis_s2mm_cmd_tdata(ht_s_axis_write_cmd_tdata),
  .m_axis_s2mm_sts_tvalid(ht_m_axis_write_sts_tvalid),
  .m_axis_s2mm_sts_tready(ht_m_axis_write_sts_tready),
  .m_axis_s2mm_sts_tdata(ht_m_axis_write_sts_tdata),
  .m_axis_s2mm_sts_tkeep(), // Assuming unused
  .m_axis_s2mm_sts_tlast(), // Assuming unused
  .m_axi_s2mm_awid(c0_s_axi_awid),
  .m_axi_s2mm_awaddr(c0_s_axi_awaddr[31:0]), // Connect lower 32 bits
  .m_axi_s2mm_awlen(c0_s_axi_awlen),
  .m_axi_s2mm_awsize(c0_s_axi_awsize),
  .m_axi_s2mm_awburst(c0_s_axi_awburst),
  .m_axi_s2mm_awprot(), // Tie off if unused
  .m_axi_s2mm_awcache(), // Tie off if unused
  .m_axi_s2mm_awuser(), // Tie off if unused
  .m_axi_s2mm_awvalid(c0_s_axi_awvalid),
  .m_axi_s2mm_awready(c0_s_axi_awready), // From MIG
  .m_axi_s2mm_wdata(c0_s_axi_wdata),
  .m_axi_s2mm_wstrb(c0_s_axi_wstrb),
  .m_axi_s2mm_wlast(c0_s_axi_wlast),
  .m_axi_s2mm_wvalid(c0_s_axi_wvalid),
  .m_axi_s2mm_wready(c0_s_axi_wready),   // From MIG
  .m_axi_s2mm_bresp(c0_s_axi_bresp),     // From MIG - Corrected syntax
  .m_axi_s2mm_bvalid(c0_s_axi_bvalid),   // From MIG
  .m_axi_s2mm