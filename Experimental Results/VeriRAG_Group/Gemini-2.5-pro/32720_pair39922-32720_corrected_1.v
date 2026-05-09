`timescale 1ns / 1ps
`timescale 1ns / 1ps
module mem_inf #(
    parameter C0_SIMULATION          =  "FALSE",
    parameter C1_SIMULATION           = "FALSE",
    parameter C0_SIM_BYPASS_INIT_CAL  = "OFF",
    parameter C1_SIM_BYPASS_INIT_CAL = "OFF"
)
(
input               test_i, // DFT test mode enable
input               scan_en, // DFT scan enable (often used for mux control)
input               test_clk, // DFT test clock
input               clk156_25,
input               reset156_25_n, // Primary reset, potentially used for DFT reset control
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
output              c0_ui_clk, // Generated clock from MIG 0
output              c0_init_calib_complete,
input               c0_sys_clk_p,
input               c0_sys_clk_n,
input               clk_ref_p,
input               clk_ref_n,
input               c1_sys_clk_p,
input               c1_sys_clk_n,
input sys_rst, // Primary system reset (active high assumed based on synchronizer logic)
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
output              c1_ui_clk, // Generated clock from MIG 1
output              c1_init_calib_complete,
input               toeTX_s_axis_read_cmd_tvalid,
output              toeTX_s_axis_read_cmd_tready,
input[71:0]         toeTX_s_axis_read_cmd_tdata,
output              toeTX_m_axis_read_sts_tvalid,
input               toeTX_m_axis_read_sts_tready,
output[7:0]         toeTX_m_axis_read_sts_tdata,
output[63:0]        toeTX_m_axis_read_tdata,
output[7:0]         toeTX_m_axis_read_tkeep,
output              toeTX_m_axis_read_tlast,
output              toeTX_m_axis_read_tvalid,
input               toeTX_m_axis_read_tready,
input               toeTX_s_axis_write_cmd_tvalid,
output              toeTX_s_axis_write_cmd_tready,
input[71:0]         toeTX_s_axis_write_cmd_tdata,
output              toeTX_m_axis_write_sts_tvalid,
input               toeTX_m_axis_write_sts_tready,
output[7:0]        toeTX_m_axis_write_sts_tdata,
input[63:0]         toeTX_s_axis_write_tdata,
input[7:0]          toeTX_s_axis_write_tkeep,
input               toeTX_s_axis_write_tlast,
input               toeTX_s_axis_write_tvalid,
output              toeTX_s_axis_write_tready,
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
input               ht_s_axis_read_cmd_tvalid,
output              ht_s_axis_read_cmd_tready,
input[71:0]         ht_s_axis_read_cmd_tdata,
output              ht_m_axis_read_sts_tvalid,
input               ht_m_axis_read_sts_tready,
output[7:0]         ht_m_axis_read_sts_tdata,
output[511:0]       ht_m_axis_read_tdata,
output[63:0]        ht_m_axis_read_tkeep,
output              ht_m_axis_read_tlast,
output              ht_m_axis_read_tvalid,
input               ht_m_axis_read_tready,
input               ht_s_axis_write_cmd_tvalid,
output              ht_s_axis_write_cmd_tready,
input[71:0]         ht_s_axis_write_cmd_tdata,
output              ht_m_axis_write_sts_tvalid,
input               ht_m_axis_write_sts_tready,
output[7:0]        ht_m_axis_write_sts_tdata,
input[511:0]        ht_s_axis_write_tdata,
input[63:0]         ht_s_axis_write_tkeep,
input               ht_s_axis_write_tlast,
input               ht_s_axis_write_tvalid,
output              ht_s_axis_write_tready,
input               upd_s_axis_read_cmd_tvalid,
output              upd_s_axis_read_cmd_tready,
input[71:0]         upd_s_axis_read_cmd_tdata,
output              upd_m_axis_read_sts_tvalid,
input               upd_m_axis_read_sts_tready,
output[7:0]         upd_m_axis_read_sts_tdata,
output[511:0]       upd_m_axis_read_tdata,
output[63:0]        upd_m_axis_read_tkeep,
output              upd_m_axis_read_tlast,
output              upd_m_axis_read_tvalid,
input               upd_m_axis_read_tready,
input               upd_s_axis_write_cmd_tvalid,
output              upd_s_axis_write_cmd_tready,
input[71:0]         upd_s_axis_write_cmd_tdata,
output              upd_m_axis_write_sts_tvalid,
input               upd_m_axis_write_sts_tready,
output[7:0]        upd_m_axis_write_sts_tdata,
input[511:0]        upd_s_axis_write_tdata,
input[63:0]         upd_s_axis_write_tkeep,
input               upd_s_axis_write_tlast,
input               upd_s_axis_write_tvalid,
output              upd_s_axis_write_tready);

localparam C0_C_S_AXI_ID_WIDTH = 1;
localparam C0_C_S_AXI_ADDR_WIDTH = 33;
localparam C0_C_S_AXI_DATA_WIDTH = 512;
localparam C1_C_S_AXI_ID_WIDTH = 1;
localparam C1_C_S_AXI_ADDR_WIDTH = 33;
localparam C1_C_S_AXI_DATA_WIDTH = 512;

wire                                    c0_ui_clk_sync_rst; // Reset synchronized to c0_ui_clk domain
wire                                    c0_mmcm_locked;
reg                                     c0_aresetn_r; // Register holding synchronized reset for c0
reg                                     c0_rst_sync1_r; // Reset synchronizer stage 1
reg                                     c0_rst_sync2_r; // Reset synchronizer stage 2
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_awid;
wire [C0_C_S_AXI_ADDR_WIDTH-1:0]        c0_s_axi_awaddr;
wire [7:0]                              c0_s_axi_awlen;
wire [2:0]                              c0_s_axi_awsize;
wire [1:0]                              c0_s_axi_awburst;
wire [0:0]                              c0_s_axi_awlock;
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
wire [0:0]                              c0_s_axi_arlock;
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

wire                                    c1_ui_clk_sync_rst; // Reset synchronized to c1_ui_clk domain
wire                                    c1_mmcm_locked;
reg                                     c1_aresetn_r; // Register holding synchronized reset for c1
reg                                     c1_rst_sync1_r; // Reset synchronizer stage 1
reg                                     c1_rst_sync2_r; // Reset synchronizer stage 2
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_awid;
wire [C1_C_S_AXI_ADDR_WIDTH-1:0]        c1_s_axi_awaddr;
wire [7:0]                              c1_s_axi_awlen;
wire [2:0]                              c1_s_axi_awsize;
wire [1:0]                              c1_s_axi_awburst;
wire [0:0]                              c1_s_axi_awlock;
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
wire [2:0]                              c1_s_axi_arsize; // Corrected truncated line
wire [1:0]                              c1_s_axi_arburst;
wire [0:0]                              c1_s_axi_arlock;
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

// DFT Logic: Clock Muxing for registers clocked by generated clocks
wire c0_clk_dft;
assign c0_clk_dft = test_i ? test_clk : c0_ui_clk; // Select test_clk in test mode for c0 domain

wire c1_clk_dft;
assign c1_clk_dft = test_i ? test_clk : c1_ui_clk; // Select test_clk in test mode for c1 domain

// DFT Logic: Reset Control
// Use primary input reset156_25_n (active low) for DFT reset control
// Use primary input sys_rst (active high) for functional reset
wire c0_reset_dft_n; // Active low reset signal for c0 synchronizer block
assign c0_reset_dft_n = test_i ? reset156