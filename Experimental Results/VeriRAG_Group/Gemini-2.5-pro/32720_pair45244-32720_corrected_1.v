`timescale 1ns / 1ps
module mem_inf #(
    parameter C0_SIMULATION          =  "FALSE",
    parameter C1_SIMULATION           = "FALSE",
    parameter C0_SIM_BYPASS_INIT_CAL  = "OFF",
    parameter C1_SIM_BYPASS_INIT_CAL = "OFF"
)
(
input               clk156_25, // Assumed to be the reference clock for DFT muxing if needed
input               reset156_25_n, // Assumed to be a primary reset
inout [71:0]        c0_ddr3_dq,
inout [8:0]         c0_ddr3_dqs_n,
inout [8:0]         c0_ddr3_dqs_p,
output [15:0]       c0_ddr3_addr,
output [2:0]        c0_ddr3_ba,
output              c0_ddr3_ras_n,
output              c0_ddr3_cas_n,
output              c0_ddr3_we_n,
output              c0_ddr3_reset_n,
output [1:0]        c0_ddr3_ck_p,
output [1:0]        c0_ddr3_ck_n,
output [1:0]        c0_ddr3_cke,
output [1:0]        c0_ddr3_cs_n,
output [1:0]        c0_ddr3_odt,
output              c0_ui_clk,
output              c0_init_calib_complete,
input               c0_sys_clk_p,
input               c0_sys_clk_n,
input               clk_ref_p,      // MIG Reference Clock
input               clk_ref_n,      // MIG Reference Clock
input               c1_sys_clk_p,
input               c1_sys_clk_n,
input               sys_rst,        // Primary System Reset (Active High)
inout [71:0]        c1_ddr3_dq,
inout [8:0]         c1_ddr3_dqs_n,
inout [8:0]         c1_ddr3_dqs_p,
output [15:0]       c1_ddr3_addr,
output [2:0]        c1_ddr3_ba,
output              c1_ddr3_ras_n,
output              c1_ddr3_cas_n,
output              c1_ddr3_we_n,
output              c1_ddr3_reset_n,
output [1:0]        c1_ddr3_ck_p,
output [1:0]        c1_ddr3_ck_n,
output [1:0]        c1_ddr3_cke,
output [1:0]        c1_ddr3_cs_n,
output [1:0]        c1_ddr3_odt,
output              c1_ui_clk,
output              c1_init_calib_complete,

// Application Interfaces (Mapped to AXI below)
// ToeTX Interface (Example mapping to c0_s_axi)
input               toeTX_s_axis_read_cmd_tvalid,
output              toeTX_s_axis_read_cmd_tready, // c0_s_axi_arready
input[71:0]         toeTX_s_axis_read_cmd_tdata,  // Contains address/len etc. for c0_s_axi_ar*
output              toeTX_m_axis_read_sts_tvalid, // c0_s_axi_rvalid
input               toeTX_m_axis_read_sts_tready, // c0_s_axi_rready
output[7:0]         toeTX_m_axis_read_sts_tdata,  // c0_s_axi_rresp + potentially rid
output[63:0]        toeTX_m_axis_read_tdata,      // c0_s_axi_rdata (lower 64 bits)
output[7:0]         toeTX_m_axis_read_tkeep,      // Derived from c0_s_axi_rdata size/alignment
output              toeTX_m_axis_read_tlast,      // c0_s_axi_rlast
output              toeTX_m_axis_read_tvalid,     // c0_s_axi_rvalid
input               toeTX_m_axis_read_tready,     // c0_s_axi_rready

input               toeTX_s_axis_write_cmd_tvalid,
output              toeTX_s_axis_write_cmd_tready,// c0_s_axi_awready
input[71:0]         toeTX_s_axis_write_cmd_tdata, // Contains address/len etc. for c0_s_axi_aw*
output              toeTX_m_axis_write_sts_tvalid,// c0_s_axi_bvalid
input               toeTX_m_axis_write_sts_tready,// c0_s_axi_bready
output[7:0]         toeTX_m_axis_write_sts_tdata, // c0_s_axi_bresp + potentially bid
input[63:0]         toeTX_s_axis_write_tdata,     // c0_s_axi_wdata (lower 64 bits)
input[7:0]          toeTX_s_axis_write_tkeep,     // c0_s_axi_wstrb (lower 8 bytes)
input               toeTX_s_axis_write_tlast,     // c0_s_axi_wlast
input               toeTX_s_axis_write_tvalid,    // c0_s_axi_wvalid
output              toeTX_s_axis_write_tready,    // c0_s_axi_wready

// ToeRX Interface (Example mapping to c1_s_axi)
input               toeRX_s_axis_read_cmd_tvalid,
output              toeRX_s_axis_read_cmd_tready, // c1_s_axi_arready
input[71:0]         toeRX_s_axis_read_cmd_tdata,  // Contains address/len etc. for c1_s_axi_ar*
output              toeRX_m_axis_read_sts_tvalid, // c1_s_axi_rvalid
input               toeRX_m_axis_read_sts_tready, // c1_s_axi_rready
output[7:0]         toeRX_m_axis_read_sts_tdata,  // c1_s_axi_rresp + potentially rid
output[63:0]        toeRX_m_axis_read_tdata,      // c1_s_axi_rdata (lower 64 bits)
output[7:0]         toeRX_m_axis_read_tkeep,      // Derived from c1_s_axi_rdata size/alignment
output              toeRX_m_axis_read_tlast,      // c1_s_axi_rlast
output              toeRX_m_axis_read_tvalid,     // c1_s_axi_rvalid
input               toeRX_m_axis_read_tready,     // c1_s_axi_rready

input               toeRX_s_axis_write_cmd_tvalid,
output              toeRX_s_axis_write_cmd_tready,// c1_s_axi_awready
input[71:0]         toeRX_s_axis_write_cmd_tdata, // Contains address/len etc. for c1_s_axi_aw*
output              toeRX_m_axis_write_sts_tvalid,// c1_s_axi_bvalid
input               toeRX_m_axis_write_sts_tready,// c1_s_axi_bready
output[7:0]         toeRX_m_axis_write_sts_tdata, // c1_s_axi_bresp + potentially bid
input[63:0]         toeRX_s_axis_write_tdata,     // c1_s_axi_wdata (lower 64 bits)
input[7:0]          toeRX_s_axis_write_tkeep,     // c1_s_axi_wstrb (lower 8 bytes)
input               toeRX_s_axis_write_tlast,     // c1_s_axi_wlast
input               toeRX_s_axis_write_tvalid,    // c1_s_axi_wvalid
output              toeRX_s_axis_write_tready,    // c1_s_axi_wready

// HT Interface (Example mapping to c0_s_axi) - Requires wider AXI or multiple bursts
input               ht_s_axis_read_cmd_tvalid,
output              ht_s_axis_read_cmd_tready,    // c0_s_axi_arready
input[71:0]         ht_s_axis_read_cmd_tdata,     // Contains address/len etc. for c0_s_axi_ar*
output              ht_m_axis_read_sts_tvalid,    // c0_s_axi_rvalid (last beat)
input               ht_m_axis_read_sts_tready,    // c0_s_axi_rready
output[7:0]         ht_m_axis_read_sts_tdata,     // c0_s_axi_rresp + potentially rid
output[511:0]       ht_m_axis_read_tdata,         // c0_s_axi_rdata (aggregated)
output[63:0]        ht_m_axis_read_tkeep,         // Derived from c0_s_axi_rdata size/alignment
output              ht_m_axis_read_tlast,         // c0_s_axi_rlast
output              ht_m_axis_read_tvalid,        // c0_s_axi_rvalid
input               ht_m_axis_read_tready,        // c0_s_axi_rready

input               ht_s_axis_write_cmd_tvalid,
output              ht_s_axis_write_cmd_tready,   // c0_s_axi_awready
input[71:0]         ht_s_axis_write_cmd_tdata,    // Contains address/len etc. for c0_s_axi_aw*
output              ht_m_axis_write_sts_tvalid,   // c0_s_axi_bvalid
input               ht_m_axis_write_sts_tready,   // c0_s_axi_bready
output[7:0]         ht_m_axis_write_sts_tdata,    // c0_s_axi_bresp + potentially bid
input[511:0]        ht_s_axis_write_tdata,        // c0_s_axi_wdata (aggregated)
input[63:0]         ht_s_axis_write_tkeep,        // c0_s_axi_wstrb (aggregated)
input               ht_s_axis_write_tlast,        // c0_s_axi_wlast
input               ht_s_axis_write_tvalid,       // c0_s_axi_wvalid
output              ht_s_axis_write_tready,       // c0_s_axi_wready

// UPD Interface (Example mapping to c1_s_axi) - Requires wider AXI or multiple bursts
input               upd_s_axis_read_cmd_tvalid,
output              upd_s_axis_read_cmd_tready,   // c1_s_axi_arready
input[71:0]         upd_s_axis_read_cmd_tdata,    // Contains address/len etc. for c1_s_axi_ar*
output              upd_m_axis_read_sts_tvalid,   // c1_s_axi_rvalid (last beat)
input               upd_m_axis_read_sts_tready,   // c1_s_axi_rready
output[7:0]         upd_m_axis_read_sts_tdata,    // c1_s_axi_rresp + potentially rid
output[511:0]       upd_m_axis_read_tdata,        // c1_s_axi_rdata (aggregated)
output[63:0]        upd_m_axis_read_tkeep,        // Derived from c1_s_axi_rdata size/alignment
output              upd_m_axis_read_tlast,        // c1_s_axi_rlast
output              upd_m_axis_read_tvalid,       // c1_s_axi_rvalid
input               upd_m_axis_read_tready,       // c1_s_axi_rready

input               upd_s_axis_write_cmd_tvalid,
output              upd_s_axis_write_cmd_tready,  // c1_s_axi_awready
input[71:0]         upd_s_axis_write_cmd_tdata,   // Contains address/len etc. for c1_s_axi_aw*
output              upd_m_axis_write_sts_tvalid,  // c1_s_axi_bvalid
input               upd_m_axis_write_sts_tready,  // c1_s_axi_bready
output[7:0]         upd_m_axis_write_sts_tdata,   // c1_s_axi_bresp + potentially bid
input[511:0]        upd_s_axis_write_tdata,       // c1_s_axi_wdata (aggregated)
input[63:0]         upd_s_axis_write_tkeep,       // c1_s_axi_wstrb (aggregated)
input               upd_s_axis_write_tlast,       // c1_s_axi_wlast
input               upd_s_axis_write_tvalid,      // c1_s_axi_wvalid
output              upd_s_axis_write_tready,      // c1_s_axi_wready

input               test_mode // Added test_mode input
);

// Parameters based on MIG7 defaults for AXI interface (adjust if needed)
localparam C0_C_S_AXI_ID_WIDTH = 4;     // Example width
localparam C0_C_S_AXI_ADDR_WIDTH = 32;   // Example width (adjust based on memory size)
localparam C0_C_S_AXI_DATA_WIDTH = 64;   // Example width (adjust based on DDR interface)
localparam C1_C_S_AXI_ID_WIDTH = 4;     // Example width
localparam C1_C_S_AXI_ADDR_WIDTH = 32;   // Example width (adjust based on memory size)
localparam C1_C_S_AXI_DATA_WIDTH = 64;   // Example width (adjust based on DDR interface)

// Internal signals for MIG Controller 0
wire                                    c0_ui_clk_sync_rst;
wire                                    c0_mmcm_locked;
reg                                     c0_aresetn_r; // Synchronized reset for MIG
wire                                    c0_app_sr_active;
wire                                    c0_app_ref_ack;
wire                                    c0_app_zq_ack;
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_awid;
wire [C0_C_S_AXI_ADDR_WIDTH-1:0]        c0_s_axi_awaddr;
wire [7:0]                              c0_s_axi_awlen;
wire [2:0]                              c0_s_axi_awsize;
wire [1:0]                              c0_s_axi_awburst;
wire                                    c0_s_axi_awlock; // Tied low typically
wire [3:0]                              c0_s_axi_awcache; // Tied low typically
wire [2:0]                              c0_s_axi_awprot; // Tied low typically
wire [3:0]                              c0_s_axi_awqos;  // Tied low typically
wire                                    c0_s_axi_awvalid;
wire                                    c0_s_axi_awready;
wire [C0_C_S_AXI_DATA_WIDTH-1:0]        c0_s_axi_wdata;
wire [(C0_C_S_AXI_DATA_WIDTH/8)-1:0]    c0_s_axi_wstrb;
wire                                    c0_s_axi_wlast;
wire                                    c0_s_axi_wvalid;
wire                                    c0_s_axi_wready;
wire                                    c0_s_axi_bready;
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_bid;
wire [1:0]                              c0_s_axi_bresp;
wire                                    c0_s_axi_bvalid;
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_arid;
wire [C0_C_S_AXI_ADDR_WIDTH-1:0]        c0_s_axi_araddr;
wire [7:0]                              c0_s_axi_arlen;
wire [2:0]                              c0_s_axi_arsize;
wire [1:0]                              c0_s_axi_arburst;
wire                                    c0_s_axi_arlock; // Tied low typically
wire [3:0]                              c0_s_axi_arcache; // Tied low typically
wire [2:0]                              c0_s_axi_arprot; // Tied low typically
wire [3:0]                              c0_s_axi_arqos; // Tied low typically
wire                                    c0_s_axi_arvalid;
wire                                    c0_s_axi_arready;
wire                                    c0_s_axi_rready;
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_rid;
wire [C0_C_S_AXI_DATA_WIDTH-1:0]        c0_s_axi_rdata;
wire [1:0]                              c0_s_axi_rresp;
wire                                    c0_s_axi_rlast;
wire                                    c0_s_axi_rvalid;

// Internal signals for MIG Controller 1
wire                                    c1_ui_clk_sync_rst;
wire                                    c1_mmcm_locked;
reg                                     c1_aresetn_r; // Synchronized reset for MIG
wire                                    c1_app_sr_active;
wire                                    c1_app_ref_ack;
wire                                    c1_app_zq_ack;
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_awid;
wire [C1_C_S_AXI_ADDR_WIDTH-1:0]        c1_s_axi_awaddr;
wire [7:0]                              c1_s_axi_awlen;
wire [2:0]                              c1_s_axi_awsize;
wire [1:0]                              c1_s_axi_awburst;
wire                                    c1_s_axi_awlock; // Tied low typically
wire [3:0]                              c1_s_axi_awcache; // Tied low typically
wire [2:0]                              c1_s_axi_awprot; // Tied low typically
wire [3:0]                              c1_s_axi_awqos; // Tied low typically
wire                                    c1_s_axi_awvalid;
wire                                    c1_s_axi_awready;
wire [C1_C_S_AXI_DATA_WIDTH-1:0]        c1_s_axi_wdata;
wire [(C1_C_S_AXI_DATA_WIDTH/8)-1:0]    c1_s_axi_wstrb;
wire                                    c1_s_axi_wlast;
wire                                    c1_s_axi_wvalid;
wire                                    c1_s_axi_wready;
wire                                    c1_s_axi_bready;
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_bid;
wire [1:0]                              c1_s_axi_bresp;
wire                                    c1_s_axi_bvalid;
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_arid;
wire [C1_C_S_AXI_ADDR_WIDTH-1:0]        c1_s_axi_araddr;
wire [7:0]                              c1_s_axi_arlen;
wire [2:0]                              c1_s_axi_arsize;
wire [1:0]                              c1_s_axi_arburst;
wire                                    c1_s_axi_arlock; // Tied low typically
wire [3:0]                              c1_s_axi_arcache; // Tied low typically
wire [2:0]                              c1_s_axi_arprot; // Tied low typically
wire [3:0]                              c1_s_axi_arqos; // Tied low typically
wire                                    c1_s_axi_arvalid;
wire                                    c1_s_axi_arready;
wire                                    c1_s_axi_rready;
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_rid;
wire [C1_C_S_AXI_DATA_WIDTH-1:0]        c1_s_axi_rdata;
wire [1:0]                              c1_s_axi_rresp;
wire                                    c1_s_axi_rlast;
wire                                    c1_s_axi_rvalid;

// DFT clock muxing
wire                                    dft_c0_ui_clk;
wire                                    dft_c1_ui_clk;
// Use clk156_25 as the test clock source, assuming it's a primary clock input suitable for testing
// If clk156_25 is not suitable, another primary clock input should be used or added.
assign dft_c0_ui_clk = test_mode ? clk156_25 : c0_ui_clk;
assign dft_c1_ui_clk = test_mode ? clk156_25 : c1_ui_clk;

// Reset Synchronization Logic (using primary reset sys_rst)
// Generate active low reset synchronous to the respective DFT-muxed UI clocks
always @(posedge dft_c0_ui_clk or posedge sys_rst) begin
  if (sys_rst) begin
    c0_aresetn_r <= 1'b0;
  end else begin
    // De-assert reset only when MMCM is locked (during functional mode)
    // In test_mode, c0_mmcm_locked might be unknown or forced, keep reset asserted if sys_rst is low
    c0_aresetn_r <= c0_mmcm_locked;
  end
end

always @(posedge dft_c1_ui_clk or posedge sys_rst) begin
  if (sys_rst) begin
    c1_aresetn_r <= 1'b0;
  end else begin
    // De-assert reset only when MMCM is locked (during functional mode)
    // In test_mode, c1_mmcm_locked might be unknown or forced, keep reset asserted if sys_rst is low
    c1_aresetn_r <= c1_mmcm_locked;
  end
end

// Placeholder logic to map application interfaces to AXI
// This needs proper implementation based on protocol requirements.
// For now, just connect basic signals to satisfy connectivity checks.

// --- C0 AXI Mapping (ToeTX and HT) ---
// Assuming ToeTX uses lower addresses/IDs and HT uses higher ones, or interleaved.
// This simple mapping assumes direct pass-through, which is likely incorrect functionally.
// Read Address Channel
assign c0_s_axi_arid    = toeTX_s_axis_read_cmd_tdata[C0_C_S_AXI_ADDR_WIDTH+C0_C_S_AXI_ID_WIDTH-1 -: C0_C_S_AXI_ID_WIDTH]; // Example mapping
assign c0_s_axi_araddr  = toeTX_s_axis_read_cmd_tdata[C0_C_S_AXI_ADDR_WIDTH-1:0]; // Example mapping
assign c0_s_axi_arlen   = toeTX_s_axis_read_cmd_tdata[C0_C_S_AXI_ADDR_WIDTH+C0_C_S_AXI_ID_WIDTH+7:C0_C_S_AXI_ADDR_WIDTH+C0_C_S_AXI_ID_WIDTH]; // Example mapping
assign c0_s_axi_arsize  = 3'd3; // Fixed 64-bit size example
assign c0_s_axi_arburst = 2'b01; // INCR burst example
assign c0_s_axi_arlock  = 1'b0;
assign c0_s_axi_arcache = 4'b0000;
assign c0_s_axi_arprot  = 3'b000;