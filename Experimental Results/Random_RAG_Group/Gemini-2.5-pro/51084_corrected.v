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
    output wire MT12,
    input wire test_i
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
    assign p4VSW = (p4VDC && SBYREL_n);
    assign IN3214 = PROCEED;
    assign SBYBUT = PROCEED;
    wire CLOCK;
    wire SIM_CLK, dft_sim_clk;
    pll agc_clock(OSC_50, SIM_CLK, CLOCK);
    assign dft_sim_clk = test_i ? OSC_50 : SIM_CLK;
    wire STRT2;
    assign STRT2 = ~KEY0;
    reg [2:0] moding_counter = 3'b0;
    always @(posedge PIPASW) begin
        moding_counter = moding_counter + 3'b1;
        if (moding_counter == 3'd6) begin
            moding_counter = 3'b0;
        end
    end
    assign PIPAXm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAYm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAZm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAXp = PIPDAT && (moding_counter < 3'd3);
    assign PIPAYp = PIPDAT && (moding_counter < 3'd3);
    assign PIPAZp = PIPDAT && (moding_counter < 3'd3);
    fpga_ch77_alarm_box RestartMonitor(
        p4VDC, p4VSW, GND, SIM_RST, dft_sim_clk, MCTRAL_n, MPAL_n, MRCH, MRPTAL_n, 
        MSCAFL_n, MSCDBL_n, MT01, MT05, MT12, MTCAL_n, MVFAIL_n, MWATCH_n, MWCH, 
        MWL01, MWL02, MWL03, MWL04, MWL05, MWL06, MWSG, DBLTST, DOSCAL, MAMU, 
        MDT01, MDT02, MDT03, MDT04, MDT05, MDT06, MDT07, MDT08, MDT09, MDT10, 
        MDT11, MDT12, MDT13, MDT14, MDT15, MDT16, MLDCH, MLOAD, MNHNC, MNHRPT, 
        MNHSBF, MONPAR, MONWBK, MRDCH, MREAD, MSBSTP, MSTP, MSTRT, MTCSAI, NHALGA
    );
    fpga_agc AGC(
        p4VDC, p4VSW, GND, SIM_RST, dft_sim_clk, BLKUPL_n, BMGXM, BMGXP, BMGYM, BMGYP, 
        BMGZM, BMGZP, CAURST, CDUFAL, CDUXM, CDUXP, CDUYM, CDUYP, CDUZM, CDUZP, CLOCK, 
        CTLSAT, DBLTST, DKBSNC, DKEND, DKSTRT, DOSCAL, EPCS_DATA, FLTOUT, FREFUN, 
        GATEX_n, GATEY_n, GATEZ_n, GCAPCL, GUIREL, HOLFUN, IMUCAG, IMUFAL, IMUOPR, 
        IN3008, IN3212, IN3213, IN3214, IN3216, IN3301, ISSTOR, LEMATT, LFTOFF, 
        LRIN0, LRIN1, LRRLSC, LVDAGD, MAINRS, MAMU, MANmP, MANmR, MANmY, MANpP, 
        MANpR, MANpY, MARK, MDT01, MDT02, MDT03, MDT04, MDT05, MDT06, MDT07, 
        MDT08, MDT09, MDT10, MDT11, MDT12, MDT13, MDT14, MDT15, MDT16, MKEY1, 
        MKEY2, MKEY3, MKEY4, MKEY5, MLDCH, MLOAD, MNHNC, MNHRPT, MNHSBF, MNIMmP, 
        MNIMmR, MNIMmY, MNIMpP, MNIMpR, MNIMpY, MONPAR, MONWBK, MRDCH, MREAD, 
        MRKREJ, MRKRST, MSTP, MSTRT, MTCSAI, MYCLMP, NAVRST, NHALGA, NHVFAL, 
        NKEY1, NKEY2, NKEY3, NKEY4, NKEY5, OPCDFL, OPMSW2, OPMSW3, PCHGOF, 
        PIPAXm, PIPAXp, PIPAYm, PIPAYp, PIPAZm, PIPAZp, ROLGOF, RRIN0, RRIN1, 
        RRPONA, RRRLSC, S4BSAB, SBYBUT, SCAFAL, SHAFTM, SHAFTP, SIGNX, SIGNY, 
        SIGNZ, SMSEPR, SPSRDY, STRPRS, STRT2, TEMPIN, TRANmX, TRANmY, TRANmZ, 
        TRANpX, TRANpY, TRANpZ, TRNM, TRNP, TRST10, TRST9, ULLTHR, UPL0, UPL1, 
        VFAIL, XLNK0, XLNK1, ZEROP, n2FSFAL, CDUXDM, CDUXDP, CDUYDM, CDUYDP, 
        CDUZDM, CDUZDP, CLK, COMACT, DKDATA, EPCS_ASDI, EPCS_CSN, EPCS_DCLK, 
        KYRLS, MBR1, MBR2, MCTRAL_n, MGOJAM, MGP_n, MIIP, MINHL, MINKL, MNISQ, 
        MON800, MONWT, MOSCAL_n, MPAL_n, MPIPAL_n, MRAG, MRCH, MREQIN, MRGG, 
        MRLG, MRPTAL_n, MRSC, MRULOG, MSCAFL_n, MSCDBL_n, MSP, MSQ10, MSQ11, 
        MSQ12, MSQ13, MSQ14, MSQ16, MSQEXT, MST1, MST2, MST3, MSTPIT_n, MT01, 
        MT02, MT03, MT04, MT05, MT06, MT07, MT08, MT09, MT10, MT11, MT12, 
        MTCAL_n, MTCSA_n, MVFAIL_n, MWAG, MWARNF_n, MWATCH_n, MWBBEG, MWBG, 
        MWCH, MWEBG, MWFBG, MWG, MWL01, MWL02, MWL03, MWL04, MWL05, MWL06, 
        MWL07, MWL08, MWL09, MWL10, MWL11, MWL12, MWL13, MWL14, MWL15, MWL16, 
        MWLG, MWQG, MWSG, MWYG, MWZG, OPEROR, PIPASW, PIPDAT, RESTRT, RLYB01, 
        RLYB02, RLYB03, RLYB04, RLYB05, RLYB06, RLYB07, RLYB08, RLYB09, RLYB10, 
        RLYB11, RYWD12, RYWD13, RYWD14, RYWD16, SBYLIT, SBYREL_n, TMPCAU, UPLACT, 
        VNFLSH
    );
endmodule