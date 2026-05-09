<xaiArtifact artifact_id="c92e5709-fc0a-41b3-a145-f8062734f941" artifact_version_id="90960be0-5562-41c8-9604-386ef56f2f70" title="fpgaTop_corrected.v" contentType="text/verilog">
module fpgaTop (
  input  wire        pcie_clkp,      
  input  wire        pcie_clkn,      
  input  wire        pcie_rstn,      
  input  wire [7:0]  pcie_rxp,       
  input  wire [7:0]  pcie_rxn,
  output wire [7:0]  pcie_txp,
  output wire [7:0]  pcie_txn,
  output wire [2:0]  led,
  output reg  [10:1] mictor,
  input  wire        test_mode
);
wire         ACLK;  
wire         ARESETN; 
wire         dft_resetn;
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
wire [31:0]  M_AXIS_DAT_TDATA;
wire         M_AXIS_DAT_TVALID;
wire [3:0]   M_AXIS_DAT_TSTRB;
wire [127:0] M_AXIS_DAT_TUSER;
wire         M_AXIS_DAT_TLAST;
wire         M_AXIS_DAT_TREADY;
wire [31:0]  S_AXIS_DAT_TDATA;
wire         S_AXIS_DAT_TVALID;
wire [3:0]   S_AXIS_DAT_TSTRB;
wire [127:0] S_AXIS_DAT_TUSER;
wire         S_AXIS_DAT_TLAST;
wire         S_AXIS_DAT_TREADY;
wire [31:0]  I_AXIS_DAT_TDATA;
wire         I_AXIS_DAT_TVALID;
wire [3:0]   I_AXIS_DAT_TSTRB;
wire [127:0] I_AXIS_DAT_TUSER;
wire         I_AXIS_DAT_TLAST;
wire         I_AXIS_DAT_TREADY;
wire [31:0]  debug_oped;       
assign led = debug_oped[2:0];  
assign dft_resetn = test_mode ? pcie_rstn : ARESETN;
always @(posedge ACLK or negedge dft_resetn) begin
  if (~dft_resetn) begin
    mictor <= 10'b0;
  end else begin
    mictor[10]  <= ^debug_oped; 
    mictor[9:1] <= debug_oped[8:0];
  end
end
OPED oped (
  .PCIE_CLKP         (pcie_clkp),
  .PCIE_CLKN         (pcie_clkn),
  .PCIE_RSTN         (pcie_rstn),
  .PCIE_RXP          (pcie_rxp),
  .PCIE_RXN          (pcie_rxn),
  .PCIE_TXP          (pcie_txp),
  .PCIE_TXN          (pcie_txn),
  .ACLK              (ACLK),
  .ARESETN           (ARESETN),
  .M_AXI_AWADDR      (M_AXI_AWADDR),
  .M_AXI_AWPROT      (M_AXI_AWPROT),
  .M_AXI_AWVALID     (M_AXI_AWVALID),
  .M_AXI_AWREADY     (M_AXI_AWREADY),
  .M_AXI_WDATA       (M_AXI_WDATA),
  .M_AXI_WSTRB       (M_AXI_WSTRB),
  .M_AXI_WVALID      (M_AXI_WVALID),
  .M_AXI_WREADY      (M_AXI_WREADY),
  .M_AXI_BRESP       (M_AXI_BRESP),
  .M_AXI_BVALID      (M_AXI_BVALID),
  .M_AXI_BREADY      (M_AXI_BREADY),
  .M_AXI_ARADDR      (M_AXI_ARADDR),
  .M_AXI_ARPROT      (M_AXI_ARPROT),
  .M_AXI_ARVALID     (M_AXI_ARVALID),
  .M_AXI_ARREADY     (M_AXI_ARREADY),
  .M_AXI_RDATA       (M_AXI_RDATA),
  .M_AXI_RRESP       (M_AXI_RRESP),
  .M_AXI_RVALID      (M_AXI_RVALID),
  .M_AXI_RREADY      (M_AXI_RREADY),
  .M_AXIS_DAT_TDATA  (M_AXIS_DAT_TDATA),
  .M_AXIS_DAT_TVALID (M_AXIS_DAT_TVALID),
  .M_AXIS_DAT_TSTRB  (M_AXIS_DAT_TSTRB),
  .M_AXIS_DAT_TUSER  (M_AXIS_DAT_TUSER),
  .M_AXIS_DAT_TLAST  (M_AXIS_DAT_TLAST),
  .M_AXIS_DAT_TREADY (M_AXIS_DAT_TREADY),
  .S_AXIS_DAT_TDATA  (S_AXIS_DAT_TDATA),
  .S_AXIS_DAT_TVALID (S_AXIS_DAT_TVALID),
  .S_AXIS_DAT_TSTRB  (S_AXIS_DAT_TSTRB),
  .S_AXIS_DAT_TUSER  (S_AXIS_DAT_TUSER),
  .S_AXIS_DAT_TLAST  (S_AXIS_DAT_TLAST),
  .S_AXIS_DAT_TREADY (S_AXIS_DAT_TREADY),
  .DEBUG             (debug_oped)
);
mkA4LS axiSlave (
  .ACLK        (ACLK),
  .ARESETN     (dft_resetn),
  .AWADDR      (M_AXI_AWADDR),
  .AWPROT      (M_AXI_AWPROT),
  .AWVALID     (M_AXI_AWVALID),
  .AWREADY     (M_AXI_AWREADY),
  .WDATA       (M_AXI_WDATA),
  .WSTRB       (M_AXI_WSTRB),
  .WVALID      (M_AXI_WVALID),
  .WREADY      (M_AXI_WREADY),
  .BRESP       (M_AXI_BRESP),
  .BVALID      (M_AXI_BVALID),
  .BREADY      (M_AXI_BREADY),
  .ARADDR      (M_AXI_ARADDR),
  .ARPROT      (M_AXI_ARPROT),
  .ARVALID     (M_AXI_ARVALID),
  .ARREADY     (M_AXI_ARREADY),
  .RDATA       (M_AXI_RDATA),
  .RRESP       (M_AXI_RRESP),
  .RVALID      (M_AXI_RVALID),
  .RREADY      (M_AXI_RREADY)
);
AXIS_LOOPBACK axisLoopback (
  .ACLK              (ACLK),
  .ARESETN           (dft_resetn),
  .S_AXIS_DAT_TDATA  (M_AXIS_DAT_TDATA),
  .S_AXIS_DAT_TVALID (M_AXIS_DAT_TVALID),
  .S_AXIS_DAT_TSTRB  (M_AXIS_DAT_TSTRB),
  .S_AXIS_DAT_TUSER  (M_AXIS_DAT_TUSER), 
  .S_AXIS_DAT_TLAST  (M_AXIS_DAT_TLAST),
  .S_AXIS_DAT_TREADY (M_AXIS_DAT_TREADY),
  .M_AXIS_DAT_TDATA  (S_AXIS_DAT_TDATA),
  .M_AXIS_DAT_TVALID (S_AXIS_DAT_TVALID),
  .M_AXIS_DAT_TSTRB  (S_AXIS_DAT_TSTRB),
  .M_AXIS_DAT_TUSER  (S_AXIS_DAT_TUSER), 
  .M_AXIS_DAT_TLAST  (S_AXIS_DAT_TLAST),
  .M_AXIS_DAT_TREADY (S_AXIS_DAT_TREADY)
);
endmodule
</xaiArtifact>