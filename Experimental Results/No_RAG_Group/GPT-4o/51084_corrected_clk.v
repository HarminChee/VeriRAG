`timescale 1ns/1ps
`default_nettype none

module de0_nano_agc(
    input wire OSC_50,
    input wire EPCS_DATA,
    input wire KEY0,
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
    wire SIM_CLK;
    wire CLOCK;
    wire CLK;
    wire STRT2;
    assign STRT2 = ~KEY0;

    wire IN3214;
    assign IN3214 = PROCEED;
    wire SBYBUT;
    assign SBYBUT = PROCEED;

    assign p4VSW = (p4VDC && SBYREL_n);

    pll agc_clock(OSC_50, SIM_CLK, CLOCK);

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
        p4VDC, p4VSW, GND, SIM_RST, OSC_50, MCTRAL_n, MPAL_n, MRCH, MRPTAL_n,
        MSCAFL_n, MSCDBL_n, MT01, MT05, MT12, MTCAL_n, MVFAIL_n, MWATCH_n, MWCH, 
        MWL01, MWL02, MWL03, MWL04, MWL05, MWL06, MWSG, DBLTST, DOSCAL, MAMU,
        MDT01, MDT02, MDT03, MDT04, MDT05, MDT06, MDT07, MDT08, MDT09, MDT10,
        MDT11, MDT12, MDT13, MDT14, MDT15, MDT16, MLDCH, MLOAD, MNHNC, MNHRPT,
        MNHSBF, MONPAR, MONWBK, MRDCH, MREAD, MSBSTP, MSTP, MSTRT, MTCSAI, NHALGA
    );

    fpga_agc AGC(
        p4VDC, p4VSW, GND, SIM_RST, OSC_50, BLKUPL_n, BMGXM, BMGXP, BMGYM, BMGYP, 
        BMGZM, BMGZP, CAURST, CDUFAL, CDUXM, CDUXP, CDUYM, CDUYP, CDUZM, CDUZP,
        CLOCK, CTLSAT, DBLTST, DKBSNC, DKEND, DKSTRT, DOSCAL, EPCS_DATA, FLTOUT, 
        FREFUN, GATEX_n, GATEY_n, GATEZ_n, GCAPCL, GUIREL, HOLFUN, IMUCAG, IMUFAL, 
        IMUOPR, IN3008, IN3212, IN3213, IN3214, IN3216, IN3301, ISSTOR, LEMATT, 
        LFTOFF, LRIN0, LRIN1, LRRLSC, LVDAGD, MAINRS, MAMU, MANmP, MANmR, MANmY, 
        MANpP, MANpR, MANpY, MARK, MDT01, MDT02, MDT03, MDT04, MDT05, MDT06, MDT07, 
        MDT08, MDT09, MDT10, MDT11, MDT12, MDT13, MDT14, MDT15, MDT16, MKEY1, MKEY2, 
        MKEY3, MKEY4, MKEY5, MLDCH, MLOAD, MNHNC, MNHRPT, MNHSBF, MNIMmP, MNIMmR, 
        MNIMmY, MNIMpP, MNIMpR, MNIMpY, MONPAR, MONWBK, MRDCH, MREAD, MRKREJ, MRKRST, 
        MSTP, MSTRT, MTCSAI, MYCLMP, NAVRST, NHALGA, NHVFAL, NKEY1, NKEY2, NKEY3, 
        NKEY4, NKEY5, OPCDFL, OPMSW2, OPMSW3, PCHGOF, PIPAXm, PIPAXp, PIPAYm, 
        PIPAYp, PIPAZm, PIPAZp, ROLGOF, RRIN0, RRIN1, RRPONA, RRRLSC, S4BSAB, SBYBUT, 
        SCAFAL, SHAFTM, SHAFTP, SIGNX, SIGNY, SIGNZ, SMSEPR, SPSRDY, STRPRS, STRT2, 
        TEMPIN, TRANmX, TRANmY, TRANmZ, TRANpX, TRANpY, TRANpZ, TRNM, TRNP, TRST10, 
        TRST9, ULLTHR, UPL0, UPL1, VFAIL, XLNK0, XLNK1, ZEROP, n2FSFAL, CDUXDM, 
        CDUXDP, CDUYDM, CDUYDP, CDUZDM, CDUZDP, CLK, COMACT, DKDATA, EPCS_ASDI, 
        EPCS_CSN, EPCS_DCLK, KYRLS, MBR1, MBR2, MCTRAL_n, MGOJAM, MGP_n, MIIP, 
        MINHL, MINKL, MNISQ, MON800, MONWT, MOSCAL_n, MPAL_n, MPIPAL_n, MRAG, MRCH, 
        MREQIN, MRGG, MRLG, MRPTAL_n, MRSC, MRULOG, MSCAFL_n, MSCDBL_n, MSP, MSQ10, 
        MSQ11, MSQ12, MSQ13, MSQ14, MSQ16, MSQEXT, MST1, MST2, MST3, MSTPIT_n, MT01, 
        MT02, MT03, MT04, MT05, MT06, MT07, MT08, MT09, MT10, MT11, MT12, MTCAL_n, 
        MTCSA_n, MVFAIL_n, MWAG, MWARNF_n, MWATCH_n, MWBBEG, MWBG, MWCH, MWEBG, 
        MWFBG, MWG, MWL01, MWL02, MWL03, MWL04, MWL05, MWL06, MWL07, MWL08, MWL09, 
        MWL10, MWL11, MWL12, MWL13, MWL14, MWL15, MWL16, MWLG, MWQG, MWSG, MWYG, 
        MWZG, OPEROR, PIPASW, PIPDAT, RESTRT, RLYB01, RLYB02, RLYB03, RLYB04, 
        RLYB05, RLYB06, RLYB07, RLYB08, RLYB09, RLYB10, RLYB11, RYWD12, RYWD13, 
        RYWD14, RYWD16, SBYLIT, SBYREL_n, TMPCAU, UPLACT, VNFLSH
    );

endmodule