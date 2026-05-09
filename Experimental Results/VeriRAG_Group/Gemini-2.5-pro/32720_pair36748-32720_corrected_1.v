`timescale 1ns / 1ps
module mem_inf #(
    parameter C0_SIMULATION          =  "FALSE",
    parameter C1_SIMULATION           = "FALSE",
    parameter C0_SIM_BYPASS_INIT_CAL  = "OFF",
    parameter C1_SIM_BYPASS_INIT_CAL = "OFF"
)
(
input               test_i,
input               scan_clk,
// input               clk156_25, // Seems unused based on connections below
// input               reset156_25_n, // Seems unused based on connections below
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
input               sys_rst, // Use this as the primary reset
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

// Application Interface Ports (Grouped for clarity)
// TOE TX Interface (Assumed to connect to MIG 0)
input               toeTX_s_axis_read_cmd_tvalid,
output              toeTX_s_axis_read_cmd_tready,
input[71:0]         toeTX_s_axis_read_cmd_tdata, // Includes Addr, Len etc.
output              toeTX_m_axis_read_sts_tvalid,
input               toeTX_m_axis_read_sts_tready,
output[7:0]         toeTX_m_axis_read_sts_tdata, // Status/Tag
output[63:0]        toeTX_m_axis_read_tdata,  // Matches MIG Data Width? Assuming 512bit MIG -> Needs conversion
output[7:0]         toeTX_m_axis_read_tkeep,  // Matches MIG Data Width?
output              toeTX_m_axis_read_tlast,
output              toeTX_m_axis_read_tvalid,
input               toeTX_m_axis_read_tready,
input               toeTX_s_axis_write_cmd_tvalid,
output              toeTX_s_axis_write_cmd_tready,
input[71:0]         toeTX_s_axis_write_cmd_tdata, // Includes Addr, Len etc.
output              toeTX_m_axis_write_sts_tvalid,
input               toeTX_m_axis_write_sts_tready,
output[7:0]        toeTX_m_axis_write_sts_tdata, // Status/Tag
input[63:0]         toeTX_s_axis_write_tdata, // Matches MIG Data Width? Assuming 512bit MIG -> Needs conversion
input[7:0]          toeTX_s_axis_write_tkeep, // Matches MIG Data Width?
input               toeTX_s_axis_write_tlast,
input               toeTX_s_axis_write_tvalid,
output              toeTX_s_axis_write_tready,

// TOE RX Interface (Assumed to connect to MIG 0)
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

// HT Interface (Assumed to connect to MIG 1)
input               ht_s_axis_read_cmd_tvalid,
output              ht_s_axis_read_cmd_tready,
input[71:0]         ht_s_axis_read_cmd_tdata,
output              ht_m_axis_read_sts_tvalid,
input               ht_m_axis_read_sts_tready,
output[7:0]         ht_m_axis_read_sts_tdata,
output[511:0]       ht_m_axis_read_tdata, // Matches MIG 1 Data Width (512)
output[63:0]        ht_m_axis_read_tkeep, // Matches MIG 1 Data Width (512/8 = 64)
output              ht_m_axis_read_tlast,
output              ht_m_axis_read_tvalid,
input               ht_m_axis_read_tready,
input               ht_s_axis_write_cmd_tvalid,
output              ht_s_axis_write_cmd_tready,
input[71:0]         ht_s_axis_write_cmd_tdata,
output              ht_m_axis_write_sts_tvalid,
input               ht_m_axis_write_sts_tready,
output[7:0]        ht_m_axis_write_sts_tdata,
input[511:0]        ht_s_axis_write_tdata, // Matches MIG 1 Data Width (512)
input[63:0]         ht_s_axis_write_tkeep, // Matches MIG 1 Data Width (512/8 = 64)
input               ht_s_axis_write_tlast,
input               ht_s_axis_write_tvalid,
output              ht_s_axis_write_tready,

// UPD Interface (Assumed to connect to MIG 1)
input               upd_s_axis_read_cmd_tvalid,
output              upd_s_axis_read_cmd_tready,
input[71:0]         upd_s_axis_read_cmd_tdata,
output              upd_m_axis_read_sts_tvalid,
input               upd_m_axis_read_sts_tready,
output[7:0]         upd_m_axis_read_sts_tdata,
output[511:0]       upd_m_axis_read_tdata, // Matches MIG 1 Data Width (512)
output[63:0]        upd_m_axis_read_tkeep, // Matches MIG 1 Data Width (512/8 = 64)
output              upd_m_axis_read_tlast,
output              upd_m_axis_read_tvalid,
input               upd_m_axis_read_tready,
input               upd_s_axis_write_cmd_tvalid,
output              upd_s_axis_write_cmd_tready,
input[71:0]         upd_s_axis_write_cmd_tdata,
output              upd_m_axis_write_sts_tvalid,
input               upd_m_axis_write_sts_tready,
output[7:0]        upd_m_axis_write_sts_tdata,
input[511:0]        upd_s_axis_write_tdata, // Matches MIG 1 Data Width (512)
input[63:0]         upd_s_axis_write_tkeep, // Matches MIG 1 Data Width (512/8 = 64)
input               upd_s_axis_write_tlast,
input               upd_s_axis_write_tvalid,
output              upd_s_axis_write_tready
);

//----------------------------------------------------------------------------
// Local Parameters
//----------------------------------------------------------------------------
localparam C0_C_S_AXI_ID_WIDTH = 1; // Assuming ID width is 1 for MIG 0
localparam C0_C_S_AXI_ADDR_WIDTH = 33;
localparam C0_C_S_AXI_DATA_WIDTH = 512; // Assuming 512-bit data width for MIG 0

localparam C1_C_S_AXI_ID_WIDTH = 1; // Assuming ID width is 1 for MIG 1
localparam C1_C_S_AXI_ADDR_WIDTH = 33;
localparam C1_C_S_AXI_DATA_WIDTH = 512; // Assuming 512-bit data width for MIG 1

//----------------------------------------------------------------------------
// Wires and Registers
//----------------------------------------------------------------------------
wire                                    dft_c0_ui_clk;
wire                                    dft_c1_ui_clk;

wire                                    c0_ui_clk_sync_rst; // MIG 0 Synchronous Reset Output
wire                                    c0_mmcm_locked;
wire                                    c0_aresetn;         // MIG 0 Asynchronous Reset Input

wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_awid;
wire [C0_C_S_AXI_ADDR_WIDTH-1:0]        c0_s_axi_awaddr;
wire [7:0]                              c0_s_axi_awlen;
wire [2:0]                              c0_s_axi_awsize;
wire [1:0]                              c0_s_axi_awburst;
// wire [0:0]                              c0_s_axi_awlock; // Not used in MIG AXI
// wire [3:0]                              c0_s_axi_awcache; // Not used in MIG AXI
// wire [2:0]                              c0_s_axi_awprot; // Not used in MIG AXI
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
// wire [0:0]                              c0_s_axi_arlock; // Not used in MIG AXI
// wire [3:0]                              c0_s_axi_arcache; // Not used in MIG AXI
// wire [2:0]                              c0_s_axi_arprot; // Not used in MIG AXI
wire                                    c0_s_axi_arvalid;
wire                                    c0_s_axi_arready;
wire                                    c0_s_axi_rready;
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_rid;
wire [C0_C_S_AXI_DATA_WIDTH-1:0]        c0_s_axi_rdata;
wire [1:0]                              c0_s_axi_rresp;
wire                                    c0_s_axi_rlast;
wire                                    c0_s_axi_rvalid;

// MIG 0 Control/Status (Unused based on instantiation)
wire                                    c0_app_sr_active;
wire                                    c0_app_ref_ack;
wire                                    c0_app_zq_ack;
wire                                    c0_s_axi_ctrl_awready;
wire                                    c0_s_axi_ctrl_wready;
wire                                    c0_s_axi_ctrl_bvalid;
wire [1:0]                              c0_s_axi_ctrl_bresp;
wire                                    c0_s_axi_ctrl_arready;
wire                                    c0_s_axi_ctrl_rvalid;
wire [31:0]                             c0_s_axi_ctrl_rdata;


wire                                    c1_ui_clk_sync_rst; // MIG 1 Synchronous Reset Output
wire                                    c1_mmcm_locked;
wire                                    c1_aresetn;         // MIG 1 Asynchronous Reset Input

wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_awid;
wire [C1_C_S_AXI_ADDR_WIDTH-1:0]        c1_s_axi_awaddr;
wire [7:0]                              c1_s_axi_awlen;
wire [2:0]                              c1_s_axi_awsize;
wire [1:0]                              c1_s_axi_awburst;
// wire [0:0]                              c1_s_axi_awlock; // Not used in MIG AXI
// wire [3:0]                              c1_s_axi_awcache;// Not used in MIG AXI
// wire [2:0]                              c1_s_axi_awprot; // Not used in MIG AXI
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
// wire [0:0]                              c1_s_axi_arlock; // Not used in MIG AXI
// wire [3:0]                              c1_s_axi_arcache;// Not used in MIG AXI
// wire [2:0]                              c1_s_axi_arprot; // Not used in MIG AXI
wire                                    c1_s_axi_arvalid;
wire                                    c1_s_axi_arready;
wire                                    c1_s_axi_rready;
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_rid;
wire [C1_C_S_AXI_DATA_WIDTH-1:0]        c1_s_axi_rdata;
wire [1:0]                              c1_s_axi_rresp;
wire                                    c1_s_axi_rlast;
wire                                    c1_s_axi_rvalid;

// MIG 1 Control/Status (Unused based on instantiation)
wire                                    c1_app_sr_active;
wire                                    c1_app_ref_ack;
wire                                    c1_app_zq_ack;
wire                                    c1_s_axi_ctrl_awready;
wire                                    c1_s_axi_ctrl_wready;
wire                                    c1_s_axi_ctrl_bvalid;
wire [1:0]                              c1_s_axi