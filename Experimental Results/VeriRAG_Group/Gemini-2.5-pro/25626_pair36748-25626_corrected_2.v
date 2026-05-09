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
input test_i,
input scan_clk,
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
wire                   c0_ui_clk_sync_rst;
wire                   c0_mmcm_locked;
reg                    c0_aresetn_r;
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
wire             c1_ui_clk_sync_rst;
wire             c1_mmcm_locked;
reg              c1_aresetn_r;
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

wire dft_c0_ui_clk;
wire dft_c1_ui_clk;
assign dft_c0_ui_clk = test_i ? scan_clk : c0_ui_clk;
assign dft_c1_ui_clk = test_i ? scan_clk : c1_ui_clk;

// DFT Note: c0_ui_clk_sync_rst and c1_ui_clk_sync_rst are assumed to be DFT-controllable resets
// or derived from such. If they are asynchronous and not controllable, further DFT logic is needed.
always @(posedge dft_c0_ui_clk)
    c0_aresetn_r <= ~c0_ui_clk_sync_rst & c0_mmcm_locked;
always @(posedge dft_c1_ui_clk)
    c1_aresetn_r <= ~c1_ui_clk_sync_rst & c1_mmcm_locked;

// Placeholder assignments for unused bits, ensures defined logic
assign c0_s_axi_awaddr[32] = 1'b0;
assign c0_s_axi_araddr[32] = 1'b0;
assign c1_s_axi_awaddr[32] = 1'b0;
assign c1_s_axi_araddr[32] = 1'b0;

// Instance for HT (Host) to DRAM C0 communication
axi_datamover_0 ht2dram_data_mover (
  .m_axi_mm2s_aclk(c0_ui_clk),                        // Functional clock for AXI Master MM2S Interface
  .m_axi_mm2s_aresetn(c0_aresetn_r),                  // Asynchronous reset for AXI Master MM2S Interface
  .mm2s_err(),                                      // MM2S Error output
  .m_axis_mm2s_cmdsts_aclk(clk156_25),        // Clock for MM2S Command/Status AXI Stream Interface
  .m_axis_mm2s_cmdsts_aresetn(reset156_25_n),  // Asynchronous reset for MM2S Command/Status AXI Stream Interface
  .s_axis_mm2s_cmd_tvalid(ht_s_axis_read_cmd_tvalid),          // Slave MM2S Command Input Valid
  .s_axis_mm2s_cmd_tready(ht_s_axis_read_cmd_tready),          // Slave MM2S Command Output Ready
  .s_axis_mm2s_cmd_tdata(ht_s_axis_read_cmd_tdata),            // Slave MM2S Command Input Data
  .m_axis_mm2s_sts_tvalid(ht_m_axis_read_sts_tvalid),          // Master MM2S Status Output Valid
  .m_axis_mm2s_sts_tready(ht_m_axis_read_sts_tready),          // Master MM2S Status Input Ready
  .m_axis_mm2s_sts_tdata(ht_m_axis_read_sts_tdata),            // Master MM2S Status Output Data
  .m_axis_mm2s_sts_tkeep(),            // Master MM2S Status Output Keep (unused)
  .m_axis_mm2s_sts_tlast(),            // Master MM2S Status Output Last (unused)
  .m_axi_mm2s_arid(c0_s_axi_arid),                        // Master AXI MM2S Read ID
  .m_axi_mm2s_araddr(c0_s_axi_araddr[31:0]),                    // Master AXI MM2S Read Address
  .m_axi_mm2s_arlen(c0_s_axi_arlen),                      // Master AXI MM2S Read Length
  .m_axi_mm2s_arsize(c0_s_axi_arsize),                    // Master AXI MM2S Read Size
  .m_axi_mm2s_arburst(c0_s_axi_arburst),                  // Master AXI MM2S Read Burst
  .m_axi_mm2s_arprot(),                    // Master AXI MM2S Read Protection (unused)
  .m_axi_mm2s_arcache(),                  // Master AXI MM2S Read Cache (unused)
  .m_axi_mm2s_aruser(),                    // Master AXI MM2S Read User (unused)
  .m_axi_mm2s_arvalid(c0_s_axi_arvalid),                  // Master AXI MM2S Read Valid
  .m_axi_mm2s_arready(c0_s_axi_arready),                  // Master AXI MM2S Read Ready
  .m_axi_mm2s_rdata(c0_s_axi_rdata),                      // Master AXI MM2S Read Data
  .m_axi_mm2s_rresp(c0_s_axi_rresp),                      // Master AXI MM2S Read Response
  .m_axi_mm2s_rlast(c0_s_axi_rlast),                      // Master AXI MM2S Read Last
  .m_axi_mm2s_rvalid(c0_s_axi_rvalid),                    // Master AXI MM2S Read Valid
  .m_axi_mm2s_rready(c0_s_axi_rready),                    // Master AXI MM2S Read Ready
  .m_axis_mm2s_tdata(c0_m_axis_read_tdata),                    // Master MM2S AXI Stream Data Output
  .m_axis_mm2s_tkeep(c0_m_axis_read_tkeep),                    // Master MM2S AXI Stream Keep Output
  .m_axis_mm2s_tlast(c0_m_axis_read_tlast),                    // Master MM2S AXI Stream Last Output
  .m_axis_mm2s_tvalid(c0_m_axis_read_tvalid),                  // Master MM2S AXI Stream Valid Output
  .m_axis_mm2s_tready(c0_m_axis_read_tready),                  // Master MM2S AXI Stream Ready Input
  .m_axi_s2mm_aclk(c0_ui_clk),                        // Functional clock for AXI Master S2MM Interface
  .m_axi_s2mm_aresetn(c0_aresetn_r),                  // Asynchronous reset for AXI Master S2MM Interface
  .s2mm_err(),                                      // S2MM Error output
  .m_axis_s2mm_cmdsts_awclk(clk156_25),      // Clock for S2MM Command/Status AXI Stream Interface
  .m_axis_s2mm_cmdsts_aresetn(reset156_25_n),  // Asynchronous reset for S2MM Command/Status AXI Stream Interface
  .s_axis_s2mm_cmd_tvalid(ht_s_axis_write_cmd_tvalid),          // Slave S2MM Command Input Valid
  .s_axis_s2mm_cmd_tready(ht_s_axis_write_cmd_tready),          // Slave S2MM Command Output Ready
  .s_axis_s2mm_cmd_tdata(ht_s_axis_write_cmd_tdata),            // Slave S2MM Command Input Data
  .m_axis_s2mm_sts_tvalid(ht_m_axis_write_sts_tvalid),          // Master S2MM Status Output Valid
  .m_axis_s2mm_sts_tready(ht_m_axis_write_sts_tready),          // Master S2MM Status Input Ready
  .m_axis_s2mm_sts_tdata(ht_m_axis_write_sts_tdata),            // Master S2MM Status Output Data
  .m_axis_s2mm_sts_tkeep(),            // Master S2MM Status Output Keep (unused)
  .m_axis_s2mm_sts_tlast(),            // Master S2MM Status Output Last (unused)
  .m_axi_s2mm_awid(c0_s_axi_awid),                        // Master AXI S2MM Write ID
  .m_axi_s2mm_awaddr(c0_s_axi_awaddr[31:0]),                    // Master AXI S2MM Write Address
  .m_axi_s2mm_awlen(c0_s_axi_awlen),                      // Master AXI S2MM Write Length
  .m_axi_s2mm_awsize(c0_s_axi_awsize),                    // Master AXI S2MM Write Size
  .m_axi_s2mm_awburst(c0_s_axi_awburst),                  // Master AXI S2MM Write Burst
  .m_axi_s2mm_awprot(),                    // Master AXI S2MM Write Protection (unused)
  .m_axi_s2mm_awcache(),                  // Master AXI S2MM Write Cache (unused)
  .m_axi_s2mm_awuser(),                    // Master AXI S2MM Write User (unused)
  .m_axi_s2mm_awvalid(c0_s_axi_awvalid),                  // Master AXI S2MM Write Valid
  .m_axi_s2mm_awready(c0_s_axi_awready),                  // Master AXI S2MM Write Ready
  .m_axi_s2mm_wdata(c0_s_axi_wdata),                      // Master AXI S2MM Write Data
  .m_axi_s2mm_wstrb(c0_s_axi_wstrb),                      // Master AXI S2MM Write Strobe
  .m_axi_s2mm_wlast(c0_s_axi_wlast),                      // Master AXI S2MM Write Last
  .m_axi_s2mm_wvalid(c0_s_axi_wvalid),                    // Master AXI S2MM Write Valid
  .m_axi_s2mm_wready(c0_s_axi_wready),                    // Master AXI S2MM Write Ready
  .m_axi_s2mm_bresp(c0_s_axi_bresp),                      // Master AXI S2MM Write Response
  .m_axi_s2mm_bvalid(c0_s_axi_bvalid),                    // Master AXI S2MM Write Response Valid
  .m_axi_s2mm_bready(c0_s_axi_bready),                    // Master AXI S2MM Write Response Ready
  .s_axis_s2mm_tdata(c0_s_axis_write_tdata),                    // Slave S2MM AXI Stream Data Input
  .s_axis_s2mm_tkeep(c0_s_axis_write_tkeep),                    // Slave S2MM AXI Stream Keep Input
  .s_axis_s2mm_tlast(c0_s_axis_write_tlast),                    // Slave S2MM AXI Stream Last Input
  .s_axis_s2mm_tvalid(c0_s_axis_write_tvalid),                  // Slave S2MM AXI Stream Valid Input
  .s_axis_s2mm_tready(c0_s_axis_write_tready)                   // Slave S2MM AXI Stream Ready Output
);

axis_clock_converter_512 ht_c0_read_data_conv (
  .s_axis_aresetn(c0_aresetn_r),  // Slave Async Reset (driven by c0_ui_clk domain)
  .m_axis_aresetn(reset156_25_n),  // Master Async Reset (driven by clk156_25 domain)
  .s_axis_aclk(c0_ui_clk),        // Slave Clock (DRAM C0 UI Clock)
  .s_axis_tvalid(c0_m_axis_read_tvalid),    // Slave Valid Input
  .s_axis_tready(c0_m_axis_read_tready),    // Slave Ready Output
  .s_axis_tdata(c0_m_axis_read_tdata),      // Slave Data Input
  .s_axis_tkeep(c0_m_axis_read_tkeep),      // Slave Keep Input
  .s_axis_tlast(c0_m_axis_read_tlast),      // Slave Last Input
  .m_axis_aclk(clk156_25),        // Master Clock (System Clock)
  .m_axis_tvalid(ht_m_axis_read_tvalid),    // Master Valid Output
  .m_axis_tready(ht_m_axis_read_tready),    // Master Ready Input
  .m_axis_tdata(ht_m_axis_read_tdata),      // Master Data Output
  .m_axis_tkeep(ht_m_axis_read_tkeep),      // Master Keep Output
  .m_axis_tlast(ht_m_axis_read_tlast)      // Master Last Output
);

axis_clock_converter_512 ht_c0_write_data_conv(
  .s_axis_aresetn(reset156_25_n),  // Slave Async Reset (driven by clk156_25 domain)
  .m_axis_aresetn(c0_aresetn_r),  // Master Async Reset (driven by c0_ui_clk domain)
  .s_axis_aclk(clk156_25),        // Slave Clock (System Clock)
  .s_axis_tvalid(ht_s_axis_write_tvalid),    // Slave Valid Input
  .s_axis_tready(ht_s_axis_write_tready),    // Slave Ready Output
  .s_axis_tdata(ht_s_axis_write_tdata),      // Slave Data Input
  .s_axis_tkeep(ht_s_axis_write_tkeep),      // Slave Keep Input
  .s_axis_tlast(ht_s_axis_write_tlast),      // Slave Last Input
  .m_axis_aclk(c0_ui_clk),        // Master Clock (DRAM C0 UI Clock)
  .m_axis_tvalid(c0_s_axis_write_tvalid),    // Master Valid Output
  .m_axis_tready(c0_s_axis_write_tready),    // Master Ready Input
  .m_axis_tdata(c0_s_axis_write_tdata),      // Master Data Output
  .m_axis_tkeep(c0_s_axis_write_tkeep),      // Master Keep Output
  .m_axis_tlast(c0_s_axis_write_tlast)      // Master Last Output
);

// Instance for VS (Video?) to DRAM C1 communication
axi_datamover_0 vs2dram_data_mover (
  .m_axi_mm2s_aclk(c1_ui_clk),                        // Functional clock for AXI Master MM2S Interface
  .m_axi_mm2s_aresetn(c1_aresetn_r),                  // Asynchronous reset for AXI Master MM2S Interface
  .mm2s_err(),                                      // MM2S Error output
  .m_axis_mm2s_cmdsts_aclk(clk156_25),        // Clock for MM2S Command/Status AXI Stream Interface
  .m_axis_mm2s_cmdsts_aresetn(reset156_25_n),  // Asynchronous reset for MM2S Command/Status AXI Stream Interface
  .s_axis_mm2s_cmd_tvalid(vs_s_axis_read_cmd_tvalid),          // Slave MM2S Command Input Valid
  .s_axis_mm2s_cmd_tready(vs_s_axis_read_cmd_tready),          // Slave MM2S Command Output Ready
  .s_axis_mm2s_cmd_tdata(vs_s_axis_read_cmd_tdata),            // Slave MM2S Command Input Data
  .m_axis_mm2s_sts_tvalid(vs_m_axis_read_sts_tvalid),          // Master MM2S Status Output Valid
  .m_axis_mm2s_sts_tready(vs_m_axis_read_sts_tready),          // Master MM2S Status Input Ready
  .m_axis_mm2s_sts_tdata(vs_m_axis_read_sts_tdata),            // Master MM2S Status Output Data
  .m_axis_mm2s_sts_tkeep(),            // Master MM2S Status Output Keep (unused)
  .m_axis_mm2s_sts_tlast(),            // Master MM2S Status Output Last (unused)
  .m_axi_