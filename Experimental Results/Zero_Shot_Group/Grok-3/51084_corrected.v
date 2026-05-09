`timescale 1ns/1ps
`default_nettype none
module de0_nano_agc(
    input wire OSC_50,
    input wire KEY0,
    input wire EPCS_DATA,
    output wire EPCS_CSN,
    output wire EPCS_DCLK,
    output wire EPCS_ASDI,
    input wire CAURST,
    input wire MAINRS,
    input wire MKEY1,
    input wire MKEY2,
    input wire MKEY3,
    input wire MKEY4,
    input wire MKEY5,
    input wire PROCEED,
    output wire COMACT,
    output wire KYRLS,
    output wire RESTRT,
    output wire OPEROR,
    output wire RLYB01,
    output wire RLYB02,
    output wire RLYB03,
    output wire RLYB04,
    output wire RLYB05,
    output wire RLYB06,
    output wire RLYB07,
    output wire RLYB08,
    output wire RLYB09,
    output wire RLYB10,
    output wire RLYB11,
    output wire RYWD12,
    output wire RYWD13,
    output wire RYWD14,
    output wire RYWD16,
    output wire SBYLIT,
    output wire TMPCAU,
    output wire UPLACT,
    output wire VNFLSH,
    output wire MT12
);
    reg p4VDC = 1;
    wire p4VSW;
    reg GND = 0;
    reg SIM_RST = 1;
    reg BLKUPL_n = 1; 
    reg BMGXM = 0; 
    reg BMGXP = 0; 
    reg BMGYM = 0; 
    reg BMGYP = 0; 
    reg BMGZM = 0; 
    reg BMGZP = 0; 
    reg CDUFAL = 0; 
    reg CDUXM = 0; 
    reg CDUXP = 0; 
    reg CDUYM = 0; 
    reg CDUYP = 0; 
    reg CDUZM = 0; 
    reg CDUZP = 0; 
    reg CTLSAT = 0; 
    wire DBLTST; 
    reg DKBSNC = 0; 
    reg DKEND = 0; 
    reg DKSTRT = 0; 
    wire DOSCAL; 
    reg FLTOUT = 0;
    reg FREFUN = 0; 
    reg GATEX_n = 1; 
    reg GATEY_n = 1; 
    reg GATEZ_n = 1; 
    reg GCAPCL = 0; 
    reg GUIREL = 0; 
    reg HOLFUN = 0; 
    reg IMUCAG = 0; 
    reg IMUFAL = 0; 
    reg IMUOPR = 1; 
    reg IN3008 = 0; 
    reg IN3212 = 0; 
    reg IN3213 = 0; 
    wire IN3214; 
    reg IN3216 = 0; 
    reg IN3301 = 0; 
    reg ISSTOR = 0; 
    reg LEMATT = 0; 
    reg LFTOFF = 0; 
    reg LRIN0 = 0; 
    reg LRIN1 = 0; 
    reg LRRLSC = 0; 
    reg LVDAGD = 0; 
    wire MAMU; 
    reg MANmP = 0; 
    reg MANmR = 0; 
    reg MANmY = 0; 
    reg MANpP = 0; 
    reg MANpR = 0; 
    reg MANpY = 0; 
    reg MARK = 0; 
    wire MDT01; 
    wire MDT02; 
    wire MDT03; 
    wire MDT04; 
    wire MDT05; 
    wire MDT06; 
    wire MDT07; 
    wire MDT08; 
    wire MDT09; 
    wire MDT10; 
    wire MDT11; 
    wire MDT12; 
    wire MDT13; 
    wire MDT14; 
    wire MDT15; 
    wire MDT16; 
    wire MLDCH; 
    wire MLOAD; 
    wire MNHNC; 
    wire MNHRPT; 
    wire MNHSBF; 
    reg MNIMmP = 0; 
    reg MNIMmR = 0; 
    reg MNIMmY = 0; 
    reg MNIMpP = 0; 
    reg MNIMpR = 0; 
    reg MNIMpY = 0; 
    wire MONPAR; 
    wire MONWBK; 
    wire MRDCH; 
    wire MREAD; 
    reg MRKREJ = 0; 
    reg MRKRST = 0; 
    wire MSBSTP; 
    wire MSTP; 
    wire MSTRT; 
    wire MTCSAI; 
    reg MYCLMP = 0;
    reg NAVRST = 0; 
    wire NHALGA; 
    reg NHVFAL = 0; 
    reg NKEY1 = 0; 
    reg NKEY2 = 0; 
    reg NKEY3 = 0; 
    reg NKEY4 = 0; 
    reg NKEY5 = 0; 
    reg OPCDFL = 0; 
    reg OPMSW2 = 0; 
    reg OPMSW3 = 0; 
    reg PCHGOF = 0; 
    wire PIPAXm; 
    wire PIPAXp; 
    wire PIPAYm; 
    wire PIPAYp; 
    wire PIPAZm; 
    wire PIPAZp; 
    reg ROLGOF = 0; 
    reg RRIN0 = 0; 
    reg RRIN1 = 0; 
    reg RRPONA = 0; 
    reg RRRLSC = 0; 
    reg S4BSAB = 0; 
    wire SBYBUT; 
    reg SCAFAL = 0;
    reg SHAFTM = 0; 
    reg SHAFTP = 0; 
    reg SIGNX = 0; 
    reg SIGNY = 0; 
    reg SIGNZ = 0; 
    reg SMSEPR = 0; 
    reg SPSRDY = 0; 
    reg STRPRS = 0; 
    reg TEMPIN = 1; 
    reg TRANmX = 0; 
    reg TRANmY = 0; 
    reg TRANmZ = 0; 
    reg TRANpX = 0; 
    reg TRANpY = 0; 
    reg TRANpZ = 0; 
    reg TRNM = 0; 
    reg TRNP = 0; 
    reg TRST10 = 0; 
    reg TRST9 = 0; 
    reg ULLTHR = 0; 
    reg UPL0 = 0; 
    reg UPL1 = 0; 
    reg VFAIL = 0;
    reg XLNK0 = 0; 
    reg XLNK1 = 0; 
    reg ZEROP = 0; 
    reg n2FSFAL = 1;
    wire CDUXDP; 
    wire CDUXDM; 
    wire CDUYDP; 
    wire CDUYDM; 
    wire CDUZDP; 
    wire CDUZDM; 
    wire CLK; 
    wire DKDATA; 
    wire MBR1; 
    wire MBR2; 
    wire MCTRAL_n; 
    wire MGOJAM; 
    wire MGP_n; 
    wire MIIP; 
    wire MINHL; 
    wire MINKL; 
    wire MNISQ; 
    wire MON800; 
    wire MONWT; 
    wire MOSCAL_n; 
    wire MPAL_n; 
    wire MPIPAL_n; 
    wire MRAG; 
    wire MRCH; 
    wire MREQIN; 
    wire MRGG; 
    wire MRLG; 
    wire MRPTAL_n; 
    wire MRSC; 
    wire MRULOG; 
    wire MSCAFL_n; 
    wire MSCDBL_n; 
    wire MSP; 
    wire MSQ10; 
    wire MSQ11; 
    wire MSQ12; 
    wire MSQ13; 
    wire MSQ14; 
    wire MSQ16; 
    wire MSQEXT; 
    wire MST1; 
    wire MST2; 
    wire MST3; 
    wire MSTPIT_n; 
    wire MT01; 
    wire MT02; 
    wire MT03; 
    wire MT04; 
    wire MT05; 
    wire MT06; 
    wire MT07; 
    wire MT08; 
    wire MT09; 
    wire MT10; 
    wire MT11; 
    wire MTCAL_n; 
    wire MTCSA_n; 
    wire MVFAIL_n; 
    wire MWAG; 
    wire MWARNF_n; 
    wire MWATCH_n; 
    wire MWBBEG; 
    wire MWBG; 
    wire MWCH; 
    wire MWEBG; 
    wire MWFBG; 
    wire MWG; 
    wire MWL01; 
    wire MWL02; 
    wire MWL03; 
    wire MWL04; 
    wire MWL05; 
    wire MWL06; 
    wire MWL07; 
    wire MWL08; 
    wire MWL09; 
    wire MWL10; 
    wire MWL11; 
    wire MWL12; 
    wire MWL13; 
    wire MWL14; 
    wire MWL15; 
    wire MWL16; 
    wire MWLG; 
    wire MWQG; 
    wire MWSG; 
    wire MWYG; 
    wire MWZG; 
    wire PIPASW; 
    wire PIPDAT; 
    wire SBYREL_n;
    assign IN3214 = PROCEED;
    assign SBYBUT = PROCEED;
    assign p4VSW = (p4VDC && SBYREL_n);
    wire CLOCK;
    wire SIM_CLK;
    pll agc_clock (
        .inclk0(OSC_50),
        .c0(SIM_CLK),
        .c1(CLOCK)
    );
    wire STRT2;
    assign STRT2 = ~KEY0;
    reg [2:0] moding_counter = 3'b0;
    always @(posedge PIPASW) begin
        moding_counter <= moding_counter + 3'b1;
        if (moding_counter == 3'd6) begin
            moding_counter <= 3'b0;
        end
    end
    assign PIPAXm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAYm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAZm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAXp = PIPDAT && (moding_counter < 3'd3);
    assign PIPAYp = PIPDAT && (moding_counter < 3'd3);
    assign PIPAZp = PIPDAT && (moding_counter < 3'd3);
    fpga_ch77_alarm_box RestartMonitor (
        .p4VDC(p4VDC),
        .p4VSW(p4VSW),
        .GND(GND),
        .SIM_RST(SIM_RST),
        .SIM_CLK(SIM_CLK),
        .MCTRAL_n(MCTRAL_n),
        .MPAL_n(MPAL_n),
        .MRCH(MRCH),
        .MRPTAL_n(MRPTAL_n),
        .MSCAFL_n(MSCAFL_n),
        .MSCDBL_n(MSCDBL_n),
        .MT01(MT01),
        .MT05(MT05),
        .MT12(MT12),
        .MTCAL_n(MTCAL_n),
        .MVFAIL_n(MVFAIL_n),
        .MWATCH_n(MWATCH_n),
        .MWCH(MWCH),
        .MWL01(MWL01),
        .MWL02(MWL02),
        .MWL03(MWL03),
        .MWL04(MWL04),
        .MWL05(MWL05),
        .MWL06(MWL06),
        .MWSG(MWSG),
        .DBLTST(DBLTST),
        .DOSCAL(DOSCAL),
        .MAMU(MAMU),
        .MDT01(MDT01),
        .MDT02(MDT02),
        .MDT03(MDT03),
        .MDT04(MDT04),
        .MDT05(MDT05),
        .MDT06(MDT06),
        .MDT07(MDT07),
        .MDT08(MDT08),
        .MDT09(MDT09),
        .MDT10(MDT10),
        .MDT11(MDT11),
        .MDT12(MDT12),
        .MDT13(MDT13),
        .MDT14(MDT14),
        .MDT15(MDT15),
        .MDT16(MDT16),
        .MLDCH(MLDCH),
        .MLOAD(MLOAD),
        .MNHNC(MNHNC),
        .MNHRPT(MNHRPT),
        .MNHSBF(MNHSBF),
        .MONPAR(MONPAR),
        .MONWBK(MONWBK),
        .MRDCH(MRDCH),
        .MREAD(MREAD),
        .MSBSTP(MSBSTP),
        .MSTP(MSTP),
        .MSTRT(MSTRT),
        .MTCSAI(MTCSAI),
        .NHALGA(NHALGA)
    );
    fpga_agc AGC (
        .p4VDC(p4VDC),
        .p4VSW(p4VSW),
        .GND(GND),
        .SIM_RST(SIM_RST),
        .SIM_CLK(SIM_CLK),
        .BLKUPL_n(BLKUPL_n),
        .BMGXM(BMGXM),
        .BMGXP(BMGXP),
        .BMGYM(BMGYM),
        .BMGYP(BMGYP),
        .BMGZM(BMGZM),
        .BMGZP(BMGZP),
        .CAURST(CAURST),
        .CDUFAL(CDUFAL),
        .CDUXM(CDUXM),
        .CDUXP(CDUXP),
        .CDUYM(CDUYM),
        .CDUYP(CDUYP),
        .CDUZM(CDUZM),
        .CDUZP(CDUZP),
        .CLOCK(CLOCK),
        .CTLSAT(CTLSAT),
        .DBLTST(DBLTST),
        .DKBSNC(DKBSNC),
        .DKEND(DKEND),
        .DKSTRT(DKSTRT),
        .DOSCAL(DOSCAL),
        .EPCS_DATA(EPCS_DATA),
        .FLTOUT(FLTOUT),
        .FREFUN(FREFUN),
        .GATEX_n(GATEX_n),
        .GATEY_n(GATEY_n),
        .GATEZ_n(GATEZ_n),
        .GCAPCL(GCAPCL),
        .GUIREL(GUIREL),
        .HOLFUN(HOLFUN),
        .IMUCAG(IMUCAG),
        .IMUFAL(IMUFAL),
        .IMUOPR(IMUOPR),
        .IN3008(IN3008),
        .IN3212(IN3212),
        .IN3213(IN3213),
        .IN3214(IN3214),
        .IN3216(IN3216),
        .IN3301(IN3301),
        .ISSTOR(ISSTOR),
        .LEMATT(LEMATT),
        .LFTOFF(LFTOFF),
        .LRIN0(LRIN0),
        .LRIN1(LRIN1),
        .LRRLSC(LRRLSC),
        .LVDAGD(LVDAGD),
        .MAINRS(MAINRS),
        .MAMU(MAMU),
        .MANmP(MANmP),
        .MANmR(MANmR),
        .MANmY(MANmY),
        .MANpP(MANpP),
        .MANpR(MANpR),
        .MANpY(MANpY),
        .MARK(MARK),
        .MDT01(MDT01),
        .MDT02(MDT02),
        .MDT03(MDT03),
        .MDT04(MDT04),
        .MDT05(MDT05),
        .MDT06(MDT06),
        .MDT07(MDT07),
        .MDT08(MDT08),
        .MDT09(MDT09),
        .MDT10(MDT10),
        .MDT11(MDT11),
        .MDT12(MDT12),
        .MDT13(MDT13),
        .MDT14(MDT14),
        .MDT15(MDT15),
        .MDT16(MDT16),
        .MKEY1(MKEY1),
        .MKEY2(MKEY2),
        .MKEY3(MKEY3),
        .MKEY4(MKEY4),
        .MKEY5(MKEY5),
        .MLDCH(MLDCH),
        .MLOAD(MLOAD),
        .MNHNC(MNHNC),
        .MNHRPT(MNHRPT),
        .MNHSBF(MNHSBF),
        .MNIMmP(MNIMmP),
        .MNIMmR(MNIMmR),
        .MNIMmY(MNIMmY),
        .MNIMpP(MNIMpP),
        .MNIMpR(MNIMpR),
        .MNIMpY(MNIMpY),
        .MONPAR(MONPAR),
        .MONWBK(MONWBK),
        .MRDCH(MRDCH),
        .MREAD(MREAD),
        .MRKREJ(MRKREJ),
        .MRKRST(MRKRST),
        .MSTP(MSTP),
        .MSTRT(MSTRT),
        .MTCSAI(MTCSAI),
        .MYCLMP(MYCLMP),
        .NAVRST(NAVRST),
        .NHALGA(NHALGA),
        .NHVFAL(NHVFAL),
        .NKEY1(NKEY1),
        .NKEY2(NKEY2),
        .NKEY3(NKEY3),
        .NKEY4(NKEY4),
        .NKEY5(NKEY5),
        .OPCDFL(OPCDFL),
        .OPMSW2(OPMSW2),
        .OPMSW3(OPMSW3),
        .PCHGOF(PCHGOF),
        .PIPAXm(PIPAXm),
        .PIPAXp(PIPAXp),
        .PIPAYm(PIPAYm),
        .PIPAYp(PIPAYp),
        .PIPAZm(PIPAZm),
        .PIPAZp(PIPAZp),
        .ROLGOF(ROLGOF),
        .RRIN0(RRIN0),
        .RRIN1(RRIN1),
        .RRPONA(RRPONA),
        .RRRLSC(RRRLSC),
        .S4BSAB(S4BSAB),
        .SBYBUT(SBYBUT),
        .SCAFAL(SCAFAL),
        .SHAFTM(SHAFTM),
        .SHAFTP(SHAFTP),
        .SIGNX(SIGNX),
        .SIGNY(SIGNY),
        .SIGNZ(SIGNZ),
        .SMSEPR(SMSEPR),
        .SPSRDY(SPSRDY),
        .STRPRS(STRPRS),
        .STRT2(STRT2),
        .TEMPIN(TEMPIN),
        .TRANmX(TRANmX),
        .TRANmY(TRANmY),
        .TRANmZ(TRANmZ),
        .TRANpX(TRANpX),
        .TRANpY(TRANpY),
        .TRANpZ(TRANpZ),
        .TRNM(TRNM),
        .TRNP(TRNP),
        .TRST10(TRST10),
        .TRST9(TRST9),
        .ULLTHR(ULLTHR),
        .UPL0(UPL0),
        .UPL1(UPL1),
        .VFAIL(VFAIL),
        .XLNK0(XLNK0),
        .XLNK1(XLNK1),
        .ZEROP(ZEROP),
        .n2FSFAL(n2FSFAL),
        .CDUXDM(CDUXDM),
        .CDUXDP(CDUXDP),
        .CDUYDM(CDUYDM),
        .CDUYDP(CDUYDP),
        .CDUZDM(CDUZDM),
        .CDUZDP(CDUZDP),
        .CLK(CLK),
        .COMACT(COMACT),
        .DKDATA(DKDATA),
        .EPCS_ASDI(EPCS_ASDI),
        .EPCS_CSN(EPCS_CSN),
        .EPCS_DCLK(EPCS_DCLK),
        .KYRLS(KYRLS),
        .MBR1(MBR1),
        .MBR2(MBR2),
        .MCTRAL_n(MCTRAL_n),
        .MGOJAM(MGOJAM),
        .MGP_n(MGP_n),
        .MIIP(MIIP),
        .MINHL(MINHL),
        .MINKL(MINKL),
        .MNISQ(MNISQ),
        .MON800(MON800),
        .MONWT(MONWT),
        .MOSCAL_n(MOSCAL_n),
        .MPAL_n(MPAL_n),
        .MPIPAL_n(MPIPAL_n),
        .MRAG(MRAG),
        .MRCH(MRCH),
        .MREQIN(MREQIN),
        .MRGG(MRGG),
        .MRLG(MRLG),
        .MRPTAL_n(MRPTAL_n),
        .MRSC(MRSC),
        .MRULOG(MRULOG),
        .MSCAFL_n(MSCAFL_n),
        .MSCDBL_n(MSCDBL_n),
        .MSP(MSP),
        .MSQ10(MSQ10),
        .MSQ11(MSQ11),
        .MSQ12(MSQ12),
        .MSQ13(MSQ13),
        .MSQ14(MSQ14),
        .MSQ16(MSQ16),
        .MSQEXT(MSQEXT),
        .MST1(MST1),
        .MST2(MST2),
        .MST3(MST3),
        .MSTPIT_n(MSTPIT_n),
        .MT01(MT01),
        .MT02(MT02),
        .MT03(MT03),
        .MT04(MT04),
        .MT05(MT05),
        .MT06(MT06),
        .MT07(MT07),
        .MT08(MT08),
        .MT09(MT09),
        .MT10(MT10),
        .MT11(MT11),
        .MT12(MT12),
        .MTCAL_n(MTCAL_n),
        .MTCSA_n(MTCSA_n),
        .MVFAIL_n(MVFAIL_n),
        .MWAG(MWAG),
        .MWARNF_n(MWARNF_n),
        .MWATCH_n(MWATCH_n),
        .MWBBEG(MWBBEG),
        .MWBG(MWBG),
        .MWCH(MWCH),
        .MWEBG(MWEBG),
        .MWFBG(MWFBG),
        .MWG(MWG),
        .MWL01(MWL01),
        .MWL02(MWL02),
        .MWL03(MWL03),
        .MWL04(MWL04),
        .MWL05(MWL05),
        .MWL06(MWL06),
        .MWL07(MWL07),
        .MWL08(MWL08),
        .MWL09(MWL09),
        .MWL10(MWL10),
        .MWL11(MWL11),
        .MWL12(MWL12),
        .MWL13(MWL13),
        .MWL14(MWL14),
        .MWL15(MWL15),
        .MWL16(MWL16),
        .MWLG(MWLG),
        .MWQG(MWQG),
        .MWSG(MWSG),
        .MWYG(MWYG),
        .MWZG(MWZG),
        .OPEROR(OPEROR),
        .PIPASW(PIPASW),
        .PIPDAT(PIPDAT),
        .RESTRT(RESTRT),
        .RLYB01(RLYB01),
        .RLYB02(RLYB02),
        .RLYB03(RLYB03),
        .RLYB04(RLYB04),
        .RLYB05(RLYB05),
        .RLYB06(RLYB06),
        .RLYB07(RLYB07),
        .RLYB08(RLYB08),
        .RLYB09(RLYB09),
        .RLYB10(RLYB10),
        .RLYB11(RLYB11),
        .RYWD12(RYWD12),
        .RYWD13(RYWD13),
        .RYWD14(RYWD14),
        .RYWD16(RYWD16),
        .SBYLIT(SBYLIT),
        .SBYREL_n(SBYREL_n),
        .TMPCAU(TMPCAU),
        .UPLACT(UPLACT),
        .VNFLSH(VNFLSH)
    );
endmodule