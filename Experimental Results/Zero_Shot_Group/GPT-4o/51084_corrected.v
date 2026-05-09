`timescale 1ns/1ps
`default_nettype none

module de0_nano_agc (
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
    wire SBYREL_n;
    wire CLOCK;
    wire SIM_CLK;

    pll agc_clock (
        .clk_in(OSC_50),
        .clk_out1(SIM_CLK),
        .clk_out2(CLOCK)
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
        .MT12(MT12),
        .COMACT(COMACT),
        .KYRLS(KYRLS),
        .RESTRT(RESTRT),
        .OPEROR(OPEROR)
    );

    fpga_agc AGC (
        .p4VDC(p4VDC),
        .p4VSW(p4VSW),
        .GND(GND),
        .SIM_RST(SIM_RST),
        .SIM_CLK(SIM_CLK),
        .CLOCK(CLOCK),
        .MAINRS(MAINRS),
        .CAURST(CAURST),
        .MKEY1(MKEY1),
        .MKEY2(MKEY2),
        .MKEY3(MKEY3),
        .MKEY4(MKEY4),
        .MKEY5(MKEY5),
        .PROCEED(PROCEED),
        .MT12(MT12),
        .COMACT(COMACT),
        .KYRLS(KYRLS),
        .RESTRT(RESTRT),
        .OPEROR(OPEROR),
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
        .TMPCAU(TMPCAU),
        .UPLACT(UPLACT),
        .VNFLSH(VNFLSH)
    );

endmodule