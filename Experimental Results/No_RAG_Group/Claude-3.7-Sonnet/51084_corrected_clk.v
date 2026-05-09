`timescale 1ns/1ps
`default_nettype none
module de0_nano_agc(
    input wire OSC_50,
    input wire KEY0,
    input wire EPCS_DATA,
    input wire CAURST,
    input wire MAINRS,
    input wire MKEY1,
    input wire MKEY2, 
    input wire MKEY3,
    input wire MKEY4,
    input wire MKEY5,
    input wire PROCEED,
    output wire EPCS_CSN,
    output wire EPCS_DCLK,
    output wire EPCS_ASDI,
    output wire COMACT,
    output wire KYRLS,
    output wire OPEROR,
    output wire RESTRT,
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
    // ... existing code ...

    assign p4VSW = (p4VDC && SBYREL_n);
    assign IN3214 = PROCEED;
    assign SBYBUT = PROCEED;

    wire CLOCK;
    wire SIM_CLK;
    wire CLK_PRIMARY;

    // Use primary input clock
    assign CLK_PRIMARY = OSC_50;
    
    pll agc_clock(
        .clk_in(CLK_PRIMARY),
        .sim_clk(SIM_CLK),
        .clock_out(CLOCK)
    );

    wire STRT2;
    assign STRT2 = ~KEY0;

    reg [2:0] moding_counter = 3'b0;
    
    // Clock moding_counter with primary input clock
    always @(posedge CLK_PRIMARY) begin
        if (PIPASW) begin
            moding_counter <= moding_counter + 3'b1;
            if (moding_counter == 3'd6) begin
                moding_counter <= 3'b0;
            end
        end
    end

    assign PIPAXm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAYm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAZm = PIPDAT && (moding_counter >= 3'd3);
    assign PIPAXp = PIPDAT && (moding_counter < 3'd3);
    assign PIPAYp = PIPDAT && (moding_counter < 3'd3);
    assign PIPAZp = PIPDAT && (moding_counter < 3'd3);

    fpga_ch77_alarm_box RestartMonitor(
        // ... existing code ...
    );

    fpga_agc AGC(
        // ... existing code ...
    );

endmodule