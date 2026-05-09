`timescale 1ns / 1ps
//`timescale 1ns / 1ps // Removed duplicate timescale
module mem_inf #(
    parameter C0_SIMULATION          =  "FALSE",
    parameter C1_SIMULATION           = "FALSE",
    parameter C0_SIM_BYPASS_INIT_CAL  = "OFF",
    parameter C1_SIM_BYPASS_INIT_CAL = "OFF"
)
(
input               test_i, // Added for DFT
input               clk156_25,
input               reset156_25_n, // Assuming this is the primary async reset
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
input               clk_ref_p,
input               clk_ref_n,
input               c1_sys_clk_p,
input               c1_sys_clk_n,
input sys_rst, // Another reset? Using reset156_25_n for MIG sync
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
// AXI Interfaces (assuming these exist based on MIG AXI ports)
// TOE TX Read
input               toeTX_s_axis_read_cmd_tvalid,
output              toeTX_s_axis_read_cmd_tready,
input[71:0]         toeTX_s_axis_read_cmd_tdata, // Contains address, length etc.
output              toeTX_m_axis_read_sts_tvalid,
input               toeTX_m_axis_read_sts_tready,
output[7:0]         toeTX_m_axis_read_sts_tdata,
output[63:0]        toeTX_m_axis_read_tdata,     // Assuming 64-bit data width
output[7:0]         toeTX_m_axis_read_tkeep,
output              toeTX_m_axis_read_tlast,
output              toeTX_m_axis_read_tvalid,
input               toeTX_m_axis_read_tready,
// TOE TX Write
input               toeTX_s_axis_write_cmd_tvalid,
output              toeTX_s_axis_write_cmd_tready,
input[71:0]         toeTX_s_axis_write_cmd_tdata, // Contains address, length etc.
output              toeTX_m_axis_write_sts_tvalid,
input               toeTX_m_axis_write_sts_tready,
output[7:0]        toeTX_m_axis_write_sts_tdata,
input[63:0]         toeTX_s_axis_write_tdata,    // Assuming 64-bit data width
input[7:0]          toeTX_s_axis_write_tkeep,
input               toeTX_s_axis_write_tlast,
input               toeTX_s_axis_write_tvalid,
output              toeTX_s_axis_write_tready,
// TOE RX Read
input               toeRX_s_axis_read_cmd_tvalid,
output              toeRX_s_axis_read_cmd_tready,
input[71:0]         toeRX_s_axis_read_cmd_tdata,
output              toeRX_m_axis_read_sts_tvalid,
input               toeRX_m_axis_read_sts_tready,
output[7:0]         toeRX_m_axis_read_sts_tdata,
output[63:0]        toeRX_m_axis_read_tdata,
output[7:0]         toeRX_m_axis_read_tkeep,
output              toeRX_m_axis_read_tlast,
output              toeRX_m_axis_read_tvalid,
input               toeRX_m_axis_read_tready,
// TOE RX Write
input               toeRX_s_axis_write_cmd_tvalid,
output              toeRX_s_axis_write_cmd_tready,
input[71:0]         toeRX_s_axis_write_cmd_tdata,
output              toeRX_m_axis_write_sts_tvalid,
input               toeRX_m_axis_write_sts_tready,
output[7:0]        toeRX_m_axis_write_sts_tdata,
input[63:0]         toeRX_s_axis_write_tdata,
input[7:0]          toeRX_s_axis_write_tkeep,
input               toeRX_s_axis_write_tlast,
input               toeRX_s_axis_write_tvalid,
output              toeRX_s_axis_write_tready,
// HT Read
input               ht_s_axis_read_cmd_tvalid,
output              ht_s_axis_read_cmd_tready,
input[71:0]         ht_s_axis_read_cmd_tdata,
output              ht_m_axis_read_sts_tvalid,
input               ht_m_axis_read_sts_tready,
output[7:0]         ht_m_axis_read_sts_tdata,
output[511:0]       ht_m_axis_read_tdata,      // Assuming 512-bit data width
output[63:0]        ht_m_axis_read_tkeep,
output              ht_m_axis_read_tlast,
output              ht_m_axis_read_tvalid,
input               ht_m_axis_read_tready,
// HT Write
input               ht_s_axis_write_cmd_tvalid,
output              ht_s_axis_write_cmd_tready,
input[71:0]         ht_s_axis_write_cmd_tdata,
output              ht_m_axis_write_sts_tvalid,
input               ht_m_axis_write_sts_tready,
output[7:0]        ht_m_axis_write_sts_tdata,
input[511:0]        ht_s_axis_write_tdata,     // Assuming 512-bit data width
input[63:0]         ht_s_axis_write_tkeep,
input               ht_s_axis_write_tlast,
input               ht_s_axis_write_tvalid,
output              ht_s_axis_write_tready,
// UPD Read
input               upd_s_axis_read_cmd_tvalid,
output              upd_s_axis_read_cmd_tready,
input[71:0]         upd_s_axis_read_cmd_tdata,
output              upd_m_axis_read_sts_tvalid,
input               upd_m_axis_read_sts_tready,
output[7:0]         upd_m_axis_read_sts_tdata,
output[511:0]       upd_m_axis_read_tdata,     // Assuming 512-bit data width
output[63:0]        upd_m_axis_read_tkeep,
output              upd_m_axis_read_tlast,
output              upd_m_axis_read_tvalid,
input               upd_m_axis_read_tready,
// UPD Write
input               upd_s_axis_write_cmd_tvalid,
output              upd_s_axis_write_cmd_tready,
input[71:0]         upd_s_axis_write_cmd_tdata,
output              upd_m_axis_write_sts_tvalid,
input               upd_m_axis_write_sts_tready,
output[7:0]        upd_m_axis_write_sts_tdata,
input[511:0]        upd_s_axis_write_tdata,    // Assuming 512-bit data width
input[63:0]         upd_s_axis_write_tkeep,
input               upd_s_axis_write_tlast,
input               upd_s_axis_write_tvalid,
output              upd_s_axis_write_tready
);

localparam C0_C_S_AXI_ID_WIDTH = 1; // Assuming ID width based on MIG ports
localparam C0_C_S_AXI_ADDR_WIDTH = 33;
localparam C0_C_S_AXI_DATA_WIDTH = 512; // Assuming data width based on MIG ports
localparam C1_C_S_AXI_ID_WIDTH = 1; // Assuming ID width based on MIG ports
localparam C1_C_S_AXI_ADDR_WIDTH = 33;
localparam C1_C_S_AXI_DATA_WIDTH = 512; // Assuming data width based on MIG ports

// Internal signals
wire                                    c0_ui_clk_sync_rst;
wire                                    c0_mmcm_locked;
reg                                     c0_aresetn_r; // Synchronized reset for MIG C0
wire                                    c1_ui_clk_sync_rst;
wire                                    c1_mmcm_locked;
reg                                     c1_aresetn_r; // Synchronized reset for MIG C1

// MIG C0 AXI signals (wires)
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_awid;
wire [C0_C_S_AXI_ADDR_WIDTH-1:0]        c0_s_axi_awaddr;
wire [7:0]                              c0_s_axi_awlen;
wire [2:0]                              c0_s_axi_awsize;
wire [1:0]                              c0_s_axi_awburst;
wire [0:0]                              c0_s_axi_awlock; // MIG expects 1-bit lock
wire [3:0]                              c0_s_axi_awcache;
wire [2:0]                              c0_s_axi_awprot;
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
wire [0:0]                              c0_s_axi_arlock; // MIG expects 1-bit lock
wire [3:0]                              c0_s_axi_arcache;
wire [2:0]                              c0_s_axi_arprot;
wire                                    c0_s_axi_arvalid;
wire                                    c0_s_axi_arready;
wire                                    c0_s_axi_rready;
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_rid;
wire [C0_C_S_AXI_DATA_WIDTH-1:0]        c0_s_axi_rdata;
wire [1:0]                              c0_s_axi_rresp;
wire                                    c0_s_axi_rlast;
wire                                    c0_s_axi_rvalid;
wire                                    c0_app_sr_active; // Example MIG output
wire                                    c0_app_ref_ack;   // Example MIG output
wire                                    c0_app_zq_ack;    // Example MIG output
wire                                    c0_s_axi_ctrl_awready; // Example MIG output
wire                                    c0_s_axi_ctrl_wready;  // Example MIG output
wire                                    c0_s_axi_ctrl_bvalid;  // Example MIG output
wire [1:0]                              c0_s_axi_ctrl_bresp;   // Example MIG output
wire                                    c0_s_axi_ctrl_arready; // Example MIG output
wire                                    c0_s_axi_ctrl_rvalid;  // Example MIG output
wire [31:0]                             c0_s_axi_ctrl_rdata;   // Example MIG output
wire [1:0]                              c0_s_axi_ctrl_rresp;   // Example MIG output
wire                                    c0_app_ecc_multiple_err; // Example MIG output

// MIG C1 AXI signals (wires)
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_awid;
wire [C1_C_S_AXI_ADDR_WIDTH-1:0]        c1_s_axi_awaddr;
wire [7:0]                              c1_s_axi_awlen;
wire [2:0]                              c1_s_axi_awsize;
wire [1:0]                              c1_s_axi_awburst;
wire [0:0]                              c1_s_axi_awlock; // MIG expects 1-bit lock
wire [3:0]                              c1_s_axi_awcache;
wire [2:0]                              c1_s_axi_awprot;
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
wire [0:0]                              c1_s_axi_arlock; // MIG expects 1-bit lock
wire [3:0]                              c1_s_axi_arcache;
wire [2:0]                              c1_s_axi_arprot;
wire                                    c1_s_axi_arvalid;
wire                                    c1_s_axi_arready;
wire                                    c1_s_axi_rready;
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_rid;
wire [C1_C_S_AXI_DATA_WIDTH-1:0]        c1_s_axi_rdata;
wire [1:0]                              c1_s_axi_rresp;
wire                                    c1_s_axi_rlast;
wire                                    c1_s_axi_rvalid;
wire                                    c1_app_sr_active; // Example MIG output
wire                                    c1_app_ref_ack;   // Example MIG output
wire                                    c1_app_zq_ack;    // Example MIG output
wire                                    c1_s_axi_ctrl_awready; // Example MIG output
wire                                    c1_s_axi_ctrl_wready;  // Example MIG output
wire                                    c1_s_axi_ctrl_bvalid;  // Example MIG output
wire [1:0]                              c1_s_axi_ctrl_bresp;   // Example MIG output
wire                                    c1_s_axi_ctrl_arready; // Example MIG output
wire                                    c1_s_axi_ctrl_rvalid;  // Example MIG output
wire [31:0]                             c1_s_axi_ctrl_rdata;   // Example MIG output
wire [1:0]                              c1_s_axi_ctrl_rresp;   // Example MIG output
wire                                    c1_app_ecc_multiple_err; // Example MIG output

// DFT Clock Muxing
wire                                    dft_c0_ui_clk; // Added for DFT
wire                                    dft_c1_ui_clk; // Added for DFT

assign dft_c0_ui_clk = test_i ? clk156_25 : c0_ui_clk; // Added for DFT - Use primary clock in test mode
assign dft_c1_ui_clk = test_i ? clk156_25 : c1_ui_clk; // Added for DFT - Use primary clock in test mode

// Reset Synchronization using DFT clocks
// Reset synchronizer for c0_ui_clk domain
reg c0_areset_r1, c0_areset_r2;
always @(posedge dft_c0_ui_clk or negedge reset156_25_n) begin // Use DFT clock & primary async reset
  if (!reset156_25_n) begin
    c0_areset_r1 <= 1'b0;
    c0_areset_r2 <= 1'b0;
    c0_aresetn_r <= 1'b0; // Active low reset output
  end else begin
    c0_areset_r1 <= 1'b1;
    c0_areset_r2 <= c0_areset_r1;
    c0_aresetn_r <= c0_areset_r2; // Synchronized active low reset
  end
end

// Reset synchronizer for c1_ui_clk domain
reg c1_areset_r1, c1_areset_r2;
always @(posedge dft_c1_ui_clk or negedge reset156_25_n) begin // Use DFT clock & primary async reset
  if (!reset156_25_n) begin
    c1_areset_r1 <= 1'b0;
    c1_areset_r2 <= 1'b0;
    c1_aresetn_r <= 1'b0; // Active low reset output
  end else begin
    c1_areset_r1 <= 1'b1;
    c1_areset_r2 <= c1_areset_r1;
    c1_aresetn_r <= c1_areset_r2; // Synchronized active low reset
  end
end


//----------------------------------------------------------------------------
// MIG Instantiation
//----------------------------------------------------------------------------
mig_7series_0 u_mig_7series_0 (
  // Controller 0 DDR Ports
  .c0_ddr3_addr                         (c0_ddr3_addr),
  .c0_ddr3_ba                           (c0_ddr3_ba),
  .c0_ddr3_cas_n                        (c0_ddr3_cas_n),
  .c0_ddr3_ck_n                         (c0_ddr3_ck_n),
  .c0_ddr3_ck_p                         (c0_ddr3_ck_p),
  .c0_ddr3_cke                          (c0_ddr3_cke),
  .c0_ddr3_ras_n                        (c0_ddr3_ras_n),
  .c0_ddr3_reset_n                      (c0_ddr3_reset_n),
  .c0_ddr3_we_n                         (c0_ddr3_we_n),
  .c0_ddr3_dq                           (c0_ddr3_dq),
  .c0_ddr3_dqs_n                        (c0_ddr3_dqs_n),
  .c0_ddr3_dqs_p                        (c0_ddr3_dqs_p),
  .c0_init_calib_complete               (c0_init_calib_complete),
  .c0_ddr3_cs_n                         (c0_ddr3_cs_n),
  .c0_ddr3_odt                          (c0_ddr3_odt),

  // Controller 0 Clocking and Reset
  .c0_ui_clk                            (c0_ui_clk),               // MIG Output Clock
  .c0_ui_clk_sync_rst                   (c0_ui_clk_sync_rst),      // MIG Output Synchronous Reset
  .c0_mmcm_locked                       (c0_mmcm_locked),          // MIG Output MMCM Lock Status
  .c0_aresetn                           (c0_aresetn_r),            // MIG Input Synchronized Reset (Active Low)

  // Controller 0 Application Status (Optional)
  .c0_app_sr_req                        (1'b0),                    // MIG Input Self Refresh Req
  .c0_app_ref_req                       (1'