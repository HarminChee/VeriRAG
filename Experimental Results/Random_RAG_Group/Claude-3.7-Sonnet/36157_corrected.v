module fetch (
    test_i,
    mio_data_vld,
    mio_data_rdata,
    mio_instr_vld,
    mio_instr_rdata,
    pc_p_4,
    branch_p_4,
    clr,
    clk,
    pen,
    ra1,
    ra2,
    rad,
    ra1_zero,
    ra2_zero,
    rad_zero,
    rd1,
    rd2,
    rdd,
    rdm,
    imm,
    pc,
    instr,
    insn,
    trap,
    lui,
    auipc,
    jal,
    jalr,
    bra,
    ld,
    st,
    opi,
    opr,
    fen,
    sys,
    rdc,
    rdco,
    f3,
    f7,
    branch,
    rwe,
    mio_instr_addr,
    mio_instr_wdata,
    mio_instr_req,
    mio_instr_rw,
    mio_instr_wmask,
    mio_data_addr,
    mio_data_wdata,
    mio_data_req,
    mio_data_rw,
    mio_data_wmask,
    junk
);
    input test_i;
    input mio_data_vld;
    input [31:0] mio_data_rdata;
    input mio_instr_vld;
    input [31:0] mio_instr_rdata;
    input [31:0] pc_p_4;
    input branch_p_4;
    input clr;
    input clk;
    output pen;
    output [4:0] ra1;
    output [4:0] ra2;
    output [4:0] rad;
    output ra1_zero;
    output ra2_zero;
    output rad_zero;
    output [31:0] rd1;
    output [31:0] rd2;
    output [31:0] rdd;
    output [31:0] rdm;
    output [31:0] imm;
    output [31:0] pc;
    output [31:0] instr;
    output [47:0] insn;
    output trap;
    output lui;
    output auipc;
    output jal;
    output jalr;
    output bra;
    output ld;
    output st;
    output opi;
    output opr;
    output fen;
    output sys;
    output rdc;
    output [2:0] rdco;
    output [2:0] f3;
    output f7;
    output branch;
    output rwe;
    output [31:0] mio_instr_addr;
    output [31:0] mio_instr_wdata;
    output mio_instr_req;
    output mio_instr_rw;
    output [3:0] mio_instr_wmask;
    output [31:0] mio_data_addr;
    output [31:0] mio_data_wdata;
    output mio_data_req;
    output mio_data_rw;
    output [3:0] mio_data_wmask;
    output junk;

    // ... existing code ...

    wire clk_gated;
    assign clk_gated = test_i ? 1'b0 : clk;

    always @(posedge clk_gated or negedge iRST_N) begin
        // ... existing code ...
    end

    // ... existing code ...

endmodule