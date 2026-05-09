`timescale 1ns / 1ps
module mem_inf #(
    parameter C0_SIMULATION          =  "FALSE",
    parameter C1_SIMULATION           = "FALSE",
    parameter C0_SIM_BYPASS_INIT_CAL  = "OFF",
    parameter C1_SIM_BYPASS_INIT_CAL = "OFF",
    // AXI Parameters (Example - Adjust based on actual MIG configuration)
    parameter C0_AXI_ID_WIDTH        = 4,
    parameter C0_AXI_ADDR_WIDTH      = 32,
    parameter C0_AXI_DATA_WIDTH      = 64,
    parameter C1_AXI_ID_WIDTH        = 4,
    parameter C1_AXI_ADDR_WIDTH      = 32,
    parameter C1_AXI_DATA_WIDTH      = 64
)
(
    // Clocks and Resets
    input               clk156_25, // Reference clock for DFT muxing
    input               reset156_25_n, // Not used directly in reset sync, sys_rst is used
    input               c0_sys_clk_p,
    input               c0_sys_clk_n,
    input               clk_ref_p,      // MIG Reference Clock
    input               clk_ref_n,      // MIG Reference Clock
    input               c1_sys_clk_p,
    input               c1_sys_clk_n,
    input               sys_rst,        // Primary System Reset (Active High)
    input               test_mode,      // DFT Test Mode enable

    // DDR3 Interface Controller 0
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

    // DDR3 Interface Controller 1
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
    input               toeTX_s_axis_read_cmd_tvalid, // -> c0_s_axi_arvalid
    output              toeTX_s_axis_read_cmd_tready, // <- c0_s_axi_arready
    input[71:0]         toeTX_s_axis_read_cmd_tdata,  // -> c0_s_axi_araddr, arlen, etc. (Requires mapping logic)
    output              toeTX_m_axis_read_sts_tvalid, // <- c0_s_axi_rvalid (partially)
    input               toeTX_m_axis_read_sts_tready, // -> c0_s_axi_rready
    output[7:0]         toeTX_m_axis_read_sts_tdata,  // <- c0_s_axi_rresp, rid (Requires mapping logic)
    output[63:0]        toeTX_m_axis_read_tdata,      // <- c0_s_axi_rdata
    output[7:0]         toeTX_m_axis_read_tkeep,      // <- Derived from c0_s_axi_rdata size/alignment (Requires mapping logic)
    output              toeTX_m_axis_read_tlast,      // <- c0_s_axi_rlast
    output              toeTX_m_axis_read_tvalid,     // <- c0_s_axi_rvalid
    input               toeTX_m_axis_read_tready,     // -> c0_s_axi_rready (Duplicated?)

    input               toeTX_s_axis_write_cmd_tvalid, // -> c0_s_axi_awvalid
    output              toeTX_s_axis_write_cmd_tready,// <- c0_s_axi_awready
    input[71:0]         toeTX_s_axis_write_cmd_tdata, // -> c0_s_axi_awaddr, awlen, etc. (Requires mapping logic)
    output              toeTX_m_axis_write_sts_tvalid,// <- c0_s_axi_bvalid
    input               toeTX_m_axis_write_sts_tready,// -> c0_s_axi_bready
    output[7:0]         toeTX_m_axis_write_sts_tdata, // <- c0_s_axi_bresp, bid (Requires mapping logic)
    input[63:0]         toeTX_s_axis_write_tdata,     // -> c0_s_axi_wdata
    input[7:0]          toeTX_s_axis_write_tkeep,     // -> c0_s_axi_wstrb (Requires mapping logic, assuming 8 bytes)
    input               toeTX_s_axis_write_tlast,     // -> c0_s_axi_wlast
    input               toeTX_s_axis_write_tvalid,    // -> c0_s_axi_wvalid
    output              toeTX_s_axis_write_tready,    // <- c0_s_axi_wready

    // ToeRX Interface (Example mapping to c1_s_axi)
    input               toeRX_s_axis_read_cmd_tvalid, // -> c1_s_axi_arvalid
    output              toeRX_s_axis_read_cmd_tready, // <- c1_s_axi_arready
    input[71:0]         toeRX_s_axis_read_cmd_tdata,  // -> c1_s_axi_araddr, arlen, etc. (Requires mapping logic)
    output              toeRX_m_axis_read_sts_tvalid, // <- c1_s_axi_rvalid (partially)
    input               toeRX_m_axis_read_sts_tready, // -> c1_s_axi_rready
    output[7:0]         toeRX_m_axis_read_sts_tdata,  // <- c1_s_axi_rresp, rid (Requires mapping logic)
    output[63:0]        toeRX_m_axis_read_tdata,      // <- c1_s_axi_rdata
    output[7:0]         toeRX_m_axis_read_tkeep,      // <- Derived from c1_s_axi_rdata size/alignment (Requires mapping logic)
    output              toeRX_m_axis_read_tlast,      // <- c1_s_axi_rlast
    output              toeRX_m_axis_read_tvalid,     // <- c1_s_axi_rvalid
    input               toeRX_m_axis_read_tready,     // -> c1_s_axi_rready (Duplicated?)

    input               toeRX_s_axis_write_cmd_tvalid, // -> c1_s_axi_awvalid
    output              toeRX_s_axis_write_cmd_tready,// <- c1_s_axi_awready
    input[71:0]         toeRX_s_axis_write_cmd_tdata, // -> c1_s_axi_awaddr, awlen, etc. (Requires mapping logic)
    output              toeRX_m_axis_write_sts_tvalid,// <- c1_s_axi_bvalid
    input               toeRX_m_axis_write_sts_tready,// -> c1_s_axi_bready
    output[7:0]         toeRX_m_axis_write_sts_tdata, // <- c1_s_axi_bresp, bid (Requires mapping logic)
    input[63:0]         toeRX_s_axis_write_tdata,     // -> c1_s_axi_wdata
    input[7:0]          toeRX_s_axis_write_tkeep,     // -> c1_s_axi_wstrb (Requires mapping logic, assuming 8 bytes)
    input               toeRX_s_axis_write_tlast,     // -> c1_s_axi_wlast
    input               toeRX_s_axis_write_tvalid,    // -> c1_s_axi_wvalid
    output              toeRX_s_axis_write_tready     // <- c1_s_axi_wready
);

    // Internal Wires
    wire                c0_sys_clk;
    wire                c1_sys_clk;
    wire                clk_ref;
    wire                c0_ui_clk_sync_rst; // MIG generated reset synced to ui_clk
    wire                c1_ui_clk_sync_rst; // MIG generated reset synced to ui_clk
    wire                dft_c0_ui_clk;      // DFT muxed clock for C0 logic
    wire                dft_c1_ui_clk;      // DFT muxed clock for C1 logic

    // AXI Interface Wires (Example for 64-bit data width)
    // MIG 0 AXI Interface
    wire [C0_AXI_ID_WIDTH-1:0]     c0_s_axi_awid;
    wire [C0_AXI_ADDR_WIDTH-1:0]   c0_s_axi_awaddr;
    wire [7:0]                     c0_s_axi_awlen;
    wire [2:0]                     c0_s_axi_awsize;
    wire [1:0]                     c0_s_axi_awburst;
    wire                           c0_s_axi_awlock;
    wire [3:0]                     c0_s_axi_awcache;
    wire [2:0]                     c0_s_axi_awprot;
    wire                           c0_s_axi_awqos; // Added based on typical AXI ports
    wire                           c0_s_axi_awregion; // Added based on typical AXI ports
    wire                           c0_s_axi_awvalid;
    wire                           c0_s_axi_awready;
    wire [C0_AXI_DATA_WIDTH-1:0]   c0_s_axi_wdata;
    wire [C0_AXI_DATA_WIDTH/8-1:0] c0_s_axi_wstrb;
    wire                           c0_s_axi_wlast;
    wire                           c0_s_axi_wvalid;
    wire                           c0_s_axi_wready;
    wire [C0_AXI_ID_WIDTH-1:0]     c0_s_axi_bid;
    wire [1:0]                     c0_s_axi_bresp;
    wire                           c0_s_axi_bvalid;
    wire                           c0_s_axi_bready;
    wire [C0_AXI_ID_WIDTH-1:0]     c0_s_axi_arid;
    wire [C0_AXI_ADDR_WIDTH-1:0]   c0_s_axi_araddr;
    wire [7:0]                     c0_s_axi_arlen;
    wire [2:0]                     c0_s_axi_arsize;
    wire [1:0]                     c0_s_axi_arburst;
    wire                           c0_s_axi_arlock;
    wire [3:0]                     c0_s_axi_arcache;
    wire [2:0]                     c0_s_axi_arprot;
    wire                           c0_s_axi_arqos; // Added based on typical AXI ports
    wire                           c0_s_axi_arregion; // Added based on typical AXI ports
    wire                           c0_s_axi_arvalid;
    wire                           c0_s_axi_arready;
    wire [C0_AXI_ID_WIDTH-1:0]     c0_s_axi_rid;
    wire [C0_AXI_DATA_WIDTH-1:0]   c0_s_axi_rdata;
    wire [1:0]                     c0_s_axi_rresp;
    wire                           c0_s_axi_rlast;
    wire                           c0_s_axi_rvalid;
    wire                           c0_s_axi_rready;

    // MIG 1 AXI Interface
    wire [C1_AXI_ID_WIDTH-1:0]     c1_s_axi_awid;
    wire [C1_AXI_ADDR_WIDTH-1:0]   c1_s_axi_awaddr;
    wire [7:0]                     c1_s_axi_awlen;
    wire [2:0]                     c1_s_axi_awsize;
    wire [1:0]                     c1_s_axi_awburst;
    wire                           c1_s_axi_awlock;
    wire [3:0]                     c1_s_axi_awcache;
    wire [2:0]                     c1_s_axi_awprot;
    wire                           c1_s_axi_awqos; // Added based on typical AXI ports
    wire                           c1_s_axi_awregion; // Added based on typical AXI ports
    wire                           c1_s_axi_awvalid;
    wire                           c1_s_axi_awready;
    wire [C1_AXI_DATA_WIDTH-1:0]   c1_s_axi_wdata;
    wire [C1_AXI_DATA_WIDTH/8-1:0] c1_s_axi_wstrb;
    wire                           c1_s_axi_wlast;
    wire                           c1_s_axi_wvalid;
    wire                           c1_s_axi_wready;
    wire [C1_AXI_ID_WIDTH-1:0]     c1_s_axi_bid;
    wire [1:0]                     c1_s_axi_bresp;
    wire                           c1_s_axi_bvalid;
    wire                           c1_s_axi_bready;
    wire [C1_AXI_ID_WIDTH-1:0]     c1_s_axi_arid;
    wire [C1_AXI_ADDR_WIDTH-1:0]   c1_s_axi_araddr;
    wire [7:0]                     c1_s_axi_arlen;
    wire [2:0]                     c1_s_axi_arsize;
    wire [1:0]                     c1_s_axi_arburst;
    wire                           c1_s_axi_arlock;
    wire [3:0]                     c1_s_axi_arcache;
    wire [2:0]                     c1_s_axi_arprot;
    wire                           c1_s_axi_arqos; // Added based on typical AXI ports
    wire                           c1_s_axi_arregion; // Added based on typical AXI ports
    wire                           c1_s_axi_arvalid;
    wire                           c1_s_axi_arready;
    wire [C1_AXI_ID_WIDTH-1:0]     c1_s_axi_rid;
    wire [C1_AXI_DATA_WIDTH-1:0]   c1_s_axi_rdata;
    wire [1:0]                     c1_s_axi_rresp;
    wire                           c1_s_axi_rlast;
    wire                           c1_s_axi_rvalid;
    wire                           c1_s_axi_rready;

    // Clock Input Buffers
    IBUFGDS c0_sys_clk_ibufgds (
        .I  (c0_sys_clk_p),
        .IB (c0_sys_clk_n),
        .O  (c0_sys_clk)
    );

    IBUFGDS c1_sys_clk_ibufgds (
        .I  (c1_sys_clk_p),
        .IB (c1_sys_clk_n),
        .O  (c1_sys_clk)
    );

     IBUFGDS clk_ref_ibufgds (
        .I  (clk_ref_p),
        .IB (clk_ref_n),
        .O  (clk_ref)
    );

    // DFT Clock Muxing: Select primary test clock in test_mode
    // Use clk156_25 as the test clock source. Ensure it's routed appropriately.
    assign dft_c0_ui_clk = test_mode ? clk156_25 : c0_ui_clk;
    assign dft_c1_ui_clk = test_mode ? clk156_25 : c1_ui_clk;

    // MIG 7 Series Instance 0
    // Placeholder - Replace with actual MIG instantiation from Vivado IP Generator
    // Ensure module name 'mig_7series_0_0' and parameters match the generated IP
    mig_7series_0_0 #(
        .C_SIMULATION           (C0_SIMULATION),
        .C_SIM_BYPASS_INIT_CAL  (C0_SIM_BYPASS_INIT_CAL),
        .C_S_AXI_ID_WIDTH       (C0_AXI_ID_WIDTH),
        .C_S_AXI_ADDR_WIDTH     (C0_AXI_ADDR_WIDTH),
        .C_S_AXI_DATA_WIDTH     (C0_AXI_DATA_WIDTH)
        // Add other necessary MIG parameters here if needed
    )
    mig_inst_0 (
        // DDR3 Interface
        .ddr3_dq            (c0_ddr3_dq),
        .ddr3_dqs_n         (c0_ddr3_dqs_n),
        .ddr3_dqs_p         (c0_ddr3_dqs_p),
        .ddr3_addr          (c0_ddr3_addr),
        .ddr3_ba            (c0_ddr3_ba),
        .ddr3_ras_n         (c0_ddr3_ras_n),
        .ddr3_cas_n         (c0_ddr3_cas_n),
        .ddr3_we_n          (c0_ddr3_we_n),
        .ddr3_reset_n       (c0_ddr3_reset_n),
        .ddr3_ck_p          (c0_ddr3_ck_p),
        .ddr3_ck_n          (c0_ddr3_ck_n),
        .ddr3_cke           (c0_ddr3_cke),
        .ddr3_cs_n          (c0_ddr3_cs_n),
        .ddr3_odt           (c0_ddr3_odt),

        // Clocking
        .sys_clk_i          (c0_sys_clk),   // MIG system clock input
        .clk_ref_i          (clk_ref),      // Reference clock input
        .ui_clk             (c0_ui_clk),    // User Interface clock output
        .ui_clk_sync_rst    (c0_ui_clk_sync_rst), // Reset synchronous to ui_clk
        .init_calib_complete(c0_init_calib_complete),

        // System Reset - Use the primary reset directly
        .sys_rst            (sys_rst),      // System reset input (Active High)

        // AXI4 Slave Interface (Ensure port names match MIG IP)
        .s_axi_awid         (c0_s_axi_awid),
        .s_axi_awaddr       (c0_s_axi_awaddr),
        .s_axi_awlen        (c0_s_axi_awlen),
        .s_axi_awsize       (c0_s_axi_awsize),
        .s_axi_awburst      (c0_s_axi_awburst),
        .s_axi_awlock       (c0_s_axi_awlock),
        .s_axi_awcache      (c0_s_axi_awcache),
        .s_axi_awprot       (c0_s_axi_awprot),
        .s_axi_awqos        (c0_s_axi_awqos),    // Connect if exists in MIG IP
        .s_axi_awregion     (c0_s_axi_awregion), // Connect if exists in MIG IP
        .s_axi_awvalid      (c0_s_axi_awvalid),
        .s_axi_awready      (c0_s_axi_awready),
        .s_axi_wdata        (c0_s_axi_wdata),
        .s_axi_wstrb        (c0_s_axi_wstrb),
        .s_axi_wlast        (c0_s_axi_wlast),
        .s_axi_wvalid       (c0_s_axi_wvalid),
        .s_axi_wready       (c0_s_axi_wready),
        .s_axi_bid          (c0_s_axi_bid),
        .s_axi_bresp        (c0_s_axi_bresp),
        .s_axi_bvalid       (c0_s_axi_bvalid),
        .s_axi_bready       (c0_s_axi_bready),
        .s_axi_arid         (c0_s_axi_arid),
        .s_axi_araddr       (c0_s_axi_araddr),
        .s_axi_arlen        (c0_s_axi_arlen),
        .s_axi_arsize       (c0_s_axi_arsize),
        .s_axi_arburst      (c0_s_axi_arburst),
        .s_axi_arlock       (c0_s_axi_arlock),
        .s_axi_arcache      (c0_s_axi_arcache),
        .s_axi_arprot       (c0_s_axi_arprot),
        .s_axi_arqos        (c0_s_axi_arqos),    // Connect if exists in MIG IP
        .s_axi_arregion     (c0_s_axi_arregion), // Connect if exists in MIG IP
        .s_axi_arvalid      (c0_s_axi_arvalid),
        .s_axi_arready      (c0_s_axi_arready),
        .s_axi_rid          (c0_s_axi_rid),
        .s_axi_rdata        (c0_s_axi_rdata),
        .s_axi_rresp        (c0_s_axi_rresp),
        .s_axi_rlast        (c0_s_axi_rlast),
        .s_axi_rvalid       (c0_s_axi_rvalid),
        .s_axi_rready       (c0_s_axi_rready)
        // Add other necessary MIG ports here if they exist
    );

    // MIG 7 Series Instance 1
    // Placeholder - Replace with actual MIG instantiation from Vivado IP Generator
    // Ensure module name 'mig_7series_0_1' and parameters match the generated IP
    mig_7series_0_1 #(
        .C_SIMULATION           (C1_SIMULATION),
        .C_SIM_BYPASS_INIT_CAL  (C1_SIM_BYPASS_INIT_CAL),
        .C_S_AXI_ID_WIDTH       (C1_AXI_ID_WIDTH),
        .C_S_AXI_ADDR_WIDTH     (C1_AXI_ADDR_WIDTH),
        .C_S_AXI_DATA_WIDTH     (C1_AXI_DATA_WIDTH)
        // Add other necessary MIG parameters here if needed
    )
    mig_inst_1 (
        // DDR3 Interface
        .ddr3_dq            (c1_ddr3_dq),
        .ddr3_dqs_n         (c1_ddr3_dqs_n),
        .ddr3_dqs_p         (c1_ddr3_dqs_p),
        .ddr3_addr          (c1_ddr3_addr),
        .ddr3_ba            (c1_ddr3_ba),
        .ddr3_ras_n         (c1_ddr3_ras_n),
        .ddr3_cas_n         (c1_ddr3_cas_n),
        .ddr3_we_n          (c1_ddr3_we_n),
        .ddr3_