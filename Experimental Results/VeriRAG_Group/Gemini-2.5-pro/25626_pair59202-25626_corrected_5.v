`timescale 1ns / 1ps

// Placeholder stub for DDR3 IP Core
module ddr3_core (
  input sys_clk_p, input sys_clk_n,
  input clk_ref_p, input clk_ref_n,
  input sys_rst,
  inout [71:0] dq, inout [8:0] dqs_n, inout [8:0] dqs_p,
  output [15:0] addr, output [2:0] ba, output ras_n,
  output cas_n, output we_n, output reset_n,
  output [1:0] ck_p, output [1:0] ck_n, output [1:0] cke,
  output [1:0] cs_n, output [1:0] odt,
  output ui_clk, output ui_clk_sync_rst, output mmcm_locked,
  output init_calib_complete,
  // AXI Slave Interface
  input           s_axi_aclk,
  input           s_axi_aresetn,
  input  [4:0]    s_axi_awid, input  [32:0]  s_axi_awaddr, input  [7:0]   s_axi_awlen,
  input  [2:0]    s_axi_awsize, input  [1:0]   s_axi_awburst, input           s_axi_awvalid,
  output          s_axi_awready,
  input  [511:0]  s_axi_wdata, input  [63:0]  s_axi_wstrb, input           s_axi_wlast,
  input           s_axi_wvalid, output          s_axi_wready,
  output [4:0]    s_axi_bid, output [1:0]    s_axi_bresp, output          s_axi_bvalid,
  input           s_axi_bready,
  input  [4:0]    s_axi_arid, input  [32:0]  s_axi_araddr, input  [7:0]   s_axi_arlen,
  input  [2:0]    s_axi_arsize, input  [1:0]   s_axi_arburst, input           s_axi_arvalid,
  output          s_axi_arready,
  output [4:0]    s_axi_rid, output [511:0]  s_axi_rdata, output [1:0]    s_axi_rresp,
  output          s_axi_rlast, output          s_axi_rvalid,
  input           s_axi_rready
);
// Stub - no internal logic
endmodule

// Placeholder stub for HT Datamover
module ht_datamover (
    input clk,
    input reset_n,

    // AXI Stream Slave (Read Command)
    input           s_axis_read_cmd_tvalid,
    output          s_axis_read_cmd_tready,
    input[71:0]     s_axis_read_cmd_tdata,

    // AXI Stream Master (Read Status)
    output          m_axis_read_sts_tvalid,
    input           m_axis_read_sts_tready,
    output[7:0]     m_axis_read_sts_tdata,

    // AXI Stream Master (Read Data)
    output[511:0]    m_axis_read_tdata,
    output[63:0]     m_axis_read_tkeep,
    output          m_axis_read_tlast,
    output          m_axis_read_tvalid,
    input           m_axis_read_tready,

    // AXI Stream Slave (Write Command)
    input           s_axis_write_cmd_tvalid,
    output          s_axis_write_cmd_tready,
    input[71:0]     s_axis_write_cmd_tdata,

    // AXI Stream Master (Write Status)
    output          m_axis_write_sts_tvalid,
    input           m_axis_write_sts_tready,
    output[7:0]     m_axis_write_sts_tdata,

    // AXI Stream Slave (Write Data)
    input[511:0]     s_axis_write_tdata,
    input[63:0]      s_axis_write_tkeep,
    input           s_axis_write_tlast,
    input           s_axis_write_tvalid,
    output          s_axis_write_tready,

    // AXI Master Interface (Connected to DDR IP)
    output  [4:0]    m_axi_awid,
    output  [32:0]   m_axi_awaddr,
    output  [7:0]    m_axi_awlen,
    output  [2:0]    m_axi_awsize,
    output  [1:0]    m_axi_awburst,
    output           m_axi_awvalid,
    input            m_axi_awready,
    output  [511:0]  m_axi_wdata,
    output  [63:0]   m_axi_wstrb,
    output           m_axi_wlast,
    output           m_axi_wvalid,
    input            m_axi_wready,
    input [4:0]      m_axi_bid,
    input [1:0]      m_axi_bresp,
    input            m_axi_bvalid,
    output           m_axi_bready,
    output [4:0]     m_axi_arid,
    output [32:0]    m_axi_araddr,
    output [7:0]     m_axi_arlen,
    output [2:0]     m_axi_arsize,
    output [1:0]     m_axi_arburst,
    output           m_axi_arvalid,
    input            m_axi_arready,
    input [4:0]      m_axi_rid,
    input [511:0]    m_axi_rdata,
    input [1:0]      m_axi_rresp,
    input            m_axi_rlast,
    input            m_axi_rvalid,
    output           m_axi_rready
);
// Stub - no internal logic
endmodule

// Placeholder stub for VS Datamover
module vs_datamover (
    input clk,
    input reset_n,

    // AXI Stream Slave (Read Command)
    input           s_axis_read_cmd_tvalid,
    output          s_axis_read_cmd_tready,
    input[71:0]     s_axis_read_cmd_tdata,

    // AXI Stream Master (Read Status)
    output          m_axis_read_sts_tvalid,
    input           m_axis_read_sts_tready,
    output[7:0]     m_axis_read_sts_tdata,

    // AXI Stream Master (Read Data)
    output[511:0]    m_axis_read_tdata,
    output[63:0]     m_axis_read_tkeep,
    output          m_axis_read_tlast,
    output          m_axis_read_tvalid,
    input           m_axis_read_tready,

    // AXI Stream Slave (Write Command)
    input           s_axis_write_cmd_tvalid,
    output          s_axis_write_cmd_tready,
    input[71:0]     s_axis_write_cmd_tdata,

    // AXI Stream Master (Write Status)
    output          m_axis_write_sts_tvalid,
    input           m_axis_write_sts_tready,
    output[7:0]     m_axis_write_sts_tdata,

    // AXI Stream Slave (Write Data)
    input[511:0]     s_axis_write_tdata,
    input[63:0]      s_axis_write_tkeep,
    input           s_axis_write_tlast,
    input           s_axis_write_tvalid,
    output          s_axis_write_tready,

    // AXI Master Interface (Connected to DDR IP)
    output  [4:0]    m_axi_awid,
    output  [32:0]   m_axi_awaddr,
    output  [7:0]    m_axi_awlen,
    output  [2:0]    m_axi_awsize,
    output  [1:0]    m_axi_awburst,
    output           m_axi_awvalid,
    input            m_axi_awready,
    output  [511:0]  m_axi_wdata,
    output  [63:0]   m_axi_wstrb,
    output           m_axi_wlast,
    output           m_axi_wvalid,
    input            m_axi_wready,
    input [4:0]      m_axi_bid,
    input [1:0]      m_axi_bresp,
    input            m_axi_bvalid,
    output           m_axi_bready,
    output [4:0]     m_axi_arid,
    output [32:0]    m_axi_araddr,
    output [7:0]     m_axi_arlen,
    output [2:0]     m_axi_arsize,
    output [1:0]     m_axi_arburst,
    output           m_axi_arvalid,
    input            m_axi_arready,
    input [4:0]      m_axi_rid,
    input [511:0]    m_axi_rdata,
    input [1:0]      m_axi_rresp,
    input            m_axi_rlast,
    input            m_axi_rvalid,
    output           m_axi_rready
);
// Stub - no internal logic
endmodule


module dram_inf
(
input clk156_25,
input reset156_25_n,
// input sys_rst, // Assuming this is the primary asynchronous reset for DFT purposes if needed - Can use reset156_25_n or add a dedicated one
input				c0_sys_clk_p,
input				c0_sys_clk_n,
input				c1_sys_clk_p,
input				c1_sys_clk_n,
input				clk_ref_p,
input				clk_ref_n,

// DFT Inputs
input           scan_mode,      // DFT Scan Mode enable
input           test_clk,       // DFT Scan Clock (can be tied to clk156_25 or separate)
input           test_reset_n,   // DFT Asynchronous Reset (active low)

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
output           c0_ui_clk, // Note: Generated by DDR IP; Clocking internal logic below with this can cause CLKNPI/FFCKNP
output           c0_init_calib_complete,
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
output           c1_ui_clk, // Note: Generated by DDR IP; Clocking internal logic below with this can cause CLKNPI/FFCKNP
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

// Internal signals from DDR3 IP (Assume ddr3_0 and ddr3_1 instances exist)
wire                   c0_ui_clk_internal; // Internal wire for clock generated by ddr3_0
wire                   c0_ui_clk_sync_rst; // Driven by ddr3_0
wire                   c0_mmcm_locked;     // Driven by ddr3_0
wire                   c1_ui_clk_internal; // Internal wire for clock generated by ddr3_1
wire                   c1_ui_clk_sync_rst; // Driven by ddr3_1
wire                   c1_mmcm_locked;     // Driven by ddr3_1

// Assign internal clocks to output ports
assign c0_ui_clk = c0_ui_clk_internal;
assign c1_ui_clk = c1_ui_clk_internal;

// DFT Clock and Reset Muxing
wire c0_logic_clk;
assign c0_logic_clk = scan_mode ? test_clk : c0_ui_clk_internal;

wire c1_logic_clk;
assign c1_logic_clk = scan_mode ? test_clk : c1_ui_clk_internal;

wire c0_logic_reset_n; // Active low reset for logic clocked by c0_logic_clk
wire c1_logic_reset_n; // Active low reset for logic clocked by c1_logic_clk

// Reset Synchronization logic
wire reset156_25; // Use active high reset internally for synchronizer
assign reset156_25 = ~reset156_25_n; // Assuming reset156_25_n is the primary reset source

// Synchronizer for c0_ui_clk domain (now uses muxed clock for DFT)
reg c0_reset_sync0, c0_reset_sync1;
wire c0_aresetn_sync_internal; // Internal synchronized reset (active low)
// CLKNPI/FFCKNP VIOLATION MITIGATED: Clocked by c0_logic_clk (muxed)
always @(posedge c0_logic_clk) begin
    c0_reset_sync0 <= reset156_25; // Synchronize primary reset
    c0_reset_sync1 <= c0_reset_sync0;
end
assign c0_aresetn_sync_internal = ~c0_reset_sync1; // Active low output

// Select reset based on mode for c0 domain logic
assign c0_logic_reset_n = scan_mode ? test_reset_n : c0_aresetn_sync_internal;

// Synchronizer for c1_ui_clk domain (now uses muxed clock for DFT)
reg c1_reset_sync0, c1_reset_sync1;
wire c1_aresetn_sync_internal; // Internal synchronized reset (active low)
// CLKNPI/FFCKNP VIOLATION MITIGATED: Clocked by c1_logic_clk (muxed)
always @(posedge c1_logic_clk) begin
    c1_reset_sync0 <= reset156_25; // Synchronize primary reset
    c1_reset_sync1 <= c1_reset_sync0;
end
assign c1_aresetn_sync_internal = ~c1_reset_sync1; // Active low output

// Select reset based on mode for c1 domain logic
assign c1_logic_reset_n = scan_mode ? test_reset_n : c1_aresetn_sync_internal;


// AXI Interface signals between datamovers and DDR IPs (driven/used by datamovers)
wire  [4:0]            c0_s_axi_awid;
wire  [32:0]           c0_s_axi_awaddr; // 33 bits
wire  [7:0]            c0_s_axi_awlen;
wire  [2:0]            c0_s_axi_awsize;
wire  [1:0]            c0_s_axi_awburst;
wire                   c0_s_axi_awvalid;
wire                   c0_s_axi_awready; // Driven by DDR IP AXI Slave Interface
wire  [511:0]          c0_s_axi_wdata;
wire  [63:0]           c0_s_axi_wstrb;
wire                   c0_s_axi_wlast;
wire                   c0_s_axi_wvalid;
wire                   c0_s_axi_wready; // Driven by DDR IP AXI Slave Interface
wire [4:0]             c0_s_axi_bid;    // Driven by DDR IP AXI Slave Interface
wire [1:0]             c0_s_axi_bresp;  // Driven by DDR IP AXI Slave Interface
wire                   c0_s_axi_bvalid; // Driven by DDR IP AXI Slave Interface
wire                   c0_s_axi_bready;
wire  [4:0]           c0_s_axi_arid;
wire  [32:0]          c0_s_axi_araddr; // 33 bits
wire  [7:0]           c0_s_axi_arlen;
wire  [2:0]           c0_s_axi_arsize;
wire  [1:0]           c0_s_axi_arburst;
wire                  c0_s_axi_arvalid;
wire                  c0_s_axi_arready; // Driven by