`define simu 
`define simu 
module TOP_SYS(  
input wire test_i, // Added for DFT
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
wire [2:0] dbg;
input            i_100MHz_P,i_100MHz_N;
input            rstn;
output           TXD;
wire      [6:0] gpio_in;
output [2:0] VID_D_N,VID_D_P;
output VID_CLK_N,VID_CLK_P;
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
input            RXD;
output           sdout,sdcs;
input            sdin;
inout     [7:0]  gpioA;
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
wire        clk;
wire        clk300;
wire        dram_rst_out;
wire        ui_clk_sync_rst;
wire        init_calib_complete;
wire        rstn_