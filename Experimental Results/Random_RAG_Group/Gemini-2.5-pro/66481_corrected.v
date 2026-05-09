`timescale 1ns / 1ps
`timescale 1ns / 1ps
module NEXYS2(
	// DFT Inputs
	input				test_i,
	input				test_clk_i,
	input				test_rst_i,
	// Original Ports
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
	input				N2_50MHZ_I,
	input				N2_BTN0_I,
	input				N2_PS2CLK_I,
	input				N2_PS2DAT_IO,
	output			N2_SD_CLK_O,
	output			N2_SD_MOSI_O,
	output			N2_SD_CS_O,
	output			N2_SD_LED_O,
	input				N2_SD_MISO_I,
	input				N2_SD_WP_I,
	input				N2_SD_CD_I
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
	wire				mgia_25mhz_o;
	wire	[13:1]	mgia_adr_o;
	wire				mgia_cyc_o;
	wire				mgia_stb_o;
	wire	[15:0]	mgia_dat_i;
	wire				mgia_ack_i;
	wire				cpu_bus_cycle;
	wire				no_peripheral_addressed;

	// DFT Signals
	wire dft_clk;
	wire dft_rst;

	assign dft_clk = test_i ? test_clk_i : mgia_25mhz_o;
	assign dft_rst = test_i ? test_rst_i : N2_BTN0_I; // Assuming N2_BTN0_I is active-high reset

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

	// Changed from combinational assignment (latch inference) to synchronous flop
	always @(posedge dft_clk or posedge dft_rst) begin
		if (dft_rst) begin
			an0n <= 1'b1;
			an1n <= 1'b1;
			an2n <= 1'b1;
			an3n <= 1'b1;
			can  <= 1'b1; // Assign safe reset values
			cbn  <= 1'b1;
			ccn  <= 1'b1;
			cdn  <= 1'b1;
			cen  <= 1'b1;
			cfn  <= 1'b1;
			cgn  <= 1'b1;
			cdpn <= 1'b1;
		end else begin
			// Assuming the intent was to update these based on video memory reads
			// This might need adjustment based on exact functional requirement,
			// but now it's clocked and reset properly.
			// The original logic depended only on mgia_dat_i changing.
			// Now it samples mgia_dat_i on the clock edge.
			an0n <= 1'b1; // Original logic kept these constant 1
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
		.res_i(dft_rst), // Use DFT reset
		.abort_i(1'b0)
	);
	KIA kia(
		.ACK_O(kia_ack_o),
		.DAT_O(kia_dat_o),
		.CLK_I(dft_clk), // Use DFT clock
		.RES_I(dft_rst), // Use DFT reset
		.ADR_I(cpu_adr_o[1]),
		.WE_I (cpu_we_o),
		.CYC_I(cpu_cyc_o),
		.STB_I(kia_stb_i),
		.D_I  (N2_PS2DAT_IO),
		.C_I  (N2_PS2CLK_I)
	);
	GPIA gpia(
		.RST_I(dft_rst), // Use DFT reset
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
		// Assuming VRAM16K internal reset is handled or not needed based on design
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
		// Assuming VRAM16K internal reset is handled or not needed based on design
	);
	VRAM16K vidmem(
		.CLK_I  (dft_clk), // Use DFT clock for Port A
		// Port B uses MGIA clock implicitly via MGIA connection below
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
		// Assuming VRAM16K internal reset is handled or not needed based on design
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
		.CLK_O_25MHZ	(mgia_25mhz_o), // Functional clock output
		.CLK_I_50MHZ	(N2_50MHZ_I),    // Primary clock input (OK)
		.RST_I			(dft_rst),       // Use DFT reset
		.MGIA_DAT_I		(mgia_dat_i),
		.MGIA_ACK_I		(mgia_ack_i)
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
progmem.ram00.INIT_15 = 256'hE01F95B04C78E01E40B0CE6CE0600000004A22120020003