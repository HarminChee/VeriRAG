`timescale 1ns / 1ps
module NEXYS2_corrected_clk(
	output	[2:0]	N2_RED_O,
	output	[2:0]	N2_GRN_O,
	output	[2:1]	N2_BLU_O,
	output			N2_HSYNC_O,
	output			N2_VSYNC_O,
	output			N2_AN0n_O,
	output			N2_AN1n_O,
	output			N2_AN2n_O,
	output			N2_AN3n_O,
	output			N2_CAn_O,
	output			N2_CBn_O,
	output			N2_CCn_O,
	output			N2_CDn_O,
	output			N2_CEn_O,
	output			N2_CFn_O,
	output			N2_CGn_O,
	output			N2_CDPn_O,
	input				N2_50MHZ_I, // Primary Clock Input
	input				N2_BTN0_I,  // Primary Reset Input
	input				N2_PS2CLK_I,
	input				N2_PS2DAT_IO,
	output			N2_SD_CLK_O,
	output			N2_SD_MOSI_O,
	output			N2_SD_CS_O,
	output			N2_SD_LED_O,
	input				N2_SD_MISO_I,
	input				N2_SD_WP_I,
	input				N2_SD_CD_I,
	input           test_mode_i // DFT Test Mode Input
);
	reg an0n, an1n, an2n, an3n, can, cbn, ccn, cdn, cen, cfn, cgn, cdpn;
	assign N2_AN0n_O = an0n;
	assign N2_AN1n_O = an1n;
	assign N2_AN2n_O = an2n;
	assign N2_AN3n_O = an3n;
	assign N2_CAn_O  = can;
	assign N2_CBn_O  = cbn;
	assign N2_CCn_O  = ccn;
	assign N2_CDn_O  = cdn;
	assign N2_CEn_O  = cen;
	assign N2_CFn_O  = cfn;
	assign N2_CGn_O  = cgn;
	assign N2_CDPn_O = cdpn;
	wire	[15:1]	cpu_adr_o;
	wire				cpu_we_o;
	wire				cpu_cyc_o;
	wire				cpu_stb_o;
	wire	[1:0]		cpu_sel_o;
	wire	[15:0]	cpu_dat_o;
	wire				cpu_ack_i;
	wire	[15:0]	cpu_dat_i;
	wire				kia_ack_o;
	wire	[7:0]		kia_dat_o;
	wire				kia_stb_i;
	wire				gpia_ack_o;
	wire	[15:0]	gpia_dat_o;
	wire				gpia_stb_i;
	wire	[15:0]	gpia_port_o;
	assign N2_SD_CLK_O	= gpia_port_o[3];
	assign N2_SD_MOSI_O	= gpia_port_o[2];
	assign N2_SD_CS_O		= gpia_port_o[1];
	assign N2_SD_LED_O	= gpia_port_o[0];
	wire				progmem_ack_o;
	wire	[15:0]	progmem_dat_o;
	wire				progmem_stb_i;
	wire				progmem1_ack_o;
	wire	[15:0]	progmem1_dat_o;
	wire				progmem1_stb_i;
	wire				vidmem_ack_o;
	wire	[15:0]	vidmem_dat_o;
	wire				vidmem_stb_i;
	wire				mgia_25mhz_o; // Internally generated clock
	wire	[13:1]	mgia_adr_o;
	wire				mgia_cyc_o;
	wire				mgia_stb_o;
	wire	[15:0]	mgia_dat_i;
	wire				mgia_ack_i;
	wire				cpu_bus_cycle;
	wire				no_peripheral_addressed;

	// DFT Clock Selection Logic
	wire dft_clk;
	assign dft_clk = test_mode_i ? N2_50MHZ_I : mgia_25mhz_o; // Select primary clock in test mode

	assign cpu_bus_cycle 				= cpu_cyc_o & cpu_stb_o;
	assign progmem_stb_i 				= cpu_bus_cycle & (cpu_adr_o[15:14] == 2'b00);
	assign progmem1_stb_i 				= cpu_bus_cycle & (cpu_adr_o[15:14] == 2'b01);
	assign kia_stb_i						= cpu_bus_cycle & (cpu_adr_o[15:4] == 12'hB00);
	assign gpia_stb_i						= cpu_bus_cycle & (cpu_adr_o[15:4] == 12'hB01);
	assign vidmem_stb_i  				= cpu_bus_cycle & (cpu_adr_o[15:14] == 2'b11);
	assign no_peripheral_addressed 	= (~progmem_stb_i & ~progmem1_stb_i & ~kia_stb_i & ~vidmem_stb_i & ~gpia_stb_i);
	wire	[15:0]	progmem_mask 		= {16{progmem_stb_i}};
	wire	[15:0]	progmem1_mask		= {16{progmem1_stb_i}};
	wire	[7:0]		kia_mask				= {8{kia_stb_i}};
	wire	[15:0]	vidmem_mask			= {16{vidmem_stb_i}};
	wire	[15:0]	gpia_mask			= {16{gpia_stb_i}};
	assign			cpu_dat_i			= (progmem_mask & progmem_dat_o) | (progmem1_mask & progmem1_dat_o) | (vidmem_mask & vidmem_dat_o) | {8'b00000000, (kia_mask & kia_dat_o)} | (gpia_mask & gpia_dat_o);
	assign			cpu_ack_i			= (progmem_stb_i & progmem_ack_o) | (progmem1_stb_i & progmem1_ack_o) | (vidmem_stb_i & vidmem_ack_o) | (kia_stb_i & kia_ack_o) | (gpia_stb_i & gpia_ack_o) | no_peripheral_addressed;

	// This block describes combinational logic or latches, not directly related to CLKNPI FF clocking issue,
	// but might be a separate DFT concern. Leaving as is per focus on CLKNPI.
	always @(mgia_dat_i) begin
		an0n <= 1'b1;
		an1n <= 1'b1;
		an2n <= 1'b1;
		an3n <= 1'b1;
		can  <= mgia_dat_i[0];
		cbn  <= mgia_dat_i[2];
		ccn  <= mgia_dat_i[4];
		cdn  <= mgia_dat_i[6];
		cen  <= mgia_dat_i[8];
		cfn  <= mgia_dat_i[10];
		cgn  <= mgia_dat_i[12];
		cdpn <= mgia_dat_i[14];
	end

	S16X4A cpu(
		.adr_o(cpu_adr_o),
		.we_o (cpu_we_o),
		.cyc_o(cpu_cyc_o),
		.stb_o(cpu_stb_o),
		.sel_o(cpu_sel_o),
		.dat_o(cpu_dat_o),
		.ack_i(cpu_ack_i),
		.dat_i(cpu_dat_i),
		.clk_i(dft_clk), // Use DFT clock
		.res_i(N2_BTN0_I),
		.abort_i(1'b0)
	);
	KIA kia(
		.ACK_O(kia_ack_o),
		.DAT_O(kia_dat_o),
		.CLK_I(dft_clk), // Use DFT clock
		.RES_I(N2_BTN0_I),
		.ADR_I(cpu_adr_o[1]),
		.WE_I (cpu_we_o),
		.CYC_I(cpu_cyc_o),
		.STB_I(kia_stb_i),
		.D_I  (N2_PS2DAT_IO),
		.C_I  (N2_PS2CLK_I)
	);
	GPIA gpia(
		.RST_I(N2_BTN0_I),
		.CLK_I(dft_clk), // Use DFT clock
		.ADR_I(cpu_adr_o[1]),
		.CYC_I(cpu_cyc_o),
		.STB_I(gpia_stb_i),
		.WE_I(cpu_we_o),
		.DAT_I(cpu_dat_o),
		.DAT_O(gpia_dat_o),
		.ACK_O(gpia_ack_o),
		.PORT_I({13'h0000, N2_SD_MISO_I, N2_SD_WP_I, N2_SD_CD_I}),
		.PORT_O(gpia_port_o)
	);
	VRAM16K progmem(
		.CLK_I  (dft_clk), // Use DFT clock
		.A_ACK_O(progmem_ack_o),
		.A_DAT_O(progmem_dat_o),
		.A_ADR_I(cpu_adr_o[13:1]),
		.A_CYC_I(cpu_cyc_o),
		.A_DAT_I(cpu_dat_o),
		.A_SEL_I(cpu_sel_o),
		.A_STB_I(progmem_stb_i),
		.A_WE_I (cpu_we_o),
		.B_ADR_I(13'b1111111111111),
		.B_CYC_I(1'b1),
		.B_DAT_I(16'hFFFF),
		.B_SEL_I(2'b11),
		.B_STB_I(1'b0),
		.B_WE_I (1'b1)
	);
	VRAM16K progmem1(
		.CLK_I  (dft_clk), // Use DFT clock
		.A_ACK_O(progmem1_ack_o),
		.A_DAT_O(progmem1_dat_o),
		.A_ADR_I(cpu_adr_o[13:1]),
		.A_CYC_I(cpu_cyc_o),
		.A_DAT_I(cpu_dat_o),
		.A_SEL_I(cpu_sel_o),
		.A_STB_I(progmem1_stb_i),
		.A_WE_I (cpu_we_o),
		.B_ADR_I(13'b1111111111111),
		.B_CYC_I(1'b1),
		.B_DAT_I(16'hFFFF),
		.B_SEL_I(2'b11),
		.B_STB_I(1'b0),
		.B_WE_I (1'b1)
	);
	VRAM16K vidmem(
		.CLK_I  (dft_clk), // Use DFT clock for Port A
		// Port B is clocked by the MGIA module's internal logic, driven by mgia signals.
		// Assuming MGIA handles its own DFT/clocking correctly or Port B is not scanned.
		// If Port B flops need scan, MGIA needs modification or a separate test clock path.
		.A_ACK_O(vidmem_ack_o),
		.A_DAT_O(vidmem_dat_o),
		.A_ADR_I(cpu_adr_o[13:1]),
		.A_CYC_I(cpu_cyc_o),
		.A_DAT_I(cpu_dat_o),
		.A_SEL_I(cpu_sel_o),
		.A_STB_I(vidmem_stb_i),
		.A_WE_I (cpu_we_o),
		.B_ACK_O(mgia_ack_i),
		.B_DAT_O(mgia_dat_i),
		.B_ADR_I(mgia_adr_o[13:1]),
		.B_CYC_I(mgia_cyc_o),
		.B_DAT_I(16'hFFFF),
		.B_SEL_I(2'b11),
		.B_STB_I(mgia_stb_o),
		.B_WE_I (1'b0)
	);
	MGIA mgia(
		.HSYNC_O			(N2_HSYNC_O),
		.VSYNC_O			(N2_VSYNC_O),
		.RED_O			(N2_RED_O),
		.GRN_O			(N2_GRN_O),
		.BLU_O			(N2_BLU_O),
		.MGIA_ADR_O		(mgia_adr_o[13:1]),
		.MGIA_CYC_O		(mgia_cyc_o),
		.MGIA_STB_O		(mgia_stb_o),
		.CLK_O_25MHZ	(mgia_25mhz_o), // MGIA still generates this for functional mode
		.CLK_I_50MHZ	(N2_50MHZ_I),   // Primary clock input to MGIA
		.RST_I			(N2_BTN0_I),
		.MGIA_DAT_I		(mgia_dat_i),
		.MGIA_ACK_I		(mgia_ack_i)
		// Assuming MGIA has its own internal DFT logic if needed,
		// potentially using N2_50MHZ_I directly for its scan flops
		// or having its own test mode input.
	);
defparam
progmem.ram00.INIT_00 = 256'h03ABABAB03FF0000000000000000000000000000000000000000B600D8001600,
progmem.ram00.INIT_01 = 256'h0D1015740000FF6BCB8BCB6BF303030303ABABAB03FFFF0B0B0B0B0BF3030303,
progmem.ram00.INIT_02 = 256'h15B8000000A41212F71215A4000094E00C101594000084E003101584000074E0,
progmem.ram00.INIT_03 = 256'hBA00E0F4000000E01212081216E0000000CC1212FD1215CC000000B81212FB12,
progmem.ram00.INIT_04 = 256'h1438000028E0041015280000000E1212021216CE1AE00E000000F41212041216,
progmem.ram00.INIT_05 = 256'h6AE03A7CE01403306A000054E03A66E014E83054000038E03E501E141412FF14,
progmem.ram00.INIT_06 = 256'h802415B4000096E0BAB0E096E0F6A6E0AA0096000080E0E292E06C8CE0800000,
progmem.ram00.INIT_07 = 256'hE0B6FEE0B6F8E0B6F2E0B6ECE0E0000000B424B124241A82D2E082CCE098C6E0,
progmem.ram00.INIT_08 = 256'h1AE0E23CE0242E1BE230E02400012E4A1A0000E0E0B616E0B610E0B60AE0B604,
progmem.ram00.INIT_09 = 256'h7A000040E0E276E0241F1B1C6AE02E20131C5EE02E2213E252E0241E1B400000,
progmem.ram00.INIT_0A = 256'h3196161E16FF2482B2E082ACE0BE002AA2E0C816179000007AE0E28CE024FFB0,
progmem.ram00.INIT_0B = 256'h4200E0F40000D2E092F0E0F6EAE0160000300031D20000009030013100903000,
progmem.ram00.INIT_0C = 256'h00002CE00126152C0000001801120C24E0180000000A30120A0000F4E0D406E0,
progmem.ram00.INIT_0D = 256'h74261274000000600112526CE060000050E0042615500000003C01122E48E03C,
progmem.ram00.INIT_0E = 256'h82C0E082BAE025011B25B41A2AA8E025B025251A92000082E000281582000000,
progmem.ram00.INIT_0F = 256'h9400E094FAE094F4E094EEE094E8E094E2E094DCE094D6E02500B0C4000092E0,
progmem.ram00.INIT_10 = 256'h1AE02C251BC636E000012C2511C626E01A000004E026251BC610E0040000C4E0,
progmem.ram00.INIT_11 = 256'h82E000627C127C2615066EE062000040E02A2C131C58E0282C131C4CE0400000,
progmem.ram00.INIT_12 = 256'h180141181A31011A211A2512C6A8E0CE321796000086E06492E086000062E042,
progmem.ram00.INIT_13 = 256'hE80212FF2516C6F4E0E80000D2E098E4E0320030D2000096E0009C3231FF3221,
progmem.ram00.INIT_14 = 256'h002C40127638E02C00000AE0C628E0C622E0D41CE0EA16E00A0000E8E0EE0000,
progmem.ram00.INIT_15 = 256'hE01F95B04C78E01E40B0CE6CE0600000004A2212002000314A00002CE00C46E0,
progmem.ram00.INIT_16 = 256'hC2E04CBCE01E41B0CEB0E0A4000060E07CA0E0109AE00694E094001A8AE0F684,
progmem.ram00.INIT_17 = 256'h8720114CFAE01E48B0CEEEE0E20000A4E07CDEE010D8E006D2E0D2001AC8E0F6,
progmem.ram00.INIT_18 = 256'h11001E50B1CE36E02A0000E2E07C26E01020E0881AE01A001A10E0F60AE0001F,
progmem.ram00.INIT_19 = 256'h1E51B0CE7AE06E00002AE07C6AE01064E0065EE05E001A54E0F64EE000220020,
progmem.ram00.INIT_1A = 256'hE0B800006EE07CB4E010AEE02EA8E006A2E0A8001A98E0F692E0201C134C86E0,
progmem.ram00.INIT_1B = 256'h02E0F60000B8E07CF2E010ECE006E6E0E6001ADCE0F6D6E04CD0E01E77B0CEC4,
progmem.ram00.INIT_1C = 256'hF640E00020002211F830E01E69B0CE24E0BA1EE0120000F6002E00F6000C1196,
progmem.ram00.INIT_1D = 256'hE0F67EE04C78E01E7AB0CE6CE060000012E07C5CE01056E00650E050001A46E0,
progmem.ram00.INIT_1E = 256'hC2E07CBCE07CB6E07CB0E07CAAE09E000060E07C9AE01094E0648EE08E001A84,
progmem.ram00.INIT_1F = 256'h02E010FCE0F6F6E0A6F0E0E400009EE07CE0E07CDAE07CD4E07CCEE07CC8E07C,
progmem.ram00.INIT_20 = 256'h7040E01C12137034E0001C001811001A003116000000060E0131060000E4E0A0,
progmem.ram00.INIT_21 = 256'hE0087EE07E007674E044E0086AE06E000C60E02C5AE044E0540E1744000016E0,
progmem.ram00.INIT_22 = 256'h00A8E084BAE0100430A800000092121201100831920000008212003182000044,
progmem.ram00.INIT_23 = 256'h02E0060084F8E0BEE008EEE0F20076E4E0BEE008DAE0DE000CD0E062CAE0BE00,
progmem.ram00.INIT_24 = 256'h0010E0C03AE010E08430E034008626E010E0200E17100000