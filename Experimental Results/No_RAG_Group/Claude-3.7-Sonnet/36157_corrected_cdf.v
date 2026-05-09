module fetch (
    mio_data_vld,
    mio_data_rdata,
    mio_instr_vld,
    mio_instr_rdata,
    pc_p_4,
    branch_p_4,
    clr,
    clk,
    test_mode,
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
    input mio_data_vld;
    input [31:0] mio_data_rdata;
    input mio_instr_vld;
    input [31:0] mio_instr_rdata;
    input [31:0] pc_p_4;
    input branch_p_4;
    input clr;
    input clk;
    input test_mode;
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
    CLKGATE clkgate (.CK(clk), .EN(!test_mode), .SE(test_mode), .GCK(clk_gated));

    always @(posedge clk_gated) begin
        if (clr)
            _2172 <= _2170;
        else
            _2172 <= _1949;
    end

    // ... existing code ...

    always @(posedge clk_gated) begin
        if (clr)
            _878 <= _876;
        else
            _878 <= pc_p_4;
    end

    // ... existing code ...

    always @(posedge clk_gated) begin
        if (clr)
            _802 <= _800;
        else
            _802 <= branch_p_4;
    end

    // ... rest of existing code ...

endmodule

module CLKGATE (
    input CK,
    input EN,
    input SE,
    output GCK
);
    reg latch_out;
    
    always @(*) begin
        if (!CK)
            latch_out = EN | SE;
    end
    
    assign GCK = CK & latch_out;
endmodule