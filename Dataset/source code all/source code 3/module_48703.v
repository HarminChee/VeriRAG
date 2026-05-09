`timescale 1 ns / 1 ps 
`timescale 1 ns / 1 ps 
module acc_vadd_hls (
        ap_clk,
        ap_rst_n,
        cmd_TDATA,
        cmd_TVALID,
        cmd_TREADY,
        resp_TDATA,
        resp_TVALID,
        resp_TREADY,
        a_Addr_A,
        a_EN_A,
        a_WEN_A,
        a_Din_A,
        a_Dout_A,
        a_Clk_A,
        a_Rst_A,
        b_Addr_A,
        b_EN_A,
        b_WEN_A,
        b_Din_A,
        b_Dout_A,
        b_Clk_A,
        b_Rst_A,
        result_Addr_A,
        result_EN_A,
        result_WEN_A,
        result_Din_A,
        result_Dout_A,
        result_Clk_A,
        result_Rst_A
);
parameter    ap_const_logic_1 = 1'b1;
parameter    ap_const_logic_0 = 1'b0;
parameter    ap_ST_st1_fsm_0 = 3'b000;
parameter    ap_ST_st2_fsm_1 = 3'b1;
parameter    ap_ST_st3_fsm_2 = 3'b10;
parameter    ap_ST_st4_fsm_3 = 3'b11;
parameter    ap_ST_st5_fsm_4 = 3'b100;
parameter    ap_const_lv1_0 = 1'b0;
parameter    ap_const_lv32_1 = 32'b1;
parameter    ap_const_lv32_2 = 32'b10;
parameter    ap_const_lv4_0 = 4'b0000;
parameter    ap_const_lv4_F = 4'b1111;
parameter    ap_const_lv32_FFFFFFFF = 32'b11111111111111111111111111111111;
parameter    ap_const_lv32_0 = 32'b00000000000000000000000000000000;
parameter    ap_true = 1'b1;
input   ap_clk;
input   ap_rst_n;
input  [31:0] cmd_TDATA;
input   cmd_TVALID;
output   cmd_TREADY;
output  [31:0] resp_TDATA;
output   resp_TVALID;
input   resp_TREADY;
output  [31:0] a_Addr_A;
output   a_EN_A;
output  [3:0] a_WEN_A;
output  [31:0] a_Din_A;
input  [31:0] a_Dout_A;
output   a_Clk_A;
output   a_Rst_A;
output  [31:0] b_Addr_A;
output   b_EN_A;
output  [3:0] b_WEN_A;
output  [31:0] b_Din_A;
input  [31:0] b_Dout_A;
output   b_Clk_A;
output   b_Rst_A;
output  [31:0] result_Addr_A;
output   result_EN_A;
output  [3:0] result_WEN_A;
output  [31:0] result_Din_A;
input  [31:0] result_Dout_A;
output   result_Clk_A;
output   result_Rst_A;
reg cmd_TREADY;
reg resp_TVALID;
reg a_EN_A;
reg b_EN_A;
reg result_EN_A;
reg[3:0] result_WEN_A;
wire   [0:0] tmp_fu_111_p2;
reg   [0:0] tmp_reg_157;
reg   [2:0] ap_CS_fsm = 3'b000;
reg   [31:0] end_reg_161;
wire   [31:0] tmp_1_fu_117_p2;
reg   [31:0] tmp_1_reg_172;
wire   [63:0] tmp_3_fu_127_p1;
reg   [63:0] tmp_3_reg_180;
wire   [0:0] tmp_2_fu_122_p2;
wire   [0:0] tmp_6_fu_133_p2;
reg   [0:0] tmp_6_reg_195;
wire   [31:0] i_1_fu_151_p2;
reg    ap_sig_ioackin_resp_TREADY;
reg   [31:0] i_reg_100;
reg    ap_reg_ioackin_resp_TREADY = 1'b0;
wire   [31:0] a_Addr_A_orig;
wire   [31:0] b_Addr_A_orig;
wire   [31:0] result_Addr_A_orig;
wire   [31:0] tmp_4_fu_138_p2;
reg   [2:0] ap_NS_fsm;
reg    ap_sig_bdd_96;
always @ (posedge ap_clk)
begin : ap_ret_ap_CS_fsm
    if (ap_rst_n == 1'b0) begin
        ap_CS_fsm <= ap_ST_st1_fsm_0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ioackin_resp_TREADY
    if (ap_rst_n == 1'b0) begin
        ap_reg_ioackin_resp_TREADY <= ap_const_logic_0;
    end else begin
        if (ap_sig_bdd_96) begin
            if (~(~(ap_const_lv1_0 == tmp_6_reg_195) & (ap_const_logic_0 == ap_sig_ioackin_resp_TREADY))) begin
                ap_reg_ioackin_resp_TREADY <= ap_const_logic_0;
            end else if ((ap_const_logic_1 == resp_TREADY)) begin
                ap_reg_ioackin_resp_TREADY <= ap_const_logic_1;
            end
        end
    end
end
always @(posedge ap_clk)
begin
    if ((~(cmd_TVALID == ap_const_logic_0) & (ap_ST_st3_fsm_2 == ap_CS_fsm) & ~(tmp_reg_157 == ap_const_lv1_0))) begin
        i_reg_100 <= cmd_TDATA;
    end else if (((ap_ST_st5_fsm_4 == ap_CS_fsm) & ~(~(ap_const_lv1_0 == tmp_6_reg_195) & (ap_const_logic_0 == ap_sig_ioackin_resp_TREADY)))) begin
        i_reg_100 <= i_1_fu_151_p2;
    end
end
always @(posedge ap_clk)
begin
    if ((~(cmd_TVALID == ap_const_logic_0) & (ap_ST_st2_fsm_1 == ap_CS_fsm))) begin
        end_reg_161 <= cmd_TDATA;
    end
end
always @(posedge ap_clk)
begin
    if ((~(cmd_TVALID == ap_const_logic_0) & (ap_ST_st3_fsm_2 == ap_CS_fsm) & ~(tmp_reg_157 == ap_const_lv1_0))) begin
        tmp_1_reg_172 <= tmp_1_fu_117_p2;
    end
end
always @(posedge ap_clk)
begin
    if ((~(tmp_reg_157 == ap_const_lv1_0) & (ap_ST_st4_fsm_3 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_2_fu_122_p2))) begin
        tmp_3_reg_180 <= tmp_3_fu_127_p1;
        tmp_6_reg_195 <= tmp_6_fu_133_p2;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~(cmd_TVALID == ap_const_logic_0))) begin
        tmp_reg_157 <= tmp_fu_111_p2;
    end
end
always @ (ap_CS_fsm)
begin
    if ((ap_ST_st4_fsm_3 == ap_CS_fsm)) begin
        a_EN_A = ap_const_logic_1;
    end else begin
        a_EN_A = ap_const_logic_0;
    end
end
always @ (resp_TREADY or ap_reg_ioackin_resp_TREADY)
begin
    if ((ap_const_logic_0 == ap_reg_ioackin_resp_TREADY)) begin
        ap_sig_ioackin_resp_TREADY = resp_TREADY;
    end else begin
        ap_sig_ioackin_resp_TREADY = ap_const_logic_1;
    end
end
always @ (ap_CS_fsm)
begin
    if ((ap_ST_st4_fsm_3 == ap_CS_fsm)) begin
        b_EN_A = ap_const_logic_1;
    end else begin
        b_EN_A = ap_const_logic_0;
    end
end
always @ (cmd_TVALID or ap_CS_fsm)
begin
    if ((((ap_ST_st1_fsm_0 == ap_CS_fsm) & ~(cmd_TVALID == ap_const_logic_0)) | (~(cmd_TVALID == ap_const_logic_0) & (ap_ST_st2_fsm_1 == ap_CS_fsm)) | (~(cmd_TVALID == ap_const_logic_0) & (ap_ST_st3_fsm_2 == ap_CS_fsm)))) begin
        cmd_TREADY = ap_const_logic_1;
    end else begin
        cmd_TREADY = ap_const_logic_0;
    end
end
always @ (ap_CS_fsm or tmp_6_reg_195 or ap_reg_ioackin_resp_TREADY)
begin
    if (((ap_ST_st5_fsm_4 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_6_reg_195) & (ap_const_logic_0 == ap_reg_ioackin_resp_TREADY))) begin
        resp_TVALID = ap_const_logic_1;
    end else begin
        resp_TVALID = ap_const_logic_0;
    end
end
always @ (ap_CS_fsm or tmp_6_reg_195 or ap_sig_ioackin_resp_TREADY)
begin
    if (((ap_ST_st5_fsm_4 == ap_CS_fsm) & ~(~(ap_const_lv1_0 == tmp_6_reg_195) & (ap_const_logic_0 == ap_sig_ioackin_resp_TREADY)))) begin
        result_EN_A = ap_const_logic_1;
    end else begin
        result_EN_A = ap_const_logic_0;
    end
end
always @ (ap_CS_fsm or tmp_6_reg_195 or ap_sig_ioackin_resp_TREADY)
begin
    if (((ap_ST_st5_fsm_4 == ap_CS_fsm) & ~(~(ap_const_lv1_0 == tmp_6_reg_195) & (ap_const_logic_0 == ap_sig_ioackin_resp_TREADY)))) begin
        result_WEN_A = ap_const_lv4_F;
    end else begin
        result_WEN_A = ap_const_lv4_0;
    end
end
always @ (cmd_TVALID or tmp_reg_157 or ap_CS_fsm or tmp_2_fu_122_p2 or tmp_6_reg_195 or ap_sig_ioackin_resp_TREADY)
begin
    case (ap_CS_fsm)
        ap_ST_st1_fsm_0 : 
        begin
            if (~(cmd_TVALID == ap_const_logic_0)) begin
                ap_NS_fsm = ap_ST_st2_fsm_1;
            end else begin
                ap_NS_fsm = ap_ST_st1_fsm_0;
            end
        end
        ap_ST_st2_fsm_1 : 
        begin
            if (~(cmd_TVALID == ap_const_logic_0)) begin
                ap_NS_fsm = ap_ST_st3_fsm_2;
            end else begin
                ap_NS_fsm = ap_ST_st2_fsm_1;
            end
        end
        ap_ST_st3_fsm_2 : 
        begin
            if (~(cmd_TVALID == ap_const_logic_0)) begin
                ap_NS_fsm = ap_ST_st4_fsm_3;
            end else begin
                ap_NS_fsm = ap_ST_st3_fsm_2;
            end
        end
        ap_ST_st4_fsm_3 : 
        begin
            if (((tmp_reg_157 == ap_const_lv1_0) | (ap_const_lv1_0 == tmp_2_fu_122_p2))) begin
                ap_NS_fsm = ap_ST_st1_fsm_0;
            end else begin
                ap_NS_fsm = ap_ST_st5_fsm_4;
            end
        end
        ap_ST_st5_fsm_4 : 
        begin
            if (~(~(ap_const_lv1_0 == tmp_6_reg_195) & (ap_const_logic_0 == ap_sig_ioackin_resp_TREADY))) begin
                ap_NS_fsm = ap_ST_st4_fsm_3;
            end else begin
                ap_NS_fsm = ap_ST_st5_fsm_4;
            end
        end
        default : 
        begin
            ap_NS_fsm = 'bx;
        end
    endcase
end
assign a_Addr_A = a_Addr_A_orig << ap_const_lv32_2;
assign a_Addr_A_orig = tmp_3_fu_127_p1;
assign a_Clk_A = ap_clk;
assign a_Din_A = ap_const_lv32_0;
assign a_Rst_A = ap_rst_n;
assign a_WEN_A = ap_const_lv4_0;
always @ (ap_CS_fsm or tmp_6_reg_195)
begin
    ap_sig_bdd_96 = ((ap_ST_st5_fsm_4 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_6_reg_195));
end
assign b_Addr_A = b_Addr_A_orig << ap_const_lv32_2;
assign b_Addr_A_orig = tmp_3_fu_127_p1;
assign b_Clk_A = ap_clk;
assign b_Din_A = ap_const_lv32_0;
assign b_Rst_A = ap_rst_n;
assign b_WEN_A = ap_const_lv4_0;
assign i_1_fu_151_p2 = (i_reg_100 + ap_const_lv32_1);
assign resp_TDATA = ap_const_lv32_1;
assign result_Addr_A = result_Addr_A_orig << ap_const_lv32_2;
assign result_Addr_A_orig = tmp_3_reg_180;
assign result_Clk_A = ap_clk;
assign result_Din_A = (tmp_4_fu_138_p2 + a_Dout_A);
assign result_Rst_A = ap_rst_n;
assign tmp_1_fu_117_p2 = (end_reg_161 + ap_const_lv32_FFFFFFFF);
assign tmp_2_fu_122_p2 = ($signed(i_reg_100) < $signed(end_reg_161)? 1'b1: 1'b0);
assign tmp_3_fu_127_p1 = $signed(i_reg_100);
assign tmp_4_fu_138_p2 = b_Dout_A << ap_const_lv32_1;
assign tmp_6_fu_133_p2 = (i_reg_100 == tmp_1_reg_172? 1'b1: 1'b0);
assign tmp_fu_111_p2 = (cmd_TDATA == ap_const_lv32_1? 1'b1: 1'b0);
endmodule 
