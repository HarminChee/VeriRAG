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

    wire [15:0] write_bus;
    assign write_bus = {MWL16, MWL15, MWL14, MWL13, MWL12, MWL11, MWL10, MWL09, MWL08, MWL07, MWL06, MWL05, MWL04, MWL03, MWL02, MWL01};
    wire [15:0] direct_sq;
    assign direct_sq = {MSQEXT, MSQ16, MSQ14, MSQ13, MSQ12, MSQ11, MSQ10, 9'b0};
    wire [2:0] stage;
    assign stage = {MST3, MST2, MST1};
    reg suppress_mstp = 1'b0;
    reg tcsaj_in_progress = 1'b0;
    reg [15:0] monitor_data;
    assign MDT01 = monitor_data[0];
    assign MDT02 = monitor_data[1];
    assign MDT03 = monitor_data[2];
    assign MDT04 = monitor_data[3];
    assign MDT05 = monitor_data[4];
    assign MDT06 = monitor_data[5];
    assign MDT07 = monitor_data[6];
    assign MDT08 = monitor_data[7];
    assign MDT09 = monitor_data[8];
    assign MDT10 = monitor_data[9];
    assign MDT11 = monitor_data[10];
    assign MDT12 = monitor_data[11];
    assign MDT13 = monitor_data[12];
    assign MDT14 = monitor_data[13];
    assign MDT15 = monitor_data[14];
    assign MDT16 = monitor_data[15];
    reg bypass_reg = 0;
    reg [15:0] tmp_reg;
    reg [15:0] cntrl_reg = 16'o0;
    reg [15:0] break_bank = 16'o0;
    reg [15:0] break_addr = 16'o0;
    reg [15:0] rw_bank = 16'o0;
    reg [15:0] rw_addr = 16'o0;
    reg [15:0] rw_data = 16'o0;
    reg [15:0] a_reg = 16'o0;
    reg [15:0] l_reg = 16'o0;
    reg [15:0] q_reg = 16'o0;
    reg [15:0] z_reg = 16'o0;
    reg [15:0] bb_reg = 16'o0;
    reg [15:0] g_reg = 16'o0;
    reg [15:0] s_reg = 16'o0;
    reg [15:0] b_reg = 16'o0;
    reg [15:0] x_reg = 16'o0;
    reg [15:0] y_reg = 16'o0;
    reg [15:0] u_reg = 16'o0;
    wire step;
    wire step_type;
    wire break_inst;
    wire fetch_data;
    wire store_data;
    wire read_chan;
    wire load_chan;
    wire transfer_control;
    assign MSTP = cntrl_reg[0] && !suppress_mstp;
    assign MSTRT = cntrl_reg[1];
    assign step = cntrl_reg[2];
    assign step_type = cntrl_reg[3];
    assign break_inst = cntrl_reg[4];
    assign fetch_data = cntrl_reg[5];
    assign store_data = cntrl_reg[6];
    assign read_chan = cntrl_reg[7];
    assign load_chan = cntrl_reg[8];
    assign transfer_control = cntrl_reg[9];
    assign NHALGA = cntrl_reg[10];
    wire tck, tdi;
    reg tdo = 0;
    wire [4:0] ir_in;
    wire cdr, sdr, e1dr;

    vjtag VJTAG (
        .tdi                (tdi),
        .tdo                (tdo),
        .ir_in              (ir_in),
        .virtual_state_cdr  (cdr),
        .virtual_state_sdr  (sdr),
        .virtual_state_e1dr (e1dr),
        .tck                (tck)
    );

    always @(posedge SIM_CLK) begin
        if (e1dr) begin
            case (ir_in)
                `CONTROL: begin
                    if (tmp_reg[15] == 1'b1) begin
                        cntrl_reg[14:0] <= tmp_reg[14:0];
                    end
                end
                `BRKBANK: begin
                    if (tmp_reg[15] == 1'b1) begin
                        break_bank[15] <= tmp_reg[14];
                        break_bank[14:0] <= tmp_reg[14:0];
                    end
                end
                `BRKADDR: begin
                    if (tmp_reg[15] == 1'b1) begin
                        break_addr[14:0] <= tmp_reg[14:0];
                    end
                end
                `RWBANK: begin
                    if (tmp_reg[15] == 1'b1) begin
                        rw_bank[15] <= tmp_reg[14];
                        rw_bank[14:0] <= tmp_reg[14:0];
                    end
                end
                `RWADDR: begin
                    if (tmp_reg[15] == 1'b1) begin
                        rw_addr[14:0] <= tmp_reg[14:0];
                    end
                end
                `RWDATA: begin
                    rw_data[15:0] <= tmp_reg[15:0];
                end
            endcase
        end else begin
            if (step) begin
                if ((MT01 && step_type == `STEP_MCT) || (MNISQ && step_type == `STEP_INST)) begin
                    cntrl_reg[2] <= 0;
                    suppress_mstp <= 0;
                end else begin
                    suppress_mstp <= 1;
                end
            end
        end

        if (MWAG) begin
            a_reg <= write_bus;
        end
        if (MWLG) begin
            l_reg <= write_bus;
        end
        if (MWQG) begin
            q_reg <= write_bus;
        end
        if (MWZG) begin
            z_reg <= write_bus;
        end
        if (MWBBEG) begin
            bb_reg[14] <= write_bus[15];
            bb_reg[13:10] <= write_bus[13:10];
            bb_reg[2:0] <= write_bus[2:0];
        end
        if (MWEBG) begin
            bb_reg[2:0] <= write_bus[10:8];
        end
        if (MWFBG) begin
            bb_reg[14] <= write_bus[15];
            bb_reg[13:10] <= write_bus[13:10];
        end
        if (MWG || MRGG) begin
            g_reg <= write_bus;
        end
        if (MWSG) begin
            s_reg[11:0] <= write_bus[11:0];
        end
        if (MWBG) begin
            b_reg <= write_bus;
        end
        if (MWCH && s_reg[8:0] == 9'o7) begin
            bb_reg[6:4] <= write_bus[6:4];
        end
        if (break_inst && MNISQ && s_reg[11:0] == break_addr[11:0] && 
            (s_reg[11:10] != 2'b01 || (s_reg[11:10] == 2'b01 &&  
            ((bb_reg[14:13] == 2'b11 && bb_reg[14:4] == break_bank[14:4]) || 
            (bb_reg[14:13] != 2'b11 && bb_reg[14:10] == break_bank[14:10]))))) begin 
            cntrl_reg[0] <= 1;
        end
        if (fetch_data || store_data) begin
            if (!MREQIN) begin
                if (fetch_data) MREAD <= 1'b1;
                else MLOAD <= 1'b1;
                suppress_mstp <= 1'b1;
            end else begin
                if (stage == 3'o0) begin
                    if (MT01) begin
                        MREAD <= 1'b0;
                        MLOAD <= 1'b0;
                    end else if (MT04) begin
                        monitor_data <= rw_bank;
                    end else if (MT05) begin
                        monitor_data <= 16'o0;
                    end else if (MT08) begin
                        monitor_data <= rw_addr;
                    end else if (MT09) begin
                        monitor_data <= 16'o0;
                    end
                end else if (stage == 3'o1) begin
                    if (MT04 && store_data) begin
                        if (rw_addr == 16'o6) MONWBK <= 1'b1;
                        monitor_data <= rw_data;
                    end else if (MT05) begin
                        monitor_data <= 16'b0;
                    end else if (MT07 && fetch_data) begin
                        rw_data <= write_bus;
                    end else if (MT09 && store_data) begin
                        monitor_data <= rw_data;
                    end else if (MT10) begin
                        monitor_data <= 16'b0;
                        bb_reg[14] <= write_bus[15];
                        bb_reg[13:10] <= write_bus[13:10];
                        bb_reg[2:0] <= write_bus[2:0];
                    end else if (MT11) begin
                        if (fetch_data) cntrl_reg[5] <= 1'b0;
                        else cntrl_reg[6] <= 1'b0;
                        suppress_mstp <= 1'b0;
                        MONWBK <= 1'b0;
                    end
                end
            end
        end
        if (read_chan || load_chan) begin
            if (!MREQIN) begin
                if (read_chan) MRDCH <= 1'b1;
                else MLDCH <= 1'b1;
                suppress_mstp <= 1'b1;
            end else begin
                if (MT01) begin
                    MRDCH <= 1'b0;
                    MLDCH <= 1'b0;
                    monitor_data <= rw_addr;
                end else if (MT02) begin
                    monitor_data <= 16'o0;
                end else if (MT05 && read_chan) begin
                    rw_data <= write_bus;
                end else if (MT07 && load_chan) begin
                    monitor_data <= rw_data;
                end else if (MT08) begin
                    monitor_data <= 16'o0;
                end else if (MT11) begin
                    if (read_chan) cntrl_reg[7] <= 1'b0;
                    else cntrl_reg[8] <= 1'b0;
                    suppress_mstp <= 1'b0;
                end
            end
        end
        if (transfer_control) begin
            if (!(!MTCSA_n || tcsaj_in_progress)) begin
                MTCSAI <= 1'b1;
                suppress_mstp <= 1'b1;
            end else begin
                if (stage == 3'o3) begin
                    if (MT01) begin
                        MTCSAI <= 1'b0;
                        tcsaj_in_progress <= 1'b1;
                    end else if (MT08) begin
                        monitor_data <= rw_addr;
                    end else if (MT09) begin
                        monitor_data <= 16'o0;
                    end
                end else if (MT11) begin
                    tcsaj_in_progress <= 1'b0;
                    cntrl_reg[9] <= 1'b0;
                    suppress_mstp <= 1'b0;
                end
            end
        end
    end

    always @(posedge tck) begin
        if (ir_in == `BYPASS) begin
            bypass_reg <= tdi;
        end else begin
            if (cdr) begin
                case (ir_in)
                    `CONTROL: tmp_reg <= cntrl_reg;
                    `BRKBANK: begin
                        tmp_reg[15] <= 1'b0;
                        tmp_reg[14:0] <= break_bank[14:0];
                    end
                    `BRKADDR: tmp_reg <= break_addr;
                    `RWBANK: begin
                        tmp_reg[15] <= 1'b0;
                        tmp_reg[14:0] <= rw_bank[14:0];
                    end
                    `RWADDR: tmp_reg <= rw_addr;
                    `RWDATA: tmp_reg <= rw_data;
                    `REG_A: tmp_reg <= a_reg;
                    `REG_L: tmp_reg <= l_reg;
                    `REG_Q: tmp_reg <= q_reg;
                    `REG_Z: tmp_reg <= z_reg;
                    `REG_BB: tmp_reg <= bb_reg;
                    `REG_G: tmp_reg <= g_reg;
                    `REG_SQ: tmp_reg <= direct_sq;
                    `REG_S: tmp_reg <= s_reg;
                    `REG_B: tmp_reg <= b_reg;
                    default: tmp_reg <= 16'b0;
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