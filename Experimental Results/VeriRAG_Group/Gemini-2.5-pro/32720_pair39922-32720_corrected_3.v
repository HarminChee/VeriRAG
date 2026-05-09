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
input               reset156_25_n, // Primary reset, potentially used for DFT reset control (active low)
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
//--- Application Interface Ports (Example based on names) ---
// These likely connect to an AXI Interconnect or directly map to MIG AXI ports
// Interface 0 (toeTX -> MIG0 Read)
input               toeTX_s_axis_read_cmd_tvalid,
output              toeTX_s_axis_read_cmd_tready, // Connect to MIG0 AXI ARREADY
input[71:0]         toeTX_s_axis_read_cmd_tdata,  // Map to MIG0 AXI ARADDR etc.
output              toeTX_m_axis_read_sts_tvalid, // Connect to MIG0 AXI RVALID
input               toeTX_m_axis_read_sts_tready, // Connect to MIG0 AXI RREADY
output[7:0]         toeTX_m_axis_read_sts_tdata,  // Map from MIG0 AXI RRESP etc.
output[63:0]        toeTX_m_axis_read_tdata,      // Connect to MIG0 AXI RDATA (lower 64b)
output[7:0]         toeTX_m_axis_read_tkeep,      // Derived from MIG0 AXI RDATA size/resp?
output              toeTX_m_axis_read_tlast,      // Connect to MIG0 AXI RLAST
output              toeTX_m_axis_read_tvalid,     // Connect to MIG0 AXI RVALID
input               toeTX_m_axis_read_tready,     // Connect to MIG0 AXI RREADY
// Interface 1 (toeTX -> MIG0 Write)
input               toeTX_s_axis_write_cmd_tvalid,
output              toeTX_s_axis_write_cmd_tready,// Connect to MIG0 AXI AWREADY
input[71:0]         toeTX_s_axis_write_cmd_tdata, // Map to MIG0 AXI AWADDR etc.
output              toeTX_m_axis_write_sts_tvalid,// Connect to MIG0 AXI BVALID
input               toeTX_m_axis_write_sts_tready,// Connect to MIG0 AXI BREADY
output[7:0]        toeTX_m_axis_write_sts_tdata, // Map from MIG0 AXI BRESP etc.
input[63:0]         toeTX_s_axis_write_tdata,     // Connect to MIG0 AXI WDATA (lower 64b)
input[7:0]          toeTX_s_axis_write_tkeep,     // Connect to MIG0 AXI WSTRB
input               toeTX_s_axis_write_tlast,     // Connect to MIG0 AXI WLAST
input               toeTX_s_axis_write_tvalid,    // Connect to MIG0 AXI WVALID
output              toeTX_s_axis_write_tready,    // Connect to MIG0 AXI WREADY
// Interface 2 (toeRX -> MIG0 Read) - Assuming similar mapping as toeTX
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
// Interface 3 (toeRX -> MIG0 Write) - Assuming similar mapping as toeTX
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
// Interface 4 (ht -> MIG1 Read) - Wider data path
input               ht_s_axis_read_cmd_tvalid,
output              ht_s_axis_read_cmd_tready,   // Connect to MIG1 AXI ARREADY
input[71:0]         ht_s_axis_read_cmd_tdata,    // Map to MIG1 AXI ARADDR etc.
output              ht_m_axis_read_sts_tvalid,   // Connect to MIG1 AXI RVALID
input               ht_m_axis_read_sts_tready,   // Connect to MIG1 AXI RREADY
output[7:0]         ht_m_axis_read_sts_tdata,    // Map from MIG1 AXI RRESP etc.
output[511:0]       ht_m_axis_read_tdata,        // Connect to MIG1 AXI RDATA
output[63:0]        ht_m_axis_read_tkeep,        // Derived from MIG1 AXI RDATA size/resp?
output              ht_m_axis_read_tlast,        // Connect to MIG1 AXI RLAST
output              ht_m_axis_read_tvalid,       // Connect to MIG1 AXI RVALID
input               ht_m_axis_read_tready,       // Connect to MIG1 AXI RREADY
// Interface 5 (ht -> MIG1 Write) - Wider data path
input               ht_s_axis_write_cmd_tvalid,
output              ht_s_axis_write_cmd_tready,  // Connect to MIG1 AXI AWREADY
input[71:0]         ht_s_axis_write_cmd_tdata,   // Map to MIG1 AXI AWADDR etc.
output              ht_m_axis_write_sts_tvalid,  // Connect to MIG1 AXI BVALID
input               ht_m_axis_write_sts_tready,  // Connect to MIG1 AXI BREADY
output[7:0]        ht_m_axis_write_sts_tdata,   // Map from MIG1 AXI BRESP etc.
input[511:0]        ht_s_axis_write_tdata,       // Connect to MIG1 AXI WDATA
input[63:0]         ht_s_axis_write_tkeep,       // Connect to MIG1 AXI WSTRB
input               ht_s_axis_write_tlast,       // Connect to MIG1 AXI WLAST
input               ht_s_axis_write_tvalid,      // Connect to MIG1 AXI WVALID
output              ht_s_axis_write_tready,      // Connect to MIG1 AXI WREADY
// Interface 6 (upd -> MIG1 Read) - Wider data path
input               upd_s_axis_read_cmd_tvalid,
output              upd_s_axis_read_cmd_tready,  // Connect to MIG1 AXI ARREADY
input[71:0]         upd_s_axis_read_cmd_tdata,   // Map to MIG1 AXI ARADDR etc.
output              upd_m_axis_read_sts_tvalid,  // Connect to MIG1 AXI RVALID
input               upd_m_axis_read_sts_tready,  // Connect to MIG1 AXI RREADY
output[7:0]         upd_m_axis_read_sts_tdata,   // Map from MIG1 AXI RRESP etc.
output[511:0]       upd_m_axis_read_tdata,       // Connect to MIG1 AXI RDATA
output[63:0]        upd_m_axis_read_tkeep,       // Derived from MIG1 AXI RDATA size/resp?
output              upd_m_axis_read_tlast,       // Connect to MIG1 AXI RLAST
output              upd_m_axis_read_tvalid,      // Connect to MIG1 AXI RVALID
input               upd_m_axis_read_tready,      // Connect to MIG1 AXI RREADY
// Interface 7 (upd -> MIG1 Write) - Wider data path
input               upd_s_axis_write_cmd_tvalid,
output              upd_s_axis_write_cmd_tready, // Connect to MIG1 AXI AWREADY
input[71:0]         upd_s_axis_write_cmd_tdata,  // Map to MIG1 AXI AWADDR etc.
output              upd_m_axis_write_sts_tvalid, // Connect to MIG1 AXI BVALID
input               upd_m_axis_write_sts_tready, // Connect to MIG1 AXI BREADY
output[7:0]        upd_m_axis_write_sts_tdata,  // Map from MIG1 AXI BRESP etc.
input[511:0]        upd_s_axis_write_tdata,      // Connect to MIG1 AXI WDATA
input[63:0]         upd_s_axis_write_tkeep,      // Connect to MIG1 AXI WSTRB
input               upd_s_axis_write_tlast,      // Connect to MIG1 AXI WLAST
input               upd_s_axis_write_tvalid,     // Connect to MIG1 AXI WVALID
output              upd_s_axis_write_tready      // Connect to MIG1 AXI WREADY
);

localparam C0_C_S_AXI_ID_WIDTH = 1; // Example width, adjust as needed
localparam C0_C_S_AXI_ADDR_WIDTH = 33; // Matches MIG parameter if available
localparam C0_C_S_AXI_DATA_WIDTH = 512; // Matches MIG parameter if available
localparam C1_C_S_AXI_ID_WIDTH = 1; // Example width, adjust as needed
localparam C1_C_S_AXI_ADDR_WIDTH = 33; // Matches MIG parameter if available
localparam C1_C_S_AXI_DATA_WIDTH = 512; // Matches MIG parameter if available

// Internal signals for MIG outputs
wire                                    c0_ui_clk_int;
wire                                    c1_ui_clk_int;
wire                                    c0_mmcm_locked; // Assuming MIG provides this
wire                                    c1_mmcm_locked; // Assuming MIG provides this

// DFT Logic: Clock Muxing for registers clocked by generated clocks
wire c0_clk_dft;
assign c0_clk_dft = test_i ? test_clk : c0_ui_clk_int; // Select test_clk in test mode for c0 domain

wire c1_clk_dft;
assign c1_clk_dft = test_i ? test_clk : c1_ui_clk_int; // Select test_clk in test mode for c1 domain

// DFT Logic: Reset Control & Synchronization
wire c0_async_reset_n;
assign c0_async_reset_n = test_i ? reset156_25_n : ~sys_rst; // Select reset source (active low)

wire c1_async_reset_n;
assign c1_async_reset_n = test_i ? reset156_25_n : ~sys_rst; // Select reset source (active low)

// c0 Reset Synchronizer
reg                                     c0_aresetn_r; // Register holding synchronized reset for c0 (active low)
reg                                     c0_rst_sync1_r; // Reset synchronizer stage 1
reg                                     c0_rst_sync2_r; // Reset synchronizer stage 2
always @(posedge c0_clk_dft or negedge c0_async_reset_n) begin
    if (!c0_async_reset_n) begin // Asynchronous reset active (either functional or DFT)
        c0_rst_sync1_r <= 1'b0;
        c0_rst_sync2_r <= 1'b0;
    end else begin // Clocked operation - sync the deassertion
        c0_rst_sync1_r <= 1'b1; // Syncing the 'not reset' state
        c0_rst_sync2_r <= c0_rst_sync1_r;
    end
end
assign c0_aresetn_r = c0_rst_sync2_r; // Output synchronized active-low reset
wire c0_ui_clk_sync_rst = ~c0_aresetn_r; // Active high version for MIG AXI interface

// c1 Reset Synchronizer
reg                                     c1_aresetn_r; // Register holding synchronized reset for c1 (active low)
reg                                     c1_rst_sync1_r; // Reset synchronizer stage 1
reg                                     c1_rst_sync2_r; // Reset synchronizer stage 2
always @(posedge c1_clk_dft or negedge c1_async_reset_n) begin
    if (!c1_async_reset_n) begin // Asynchronous reset active (either functional or DFT)
        c1_rst_sync1_r <= 1'b0;
        c1_rst_sync2_r <= 1'b0;
    end else begin // Clocked operation - sync the deassertion
        c1_rst_sync1_r <= 1'b1; // Syncing the 'not reset' state
        c1_rst_sync2_r <= c1_rst_sync1_r;
    end
end
assign c1_aresetn_r = c1_rst_sync2_r; // Output synchronized active-low reset
wire c1_ui_clk_sync_rst = ~c1_aresetn_r; // Active high version for MIG AXI interface

// --- AXI signals connecting TO the MIG cores ---
// These signals would typically be driven by an AXI Interconnect or master logic
// For MIG 0
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_awid;
wire [C0_C_S_AXI_ADDR_WIDTH-1:0]        c0_s_axi_awaddr;
wire [7:0]                              c0_s_axi_awlen;
wire [2:0]                              c0_s_axi_awsize;
wire [1:0]                              c0_s_axi_awburst;
wire [0:0]                              c0_s_axi_awlock;
wire [3:0]                              c0_s_axi_awcache;
wire [2:0]                              c0_s_axi_awprot;
wire                                    c0_s_axi_awqos = 4'b0; // Example, connect if needed
wire                                    c0_s_axi_awregion = 4'b0; // Example, connect if needed
wire                                    c0_s_axi_awvalid;
wire                                    c0_s_axi_awready; // From MIG 0
wire [C0_C_S_AXI_DATA_WIDTH-1:0]        c0_s_axi_wdata;
wire [(C0_C_S_AXI_DATA_WIDTH/8)-1:0]    c0_s_axi_wstrb;
wire                                    c0_s_axi_wlast;
wire                                    c0_s_axi_wvalid;
wire                                    c0_s_axi_wready; // From MIG 0
wire                                    c0_s_axi_bready;
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_bid; // From MIG 0
wire [1:0]                              c0_s_axi_bresp; // From MIG 0
wire                                    c0_s_axi_bvalid; // From MIG 0
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_arid;
wire [C0_C_S_AXI_ADDR_WIDTH-1:0]        c0_s_axi_araddr;
wire [7:0]                              c0_s_axi_arlen;
wire [2:0]                              c0_s_axi_arsize;
wire [1:0]                              c0_s_axi_arburst;
wire [0:0]                              c0_s_axi_arlock;
wire [3:0]                              c0_s_axi_arcache;
wire [2:0]                              c0_s_axi_arprot;
wire                                    c0_s_axi_arqos = 4'b0; // Example, connect if needed
wire                                    c0_s_axi_arregion = 4'b0; // Example, connect if needed
wire                                    c0_s_axi_arvalid;
wire                                    c0_s_axi_arready; // From MIG 0
wire                                    c0_s_axi_rready;
wire [C0_C_S_AXI_ID_WIDTH-1:0]          c0_s_axi_rid; // From MIG 0
wire [C0_C_S_AXI_DATA_WIDTH-1:0]        c0_s_axi_rdata; // From MIG 0
wire [1:0]                              c0_s_axi_rresp; // From MIG 0
wire                                    c0_s_axi_rlast; // From MIG 0
wire                                    c0_s_axi_rvalid; // From MIG 0

// For MIG 1
wire [C1_C_S_AXI_ID_WIDTH-1:0]          c1_s_axi_awid;
wire [C1_C_S_AXI_ADDR_WIDTH-1:0]        c1_s_axi_awaddr;
wire [7:0]                              c1_s_axi_awlen;
wire [2:0]                              c1_s_axi_awsize;
wire [1:0]                              c1_s_axi_awburst;
wire [0:0]                              c1_s_axi_awlock;
wire [3:0]                              c1_s_axi_awcache;
wire [2:0]                              c1_s_axi_awprot;
wire                                    c1_s_axi_awqos = 4'b0; // Example, connect if needed
wire                                    c1_s_axi_awregion = 4'b0; // Example, connect if needed
wire                                    c1_s_axi_awvalid;
wire                                    c1