`define NET0
`define NET1
`define NET2
`define NET3
`define NET0
`define NET1
`define NET2
`define NET3
module DE4_Reference_Router(
	GCLKIN,
	GCLKOUT_FPGA,
	OSC_50_BANK2,
	OSC_50_BANK3,
	OSC_50_BANK4,
	OSC_50_BANK5,
	OSC_50_BANK6,
	OSC_50_BANK7,
	PLL_CLKIN_p,
	MAX_I2C_SCLK,
	MAX_I2C_SDAT,
	LED,
	BUTTON,
	CPU_RESET_n,
	EXT_IO,
	SW,
	SLIDE_SW,
	SEG0_D,
	SEG0_DP,
	SEG1_D,
	SEG1_DP,
	TEMP_INT_n,
	TEMP_SMCLK,
	TEMP_SMDAT,
	CSENSE_ADC_FO,
	CSENSE_CS_n,
	CSENSE_SCK,
	CSENSE_SDI,
	CSENSE_SDO,
	PCIE_PREST_n,
	PCIE_REFCLK_p,
	PCIE_RX_p,
	PCIE_SMBCLK,
	PCIE_SMBDAT,
	PCIE_TX_p,
	PCIE_WAKE_n,
	FAN_CTRL,
	EEP_SCL,
	EEP_SDA,
	SD_CLK,
	SD_CMD,
	SD_DAT,
	SD_WP_n,
	UART_CTS,
	UART_RTS,
	UART_RXD,
	UART_TXD,
	ETH_INT_n,
	ETH_MDC,
	ETH_MDIO,
	ETH_RST_n,
	ETH_RX_p,
	ETH_TX_p,
	FLASH_ADV_n,
	FLASH_CLK,
	FLASH_RESET_n,
	FLASH_RYBY_n,
	SSRAM_ADV,
	SSRAM_BWA_n,
	SSRAM_BWB_n,
	SSRAM_CE_n,
	SSRAM_CKE_n,
	SSRAM_CLK,
	SSRAM_OE_n,
	SSRAM_WE_n 
);
input		          		GCLKIN;
output		          		GCLKOUT_FPGA;
input		          		OSC_50_BANK2;
input		          		OSC_50_BANK3;
input		          		OSC_50_BANK4;
input		          		OSC_50_BANK5;
input		          		OSC_50_BANK6;
input		          		OSC_50_BANK7;
input		          		PLL_CLKIN_p;
output		          		MAX_I2C_SCLK;
inout		          		MAX_I2C_SDAT;
output		     [7:0]		LED;
input		     [3:0]		BUTTON;
input		          		CPU_RESET_n;
inout		          		EXT_IO;
input		     [7:0]		SW;
input		     [3:0]		SLIDE_SW;
output		     [6:0]		SEG0_D;
output		          		SEG0_DP;
output		     [6:0]		SEG1_D;
output		          		SEG1_DP;
input		          		TEMP_INT_n;
output		          		TEMP_SMCLK;
inout		          		TEMP_SMDAT;
output		          		CSENSE_ADC_FO;
output		     [1:0]		CSENSE_CS_n;
output		          		CSENSE_SCK;
output		          		CSENSE_SDI;
input		          		CSENSE_SDO;
input		          	PCIE_PREST_n;
input		          	PCIE_REFCLK_p;
input						PCIE_RX_p;
input		          	PCIE_SMBCLK;
inout		          	PCIE_SMBDAT;
output					PCIE_TX_p;
output		         PCIE_WAKE_n;
output		          		FAN_CTRL;
output		          		EEP_SCL;
inout		          		EEP_SDA;
output		          		SD_CLK;
inout		          		SD_CMD;
inout		     [3:0]		SD_DAT;
input		          		SD_WP_n;
output		          		UART_CTS;
input		          		UART_RTS;
input		          		UART_RXD;
output		          		UART_TXD;
input		     [3:0]		ETH_INT_n;
output		     [3:0]		ETH_MDC;
inout		     [3:0]		ETH_MDIO;
output		          		ETH_RST_n;
input		     [3:0]		ETH_RX_p;
output		     [3:0]		ETH_TX_p;
output		          		FLASH_ADV_n;
output		          		FLASH_CLK;
output		          		FLASH_RESET_n;
input		          		FLASH_RYBY_n;
output		          		SSRAM_ADV;
output		          		SSRAM_BWA_n;
output		          		SSRAM_BWB_n;
output		          		SSRAM_CE_n;
output		          		SSRAM_CKE_n;
output		          		SSRAM_CLK;
output		          		SSRAM_OE_n;
output		          		SSRAM_WE_n;
wire						global_reset_n;
wire						enet_reset_n;
wire						enet_mdc0;
wire						enet_mdio_in0;
wire						enet_mdio_oen0;
wire						enet_mdio_out0;
wire						enet_refclk_125MHz;
wire						lvds_rxp0;
wire						lvds_txp0;
wire						enet_mdc1;
wire						enet_mdio_in1;
wire						enet_mdio_oen1;
wire						enet_mdio_out1;
wire						lvds_rxp1;
wire						lvds_txp1;
wire						enet_mdc2;
wire						enet_mdio_in2;
wire						enet_mdio_oen2;
wire						enet_mdio_out2;
wire						lvds_rxp2;
wire						lvds_txp2;
wire						enet_mdc3;
wire						enet_mdio_in3;
wire						enet_mdio_oen3;
wire						enet_mdio_out3;
wire						lvds_rxp3;
wire						lvds_txp3;
wire [ 3: 0] clk1_set_wr, clk2_set_wr, clk3_set_wr;
wire         rstn;
wire         conf_ready;
wire         counter_max;
wire  [7:0]  counter_inc;
reg   [7:0]  auto_set_counter;
reg          conf_wr;
assign clk1_set_wr = 4'd4; 
assign clk2_set_wr = 4'd4; 
assign clk3_set_wr = 4'd4; 
assign rstn = CPU_RESET_n;
assign counter_max = &auto_set_counter;
assign counter_inc = auto_set_counter + 1'b1;
always @(posedge OSC_50_BANK2 or negedge rstn)
	if(!rstn)
	begin
		auto_set_counter <= 0;
		conf_wr <= 0;
	end 
	else if (counter_max)
		conf_wr <= 1;
	else
		auto_set_counter <= counter_inc;
ext_pll_ctrl ext_pll_ctrl_Inst(
	.osc_50(OSC_50_BANK2), 
	.rstn(rstn),
	.clk1_set_wr(clk1_set_wr),
	.clk1_set_rd(),
	.clk2_set_wr(clk2_set_wr),
	.clk2_set_rd(),
	.clk3_set_wr(clk3_set_wr),
	.clk3_set_rd(),
	.conf_wr(conf_wr), 
	.conf_rd(), 
	.conf_ready(conf_ready),
	.max_sclk(MAX_I2C_SCLK),
	.max_sdat(MAX_I2C_SDAT)
);
assign	ETH_RST_n			= enet_reset_n;
`ifdef NET0
assign	lvds_rxp0			= ETH_RX_p[0];
assign	ETH_TX_p[0]			= lvds_txp0;
assign	enet_mdio_in0		= ETH_MDIO[0];
assign	ETH_MDIO[0]			= !enet_mdio_oen0 ? enet_mdio_out0 : 1'bz;
assign	ETH_MDC[0]			= enet_mdc0;
`endif
`ifdef NET1
assign	lvds_rxp1			= ETH_RX_p[1];
assign	ETH_TX_p[1]			= lvds_txp1;
assign	enet_mdio_in1		= ETH_MDIO[1];
assign	ETH_MDIO[1]			= !enet_mdio_oen1 ? enet_mdio_out1 : 1'bz;
assign	ETH_MDC[1]			= enet_mdc1;
`endif
`ifdef NET2
assign	lvds_rxp2			= ETH_RX_p[2];
assign	ETH_TX_p[2]			= lvds_txp2;
assign	enet_mdio_in2		= ETH_MDIO[2];
assign	ETH_MDIO[2]			= !enet_mdio_oen2 ? enet_mdio_out2 : 1'bz;
assign	ETH_MDC[2]			= enet_mdc2;
`endif
`ifdef NET3
assign	lvds_rxp3			= ETH_RX_p[3];
assign	ETH_TX_p[3]			= lvds_txp3;
assign	enet_mdio_in3		= ETH_MDIO[3];
assign	ETH_MDIO[3]			= !enet_mdio_oen3 ? enet_mdio_out3 : 1'bz;
assign	ETH_MDC[3]			= enet_mdc3;
`endif
assign	FLASH_ADV_n		= 1'b0;					
assign	FLASH_CLK		= 1'b0;					
assign	FLASH_RESET_n	= global_reset_n;
assign	FAN_CTRL	= 1'bz;	
pll_125 pll_125_ins (
				.inclk0(OSC_50_BANK3),
				.c0(enet_refclk_125MHz)
				);
gen_reset_n	system_gen_reset_n (
				.tx_clk(OSC_50_BANK3),
				.reset_n_in(CPU_RESET_n),
				.reset_n_out(global_reset_n)
				);
gen_reset_n	net_gen_reset_n(
				.tx_clk(OSC_50_BANK3),
				.reset_n_in(global_reset_n),
				.reset_n_out(enet_reset_n)
				);
wire 	[39:0]			test_in;
wire	[8:0]				test_out;
wire 						busy;
wire	[16 : 0]			reconfig_fromgxb;
wire	[3 : 0]			reconfig_togxb;
wire 						PCIE_RX_p_wire;
wire 						PCIE_TX_p_wire;
wire 						pipe_mode_pcie_compiler_0;
wire 						phystatus_ext_pcie_compiler_0;	
	assign test_in[39 : 12] = 0;
	assign test_in[11: 8] = 4'b0000;
	assign test_in[7 : 6] = 2'b10;
	assign test_in[5] = 1'b0;
	assign test_in[4 : 0] = 5'b01000;
	assign pipe_mode_pcie_compiler_0 = 0;
	assign phystatus_ext_pcie_compiler_0 = 0;	
	wire reconfig_clk;
	wire fixed_clk;
	wire pll_locked;
reconfig_pll	reconfig_pll_inst (
	.inclk0 ( GCLKIN ),
	.c0 ( reconfig_clk ),
	.c1 ( fixed_clk ),
	.locked ( pll_locked )
	);
	altgx_reconfig	altgx_reconfig_inst (
	.offset_cancellation_reset ( !pll_locked ),
	.reconfig_clk ( reconfig_clk ),
	.reconfig_fromgxb(reconfig_fromgxb),
	.busy(busy),
	.reconfig_togxb(reconfig_togxb)
	);
 DE4_SOPC  SOPC_INST(
                   .ext_clk(enet_refclk_125MHz),
                   .pll_peripheral_clk(),
                   .pll_sys_clk(),
                   .reset_n(global_reset_n),
                   .cal_blk_clk_0(reconfig_clk),
                   .out_port_from_the_led_pio({dummy_LED,LED[6:0]}),
                   .in_port_to_the_pb_pio(BUTTON),
                   .user_sw_to_the_ethernet_port_interface_0(SLIDE_SW[0]),
						 .protocol_to_the_ethernet_port_interface_0(SLIDE_SW[1]),
                   .out_port_from_the_seven_seg_pio({SEG1_DP,SEG1_D[6:0],SEG0_DP,SEG0_D[6:0]}),
                   .in_port_to_the_sw_pio(SW),
                     .busy_altgxb_reconfig_pcie_compiler_0(busy),
                     .fixedclk_serdes_pcie_compiler_0(fixed_clk),
                     .gxb_powerdown_pcie_compiler_0({~PCIE_PREST_n}),
                     .pcie_rstn_pcie_compiler_0(PCIE_PREST_n),
                     .pll_powerdown_pcie_compiler_0({~PCIE_PREST_n}),
                     .reconfig_fromgxb_pcie_compiler_0(reconfig_fromgxb),
                     .reconfig_togxb_pcie_compiler_0(reconfig_togxb),
                     .refclk_pcie_compiler_0(PCIE_REFCLK_p),
                     .rx_in0_pcie_compiler_0(PCIE_RX_p_wire),   
                     .test_in_pcie_compiler_0(test_in),
                     .test_out_pcie_compiler_0(test_out),
                     .tx_out0_pcie_compiler_0(PCIE_TX_p_wire),
							.reconfig_clk_pcie_compiler_0(reconfig_clk),
							.pipe_mode_pcie_compiler_0(pipe_mode_pcie_compiler_0),
							.phystatus_ext_pcie_compiler_0(phystatus_ext_pcie_compiler_0),
                   .led_an_from_the_tse_mac(led_an_from_the_tse_mac),
                   .led_char_err_from_the_tse_mac(led_char_err_from_the_tse_mac),
                   .led_col_from_the_tse_mac(led_col_from_the_tse_mac),
                   .led_crs_from_the_tse_mac(led_crs_from_the_tse_mac),
                   .led_disp_err_from_the_tse_mac(led_disp_err_from_the_tse_mac),
                   .led_link_from_the_tse_mac(led_link_from_the_tse_mac),
                   .mdc_from_the_tse_mac(enet_mdc0),
                   .mdio_in_to_the_tse_mac(enet_mdio_in0),
                   .mdio_oen_from_the_tse_mac(enet_mdio_oen0),
                   .mdio_out_from_the_tse_mac(enet_mdio_out0),
                   .ref_clk_to_the_tse_mac(enet_refclk_125MHz),
                   .rxp_to_the_tse_mac(lvds_rxp0),
                   .txp_from_the_tse_mac(lvds_txp0),
                   .led_an_from_the_tse_mac1(),
                   .led_char_err_from_the_tse_mac1(),
                   .led_col_from_the_tse_mac1(),
                   .led_crs_from_the_tse_mac1(),
                   .led_disp_err_from_the_tse_mac1(),
                   .led_link_from_the_tse_mac1(),
                   .mdc_from_the_tse_mac1(enet_mdc1),
                   .mdio_in_to_the_tse_mac1(enet_mdio_in1),
                   .mdio_oen_from_the_tse_mac1(enet_mdio_oen1),
                   .mdio_out_from_the_tse_mac1(enet_mdio_out1),
                   .ref_clk_to_the_tse_mac1(enet_refclk_125MHz),
                   .rxp_to_the_tse_mac1(lvds_rxp1),
                   .txp_from_the_tse_mac1(lvds_txp1),
                   .led_an_from_the_tse_mac2(),
                   .led_char_err_from_the_tse_mac2(),
                   .led_col_from_the_tse_mac2(),
                   .led_crs_from_the_tse_mac2(),
                   .led_disp_err_from_the_tse_mac2(),
                   .led_link_from_the_tse_mac2(),
                   .mdc_from_the_tse_mac2(enet_mdc2),
                   .mdio_in_to_the_tse_mac2(enet_mdio_in2),
                   .mdio_oen_from_the_tse_mac2(enet_mdio_oen2),
                   .mdio_out_from_the_tse_mac2(enet_mdio_out2),
                   .ref_clk_to_the_tse_mac2(enet_refclk_125MHz),
                   .rxp_to_the_tse_mac2(lvds_rxp2),
                   .txp_from_the_tse_mac2(lvds_txp2),
                   .led_an_from_the_tse_mac3(),
                   .led_char_err_from_the_tse_mac3(),
                   .led_col_from_the_tse_mac3(),
                   .led_crs_from_the_tse_mac3(),
                   .led_disp_err_from_the_tse_mac3(),
                   .led_link_from_the_tse_mac3(),
                   .mdc_from_the_tse_mac3(enet_mdc3),
                   .mdio_in_to_the_tse_mac3(enet_mdio_in3),
                   .mdio_oen_from_the_tse_mac3(enet_mdio_oen3),
                   .mdio_out_from_the_tse_mac3(enet_mdio_out3),
                   .ref_clk_to_the_tse_mac3(enet_refclk_125MHz),
                   .rxp_to_the_tse_mac3(lvds_rxp3),
                   .txp_from_the_tse_mac3(lvds_txp3)
                );	
assign PCIE_RX_p_wire = PCIE_RX_p;
assign PCIE_TX_p = PCIE_TX_p_wire;	
reg	[31:0]		count;
assign	LED[7] = count[21];
always @ (negedge global_reset_n or posedge OSC_50_BANK3)
begin
	if (!global_reset_n) begin
		count	<= 0;
	end
	else begin
		count	<= count + 1;
	end
end
endmodule
