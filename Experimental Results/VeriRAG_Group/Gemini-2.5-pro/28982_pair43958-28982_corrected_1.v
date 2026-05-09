module TOP_SYS(
test_i,
i_100MHz_P,
i_100MHz_N,
rstn,
TXD,RXD,
DDR3DQ,
DDR3DQS_N,
DDR3DQS_P,
DDR3ADDR,
DDR3BA,
DDR3RAS_N,
DDR3CAS_N,
DDR3WE_N,
DDR3CK_P,
DDR3CK_N,
DDR3CKE,
DDR3RST_N,
DDR3DM,
DDR3ODT,
sdin,sdout,sdcs,
gpioA,
VID_CLK_N,
VID_CLK_P,
VID_D_N,
VID_D_P
);

// Ports
input            test_i;
input            i_100MHz_P,i_100MHz_N;
input            rstn;
output           TXD;
input            RXD;
inout wire [15:0]  DDR3DQ;
inout wire [1:0]   DDR3DQS_N;
inout wire [1:0]   DDR3DQS_P;
output wire [13:0] DDR3ADDR;
output wire [2:0]  DDR3BA;
output wire        DDR3RAS_N;
output wire        DDR3CAS_N;
output wire        DDR3WE_N;
output wire        DDR3CK_P;
output wire        DDR3CK_N;
output wire        DDR3CKE;
output wire        DDR3RST_N;
output wire [1:0]  DDR3DM;
output wire        DDR3ODT;
output           sdout,sdcs;
input            sdin;
inout     [7:0]  gpioA;
output [2:0] VID_D_N,VID_D_P;
output VID_CLK_N,VID_CLK_P;

// Internal Wires and Regs
wire [2:0] dbg;
wire      [6:0] gpio_in;
wire     [7:0]  gpioB;
wire PhyMdio_t;
wire PhyMdio_o;
wire PhyMdio_i;
wire int_net;
wire PhyRstn;
wire PhyCrs;
wire       PhyRxErr;
wire  [1:0] PhyRxd;
wire       PhyTxEn;
wire [1:0] PhyTxd;
reg PhyClk50Mhz;
wire [4:0] debug_int;
wire       rmii2mac_tx_clk;
wire       rmii2mac_rx_clk;
wire       rmii2mac_crs;
wire       rmii2mac_rx_dv;
wire [3:0] rmii2mac_rxd;
wire       rmii2mac_col;
wire       rmii2mac_rx_er;
wire       mac2rmii_tx_en;
wire [3:0] mac2rmii_txd;
wire       mac2rmii_tx_er;
wire [31:0] M_AXI_AW, M_AXI_AR;
wire        M_AXI_AWVALID,M_AXI_ARVALID,M_AXI_WVALID,M_AXI_RREADY;
wire        M_AXI_AWREADY,M_AXI_ARREADY,M_AXI_WREADY,M_AXI_RVALID,M_AXI_RLAST,M_AXI_WLAST, M_AXI_BREADY;
wire [31:0] M_AXI_R;
wire [31:0] M_AXI_W;
wire  [3:0] M_AXI_WSTRB;
wire  [1:0] M_AXI_ARBURST;
wire  [7:0] M_AXI_ARLEN;
wire  [2:0] M_AXI_ARSIZE;
wire  [1:0] M_AXI_AWBURST;
wire  [7:0] M_AXI_AWLEN;
wire  [2:0] M_AXI_AWSIZE;
wire [31:0] S_AXI_AW_ram, S_AXI_AR_ram;
wire        S_AXI_AWVALID_ram,S_AXI_ARVALID_ram,S_AXI_WVALID_ram,S_AXI_RREADY_ram;
wire        S_AXI_AWREADY_ram,S_AXI_ARREADY_ram,S_AXI_WREADY_ram,S_AXI_RVALID_ram,S_AXI_RLAST_ram,S_AXI_WLAST_ram;
wire [31:0] S_AXI_R_ram;
wire [31:0] S_AXI_W_ram;
wire  [3:0] S_AXI_WSTRB_ram;
wire  [1:0] S_AXI_ARBURST_ram;
wire  [7:0] S_AXI_ARLEN_ram;
wire  [2:0] S_AXI_ARSIZE_ram;
wire  [1:0] S_AXI_AWBURST_ram;
wire  [7:0] S_AXI_AWLEN_ram;
wire  [2:0] S_AXI_AWSIZE_ram;
wire [31:0] S_AXI_AW_rom, S_AXI_AR_rom;
wire        S_AXI_AWVALID_rom,S_AXI_ARVALID_rom,S_AXI_WVALID_rom,S_AXI_RREADY_rom;
wire        S_AXI_AWREADY_rom,S_AXI_ARREADY_rom,S_AXI_WREADY_rom,S_AXI_RVALID_rom,S_AXI_RLAST_rom,S_AXI_WLAST_rom;
wire [31:0] S_AXI_R_rom;
wire [31:0] S_AXI_W_rom;
wire  [3:0] S_AXI_WSTRB_rom;
wire  [1:0] S_AXI_ARBURST_rom;
wire  [7:0] S_AXI_ARLEN_rom;
wire  [2:0] S_AXI_ARSIZE_rom;
wire  [1:0] S_AXI_AWBURST_rom;
wire  [7:0] S_AXI_AWLEN_rom;
wire  [2:0] S_AXI_AWSIZE_rom;
wire [31:0] S_AXI_AW_net, S_AXI_AR_net;
wire        S_AXI_AWVALID_net,S_AXI_ARVALID_net,S_AXI_WVALID_net,S_AXI_RREADY_net;
wire        S_AXI_AWREADY_net,S_AXI_ARREADY_net,S_AXI_WREADY_net,S_AXI_RVALID_net,S_AXI_RLAST_net,S_AXI_WLAST_net;
wire [31:0] S_AXI_R_net;
wire [31:0] S_AXI_W_net;
wire  [3:0] S_AXI_WSTRB_net;
wire  [1:0] S_AXI_ARBURST_net;
wire  [7:0] S_AXI_ARLEN_net;
wire  [2:0] S_AXI_ARSIZE_net;
wire  [1:0] S_AXI_AWBURST_net;
wire  [7:0] S_AXI_AWLEN_net;
wire  [2:0] S_AXI_AWSIZE_net;
wire [31:0] M_IO_AXI_AW, M_IO_AXI_AR;
wire        M_IO_AXI_AWVALID,M_IO_AXI_ARVALID,M_IO_AXI_WVALID,M_IO_AXI_RREADY;
wire        M_IO_AXI_AWREADY,M_IO_AXI_ARREADY,M_IO_AXI_WREADY,M_IO_AXI_RVALID,M_IO_AXI_RLAST,M_IO_AXI_WLAST, M_IO_AXI_BREADY;
wire [31:0] M_IO_AXI_R;
wire [31:0] M_IO_AXI_W;
wire  [3:0] M_IO_AXI_WSTRB;
wire  [1:0] M_IO_AXI_ARBURST;
wire  [3:0] M_IO_AXI_ARLEN; // Note: v586 instance uses [7:0] for ARLEN
wire  [2:0] M_IO_AXI_ARSIZE;
wire  [1:0] M_IO_AXI_AWBURST;
wire  [7:0] M_IO_AXI_AWLEN;
wire  [2:0] M_IO_AXI_AWSIZE;
wire [15:0] extDBo,extDBt;
wire  [7:0] gpioA_dir,gpioB_dir,gpioA_out,gpioB_out;
wire [31:0] romA,romQ;
wire int_pic,iack;
wire [7:0] ivect;
wire        clk;
wire        clk300;
wire        dram_rst_out;
wire        ui_clk_sync_rst;
wire        init_calib_complete;
wire        rstn_ddr;
wire        locked;
wire        mmcm_locked;
wire [119:0] ddr3_ila_basic;
wire clk200,clk_pix, clk400;
wire sdclk; // Declaration added

// DFT Signals
wire dft_clk;
wire dft_rstn_ddr;
wire dft_sys_rst;

assign dft_clk = test_i ? clk200 : clk; // DFT clock mux: use clk200 (from PLL) in test mode
assign dft_rstn_ddr = test_i ? rstn : rstn_ddr; // DFT reset mux for internally generated reset
assign dft_sys_rst = test_i ? ~rstn : ~locked; // DFT reset mux for ddr_axi sys_rst

assign gpio_in = 0;
assign dbg = {rstn_ddr,init_calib_complete,mmcm_locked};

freq_man ifreq_man (
.clk_in1_p(i_100MHz_P),
.clk_in1_n(i_100MHz_N),
.clk_out1(clk400),
.clk_out2(clk200),
.clk_out3(clk_pix),
.locked(locked)
);

HDMI_test ihdmi(
.rstn(rstn), // Use primary reset
.pixclk(clk_pix), // Clocked by dedicated pixel clock
.TMDSp(VID_D_P),
.TMDSn(VID_D_N),
.TMDSp_clock(VID_CLK_P),
.TMDSn_clock(VID_CLK_N)
);

STARTUPE2 #(
   .PROG_USR("FALSE"),
   .SIM_CCLK_FREQ(0.0)
)
STARTUPE2_inst (
   .CFGCLK(),
   .CFGMCLK(),
   .EOS(),
   .PREQ(),
   .CLK(1'b0),
   .GSR(1'b0),
   .GTS(1'b0),
   .KEYCLEARB(1'b0),
   .PACK(1'b0),
   .USRCCLKO(sdclk),
   .USRCCLKTS(1'b0),
   .USRDONEO(1'b1),
   .USRDONETS(1'b1)
);

RSTGEN rstgen(
    .CLK(dft_clk), // Use DFT controllable clock
    .RST_X_I(~(~rstn | dram_rst_out)),
    .RST_X_O(rstn_ddr)
);

assign dram_rst_out = (ui_clk_sync_rst | ~init_calib_complete);

v586 v586 (
.m00_AXI_RSTN(dft_rstn_ddr),.m00_AXI_CLK(dft_clk), // Use DFT clk & rst
.m00_AXI_AWADDR(M_AXI_AW), .m00_AXI_AWVALID(M_AXI_AWVALID), .m00_AXI_AWREADY(M_AXI_AWREADY),
.m00_AXI_AWBURST(M_AXI_AWBURST), .m00_AXI_AWLEN(M_AXI_AWLEN), .m00_AXI_AWSIZE(M_AXI_AWSIZE),
.m00_AXI_WDATA(M_AXI_W), .m00_AXI_WVALID(M_AXI_WVALID), .m00_AXI_WREADY(M_AXI_WREADY), .m00_AXI_WSTRB(M_AXI_WSTRB), .m00_AXI_WLAST(M_AXI_WLAST),
.m00_AXI_ARADDR(M_AXI_AR), .m00_AXI_ARVALID(M_AXI_ARVALID), .m00_AXI_ARREADY(M_AXI_ARREADY),
.m00_AXI_ARBURST(M_AXI_ARBURST), .m00_AXI_ARLEN(M_AXI_ARLEN), .m00_AXI_ARSIZE(M_AXI_ARSIZE),
.m00_AXI_RDATA(M_AXI_R), .m00_AXI_RVALID(M_AXI_RVALID), .m00_AXI_RREADY(M_AXI_RREADY), .m00_AXI_RLAST(M_AXI_RLAST),
.m00_AXI_BVALID(1'b1),.m00_AXI_BREADY(M_AXI_BREADY), // Assuming BREADY is output from v586
.m01_AXI_AWADDR(M_IO_AXI_AW), .m01_AXI_AWVALID(M_IO_AXI_AWVALID), .m01_AXI_AWREADY(M_IO_AXI_AWREADY),
.m01_AXI_AWBURST(M_IO_AXI_AWBURST), .m01_AXI_AWLEN(M_IO_AXI_AWLEN), .m01_AXI_AWSIZE(M_IO_AXI_AWSIZE),
.m01_AXI_WDATA(M_IO_AXI_W), .m01_AXI_WVALID(M_IO_AXI_WVALID), .m01_AXI_WREADY(M_IO_AXI_WREADY), .m01_AXI_WSTRB(M_IO_AXI_WSTRB), .m01_AXI_WLAST(M_IO_AXI_WLAST),
.m01_AXI_ARADDR(M_IO_AXI_AR), .m01_AXI_ARVALID(M_IO_AXI_ARVALID), .m01_AXI_ARREADY(M_IO_AXI_ARREADY),
.m01_AXI_ARBURST(M_IO_AXI_ARBURST), .m01_AXI_ARLEN(M_IO_AXI_ARLEN[3:0]), .m01_AXI_ARSIZE(M_IO_AXI_ARSIZE), // Check ARLEN width mismatch
.m01_AXI_RDATA(M_IO_AXI_R), .m01_AXI_RVALID(M_IO_AXI_RVALID), .m01_AXI_RREADY(M_IO_AXI_RREADY), .m01_AXI_RLAST(M_IO_AXI_RLAST),
.m01_AXI_BVALID(1'b1),.m01_AXI_BREADY(M_IO_AXI_BREADY), // Assuming BREADY is output from v586
.int_pic(int_pic),.ivect(ivect),.iack(iack), .debug(debug_int)
);

ddr_axi i_ddr_axi (
   .ddr3_dq(DDR3DQ),
   .ddr3_dqs_n(DDR3DQS_N),
   .ddr3_dqs_p(DDR3DQS_P),
   .ddr3_addr(DDR3ADDR),
   .ddr3_ba(DDR3BA),
   .ddr3_ras_n(DDR3RAS_N),
   .ddr3_cas_n(DDR3CAS_N),
   .ddr3_we_n(DDR3WE_N),
   .ddr3_ck_p(DDR3CK_P),
   .ddr3_ck_n(DDR3CK_N),
   .ddr3_cke(DDR3CKE),
   .ddr3_reset_n(DDR3RST_N),
   .ddr3_dm(DDR3DM),
   .ddr3_odt(DDR3ODT),
   .sys_clk_i(clk400), // Input clock from PLL
   .clk_ref_i(clk200), // Input clock from PLL
   .ui_clk(clk), // Output clock (internal source - CLKNPI)
   .ui_clk_sync_rst(ui_clk_sync_rst), // Output reset
   .mmcm_locked(mmcm_locked), // Output status
   .aresetn(rstn), // Use primary reset
   .app_sr_req(0),
   .app_ref_req(0),
   .app_zq_req(0),
   .app_sr_active(),
   .app_ref_ack(),
   .app_zq_ack(),
       .s_axi_awid(4'b00),
       .s_axi_awaddr(S_AXI_AW_ram),
       .s_axi_awlen(S_AXI_AWLEN_ram),
       .s_axi_awsize(S_AXI_AWSIZE_ram),
       .s_axi_awburst(S_AXI_AWBURST_ram),
       .s_axi_awlock(1'b0),
       .s_axi_awcache(4'h0),
       .s_axi_awprot(3'h0),
       .s_axi_awqos(4'h0),
       .s_axi_awvalid(S_AXI_AWVALID_ram),
       .s_axi_awready(S_AXI_AWREADY_ram),
       .s_axi_wdata(S_AXI_W_ram),
       .s_axi_wstrb(S_AXI_WSTRB_ram),
       .s_axi_wlast(S_AXI_WLAST_ram),
       .s_axi_wvalid(S_AXI_WVALID_ram),
       .s_axi_wready(S_AXI_WREADY_ram),
       .s_axi_bid(),
       .s_axi_bresp(),
       .s_axi_bvalid(),
       .s_axi_bready(1'b1),
       .s_axi_arid(4'b0),
       .s_axi_araddr(S_AXI_AR_ram),
       .s_axi_arlen(S_AXI_ARLEN_ram),
       .s_axi_arsize(S_AXI_ARSIZE_ram),
       .s_axi_arburst(S_AXI_ARBURST_ram),
       .s_axi_arlock(1'b0),
       .s_axi_arcache(4'h0),
       .s_axi_arprot(3'h0),
       .s_axi_arqos(4'h0),
       .s_axi_arvalid(S_AXI_ARVALID_ram),
       .s_axi_arready(S_AXI_ARREADY_ram),
       .s_axi_rid(),
       .s_axi_rdata(S_AXI_R_ram),
       .s_axi_rresp(),
       .s_axi_rlast(S_AXI_RLAST_ram),
       .s_axi_rvalid(S_AXI_RVALID_ram),
       .s_axi_rready(S_AXI_RREADY_ram),
       .init_calib_complete(init_calib_complete), // Output status
       .sys_rst(dft_sys_rst) // Use DFT controllable reset
  );

axi_rom bootrom (
   .clk(dft_clk), // Use DFT controllable clock
   .rstn(dft_rstn_ddr), // Use DFT controllable reset
   .axi_ARVALID(S_AXI_ARVALID_rom),
   .axi_ARREADY(S_AXI_ARREADY_rom),
   .axi_AR(S_AXI_AR_rom),
   .axi_ARBURST(S_AXI_ARBURST_rom),
   .axi_ARLEN(S_AXI_ARLEN_rom),
   .axi_RLAST(S_AXI_RLAST_rom),
   .axi_R(S_AXI_R_rom)
); // Added missing parenthesis

endmodule