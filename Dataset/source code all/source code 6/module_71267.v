module radio_bridge_ratechangefilter_4x_2ch_cw (
  clk,
  ce,
  decfiltbypass,
  interpfiltbypass,
  interp_en,
  rx_i,
  rx_i_fullrate,
  rx_q,
  rx_q_fullrate,
  tx_i,
  tx_i_fullrate,
  tx_q,
  tx_q_fullrate
);
	input	clk;
	input	ce;
	input	decfiltbypass;
	input	interpfiltbypass;
	input	interp_en;
	input	[13:0] rx_i_fullrate;
	input	[13:0] rx_q_fullrate;
	input	[15:0] tx_i;
	input	[15:0] tx_q;
	output	[13:0] rx_i;
	output	[13:0] rx_q;
	output	[15:0] tx_i_fullrate;
	output	[15:0] tx_q_fullrate;
endmodule
module radio_bridge
(
	converter_clock_in,
	converter_clock_out,
	user_RSSI_ADC_clk,
	radio_RSSI_ADC_clk,
	user_RSSI_ADC_D,
	user_EEPROM_IO_T,
	user_EEPROM_IO_O,
	user_EEPROM_IO_I,
	user_TxModelStart,
	radio_EEPROM_IO,
	radio_DAC_I,
	radio_DAC_Q,
	radio_ADC_I,
	radio_ADC_Q,
	user_DAC_I,
	user_DAC_Q,
	user_ADC_I,
	user_ADC_Q,
	radio_B,
	user_Tx_gain,
	user_RxBB_gain,
	user_RxRF_gain,
	user_SHDN_external,
	user_RxEn_external,
	user_TxEn_external,
	user_RxHP_external,
	controller_logic_clk,
	controller_spi_clk,
	controller_spi_data,
	controller_radio_cs,
	controller_dac_cs,
	controller_SHDN,
	controller_TxEn,
	controller_RxEn,
	controller_RxHP,
	controller_24PA,
	controller_5PA,
	controller_ANTSW,
	controller_LED,
	controller_RX_ADC_DCS,
	controller_RX_ADC_DFS,
	controller_RX_ADC_PWDNA,
	controller_RX_ADC_PWDNB,
	controller_DIPSW,
	controller_RSSI_ADC_CLAMP,
	controller_RSSI_ADC_HIZ,
	controller_RSSI_ADC_SLEEP,
	controller_RSSI_ADC_D,
	controller_TxStart,
	controller_LD,
	controller_RX_ADC_OTRA,
	controller_RX_ADC_OTRB,
	controller_RSSI_ADC_OTR,
	controller_DAC_PLL_LOCK,
	controller_DAC_RESET,
	controller_SHDN_external,
	controller_RxEn_external,
	controller_TxEn_external,
	controller_RxHP_external,
	controller_interpfiltbypass,
	controller_decfiltbypass,
	dac_spi_data,
	dac_spi_cs,
	dac_spi_clk,
	radio_spi_clk,
	radio_spi_data,
	radio_spi_cs,
	radio_SHDN,
	radio_TxEn,
	radio_RxEn,
	radio_RxHP,
	radio_24PA,
	radio_5PA,
	radio_ANTSW,
	radio_LED,
	radio_RX_ADC_DCS,
	radio_RX_ADC_DFS,
	radio_RX_ADC_PWDNA,
	radio_RX_ADC_PWDNB,
	radio_DIPSW,
	radio_RSSI_ADC_CLAMP,
	radio_RSSI_ADC_HIZ,
	radio_RSSI_ADC_SLEEP,
	radio_RSSI_ADC_D,
	radio_LD,
	radio_RX_ADC_OTRA,
	radio_RX_ADC_OTRB,
	radio_RSSI_ADC_OTR,
	radio_DAC_PLL_LOCK,
	radio_DAC_RESET
);
parameter rate_change = 16'h0004;
parameter C_FAMILY = "virtex2p";
input	converter_clock_in;
output	converter_clock_out;
input	user_RSSI_ADC_clk;
output	radio_RSSI_ADC_clk;
output	[0:9] user_RSSI_ADC_D;
input	user_EEPROM_IO_T;
input	user_EEPROM_IO_O;
output	user_EEPROM_IO_I;
output	user_TxModelStart;
output	[0:15] radio_DAC_I;
output	[0:15] radio_DAC_Q;
input	[0:13] radio_ADC_I;
input	[0:13] radio_ADC_Q;
input	[0:15] user_DAC_I;
input	[0:15] user_DAC_Q;
output	[0:13] user_ADC_I;
output	[0:13] user_ADC_Q;
input	[0:1] user_RxRF_gain;
input	[0:4] user_RxBB_gain;
input	[0:5] user_Tx_gain;
output	[0:6] radio_B;
input	user_SHDN_external;
input	user_RxEn_external;
input	user_TxEn_external;
input	user_RxHP_external;
input	controller_logic_clk;
input	controller_spi_clk;
input	controller_spi_data;
input	controller_radio_cs;
input	controller_dac_cs;
input	controller_interpfiltbypass;
input	controller_decfiltbypass;
input	controller_SHDN;
input	controller_TxEn;
input	controller_RxEn;
input	controller_RxHP;
input	controller_24PA;
input	controller_5PA;
input	[0:1] controller_ANTSW;
input	[0:2] controller_LED;
input	controller_RX_ADC_DCS;
input	controller_RX_ADC_DFS;
input	controller_RX_ADC_PWDNA;
input	controller_RX_ADC_PWDNB;
input	controller_RSSI_ADC_CLAMP;
input	controller_RSSI_ADC_HIZ;
input	controller_RSSI_ADC_SLEEP;
input	controller_DAC_RESET;
input	controller_TxStart;
output	[0:3] controller_DIPSW;
output	[0:9] controller_RSSI_ADC_D;
output	controller_LD;
output	controller_RX_ADC_OTRA;
output	controller_RX_ADC_OTRB;
output	controller_RSSI_ADC_OTR;
output	controller_DAC_PLL_LOCK;
output	controller_SHDN_external;
output	controller_RxEn_external;
output	controller_TxEn_external;
output	controller_RxHP_external;
output	dac_spi_data;
output	dac_spi_cs;
output	dac_spi_clk;
output	radio_spi_clk;
output	radio_spi_data;
output	radio_spi_cs;
output	radio_SHDN;
output	radio_TxEn;
output	radio_RxEn;
output	radio_RxHP;
output	radio_24PA;
output	radio_5PA;
output	[0:1] radio_ANTSW;
output	[0:2] radio_LED;
output	radio_RX_ADC_DCS;
output	radio_RX_ADC_DFS;
output	radio_RX_ADC_PWDNA;
output	radio_RX_ADC_PWDNB;
output	radio_RSSI_ADC_CLAMP;
output	radio_RSSI_ADC_HIZ;
output	radio_RSSI_ADC_SLEEP;
output	radio_DAC_RESET;
input	[0:9] radio_RSSI_ADC_D;
input	radio_LD;
input	radio_RX_ADC_OTRA;
input	radio_RX_ADC_OTRB;
input	radio_RSSI_ADC_OTR;
input	radio_DAC_PLL_LOCK;
input	[0:3] radio_DIPSW;
inout	radio_EEPROM_IO;
reg	radio_RSSI_ADC_clk;
reg	[0:9] user_RSSI_ADC_D;
reg	[0:15] radio_DAC_I;
reg	[0:15] radio_DAC_Q;
reg	[0:13] user_ADC_I;
reg	[0:13] user_ADC_Q;
reg [0:13] radio_ADC_I_nReg;
reg [0:13] radio_ADC_Q_nReg;
reg	[0:6] radio_B;
reg	[0:3] controller_DIPSW;
reg	[0:9] controller_RSSI_ADC_D;
reg	controller_LD;
reg	controller_RX_ADC_OTRA;
reg	controller_RX_ADC_OTRB;
reg	controller_RSSI_ADC_OTR;
reg	controller_DAC_PLL_LOCK;
reg	dac_spi_data;
reg	dac_spi_cs;
reg	dac_spi_clk;
reg	radio_spi_clk;
reg	radio_spi_data;
reg	radio_spi_cs;
reg	radio_SHDN;
reg	radio_TxEn;
reg	radio_RxEn;
reg	radio_RxHP;
reg	radio_24PA;
reg	radio_5PA;
reg	[0:1] radio_ANTSW;
reg	[0:2] radio_LED;
reg	radio_RX_ADC_DCS;
reg	radio_RX_ADC_DFS;
reg	radio_RX_ADC_PWDNA;
reg	radio_RX_ADC_PWDNB;
reg	radio_RSSI_ADC_CLAMP;
reg	radio_RSSI_ADC_HIZ;
reg	radio_RSSI_ADC_SLEEP;
reg	radio_DAC_RESET;
OFDDRRSE OFDDRRSE_inst (
	.Q(converter_clock_out),      
	.C0(converter_clock_in),    
	.C1(~converter_clock_in),    
	.CE(1'b1),    
	.D0(1'b1),    
	.D1(1'b0),    
	.R(1'b0),      
	.S(1'b0)       
);
assign	user_TxModelStart = controller_TxStart;
assign controller_SHDN_external = user_SHDN_external;
assign controller_RxEn_external = user_RxEn_external;
assign controller_TxEn_external = user_TxEn_external;
assign controller_RxHP_external = user_RxHP_external;
wire	[0:6] radio_B_preReg;
assign radio_B_preReg = radio_RxEn ? {user_RxRF_gain, user_RxBB_gain} : {1'b0, user_Tx_gain};
wire [15:0] user_DAC_I_interpolated;
wire [15:0] user_DAC_Q_interpolated;
wire [13:0] radio_ADC_I_nReg_decimated;
wire [13:0] radio_ADC_Q_nReg_decimated;
generate
	if(rate_change == 1) 
		begin
			assign radio_ADC_I_nReg_decimated = radio_ADC_I_nReg;
			assign radio_ADC_Q_nReg_decimated = radio_ADC_Q_nReg;
			assign user_DAC_I_interpolated = user_DAC_I;
			assign user_DAC_Q_interpolated = user_DAC_Q;
		end
	else
		begin
			radio_bridge_ratechangefilter_4x_2ch_cw bridgeFilter (
				.clk(converter_clock_in),
				.ce(1'b1),
				.interp_en(~controller_RxEn),
				.decfiltbypass(controller_decfiltbypass),
				.interpfiltbypass(controller_interpfiltbypass),
				.rx_i(radio_ADC_I_nReg_decimated),
				.rx_q(radio_ADC_Q_nReg_decimated),
				.rx_i_fullrate(radio_ADC_I_nReg),
				.rx_q_fullrate(radio_ADC_Q_nReg),
				.tx_i(user_DAC_I),
				.tx_q(user_DAC_Q),
				.tx_i_fullrate(user_DAC_I_interpolated),
				.tx_q_fullrate(user_DAC_Q_interpolated)
			);
		end
endgenerate
IOBUF xIOBUF(
	.T(user_EEPROM_IO_T),
	.I(user_EEPROM_IO_O),
	.O(user_EEPROM_IO_I),
	.IO(radio_EEPROM_IO)
);
always @( negedge converter_clock_in )
begin
	radio_ADC_I_nReg <= radio_ADC_I;
	radio_ADC_Q_nReg <= radio_ADC_Q;
end
always @( posedge converter_clock_in )
begin
	radio_B <= radio_B_preReg;
	radio_RSSI_ADC_clk <= user_RSSI_ADC_clk;
	user_ADC_I <= radio_ADC_I_nReg_decimated;
	user_ADC_Q <= radio_ADC_Q_nReg_decimated;
	radio_DAC_I <= user_DAC_I_interpolated;
	radio_DAC_Q <= user_DAC_Q_interpolated;
end
always @( posedge controller_logic_clk )
begin
	dac_spi_clk <= controller_spi_clk;
	dac_spi_data <= controller_spi_data;
	dac_spi_cs <= controller_dac_cs;
	radio_spi_clk <= controller_spi_clk;
	radio_spi_data <= controller_spi_data;
	radio_spi_cs <= controller_radio_cs;
	radio_SHDN <= controller_SHDN;
	radio_TxEn <= controller_TxEn;
	radio_RxEn <= controller_RxEn;
	radio_RxHP <= controller_RxHP;
	radio_24PA <= controller_24PA;
	radio_5PA <= controller_5PA;
	radio_ANTSW <= controller_ANTSW;
	radio_LED <= controller_LED;
	radio_RX_ADC_DCS <= controller_RX_ADC_DCS;
	radio_RX_ADC_DFS <= controller_RX_ADC_DFS;
	radio_RX_ADC_PWDNA <= controller_RX_ADC_PWDNA;
	radio_RX_ADC_PWDNB <= controller_RX_ADC_PWDNB;
	radio_RSSI_ADC_CLAMP <= controller_RSSI_ADC_CLAMP;
	radio_RSSI_ADC_HIZ <= controller_RSSI_ADC_HIZ;
	radio_RSSI_ADC_SLEEP <= controller_RSSI_ADC_SLEEP;
	controller_DIPSW <= radio_DIPSW;
	controller_LD <= radio_LD;
	controller_RX_ADC_OTRA <= radio_RX_ADC_OTRA;
	controller_RX_ADC_OTRB <= radio_RX_ADC_OTRB;
	controller_RSSI_ADC_OTR <= radio_RSSI_ADC_OTR;
	controller_DAC_PLL_LOCK <= radio_DAC_PLL_LOCK;
	radio_DAC_RESET <= controller_DAC_RESET;
end
reg user_RSSI_ADC_clk_d1;
always @( posedge controller_logic_clk )
begin
	user_RSSI_ADC_clk_d1 <= user_RSSI_ADC_clk;
end
always @( posedge controller_logic_clk )
begin
	if(user_RSSI_ADC_clk & ~user_RSSI_ADC_clk_d1)
	begin
		controller_RSSI_ADC_D <= radio_RSSI_ADC_D;
		user_RSSI_ADC_D <= radio_RSSI_ADC_D;
	end
end
endmodule
module radio_bridge_ratechangefilter_4x_2ch_cw (
  clk,
  ce,
  decfiltbypass,
  interpfiltbypass,
  interp_en,
  rx_i,
  rx_i_fullrate,
  rx_q,
  rx_q_fullrate,
  tx_i,
  tx_i_fullrate,
  tx_q,
  tx_q_fullrate
);
	input	clk;
	input	ce;
	input	decfiltbypass;
	input	interpfiltbypass;
	input	interp_en;
	input	[13:0] rx_i_fullrate;
	input	[13:0] rx_q_fullrate;
	input	[15:0] tx_i;
	input	[15:0] tx_q;
	output	[13:0] rx_i;
	output	[13:0] rx_q;
	output	[15:0] tx_i_fullrate;
	output	[15:0] tx_q_fullrate;
endmodule
