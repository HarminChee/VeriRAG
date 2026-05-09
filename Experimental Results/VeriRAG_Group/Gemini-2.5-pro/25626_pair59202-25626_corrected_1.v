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
// Internal connections for DDR3 instances and AXIS interfaces
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

// Internal signals for reset synchronization and AXI interface logic
wire                   c0_ui_clk_sync_rst; // Driven by ddr3_0
wire                   c0_mmcm_locked;     // Driven by ddr3_0
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

wire             c1_ui_clk_sync_rst; // Driven by ddr3_1
wire             c1_mmcm_locked;     // Driven by ddr3_1
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

// Synchronous reset generation based on DDR UI clock and MMCM lock status
// Note: Using internally generated clocks (c0_ui_clk, c1_ui_clk) violates DFT rules (CLKNPI/FFCKNP).
//       The generated resets (c0_aresetn_r, c1_aresetn_r) might also cause issues.
//       These are kept as per the original logic for syntax correction.
always @(posedge c0_ui_clk) begin
    if (c0_ui_clk_sync_rst) // Assuming active high sync reset from DDR IP
        c0_aresetn_r <= 1'b0;
    else
        c0_aresetn_r <= c0_mmcm_locked; // Assert reset low until MMCM is locked
end

always @(posedge c1_ui_clk) begin
     if (c1_ui_clk_sync_rst) // Assuming active high sync reset from DDR IP
        c1_aresetn_r <= 1'b0;
    else
        c1_aresetn_r <= c1_mmcm_locked; // Assert reset low until MMCM is locked
end

// Tie off upper address bits (assuming 32-bit address space for AXI)
assign c0_s_axi_awaddr[32] = 1'b0;
assign c0_s_axi_araddr[32] = 1'b0;
assign c1_s_axi_awaddr[32] = 1'b0;
assign c1_s_axi_araddr[32] = 1'b0;

// Instantiate AXI Datamover for HT interface (Host Transaction)
// Assuming 'axi_datamover_0' is the correct module name
axi_datamover_0 ht2dram_data_mover (
  // MM2S Interface (Read from Memory)
  .m_axi_mm2s_aclk(c0_ui_clk),                        // Clocked by DDR UI Clock (DFT Issue)
  .m_axi_mm2s_aresetn(c0_aresetn_r),                  // Reset by internally generated reset (DFT Issue)
  .mm2s_err(),                                      // Output: MM2S Error Status
  .m_axis_mm2s_cmdsts_aclk(clk156_25),                // Command/Status Clock (Primary Input - Good)
  .m_axis_mm2s_cmdsts_aresetn(reset156_25_n),         // Command/Status Reset (Primary Input - Good)
  .s_axis_mm2s_cmd_tvalid(ht_s_axis_read_cmd_tvalid), // Input: Read Command Valid
  .s_axis_mm2s_cmd_tready(ht_s_axis_read_cmd_tready), // Output: Read Command Ready
  .s_axis_mm2s_cmd_tdata(ht_s_axis_read_cmd_tdata),   // Input: Read Command Data
  .m_axis_mm2s_sts_tvalid(ht_m_axis_read_sts_tvalid), // Output: Read Status Valid
  .m_axis_mm2s_sts_tready(ht_m_axis_read_sts_tready), // Input: Read Status Ready
  .m_axis_mm2s_sts_tdata(ht_m_axis_read_sts_tdata),   // Output: Read Status Data
  .m_axis_mm2s_sts_tkeep(),                           // Output: Read Status Keep (unused)
  .m_axis_mm2s_sts_tlast(),                           // Output: Read Status Last (unused)
  .m_axi_mm2s_arid(c0_s_axi_arid),                    // Output: AXI Read ID
  .m_axi_mm2s_araddr(c0_s_axi_araddr[31:0]),           // Output: AXI Read Address
  .m_axi_mm2s_arlen(c0_s_axi_arlen),                  // Output: AXI Read Length
  .m_axi_mm2s_arsize(c0_s_axi_arsize),                // Output: AXI Read Size
  .m_axi_mm2s_arburst(c0_s_axi_arburst),              // Output: AXI Read Burst
  .m_axi_mm2s_arprot(),                               // Output: AXI Read Protection (unused)
  .m_axi_mm2s_arcache(),                              // Output: AXI Read Cache (unused)
  .m_axi_mm2s_aruser(),                               // Output: AXI Read User (unused)
  .m_axi_mm2s_arvalid(c0_s_axi_arvalid),              // Output: AXI Read Valid
  .m_axi_mm2s_arready(c0_s_axi_arready),              // Input: AXI Read Ready
  .m_axi_mm2s_rdata(c0_s_axi_rdata),                  // Input: AXI Read Data
  .m_axi_mm2s_rresp(c0_s_axi_rresp),                  // Input: AXI Read Response
  .m_axi_mm2s_rlast(c0_s_axi_rlast),                  // Input: AXI Read Last
  .m_axi_mm2s_rvalid(c0_s_axi_rvalid),                // Input: AXI Read Valid
  .m_axi_mm2s_rready(c0_s_axi_rready),                // Output: AXI Read Ready
  .m_axis_mm2s_tdata(ht_m_axis_read_tdata),           // Output: Read Data Stream Data
  .m_axis_mm2s_tkeep(ht_m_axis_read_tkeep),           // Output: Read Data Stream Keep
  .m_axis_mm2s_tlast(ht_m_axis_read_tlast),           // Output: Read Data Stream Last
  .m_axis_mm2s_tvalid(ht_m_axis_read_tvalid),         // Output: Read Data Stream Valid
  .m_axis_mm2s_tready(ht_m_axis_read_tready),         // Input: Read Data Stream Ready

  // S2MM Interface (Write to Memory)
  .m_axi_s2mm_aclk(c0_ui_clk),                        // Clocked by DDR UI Clock (DFT Issue)
  .m_axi_s2mm_aresetn(c0_aresetn_r),                  // Reset by internally generated reset (DFT Issue)
  .s2mm_err(),                                      // Output: S2MM Error Status
  .m_axis_s2mm_cmdsts_awclk(clk156_25),               // Command/Status Clock (Primary Input - Good)
  .m_axis_s2mm_cmdsts_aresetn(reset156_25_n),         // Command/Status Reset (Primary Input - Good)
  .s_axis_s2mm_cmd_tvalid(ht_s_axis_write_cmd_tvalid),// Input: Write Command Valid
  .s_axis_s2mm_cmd_tready(ht_s_axis_write_cmd_tready),// Output: Write Command Ready
  .s_axis_s2mm_cmd_tdata(ht_s_axis_write_cmd_tdata),  // Input: Write Command Data
  .m_axis_s2mm_sts_tvalid(ht_m_axis_write_sts_tvalid),// Output: Write Status Valid
  .m_axis_s2mm_sts_tready(ht_m_axis_write_sts_tready),// Input: Write Status Ready
  .m_axis_s2mm_sts_tdata(ht_m_axis_write_sts_tdata),  // Output: Write Status Data
  .m_axis_s2mm_sts_tkeep(),                           // Output: Write Status Keep (unused)
  .m_axis_s2mm_sts_tlast(),                           // Output: Write Status Last (unused)
  .m_axi_s2mm_awid(c0_s_axi_awid),                    // Output: AXI Write ID
  .m_axi_s2mm_awaddr(c0_s_axi_awaddr[31:0]),           // Output: AXI Write Address
  .m_axi_s2mm_awlen(c0_s_axi_awlen),                  // Output: AXI Write Length
  .m_axi_s2mm_awsize(c0_s_axi_awsize),                // Output: AXI Write Size
  .m_axi_s2mm_awburst(c0_s_axi_awburst),              // Output: AXI Write Burst
  .m_axi_s2mm_awprot(),                               // Output: AXI Write Protection (unused)
  .m_axi_s2mm_awcache(),                              // Output: AXI Write Cache (unused)
  .m_axi_s2mm_awuser(),                               // Output: AXI Write User (unused)
  .m_axi_s2mm_awvalid(c0_s_axi_awvalid),              // Output: AXI Write Valid
  .m_axi_s2mm_awready(c0_s_axi_awready),              // Input: AXI Write Ready
  .m_axi_s2mm_wdata(c0_s_axi_wdata),                  // Output: AXI Write Data
  .m_axi_s2mm_wstrb(c0_s_axi_wstrb),                  // Output: AXI Write Strobe
  .m_axi_s2mm_wlast(c0_s_axi_wlast),                  // Output: AXI Write Last
  .m_axi_s2mm_wvalid(c0_s_axi_wvalid),                // Output: AXI Write Valid
  .m_axi_s2mm_wready(c0_s_axi_wready),                // Input: AXI Write Ready
  .m_axi_s