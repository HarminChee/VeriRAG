module noc_block_exmodrec #(
  parameter NOC_ID = 64'hABCD080D2EC00000,
  parameter STR_SINK_FIFOSIZE = 11)
(
  input bus_clk, input bus_rst,
  input ce_clk, input ce_rst,
  input  [63:0] i_tdata, input  i_tlast, input  i_tvalid, output i_tready,
  output [63:0] o_tdata, output o_tlast, output o_tvalid, input  o_tready,
  output [63:0] debug
);
  wire [31:0] set_data;
  wire [7:0]  set_addr;
  wire        set_stb;
  reg  [63:0] rb_data;
  wire [7:0]  rb_addr;
  wire [63:0] cmdout_tdata, ackin_tdata;
  wire        cmdout_tlast, cmdout_tvalid, cmdout_tready, ackin_tlast, ackin_tvalid, ackin_tready;
  wire [63:0] str_sink_tdata, str_src_tdata;
  wire        str_sink_tlast, str_sink_tvalid, str_sink_tready, str_src_tlast, str_src_tvalid, str_src_tready;
  wire [15:0] src_sid;
  wire [15:0] next_dst_sid, resp_out_dst_sid;
  wire [15:0] resp_in_dst_sid;
  wire        clear_tx_seqnum;
  noc_shell #(
    .NOC_ID(NOC_ID),
    .STR_SINK_FIFOSIZE(STR_SINK_FIFOSIZE))
  noc_shell (
    .bus_clk(bus_clk), .bus_rst(bus_rst),
    .i_tdata(i_tdata), .i_tlast(i_tlast), .i_tvalid(i_tvalid), .i_tready(i_tready),
    .o_tdata(o_tdata), .o_tlast(o_tlast), .o_tvalid(o_tvalid), .o_tready(o_tready),
    .clk(ce_clk), .reset(ce_rst),
    .set_data(set_data), .set_addr(set_addr), .set_stb(set_stb),
    .rb_stb(1'b1), .rb_data(rb_data), .rb_addr(rb_addr),
    .cmdout_tdata(cmdout_tdata), .cmdout_tlast(cmdout_tlast), .cmdout_tvalid(cmdout_tvalid), .cmdout_tready(cmdout_tready),
    .ackin_tdata(ackin_tdata), .ackin_tlast(ackin_tlast), .ackin_tvalid(ackin_tvalid), .ackin_tready(ackin_tready),
    .str_sink_tdata(str_sink_tdata), .str_sink_tlast(str_sink_tlast), .str_sink_tvalid(str_sink_tvalid), .str_sink_tready(str_sink_tready),
    .str_src_tdata(str_src_tdata), .str_src_tlast(str_src_tlast), .str_src_tvalid(str_src_tvalid), .str_src_tready(str_src_tready),
    .src_sid(src_sid),                   
    .next_dst_sid(next_dst_sid),         
    .resp_in_dst_sid(resp_in_dst_sid),   
    .resp_out_dst_sid(resp_out_dst_sid), 
    .vita_time('d0), .clear_tx_seqnum(clear_tx_seqnum),
    .debug(debug));
  wire [31:0] m_axis_data_tdata;
  wire [127:0] m_axis_data_tuser;
  wire        m_axis_data_tlast;
  wire        m_axis_data_tvalid;
  wire        m_axis_data_tready;
  wire [31:0] s_axis_data_tdata;
  wire [127:0] s_axis_data_tuser;
  wire        s_axis_data_tlast;
  wire        s_axis_data_tvalid;
  wire        s_axis_data_tready;
  axi_wrapper #(
    .SIMPLE_MODE(0))
  axi_wrapper (
    .clk(ce_clk), .reset(ce_rst),
    .clear_tx_seqnum(clear_tx_seqnum),
    .next_dst(next_dst_sid),
    .set_stb(set_stb), .set_addr(set_addr), .set_data(set_data),
    .i_tdata(str_sink_tdata), .i_tlast(str_sink_tlast), .i_tvalid(str_sink_tvalid), .i_tready(str_sink_tready),
    .o_tdata(str_src_tdata), .o_tlast(str_src_tlast), .o_tvalid(str_src_tvalid), .o_tready(str_src_tready),
    .m_axis_data_tdata(m_axis_data_tdata),
    .m_axis_data_tlast(m_axis_data_tlast),
    .m_axis_data_tvalid(m_axis_data_tvalid),
    .m_axis_data_tready(m_axis_data_tready),
    .m_axis_data_tuser(m_axis_data_tuser),
    .s_axis_data_tdata(s_axis_data_tdata),
    .s_axis_data_tlast(s_axis_data_tlast),
    .s_axis_data_tvalid(s_axis_data_tvalid),
    .s_axis_data_tready(s_axis_data_tready),
    .s_axis_data_tuser(s_axis_data_tuser),
    .m_axis_config_tdata(),
    .m_axis_config_tlast(),
    .m_axis_config_tvalid(),
    .m_axis_config_tready(),
    .m_axis_pkt_len_tdata(),
    .m_axis_pkt_len_tvalid(),
    .m_axis_pkt_len_tready());
  localparam SR_USER_REG_BASE = 128;
  assign cmdout_tdata  = 64'd0;
  assign cmdout_tlast  = 1'b0;
  assign cmdout_tvalid = 1'b0;
  assign ackin_tready  = 1'b1;
  localparam RB_SIZE_INPUT = 129;
  localparam RB_SIZE_OUTPUT = 130;
  wire [15:0] const_size_in, const_size_out;
  always @(posedge ce_clk) begin
    case(rb_addr)
      RB_SIZE_INPUT  : rb_data <= {48'd0, const_size_in};
      RB_SIZE_OUTPUT : rb_data <= {48'd0, const_size_out};
      default : rb_data <= 64'h0BADC0DE0BADC0DE;
    endcase
  end
  wire [31:0]  in_data_tdata,  out_data_tdata;
  wire         in_data_tlast,  out_data_tlast;
  wire         in_data_tvalid, out_data_tvalid;
  wire         in_data_tready, out_data_tready;
  nnet_vector_wrapper inst_nnet_wrapper (
    .clk(ce_clk), .reset(ce_rst), .clear(clear_tx_seqnum),
    .next_dst_sid(next_dst_sid),
    .pkt_size_in(const_size_in), .pkt_size_out(const_size_out),
    .i_tdata(m_axis_data_tdata),
    .i_tlast(m_axis_data_tlast),
    .i_tvalid(m_axis_data_tvalid),
    .i_tready(m_axis_data_tready),
    .i_tuser(m_axis_data_tuser),
    .o_tdata(s_axis_data_tdata),
    .o_tlast(s_axis_data_tlast),
    .o_tvalid(s_axis_data_tvalid),
    .o_tready(s_axis_data_tready),
    .o_tuser(s_axis_data_tuser),
    .m_axis_data_tdata(in_data_tdata),
    .m_axis_data_tlast(in_data_tlast),
    .m_axis_data_tvalid(in_data_tvalid),
    .m_axis_data_tready(in_data_tready),
    .s_axis_data_tdata(out_data_tdata),
    .s_axis_data_tlast(out_data_tlast),
    .s_axis_data_tvalid(out_data_tvalid),
    .s_axis_data_tready(out_data_tready));
  assign out_data_tdata[31:16] = 0;
  assign out_data_tlast = 1'b0;
  ex_modrec inst_example_modrec (
    .ap_clk(ce_clk), .ap_rst_n(~ce_rst),
    .const_size_in(const_size_in), .const_size_out(const_size_out),
    .data_V_V_TDATA(in_data_tdata), .data_V_V_TVALID(in_data_tvalid), .data_V_V_TREADY(in_data_tready), 
    .res_V_V_TDATA(out_data_tdata), .res_V_V_TVALID(out_data_tvalid), .res_V_V_TREADY(out_data_tready));
endmodule
