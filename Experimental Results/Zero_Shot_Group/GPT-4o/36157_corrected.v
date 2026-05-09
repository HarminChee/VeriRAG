module fetch (
    input mio_data_vld,
    input [31:0] mio_data_rdata,
    input mio_instr_vld,
    input [31:0] mio_instr_rdata,
    input [31:0] pc_p_4,
    input branch_p_4,
    input clr,
    input clk,
    output reg pen,
    output reg [4:0] ra1,
    output reg [4:0] ra2,
    output reg [4:0] rad,
    output reg ra1_zero,
    output reg ra2_zero,
    output reg rad_zero,
    output reg [31:0] rd1,
    output reg [31:0] rd2,
    output reg [31:0] rdd,
    output reg [31:0] rdm,
    output reg [31:0] imm,
    output reg [31:0] pc,
    output reg [31:0] instr,
    output reg [47:0] insn,
    output reg trap,
    output reg lui,
    output reg auipc,
    output reg jal,
    output reg jalr,
    output reg bra,
    output reg ld,
    output reg st,
    output reg opi,
    output reg opr,
    output reg fen,
    output reg sys,
    output reg rdc,
    output reg [2:0] rdco,
    output reg [2:0] f3,
    output reg f7,
    output reg branch,
    output reg rwe,
    output reg [31:0] mio_instr_addr,
    output reg [31:0] mio_instr_wdata,
    output reg mio_instr_req,
    output reg mio_instr_rw,
    output reg [3:0] mio_instr_wmask,
    output reg [31:0] mio_data_addr,
    output reg [31:0] mio_data_wdata,
    output reg mio_data_req,
    output reg mio_data_rw,
    output reg [3:0] mio_data_wmask,
    output reg junk
);

always @(posedge clk or posedge clr) begin
    if (clr) begin
        pen <= 0;
        ra1 <= 0;
        ra2 <= 0;
        rad <= 0;
        ra1_zero <= 0;
        ra2_zero <= 0;
        rad_zero <= 0;
        rd1 <= 0;
        rd2 <= 0;
        rdd <= 0;
        rdm <= 0;
        imm <= 0;
        pc <= 32'h0010;
        instr <= 0;
        insn <= 0;
        trap <= 0;
        lui <= 0;
        auipc <= 0;
        jal <= 0;
        jalr <= 0;
        bra <= 0;
        ld <= 0;
        st <= 0;
        opi <= 0;
        opr <= 0;
        fen <= 0;
        sys <= 0;
        rdc <= 0;
        rdco <= 0;
        f3 <= 0;
        f7 <= 0;
        branch <= 0;
        rwe <= 0;
        mio_instr_addr <= 0;
        mio_instr_wdata <= 0;
        mio_instr_req <= 0;
        mio_instr_rw <= 0;
        mio_instr_wmask <= 0;
        mio_data_addr <= 0;
        mio_data_wdata <= 0;
        mio_data_req <= 0;
        mio_data_rw <= 0;
        mio_data_wmask <= 0;
        junk <= 0;
    end else begin
        if (branch_p_4)
            pc <= pc_p_4;
        else
            pc <= pc + 4;

        instr <= mio_instr_rdata;
        mio_instr_addr <= pc;
        mio_instr_req <= 1;

        if (mio_instr_vld) begin
            ra1 <= instr[19:15];
            ra2 <= instr[24:20];
            rad <= instr[11:7];
            rd1 <= mio_data_rdata;
            rd2 <= mio_data_rdata;
            imm <= {instr[31:20]};
            
            case (instr[6:0])
                7'b0110111: lui <= 1;
                7'b0010111: auipc <= 1;
                7'b1101111: jal <= 1;
                7'b1100111: jalr <= 1;
                7'b1100011: bra <= 1;
                7'b0000011: ld <= 1;
                7'b0100011: st <= 1;
                7'b0010011: opi <= 1;
                7'b0110011: opr <= 1;
                7'b0001111: fen <= 1;
                7'b1110011: sys <= 1;
                default: begin
                    lui <= 0;
                    auipc <= 0;
                    jal <= 0;
                    jalr <= 0;
                    bra <= 0;
                    ld <= 0;
                    st <= 0;
                    opi <= 0;
                    opr <= 0;
                    fen <= 0;
                    sys <= 0;
                end
            endcase
        end
    end
end

endmodule