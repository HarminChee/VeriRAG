module parallella_7020_top (
   processing_system7_0_DDR_WEB_pin, GPIO12_P, GPIO12_N, GPIO13_P,
   GPIO13_N, GPIO14_P, GPIO14_N, GPIO15_P, GPIO15_N, GPIO16_P,
   GPIO16_N, GPIO17_P, GPIO17_N, GPIO18_P, GPIO18_N, GPIO19_P,
   GPIO19_N, GPIO20_P, GPIO20_N, GPIO21_P, GPIO21_N, GPIO22_P,
   GPIO22_N, GPIO23_P, GPIO23_N, RXI_DATA0_P, RXI_DATA1_P,
   RXI_DATA2_P, RXI_DATA3_P, RXI_DATA4_P, RXI_DATA5_P, RXI_DATA6_P,
   RXI_DATA7_P, RXI_DATA0_N, RXI_DATA1_N, RXI_DATA2_N, RXI_DATA3_N,
   RXI_DATA4_N, RXI_DATA5_N, RXI_DATA6_N, RXI_DATA7_N, RXI_FRAME_P,
   RXI_FRAME_N, RXI_LCLK_P, RXI_LCLK_N, TXI_WR_WAIT_P, TXI_WR_WAIT_N,
   TXI_RD_WAIT_P, TXI_RD_WAIT_N, RXI_CCLK_P, RXI_CCLK_N, DSP_RESET_N,
   processing_system7_0_MIO, processing_system7_0_DDR_Clk,
   processing_system7_0_DDR_Clk_n, processing_system7_0_DDR_CKE,
   processing_system7_0_DDR_CS_n, processing_system7_0_DDR_RAS_n,
   processing_system7_0_DDR_CAS_n, processing_system7_0_DDR_BankAddr,
   processing_system7_0_DDR_Addr, processing_system7_0_DDR_ODT,
   processing_system7_0_DDR_DRSTB, processing_system7_0_DDR_DQ,
   processing_system7_0_DDR_DM, processing_system7_0_DDR_DQS,
   processing_system7_0_DDR_DQS_n, processing_system7_0_DDR_VRN,
   processing_system7_0_DDR_VRP,
   processing_system7_0_PS_SRSTB_pin, processing_system7_0_PS_CLK_pin,
   processing_system7_0_PS_PORB_pin, GPIO0_P, GPIO0_N, GPIO1_P,
   GPIO1_N, GPIO2_P, GPIO2_N, GPIO3_P, GPIO3_N, GPIO4_P, GPIO4_N,
   GPIO5_P, GPIO5_N, GPIO6_P, GPIO6_N, GPIO7_P, GPIO7_N, GPIO8_P,
   GPIO8_N, GPIO9_P, GPIO9_N, GPIO10_P, GPIO10_N, GPIO11_P, GPIO11_N,
   TXO_DATA0_P, TXO_DATA1_P, TXO_DATA2_P, TXO_DATA3_P, TXO_DATA4_P,
   TXO_DATA5_P, TXO_DATA6_P, TXO_DATA7_P, TXO_DATA0_N, TXO_DATA1_N,
   TXO_DATA2_N, TXO_DATA3_N, TXO_DATA4_N, TXO_DATA5_N, TXO_DATA6_N,
   TXO_DATA7_N, TXO_FRAME_P, TXO_FRAME_N, TXO_LCLK_P, TXO_LCLK_N,
   RXO_WR_WAIT_P, RXO_WR_WAIT_N, RXO_RD_WAIT_P, RXO_RD_WAIT_N,
   DSP_FLAG,
   HDMI_D23, HDMI_D22, HDMI_D21, HDMI_D20, HDMI_D19, HDMI_D18, HDMI_D17,
   HDMI_D16, HDMI_D15, HDMI_D14, HDMI_D13, HDMI_D12, HDMI_D11, HDMI_D10,
   HDMI_D9, HDMI_D8, HDMI_CLK, HDMI_HSYNC, HDMI_VSYNC, HDMI_DE, PS_I2C_SCL,
   PS_I2C_SDA,
   // DFT Ports
   scan_enable,
   test_clk
   );
   parameter SIDW = 12;
   parameter SAW  = 32;
   parameter SDW  = 32;
   parameter MIDW = 6;
   parameter MAW  = 32;
   parameter MDW  = 64;
   parameter STW  = 8;
   parameter DPW  = 20;
   inout [53:0] processing_system7_0_MIO;
   input 	processing_system7_0_PS_SRSTB_pin;
   input 	processing_system7_0_PS_CLK_pin;
   input 	processing_system7_0_PS_PORB_pin;
   inout 	processing_system7_0_DDR_Clk;
   inout 	processing_system7_0_DDR_Clk_n;
   inout 	processing_system7_0_DDR_CKE;
   inout 	processing_system7_0_DDR_CS_n;
   inout 	processing_system7_0_DDR_RAS_n;
   inout 	processing_system7_0_DDR_CAS_n;
   output 	processing_system7_0_DDR_WEB_pin;
   inout [2:0] 	processing_system7_0_DDR_BankAddr;
   inout [14:0] processing_system7_0_DDR_Addr;
   inout 	processing_system7_0_DDR_ODT;
   inout 	processing_system7_0_DDR_DRSTB;
   inout [31:0] processing_system7_0_DDR_DQ;
   inout [3:0] 	processing_system7_0_DDR_DM;
   inout [3:0] 	processing_system7_0_DDR_DQS;
   inout [3:0] 	processing_system7_0_DDR_DQS_n;
   inout 	processing_system7_0_DDR_VRN;
   inout 	processing_system7_0_DDR_VRP;
   output 	HDMI_D23;
   output 	HDMI_D22;
   output 	HDMI_D21;
   output 	HDMI_D20;
   output 	HDMI_D19;
   output 	HDMI_D18;
   output 	HDMI_D17;
   output 	HDMI_D16;
   output 	HDMI_D15;
   output 	HDMI_D14;
   output 	HDMI_D13;
   output 	HDMI_D12;
   output 	HDMI_D11;
   output 	HDMI_D10;
   output 	HDMI_D9;
   output 	HDMI_D8;
   output 	HDMI_CLK;
   output 	HDMI_HSYNC;
   output 	HDMI_VSYNC;
   output 	HDMI_DE;
   inout 	PS_I2C_SCL;
   inout 	PS_I2C_SDA;
   input 	GPIO0_P;
   input 	GPIO0_N;
   input 	GPIO1_P;
   input 	GPIO1_N;
   input 	GPIO2_P;
   input 	GPIO2_N;
   input 	GPIO3_P;
   input 	GPIO3_N;
   input 	GPIO4_P;
   input 	GPIO4_N;
   input 	GPIO5_P;
   input 	GPIO5_N;
   input 	GPIO6_P;
   input 	GPIO6_N;
   input 	GPIO7_P;
   input 	GPIO7_N;
   input 	GPIO8_P;
   input 	GPIO8_N;
   input 	GPIO9_P;
   input 	GPIO9_N;
   input 	GPIO10_P;
   input 	GPIO10_N;
   input 	GPIO11_P;
   input 	GPIO11_N;
   output 	GPIO12_P;
   output 	GPIO12_N;
   output 	GPIO13_P;
   output 	GPIO13_N;
   output 	GPIO14_P;
   output 	GPIO14_N;
   output 	GPIO15_P;
   output 	GPIO15_N;
   output 	GPIO16_P;
   output 	GPIO16_N;
   output 	GPIO17_P;
   output 	GPIO17_N;
   output 	GPIO18_P;
   output 	GPIO18_N;
   output 	GPIO19_P;
   output 	GPIO19_N;
   output 	GPIO20_P;
   output 	GPIO20_N;
   output 	GPIO21_P;
   output 	GPIO21_N;
   output 	GPIO22_P;
   output 	GPIO22_N;
   output 	GPIO23_P;
   output 	GPIO23_N;
   input 	TXO_DATA0_P;
   input 	TXO_DATA1_P;
   input 	TXO_DATA2_P;
   input 	TXO_DATA3_P;
   input 	TXO_DATA4_P;
   input 	TXO_DATA5_P;
   input 	TXO_DATA6_P;
   input 	TXO_DATA7_P;
   input 	TXO_DATA0_N;
   input 	TXO_DATA1_N;
   input 	TXO_DATA2_N;
   input 	TXO_DATA3_N;
   input 	TXO_DATA4_N;
   input 	TXO_DATA5_N;
   input 	TXO_DATA6_N;
   input 	TXO_DATA7_N;
   input 	TXO_FRAME_P;
   input 	TXO_FRAME_N;
   input 	TXO_LCLK_P;
   input 	TXO_LCLK_N;
   input 	RXO_WR_WAIT_P;
   input 	RXO_WR_WAIT_N;
   input 	RXO_RD_WAIT_P;
   input 	RXO_RD_WAIT_N;
   output 	RXI_DATA0_P;
   output 	RXI_DATA1_P;
   output 	RXI_DATA2_P;
   output 	RXI_DATA3_P;
   output 	RXI_DATA4_P;
   output 	RXI_DATA5_P;
   output 	RXI_DATA6_P;
   output 	RXI_DATA7_P;
   output 	RXI_DATA0_N;
   output 	RXI_DATA1_N;
   output 	RXI_DATA2_N;
   output 	RXI_DATA3_N;
   output 	RXI_DATA4_N;
   output 	RXI_DATA5_N;
   output 	RXI_DATA6_N;
   output 	RXI_DATA7_N;
   output 	RXI_FRAME_P;
   output 	RXI_FRAME_N;
   output 	RXI_LCLK_P;
   output 	RXI_LCLK_N;
   output 	TXI_WR_WAIT_P;
   output 	TXI_WR_WAIT_N;
   output 	TXI_RD_WAIT_P;
   output 	TXI_RD_WAIT_N;
   output 	RXI_CCLK_P;
   output 	RXI_CCLK_N;
   output 	DSP_RESET_N;
   input 	DSP_FLAG;
   // DFT Ports
   input        scan_enable;
   input        test_clk;

   wire			cactive;
   wire			csysack;
   wire			processing_system7_0_FCLK_CLK0_pin;
   wire			processing_system7_0_FCLK_CLK3_pin;
   wire [31:0]		processing_system7_0_M_AXI_GP1_ARADDR_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_ARBURST_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_ARCACHE_pin;
   wire			processing_system7_0_M_AXI_GP1_ARESETN_pin;
   wire [11:0]		processing_system7_0_M_AXI_GP1_ARID_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_ARLEN_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_ARLOCK_pin;
   wire [2:0]		processing_system7_0_M_AXI_GP1_ARPROT_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_ARQOS_pin;
   wire			processing_system7_0_M_AXI_GP1_ARREADY_pin;
   wire [2:0]		processing_system7_0_M_AXI_GP1_ARSIZE_pin;
   wire			processing_system7_0_M_AXI_GP1_ARVALID_pin;
   wire [31:0]		processing_system7_0_M_AXI_GP1_AWADDR_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_AWBURST_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_AWCACHE_pin;
   wire [11:0]		processing_system7_0_M_AXI_GP1_AWID_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_AWLEN_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_AWLOCK_pin;
   wire [2:0]		processing_system7_0_M_AXI_GP1_AWPROT_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_AWQOS_pin;
   wire			processing_system7_0_M_AXI_GP1_AWREADY_pin;
   wire [2:0]		processing_system7_0_M_AXI_GP1_AWSIZE_pin;
   wire			processing_system7_0_M_AXI_GP1_AWVALID_pin;
   wire [SIDW-1:0]	processing_system7_0_M_AXI_GP1_BID_pin;
   wire			processing_system7_0_M_AXI_GP1_BREADY_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_BRESP_pin;
   wire			processing_system7_0_M_AXI_GP1_BVALID_pin;
   wire [SDW-1:0]	processing_system7_0_M_AXI_GP1_RDATA_pin;
   wire [SIDW-1:0]	processing_system7_0_M_AXI_GP1_RID_pin;
   wire			processing_system7_0_M_AXI_GP1_RLAST_pin;
   wire			processing_system7_0_M_AXI_GP1_RREADY_pin;
   wire [1:0]		processing_system7_0_M_AXI_GP1_RRESP_pin;
   wire			processing_system7_0_M_AXI_GP1_RVALID_pin;
   wire [31:0]		processing_system7_0_M_AXI_GP1_WDATA_pin;
   wire [11:0]		processing_system7_0_M_AXI_GP1_WID_pin;
   wire			processing_system7_0_M_AXI_GP1_WLAST_pin;
   wire			processing_system7_0_M_AXI_GP1_WREADY_pin;
   wire [3:0]		processing_system7_0_M_AXI_GP1_WSTRB_pin;
   wire			processing_system7_0_M_AXI_GP1_WVALID_pin;
   wire [MAW-1:0]	processing_system7_0_S_AXI_HP1_ARADDR_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_ARBURST_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_ARCACHE_pin;
   wire			processing_system7_0_S_AXI_HP1_ARESETN_pin;
   wire [MIDW-1:0]	processing_system7_0_S_AXI_HP1_ARID_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_ARLEN_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_ARLOCK_pin;
   wire [2:0]		processing_system7_0_S_AXI_HP1_ARPROT_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_ARQOS_pin;
   wire			processing_system7_0_S_AXI_HP1_ARREADY_pin;
   wire [2:0]		processing_system7_0_S_AXI_HP1_ARSIZE_pin;
   wire			processing_system7_0_S_AXI_HP1_ARVALID_pin;
   wire [MAW-1:0]	processing_system7_0_S_AXI_HP1_AWADDR_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_AWBURST_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_AWCACHE_pin;
   wire [MIDW-1:0]	processing_system7_0_S_AXI_HP1_AWID_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_AWLEN_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_AWLOCK_pin;
   wire [2:0]		processing_system7_0_S_AXI_HP1_AWPROT_pin;
   wire [3:0]		processing_system7_0_S_AXI_HP1_AWQOS_pin;
   wire			processing_system7_0_S_AXI_HP1_AWREADY_pin;
   wire [2:0]		processing_system7_0_S_AXI_HP1_AWSIZE_pin;
   wire			processing_system7_0_S_AXI_HP1_AWVALID_pin;
   wire [5:0]		processing_system7_0_S_AXI_HP1_BID_pin;
   wire			processing_system7_0_S_AXI_HP1_BREADY_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_BRESP_pin;
   wire			processing_system7_0_S_AXI_HP1_BVALID_pin;
   wire [63:0]		processing_system7_0_S_AXI_HP1_RDATA_pin;
   wire [5:0]		processing_system7_0_S_AXI_HP1_RID_pin;
   wire			processing_system7_0_S_AXI_HP1_RLAST_pin;
   wire			processing_system7_0_S_AXI_HP1_RREADY_pin;
   wire [1:0]		processing_system7_0_S_AXI_HP1_RRESP_pin;
   wire			processing_system7_0_S_AXI_HP1_RVALID_pin;
   wire [MDW-1:0]	processing_system7_0_S_AXI_HP1_WDATA_pin;
   wire [MIDW-1:0]	processing_system7_0_S_AXI_HP1_WID_pin;
   wire			processing_system7_0_S_AXI_HP1_WLAST_pin;
   wire			processing_system7_0_S_AXI_HP1_WREADY_pin;
   wire [STW-1:0]	processing_system7_0_S_AXI_HP1_WSTRB_pin;
   wire			processing_system7_0_S_AXI_HP1_WVALID_pin;
   wire			reset_chip;
   wire			reset_fpga;
   reg [19:0]    por_cnt;
   reg           por_reset;
   reg [1:0] 	 user_pb_clean_reg;
   reg [31:0]    counter_reg;
   wire 	 sys_clk;
   wire 	 dft_clk; // Clock used for DFT-friendly flip-flops
   wire 	 esaxi_areset;
   wire 	 fpga_reset;
   wire 	 pbr_reset;
   wire [1:0] 	 user_pb_clean;
   wire 	 user_pb7_pulse;
   wire [15:0] 	 hdmi_data;
   wire 	 hdmi_clk;
   wire 	 hdmi_hsync;
   wire 	 hdmi_vsync;
   wire 	 hdmi_data_e;
   wire 	 hdmi_spdif;
   wire 	 hdmi_int;
   wire [7:0] 	 rxi_data_p;
   wire [7:0] 	 rxi_data_n;
   wire 	 rxi_frame_p;
   wire 	 rxi_frame_n;
   wire 	 rxi_lclk_p;
   wire 	 rxi_lclk_n;
   wire 	 txo_wr_wait_p;
   wire 	 txo_wr_wait_n;
   wire 	 txo_rd_wait_p;
   wire 	 txo_rd_wait_n;
   wire [7:0] 	 txo_data_p;
   wire [7:0]    txo_data_n;
   wire 	 txo_frame_p;
   wire 	 txo_frame_n;
   wire 	 txo_lclk_p;
   wire 	 txo_lclk_n;
   wire 	 rxi_wr_wait_p;
   wire 	 rxi_wr_wait_n;
   wire 	 rxi_rd_wait_p;
   wire 	 rxi_rd_wait_n;
   wire 	 aafm_resetn;
   wire [7:0] 	 user_led;
   wire [1:0] 	 user_pb;
   wire [11:0] 	 gpio_in;
   wire [23:0] 	 GPIO_P;
   wire [23:0] 	 GPIO_N;
   wire 	 SD1_WPn;

   // Select between functional clock and test clock based on scan_enable
   assign dft_clk = scan_enable ? test_clk : sys_clk;

   assign GPIO_P[0]  = GPIO0_P;
   assign GPIO_N[0]  = GPIO0_N;
   assign GPIO_P[1]  = GPIO1_P;
   assign GPIO_N[1]  = GPIO1_N;
   assign GPIO_P[2]  = GPIO2_P;
   assign GPIO_N[2]  = GPIO2_N;
   assign GPIO_P[3]  = GPIO3_P;
   assign GPIO_N[3]  = GPIO3_N;
   assign GPIO_P[4]  = GPIO4_P;
   assign GPIO_N[4]  = GPIO4_N;
   assign GPIO_P[5]  = GPIO5_P;
   assign GPIO_N[5]  = GPIO5_N;
   assign GPIO_P[6]  = GPIO6_P;
   assign GPIO_N[6]  = GPIO6_N;
   assign GPIO_P[7]  = GPIO7_P;
   assign GPIO_N[7]  = GPIO7_N;
   assign GPIO_P[8]  = GPIO8_P;
   assign GPIO_N[8]  = GPIO8_N;
   assign GPIO_P[9]  = GPIO9_P;
   assign GPIO_N[9]  = GPIO9_N;
   assign GPIO_P[10] = GPIO10_P;
   assign GPIO_N[10] = GPIO10_N;
   assign GPIO_P[11] = GPIO11_P;
   assign GPIO_N[11] = GPIO11_N;
   genvar 	 gpin_cnt;
   generate
      for (gpin_cnt = 0; gpin_cnt < 12; gpin_cnt = gpin_cnt + 1) begin: gpins
	 IBUFDS
	   #(.DIFF_TERM  ("TRUE"),
           .IOSTANDARD ("LVDS_25"))
	 gpin_inst
	   (.I     (GPIO_P[gpin_cnt]),
           .IB     (GPIO_N[gpin_cnt]),
           .O      (gpio_in[gpin_cnt]));
      end
   endgenerate
   assign GPIO12_P = GPIO_P[12];
   assign GPIO12_N = GPIO_N[12];
   assign GPIO13_P = GPIO_P[13];
   assign GPIO13