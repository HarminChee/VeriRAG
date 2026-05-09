`define simu 

module TOP_SYS(
    input i_100MHz_P, i_100MHz_N,
    input rstn,
    output TXD,
    input RXD,
    inout [15:0] DDR3DQ,
    inout [1:0] DDR3DQS_N,
    inout [1:0] DDR3DQS_P,
    output [13:0] DDR3ADDR,
    output [2:0] DDR3BA,
    output DDR3RAS_N,
    output DDR3CAS_N,
    output DDR3WE_N,
    output DDR3CK_P,
    output DDR3CK_N,
    output DDR3CKE,
    output DDR3RST_N,
    output [1:0] DDR3DM,
    output DDR3ODT,
    output sdout, sdcs,
    input sdin,
    inout [7:0] gpioA,
    output VID_CLK_N, VID_CLK_P,
    output [2:0] VID_D_N, VID_D_P
);

wire [2:0] dbg;
wire [7:0] gpioB;
wire clk, clk200, clk400, clk_pix;
wire dram_rst_out, ui_clk_sync_rst, init_calib_complete, rstn_ddr, locked, mmcm_locked;
wire [119:0] ddr3_ila_basic;
wire [31:0] M_AXI_AW, M_AXI_AR, M_AXI_R, M_AXI_W;
wire M_AXI_AWVALID, M_AXI_ARVALID, M_AXI_WVALID, M_AXI_RREADY;
wire M_AXI_AWREADY, M_AXI_ARREADY, M_AXI_WREADY, M_AXI_RVALID, M_AXI_RLAST, M_AXI_WLAST;
wire [3:0] M_AXI_WSTRB;
wire [1:0] M_AXI_ARBURST, M_AXI_AWBURST;
wire [7:0] M_AXI_ARLEN, M_AXI_AWLEN;
wire [2:0] M_AXI_ARSIZE, M_AXI_AWSIZE;

freq_man ifreq_man(
    .clk_in1_p(i_100MHz_P),
    .clk_in1_n(i_100MHz_N),
    .clk_out1(clk400),
    .clk_out2(clk200),
    .clk_out3(clk_pix),
    .locked(locked)
);

HDMI_test ihdmi(
    .rstn(rstn),
    .pixclk(clk_pix),
    .TMDSp(VID_D_P),
    .TMDSn(VID_D_N),
    .TMDSp_clock(VID_CLK_P),
    .TMDSn_clock(VID_CLK_N)
);

RSTGEN rstgen(
    .CLK(clk),
    .RST_X_I(~(~rstn | dram_rst_out)),
    .RST_X_O(rstn_ddr)
);

assign dram_rst_out = (ui_clk_sync_rst | ~init_calib_complete);

ddr_axi i_ddr_axi(
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
    .sys_clk_i(clk400),
    .clk_ref_i(clk200),
    .ui_clk(clk),
    .ui_clk_sync_rst(ui_clk_sync_rst),
    .mmcm_locked(mmcm_locked),
    .aresetn(rstn),
    .app_sr_req(0),
    .app_ref_req(0),
    .app_zq_req(0),
    .init_calib_complete(init_calib_complete),
    .sys_rst(~locked)
);

axi_rom bootrom(
    .clk(clk),
    .rstn(rstn_ddr),
    .axi_ARVALID(S_AXI_ARVALID_rom),
    .axi_ARREADY(S_AXI_ARREADY_rom),
    .axi_AR(S_AXI_AR_rom),
    .axi_ARBURST(S_AXI_ARBURST_rom),
    .axi_ARLEN(S_AXI_ARLEN_rom),
    .axi_RLAST(S_AXI_RLAST_rom),
    .axi_R(S_AXI_R_rom),
    .axi_RVALID(S_AXI_RVALID_rom),
    .axi_RREADY(S_AXI_RREADY_rom)
);

periph i_periph(
    .s00_AXI_RSTN(rstn_ddr),
    .s00_AXI_CLK(clk),
    .cfg(gpio_in[6:0]),
    .spi_mosi(sdout),
    .spi_miso(sdin),
    .spi_clk(sdclk),
    .spi_cs(sdcs),
    .gpioA_in(gpioA),
    .gpioA_out(gpioA_out),
    .gpioA_dir(gpioA_dir),
    .RXD(RXD),
    .TXD(TXD),
    .s00_AXI_AWADDR(M_IO_AXI_AW),
    .s00_AXI_AWVALID(M_IO_AXI_AWVALID),
    .s00_AXI_AWREADY(M_IO_AXI_AWREADY),
    .s00_AXI_AWBURST(M_IO_AXI_AWBURST),
    .s00_AXI_AWLEN(M_IO_AXI_AWLEN),
    .s00_AXI_AWSIZE(M_IO_AXI_AWSIZE),
    .s00_AXI_ARADDR(M_IO_AXI_AR),
    .s00_AXI_ARVALID(M_IO_AXI_ARVALID),
    .s00_AXI_ARREADY(M_IO_AXI_ARREADY),
    .s00_AXI_ARBURST(M_IO_AXI_ARBURST),
    .s00_AXI_ARLEN(M_IO_AXI_ARLEN),
    .s00_AXI_ARSIZE(M_IO_AXI_ARSIZE),
    .s00_AXI_WDATA(M_IO_AXI_W),
    .s00_AXI_WVALID(M_IO_AXI_WVALID),
    .s00_AXI_WREADY(M_IO_AXI_WREADY),
    .s00_AXI_WSTRB(M_IO_AXI_WSTRB),
    .s00_AXI_WLAST(M_IO_AXI_WLAST),
    .s00_AXI_RDATA(M_IO_AXI_R),
    .s00_AXI_RVALID(M_IO_AXI_RVALID),
    .s00_AXI_RREADY(M_IO_AXI_RREADY),
    .s00_AXI_RLAST(M_IO_AXI_RLAST),
    .s00_AXI_BVALID(),
    .s00_AXI_BREADY(1'b1)
);

`ifndef simu
mii_to_rmii_0 mii_to_rmii_i(
    .rst_n(PhyRstn),
    .ref_clk(PhyClk50Mhz),
    .mac2rmii_tx_en(mac2rmii_tx_en),
    .mac2rmii_txd(mac2rmii_txd),
    .mac2rmii_tx_er(mac2rmii_tx_er),
    .rmii2mac_tx_clk(rmii2mac_tx_clk),
    .rmii2mac_rx_clk(rmii2mac_rx_clk),
    .rmii2mac_col(rmii2mac_col),
    .rmii2mac_crs(rmii2mac_crs),
    .rmii2mac_rx_dv(rmii2mac_rx_dv),
    .rmii2mac_rx_er(rmii2mac_rx_er),
    .rmii2mac_rxd(rmii2mac_rxd),
    .phy2rmii_crs_dv(PhyCrs),
    .phy2rmii_rx_er(PhyRxErr),
    .phy2rmii_rxd(PhyRxd),
    .rmii2phy_txd(PhyTxd),
    .rmii2phy_tx_en(PhyTxEn)
);
`endif

endmodule