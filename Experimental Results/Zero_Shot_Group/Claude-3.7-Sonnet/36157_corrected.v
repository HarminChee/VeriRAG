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

reg [31:0] pc_reg;
reg [31:0] instr_reg;
reg [47:0] insn_reg;
reg branch_reg;
reg [31:0] rd1_reg;
reg [31:0] rd2_reg;
reg [31:0] rdd_reg;
reg [31:0] rdm_reg;
reg [31:0] imm_reg;
reg [4:0] ra1_reg;
reg [4:0] ra2_reg;
reg [4:0] rad_reg;
reg ra1_zero_reg;
reg ra2_zero_reg;
reg rad_zero_reg;
reg trap_reg;
reg lui_reg;
reg auipc_reg;
reg jal_reg;
reg jalr_reg;
reg bra_reg;
reg ld_reg;
reg st_reg;
reg opi_reg;
reg opr_reg;
reg fen_reg;
reg sys_reg;
reg rdc_reg;
reg [2:0] rdco_reg;
reg [2:0] f3_reg;
reg f7_reg;
reg rwe_reg;
reg [31:0] mio_instr_addr_reg;
reg [31:0] mio_instr_wdata_reg;
reg mio_instr_req_reg;
reg mio_instr_rw_reg;
reg [3:0] mio_instr_wmask_reg;
reg [31:0] mio_data_addr_reg;
reg [31:0] mio_data_wdata_reg;
reg mio_data_req_reg;
reg mio_data_rw_reg;
reg [3:0] mio_data_wmask_reg;
reg junk_reg;
reg pen_reg;

wire [67:0] input_bus;
assign input_bus = {clk, clr, mio_instr_rdata, mio_instr_vld, mio_data_rdata, mio_data_vld};

always @(posedge clk) begin
    if (clr) begin
        pc_reg <= 32'h10;
        instr_reg <= 32'h0;
        insn_reg <= 48'h0;
        branch_reg <= 1'b0;
        rd1_reg <= 32'h0;
        rd2_reg <= 32'h0;
        rdd_reg <= 32'h0;
        rdm_reg <= 32'h0;
        imm_reg <= 32'h0;
        ra1_reg <= 5'h0;
        ra2_reg <= 5'h0;
        rad_reg <= 5'h0;
        ra1_zero_reg <= 1'b0;
        ra2_zero_reg <= 1'b0;
        rad_zero_reg <= 1'b0;
        trap_reg <= 1'b0;
        lui_reg <= 1'b0;
        auipc_reg <= 1'b0;
        jal_reg <= 1'b0;
        jalr_reg <= 1'b0;
        bra_reg <= 1'b0;
        ld_reg <= 1'b0;
        st_reg <= 1'b0;
        opi_reg <= 1'b0;
        opr_reg <= 1'b0;
        fen_reg <= 1'b0;
        sys_reg <= 1'b0;
        rdc_reg <= 1'b0;
        rdco_reg <= 3'h0;
        f3_reg <= 3'h0;
        f7_reg <= 1'b0;
        rwe_reg <= 1'b0;
        mio_instr_addr_reg <= 32'h0;
        mio_instr_wdata_reg <= 32'h0;
        mio_instr_req_reg <= 1'b0;
        mio_instr_rw_reg <= 1'b0;
        mio_instr_wmask_reg <= 4'h0;
        mio_data_addr_reg <= 32'h0;
        mio_data_wdata_reg <= 32'h0;
        mio_data_req_reg <= 1'b0;
        mio_data_rw_reg <= 1'b0;
        mio_data_wmask_reg <= 4'h0;
        junk_reg <= 1'b0;
        pen_reg <= 1'b0;
    end
    else begin
        pc_reg <= branch_p_4 ? pc_p_4 : (pc_reg + 32'h4);
        instr_reg <= mio_instr_rdata;
        insn_reg <= {mio_instr_rdata, 16'h0};
        branch_reg <= branch_p_4;
        rd1_reg <= rd1;
        rd2_reg <= rd2;
        rdd_reg <= rdd;
        rdm_reg <= rdm;
        imm_reg <= imm;
        ra1_reg <= ra1;
        ra2_reg <= ra2;
        rad_reg <= rad;
        ra1_zero_reg <= ra1_zero;
        ra2_zero_reg <= ra2_zero;
        rad_zero_reg <= rad_zero;
        trap_reg <= trap;
        lui_reg <= lui;
        auipc_reg <= auipc;
        jal_reg <= jal;
        jalr_reg <= jalr;
        bra_reg <= bra;
        ld_reg <= ld;
        st_reg <= st;
        opi_reg <= opi;
        opr_reg <= opr;
        fen_reg <= fen;
        sys_reg <= sys;
        rdc_reg <= rdc;
        rdco_reg <= rdco;
        f3_reg <= f3;
        f7_reg <= f7;
        rwe_reg <= rwe;
        mio_instr_addr_reg <= pc_reg;
        mio_instr_wdata_reg <= mio_instr_wdata;
        mio_instr_req_reg <= 1'b1;
        mio_instr_rw_reg <= 1'b0;
        mio_instr_wmask_reg <= 4'h0;
        mio_data_addr_reg <= mio_data_addr;
        mio_data_wdata_reg <= mio_data_wdata;
        mio_data_req_reg <= mio_data_req;
        mio_data_rw_reg <= mio_data_rw;
        mio_data_wmask_reg <= mio_data_wmask;
        junk_reg <= |input_bus;
        pen_reg <= 1'b1;
    end
end

assign pc = pc_reg;
assign instr = instr_reg;
assign insn = insn_reg;
assign branch = branch_reg;
assign rd1 = rd1_reg;
assign rd2 = rd2_reg;
assign rdd = rdd_reg;
assign rdm = rdm_reg;
assign imm = imm_reg;
assign ra1 = ra1_reg;
assign ra2 = ra2_reg;
assign rad = rad_reg;
assign ra1_zero = ra1_zero_reg;
assign ra2_zero = ra2_zero_reg;
assign rad_zero = rad_zero_reg;
assign trap = trap_reg;
assign lui = lui_reg;
assign auipc = auipc_reg;
assign jal = jal_reg;
assign jalr = jalr_reg;
assign bra = bra_reg;
assign ld = ld_reg;
assign st = st_reg;
assign opi = opi_reg;
assign opr = opr_reg;
assign fen = fen_reg;
assign sys = sys_reg;
assign rdc = rdc_reg;
assign rdco = rdco_reg;
assign f3 = f3_reg;
assign f7 = f7_reg;
assign rwe = rwe_reg;
assign mio_instr_addr = mio_instr_addr_reg;
assign mio_instr_wdata = mio_instr_wdata_reg;
assign mio_instr_req = mio_instr_req_reg;
assign mio_instr_rw = mio_instr_rw_reg;
assign mio_instr_wmask = mio_instr_wmask_reg;
assign mio_data_addr = mio_data_addr_reg;
assign mio_data_wdata = mio_data_wdata_reg;
assign mio_data_req = mio_data_req_reg;
assign mio_data_rw = mio_data_rw_reg;
assign mio_data_wmask = mio_data_wmask_reg;
assign junk = junk_reg;
assign pen = pen_reg;

endmodule