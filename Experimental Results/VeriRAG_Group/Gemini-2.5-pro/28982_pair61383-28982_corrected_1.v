`define simu
module TOP_SYS(
input test_mode,
input scan_rstn,
input i_100MHz_P,
input i_100MHz_N,
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
input sdin,
output sdout,
output sdcs,
inout [7:0] gpioA,
output [2:0] VID_D_N,
output [2:0] VID_D_P,
output VID_CLK_N,
output VID_CLK_P
);
wire [2:0] dbg;
//input            i_100MHz_P,i_100MHz_N; // Already declared
//input            rstn; // Already declared
//output           TXD; // Already declared
wire      [6:0] gpio_in;
//output [2:0] VID_D_N,VID_D_P; // Already declared
//output VID_CLK_N,VID_CLK_P; // Already declared
//inout wire [15:0]  DDR3DQ; // Already declared
//inout wire [1:0]   DDR3DQS_N; // Already declared
//inout wire [1:0]   DDR3DQS_P; // Already declared
//output wire [13:0] DDR3ADDR; // Already declared
//output wire [2:0]  DDR3BA; // Already declared
//output wire        DDR3RAS_N; // Already declared
//output wire        DDR3CAS_N; // Already declared
//output wire        DDR3WE_N; // Already declared
//output wire        DDR3CK_P; // Already declared
//output wire        DDR3CK_N; // Already declared
//output wire        DDR3CKE; // Already declared
//output wire        DDR3RST_N; // Already declared
//output wire [1:0]  DDR3DM; // Already declared
//output wire        DDR3ODT; // Already declared
//input            RXD; // Already declared
//output           sdout,sdcs; // Already declared
//input            sdin; // Already declared
//inout     [7:0]  gpioA; // Already declared
wire     [7:0]  gpioB; // Unused?
wire PhyMdio_t; // Unused?
wire PhyMdio_o; // Unused?
wire PhyMdio_i; // Unused?
wire int_net; // Unused?
wire PhyRstn; // Driven where? Assumed internal for DFT fix
wire PhyCrs; // Unused?
wire       PhyRxErr; // Unused?
wire  [1:0] PhyRxd; // Unused?
wire       PhyTxEn; // Unused?
wire [1:0] PhyTxd; // Unused?
reg PhyClk50Mhz; // Driven where? Assumed internal for DFT fix
wire [4:0] debug_int;
wire       rmii2mac_tx_clk; // Unused?
wire       rmii2mac_rx_clk; // Unused?
wire       rmii2mac_crs; // Unused?
wire       rmii2mac_rx_dv; // Unused?
wire [3:0] rmii2mac_rxd; // Unused?
wire       rmii2mac_col; // Unused?
wire       rmii2mac_rx_er; // Unused?
wire       mac2rmii_tx_en; // Unused?
wire [3:0] mac2rmii_txd; // Unused?
wire       mac2rmii_tx_er; // Unused?
wire [31:0] M_AXI_AW, M_AXI_AR;
wire        M_AXI_AWVALID,M_AXI_ARVALID,M_AXI_WVALID,M_AXI_RREADY;
wire        M_AXI_AWREADY,M_AXI_ARREADY,M_AXI_WREADY,M_AXI_RVALID,M_AXI_RLAST,M_AXI_WLAST,M_AXI_BREADY; // Added M_AXI_BREADY
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
wire [31:0] S_AXI_AW_rom, S_AXI_AR_rom; // Unused?
wire        S_AXI_AWVALID_rom,S_AXI_ARVALID_rom,S_AXI_WVALID_rom,S_AXI_RREADY_rom; // Unused?
wire        S_AXI_AWREADY_rom,S_AXI_ARREADY_rom,S_AXI_WREADY_rom,S_AXI_RVALID_rom,S_AXI_RLAST_rom,S_AXI_WLAST_rom; // Unused?
wire [31:0] S_AXI_R_rom; // Unused?
wire [31:0] S_AXI_W_rom; // Unused?
wire  [3:0] S_AXI_WSTRB_rom; // Unused?
wire  [1:0] S_AXI_ARBURST_rom; // Unused?
wire  [7:0] S_AXI_ARLEN_rom; // Unused?
wire  [2:0] S_AXI_ARSIZE_rom; // Unused?
wire  [1:0] S_AXI_AWBURST_rom; // Unused?
wire  [7:0] S_AXI_AWLEN_rom; // Unused?
wire  [2:0] S_AXI_AWSIZE_rom; // Unused?
wire [31:0] S_AXI_AW_net, S_AXI_AR_net; // Unused?
wire        S_AXI_AWVALID_net,S_AXI_ARVALID_net,S_AXI_WVALID_net,S_AXI_RREADY_net; // Unused?
wire        S_AXI_AWREADY_net,S_AXI_ARREADY_net,S_AXI_WREADY_net,S_AXI_RVALID_net,S_AXI_RLAST_net,S_AXI_WLAST_net; // Unused?
wire [31:0] S_AXI_R_net; // Unused?
wire [31:0] S_AXI_W_net; // Unused?
wire  [3:0] S_AXI_WSTRB_net; // Unused?
wire  [1:0] S_AXI_ARBURST_net; // Unused?
wire  [7:0] S_AXI_ARLEN_net; // Unused?
wire  [2:0] S_AXI_ARSIZE_net; // Unused?
wire  [1:0] S_AXI_AWBURST_net; // Unused?
wire  [7:0] S_AXI_AWLEN_net; // Unused?
wire  [2:0] S_AXI_AWSIZE_net; // Unused?
wire [31:0] M_IO_AXI_AW, M_IO_AXI_AR;
wire        M_IO_AXI_AWVALID,M_IO_AXI_ARVALID,M_IO_AXI_WVALID,M_IO_AXI_RREADY;
wire        M_IO_AXI_AWREADY,M_IO_AXI_ARREADY,M_IO_AXI_WREADY,M_IO_AXI_RVALID,M_IO_AXI_RLAST,M_IO_AXI_WLAST, M_IO_AXI_BREADY; // Added M_IO_AXI_BREADY
wire [31:0] M_IO_AXI_R;
wire [31:0] M_IO_AXI_W;
wire  [3:0] M_IO_AXI_WSTRB;
wire  [1:0] M_IO_AXI_ARBURST;
wire  [3:0] M_IO_AXI_ARLEN; // Width mismatch? v586 port is [7:0]
wire  [2:0] M_IO_AXI_ARSIZE;
wire  [1:0] M_IO_AXI_AWBURST;
wire  [7:0] M_IO_AXI_AWLEN;
wire  [2:0] M_IO_AXI_AWSIZE;
wire [15:0] extDBo,extDBt; // Unused?
wire  [7:0] gpioA_dir,gpioB_dir,gpioA_out,gpioB_out; // Unused?
wire [31:0] romA,romQ; // Unused?
wire int_pic,iack;
wire [7:0] ivect;
wire        clk;
wire        clk300; // Unused?
wire        dram_rst_out;
wire        ui_clk_sync_rst;
wire        init_calib_complete;
wire        rstn_ddr;
wire        locked;
wire        mmcm_locked;
wire [119:0] ddr3_ila_basic; // Unused?
wire clk200,clk_pix, clk400;
wire sdclk;
wire rstn_ddr_dft;
wire PhyRstn_dft;
wire clk_for_mii_to_rmii;
wire sdclk_dft;

// DFT Signal Muxing
// Use scan_rstn (active low) if test_mode is active
// Assuming rstn_ddr is active high based on RSTGEN input calculation
assign rstn_ddr_dft = test_mode ? ~scan_rstn : rstn_ddr;
// Assuming PhyRstn follows same polarity convention as rstn_ddr
assign PhyRstn_dft = test_mode ? ~scan_rstn : PhyRstn;
// Select primary-derived clock 'clk' in test_mode
assign clk_for_mii_to_rmii = test_mode ? clk : PhyClk50Mhz;
assign sdclk_dft = test_mode ? clk : sdclk;

assign gpio_in = 7'b0; // Corrected width
assign dbg = {rstn_ddr,init_calib_complete,mmcm_locked};

freq_man ifreq_man (
.clk_in1_p(i_100MHz_P),
.clk_in1_n(i_100MHz_N),
.clk_out1(clk400),
.clk_out2(clk200),
.clk_out3(clk_pix),
.locked(locked)
);

// Assign clk (assuming it's clk200 for main logic)
assign clk = clk200;

HDMI_test ihdmi(
.rstn(rstn), // Use primary reset
.pixclk(clk_pix),
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

// Reset generation: RST_X_I is active high, asserted when rstn is low or dram_rst_out is high
// rstn_ddr is the output reset (presumably active high)
RSTGEN rstgen(.CLK(clk), .RST_X_I(~(~rstn | dram_rst_out)), .RST_X_O(rstn_ddr));
assign dram_rst_out = (ui_clk_sync_rst | ~init_calib_complete);

v586 v586 (
.m00_AXI_RSTN(rstn_ddr_dft), // Use DFT reset mux output
.m00_AXI_CLK(clk),
.m00_AXI_AWADDR(M_AXI_AW), .m00_AXI_AWVALID(M_AXI_AWVALID), .m00_AXI_AWREADY(M_AXI_AWREADY),
.m00_AXI_AWBURST(M_AXI_AWBURST), .m00_AXI_AWLEN(M_AXI_AWLEN), .m00_AXI_AWSIZE(M_AXI_AWSIZE),
.m00_AXI_WDATA(M_AXI_W), .m00_AXI_WVALID(M_AXI_WVALID), .m00_AXI_WREADY(M_AXI_WREADY), .m00_AXI_WSTRB(M_AXI_WSTRB), .m00_AXI_WLAST(M_AXI_WLAST),
.m00_AXI_ARADDR(M_AXI_AR), .m00_AXI_ARVALID(M_AXI_ARVALID), .m00_AXI_ARREADY(M_AXI_ARREADY),
.m00_AXI_ARBURST(M_AXI_ARBURST), .m00_AXI_ARLEN(M_AXI_ARLEN), .m00_AXI_ARSIZE(M_AXI_ARSIZE),
.m00_AXI_RDATA(M_AXI_R), .m00_AXI_RVALID(M_AXI_RVALID), .m00_AXI_RREADY(M_AXI_RREADY), .m