`timescale 1ns / 1ps

module NEXYS2(
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
	inout				N2_PS2DAT_IO,
	output			N2_SD_CLK_O,
	output			N2_SD_MOSI_O,
	output			N2_SD_CS_O,
	output			N2_SD_LED_O,
	input				N2_SD_MISO_I,
	input				N2_SD_WP_I,
	input				N2_SD_CD_I
);

	reg an0n, an1n, an2n, an3n;
	reg can, cbn, ccn, cdn, cen, cfn, cgn, cdpn;

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

	assign N2_SD_CLK_O  = gpia_port_o[3];
	assign N2_SD_MOSI_O = gpia_port_o[2];
	assign N2_SD_CS_O   = gpia_port_o[1];
	assign N2_SD_LED_O  = gpia_port_o[0];

	wire	progmem_ack_o;
	wire	[15:0]	progmem_dat_o;
	wire	progmem_stb_i;

	wire	progmem1_ack_o;
	wire	[15:0]	progmem1_dat_o;
	wire	progmem1_stb_i;

	wire	vidmem_ack_o;
	wire	[15:0]	vidmem_dat_o;
	wire	vidmem_stb_i;

	wire	mgia_25mhz_o;
	wire	[13:1]	mgia_adr_o;
	wire	mgia_cyc_o;
	wire	mgia_stb_o;
	wire	[15:0]	mgia_dat_i;
	wire	mgia_ack_i;

	wire	cpu_bus_cycle;
	wire	no_peripheral_addressed;

	assign cpu_bus_cycle = cpu_cyc_o & cpu_stb_o;

	assign progmem_stb_i  = cpu_bus_cycle & (cpu_adr_o[15:14] == 2'b00);		
	assign progmem1_stb_i = cpu_bus_cycle & (cpu_adr_o[15:14] == 2'b01);		
	assign kia_stb_i      = cpu_bus_cycle & (cpu_adr_o[15:4]  == 12'hB00);		
	assign gpia_stb_i     = cpu_bus_cycle & (cpu_adr_o[15:4]  == 12'hB01);		
	assign vidmem_stb_i   = cpu_bus_cycle & (cpu_adr_o[15:14] == 2'b11);		

	assign no_peripheral_addressed = ~progmem_stb_i & ~progmem1_stb_i & ~kia_stb_i & ~vidmem_stb_i & ~gpia_stb_i;

	wire [15:0] progmem_mask  = {16{progmem_stb_i}};
	wire [15:0] progmem1_mask = {16{progmem1_stb_i}};
	wire [7:0]  kia_mask      = {8{kia_stb_i}};
	wire [15:0] vidmem_mask   = {16{vidmem_stb_i}};
	wire [15:0] gpia_mask     = {16{gpia_stb_i}};

	assign cpu_dat_i = (progmem_mask  & progmem_dat_o) |
	                   (progmem1_mask & progmem1_dat_o) |
	                   (vidmem_mask   & vidmem_dat_o)   |
	                   {8'b0, (kia_mask & kia_dat_o)}   |
	                   (gpia_mask     & gpia_dat_o);

	assign cpu_ack_i = (progmem_stb_i  & progmem_ack_o) |
	                   (progmem1_stb_i & progmem1_ack_o) |
	                   (vidmem_stb_i   & vidmem_ack_o)   |
	                   (kia_stb_i      & kia_ack_o)      |
	                   (gpia_stb_i     & gpia_ack_o)     |
	                   no_peripheral_addressed;

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

	// 实例化模块保持不变，略...

endmodule