`timescale 1ns / 1ps
`define DLY #1

module DdrCtl1 (
    input wire         clock0,
    input wire         clock90,
    input wire         reset,
    input wire [11:0]  inst,
    input wire         inst_en,
    output wire [31:0] page,
    output wire        ready,
    input wire         ddr_clock0,
    input wire         ddr_clock90,
    input wire         ddr_clock270,
    output reg         ddr_cke,
    output reg         ddr_csn,
    output reg         ddr_rasn,
    output reg         ddr_casn,
    output reg         ddr_wen,
    output reg [1:0]   ddr_ba,
    output reg [12:0]  ddr_addr,
    output wire [1:0]  ddr_dm,
    inout wire [15:0]  ddr_dq,
    inout wire [1:0]   ddr_dqs
);

    reg [2:0]          s_IntfState;
    reg [31:0]         s_IntfAddress;
    reg [31:0]         s_IntfPage;
    reg                i_IntfDoRead;
    reg                i_IntfDoWrite;
    reg [3:0]          s_CoreState;
    reg [4:0]          i_CoreCommand;
    reg [1:0]          i_CoreBank;
    reg [12:0]         i_CoreAddr;
    reg                i_CoreTakeCommand0;
    reg                i_CoreTakeCommand1;
    reg                i_CoreTakeCommand2;
    reg                i_CoreTakeCommand3;
    reg                i_CoreRefreshDone;
    reg                i_CoreReadDone;
    reg                i_CoreWriteDone;
    reg [4:0]          s_InitState;
    reg [4:0]          i_InitCommand;
    reg [1:0]          i_InitBank;
    reg [12:0]         i_InitAddr;
    reg                i_InitTakeCommand0;
    reg                i_InitTakeCommand1;
    reg                i_InitDone;
    reg                i_InitDo200us;
    reg                i_InitDo200;
    reg [8:0]          s_AutoRefreshCounter;
    reg                i_AutoRefreshDoRefresh;
    reg [13:0]         s_InitCnt200usCounter;
    reg                i_InitCnt200usDone;
    reg [7:0]          s_InitCnt200Counter;
    reg                i_InitCnt200Done;
    reg [15:0]         s_HalfPage0;
    reg [15:0]         s_HalfPage1;
    wire               i_Ready;
    wire [3:0]         w_InstCode;
    wire [7:0]         w_InstImm;

    assign page = s_IntfPage;
    assign ready = i_Ready;

    always @ * begin
        if (i_InitDone) begin
            if (i_CoreTakeCommand0 && clock90) begin
                ddr_cke   = i_CoreCommand[4];
                ddr_csn   = i_CoreCommand[3];
                ddr_rasn  = i_CoreCommand[2];
                ddr_casn  = i_CoreCommand[1];
                ddr_wen   = i_CoreCommand[0];
                ddr_ba    = i_CoreBank;
                ddr_addr  = i_CoreAddr;
            end else begin
                ddr_cke   = 1;
                ddr_csn   = 0;
                ddr_rasn  = 1;
                ddr_casn  = 1;
                ddr_wen   = 1;
                ddr_ba    = 2'b00;
                ddr_addr  = 13'b0000000000000;
            end
        end else begin
            if (i_InitTakeCommand0 || (i_InitTakeCommand1 && clock90)) begin
                ddr_cke   = i_InitCommand[4];
                ddr_csn   = i_InitCommand[3];
                ddr_rasn  = i_InitCommand[2];
                ddr_casn  = i_InitCommand[1];
                ddr_wen   = i_InitCommand[0];
                ddr_ba    = i_InitBank;
                ddr_addr  = i_InitAddr;
            end else begin
                ddr_cke   = 1;
                ddr_csn   = 0;
                ddr_rasn  = 1;
                ddr_casn  = 1;
                ddr_wen   = 1;
                ddr_ba    = 2'b00;
                ddr_addr  = 13'b0000000000000;
            end
        end
    end

    assign ddr_dm  = 2'b00;
    assign ddr_dq  = i_CoreTakeCommand1 ? (ddr_clock90 == 0 ? s_IntfPage[31:16] : s_IntfPage[15:0]) : 16'bz;
    assign ddr_dqs = (i_CoreTakeCommand2 || i_CoreTakeCommand3) ? {ddr_clock0, ddr_clock0} : 2'bz;
    assign w_InstCode = inst[11:8];
    assign w_InstImm  = inst[7:0];
    assign i_Ready    = (s_IntfState == 3'h2) && (s_CoreState == 4'h2) &&
                        (w_InstCode != 4'h9) && (w_InstCode != 4'hA);

    always @ (posedge clock0) begin
        if (reset) begin
            s_IntfState   <= 3'h0;
            s_IntfAddress <= 0;
            s_IntfPage    <= 0;
            i_IntfDoRead  <= 0;
            i_IntfDoWrite <= 0;
        end else begin
            case (s_IntfState)
                3'h0: begin
                    s_IntfState   <= 3'h1;
                    s_IntfAddress <= 0;
                    s_IntfPage    <= 0;
                    i_IntfDoRead  <= 0;
                    i_IntfDoWrite <= 0;
                end
                3'h1: begin
                    if (i_InitDone) begin
                        s_IntfState   <= 3'h2;
                        s_IntfAddress <= 0;
                        s_IntfPage    <= 0;
                        i_IntfDoRead  <= 0;
                        i_IntfDoWrite <= 0;
                    end
                end
                3'h2: begin
                    if (inst_en) begin
                        case (w_InstCode)
                            4'h0:  s_IntfState <= 3'h2;
                            4'h1:  s_IntfAddress[7:0]  <= w_InstImm;
                            4'h2:  s_IntfAddress[15:8] <= w_InstImm;
                            4'h3:  s_IntfAddress[23:16] <= w_InstImm;
                            4'h4:  s_IntfAddress[31:24] <= w_InstImm;
                            4'h5:  s_IntfPage[7:0]  <= w_InstImm;
                            4'h6:  s_IntfPage[15:8] <= w_InstImm;
                            4'h7:  s_IntfPage[23:16] <= w_InstImm;
                            4'h8:  s_IntfPage[31:24] <= w_InstImm;
                            4'h9:  s_IntfState <= 3'h3;
                            4'hA:  s_IntfState <= 3'h4;
                            default: s_IntfState <= 3'h5;
                        endcase
                    end
                end
                3'h3: if (i_CoreReadDone) s_IntfState <= 3'h2;
                3'h4: if (i_CoreWriteDone) s_IntfState <= 3'h2;
                3'h5: s_IntfState <= 3'h5;
                default: s_IntfState <= 3'h5;
            endcase
        end
    end

endmodule