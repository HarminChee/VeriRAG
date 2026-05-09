`timescale 1 ns / 1 ps 
`timescale 1 ns / 1 ps 
module vectoradd (
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
parameter    ap_ST_st6_fsm_5 = 3'b101;
parameter    ap_ST_st7_fsm_6 = 3'b110;
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
reg[31:0] result_Din_A;
wire   [31:0] grp_fu_155_p2;
reg   [31:0] reg_160;
reg   [2:0] ap_CS_fsm = 3'b000;
wire   [0:0] tmp_fu_164_p2;
wire   [0:0] tmp_2_fu_169_p2;
reg   [31:0] op_reg_234;
reg   [31:0] end_reg_240;
reg   [0:0] tmp_reg_253;
reg   [0:0] tmp_2_reg_257;
wire   [63:0] tmp_s_fu_179_p1;
reg   [63:0] tmp_s_reg_264;
wire   [0:0] tmp_8_fu_174_p2;
wire   [0:0] tmp_10_fu_185_p2;
reg   [0:0] tmp_10_reg_279;
wire   [63:0] tmp_5_fu_196_p1;
reg   [63:0] tmp_5_reg_286;
wire   [0:0] tmp_3_fu_191_p2;
wire   [0:0] tmp_7_fu_202_p2;
reg   [0:0] tmp_7_reg_301;
wire   [31:0] i_3_fu_215_p2;
reg    ap_sig_ioackin_resp_TREADY;
wire   [31:0] i_2_fu_228_p2;
reg   [31:0] i_1_reg_134;
reg   [31:0] i_reg_144;
reg    ap_reg_ioackin_resp_TREADY = 1'b0;
reg   [31:0] a_Addr_A_orig;
reg   [31:0] b_Addr_A_orig;
wire   [31:0] tmp_9_fu_208_p2;
wire   [31:0] tmp_6_fu_221_p2;
reg   [31:0] result_Addr_A_orig;
reg   [2:0] ap_NS_fsm;
reg    ap_sig_bdd_87;
reg    ap_sig_bdd_101;
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
        if ((((ap_ST_st6_fsm_5 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_10_reg_279) & ~(~(ap_const_lv1_0 == tmp_10_reg_279) & (ap_const_logic_0 == ap_sig_ioackin_resp_TREADY))) | ((ap_ST_st7_fsm_6 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_7_reg_301) & ~((ap_const_logic_0 == ap_sig_ioackin_resp_TREADY) & ~(ap_const_lv1_0 == tmp_7_reg_301))))) begin
            ap_reg_ioackin_resp_TREADY <= ap_const_logic_0;
        end else if ((((ap_ST_st6_fsm_5 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_10_reg_279) & (ap_const_logic_1 == resp_TREADY)) | ((ap_ST_st7_fsm_6 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_7_reg_301) & (ap_const_logic_1 == resp_TREADY)))) begin
            ap_reg_ioackin_resp_TREADY <= ap_const_logic_1;
        end
    end
end
always @(posedge ap_clk)
begin
    if (((ap_ST_st4_fsm_3 == ap_CS_fsm) & ~(cmd_TVALID == ap_const_logic_0) & (tmp_fu_164_p2 == ap_const_lv1_0) & ~(ap_const_lv1_0 == tmp_2_fu_169_p2))) begin
        i_1_reg_134 <= cmd_TDATA;
    end else if (((ap_ST_st6_fsm_5 == ap_CS_fsm) & ~(~(ap_const_lv1_0 == tmp_10_reg_279) & (ap_const_logic_0 == ap_sig_ioackin_resp_TREADY)))) begin
        i_1_reg_134 <= i_3_fu_215_p2;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_ST_st4_fsm_3 == ap_CS_fsm) & ~(cmd_TVALID == ap_const_logic_0) & ~(tmp_fu_164_p2 == ap_const_lv1_0))) begin
        i_reg_144 <= cmd_TDATA;
    end else if (((ap_ST_st7_fsm_6 == ap_CS_fsm) & ~((ap_const_logic_0 == ap_sig_ioackin_resp_TREADY) & ~(ap_const_lv1_0 == tmp_7_reg_301)))) begin
        i_reg_144 <= i_2_fu_228_p2;
    end
end
always @(posedge ap_clk)
begin
    if ((~(cmd_TVALID == ap_const_logic_0) & (ap_ST_st3_fsm_2 == ap_CS_fsm))) begin
        end_reg_240 <= cmd_TDATA;
    end
end
always @(posedge ap_clk)
begin
    if ((~(cmd_TVALID == ap_const_logic_0) & (ap_ST_st2_fsm_1 == ap_CS_fsm))) begin
        op_reg_234 <= cmd_TDATA;
    end
end
always @(posedge ap_clk)
begin
    if ((((ap_ST_st4_fsm_3 == ap_CS_fsm) & ~(cmd_TVALID == ap_const_logic_0) & (tmp_fu_164_p2 == ap_const_lv1_0) & ~(ap_const_lv1_0 == tmp_2_fu_169_p2)) | ((ap_ST_st4_fsm_3 == ap_CS_fsm) & ~(cmd_TVALID == ap_const_logic_0) & ~(tmp_fu_164_p2 == ap_const_lv1_0)))) begin
        reg_160 <= grp_fu_155_p2;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_ST_st5_fsm_4 == ap_CS_fsm) & (ap_const_lv1_0 == tmp_reg_253) & ~(ap_const_lv1_0 == tmp_2_reg_257) & ~(ap_const_lv1_0 == tmp_8_fu_174_p2))) begin
        tmp_10_reg_279 <= tmp_10_fu_185_p2;
        tmp_s_reg_264 <= tmp_s_fu_179_p1;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_ST_st4_fsm_3 == ap_CS_fsm) & ~(cmd_TVALID == ap_const_logic_0) & (tmp_fu_164_p2 == ap_const_lv1_0))) begin
        tmp_2_reg_257 <= tmp_2_fu_169_p2;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_ST_st5_fsm_4 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_reg_253) & ~(ap_const_lv1_0 == tmp_3_fu_191_p2))) begin
        tmp_5_reg_286 <= tmp_5_fu_196_p1;
        tmp_7_reg_301 <= tmp_7_fu_202_p2;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_ST_st4_fsm_3 == ap_CS_fsm) & ~(cmd_TVALID == ap_const_logic_0))) begin
        tmp_reg_253 <= tmp_fu_164_p2;
    end
end
always @ (ap_CS_fsm or tmp_s_fu_179_p1 or tmp_5_fu_196_p1 or ap_sig_bdd_87 or ap_sig_bdd_101)
begin
    if ((ap_ST_st5_fsm_4 == ap_CS_fsm)) begin
        if (ap_sig_bdd_101) begin
            a_Addr_A_orig = tmp_5_fu_196_p1;
        end else if (ap_sig_bdd_87) begin
            a_Addr_A_orig = tmp_s_fu_179_p1;
        end else begin
            a_Addr_A_orig = 'bx;
        end
    end else begin
        a_Addr_A_orig = 'bx;
    end
end
always @ (ap_CS_fsm or tmp_reg_253 or tmp_2_reg_257 or tmp_8_fu_174_p2 or tmp_3_fu_191_p2)
begin
    if ((((ap_ST_st5_fsm_4 == ap_CS_fsm) & (ap_const_lv1_0 == tmp_reg_253) & ~(ap_const_lv1_0 == tmp_2_reg_257) & ~(ap_const_lv1_0 == tmp_8_fu_174_p2)) | ((ap_ST_st5_fsm_4 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_reg_253) & ~(ap_const_lv1_0 == tmp_3_fu_191_p2)))) begin
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
always @ (ap_CS_fsm or tmp_s_fu_179_p1 or tmp_5_fu_196_p1 or ap_sig_bdd_87 or ap_sig_bdd_101)
begin
    if ((ap_ST_st5_fsm_4 == ap_CS_fsm)) begin
        if (ap_sig_bdd_101) begin
            b_Addr_A_orig = tmp_5_fu_196_p1;
        end else if (ap_sig_bdd_87) begin
            b_Addr_A_orig = tmp_s_fu_179_p1;
        end else begin
            b_Addr_A_orig = 'bx;
        end
    end else begin
        b_Addr_A_orig = 'bx;
    end
end
always @ (ap_CS_fsm or tmp_reg_253 or tmp_2_reg_257 or tmp_8_fu_174_p2 or tmp_3_fu_191_p2)
begin
    if ((((ap_ST_st5_fsm_4 == ap_CS_fsm) & (ap_const_lv1_0 == tmp_reg_253) & ~(ap_const_lv1_0 == tmp_2_reg_257) & ~(ap_const_lv1_0 == tmp_8_fu_174_p2)) | ((ap_ST_st5_fsm_4 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_reg_253) & ~(ap_const_lv1_0 == tmp_3_fu_191_p2)))) begin
        b_EN_A = ap_const_logic_1;
    end else begin
        b_EN_A = ap_const_logic_0;
    end
end
always @ (cmd_TVALID or ap_CS_fsm)
begin
    if ((((ap_ST_st4_fsm_3 == ap_CS_fsm) & ~(cmd_TVALID == ap_const_logic_0)) | (~(cmd_TVALID == ap_const_logic_0) & (ap_ST_st2_fsm_1 == ap_CS_fsm)) | (~(cmd_TVALID == ap_const_logic_0) & (ap_ST_st3_fsm_2 == ap_CS_fsm)))) begin
        cmd_TREADY = ap_const_logic_1;
    end else begin
        cmd_TREADY = ap_const_logic_0;
    end
end
always @ (ap_CS_fsm or tmp_10_reg_279 or tmp_7_reg_301 or ap_reg_ioackin_resp_TREADY)
begin
    if ((((ap_ST_st6_fsm_5 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_10_reg_279) & (ap_const_logic_0 == ap_reg_ioackin_resp_TREADY)) | ((ap_ST_st7_fsm_6 == ap_CS_fsm) & ~(ap_const_lv1_0 == tmp_7_reg_301) & (ap_const_logic_0 == ap_reg_ioackin_resp_TREADY)))) begin
        resp_TVALID = ap_const_logic_1;
    end else begin
        resp_TVALID = ap_const_logic_0;
    end
end
always @ (ap_CS_fsm or tmp_s_reg_264 or tmp_5_reg_286)
begin
    if ((ap_ST_st7_fsm_6 == ap_CS_fsm)) begin
        result_Addr_A_orig = tmp_5_reg_286;
    end else if ((ap_ST_st6_fsm_5 == ap_CS_fsm)) begin
        result_Addr_A_orig = tmp_s_reg_264;
    end else begin
        result_Addr_A_orig = 'bx;
    end
end
always @ (ap_CS_fsm or tmp_9_fu_208_p2 or tmp_6_fu_221_p2)
begin
    if ((ap_ST_st7_fsm_6 == ap_CS_fsm)) begin
        result_Din_A = tmp_6_fu_221_p2;
    end else if ((ap_ST_st6_fsm_5 == ap_CS_fsm)) begin
        result_Din_A = tmp_9_fu_208_p2;
    end else begin
        result_Din_A = 'bx;
    end
end
always @ (ap_CS_fsm or tmp_10_reg_279 or tmp_7_reg_301 or ap_sig_ioackin_resp_TREADY)
begin
    if ((((ap_ST_st6_fsm_5 == ap_CS_fsm) & ~(~(ap_const_lv1_0 == tmp_10_reg_279) & (ap_const_logic_0 == ap_sig_ioackin_resp_TREADY))) | ((ap_ST_st7_fsm_6 == ap_CS_fsm) & ~((ap_const_logic_0 == ap_sig_ioackin_resp_TREADY) & ~(ap_const_lv1_0 == tmp_7_reg_301))))) begin
        result_EN_A = ap_const_logic_1;
    end else begin
        result_EN_A = ap_const_logic_0;
    end
end
always @ (ap_CS_fsm or tmp_10_reg_279 or tmp_7_reg_301 or ap_sig_ioackin_resp_TREADY)
begin
    if ((((ap_ST_st6_fsm_5 == ap_CS_fsm) & ~(~(ap_const_lv1_0 == tmp_10_reg_279) & (ap_const_logic_0 == ap_sig_ioackin_resp_TREADY))) | ((ap_ST_st7_fsm_6 == ap_CS_fsm) & ~((ap_const_logic_0 == ap_sig_ioackin_resp_TREADY) & ~(ap_const_lv1_0 == tmp_7_reg_301))))) begin
        result_WEN_A = ap_const_lv4_F;
    end else begin
        result_WEN_A = ap_const_lv4_0;
    end
end
always @ (cmd_TVALID or ap_CS_fsm or tmp_reg_253 or tmp_2_reg_257 or tmp_8_fu_174_p2 or tmp_10_reg_279 or tmp_3_fu_191_p2 or tmp_7_reg_301 or ap_sig_ioackin_resp_TREADY)
begin
    case (ap_CS_fsm)
        ap_ST_st1_fsm_0 : 
        begin
            ap_NS_fsm = ap_ST_st2_fsm_1;
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
            if (~(cmd_TVALID == ap_const_logic_0)) begin
                ap_NS_fsm = ap_ST_st5_fsm_4;
            end else begin
                ap_NS_fsm = ap_ST_st4_fsm_3;
            end
        end
        ap_ST_st5_fsm_4 : 
        begin
            if ((((ap_const_lv1_0 == tmp_reg_253) & (ap_const_lv1_0 == tmp_2_reg_257)) | (~(ap_const_lv1_0 == tmp_reg_253) & (ap_const_lv1_0 == tmp_3_fu_191_p2)) | ((ap_const_lv1_0 == tmp_reg_253) & (ap_const_lv1_0 == tmp_8_fu_174_p2)))) begin
                ap_NS_fsm = ap_ST_st2_fsm_1;
            end else if ((~(ap_const_lv1_0 == tmp_reg_253) & ~(ap_const_lv1_0 == tmp_3_fu_191_p2))) begin
                ap_NS_fsm = ap_ST_st7_fsm_6;
            end else begin
                ap_NS_fsm = ap_ST_st6_fsm_5;
            end
        end
        ap_ST_st6_fsm_5 : 
        begin
            if (~(~(ap_const_lv1_0 == tmp_10_reg_279) & (ap_const_logic_0 == ap_sig_ioackin_resp_TREADY))) begin
                ap_NS_fsm = ap_ST_st5_fsm_4;
            end else begin
                ap_NS_fsm = ap_ST_st6_fsm_5;
            end
        end
        ap_ST_st7_fsm_6 : 
        begin
            if (~((ap_const_logic_0 == ap_sig_ioackin_resp_TREADY) & ~(ap_const_lv1_0 == tmp_7_reg_301))) begin
                ap_NS_fsm = ap_ST_st5_fsm_4;
            end else begin
                ap_NS_fsm = ap_ST_st7_fsm_6;
            end
        end
        default : 
        begin
            ap_NS_fsm = 'bx;
        end
    endcase
end
assign a_Addr_A = a_Addr_A_orig << ap_const_lv32_2;
assign a_Clk_A = ap_clk;
assign a_Din_A = ap_const_lv32_0;
assign a_Rst_A = ap_rst_n;
assign a_WEN_A = ap_const_lv4_0;
always @ (tmp_reg_253 or tmp_3_fu_191_p2)
begin
    ap_sig_bdd_101 = (~(ap_const_lv1_0 == tmp_reg_253) & ~(ap_const_lv1_0 == tmp_3_fu_191_p2));
end
always @ (tmp_reg_253 or tmp_2_reg_257 or tmp_8_fu_174_p2)
begin
    ap_sig_bdd_87 = ((ap_const_lv1_0 == tmp_reg_253) & ~(ap_const_lv1_0 == tmp_2_reg_257) & ~(ap_const_lv1_0 == tmp_8_fu_174_p2));
end
assign b_Addr_A = b_Addr_A_orig << ap_const_lv32_2;
assign b_Clk_A = ap_clk;
assign b_Din_A = ap_const_lv32_0;
assign b_Rst_A = ap_rst_n;
assign b_WEN_A = ap_const_lv4_0;
assign grp_fu_155_p2 = (end_reg_240 + ap_const_lv32_FFFFFFFF);
assign i_2_fu_228_p2 = (i_reg_144 + ap_const_lv32_1);
assign i_3_fu_215_p2 = (i_1_reg_134 + ap_const_lv32_1);
assign resp_TDATA = ap_const_lv32_1;
assign result_Addr_A = result_Addr_A_orig << ap_const_lv32_2;
assign result_Clk_A = ap_clk;
assign result_Rst_A = ap_rst_n;
assign tmp_10_fu_185_p2 = (i_1_reg_134 == reg_160? 1'b1: 1'b0);
assign tmp_2_fu_169_p2 = (op_reg_234 == ap_const_lv32_2? 1'b1: 1'b0);
assign tmp_3_fu_191_p2 = ($signed(i_reg_144) < $signed(end_reg_240)? 1'b1: 1'b0);
assign tmp_5_fu_196_p1 = $signed(i_reg_144);
assign tmp_6_fu_221_p2 = (b_Dout_A + a_Dout_A);
assign tmp_7_fu_202_p2 = (i_reg_144 == reg_160? 1'b1: 1'b0);
assign tmp_8_fu_174_p2 = ($signed(i_1_reg_134) < $signed(end_reg_240)? 1'b1: 1'b0);
assign tmp_9_fu_208_p2 = (a_Dout_A - b_Dout_A);
assign tmp_fu_164_p2 = (op_reg_234 == ap_const_lv32_1? 1'b1: 1'b0);
assign tmp_s_fu_179_p1 = $signed(i_1_reg_134);
endmodule 
