module fetch (
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
    input mio_data_vld;
    input [31:0] mio_data_rdata;
    input mio_instr_vld;
    input [31:0] mio_instr_rdata;
    input [31:0] pc_p_4;
    input branch_p_4;
    input clr;
    input clk;
    output reg pen;
    output reg [4:0] ra1;
    output reg [4:0] ra2;
    output reg [4:0] rad;
    output reg ra1_zero;
    output reg ra2_zero;
    output reg rad_zero;
    output reg [31:0] rd1;
    output reg [31:0] rd2;
    output reg [31:0] rdd;
    output reg [31:0] rdm;
    output reg [31:0] imm;
    output reg [31:0] pc;
    output reg [31:0] instr;
    output reg [47:0] insn;
    output reg trap;
    output reg lui;
    output reg auipc;
    output reg jal;
    output reg jalr;
    output reg bra;
    output reg ld;
    output reg st;
    output reg opi;
    output reg opr;
    output reg fen;
    output reg sys;
    output reg rdc;
    output reg [2:0] rdco;
    output reg [2:0] f3;
    output reg f7;
    output reg branch;
    output reg rwe;
    output reg [31:0] mio_instr_addr;
    output reg [31:0] mio_instr_wdata;
    output reg mio_instr_req;
    output reg mio_instr_rw;
    output reg [3:0] mio_instr_wmask;
    output reg [31:0] mio_data_addr;
    output reg [31:0] mio_data_wdata;
    output reg mio_data_req;
    output reg mio_data_rw;
    output reg [3:0] mio_data_wmask;
    output reg junk;

    reg [31:0] pc_reg;
    wire [31:0] pc_next;
    wire [67:0] inputs_concat;
    wire input_changed;

    assign inputs_concat = {clk, clr, mio_instr_rdata, mio_instr_vld, mio_data_rdata, mio_data_vld};
    assign input_changed = |inputs_concat;

    assign pc_next = branch_p_4 ? pc_p_4 : (pc_reg + 32'd4);

    always @(posedge clk) begin
        if (clr) begin
            pen <= 1'b0;
            ra1 <= 5'b0;
            ra2 <= 5'b0;
            rad <= 5'b0;
            ra1_zero <= 1'b0;
            ra2_zero <= 1'b0;
            rad_zero <= 1'b0;
            rd1 <= 32'b0;
            rd2 <= 32'b0;
            rdd <= 32'b0;
            rdm <= 32'b0;
            imm <= 32'b0;
            pc <= 32'h00000010;
            instr <= 32'b0;
            insn <= 48'b0;
            trap <= 1'b0;
            lui <= 1'b0;
            auipc <= 1'b0;
            jal <= 1'b0;
            jalr <= 1'b0;
            bra <= 1'b0;
            ld <= 1'b0;
            st <= 1'b0;
            opi <= 1'b0;
            opr <= 1'b0;
            fen <= 1'b0;
            sys <= 1'b0;
            rdc <= 1'b0;
            rdco <= 3'b0;
            f3 <= 3'b0;
            f7 <= 1'b0;
            branch <= 1'b0;
            rwe <= 1'b0;
            mio_instr_addr <= 32'b0;
            mio_instr_wdata <= 32'b0;
            mio_instr_req <= 1'b0;
            mio_instr_rw <= 1'b0;
            mio_instr_wmask <= 4'b0;
            mio_data_addr <= 32'b0;
            mio_data_wdata <= 32'b0;
            mio_data_req <= 1'b0;
            mio_data_rw <= 1'b0;
            mio_data_wmask <= 4'b0;
            junk <= 1'b0;
            pc_reg <= 32'h00000010;
        end else begin
            pc_reg <= pc_next;
            pc <= pc_next;
            mio_instr_addr <= pc_next;
            instr <= mio_instr_rdata;
            mio_instr_req <= 1'b1;
            pen <= 1'b1;
            junk <= input_changed;
        end
    end
endmodule