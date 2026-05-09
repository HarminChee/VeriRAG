`timescale 1 ns / 1 ps 
`timescale 1 ns / 1 ps 
module pixelq_op_AXIvideo2Mat (
        ap_clk,
        ap_rst,
        ap_start,
        ap_done,
        ap_continue,
        ap_idle,
        ap_ready,
        AXI_video_strm_V_data_V_dout,
        AXI_video_strm_V_data_V_empty_n,
        AXI_video_strm_V_data_V_read,
        AXI_video_strm_V_keep_V_dout,
        AXI_video_strm_V_keep_V_empty_n,
        AXI_video_strm_V_keep_V_read,
        AXI_video_strm_V_strb_V_dout,
        AXI_video_strm_V_strb_V_empty_n,
        AXI_video_strm_V_strb_V_read,
        AXI_video_strm_V_user_V_dout,
        AXI_video_strm_V_user_V_empty_n,
        AXI_video_strm_V_user_V_read,
        AXI_video_strm_V_last_V_dout,
        AXI_video_strm_V_last_V_empty_n,
        AXI_video_strm_V_last_V_read,
        AXI_video_strm_V_id_V_dout,
        AXI_video_strm_V_id_V_empty_n,
        AXI_video_strm_V_id_V_read,
        AXI_video_strm_V_dest_V_dout,
        AXI_video_strm_V_dest_V_empty_n,
        AXI_video_strm_V_dest_V_read,
        img_rows_V_read,
        img_cols_V_read,
        img_data_stream_0_V_din,
        img_data_stream_0_V_full_n,
        img_data_stream_0_V_write,
        img_data_stream_1_V_din,
        img_data_stream_1_V_full_n,
        img_data_stream_1_V_write,
        img_data_stream_2_V_din,
        img_data_stream_2_V_full_n,
        img_data_stream_2_V_write
);
parameter    ap_const_logic_1 = 1'b1;
parameter    ap_const_logic_0 = 1'b0;
parameter    ap_ST_st1_fsm_0 = 7'b1;
parameter    ap_ST_st2_fsm_1 = 7'b10;
parameter    ap_ST_st3_fsm_2 = 7'b100;
parameter    ap_ST_st4_fsm_3 = 7'b1000;
parameter    ap_ST_pp1_stg0_fsm_4 = 7'b10000;
parameter    ap_ST_st7_fsm_5 = 7'b100000;
parameter    ap_ST_st8_fsm_6 = 7'b1000000;
parameter    ap_const_lv32_0 = 32'b00000000000000000000000000000000;
parameter    ap_const_lv1_1 = 1'b1;
parameter    ap_const_lv32_1 = 32'b1;
parameter    ap_const_lv32_3 = 32'b11;
parameter    ap_const_lv32_4 = 32'b100;
parameter    ap_const_lv1_0 = 1'b0;
parameter    ap_const_lv32_5 = 32'b101;
parameter    ap_const_lv32_6 = 32'b110;
parameter    ap_const_lv32_2 = 32'b10;
parameter    ap_const_lv12_0 = 12'b000000000000;
parameter    ap_const_lv12_1 = 12'b1;
parameter    ap_const_lv32_8 = 32'b1000;
parameter    ap_const_lv32_F = 32'b1111;
parameter    ap_const_lv32_10 = 32'b10000;
parameter    ap_const_lv32_17 = 32'b10111;
parameter    ap_true = 1'b1;
input   ap_clk;
input   ap_rst;
input   ap_start;
output   ap_done;
input   ap_continue;
output   ap_idle;
output   ap_ready;
input  [23:0] AXI_video_strm_V_data_V_dout;
input   AXI_video_strm_V_data_V_empty_n;
output   AXI_video_strm_V_data_V_read;
input  [2:0] AXI_video_strm_V_keep_V_dout;
input   AXI_video_strm_V_keep_V_empty_n;
output   AXI_video_strm_V_keep_V_read;
input  [2:0] AXI_video_strm_V_strb_V_dout;
input   AXI_video_strm_V_strb_V_empty_n;
output   AXI_video_strm_V_strb_V_read;
input  [0:0] AXI_video_strm_V_user_V_dout;
input   AXI_video_strm_V_user_V_empty_n;
output   AXI_video_strm_V_user_V_read;
input  [0:0] AXI_video_strm_V_last_V_dout;
input   AXI_video_strm_V_last_V_empty_n;
output   AXI_video_strm_V_last_V_read;
input  [0:0] AXI_video_strm_V_id_V_dout;
input   AXI_video_strm_V_id_V_empty_n;
output   AXI_video_strm_V_id_V_read;
input  [0:0] AXI_video_strm_V_dest_V_dout;
input   AXI_video_strm_V_dest_V_empty_n;
output   AXI_video_strm_V_dest_V_read;
input  [11:0] img_rows_V_read;
input  [11:0] img_cols_V_read;
output  [7:0] img_data_stream_0_V_din;
input   img_data_stream_0_V_full_n;
output   img_data_stream_0_V_write;
output  [7:0] img_data_stream_1_V_din;
input   img_data_stream_1_V_full_n;
output   img_data_stream_1_V_write;
output  [7:0] img_data_stream_2_V_din;
input   img_data_stream_2_V_full_n;
output   img_data_stream_2_V_write;
reg ap_done;
reg ap_idle;
reg ap_ready;
reg img_data_stream_0_V_write;
reg img_data_stream_1_V_write;
reg img_data_stream_2_V_write;
reg    ap_done_reg = 1'b0;
(* fsm_encoding = "none" *) reg   [6:0] ap_CS_fsm = 7'b1;
reg    ap_sig_cseq_ST_st1_fsm_0;
reg    ap_sig_bdd_26;
reg   [11:0] p_1_reg_218;
reg   [0:0] eol_1_reg_229;
reg   [23:0] axi_data_V_1_reg_240;
reg   [0:0] eol_reg_251;
reg    ap_sig_bdd_94;
reg   [23:0] tmp_data_V_reg_439;
reg    ap_sig_cseq_ST_st2_fsm_1;
reg    ap_sig_bdd_106;
wire    AXI_video_strm_V_id_V0_status;
reg   [0:0] tmp_last_V_reg_447;
wire   [0:0] exitcond1_fu_353_p2;
reg    ap_sig_cseq_ST_st4_fsm_3;
reg    ap_sig_bdd_121;
wire   [11:0] i_V_fu_358_p2;
reg   [11:0] i_V_reg_463;
wire   [0:0] exitcond2_fu_364_p2;
reg   [0:0] exitcond2_reg_468;
reg    ap_sig_cseq_ST_pp1_stg0_fsm_4;
reg    ap_sig_bdd_132;
reg    ap_reg_ppiten_pp1_it0 = 1'b0;
wire   [0:0] brmerge_fu_378_p2;
reg    ap_sig_bdd_151;
reg    ap_reg_ppiten_pp1_it1 = 1'b0;
wire   [11:0] j_V_fu_369_p2;
reg    ap_sig_cseq_ST_st7_fsm_5;
reg    ap_sig_bdd_167;
reg    ap_sig_bdd_172;
reg   [0:0] axi_last_V_3_reg_298;
reg   [0:0] axi_last_V1_reg_187;
reg    ap_sig_cseq_ST_st8_fsm_6;
reg    ap_sig_bdd_190;
reg    ap_sig_cseq_ST_st3_fsm_2;
reg    ap_sig_bdd_197;
reg   [23:0] axi_data_V_3_reg_310;
reg   [23:0] axi_data_V1_reg_197;
reg   [11:0] p_s_reg_207;
reg   [0:0] axi_last_V_2_phi_fu_267_p4;
reg   [23:0] p_Val2_s_phi_fu_279_p4;
reg   [0:0] eol_2_phi_fu_291_p4;
wire   [0:0] ap_reg_phiprechg_axi_last_V_2_reg_263pp1_it1;
wire   [23:0] ap_reg_phiprechg_p_Val2_s_reg_275pp1_it1;
wire   [0:0] ap_reg_phiprechg_eol_2_reg_287pp1_it1;
wire   [0:0] axi_last_V_1_mux_fu_390_p2;
reg   [0:0] eol_3_reg_322;
reg    AXI_video_strm_V_id_V0_update;
reg   [0:0] sof_1_fu_132;
wire   [0:0] not_sof_2_fu_384_p2;
wire   [0:0] tmp_user_V_fu_344_p1;
reg   [6:0] ap_NS_fsm;
reg    ap_sig_bdd_253;
always @ (posedge ap_clk)
begin : ap_ret_ap_CS_fsm
    if (ap_rst == 1'b1) begin
        ap_CS_fsm <= ap_ST_st1_fsm_0;
    end else begin
        ap_CS_fsm <= ap_NS_fsm;
    end
end
always @ (posedge ap_clk)
begin : ap_ret_ap_done_reg
    if (ap_rst == 1'b1) begin
        ap_done_reg <= ap_const_logic_0;
    end else begin
        if ((ap_const_logic_1 == ap_continue)) begin
            ap_done_reg <= ap_const_logic_0;
        end else if (((ap_const_logic_1 == ap_sig_cseq_ST_st4_fsm_3) & ~(exitcond1_fu_353_p2 == ap_const_lv1_0))) begin
            ap_done_reg <= ap_const_logic_1;
        end
    end
end
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp1_it0
    if (ap_rst == 1'b1) begin
        ap_reg_ppiten_pp1_it0 <= ap_const_logic_0;
    end else begin
        if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(exitcond2_fu_364_p2 == ap_const_lv1_0))) begin
            ap_reg_ppiten_pp1_it0 <= ap_const_logic_0;
        end else if (((ap_const_logic_1 == ap_sig_cseq_ST_st4_fsm_3) & (exitcond1_fu_353_p2 == ap_const_lv1_0))) begin
            ap_reg_ppiten_pp1_it0 <= ap_const_logic_1;
        end
    end
end
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ppiten_pp1_it1
    if (ap_rst == 1'b1) begin
        ap_reg_ppiten_pp1_it1 <= ap_const_logic_0;
    end else begin
        if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
            ap_reg_ppiten_pp1_it1 <= ap_reg_ppiten_pp1_it0;
        end else if (((ap_const_logic_1 == ap_sig_cseq_ST_st4_fsm_3) & (exitcond1_fu_353_p2 == ap_const_lv1_0))) begin
            ap_reg_ppiten_pp1_it1 <= ap_const_logic_0;
        end
    end
end
always @(posedge ap_clk)
begin
    if ((ap_const_logic_1 == ap_sig_cseq_ST_st3_fsm_2)) begin
        axi_data_V1_reg_197 <= tmp_data_V_reg_439;
    end else if ((ap_const_logic_1 == ap_sig_cseq_ST_st8_fsm_6)) begin
        axi_data_V1_reg_197 <= axi_data_V_3_reg_310;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (exitcond2_reg_468 == ap_const_lv1_0) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
        axi_data_V_1_reg_240 <= p_Val2_s_phi_fu_279_p4;
    end else if (((ap_const_logic_1 == ap_sig_cseq_ST_st4_fsm_3) & (exitcond1_fu_353_p2 == ap_const_lv1_0))) begin
        axi_data_V_1_reg_240 <= axi_data_V1_reg_197;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(exitcond2_reg_468 == ap_const_lv1_0))) begin
        axi_data_V_3_reg_310 <= axi_data_V_1_reg_240;
    end else if (((ap_const_logic_1 == ap_sig_cseq_ST_st7_fsm_5) & (ap_const_lv1_0 == eol_3_reg_322) & ~ap_sig_bdd_172)) begin
        axi_data_V_3_reg_310 <= AXI_video_strm_V_data_V_dout;
    end
end
always @(posedge ap_clk)
begin
    if ((ap_const_logic_1 == ap_sig_cseq_ST_st3_fsm_2)) begin
        axi_last_V1_reg_187 <= tmp_last_V_reg_447;
    end else if ((ap_const_logic_1 == ap_sig_cseq_ST_st8_fsm_6)) begin
        axi_last_V1_reg_187 <= axi_last_V_3_reg_298;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(exitcond2_reg_468 == ap_const_lv1_0))) begin
        axi_last_V_3_reg_298 <= eol_1_reg_229;
    end else if (((ap_const_logic_1 == ap_sig_cseq_ST_st7_fsm_5) & (ap_const_lv1_0 == eol_3_reg_322) & ~ap_sig_bdd_172)) begin
        axi_last_V_3_reg_298 <= AXI_video_strm_V_last_V_dout;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (exitcond2_reg_468 == ap_const_lv1_0) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
        eol_1_reg_229 <= axi_last_V_2_phi_fu_267_p4;
    end else if (((ap_const_logic_1 == ap_sig_cseq_ST_st4_fsm_3) & (exitcond1_fu_353_p2 == ap_const_lv1_0))) begin
        eol_1_reg_229 <= axi_last_V1_reg_187;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(exitcond2_reg_468 == ap_const_lv1_0))) begin
        eol_3_reg_322 <= eol_reg_251;
    end else if (((ap_const_logic_1 == ap_sig_cseq_ST_st7_fsm_5) & (ap_const_lv1_0 == eol_3_reg_322) & ~ap_sig_bdd_172)) begin
        eol_3_reg_322 <= AXI_video_strm_V_last_V_dout;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (exitcond2_reg_468 == ap_const_lv1_0) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
        eol_reg_251 <= eol_2_phi_fu_291_p4;
    end else if (((ap_const_logic_1 == ap_sig_cseq_ST_st4_fsm_3) & (exitcond1_fu_353_p2 == ap_const_lv1_0))) begin
        eol_reg_251 <= ap_const_lv1_0;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it0) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & (exitcond2_fu_364_p2 == ap_const_lv1_0))) begin
        p_1_reg_218 <= j_V_fu_369_p2;
    end else if (((ap_const_logic_1 == ap_sig_cseq_ST_st4_fsm_3) & (exitcond1_fu_353_p2 == ap_const_lv1_0))) begin
        p_1_reg_218 <= ap_const_lv12_0;
    end
end
always @(posedge ap_clk)
begin
    if ((ap_const_logic_1 == ap_sig_cseq_ST_st3_fsm_2)) begin
        p_s_reg_207 <= ap_const_lv12_0;
    end else if ((ap_const_logic_1 == ap_sig_cseq_ST_st8_fsm_6)) begin
        p_s_reg_207 <= i_V_reg_463;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (exitcond2_reg_468 == ap_const_lv1_0) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
        sof_1_fu_132 <= ap_const_lv1_0;
    end else if ((ap_const_logic_1 == ap_sig_cseq_ST_st3_fsm_2)) begin
        sof_1_fu_132 <= ap_const_lv1_1;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
        exitcond2_reg_468 <= exitcond2_fu_364_p2;
    end
end
always @(posedge ap_clk)
begin
    if ((ap_const_logic_1 == ap_sig_cseq_ST_st4_fsm_3)) begin
        i_V_reg_463 <= i_V_fu_358_p2;
    end
end
always @(posedge ap_clk)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_st2_fsm_1) & ~(AXI_video_strm_V_id_V0_status == ap_const_logic_0))) begin
        tmp_data_V_reg_439 <= AXI_video_strm_V_data_V_dout;
        tmp_last_V_reg_447 <= AXI_video_strm_V_last_V_dout;
    end
end
always @ (ap_sig_cseq_ST_st2_fsm_1 or AXI_video_strm_V_id_V0_status or exitcond2_reg_468 or ap_sig_cseq_ST_pp1_stg0_fsm_4 or brmerge_fu_378_p2 or ap_sig_bdd_151 or ap_reg_ppiten_pp1_it1 or ap_sig_cseq_ST_st7_fsm_5 or ap_sig_bdd_172 or eol_3_reg_322)
begin
    if ((((ap_const_logic_1 == ap_sig_cseq_ST_st2_fsm_1) & ~(AXI_video_strm_V_id_V0_status == ap_const_logic_0)) | ((ap_const_logic_1 == ap_sig_cseq_ST_st7_fsm_5) & (ap_const_lv1_0 == eol_3_reg_322) & ~ap_sig_bdd_172) | ((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (exitcond2_reg_468 == ap_const_lv1_0) & (ap_const_lv1_0 == brmerge_fu_378_p2) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1))))) begin
        AXI_video_strm_V_id_V0_update = ap_const_logic_1;
    end else begin
        AXI_video_strm_V_id_V0_update = ap_const_logic_0;
    end
end
always @ (ap_done_reg or exitcond1_fu_353_p2 or ap_sig_cseq_ST_st4_fsm_3)
begin
    if (((ap_const_logic_1 == ap_done_reg) | ((ap_const_logic_1 == ap_sig_cseq_ST_st4_fsm_3) & ~(exitcond1_fu_353_p2 == ap_const_lv1_0)))) begin
        ap_done = ap_const_logic_1;
    end else begin
        ap_done = ap_const_logic_0;
    end
end
always @ (ap_start or ap_sig_cseq_ST_st1_fsm_0)
begin
    if ((~(ap_const_logic_1 == ap_start) & (ap_const_logic_1 == ap_sig_cseq_ST_st1_fsm_0))) begin
        ap_idle = ap_const_logic_1;
    end else begin
        ap_idle = ap_const_logic_0;
    end
end
always @ (exitcond1_fu_353_p2 or ap_sig_cseq_ST_st4_fsm_3)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_st4_fsm_3) & ~(exitcond1_fu_353_p2 == ap_const_lv1_0))) begin
        ap_ready = ap_const_logic_1;
    end else begin
        ap_ready = ap_const_logic_0;
    end
end
always @ (ap_sig_bdd_132)
begin
    if (ap_sig_bdd_132) begin
        ap_sig_cseq_ST_pp1_stg0_fsm_4 = ap_const_logic_1;
    end else begin
        ap_sig_cseq_ST_pp1_stg0_fsm_4 = ap_const_logic_0;
    end
end
always @ (ap_sig_bdd_26)
begin
    if (ap_sig_bdd_26) begin
        ap_sig_cseq_ST_st1_fsm_0 = ap_const_logic_1;
    end else begin
        ap_sig_cseq_ST_st1_fsm_0 = ap_const_logic_0;
    end
end
always @ (ap_sig_bdd_106)
begin
    if (ap_sig_bdd_106) begin
        ap_sig_cseq_ST_st2_fsm_1 = ap_const_logic_1;
    end else begin
        ap_sig_cseq_ST_st2_fsm_1 = ap_const_logic_0;
    end
end
always @ (ap_sig_bdd_197)
begin
    if (ap_sig_bdd_197) begin
        ap_sig_cseq_ST_st3_fsm_2 = ap_const_logic_1;
    end else begin
        ap_sig_cseq_ST_st3_fsm_2 = ap_const_logic_0;
    end
end
always @ (ap_sig_bdd_121)
begin
    if (ap_sig_bdd_121) begin
        ap_sig_cseq_ST_st4_fsm_3 = ap_const_logic_1;
    end else begin
        ap_sig_cseq_ST_st4_fsm_3 = ap_const_logic_0;
    end
end
always @ (ap_sig_bdd_167)
begin
    if (ap_sig_bdd_167) begin
        ap_sig_cseq_ST_st7_fsm_5 = ap_const_logic_1;
    end else begin
        ap_sig_cseq_ST_st7_fsm_5 = ap_const_logic_0;
    end
end
always @ (ap_sig_bdd_190)
begin
    if (ap_sig_bdd_190) begin
        ap_sig_cseq_ST_st8_fsm_6 = ap_const_logic_1;
    end else begin
        ap_sig_cseq_ST_st8_fsm_6 = ap_const_logic_0;
    end
end
always @ (AXI_video_strm_V_last_V_dout or eol_1_reg_229 or brmerge_fu_378_p2 or ap_reg_phiprechg_axi_last_V_2_reg_263pp1_it1 or ap_sig_bdd_253)
begin
    if (ap_sig_bdd_253) begin
        if (~(ap_const_lv1_0 == brmerge_fu_378_p2)) begin
            axi_last_V_2_phi_fu_267_p4 = eol_1_reg_229;
        end else if ((ap_const_lv1_0 == brmerge_fu_378_p2)) begin
            axi_last_V_2_phi_fu_267_p4 = AXI_video_strm_V_last_V_dout;
        end else begin
            axi_last_V_2_phi_fu_267_p4 = ap_reg_phiprechg_axi_last_V_2_reg_263pp1_it1;
        end
    end else begin
        axi_last_V_2_phi_fu_267_p4 = ap_reg_phiprechg_axi_last_V_2_reg_263pp1_it1;
    end
end
always @ (AXI_video_strm_V_last_V_dout or brmerge_fu_378_p2 or ap_reg_phiprechg_eol_2_reg_287pp1_it1 or axi_last_V_1_mux_fu_390_p2 or ap_sig_bdd_253)
begin
    if (ap_sig_bdd_253) begin
        if (~(ap_const_lv1_0 == brmerge_fu_378_p2)) begin
            eol_2_phi_fu_291_p4 = axi_last_V_1_mux_fu_390_p2;
        end else if ((ap_const_lv1_0 == brmerge_fu_378_p2)) begin
            eol_2_phi_fu_291_p4 = AXI_video_strm_V_last_V_dout;
        end else begin
            eol_2_phi_fu_291_p4 = ap_reg_phiprechg_eol_2_reg_287pp1_it1;
        end
    end else begin
        eol_2_phi_fu_291_p4 = ap_reg_phiprechg_eol_2_reg_287pp1_it1;
    end
end
always @ (exitcond2_reg_468 or ap_sig_cseq_ST_pp1_stg0_fsm_4 or ap_sig_bdd_151 or ap_reg_ppiten_pp1_it1)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (exitcond2_reg_468 == ap_const_lv1_0) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
        img_data_stream_0_V_write = ap_const_logic_1;
    end else begin
        img_data_stream_0_V_write = ap_const_logic_0;
    end
end
always @ (exitcond2_reg_468 or ap_sig_cseq_ST_pp1_stg0_fsm_4 or ap_sig_bdd_151 or ap_reg_ppiten_pp1_it1)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (exitcond2_reg_468 == ap_const_lv1_0) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
        img_data_stream_1_V_write = ap_const_logic_1;
    end else begin
        img_data_stream_1_V_write = ap_const_logic_0;
    end
end
always @ (exitcond2_reg_468 or ap_sig_cseq_ST_pp1_stg0_fsm_4 or ap_sig_bdd_151 or ap_reg_ppiten_pp1_it1)
begin
    if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (exitcond2_reg_468 == ap_const_lv1_0) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)))) begin
        img_data_stream_2_V_write = ap_const_logic_1;
    end else begin
        img_data_stream_2_V_write = ap_const_logic_0;
    end
end
always @ (AXI_video_strm_V_data_V_dout or axi_data_V_1_reg_240 or brmerge_fu_378_p2 or ap_reg_phiprechg_p_Val2_s_reg_275pp1_it1 or ap_sig_bdd_253)
begin
    if (ap_sig_bdd_253) begin
        if (~(ap_const_lv1_0 == brmerge_fu_378_p2)) begin
            p_Val2_s_phi_fu_279_p4 = axi_data_V_1_reg_240;
        end else if ((ap_const_lv1_0 == brmerge_fu_378_p2)) begin
            p_Val2_s_phi_fu_279_p4 = AXI_video_strm_V_data_V_dout;
        end else begin
            p_Val2_s_phi_fu_279_p4 = ap_reg_phiprechg_p_Val2_s_reg_275pp1_it1;
        end
    end else begin
        p_Val2_s_phi_fu_279_p4 = ap_reg_phiprechg_p_Val2_s_reg_275pp1_it1;
    end
end
always @ (ap_CS_fsm or ap_sig_bdd_94 or AXI_video_strm_V_id_V0_status or exitcond1_fu_353_p2 or ap_sig_cseq_ST_pp1_stg0_fsm_4 or ap_reg_ppiten_pp1_it0 or ap_sig_bdd_151 or ap_reg_ppiten_pp1_it1 or ap_sig_bdd_172 or eol_3_reg_322 or tmp_user_V_fu_344_p1)
begin
    case (ap_CS_fsm)
        ap_ST_st1_fsm_0 : 
        begin
            if (~ap_sig_bdd_94) begin
                ap_NS_fsm = ap_ST_st2_fsm_1;
            end else begin
                ap_NS_fsm = ap_ST_st1_fsm_0;
            end
        end
        ap_ST_st2_fsm_1 : 
        begin
            if ((~(AXI_video_strm_V_id_V0_status == ap_const_logic_0) & (ap_const_lv1_0 == tmp_user_V_fu_344_p1))) begin
                ap_NS_fsm = ap_ST_st2_fsm_1;
            end else if ((~(AXI_video_strm_V_id_V0_status == ap_const_logic_0) & ~(ap_const_lv1_0 == tmp_user_V_fu_344_p1))) begin
                ap_NS_fsm = ap_ST_st3_fsm_2;
            end else begin
                ap_NS_fsm = ap_ST_st2_fsm_1;
            end
        end
        ap_ST_st3_fsm_2 : 
        begin
            ap_NS_fsm = ap_ST_st4_fsm_3;
        end
        ap_ST_st4_fsm_3 : 
        begin
            if (~(exitcond1_fu_353_p2 == ap_const_lv1_0)) begin
                ap_NS_fsm = ap_ST_st1_fsm_0;
            end else begin
                ap_NS_fsm = ap_ST_pp1_stg0_fsm_4;
            end
        end
        ap_ST_pp1_stg0_fsm_4 : 
        begin
            if (~((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(ap_const_logic_1 == ap_reg_ppiten_pp1_it0))) begin
                ap_NS_fsm = ap_ST_pp1_stg0_fsm_4;
            end else if (((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1) & ~(ap_sig_bdd_151 & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1)) & ~(ap_const_logic_1 == ap_reg_ppiten_pp1_it0))) begin
                ap_NS_fsm = ap_ST_st7_fsm_5;
            end else begin
                ap_NS_fsm = ap_ST_pp1_stg0_fsm_4;
            end
        end
        ap_ST_st7_fsm_5 : 
        begin
            if (((ap_const_lv1_0 == eol_3_reg_322) & ~ap_sig_bdd_172)) begin
                ap_NS_fsm = ap_ST_st7_fsm_5;
            end else if ((~ap_sig_bdd_172 & ~(ap_const_lv1_0 == eol_3_reg_322))) begin
                ap_NS_fsm = ap_ST_st8_fsm_6;
            end else begin
                ap_NS_fsm = ap_ST_st7_fsm_5;
            end
        end
        ap_ST_st8_fsm_6 : 
        begin
            ap_NS_fsm = ap_ST_st4_fsm_3;
        end
        default : 
        begin
            ap_NS_fsm = 'bx;
        end
    endcase
end
assign AXI_video_strm_V_data_V_read = AXI_video_strm_V_id_V0_update;
assign AXI_video_strm_V_dest_V_read = AXI_video_strm_V_id_V0_update;
assign AXI_video_strm_V_id_V0_status = (AXI_video_strm_V_data_V_empty_n & AXI_video_strm_V_keep_V_empty_n & AXI_video_strm_V_strb_V_empty_n & AXI_video_strm_V_user_V_empty_n & AXI_video_strm_V_last_V_empty_n & AXI_video_strm_V_id_V_empty_n & AXI_video_strm_V_dest_V_empty_n);
assign AXI_video_strm_V_id_V_read = AXI_video_strm_V_id_V0_update;
assign AXI_video_strm_V_keep_V_read = AXI_video_strm_V_id_V0_update;
assign AXI_video_strm_V_last_V_read = AXI_video_strm_V_id_V0_update;
assign AXI_video_strm_V_strb_V_read = AXI_video_strm_V_id_V0_update;
assign AXI_video_strm_V_user_V_read = AXI_video_strm_V_id_V0_update;
assign ap_reg_phiprechg_axi_last_V_2_reg_263pp1_it1 = 'bx;
assign ap_reg_phiprechg_eol_2_reg_287pp1_it1 = 'bx;
assign ap_reg_phiprechg_p_Val2_s_reg_275pp1_it1 = 'bx;
always @ (ap_CS_fsm)
begin
    ap_sig_bdd_106 = (ap_const_lv1_1 == ap_CS_fsm[ap_const_lv32_1]);
end
always @ (ap_CS_fsm)
begin
    ap_sig_bdd_121 = (ap_const_lv1_1 == ap_CS_fsm[ap_const_lv32_3]);
end
always @ (ap_CS_fsm)
begin
    ap_sig_bdd_132 = (ap_const_lv1_1 == ap_CS_fsm[ap_const_lv32_4]);
end
always @ (img_data_stream_0_V_full_n or img_data_stream_1_V_full_n or img_data_stream_2_V_full_n or AXI_video_strm_V_id_V0_status or exitcond2_reg_468 or brmerge_fu_378_p2)
begin
    ap_sig_bdd_151 = (((AXI_video_strm_V_id_V0_status == ap_const_logic_0) & (exitcond2_reg_468 == ap_const_lv1_0) & (ap_const_lv1_0 == brmerge_fu_378_p2)) | ((exitcond2_reg_468 == ap_const_lv1_0) & (img_data_stream_0_V_full_n == ap_const_logic_0)) | ((exitcond2_reg_468 == ap_const_lv1_0) & (img_data_stream_1_V_full_n == ap_const_logic_0)) | ((exitcond2_reg_468 == ap_const_lv1_0) & (img_data_stream_2_V_full_n == ap_const_logic_0)));
end
always @ (ap_CS_fsm)
begin
    ap_sig_bdd_167 = (ap_const_lv1_1 == ap_CS_fsm[ap_const_lv32_5]);
end
always @ (AXI_video_strm_V_id_V0_status or eol_3_reg_322)
begin
    ap_sig_bdd_172 = ((AXI_video_strm_V_id_V0_status == ap_const_logic_0) & (ap_const_lv1_0 == eol_3_reg_322));
end
always @ (ap_CS_fsm)
begin
    ap_sig_bdd_190 = (ap_const_lv1_1 == ap_CS_fsm[ap_const_lv32_6]);
end
always @ (ap_CS_fsm)
begin
    ap_sig_bdd_197 = (ap_const_lv1_1 == ap_CS_fsm[ap_const_lv32_2]);
end
always @ (exitcond2_reg_468 or ap_sig_cseq_ST_pp1_stg0_fsm_4 or ap_reg_ppiten_pp1_it1)
begin
    ap_sig_bdd_253 = ((ap_const_logic_1 == ap_sig_cseq_ST_pp1_stg0_fsm_4) & (exitcond2_reg_468 == ap_const_lv1_0) & (ap_const_logic_1 == ap_reg_ppiten_pp1_it1));
end
always @ (ap_CS_fsm)
begin
    ap_sig_bdd_26 = (ap_CS_fsm[ap_const_lv32_0] == ap_const_lv1_1);
end
always @ (ap_start or ap_done_reg)
begin
    ap_sig_bdd_94 = ((ap_start == ap_const_logic_0) | (ap_done_reg == ap_const_logic_1));
end
assign axi_last_V_1_mux_fu_390_p2 = (eol_1_reg_229 | not_sof_2_fu_384_p2);
assign brmerge_fu_378_p2 = (sof_1_fu_132 | eol_reg_251);
assign exitcond1_fu_353_p2 = (p_s_reg_207 == img_rows_V_read? 1'b1: 1'b0);
assign exitcond2_fu_364_p2 = (p_1_reg_218 == img_cols_V_read? 1'b1: 1'b0);
assign i_V_fu_358_p2 = (p_s_reg_207 + ap_const_lv12_1);
assign img_data_stream_0_V_din = p_Val2_s_phi_fu_279_p4[7:0];
assign img_data_stream_1_V_din = {{p_Val2_s_phi_fu_279_p4[ap_const_lv32_F : ap_const_lv32_8]}};
assign img_data_stream_2_V_din = {{p_Val2_s_phi_fu_279_p4[ap_const_lv32_17 : ap_const_lv32_10]}};
assign j_V_fu_369_p2 = (p_1_reg_218 + ap_const_lv12_1);
assign not_sof_2_fu_384_p2 = (sof_1_fu_132 ^ ap_const_lv1_1);
assign tmp_user_V_fu_344_p1 = AXI_video_strm_V_user_V_dout;
endmodule 
