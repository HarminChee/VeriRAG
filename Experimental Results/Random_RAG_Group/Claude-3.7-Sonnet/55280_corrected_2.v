`timescale 1ns / 1ps
module NEXYS2(
    output  [2:0]   N2_RED_O,
    output  [2:0]   N2_GRN_O,
    output  [2:1]   N2_BLU_O,
    output          N2_HSYNC_O,
    output          N2_VSYNC_O,
    output          N2_AN0n_O,
    output          N2_AN1n_O,
    output          N2_AN2n_O,
    output          N2_AN3n_O,
    output          N2_CAn_O,
    output          N2_CBn_O,
    output          N2_CCn_O,
    output          N2_CDn_O,
    output          N2_CEn_O,
    output          N2_CFn_O,
    output          N2_CGn_O,
    output          N2_CDPn_O,
    input           N2_50MHZ_I,
    input           N2_BTN0_I,
    input           N2_PS2CLK_I,
    inout           N2_PS2DAT_IO,
    output          N2_SD_CLK_O,
    output          N2_SD_MOSI_O,
    output          N2_SD_CS_O,
    output          N2_SD_LED_O,
    input           N2_SD_MISO_I,
    input           N2_SD_WP_I,
    input           N2_SD_CD_I,
    input           test_i
);

reg an0n, an1n, an2n, an3n;
reg can, cbn, ccn, cdn, cen, cfn, cgn, cdpn;
wire mgia_25mhz_o;
wire [15:0] mgia_dat_i;

assign N2_AN0n_O = an0n;
assign N2_AN1n_O = an1n;
assign N2_AN2n_O = an2n;
assign N2_AN3n_O = an3n;
assign N2_CAn_O = can;
assign N2_CBn_O = cbn;
assign N2_CCn_O = ccn;
assign N2_CDn_O = cdn;
assign N2_CEn_O = cen;
assign N2_CFn_O = cfn;
assign N2_CGn_O = cgn;
assign N2_CDPn_O = cdpn;

wire dft_clk;
assign dft_clk = test_i ? N2_50MHZ_I : mgia_25mhz_o;

always @(posedge dft_clk or negedge N2_BTN0_I) begin
    if(!N2_BTN0_I) begin
        an0n <= 1'b1;
        an1n <= 1'b1;
        an2n <= 1'b1;
        an3n <= 1'b1;
        can  <= 1'b1;
        cbn  <= 1'b1;
        ccn  <= 1'b1;
        cdn  <= 1'b1;
        cen  <= 1'b1;
        cfn  <= 1'b1;
        cgn  <= 1'b1;
        cdpn <= 1'b1;
    end else begin
        if(test_i) begin
            an0n <= 1'b1;
            an1n <= 1'b1;
            an2n <= 1'b1;
            an3n <= 1'b1;
            can  <= 1'b1;
            cbn  <= 1'b1;
            ccn  <= 1'b1;
            cdn  <= 1'b1;
            cen  <= 1'b1;
            cfn  <= 1'b1;
            cgn  <= 1'b1;
            cdpn <= 1'b1;
        end else begin
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
    end
end

endmodule