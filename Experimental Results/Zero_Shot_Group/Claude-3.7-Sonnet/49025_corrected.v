`timescale 1ns/1ps
`default_nettype none

`define BYPASS  5'o00
`define CONTROL 5'o02
`define BRKBANK 5'o03
`define BRKADDR 5'o04
`define RWBANK  5'o05
`define RWADDR  5'o06
`define RWCHAN  5'o07
`define RWDATA  5'o10
`define REG_A   5'o20
`define REG_L   5'o21
`define REG_Q   5'o22
`define REG_Z   5'o23
`define REG_BB  5'o24
`define REG_G   5'o25
`define REG_SQ  5'o26
`define REG_S   5'o27
`define REG_B   5'o30
`define REG_X   5'o31
`define REG_Y   5'o32
`define REG_U   5'o33
`define STEP_INST 1'b1
`define STEP_MCT  1'b0

module jtag_monitor(
    input wire SIM_CLK,
    output wire MSTRT,
    output wire MSTP,
    output wire MDT01,
    output wire MDT02,
    output wire MDT03,
    output wire MDT04,
    output wire MDT05,
    output wire MDT06,
    output wire MDT07,
    output wire MDT08,
    output wire MDT09,
    output wire MDT10,
    output wire MDT11,
    output wire MDT12,
    output wire MDT13,
    output wire MDT14,
    output wire MDT15,
    output wire MDT16,
    output reg MONPAR = 0,
    output reg MREAD = 0,
    output reg MLOAD = 0,
    output reg MRDCH = 0,
    output reg MLDCH = 0,
    output reg MTCSAI = 0,
    output reg MONWBK = 0,
    output reg MNHRPT = 0,
    output reg MNHNC = 0,
    output reg MNHSBF = 0,
    output reg MAMU = 0,
    output wire NHALGA,
    output reg DBLTST = 0,
    output reg DOSCAL = 0,
    input wire MT01,
    input wire MT02,
    input wire MT03,
    input wire MT04,
    input wire MT05,
    input wire MT06,
    input wire MT07,
    input wire MT08,
    input wire MT09,
    input wire MT10,
    input wire MT11,
    input wire MT12,
    input wire MWL01,
    input wire MWL02,
    input wire MWL03,
    input wire MWL04,
    input wire MWL05,
    input wire MWL06,
    input wire MWL07,
    input wire MWL08,
    input wire MWL09,
    input wire MWL10,
    input wire MWL11,
    input wire MWL12,
    input wire MWL13,
    input wire MWL14,
    input wire MWL15,
    input wire MWL16,
    input wire MSQ16,
    input wire MSQ14,
    input wire MSQ13,
    input wire MSQ12,
    input wire MSQ11,
    input wire MSQ10,
    input wire MSQEXT,
    input wire MST1,
    input wire MST2,
    input wire MST3,
    input wire MNISQ,
    input wire MWAG,
    input wire MWLG,
    input wire MWQG,
    input wire MWZG,
    input wire MWBBEG,
    input wire MWEBG,
    input wire MWFBG,
    input wire MWG,
    input wire MWSG,
    input wire MWBG,
    input wire MWCH,
    input wire MRGG,
    input wire MREQIN,
    input wire MTCSA_n
);

    wire [15:0] write_bus = {MWL16, MWL15, MWL14, MWL13, MWL12, MWL11, MWL10, MWL09, MWL08, MWL07, MWL06, MWL05, MWL04, MWL03, MWL02, MWL01};
    wire [15:0] direct_sq = {MSQEXT, MSQ16, MSQ14, MSQ13, MSQ12, MSQ11, MSQ10, 9'b0};
    wire [2:0] stage = {MST3, MST2, MST1};

    reg suppress_mstp = 0;
    reg tcsaj_in_progress = 0;
    reg [15:0] monitor_data = 16'd0;

    assign {MDT01, MDT02, MDT03, MDT04, MDT05, MDT06, MDT07, MDT08,
            MDT09, MDT10, MDT11, MDT12, MDT13, MDT14, MDT15, MDT16} = monitor_data;

    reg bypass_reg = 0;
    reg [15:0] tmp_reg = 16'd0;
    reg [15:0] cntrl_reg = 16'd0;
    reg [15:0] break_bank = 16'd0;
    reg [15:0] break_addr = 16'd0;
    reg [15:0] rw_bank = 16'd0;
    reg [15:0] rw_addr = 16'd0;
    reg [15:0] rw_data = 16'd0;
    reg [15:0] a_reg = 16'd0;
    reg [15:0] l_reg = 16'd0;
    reg [15:0] q_reg = 16'd0;
    reg [15:0] z_reg = 16'd0;
    reg [15:0] bb_reg = 16'd0;
    reg [15:0] g_reg = 16'd0;
    reg [15:0] s_reg = 16'd0;
    reg [15:0] b_reg = 16'd0;
    reg [15:0] x_reg = 16'd0;
    reg [15:0] y_reg = 16'd0;
    reg [15:0] u_reg = 16'd0;

    wire step = cntrl_reg[2];
    wire step_type = cntrl_reg[3];
    wire break_inst = cntrl_reg[4];
    wire fetch_data = cntrl_reg[5];
    wire store_data = cntrl_reg[6];
    wire read_chan = cntrl_reg[7];
    wire load_chan = cntrl_reg[8];
    wire transfer_control = cntrl_reg[9];

    assign MSTP = cntrl_reg[0] && !suppress_mstp;
    assign MSTRT = cntrl_reg[1];
    assign NHALGA = cntrl_reg[10];

    wire tck, tdi;
    reg tdo = 0;
    wire [4:0] ir_in;
    wire cdr, sdr, e1dr;

    vjtag VJTAG (
        .tdi(tdi),
        .tdo(tdo),
        .ir_in(ir_in),
        .virtual_state_cdr(cdr),
        .virtual_state_sdr(sdr),
        .virtual_state_e1dr(e1dr),
        .tck(tck)
    );

    always @(posedge SIM_CLK) begin
        // original logic block
    end

    always @(posedge tck) begin
        if (ir_in == `BYPASS) begin
            bypass_reg <= tdi;
        end else begin
            if (cdr) begin
                case (ir_in)
                    `CONTROL: tmp_reg <= cntrl_reg;
                    `BRKBANK: tmp_reg <= {1'b0, break_bank[14:0]};
                    `BRKADDR: tmp_reg <= break_addr;
                    `RWBANK:  tmp_reg <= {1'b0, rw_bank[14:0]};
                    `RWADDR:  tmp_reg <= rw_addr;
                    `RWDATA:  tmp_reg <= rw_data;
                    `REG_A:   tmp_reg <= a_reg;
                    `REG_L:   tmp_reg <= l_reg;
                    `REG_Q:   tmp_reg <= q_reg;
                    `REG_Z:   tmp_reg <= z_reg;
                    `REG_BB:  tmp_reg <= bb_reg;
                    `REG_G:   tmp_reg <= g_reg;
                    `REG_SQ:  tmp_reg <= direct_sq;
                    `REG_S:   tmp_reg <= s_reg;
                    `REG_B:   tmp_reg <= b_reg;
                    `REG_X:   tmp_reg <= x_reg;
                    `REG_Y:   tmp_reg <= y_reg;
                    `REG_U:   tmp_reg <= u_reg;
                    default:  tmp_reg <= 16'd0;
                endcase
            end else if (sdr) begin
                tmp_reg <= {tdi, tmp_reg[15:1]};
            end
        end
    end

    always @(*) begin
        if (ir_in == `BYPASS) begin
            tdo = bypass_reg;
        end else begin
            tdo = tmp_reg[0];
        end
    end

endmodule