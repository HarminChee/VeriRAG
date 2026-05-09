`timescale 1 ns / 1 ps 
`timescale 1 ns / 1 ps 
module pixelq_op (
        src_axi_V_data_V_dout,
        src_axi_V_data_V_empty_n,
        src_axi_V_data_V_read,
        src_axi_V_keep_V_dout,
        src_axi_V_keep_V_empty_n,
        src_axi_V_keep_V_read,
        src_axi_V_strb_V_dout,
        src_axi_V_strb_V_empty_n,
        src_axi_V_strb_V_read,
        src_axi_V_user_V_dout,
        src_axi_V_user_V_empty_n,
        src_axi_V_user_V_read,
        src_axi_V_last_V_dout,
        src_axi_V_last_V_empty_n,
        src_axi_V_last_V_read,
        src_axi_V_id_V_dout,
        src_axi_V_id_V_empty_n,
        src_axi_V_id_V_read,
        src_axi_V_dest_V_dout,
        src_axi_V_dest_V_empty_n,
        src_axi_V_dest_V_read,
        dst_axi_V_data_V_din,
        dst_axi_V_data_V_full_n,
        dst_axi_V_data_V_write,
        dst_axi_V_keep_V_din,
        dst_axi_V_keep_V_full_n,
        dst_axi_V_keep_V_write,
        dst_axi_V_strb_V_din,
        dst_axi_V_strb_V_full_n,
        dst_axi_V_strb_V_write,
        dst_axi_V_user_V_din,
        dst_axi_V_user_V_full_n,
        dst_axi_V_user_V_write,
        dst_axi_V_last_V_din,
        dst_axi_V_last_V_full_n,
        dst_axi_V_last_V_write,
        dst_axi_V_id_V_din,
        dst_axi_V_id_V_full_n,
        dst_axi_V_id_V_write,
        dst_axi_V_dest_V_din,
        dst_axi_V_dest_V_full_n,
        dst_axi_V_dest_V_write,
        rows,
        cols,
        ap_clk,
        ap_rst,
        ap_done,
        ap_start,
        ap_idle,
        ap_ready
);
parameter    ap_const_logic_0 = 1'b0;
parameter    ap_const_lv24_0 = 24'b000000000000000000000000;
parameter    ap_const_lv3_0 = 3'b000;
parameter    ap_const_lv1_0 = 1'b0;
parameter    ap_const_logic_1 = 1'b1;
parameter    ap_true = 1'b1;
input  [23:0] src_axi_V_data_V_dout;
input   src_axi_V_data_V_empty_n;
output   src_axi_V_data_V_read;
input  [2:0] src_axi_V_keep_V_dout;
input   src_axi_V_keep_V_empty_n;
output   src_axi_V_keep_V_read;
input  [2:0] src_axi_V_strb_V_dout;
input   src_axi_V_strb_V_empty_n;
output   src_axi_V_strb_V_read;
input  [0:0] src_axi_V_user_V_dout;
input   src_axi_V_user_V_empty_n;
output   src_axi_V_user_V_read;
input  [0:0] src_axi_V_last_V_dout;
input   src_axi_V_last_V_empty_n;
output   src_axi_V_last_V_read;
input  [0:0] src_axi_V_id_V_dout;
input   src_axi_V_id_V_empty_n;
output   src_axi_V_id_V_read;
input  [0:0] src_axi_V_dest_V_dout;
input   src_axi_V_dest_V_empty_n;
output   src_axi_V_dest_V_read;
output  [23:0] dst_axi_V_data_V_din;
input   dst_axi_V_data_V_full_n;
output   dst_axi_V_data_V_write;
output  [2:0] dst_axi_V_keep_V_din;
input   dst_axi_V_keep_V_full_n;
output   dst_axi_V_keep_V_write;
output  [2:0] dst_axi_V_strb_V_din;
input   dst_axi_V_strb_V_full_n;
output   dst_axi_V_strb_V_write;
output  [0:0] dst_axi_V_user_V_din;
input   dst_axi_V_user_V_full_n;
output   dst_axi_V_user_V_write;
output  [0:0] dst_axi_V_last_V_din;
input   dst_axi_V_last_V_full_n;
output   dst_axi_V_last_V_write;
output  [0:0] dst_axi_V_id_V_din;
input   dst_axi_V_id_V_full_n;
output   dst_axi_V_id_V_write;
output  [0:0] dst_axi_V_dest_V_din;
input   dst_axi_V_dest_V_full_n;
output   dst_axi_V_dest_V_write;
input  [31:0] rows;
input  [31:0] cols;
input   ap_clk;
input   ap_rst;
output   ap_done;
input   ap_start;
output   ap_idle;
output   ap_ready;
reg ap_idle;
reg    pixelq_op_Block_proc_U0_ap_start = 1'b0;
wire    pixelq_op_Block_proc_U0_ap_done;
reg    pixelq_op_Block_proc_U0_ap_continue;
wire    pixelq_op_Block_proc_U0_ap_idle;
wire    pixelq_op_Block_proc_U0_ap_ready;
wire   [11:0] pixelq_op_Block_proc_U0_ap_return_0;
wire   [11:0] pixelq_op_Block_proc_U0_ap_return_1;
wire   [11:0] pixelq_op_Block_proc_U0_ap_return_2;
wire   [11:0] pixelq_op_Block_proc_U0_ap_return_3;
reg    ap_chn_write_pixelq_op_Block_proc_U0_img_cols_V_channel;
wire    img_cols_V_channel_full_n;
reg    ap_reg_ready_img_cols_V_channel_full_n = 1'b0;
reg    ap_sig_ready_img_cols_V_channel_full_n;
reg    ap_chn_write_pixelq_op_Block_proc_U0_img_rows_V_channel3;
wire    img_rows_V_channel3_full_n;
reg    ap_reg_ready_img_rows_V_channel3_full_n = 1'b0;
reg    ap_sig_ready_img_rows_V_channel3_full_n;
reg    ap_chn_write_pixelq_op_Block_proc_U0_img_rows_V_channel;
wire    img_rows_V_channel_full_n;
reg    ap_reg_ready_img_rows_V_channel_full_n = 1'b0;
reg    ap_sig_ready_img_rows_V_channel_full_n;
reg    ap_chn_write_pixelq_op_Block_proc_U0_img_cols_V_channel4;
wire    img_cols_V_channel4_full_n;
reg    ap_reg_ready_img_cols_V_channel4_full_n = 1'b0;
reg    ap_sig_ready_img_cols_V_channel4_full_n;
wire    pixelq_op_AXIvideo2Mat_U0_ap_start;
wire    pixelq_op_AXIvideo2Mat_U0_ap_done;
wire    pixelq_op_AXIvideo2Mat_U0_ap_continue;
wire    pixelq_op_AXIvideo2Mat_U0_ap_idle;
wire    pixelq_op_AXIvideo2Mat_U0_ap_ready;
wire   [23:0] pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_data_V_dout;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_data_V_empty_n;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_data_V_read;
wire   [2:0] pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_keep_V_dout;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_keep_V_empty_n;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_keep_V_read;
wire   [2:0] pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_strb_V_dout;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_strb_V_empty_n;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_strb_V_read;
wire   [0:0] pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_user_V_dout;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_user_V_empty_n;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_user_V_read;
wire   [0:0] pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_last_V_dout;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_last_V_empty_n;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_last_V_read;
wire   [0:0] pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_id_V_dout;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_id_V_empty_n;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_id_V_read;
wire   [0:0] pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_dest_V_dout;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_dest_V_empty_n;
wire    pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_dest_V_read;
wire   [11:0] pixelq_op_AXIvideo2Mat_U0_img_rows_V_read;
wire   [11:0] pixelq_op_AXIvideo2Mat_U0_img_cols_V_read;
wire   [7:0] pixelq_op_AXIvideo2Mat_U0_img_data_stream_0_V_din;
wire    pixelq_op_AXIvideo2Mat_U0_img_data_stream_0_V_full_n;
wire    pixelq_op_AXIvideo2Mat_U0_img_data_stream_0_V_write;
wire   [7:0] pixelq_op_AXIvideo2Mat_U0_img_data_stream_1_V_din;
wire    pixelq_op_AXIvideo2Mat_U0_img_data_stream_1_V_full_n;
wire    pixelq_op_AXIvideo2Mat_U0_img_data_stream_1_V_write;
wire   [7:0] pixelq_op_AXIvideo2Mat_U0_img_data_stream_2_V_din;
wire    pixelq_op_AXIvideo2Mat_U0_img_data_stream_2_V_full_n;
wire    pixelq_op_AXIvideo2Mat_U0_img_data_stream_2_V_write;
wire    pixelq_op_Mat2AXIvideo_U0_ap_start;
wire    pixelq_op_Mat2AXIvideo_U0_ap_done;
wire    pixelq_op_Mat2AXIvideo_U0_ap_continue;
wire    pixelq_op_Mat2AXIvideo_U0_ap_idle;
wire    pixelq_op_Mat2AXIvideo_U0_ap_ready;
wire   [11:0] pixelq_op_Mat2AXIvideo_U0_img_rows_V_read;
wire   [11:0] pixelq_op_Mat2AXIvideo_U0_img_cols_V_read;
wire   [7:0] pixelq_op_Mat2AXIvideo_U0_img_data_stream_0_V_dout;
wire    pixelq_op_Mat2AXIvideo_U0_img_data_stream_0_V_empty_n;
wire    pixelq_op_Mat2AXIvideo_U0_img_data_stream_0_V_read;
wire   [7:0] pixelq_op_Mat2AXIvideo_U0_img_data_stream_1_V_dout;
wire    pixelq_op_Mat2AXIvideo_U0_img_data_stream_1_V_empty_n;
wire    pixelq_op_Mat2AXIvideo_U0_img_data_stream_1_V_read;
wire   [7:0] pixelq_op_Mat2AXIvideo_U0_img_data_stream_2_V_dout;
wire    pixelq_op_Mat2AXIvideo_U0_img_data_stream_2_V_empty_n;
wire    pixelq_op_Mat2AXIvideo_U0_img_data_stream_2_V_read;
wire   [23:0] pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_data_V_din;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_data_V_full_n;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_data_V_write;
wire   [2:0] pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_keep_V_din;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_keep_V_full_n;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_keep_V_write;
wire   [2:0] pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_strb_V_din;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_strb_V_full_n;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_strb_V_write;
wire   [0:0] pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_user_V_din;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_user_V_full_n;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_user_V_write;
wire   [0:0] pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_last_V_din;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_last_V_full_n;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_last_V_write;
wire   [0:0] pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_id_V_din;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_id_V_full_n;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_id_V_write;
wire   [0:0] pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_dest_V_din;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_dest_V_full_n;
wire    pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_dest_V_write;
wire    ap_sig_hs_continue;
wire    img_rows_V_channel_U_ap_dummy_ce;
wire   [11:0] img_rows_V_channel_din;
wire    img_rows_V_channel_write;
wire   [11:0] img_rows_V_channel_dout;
wire    img_rows_V_channel_empty_n;
wire    img_rows_V_channel_read;
wire    img_rows_V_channel3_U_ap_dummy_ce;
wire   [11:0] img_rows_V_channel3_din;
wire    img_rows_V_channel3_write;
wire   [11:0] img_rows_V_channel3_dout;
wire    img_rows_V_channel3_empty_n;
wire    img_rows_V_channel3_read;
wire    img_cols_V_channel_U_ap_dummy_ce;
wire   [11:0] img_cols_V_channel_din;
wire    img_cols_V_channel_write;
wire   [11:0] img_cols_V_channel_dout;
wire    img_cols_V_channel_empty_n;
wire    img_cols_V_channel_read;
wire    img_cols_V_channel4_U_ap_dummy_ce;
wire   [11:0] img_cols_V_channel4_din;
wire    img_cols_V_channel4_write;
wire   [11:0] img_cols_V_channel4_dout;
wire    img_cols_V_channel4_empty_n;
wire    img_cols_V_channel4_read;
wire    img_data_stream_0_V_U_ap_dummy_ce;
wire   [7:0] img_data_stream_0_V_din;
wire    img_data_stream_0_V_full_n;
wire    img_data_stream_0_V_write;
wire   [7:0] img_data_stream_0_V_dout;
wire    img_data_stream_0_V_empty_n;
wire    img_data_stream_0_V_read;
wire    img_data_stream_1_V_U_ap_dummy_ce;
wire   [7:0] img_data_stream_1_V_din;
wire    img_data_stream_1_V_full_n;
wire    img_data_stream_1_V_write;
wire   [7:0] img_data_stream_1_V_dout;
wire    img_data_stream_1_V_empty_n;
wire    img_data_stream_1_V_read;
wire    img_data_stream_2_V_U_ap_dummy_ce;
wire   [7:0] img_data_stream_2_V_din;
wire    img_data_stream_2_V_full_n;
wire    img_data_stream_2_V_write;
wire   [7:0] img_data_stream_2_V_dout;
wire    img_data_stream_2_V_empty_n;
wire    img_data_stream_2_V_read;
reg    ap_reg_procdone_pixelq_op_Block_proc_U0 = 1'b0;
reg    ap_sig_hs_done;
reg    ap_reg_procdone_pixelq_op_AXIvideo2Mat_U0 = 1'b0;
reg    ap_reg_procdone_pixelq_op_Mat2AXIvideo_U0 = 1'b0;
reg    ap_CS;
wire    ap_sig_top_allready;
pixelq_op_Block_proc pixelq_op_Block_proc_U0(
    .ap_clk( ap_clk ),
    .ap_rst( ap_rst ),
    .ap_start( pixelq_op_Block_proc_U0_ap_start ),
    .ap_done( pixelq_op_Block_proc_U0_ap_done ),
    .ap_continue( pixelq_op_Block_proc_U0_ap_continue ),
    .ap_idle( pixelq_op_Block_proc_U0_ap_idle ),
    .ap_ready( pixelq_op_Block_proc_U0_ap_ready ),
    .ap_return_0( pixelq_op_Block_proc_U0_ap_return_0 ),
    .ap_return_1( pixelq_op_Block_proc_U0_ap_return_1 ),
    .ap_return_2( pixelq_op_Block_proc_U0_ap_return_2 ),
    .ap_return_3( pixelq_op_Block_proc_U0_ap_return_3 )
);
pixelq_op_AXIvideo2Mat pixelq_op_AXIvideo2Mat_U0(
    .ap_clk( ap_clk ),
    .ap_rst( ap_rst ),
    .ap_start( pixelq_op_AXIvideo2Mat_U0_ap_start ),
    .ap_done( pixelq_op_AXIvideo2Mat_U0_ap_done ),
    .ap_continue( pixelq_op_AXIvideo2Mat_U0_ap_continue ),
    .ap_idle( pixelq_op_AXIvideo2Mat_U0_ap_idle ),
    .ap_ready( pixelq_op_AXIvideo2Mat_U0_ap_ready ),
    .AXI_video_strm_V_data_V_dout( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_data_V_dout ),
    .AXI_video_strm_V_data_V_empty_n( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_data_V_empty_n ),
    .AXI_video_strm_V_data_V_read( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_data_V_read ),
    .AXI_video_strm_V_keep_V_dout( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_keep_V_dout ),
    .AXI_video_strm_V_keep_V_empty_n( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_keep_V_empty_n ),
    .AXI_video_strm_V_keep_V_read( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_keep_V_read ),
    .AXI_video_strm_V_strb_V_dout( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_strb_V_dout ),
    .AXI_video_strm_V_strb_V_empty_n( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_strb_V_empty_n ),
    .AXI_video_strm_V_strb_V_read( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_strb_V_read ),
    .AXI_video_strm_V_user_V_dout( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_user_V_dout ),
    .AXI_video_strm_V_user_V_empty_n( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_user_V_empty_n ),
    .AXI_video_strm_V_user_V_read( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_user_V_read ),
    .AXI_video_strm_V_last_V_dout( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_last_V_dout ),
    .AXI_video_strm_V_last_V_empty_n( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_last_V_empty_n ),
    .AXI_video_strm_V_last_V_read( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_last_V_read ),
    .AXI_video_strm_V_id_V_dout( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_id_V_dout ),
    .AXI_video_strm_V_id_V_empty_n( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_id_V_empty_n ),
    .AXI_video_strm_V_id_V_read( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_id_V_read ),
    .AXI_video_strm_V_dest_V_dout( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_dest_V_dout ),
    .AXI_video_strm_V_dest_V_empty_n( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_dest_V_empty_n ),
    .AXI_video_strm_V_dest_V_read( pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_dest_V_read ),
    .img_rows_V_read( pixelq_op_AXIvideo2Mat_U0_img_rows_V_read ),
    .img_cols_V_read( pixelq_op_AXIvideo2Mat_U0_img_cols_V_read ),
    .img_data_stream_0_V_din( pixelq_op_AXIvideo2Mat_U0_img_data_stream_0_V_din ),
    .img_data_stream_0_V_full_n( pixelq_op_AXIvideo2Mat_U0_img_data_stream_0_V_full_n ),
    .img_data_stream_0_V_write( pixelq_op_AXIvideo2Mat_U0_img_data_stream_0_V_write ),
    .img_data_stream_1_V_din( pixelq_op_AXIvideo2Mat_U0_img_data_stream_1_V_din ),
    .img_data_stream_1_V_full_n( pixelq_op_AXIvideo2Mat_U0_img_data_stream_1_V_full_n ),
    .img_data_stream_1_V_write( pixelq_op_AXIvideo2Mat_U0_img_data_stream_1_V_write ),
    .img_data_stream_2_V_din( pixelq_op_AXIvideo2Mat_U0_img_data_stream_2_V_din ),
    .img_data_stream_2_V_full_n( pixelq_op_AXIvideo2Mat_U0_img_data_stream_2_V_full_n ),
    .img_data_stream_2_V_write( pixelq_op_AXIvideo2Mat_U0_img_data_stream_2_V_write )
);
pixelq_op_Mat2AXIvideo pixelq_op_Mat2AXIvideo_U0(
    .ap_clk( ap_clk ),
    .ap_rst( ap_rst ),
    .ap_start( pixelq_op_Mat2AXIvideo_U0_ap_start ),
    .ap_done( pixelq_op_Mat2AXIvideo_U0_ap_done ),
    .ap_continue( pixelq_op_Mat2AXIvideo_U0_ap_continue ),
    .ap_idle( pixelq_op_Mat2AXIvideo_U0_ap_idle ),
    .ap_ready( pixelq_op_Mat2AXIvideo_U0_ap_ready ),
    .img_rows_V_read( pixelq_op_Mat2AXIvideo_U0_img_rows_V_read ),
    .img_cols_V_read( pixelq_op_Mat2AXIvideo_U0_img_cols_V_read ),
    .img_data_stream_0_V_dout( pixelq_op_Mat2AXIvideo_U0_img_data_stream_0_V_dout ),
    .img_data_stream_0_V_empty_n( pixelq_op_Mat2AXIvideo_U0_img_data_stream_0_V_empty_n ),
    .img_data_stream_0_V_read( pixelq_op_Mat2AXIvideo_U0_img_data_stream_0_V_read ),
    .img_data_stream_1_V_dout( pixelq_op_Mat2AXIvideo_U0_img_data_stream_1_V_dout ),
    .img_data_stream_1_V_empty_n( pixelq_op_Mat2AXIvideo_U0_img_data_stream_1_V_empty_n ),
    .img_data_stream_1_V_read( pixelq_op_Mat2AXIvideo_U0_img_data_stream_1_V_read ),
    .img_data_stream_2_V_dout( pixelq_op_Mat2AXIvideo_U0_img_data_stream_2_V_dout ),
    .img_data_stream_2_V_empty_n( pixelq_op_Mat2AXIvideo_U0_img_data_stream_2_V_empty_n ),
    .img_data_stream_2_V_read( pixelq_op_Mat2AXIvideo_U0_img_data_stream_2_V_read ),
    .AXI_video_strm_V_data_V_din( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_data_V_din ),
    .AXI_video_strm_V_data_V_full_n( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_data_V_full_n ),
    .AXI_video_strm_V_data_V_write( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_data_V_write ),
    .AXI_video_strm_V_keep_V_din( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_keep_V_din ),
    .AXI_video_strm_V_keep_V_full_n( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_keep_V_full_n ),
    .AXI_video_strm_V_keep_V_write( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_keep_V_write ),
    .AXI_video_strm_V_strb_V_din( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_strb_V_din ),
    .AXI_video_strm_V_strb_V_full_n( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_strb_V_full_n ),
    .AXI_video_strm_V_strb_V_write( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_strb_V_write ),
    .AXI_video_strm_V_user_V_din( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_user_V_din ),
    .AXI_video_strm_V_user_V_full_n( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_user_V_full_n ),
    .AXI_video_strm_V_user_V_write( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_user_V_write ),
    .AXI_video_strm_V_last_V_din( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_last_V_din ),
    .AXI_video_strm_V_last_V_full_n( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_last_V_full_n ),
    .AXI_video_strm_V_last_V_write( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_last_V_write ),
    .AXI_video_strm_V_id_V_din( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_id_V_din ),
    .AXI_video_strm_V_id_V_full_n( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_id_V_full_n ),
    .AXI_video_strm_V_id_V_write( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_id_V_write ),
    .AXI_video_strm_V_dest_V_din( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_dest_V_din ),
    .AXI_video_strm_V_dest_V_full_n( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_dest_V_full_n ),
    .AXI_video_strm_V_dest_V_write( pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_dest_V_write )
);
FIFO_pixelq_op_img_rows_V_channel img_rows_V_channel_U(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .if_read_ce( img_rows_V_channel_U_ap_dummy_ce ),
    .if_write_ce( img_rows_V_channel_U_ap_dummy_ce ),
    .if_din( img_rows_V_channel_din ),
    .if_full_n( img_rows_V_channel_full_n ),
    .if_write( img_rows_V_channel_write ),
    .if_dout( img_rows_V_channel_dout ),
    .if_empty_n( img_rows_V_channel_empty_n ),
    .if_read( img_rows_V_channel_read )
);
FIFO_pixelq_op_img_rows_V_channel3 img_rows_V_channel3_U(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .if_read_ce( img_rows_V_channel3_U_ap_dummy_ce ),
    .if_write_ce( img_rows_V_channel3_U_ap_dummy_ce ),
    .if_din( img_rows_V_channel3_din ),
    .if_full_n( img_rows_V_channel3_full_n ),
    .if_write( img_rows_V_channel3_write ),
    .if_dout( img_rows_V_channel3_dout ),
    .if_empty_n( img_rows_V_channel3_empty_n ),
    .if_read( img_rows_V_channel3_read )
);
FIFO_pixelq_op_img_cols_V_channel img_cols_V_channel_U(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .if_read_ce( img_cols_V_channel_U_ap_dummy_ce ),
    .if_write_ce( img_cols_V_channel_U_ap_dummy_ce ),
    .if_din( img_cols_V_channel_din ),
    .if_full_n( img_cols_V_channel_full_n ),
    .if_write( img_cols_V_channel_write ),
    .if_dout( img_cols_V_channel_dout ),
    .if_empty_n( img_cols_V_channel_empty_n ),
    .if_read( img_cols_V_channel_read )
);
FIFO_pixelq_op_img_cols_V_channel4 img_cols_V_channel4_U(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .if_read_ce( img_cols_V_channel4_U_ap_dummy_ce ),
    .if_write_ce( img_cols_V_channel4_U_ap_dummy_ce ),
    .if_din( img_cols_V_channel4_din ),
    .if_full_n( img_cols_V_channel4_full_n ),
    .if_write( img_cols_V_channel4_write ),
    .if_dout( img_cols_V_channel4_dout ),
    .if_empty_n( img_cols_V_channel4_empty_n ),
    .if_read( img_cols_V_channel4_read )
);
FIFO_pixelq_op_img_data_stream_0_V img_data_stream_0_V_U(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .if_read_ce( img_data_stream_0_V_U_ap_dummy_ce ),
    .if_write_ce( img_data_stream_0_V_U_ap_dummy_ce ),
    .if_din( img_data_stream_0_V_din ),
    .if_full_n( img_data_stream_0_V_full_n ),
    .if_write( img_data_stream_0_V_write ),
    .if_dout( img_data_stream_0_V_dout ),
    .if_empty_n( img_data_stream_0_V_empty_n ),
    .if_read( img_data_stream_0_V_read )
);
FIFO_pixelq_op_img_data_stream_1_V img_data_stream_1_V_U(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .if_read_ce( img_data_stream_1_V_U_ap_dummy_ce ),
    .if_write_ce( img_data_stream_1_V_U_ap_dummy_ce ),
    .if_din( img_data_stream_1_V_din ),
    .if_full_n( img_data_stream_1_V_full_n ),
    .if_write( img_data_stream_1_V_write ),
    .if_dout( img_data_stream_1_V_dout ),
    .if_empty_n( img_data_stream_1_V_empty_n ),
    .if_read( img_data_stream_1_V_read )
);
FIFO_pixelq_op_img_data_stream_2_V img_data_stream_2_V_U(
    .clk( ap_clk ),
    .reset( ap_rst ),
    .if_read_ce( img_data_stream_2_V_U_ap_dummy_ce ),
    .if_write_ce( img_data_stream_2_V_U_ap_dummy_ce ),
    .if_din( img_data_stream_2_V_din ),
    .if_full_n( img_data_stream_2_V_full_n ),
    .if_write( img_data_stream_2_V_write ),
    .if_dout( img_data_stream_2_V_dout ),
    .if_empty_n( img_data_stream_2_V_empty_n ),
    .if_read( img_data_stream_2_V_read )
);
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_procdone_pixelq_op_AXIvideo2Mat_U0
    if (ap_rst == 1'b1) begin
        ap_reg_procdone_pixelq_op_AXIvideo2Mat_U0 <= ap_const_logic_0;
    end else begin
        if ((ap_const_logic_1 == ap_sig_hs_done)) begin
            ap_reg_procdone_pixelq_op_AXIvideo2Mat_U0 <= ap_const_logic_0;
        end else if ((ap_const_logic_1 == pixelq_op_AXIvideo2Mat_U0_ap_done)) begin
            ap_reg_procdone_pixelq_op_AXIvideo2Mat_U0 <= ap_const_logic_1;
        end
    end
end
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_procdone_pixelq_op_Block_proc_U0
    if (ap_rst == 1'b1) begin
        ap_reg_procdone_pixelq_op_Block_proc_U0 <= ap_const_logic_0;
    end else begin
        if ((ap_const_logic_1 == ap_sig_hs_done)) begin
            ap_reg_procdone_pixelq_op_Block_proc_U0 <= ap_const_logic_0;
        end else if ((pixelq_op_Block_proc_U0_ap_done == ap_const_logic_1)) begin
            ap_reg_procdone_pixelq_op_Block_proc_U0 <= ap_const_logic_1;
        end
    end
end
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_procdone_pixelq_op_Mat2AXIvideo_U0
    if (ap_rst == 1'b1) begin
        ap_reg_procdone_pixelq_op_Mat2AXIvideo_U0 <= ap_const_logic_0;
    end else begin
        if ((ap_const_logic_1 == ap_sig_hs_done)) begin
            ap_reg_procdone_pixelq_op_Mat2AXIvideo_U0 <= ap_const_logic_0;
        end else if ((ap_const_logic_1 == pixelq_op_Mat2AXIvideo_U0_ap_done)) begin
            ap_reg_procdone_pixelq_op_Mat2AXIvideo_U0 <= ap_const_logic_1;
        end
    end
end
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ready_img_cols_V_channel4_full_n
    if (ap_rst == 1'b1) begin
        ap_reg_ready_img_cols_V_channel4_full_n <= ap_const_logic_0;
    end else begin
        if (((pixelq_op_Block_proc_U0_ap_done == ap_const_logic_1) & (pixelq_op_Block_proc_U0_ap_continue == ap_const_logic_1))) begin
            ap_reg_ready_img_cols_V_channel4_full_n <= ap_const_logic_0;
        end else if (((pixelq_op_Block_proc_U0_ap_done == ap_const_logic_1) & (ap_const_logic_1 == img_cols_V_channel4_full_n))) begin
            ap_reg_ready_img_cols_V_channel4_full_n <= ap_const_logic_1;
        end
    end
end
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ready_img_cols_V_channel_full_n
    if (ap_rst == 1'b1) begin
        ap_reg_ready_img_cols_V_channel_full_n <= ap_const_logic_0;
    end else begin
        if (((pixelq_op_Block_proc_U0_ap_done == ap_const_logic_1) & (pixelq_op_Block_proc_U0_ap_continue == ap_const_logic_1))) begin
            ap_reg_ready_img_cols_V_channel_full_n <= ap_const_logic_0;
        end else if (((pixelq_op_Block_proc_U0_ap_done == ap_const_logic_1) & (ap_const_logic_1 == img_cols_V_channel_full_n))) begin
            ap_reg_ready_img_cols_V_channel_full_n <= ap_const_logic_1;
        end
    end
end
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ready_img_rows_V_channel3_full_n
    if (ap_rst == 1'b1) begin
        ap_reg_ready_img_rows_V_channel3_full_n <= ap_const_logic_0;
    end else begin
        if (((pixelq_op_Block_proc_U0_ap_done == ap_const_logic_1) & (pixelq_op_Block_proc_U0_ap_continue == ap_const_logic_1))) begin
            ap_reg_ready_img_rows_V_channel3_full_n <= ap_const_logic_0;
        end else if (((pixelq_op_Block_proc_U0_ap_done == ap_const_logic_1) & (ap_const_logic_1 == img_rows_V_channel3_full_n))) begin
            ap_reg_ready_img_rows_V_channel3_full_n <= ap_const_logic_1;
        end
    end
end
always @ (posedge ap_clk)
begin : ap_ret_ap_reg_ready_img_rows_V_channel_full_n
    if (ap_rst == 1'b1) begin
        ap_reg_ready_img_rows_V_channel_full_n <= ap_const_logic_0;
    end else begin
        if (((pixelq_op_Block_proc_U0_ap_done == ap_const_logic_1) & (pixelq_op_Block_proc_U0_ap_continue == ap_const_logic_1))) begin
            ap_reg_ready_img_rows_V_channel_full_n <= ap_const_logic_0;
        end else if (((pixelq_op_Block_proc_U0_ap_done == ap_const_logic_1) & (ap_const_logic_1 == img_rows_V_channel_full_n))) begin
            ap_reg_ready_img_rows_V_channel_full_n <= ap_const_logic_1;
        end
    end
end
always @ (posedge ap_clk)
begin : ap_ret_pixelq_op_Block_proc_U0_ap_start
    if (ap_rst == 1'b1) begin
        pixelq_op_Block_proc_U0_ap_start <= ap_const_logic_0;
    end else begin
        pixelq_op_Block_proc_U0_ap_start <= ap_const_logic_1;
    end
end
always @(posedge ap_clk)
begin
    ap_CS <= ap_const_logic_0;
end
always @ (pixelq_op_Block_proc_U0_ap_done or ap_reg_ready_img_cols_V_channel_full_n)
begin
    if ((ap_const_logic_1 == ap_reg_ready_img_cols_V_channel_full_n)) begin
        ap_chn_write_pixelq_op_Block_proc_U0_img_cols_V_channel = ap_const_logic_0;
    end else begin
        ap_chn_write_pixelq_op_Block_proc_U0_img_cols_V_channel = pixelq_op_Block_proc_U0_ap_done;
    end
end
always @ (pixelq_op_Block_proc_U0_ap_done or ap_reg_ready_img_cols_V_channel4_full_n)
begin
    if ((ap_const_logic_1 == ap_reg_ready_img_cols_V_channel4_full_n)) begin
        ap_chn_write_pixelq_op_Block_proc_U0_img_cols_V_channel4 = ap_const_logic_0;
    end else begin
        ap_chn_write_pixelq_op_Block_proc_U0_img_cols_V_channel4 = pixelq_op_Block_proc_U0_ap_done;
    end
end
always @ (pixelq_op_Block_proc_U0_ap_done or ap_reg_ready_img_rows_V_channel_full_n)
begin
    if ((ap_const_logic_1 == ap_reg_ready_img_rows_V_channel_full_n)) begin
        ap_chn_write_pixelq_op_Block_proc_U0_img_rows_V_channel = ap_const_logic_0;
    end else begin
        ap_chn_write_pixelq_op_Block_proc_U0_img_rows_V_channel = pixelq_op_Block_proc_U0_ap_done;
    end
end
always @ (pixelq_op_Block_proc_U0_ap_done or ap_reg_ready_img_rows_V_channel3_full_n)
begin
    if ((ap_const_logic_1 == ap_reg_ready_img_rows_V_channel3_full_n)) begin
        ap_chn_write_pixelq_op_Block_proc_U0_img_rows_V_channel3 = ap_const_logic_0;
    end else begin
        ap_chn_write_pixelq_op_Block_proc_U0_img_rows_V_channel3 = pixelq_op_Block_proc_U0_ap_done;
    end
end
always @ (pixelq_op_Block_proc_U0_ap_idle or pixelq_op_AXIvideo2Mat_U0_ap_idle or pixelq_op_Mat2AXIvideo_U0_ap_idle or img_rows_V_channel_empty_n or img_rows_V_channel3_empty_n or img_cols_V_channel_empty_n or img_cols_V_channel4_empty_n)
begin
    if (((pixelq_op_Block_proc_U0_ap_idle == ap_const_logic_1) & (ap_const_logic_1 == pixelq_op_AXIvideo2Mat_U0_ap_idle) & (ap_const_logic_1 == pixelq_op_Mat2AXIvideo_U0_ap_idle) & (ap_const_logic_0 == img_rows_V_channel_empty_n) & (ap_const_logic_0 == img_rows_V_channel3_empty_n) & (ap_const_logic_0 == img_cols_V_channel_empty_n) & (ap_const_logic_0 == img_cols_V_channel4_empty_n))) begin
        ap_idle = ap_const_logic_1;
    end else begin
        ap_idle = ap_const_logic_0;
    end
end
always @ (pixelq_op_Mat2AXIvideo_U0_ap_done)
begin
    if ((ap_const_logic_1 == pixelq_op_Mat2AXIvideo_U0_ap_done)) begin
        ap_sig_hs_done = ap_const_logic_1;
    end else begin
        ap_sig_hs_done = ap_const_logic_0;
    end
end
always @ (img_cols_V_channel4_full_n or ap_reg_ready_img_cols_V_channel4_full_n)
begin
    if ((ap_const_logic_0 == ap_reg_ready_img_cols_V_channel4_full_n)) begin
        ap_sig_ready_img_cols_V_channel4_full_n = img_cols_V_channel4_full_n;
    end else begin
        ap_sig_ready_img_cols_V_channel4_full_n = ap_const_logic_1;
    end
end
always @ (img_cols_V_channel_full_n or ap_reg_ready_img_cols_V_channel_full_n)
begin
    if ((ap_const_logic_0 == ap_reg_ready_img_cols_V_channel_full_n)) begin
        ap_sig_ready_img_cols_V_channel_full_n = img_cols_V_channel_full_n;
    end else begin
        ap_sig_ready_img_cols_V_channel_full_n = ap_const_logic_1;
    end
end
always @ (img_rows_V_channel3_full_n or ap_reg_ready_img_rows_V_channel3_full_n)
begin
    if ((ap_const_logic_0 == ap_reg_ready_img_rows_V_channel3_full_n)) begin
        ap_sig_ready_img_rows_V_channel3_full_n = img_rows_V_channel3_full_n;
    end else begin
        ap_sig_ready_img_rows_V_channel3_full_n = ap_const_logic_1;
    end
end
always @ (img_rows_V_channel_full_n or ap_reg_ready_img_rows_V_channel_full_n)
begin
    if ((ap_const_logic_0 == ap_reg_ready_img_rows_V_channel_full_n)) begin
        ap_sig_ready_img_rows_V_channel_full_n = img_rows_V_channel_full_n;
    end else begin
        ap_sig_ready_img_rows_V_channel_full_n = ap_const_logic_1;
    end
end
always @ (ap_sig_ready_img_cols_V_channel_full_n or ap_sig_ready_img_rows_V_channel3_full_n or ap_sig_ready_img_rows_V_channel_full_n or ap_sig_ready_img_cols_V_channel4_full_n)
begin
    if (((ap_const_logic_1 == ap_sig_ready_img_cols_V_channel_full_n) & (ap_const_logic_1 == ap_sig_ready_img_rows_V_channel3_full_n) & (ap_const_logic_1 == ap_sig_ready_img_rows_V_channel_full_n) & (ap_const_logic_1 == ap_sig_ready_img_cols_V_channel4_full_n))) begin
        pixelq_op_Block_proc_U0_ap_continue = ap_const_logic_1;
    end else begin
        pixelq_op_Block_proc_U0_ap_continue = ap_const_logic_0;
    end
end
assign ap_done = ap_sig_hs_done;
assign ap_ready = ap_sig_top_allready;
assign ap_sig_hs_continue = ap_const_logic_1;
assign ap_sig_top_allready = pixelq_op_AXIvideo2Mat_U0_ap_ready;
assign dst_axi_V_data_V_din = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_data_V_din;
assign dst_axi_V_data_V_write = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_data_V_write;
assign dst_axi_V_dest_V_din = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_dest_V_din;
assign dst_axi_V_dest_V_write = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_dest_V_write;
assign dst_axi_V_id_V_din = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_id_V_din;
assign dst_axi_V_id_V_write = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_id_V_write;
assign dst_axi_V_keep_V_din = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_keep_V_din;
assign dst_axi_V_keep_V_write = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_keep_V_write;
assign dst_axi_V_last_V_din = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_last_V_din;
assign dst_axi_V_last_V_write = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_last_V_write;
assign dst_axi_V_strb_V_din = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_strb_V_din;
assign dst_axi_V_strb_V_write = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_strb_V_write;
assign dst_axi_V_user_V_din = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_user_V_din;
assign dst_axi_V_user_V_write = pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_user_V_write;
assign img_cols_V_channel4_U_ap_dummy_ce = ap_const_logic_1;
assign img_cols_V_channel4_din = pixelq_op_Block_proc_U0_ap_return_3;
assign img_cols_V_channel4_read = pixelq_op_Mat2AXIvideo_U0_ap_ready;
assign img_cols_V_channel4_write = ap_chn_write_pixelq_op_Block_proc_U0_img_cols_V_channel4;
assign img_cols_V_channel_U_ap_dummy_ce = ap_const_logic_1;
assign img_cols_V_channel_din = pixelq_op_Block_proc_U0_ap_return_2;
assign img_cols_V_channel_read = pixelq_op_AXIvideo2Mat_U0_ap_ready;
assign img_cols_V_channel_write = ap_chn_write_pixelq_op_Block_proc_U0_img_cols_V_channel;
assign img_data_stream_0_V_U_ap_dummy_ce = ap_const_logic_1;
assign img_data_stream_0_V_din = pixelq_op_AXIvideo2Mat_U0_img_data_stream_0_V_din;
assign img_data_stream_0_V_read = pixelq_op_Mat2AXIvideo_U0_img_data_stream_0_V_read;
assign img_data_stream_0_V_write = pixelq_op_AXIvideo2Mat_U0_img_data_stream_0_V_write;
assign img_data_stream_1_V_U_ap_dummy_ce = ap_const_logic_1;
assign img_data_stream_1_V_din = pixelq_op_AXIvideo2Mat_U0_img_data_stream_1_V_din;
assign img_data_stream_1_V_read = pixelq_op_Mat2AXIvideo_U0_img_data_stream_1_V_read;
assign img_data_stream_1_V_write = pixelq_op_AXIvideo2Mat_U0_img_data_stream_1_V_write;
assign img_data_stream_2_V_U_ap_dummy_ce = ap_const_logic_1;
assign img_data_stream_2_V_din = pixelq_op_AXIvideo2Mat_U0_img_data_stream_2_V_din;
assign img_data_stream_2_V_read = pixelq_op_Mat2AXIvideo_U0_img_data_stream_2_V_read;
assign img_data_stream_2_V_write = pixelq_op_AXIvideo2Mat_U0_img_data_stream_2_V_write;
assign img_rows_V_channel3_U_ap_dummy_ce = ap_const_logic_1;
assign img_rows_V_channel3_din = pixelq_op_Block_proc_U0_ap_return_1;
assign img_rows_V_channel3_read = pixelq_op_Mat2AXIvideo_U0_ap_ready;
assign img_rows_V_channel3_write = ap_chn_write_pixelq_op_Block_proc_U0_img_rows_V_channel3;
assign img_rows_V_channel_U_ap_dummy_ce = ap_const_logic_1;
assign img_rows_V_channel_din = pixelq_op_Block_proc_U0_ap_return_0;
assign img_rows_V_channel_read = pixelq_op_AXIvideo2Mat_U0_ap_ready;
assign img_rows_V_channel_write = ap_chn_write_pixelq_op_Block_proc_U0_img_rows_V_channel;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_data_V_dout = src_axi_V_data_V_dout;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_data_V_empty_n = src_axi_V_data_V_empty_n;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_dest_V_dout = src_axi_V_dest_V_dout;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_dest_V_empty_n = src_axi_V_dest_V_empty_n;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_id_V_dout = src_axi_V_id_V_dout;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_id_V_empty_n = src_axi_V_id_V_empty_n;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_keep_V_dout = src_axi_V_keep_V_dout;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_keep_V_empty_n = src_axi_V_keep_V_empty_n;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_last_V_dout = src_axi_V_last_V_dout;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_last_V_empty_n = src_axi_V_last_V_empty_n;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_strb_V_dout = src_axi_V_strb_V_dout;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_strb_V_empty_n = src_axi_V_strb_V_empty_n;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_user_V_dout = src_axi_V_user_V_dout;
assign pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_user_V_empty_n = src_axi_V_user_V_empty_n;
assign pixelq_op_AXIvideo2Mat_U0_ap_continue = ap_const_logic_1;
assign pixelq_op_AXIvideo2Mat_U0_ap_start = (img_rows_V_channel_empty_n & ap_start & img_cols_V_channel_empty_n);
assign pixelq_op_AXIvideo2Mat_U0_img_cols_V_read = img_cols_V_channel_dout;
assign pixelq_op_AXIvideo2Mat_U0_img_data_stream_0_V_full_n = img_data_stream_0_V_full_n;
assign pixelq_op_AXIvideo2Mat_U0_img_data_stream_1_V_full_n = img_data_stream_1_V_full_n;
assign pixelq_op_AXIvideo2Mat_U0_img_data_stream_2_V_full_n = img_data_stream_2_V_full_n;
assign pixelq_op_AXIvideo2Mat_U0_img_rows_V_read = img_rows_V_channel_dout;
assign pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_data_V_full_n = dst_axi_V_data_V_full_n;
assign pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_dest_V_full_n = dst_axi_V_dest_V_full_n;
assign pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_id_V_full_n = dst_axi_V_id_V_full_n;
assign pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_keep_V_full_n = dst_axi_V_keep_V_full_n;
assign pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_last_V_full_n = dst_axi_V_last_V_full_n;
assign pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_strb_V_full_n = dst_axi_V_strb_V_full_n;
assign pixelq_op_Mat2AXIvideo_U0_AXI_video_strm_V_user_V_full_n = dst_axi_V_user_V_full_n;
assign pixelq_op_Mat2AXIvideo_U0_ap_continue = ap_sig_hs_continue;
assign pixelq_op_Mat2AXIvideo_U0_ap_start = (img_rows_V_channel3_empty_n & img_cols_V_channel4_empty_n);
assign pixelq_op_Mat2AXIvideo_U0_img_cols_V_read = img_cols_V_channel4_dout;
assign pixelq_op_Mat2AXIvideo_U0_img_data_stream_0_V_dout = img_data_stream_0_V_dout;
assign pixelq_op_Mat2AXIvideo_U0_img_data_stream_0_V_empty_n = img_data_stream_0_V_empty_n;
assign pixelq_op_Mat2AXIvideo_U0_img_data_stream_1_V_dout = img_data_stream_1_V_dout;
assign pixelq_op_Mat2AXIvideo_U0_img_data_stream_1_V_empty_n = img_data_stream_1_V_empty_n;
assign pixelq_op_Mat2AXIvideo_U0_img_data_stream_2_V_dout = img_data_stream_2_V_dout;
assign pixelq_op_Mat2AXIvideo_U0_img_data_stream_2_V_empty_n = img_data_stream_2_V_empty_n;
assign pixelq_op_Mat2AXIvideo_U0_img_rows_V_read = img_rows_V_channel3_dout;
assign src_axi_V_data_V_read = pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_data_V_read;
assign src_axi_V_dest_V_read = pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_dest_V_read;
assign src_axi_V_id_V_read = pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_id_V_read;
assign src_axi_V_keep_V_read = pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_keep_V_read;
assign src_axi_V_last_V_read = pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_last_V_read;
assign src_axi_V_strb_V_read = pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_strb_V_read;
assign src_axi_V_user_V_read = pixelq_op_AXIvideo2Mat_U0_AXI_video_strm_V_user_V_read;
endmodule 
