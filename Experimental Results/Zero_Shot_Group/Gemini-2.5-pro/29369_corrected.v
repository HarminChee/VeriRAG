module fpgaTop (
  input  wire        pcie_clkp,
  input  wire        pcie_clkn,
  input  wire        pcie_rstn,
  input  wire [7:0]  pcie_rxp,
  input  wire [7:0]  pcie_rxn,
  output wire [7:0]  pcie_txp,
  output wire [7:0]  pcie_txn,
  output wire [2:0]  led,
  output reg  [10:1] mictor
);

// Internal Signals
wire         ACLK;
wire         ARESETN;

// AXI Master Interface (from OPED to mkA4LS)
wire [31:0]  M_AXI_AWADDR;
wire [2:0]   M_AXI_AWPROT;
wire         M_AXI_AWVALID;
wire         M_AXI_AWREADY;
wire [31:0]  M_AXI_WDATA;
wire [3:0]   M_AXI_WSTRB;
wire         M_AXI_WVALID;
wire         M_AXI_WREADY;
wire [1:0]   M_AXI_BRESP;
wire         M_AXI_BVALID;
wire         M_AXI_BREADY;
wire [31:0]  M_AXI_ARADDR;
wire [2:0]   M_AXI_ARPROT;
wire         M_AXI_ARVALID;
wire         M_AXI_ARREADY;
wire [31:0]  M_AXI_RDATA;
wire [1:0]   M_AXI_RRESP;
wire         M_AXI_RVALID;
wire         M_AXI_RREADY;

// AXI Stream Master Interface (from OPED to AXIS_LOOPBACK)
wire [31:0]  M_AXIS_DAT_TDATA;
wire         M_AXIS_DAT_TVALID;
wire [3:0]   M_AXIS_DAT_TSTRB;
wire [127:0] M_AXIS_DAT_TUSER;
wire         M_AXIS_DAT_TLAST;
wire         M_AXIS_DAT_TREADY;

// AXI Stream Slave Interface (from AXIS_LOOPBACK to OPED)
wire [31:0]  S_AXIS_DAT_TDATA;
wire         S_AXIS_DAT_TVALID;
wire [3:0]   S_AXIS_DAT_TSTRB;
wire [127:0] S_AXIS_DAT_TUSER;
wire         S_AXIS_DAT_TLAST;
wire         S_AXIS_DAT_TREADY;

// Debug Signal
wire [31:0]  debug_oped;

// Assignments
assign led = debug_oped[2:0];

always @(posedge ACLK) begin
  if (!ARESETN) begin
    mictor <= 10'b0;
  end else begin
    mictor[10]  <= ^debug_oped;
    mictor[9:1] <= debug_oped[8:0];
  end
end

// Instantiate OPED Core
 OPED oped (
  .PCIE_CLKP         (pcie_clkp),
  .PCIE_CLKN         (pcie_clkn),
  .PCIE_RSTN         (pcie_rstn),
  .PCIE_RXP          (pcie_rxp),
  .PCIE_RXN          (pcie_rxn),
  .PCIE_TXP          (pcie_txp),
  .PCIE_TXN          (pcie_txn),

  .ACLK              (ACLK),          // Output clock from OPED
  .ARESETN           (ARESETN),       // Output reset from OPED

  // AXI Master Interface (Output from OPED)
  .M_AXI_AWADDR      (M_AXI_AWADDR),
  .M_AXI_AWPROT      (M_AXI_AWPROT),
  .M_AXI_AWVALID     (M_AXI_AWVALID),
  .M_AXI_AWREADY     (M_AXI_AWREADY), // Input to OPED
  .M_AXI_WDATA       (M_AXI_WDATA),
  .M_AXI_WSTRB       (M_AXI_WSTRB),
  .M_AXI_WVALID      (M_AXI_WVALID),
  .M_AXI_WREADY      (M_AXI_WREADY),  // Input to OPED
  .M_AXI_BRESP       (M_AXI_BRESP),   // Input to OPED
  .M_AXI_BVALID      (M_AXI_BVALID),  // Input to OPED
  .M_AXI_BREADY      (M_AXI_BREADY),
  .M_AXI_ARADDR      (M_AXI_ARADDR),
  .M_AXI_ARPROT      (M_AXI_ARPROT),
  .M_AXI_ARVALID     (M_AXI_ARVALID),
  .M_AXI_ARREADY     (M_AXI_ARREADY), // Input to OPED
  .M_AXI_RDATA       (M_AXI_RDATA),   // Input to OPED
  .M_AXI_RRESP       (M_AXI_RRESP),   // Input to OPED
  .M_AXI_RVALID      (M_AXI_RVALID),  // Input to OPED
  .M_AXI_RREADY      (M_AXI_RREADY),

  // AXI Stream Master Interface (Output from OPED)
  .M_AXIS_DAT_TDATA  (M_AXIS_DAT_TDATA),
  .M_AXIS_DAT_TVALID (M_AXIS_DAT_TVALID),
  .M_AXIS_DAT_TSTRB  (M_AXIS_DAT_TSTRB),
  .M_AXIS_DAT_TUSER  (M_AXIS_DAT_TUSER),
  .M_AXIS_DAT_TLAST  (M_AXIS_DAT_TLAST),
  .M_AXIS_DAT_TREADY (M_AXIS_DAT_TREADY), // Input to OPED

  // AXI Stream Slave Interface (Input to OPED)
  .S_AXIS_DAT_TDATA  (S_AXIS_DAT_TDATA),  // Input to OPED
  .S_AXIS_DAT_TVALID (S_AXIS_DAT_TVALID), // Input to OPED
  .S_AXIS_DAT_TSTRB  (S_AXIS_DAT_TSTRB),  // Input to OPED
  .S_AXIS_DAT_TUSER  (S_AXIS_DAT_TUSER),  // Input to OPED
  .S_AXIS_DAT_TLAST  (S_AXIS_DAT_TLAST),  // Input to OPED
  .S_AXIS_DAT_TREADY (S_AXIS_DAT_TREADY), // Output from OPED

  // Debug Output
  .DEBUG             (debug_oped)       // Output from OPED
);

// Instantiate AXI Lite Slave Example
 mkA4LS axiSlave (
  .ACLK        (ACLK),
  .ARESETN     (ARESETN),

  // AXI Write Address Channel (Input to Slave)
  .AWADDR      (M_AXI_AWADDR),
  .AWPROT      (M_AXI_AWPROT),
  .AWVALID     (M_AXI_AWVALID),
  .AWREADY     (M_AXI_AWREADY), // Output from Slave

  // AXI Write Data Channel (Input to Slave)
  .WDATA       (M_AXI_WDATA),
  .WSTRB       (M_AXI_WSTRB),
  .WVALID      (M_AXI_WVALID),
  .WREADY      (M_AXI_WREADY),  // Output from Slave

  // AXI Write Response Channel (Output from Slave)
  .BRESP       (M_AXI_BRESP),
  .BVALID      (M_AXI_BVALID),
  .BREADY      (M_AXI_BREADY),  // Input to Slave

  // AXI Read Address Channel (Input to Slave)
  .ARADDR      (M_AXI_ARADDR),
  .ARPROT      (M_AXI_ARPROT),
  .ARVALID     (M_AXI_ARVALID),
  .ARREADY     (M_AXI_ARREADY), // Output from Slave

  // AXI Read Data Channel (Output from Slave)
  .RDATA       (M_AXI_RDATA),
  .RRESP       (M_AXI_RRESP),
  .RVALID      (M_AXI_RVALID),
  .RREADY      (M_AXI_RREADY)   // Input to Slave
);

// Instantiate AXI Stream Loopback
 AXIS_LOOPBACK axisLoopback (
  .ACLK              (ACLK),
  .ARESETN           (ARESETN),

  // AXI Stream Slave Interface (Input to Loopback)
  .S_AXIS_DAT_TDATA  (M_AXIS_DAT_TDATA),  // From OPED Master Port
  .S_AXIS_DAT_TVALID (M_AXIS_DAT_TVALID), // From OPED Master Port
  .S_AXIS_DAT_TSTRB  (M_AXIS_DAT_TSTRB),  // From OPED Master Port
  .S_AXIS_DAT_TUSER  (M_AXIS_DAT_TUSER),  // From OPED Master Port
  .S_AXIS_DAT_TLAST  (M_AXIS_DAT_TLAST),  // From OPED Master Port
  .S_AXIS_DAT_TREADY (M_AXIS_DAT_TREADY), // To OPED Master Port (Output from Loopback)

  // AXI Stream Master Interface (Output from Loopback)
  .M_AXIS_DAT_TDATA  (S_AXIS_DAT_TDATA),  // To OPED Slave Port
  .M_AXIS_DAT_TVALID (S_AXIS_DAT_TVALID), // To OPED Slave Port
  .M_AXIS_DAT_TSTRB  (S_AXIS_DAT_TSTRB),  // To OPED Slave Port
  .M_AXIS_DAT_TUSER  (S_AXIS_DAT_TUSER),  // To OPED Slave Port
  .M_AXIS_DAT_TLAST  (S_AXIS_DAT_TLAST),  // To OPED Slave Port
  .M_AXIS_DAT_TREADY (S_AXIS_DAT_TREADY)  // From OPED Slave Port (Input to Loopback)
);

endmodule