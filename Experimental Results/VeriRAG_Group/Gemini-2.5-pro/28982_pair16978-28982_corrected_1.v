`define simu
`define simu
module TOP_SYS(
  input test_i, // DFT test mode enable
  input test_clk, // DFT test clock
  input test_rst_n, // DFT test reset (active low)
  input            i_100MHz_P,
  input            i_100MHz_N,
  input            rstn, // Functional reset (active low)
  output           TXD,
  input            RXD,
  inout wire [15:0]  DDR3DQ,
  inout wire [1:0]   DDR3DQS_N,
  inout wire [1:0]   DDR3DQS_P,
  output wire [13:0] DDR3ADDR,
  output wire [2:0]  DDR3BA,
  output wire        DDR3RAS_N,
  output wire        DDR3CAS_N,
  output wire        DDR3WE_N,
  output wire        DDR3CK_P,
  output wire        DDR3CK_N,
  output wire        DDR3CKE,
  output wire        DDR3RST_N,
  output wire [1:0]  DDR3DM,
  output wire        DDR3ODT,
  input            sdin,
  output           sdout,
  output           sdcs,
  inout     [7:0]  gpioA,
  output [2:0] VID_D_N,
  output [2:0] VID_D_P,
  output VID_CLK_N,
  output VID_CLK_P
);
wire [2:0] dbg;
// Redundant declarations removed
// input            i_100MHz_P,i_100MHz_N;
// input            rstn; // Functional reset (active low)
// output           TXD;
wire      [6:0] gpio_in;
// output [2:0] VID_D_N,VID_D_P;
// output VID_CLK_N,VID_CLK_P;
// inout wire [15:0]  DDR3DQ;
// inout wire [1:0]   DDR3DQS_N;
// inout wire [1:0]   DDR3DQS_P;
// output wire [13:0] DDR3ADDR;
// output wire [2:0]  DDR3BA;
// output wire        DDR3RAS_N;
// output wire        DDR3CAS_N;
// output wire        DDR3WE_N;
// output wire        DDR3CK_P;
// output wire        DDR3CK_N;
// output wire        DDR3CKE;
// output wire        DDR3RST_N;
// output wire [1:0]  DDR3DM;
// output wire        DDR3ODT;
// input            RXD;
// output           sdout,sdcs;
// input            sdin;
// inout     [7:0]  gpioA;
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
wire PhyClk50Mhz; // Changed from reg to wire
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
wire        M_AXI_AWREADY,M_AXI_ARREADY,M_AXI_WREADY,M_AXI_RVALID,M_AXI_RLAST,M_AXI_WLAST;
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
wire        M_IO_AXI_AWREADY,M_IO_AXI_ARREADY,M_IO_AXI_WREADY,M_IO_AXI_RVALID,M_IO_AXI_RLAST,M_IO_AXI_WLAST;
wire [31:0] M_IO_AXI_R;
wire [31:0] M_IO_AXI_W;
wire  [3:0] M_IO_AXI_WSTRB;
wire  [1:0] M_IO_AXI_ARBURST;
wire  [3:0] M_IO_AXI_ARLEN;
wire  [2:0] M_IO_AXI_ARSIZE;
wire  [1:0] M_IO_AXI_AWBURST;
wire  [7:0] M_IO_AXI_AWLEN;
wire  [2:0] M_IO_AXI_AWSIZE;
wire [15:0] extDBo,extDBt;
wire  [7:0] gpioA_dir,gpioB_dir,gpioA_out,gpioB_out;
wire [31:0] romA,romQ;
wire int_pic,iack;
wire [7:0] ivect;
wire        clk; // Functional clock from DDR PHY
wire        clk400; // Clock from freq_man
wire        clk300;
wire        dram_rst_out;
wire        dram_rst_out_func;
wire        dram_rst_out_muxed;
wire        ui_clk_sync_rst; // Assuming this is generated elsewhere or an input
wire        init_calib_complete; // Assuming this comes from DDR PHY
wire        rstn_ddr; // Master reset signal (muxed)
wire        rstn_ddr_func; // Functional reset signal
wire        locked;
wire        mmcm_locked;
wire [119:0] ddr3_ila_basic;
wire clk200,clk_pix; // Clocks from freq_man
wire sdclk; // Clock from STARTUPE2
wire ddr_sys_rst; // Muxed reset for DDR PHY

// DFT Muxed Signals
wire dft_clk;
wire dft_sdclk;
wire dft_PhyClk50Mhz;
wire dft_rmii2mac_tx_clk;
wire dft_rmii2mac_rx_clk;
wire dft_clk_pix;

assign gpio_in = 0; // Placeholder
assign dbg = {rstn_ddr,init_calib_complete,mmcm_locked}; // Example debug

// DFT Clock Muxing
assign dft_clk = test_i ? test_clk : clk;
assign dft_sdclk = test_i ? test_clk : sdclk;
assign dft_PhyClk50Mhz = test_i ? test_clk : PhyClk50Mhz;
assign dft_rmii2mac_tx_clk = test_i ? test_clk : rmii2mac_tx_clk;
assign dft_rmii2mac_rx_clk = test_i ? test_clk : rmii2mac_rx_clk;
assign dft_clk_pix = test_i ? test_clk : clk_pix;

freq_man ifreq_man (
.clk_in1_p(i_100MHz_P),
.clk_in1_n(i_100MHz_N),
.clk_out1(clk400),
.clk_out2(clk200),
.clk_out3(clk_pix),
.locked(locked)
);

HDMI_test ihdmi(
.rstn(rstn_ddr), // Use muxed reset
.pixclk(dft_clk_pix), // Use muxed clock
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
   .USRCCLKO(sdclk), // Functional clock output
   .USRCCLKTS(1'b0),
   .USRDONEO(1'b1),
   .USRDONETS(1'b1)
);

// DFT Reset Generation/Muxing
// Assuming ui_clk_sync_rst is properly generated/controlled
assign dram_rst_out_func = (ui_clk_sync_rst | ~init_calib_complete);
assign dram_rst_out_muxed = test_i ? 1'b1 : dram_rst_out_func; // Force active (reset state) in test mode? Or inactive (1'b0)? Needs clarification based on reset polarity. Assuming active high reset logic downstream for this mux. If RSTGEN output is active low, this might need inversion.

// Use dft_clk for the reset synchronizer/generator
// Assuming RSTGEN generates an active-low reset signal (based on name rstn_ddr_func)
// Input RST_X_I should be active-high for RSTGEN if it expects active-high async reset input
// Let's assume RSTGEN input RST_X_I is active high async reset.
// Functional reset condition: ~rstn (active high) OR dram_rst_out_muxed (active high)
wire rstgen_input_func = ~rstn | dram_rst_out_muxed;
wire rstgen_input_test = ~test_rst_n; // Assuming test_rst_n is active low, so ~test_rst_n is active high
wire rstgen_input_muxed = test_i ? rstgen_input_test : rstgen_input_func;

RSTGEN rstgen(
    .CLK(dft_clk),          // Use muxed clock
    .RST_X_I(rstgen_input_muxed), // Muxed active-high async reset input
    .RST_X_O(rstn_ddr_func)  // Assuming this is the synchronized active-low reset output
);

// Mux the final reset signal for all downstream logic
// rstn_ddr should be active low
assign rstn_ddr = test_i ? test_rst_n : rstn_ddr_func; // Select test reset or functional reset

// Mux reset for DDR PHY sys_rst input
// Assuming DDR PHY sys_rst input is active high
// Functional reset condition: ~locked (active high when not locked)
// Test reset condition: ~test_rst_n (active high)
assign ddr_sys_rst = test_i ? ~test_rst_n : ~locked;


// NOTE: The rest of the module instantiations (CPU, DDR PHY, AXI Interconnects, Peripherals etc.)
// are assumed to be present here, connecting to the declared wires and using the
// muxed clocks (dft_*) and resets (rstn_ddr, ddr_sys_rst) appropriately.
// Without the full code, complete DFT verification is not possible.


endmodule