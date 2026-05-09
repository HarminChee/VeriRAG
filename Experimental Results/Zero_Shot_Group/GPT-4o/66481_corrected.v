`timescale 1ns / 1ps

module NEXYS2 (
    output [2:0] N2_RED_O,
    output [2:0] N2_GRN_O,
    output [2:1] N2_BLU_O,
    output N2_HSYNC_O,
    output N2_VSYNC_O,
    output N2_AN0n_O,
    output N2_AN1n_O,
    output N2_AN2n_O,
    output N2_AN3n_O,
    output N2_CAn_O,
    output N2_CBn_O,
    output N2_CCn_O,
    output N2_CDn_O,
    output N2_CEn_O,
    output N2_CFn_O,
    output N2_CGn_O,
    output N2_CDPn_O,
    input N2_50MHZ_I,
    input N2_BTN0_I,
    input N2_PS2CLK_I,
    inout N2_PS2DAT_IO,
    output N2_SD_CLK_O,
    output N2_SD_MOSI_O,
    output N2_SD_CS_O,
    output N2_SD_LED_O,
    input N2_SD_MISO_I,
    input N2_SD_WP_I,
    input N2_SD_CD_I
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

    wire [15:1] cpu_adr_o;
    wire cpu_we_o, cpu_cyc_o, cpu_stb_o;
    wire [1:0] cpu_sel_o;
    wire [15:0] cpu_dat_o, cpu_dat_i;
    wire cpu_ack_i;

    wire kia_ack_o, gpia_ack_o;
    wire [7:0] kia_dat_o;
    wire [15:0] gpia_dat_o, gpia_port_o;
    wire kia_stb_i, gpia_stb_i;

    assign N2_SD_CLK_O  = gpia_port_o[3];
    assign N2_SD_MOSI_O = gpia_port_o[2];
    assign N2_SD_CS_O   = gpia_port_o[1];
    assign N2_SD_LED_O  = gpia_port_o[0];

    wire progmem_ack_o, progmem1_ack_o, vidmem_ack_o;
    wire [15:0] progmem_dat_o, progmem1_dat_o, vidmem_dat_o;
    wire progmem_stb_i, progmem1_stb_i, vidmem_stb_i;

    wire mgia_25mhz_o;
    wire [13:1] mgia_adr_o;
    wire mgia_cyc_o, mgia_stb_o;
    wire [15:0] mgia_dat_i;
    wire mgia_ack_i;

    wire cpu_bus_cycle = cpu_cyc_o & cpu_stb_o;

    assign progmem_stb_i  = cpu_bus_cycle & (cpu_adr_o[15:14] == 2'b00);
    assign progmem1_stb_i = cpu_bus_cycle & (cpu_adr_o[15:14] == 2'b01);
    assign kia_stb_i      = cpu_bus_cycle & (cpu_adr_o[15:4] == 12'hB00);
    assign gpia_stb_i     = cpu_bus_cycle & (cpu_adr_o[15:4] == 12'hB01);
    assign vidmem_stb_i   = cpu_bus_cycle & (cpu_adr_o[15:14] == 2'b11);

    assign cpu_dat_i = (progmem_stb_i ? progmem_dat_o : 16'b0) |
                       (progmem1_stb_i ? progmem1_dat_o : 16'b0) |
                       (vidmem_stb_i ? vidmem_dat_o : 16'b0) |
                       (kia_stb_i ? {8'b0, kia_dat_o} : 16'b0) |
                       (gpia_stb_i ? gpia_dat_o : 16'b0);

    assign cpu_ack_i = progmem_stb_i | progmem1_stb_i | vidmem_stb_i | kia_stb_i | gpia_stb_i;

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

    S16X4A cpu (
        .adr_o(cpu_adr_o),
        .we_o(cpu_we_o),
        .cyc_o(cpu_cyc_o),
        .stb_o(cpu_stb_o),
        .sel_o(cpu_sel_o),
        .dat_o(cpu_dat_o),
        .ack_i(cpu_ack_i),
        .dat_i(cpu_dat_i),
        .clk_i(mgia_25mhz_o),
        .res_i(N2_BTN0_I),
        .abort_i(1'b0)
    );

    KIA kia (
        .ACK_O(kia_ack_o),
        .DAT_O(kia_dat_o),
        .CLK_I(mgia_25mhz_o),
        .RES_I(N2_BTN0_I),
        .ADR_I(cpu_adr_o[1]),
        .WE_I(cpu_we_o),
        .CYC_I(cpu_cyc_o),
        .STB_I(kia_stb_i),
        .D_I(N2_PS2DAT_IO),
        .C_I(N2_PS2CLK_I)
    );

    GPIA gpia (
        .RST_I(N2_BTN0_I),
        .CLK_I(mgia_25mhz_o),
        .ADR_I(cpu_adr_o[1]),
        .CYC_I(cpu_cyc_o),
        .STB_I(gpia_stb_i),
        .WE_I(cpu_we_o),
        .DAT_I(cpu_dat_o),
        .DAT_O(gpia_dat_o),
        .ACK_O(gpia_ack_o),
        .PORT_I({13'b0, N2_SD_MISO_I, N2_SD_WP_I, N2_SD_CD_I}),
        .PORT_O(gpia_port_o)
    );

    MGIA mgia (
        .HSYNC_O(N2_HSYNC_O),
        .VSYNC_O(N2_VSYNC_O),
        .RED_O(N2_RED_O),
        .GRN_O(N2_GRN_O),
        .BLU_O(N2_BLU_O),
        .MGIA_ADR_O(mgia_adr_o),
        .MGIA_CYC_O(mgia_cyc_o),
        .MGIA_STB_O(mgia_stb_o),
        .CLK_O_25MHZ(mgia_25mhz_o),
        .CLK_I_50MHZ(N2_50MHZ_I),
        .RST_I(N2_BTN0_I),
        .MGIA_DAT_I(mgia_dat_i),
        .MGIA_ACK_I(mgia_ack_i)
    );

endmodule