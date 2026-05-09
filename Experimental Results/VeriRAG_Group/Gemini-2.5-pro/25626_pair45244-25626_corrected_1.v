`timescale 1ns / 1ps
module dram_inf
(
input clk156_25,
input reset156_25_n,
input sys_rst,
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

// Internal wires from DDR controllers
wire                   c0_ui_clk_sync_rst;
wire                   c0_mmcm_locked;
wire                   c1_ui_clk_sync_rst;
wire                   c1_mmcm_locked;

// Internal AXI signals for DDR controllers
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

// Internal functional reset signals
reg                    c0_aresetn_r;
reg                    c1_aresetn_r;

// DFT Signals
wire             dft_c0_ui_clk;
wire             dft_c1_ui_clk;
wire             dft_c0_aresetn;
wire             dft_c1_aresetn;

// DFT Clock Muxing (Fixes CLKNPI)
assign dft_c0_ui_clk = test_mode ? clk156_25 : c0_ui_clk;
assign dft_c1_ui_clk = test_mode ? clk156_25 : c1_ui_clk;

// Functional Reset Generation
// Use DFT clock for reset synchronizer flip-flops
always @(posedge dft_c0_ui_clk or negedge reset156_25_n) begin
  if (!reset156_25_n) begin
    c0_aresetn_r <= 1'b0;
  end else begin
    c0_aresetn_r <= ~c0_ui_clk_sync_rst & c0_mmcm_locked;
  end
end

always @(posedge dft_c1_ui_clk or negedge reset156_25_n) begin
  if (!reset156_25_n) begin
    c1_aresetn_r <= 1'b0;
  end else begin
    c1_aresetn_r <= ~c1_ui_clk_sync_rst & c1_mmcm_locked;
  end
end

// DFT Reset Muxing (Fixes ACNCPI)
// Selects between functional reset (c0/1_aresetn_r) and primary reset (reset156_25_n)
assign dft_c0_aresetn = test_mode ? reset156_25_n : c0_aresetn_r;
assign dft_c1_aresetn = test_mode ? reset156_25_n : c1_aresetn_r;


// Padding address bits for AXI (assuming 32-bit address space for DDR)
assign c0_s_axi_awaddr[32] = 1'b0;
assign c0_s_axi_araddr[32] = 1'b0;
assign c1_s_axi_awaddr[32] = 1'b0;
assign c1_s_axi_araddr[32] = 1'b0;


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
  .c0_s_axi_awid(c0_s_axi_awid),
  .c0_s_axi_awaddr(c0_s_axi_awaddr[31:0]), // Connect lower 32 bits
  .c0_s_axi_awlen(c0_s_axi_awlen),
  .c0_s_axi_awsize(c0_s_axi_awsize),
  .c0_s_axi_awburst(c0_s_axi_awburst),
  .c0_s_axi_awlock(), // Assuming no lock needed
  .c0_s_axi_awcache(), // Assuming default cache
  .c0_s_axi_awprot(), // Assuming default prot
  .c0_s_axi_awqos(), // Assuming default qos
  .c0_s_axi_awregion(), // Assuming default region
  .c0_s_axi_awuser(), // Assuming no user bits
  .c0_s_axi_awvalid(c0_s_axi_awvalid),
  .c0_s_axi_awready(c0_s_axi_awready),
  .c0_s_axi_wdata(c0_s_axi_wdata),
  .c0_s_axi_wstrb(c0_s_axi_wstrb),
  .c0_s_axi_wlast(c0_s_axi_wlast),
  .c0_s_axi_wuser(), // Assuming no user bits
  .c0_s_axi_wvalid(c0_s_axi_wvalid),
  .c0_s_axi_wready(c0_s_axi_wready),
  .c0_s_axi_bid(c0_s_axi_bid),
  .c0_s_axi_bresp(c0_s_axi_bresp),
  .c0_s_axi_buser(), // Assuming no user bits
  .c0_s_axi_bvalid(c0_s_axi_bvalid),
  .c0_s_axi_bready(c0_s_axi_bready),
  .c0_s_axi_arid(c0_s_axi_arid),
  .c0_s_axi_araddr(c0_s_axi_araddr[31:0]), // Connect lower 32 bits
  .c0_s_axi_arlen(c0_s_axi_arlen),
  .c0_s_axi_arsize(c0_s_axi_arsize),
  .c0_s_axi_arburst(c0_s_axi_arburst),
  .c0_s_axi_arlock(), // Assuming no lock needed
  .c0_s_axi_arcache(), // Assuming default cache
  .c0_s_axi_arprot(), // Assuming default prot
  .c0_s_axi_arqos(), // Assuming default qos
  .c0_s_axi_arregion(), // Assuming default region
  .c0_s_axi_aruser(), // Assuming no user bits
  .c0_s_axi_arvalid(c0_s_axi_arvalid),
  .c0_s_axi_arready(c0_s_axi_arready),
  .c0_s_axi_rid(c0_s_axi_rid),
  .c0_s_axi_rdata(c0_s_axi_rdata),
  .c0_s_axi_rresp(c0_s_axi_rresp),
  .c0_s_axi_rlast(c0_s_axi_rlast),
  .c0_s_axi_ruser(), // Assuming no user bits
  .c0_s_axi_rvalid(c0_s_axi_rvalid),
  .c0_s_axi_rready(c0_s_axi_rready),
  .c0_sys_rst(sys_rst), // Use primary system reset
  // Use DFT clock and reset for the AXI interface
  .c0_s_axi_aclk(dft_c0_ui_clk),
  .c0_s_axi_aresetn(dft_c0_aresetn)
);


// Instantiate DDR3 Controller 1
ddr3_1 ddr3_inst_1 (
  .c0_sys_clk_p(c1_sys_clk_p), // Note: IP instance port names might be c0_* even for controller 1
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
  .c0_ddr3_odt(c1_ddr3_odt),
  .c0_ui_clk(c1_ui_clk),
  .c0_ui_clk_sync_rst(c1_ui_clk_sync_rst),
  .c0_mmcm_locked(c1_mmcm_locked),
  .c0_init_calib_complete(c1_init_calib_complete),
  .c0_s_axi_awid(c1_s_axi_awid),
  .c0_s_axi_awaddr(c1_s_axi_awaddr[31:0]), // Connect lower 32 bits
  .c0_s_axi_awlen(c1_s_axi_awlen),
  .c0_s_axi_awsize(c1_s_axi_awsize),
  .c0_s_axi_awburst(c1_s_axi_awburst),
  .c0_s_axi_awlock(), // Assuming no lock needed
  .c0_s_axi_awcache(), // Assuming default cache
  .c0_s_axi_awprot(), // Assuming default prot
  .c0_s_axi_awqos(), // Assuming default qos
  .c0_s_axi_awregion(), // Assuming default region
  .c0_s_axi_awuser(), // Assuming no user bits
  .c0_s_axi_awvalid(c1_s_axi_awvalid),
  .c0_s_axi_awready(c1_s_axi_awready),
  .c0_s_axi_wdata(c1_s_axi_wdata),
  .c0_s_axi_wstrb(c1_s_axi_wstrb),
  .c0_s_axi_wlast(c1_s_axi_wlast),
  .c0_s_axi_wuser(), // Assuming no user bits
  .c0_s_axi_wvalid(c1_s_axi_wvalid),
  .c0_s_axi_wready(c1_s_axi_wready),
  .c0_s_axi_bid(c1_s_axi_bid),
  .c0_s_axi_bresp(c1_s_axi_bresp),
  .c0_s_axi_buser(), // Assuming no user bits
  .c0_s_axi_bvalid(c1_s_axi_bvalid),
  .c0_s_axi_bready(c1_s_axi_bready),
  .c0_s_axi_arid(c1_s_axi_arid),
  .c0_s_axi_araddr(c1_s_axi_araddr[31:0]), // Connect lower 32 bits
  .c0_s_axi_arlen(c1_s_axi_arlen),
  .c0_s_axi_arsize(c1_s_axi_arsize),
  .c0_s_axi_arburst(c1_s_axi_arburst),
  .c0_s_axi_arlock(), // Assuming no lock needed
  .c0_s_axi_arcache(), // Assuming default cache
  .c0_s_axi_arprot(), // Assuming default prot
  .c0_s_axi_arqos(), // Assuming default qos
  .c0_s_axi_arregion(), // Assuming default region
  .c0_s_axi_aruser(), // Assuming no user bits
  .c0_s_axi_arvalid(c1_s_axi_arvalid),
  .c0_s_axi_arready(c1_s_axi_arready),
  .c0_s_axi_rid(c1_s_axi_rid),
  .c0_s_axi_rdata(c1_s_axi_rdata),
  .c0_s_axi_rresp(c1_s_axi_rresp),
  .c0_s_axi_rlast(c1_s_axi_rlast),
  .c0_s_axi_ruser(), // Assuming no user bits
  .c0_s_axi_rvalid(c1_s_axi_rvalid),
  .c0_s_axi_rready(c1_s_axi_rready),
  .c0_sys_rst(sys_rst), // Use primary system reset
  // Use DFT clock and reset for the AXI interface
  .c0_s_axi_aclk(dft_c1_ui_clk),
  .c0_s_axi_aresetn(dft_c1_aresetn)
);


// Instantiate AXI Datamover 0 (HT to DRAM0)
axi_datamover_0 ht2dram_data_mover (
  // MM2S Interface (Read from DRAM)
  .m_axi_mm2s_aclk(dft_c0_ui_clk),                      // Changed clock to DFT version
  .m_axi_mm2s_aresetn(dft_c0_aresetn),                  // Changed reset to DFT version
  .mm2s_err(),
  .m_axi_mm2s_arid(c0_s_axi_arid),
  .m_axi_mm2s_araddr(c0_s_axi_araddr[31:0]),
  .m_axi_mm2s_arlen(c0_s_axi_arlen),
  .m_axi_mm2s_arsize(c0_s_axi_arsize),
  .m_axi_mm2s_arburst(c0_s_axi_arburst),
  .m_axi_mm2s_arprot(),
  .m_axi_mm2s_arcache(),
  .m_axi_mm2s_aruser(),
  .m_axi_mm2s_arvalid(c0_s_axi_arvalid),
  .m_axi_mm2s_arready(c0_s_axi_arready),
  .m_axi_mm2s_rdata(c0_s_axi_rdata),
  .m_axi_mm2s_rresp(c0_s_axi_rresp),
  .m_axi_mm2s_rlast(c0_s_axi_rlast),
  .m_axi_mm2s_rvalid(c0_s_axi_rvalid),
  .m_axi_mm2s_rready(c0_s_axi_rready),
  .m_axis_mm2s_tdata(ht_m_axis_read_tdata), // Output read data
  .m_axis_mm2s_tkeep(ht_m_axis_read_tkeep),
  .m_axis_mm2s_tlast(ht_m_axis_read_tlast),
  .m_axis_mm2s_tvalid