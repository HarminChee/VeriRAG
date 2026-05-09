`timescale 1 ns / 1 ps 
`timescale 1 ns / 1 ps 
module qam_dem_top (
        din_i_V,
        din_q_V,
        dout_mix_i_V,
        dout_mix_q_V,
        ph_in_i_V,
        ph_in_q_V,
        ph_out_i_V,
        ph_out_q_V,
        loop_integ_V,
        control_qam_V,
        control_lf_p,
        control_lf_i,
        control_lf_out_gain,
        control_reg_clr,
        control_reg_init_V,
        ap_clk,
        ap_rst,
        ap_done,
        ap_start,
        ap_idle,
        ap_ready
);
parameter    ap_const_lv16_0 = 16'b0000000000000000;
parameter    ap_const_lv12_0 = 12'b000000000000;
parameter    ap_const_lv28_0 = 28'b0000000000000000000000000000;
parameter    ap_const_logic_1 = 1'b1;
parameter    ap_true = 1'b1;
parameter    ap_const_logic_0 = 1'b0;
input  [15:0] din_i_V;
input  [15:0] din_q_V;
output  [15:0] dout_mix_i_V;
output  [15:0] dout_mix_q_V;
input  [11:0] ph_in_i_V;
input  [11:0] ph_in_q_V;
output  [11:0] ph_out_i_V;
output  [11:0] ph_out_q_V;
output  [27:0] loop_integ_V;
input  [1:0] control_qam_V;
input  [7:0] control_lf_p;
input  [7:0] control_lf_i;
input  [7:0] control_lf_out_gain;
input  [0:0] control_reg_clr;
input  [27:0] control_reg_init_V;
input   ap_clk;
input   ap_rst;
output   ap_done;
input   ap_start;
output   ap_idle;
output   ap_ready;
reg ap_idle;
wire    qam_dem_top_mounstrito_U0_ap_start;
wire    qam_dem_top_mounstrito_U0_ap_done;
wire    qam_dem_top_mounstrito_U0_ap_continue;
wire    qam_dem_top_mounstrito_U0_ap_idle;
wire    qam_dem_top_mounstrito_U0_ap_ready;
wire   [15:0] qam_dem_top_mounstrito_U0_din_i_V;
wire   [15:0] qam_dem_top_mounstrito_U0_din_q_V;
wire   [15:0] qam_dem_top_mounstrito_U0_dout_mix_i_V;
wire    qam_dem_top_mounstrito_U0_dout_mix_i_V_ap_vld;
wire   [15:0] qam_dem_top_mounstrito_U0_dout_mix_q_V;
wire    qam_dem_top_mounstrito_U0_dout_mix_q_V_ap_vld;
wire   [11:0] qam_dem_top_mounstrito_U0_ph_in_i_V;
wire   [11:0] qam_dem_top_mounstrito_U0_ph_in_q_V;
wire   [11:0] qam_dem_top_mounstrito_U0_ph_out_i_V;
wire    qam_dem_top_mounstrito_U0_ph_out_i_V_ap_vld;
wire   [11:0] qam_dem_top_mounstrito_U0_ph_out_q_V;
wire    qam_dem_top_mounstrito_U0_ph_out_q_V_ap_vld;
wire   [27:0] qam_dem_top_mounstrito_U0_loop_integ_V;
wire    qam_dem_top_mounstrito_U0_loop_integ_V_ap_vld;
wire   [7:0] qam_dem_top_mounstrito_U0_control_lf_p;
wire   [7:0] qam_dem_top_mounstrito_U0_control_lf_i;
wire   [7:0] qam_dem_top_mounstrito_U0_control_lf_out_gain;
wire   [0:0] qam_dem_top_mounstrito_U0_control_reg_clr;
wire   [27:0] qam_dem_top_mounstrito_U0_control_reg_init_V;
wire    ap_sig_hs_continue;
reg    ap_reg_procdone_qam_dem_top_mounstrito_U0 = 1'b0;
reg    ap_sig_hs_done;
reg    ap_CS;
wire    ap_sig_top_allready;
qam_dem_top_mounstrito qam_dem_top_mounstrito_U0(
    .ap_clk( ap_clk ),
    .ap_rst( ap_rst ),
    .ap_start( qam_dem_top_mounstrito_U0_ap_start ),
    .ap_done( qam_dem_top_mounstrito_U0_ap_done ),
    .ap_continue( qam_dem_top_mounstrito_U0_ap_continue ),
    .ap_idle( qam_dem_top_mounstrito_U0_ap_idle ),
    .ap_ready( qam_dem_top_mounstrito_U0_ap_ready ),
    .din_i_V( qam_dem_top_mounstrito_U0_din_i_V ),
    .din_q_V( qam_dem_top_mounstrito_U0_din_q_V ),
    .dout_mix_i_V( qam_dem_top_mounstrito_U0_dout_mix_i_V ),
    .dout_mix_i_V_ap_vld( qam_dem_top_mounstrito_U0_dout_mix_i_V_ap_vld ),
    .dout_mix_q_V( qam_dem_top_mounstrito_U0_dout_mix_q_V ),
    .dout_mix_q_V_ap_vld( qam_dem_top_mounstrito_U0_dout_mix_q_V_ap_vld ),
    .ph_in_i_V( qam_dem_top_mounstrito_U0_ph_in_i_V ),
    .ph_in_q_V( qam_dem_top_mounstrito_U0_ph_in_q_V ),
    .ph_out_i_V( qam_dem_top_mounstrito_U0_ph_out_i_V ),
    .ph_out_i_V_ap_vld( qam_dem_top_mounstrito_U0_ph_out_i_V_ap_vld ),
    .ph_out_q_V( qam_dem_top_mounstrito_U0_ph_out_q_V ),
    .ph_out_q_V_ap_vld( qam_dem_top_mounstrito_U0_ph_out_q_V_ap_vld ),
    .loop_integ_V( qam_dem_top_mounstrito_U0_loop_integ_V ),
    .loop_integ_V_ap_vld( qam_dem_top_mounstrito_U0_loop_integ_V_ap_vld ),
    .control_lf_p( qam_dem_top_mounstrito_U0_control_lf_p ),
    .control_lf_i( qam_dem_top_mounstrito_U0_control_lf_i ),
    .control_lf_out_gain( qam_dem_top_mounstrito_U0_control_lf_out_gain ),
    .control_reg_clr( qam_dem_top_mounstrito_U0_control_reg_clr ),
    .control_reg_init_V( qam_dem_top_mounstrito_U0_control_reg_init_V )
);
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_procdone_qam_dem_top_mounstrito_U0
    if (ap_rst == 1'b1) begin
        ap_reg_procdone_qam_dem_top_mounstrito_U0 <= ap_const_logic_0;
    end else begin
        if ((ap_const_logic_1 == ap_sig_hs_done)) begin
            ap_reg_procdone_qam_dem_top_mounstrito_U0 <= ap_const_logic_0;
        end else if ((qam_dem_top_mounstrito_U0_ap_done == ap_const_logic_1)) begin
            ap_reg_procdone_qam_dem_top_mounstrito_U0 <= ap_const_logic_1;
        end
    end
end
always @(posedge ap_clk)
begin
    ap_CS <= ap_const_logic_0;
end
always @ (qam_dem_top_mounstrito_U0_ap_idle)
begin
    if ((qam_dem_top_mounstrito_U0_ap_idle == ap_const_logic_1)) begin
        ap_idle = ap_const_logic_1;
    end else begin
        ap_idle = ap_const_logic_0;
    end
end
always @ (qam_dem_top_mounstrito_U0_ap_done)
begin
    if ((qam_dem_top_mounstrito_U0_ap_done == ap_const_logic_1)) begin
        ap_sig_hs_done = ap_const_logic_1;
    end else begin
        ap_sig_hs_done = ap_const_logic_0;
    end
end
assign ap_done = ap_sig_hs_done;
assign ap_ready = ap_sig_top_allready;
assign ap_sig_hs_continue = ap_const_logic_1;
assign ap_sig_top_allready = qam_dem_top_mounstrito_U0_ap_ready;
assign dout_mix_i_V = qam_dem_top_mounstrito_U0_dout_mix_i_V;
assign dout_mix_q_V = qam_dem_top_mounstrito_U0_dout_mix_q_V;
assign loop_integ_V = qam_dem_top_mounstrito_U0_loop_integ_V;
assign ph_out_i_V = qam_dem_top_mounstrito_U0_ph_out_i_V;
assign ph_out_q_V = qam_dem_top_mounstrito_U0_ph_out_q_V;
assign qam_dem_top_mounstrito_U0_ap_continue = ap_sig_hs_continue;
assign qam_dem_top_mounstrito_U0_ap_start = ap_start;
assign qam_dem_top_mounstrito_U0_control_lf_i = control_lf_i;
assign qam_dem_top_mounstrito_U0_control_lf_out_gain = control_lf_out_gain;
assign qam_dem_top_mounstrito_U0_control_lf_p = control_lf_p;
assign qam_dem_top_mounstrito_U0_control_reg_clr = control_reg_clr;
assign qam_dem_top_mounstrito_U0_control_reg_init_V = control_reg_init_V;
assign qam_dem_top_mounstrito_U0_din_i_V = din_i_V;
assign qam_dem_top_mounstrito_U0_din_q_V = din_q_V;
assign qam_dem_top_mounstrito_U0_ph_in_i_V = ph_in_i_V;
assign qam_dem_top_mounstrito_U0_ph_in_q_V = ph_in_q_V;
endmodule 
