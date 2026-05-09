`timescale 1ps/1ps
`timescale 1ps/1ps
module PCIEBus_axi_basic_tx_thrtl_ctl #(
  parameter C_DATA_WIDTH = 128,           
  parameter C_FAMILY     = "X7",          
  parameter C_ROOT_PORT  = "FALSE",       
  parameter TCQ = 1                       
  ) (
  input  [C_DATA_WIDTH-1:0] s_axis_tx_tdata,         
  input                     s_axis_tx_tvalid,        
  input               [3:0] s_axis_tx_tuser,         
  input                     s_axis_tx_tlast,         
  input                     user_turnoff_ok,         
  input                     user_tcfg_gnt,           
  input               [5:0] trn_tbuf_av,             
  input                     trn_tdst_rdy,            
  input                     trn_tcfg_req,            
  output                    trn_tcfg_gnt,            
  input                     trn_lnk_up,              
  input               [2:0] cfg_pcie_link_state,     
  input                     cfg_pm_send_pme_to,      
  input               [1:0] cfg_pmcsr_powerstate,    
  input              [31:0] trn_rdllp_data,          
  input                     trn_rdllp_src_rdy,       
  input                     cfg_to_turnoff,          
  output reg                cfg_turnoff_ok,          
  output reg                tready_thrtl,            
  input                     user_clk,                
  input                     user_rst                 
);
localparam TBUF_AV_MIN = (C_DATA_WIDTH == 128) ? 5 :
                                                   (C_DATA_WIDTH == 64) ? 1 : 0;
localparam TBUF_AV_GAP = TBUF_AV_MIN + 1;
localparam TBUF_GAP_TIME = (C_DATA_WIDTH == 128) ? 4 : 1;
localparam TCFG_LATENCY_TIME = 2'd2;
localparam TCFG_GNT_PIPE_STAGES = 3;
reg        lnk_up_thrtl;
wire       lnk_up_trig;
wire       lnk_up_exit;
reg        tbuf_av_min_thrtl;
wire       tbuf_av_min_trig;
reg        tbuf_av_gap_thrtl;
reg  [2:0] tbuf_gap_cnt;
wire       tbuf_av_gap_trig;
wire       tbuf_av_gap_exit;
wire       gap_trig_tlast;
wire       gap_trig_decr;
reg  [5:0] tbuf_av_d;
reg        tcfg_req_thrtl;
reg  [1:0] tcfg_req_cnt;
reg        trn_tdst_rdy_d;
wire       tcfg_req_trig;
wire       tcfg_req_exit;
reg        tcfg_gnt_log;
wire       pre_throttle;
wire       reg_throttle;
wire       exit_crit;
reg        reg_tcfg_gnt;
reg        trn_tcfg_req_d;
reg        tcfg_gnt_pending;
wire       wire_to_turnoff;
reg        reg_turnoff_ok;
reg        tready_thrtl_mux;
localparam LINKSTATE_L0             = 3'b000;
localparam LINKSTATE_PPM_L1         = 3'b001;
localparam LINKSTATE_PPM_L1_TRANS   = 3'b101;
localparam LINKSTATE_PPM_L23R_TRANS = 3'b110;
localparam PM_ENTER_L1              = 8'h20;
localparam POWERSTATE_D0            = 2'b00;
reg        ppm_L1_thrtl;
wire       ppm_L1_trig;
wire       ppm_L1_exit;
reg  [2:0] cfg_pcie_link_state_d;
reg        trn_rdllp_src_rdy_d;
reg        ppm_L23_thrtl;
wire       ppm_L23_trig;
reg        cfg_turnoff_ok_pending;
reg        reg_tlast;
localparam IDLE       = 0;
localparam THROTTLE   = 1;
reg        cur_state;
reg        next_state;
reg        reg_axi_in_pkt;
wire       axi_in_pkt;
wire       axi_pkt_ending;
wire       axi_throttled;
wire       axi_thrtl_ok;
wire       tx_ecrc_pause;
assign lnk_up_trig = !trn_lnk_up;
assign lnk_up_exit = trn_tdst_rdy;
always @(posedge user_clk) begin
  if(user_rst) begin
    lnk_up_thrtl <= #TCQ 1'b1;
  end
  else begin
    if(lnk_up_trig) begin
      lnk_up_thrtl <= #TCQ 1'b1;
    end
    else if(lnk_up_exit) begin
      lnk_up_thrtl <= #TCQ 1'b0;
    end
  end
end
assign tbuf_av_min_trig = (trn_tbuf_av <= TBUF_AV_MIN);
always @(posedge user_clk) begin
  if(user_rst) begin
    tbuf_av_min_thrtl <= #TCQ 1'b0;
  end
  else begin
    if(tbuf_av_min_trig) begin
      tbuf_av_min_thrtl <= #TCQ 1'b1;
    end
    else begin
      tbuf_av_min_thrtl <= #TCQ 1'b0;
    end
  end
end
assign gap_trig_tlast = (trn_tbuf_av <= TBUF_AV_GAP) &&
                            s_axis_tx_tvalid && tready_thrtl && s_axis_tx_tlast;
assign gap_trig_decr  = (trn_tbuf_av == (TBUF_AV_GAP)) &&
                                                 (tbuf_av_d == (TBUF_AV_GAP+1));
assign gap_trig_tcfg  = (tcfg_req_thrtl && tcfg_req_exit);
assign tbuf_av_gap_trig = gap_trig_tlast || gap_trig_decr || gap_trig_tcfg;
assign tbuf_av_gap_exit = (tbuf_gap_cnt == 0);
always @(posedge user_clk) begin
  if(user_rst) begin
    tbuf_av_gap_thrtl <= #TCQ 1'b0;
    tbuf_gap_cnt      <= #TCQ 3'h0;
    tbuf_av_d         <= #TCQ 6'h00;
  end
  else begin
    if(tbuf_av_gap_trig) begin
      tbuf_av_gap_thrtl <= #TCQ 1'b1;
    end
    else if(tbuf_av_gap_exit) begin
      tbuf_av_gap_thrtl <= #TCQ 1'b0;
    end
    if(tbuf_av_gap_thrtl && (cur_state == THROTTLE)) begin
      if(tbuf_gap_cnt > 0) begin
        tbuf_gap_cnt <= #TCQ tbuf_gap_cnt - 3'd1;
      end
    end
    else begin
      tbuf_gap_cnt <= #TCQ TBUF_GAP_TIME;
    end
    tbuf_av_d <= #TCQ trn_tbuf_av;
  end
end
assign tcfg_req_trig = trn_tcfg_req && reg_tcfg_gnt;
assign tcfg_req_exit = (tcfg_req_cnt == 2'd0) && !trn_tdst_rdy_d &&
                                                                   trn_tdst_rdy;
always @(posedge user_clk) begin
  if(user_rst) begin
    tcfg_req_thrtl   <= #TCQ 1'b0;
    trn_tcfg_req_d   <= #TCQ 1'b0;
    trn_tdst_rdy_d   <= #TCQ 1'b1;
    reg_tcfg_gnt     <= #TCQ 1'b0;
    tcfg_req_cnt     <= #TCQ 2'd0;
    tcfg_gnt_pending <= #TCQ 1'b0;
  end
  else begin
    if(tcfg_req_trig) begin
      tcfg_req_thrtl <= #TCQ 1'b1;
    end
    else if(tcfg_req_exit) begin
      tcfg_req_thrtl <= #TCQ 1'b0;
    end
    if((trn_tcfg_req && !trn_tcfg_req_d) || tcfg_gnt_pending) begin
      tcfg_req_cnt <= #TCQ TCFG_LATENCY_TIME;
    end
    else begin
      if(tcfg_req_cnt > 0) begin
        tcfg_req_cnt <= #TCQ tcfg_req_cnt - 2'd1;
      end
    end
    if(trn_tcfg_req && !trn_tcfg_req_d) begin
      tcfg_gnt_pending <= #TCQ 1'b1;
    end
    else if(tcfg_gnt_log) begin
      tcfg_gnt_pending <= #TCQ 1'b0;
    end
    trn_tcfg_req_d <= #TCQ trn_tcfg_req;
    trn_tdst_rdy_d <= #TCQ trn_tdst_rdy;
    reg_tcfg_gnt   <= #TCQ user_tcfg_gnt;
  end
end
generate
  if((C_FAMILY == "X7") && (C_ROOT_PORT == "TRUE")) begin : x7_L1_thrtl_rp
    assign ppm_L1_trig = (cfg_pcie_link_state_d == LINKSTATE_L0) &&
                           (cfg_pcie_link_state == LINKSTATE_PPM_L1_TRANS);
    assign ppm_L1_exit = cfg_pcie_link_state == LINKSTATE_PPM_L1;
  end
  else if((C_FAMILY == "X7") && (C_ROOT_PORT == "FALSE")) begin : x7_L1_thrtl_ep
    assign ppm_L1_trig = (cfg_pcie_link_state_d == LINKSTATE_L0) &&
                           (cfg_pcie_link_state == LINKSTATE_PPM_L1_TRANS);
    assign ppm_L1_exit = cfg_pcie_link_state == LINKSTATE_L0;
  end
  else if((C_FAMILY == "V6") && (C_ROOT_PORT == "TRUE")) begin : v6_L1_thrtl_rp
    assign ppm_L1_trig = (trn_rdllp_data[31:24] == PM_ENTER_L1) &&
                                      trn_rdllp_src_rdy && !trn_rdllp_src_rdy_d;
    assign ppm_L1_exit = cfg_pcie_link_state == LINKSTATE_PPM_L1;
  end
  else if((C_FAMILY == "V6") && (C_ROOT_PORT == "FALSE")) begin : v6_L1_thrtl_ep
    assign ppm_L1_trig = (cfg_pmcsr_powerstate != POWERSTATE_D0);
    assign ppm_L1_exit = cfg_pcie_link_state == LINKSTATE_L0;
  end
  else begin : s6_L1_thrtl
    assign ppm_L1_trig = 1'b0;
    assign ppm_L1_exit = 1'b1;
  end
endgenerate
always @(posedge user_clk) begin
  if(user_rst) begin
    ppm_L1_thrtl          <= #TCQ 1'b0;
    cfg_pcie_link_state_d <= #TCQ 3'b0;
    trn_rdllp_src_rdy_d   <= #TCQ 1'b0;
  end
  else begin
    if(ppm_L1_trig) begin
      ppm_L1_thrtl <= #TCQ 1'b1;
    end
    else if(ppm_L1_exit) begin
      ppm_L1_thrtl <= #TCQ 1'b0;
    end
    cfg_pcie_link_state_d <= #TCQ cfg_pcie_link_state;
    trn_rdllp_src_rdy_d   <= #TCQ trn_rdllp_src_rdy;
  end
end
generate
  if((C_FAMILY == "X7") && (C_ROOT_PORT == "TRUE")) begin : x7_L23_thrtl_rp
    assign ppm_L23_trig = (cfg_pcie_link_state_d == LINKSTATE_PPM_L23R_TRANS);
    assign wire_to_turnoff = 1'b0;
  end
  else if((C_FAMILY == "V6") && (C_ROOT_PORT == "TRUE")) begin : v6_L23_thrtl_rp
    assign ppm_L23_trig = cfg_pm_send_pme_to;
    assign wire_to_turnoff = 1'b0;
  end
  else begin : L23_thrtl_ep
    assign ppm_L23_trig = wire_to_turnoff && reg_turnoff_ok;
    if(C_FAMILY == "X7") begin : x7_L23_thrtl_ep
      reg reg_to_turnoff;
      always @(posedge user_clk) begin
        if(user_rst) begin
          reg_to_turnoff <= #TCQ 1'b0;
        end
        else begin
          if(cfg_to_turnoff) begin
            reg_to_turnoff <= #TCQ 1'b1;
          end
        end
      end
      assign wire_to_turnoff = reg_to_turnoff;
    end
    else begin : v6_s6_L23_thrtl_ep
      assign wire_to_turnoff = cfg_to_turnoff;
    end
    always @(posedge user_clk) begin
      if(user_rst) begin
        reg_turnoff_ok <= #TCQ 1'b0;
      end
      else begin
        reg_turnoff_ok <= #TCQ user_turnoff_ok;
      end
    end
  end
endgenerate
always @(posedge user_clk) begin
  if(user_rst) begin
    ppm_L23_thrtl   <= #TCQ 1'b0;
    cfg_turnoff_ok_pending <= #TCQ 1'b0;
  end
  else begin
    if(ppm_L23_trig) begin
      ppm_L23_thrtl <= #TCQ 1'b1;
    end
    if(ppm_L23_trig && !ppm_L23_thrtl) begin
      cfg_turnoff_ok_pending <= #TCQ 1'b1;
    end
    else if(cfg_turnoff_ok) begin
      cfg_turnoff_ok_pending <= #TCQ 1'b0;
    end
  end
end
always @(posedge user_clk) begin
  if(user_rst) begin
    reg_axi_in_pkt <= #TCQ 1'b0;
  end
  else begin
    if(s_axis_tx_tvalid && s_axis_tx_tlast) begin
      reg_axi_in_pkt <= #TCQ 1'b0;
    end
    else if(tready_thrtl && s_axis_tx_tvalid) begin
      reg_axi_in_pkt <= #TCQ 1'b1;
    end
  end
end
assign axi_in_pkt     = s_axis_tx_tvalid || reg_axi_in_pkt;
assign axi_pkt_ending = s_axis_tx_tvalid && s_axis_tx_tlast;
assign axi_throttled  = !tready_thrtl;
assign axi_thrtl_ok   = !axi_in_pkt || axi_pkt_ending || axi_throttled;
assign pre_throttle = tbuf_av_min_trig || tbuf_av_gap_trig || lnk_up_trig
                                || tcfg_req_trig || ppm_L1_trig || ppm_L23_trig;
assign reg_throttle = tbuf_av_min_thrtl || tbuf_av_gap_thrtl || lnk_up_thrtl
                             || tcfg_req_thrtl || ppm_L1_thrtl || ppm_L23_thrtl;
assign exit_crit = !tbuf_av_min_thrtl && !tbuf_av_gap_thrtl && !lnk_up_thrtl
                          && !tcfg_req_thrtl && !ppm_L1_thrtl && !ppm_L23_thrtl;
always @(*) begin
  case(cur_state)
    IDLE: begin
      if(reg_throttle && axi_thrtl_ok) begin
        tready_thrtl_mux = 1'b0;
        next_state       = THROTTLE;
        if(tcfg_req_thrtl) begin
          tcfg_gnt_log   = 1'b1;   
          cfg_turnoff_ok = 1'b0;   
        end
        else if(ppm_L23_thrtl) begin
          tcfg_gnt_log   = 1'b0;   
          cfg_turnoff_ok = 1'b1;   
        end
        else begin
          tcfg_gnt_log   = 1'b0;   
          cfg_turnoff_ok = 1'b0;   
        end
      end
      else begin
        tready_thrtl_mux = !(axi_thrtl_ok && pre_throttle);
        next_state       = IDLE;
        tcfg_gnt_log     = 1'b0;
        cfg_turnoff_ok   = 1'b0;
      end
    end
    THROTTLE: begin
      if(exit_crit) begin
        tready_thrtl_mux = !pre_throttle;
        next_state       = IDLE;
      end
      else begin
        tready_thrtl_mux = 1'b0;
        next_state       = THROTTLE;
      end
      if(tcfg_req_thrtl && tcfg_gnt_pending) begin
        tcfg_gnt_log   = 1'b1;   
        cfg_turnoff_ok = 1'b0;   
      end
      else if(cfg_turnoff_ok_pending) begin
        tcfg_gnt_log   = 1'b0;   
        cfg_turnoff_ok = 1'b1;   
      end
      else begin
        tcfg_gnt_log   = 1'b0;   
        cfg_turnoff_ok = 1'b0;   
      end
    end
    default: begin
      tready_thrtl_mux = 1'b0;
      next_state       = IDLE;
      tcfg_gnt_log     = 1'b0;
      cfg_turnoff_ok   = 1'b0;
    end
  endcase
end
always @(posedge user_clk) begin
  if(user_rst) begin
    cur_state        <= #TCQ THROTTLE;
    reg_tlast        <= #TCQ 1'b0;
    tready_thrtl     <= #TCQ 1'b0;
  end
  else begin
    cur_state        <= #TCQ next_state;
    tready_thrtl     <= #TCQ tready_thrtl_mux && !tx_ecrc_pause;
    reg_tlast        <= #TCQ s_axis_tx_tlast;
  end
end
generate
  if(C_FAMILY == "X7") begin : ecrc_pause_enabled
    wire        tx_ecrc_pkt;
    reg         reg_tx_ecrc_pkt;
    wire  [1:0] packet_fmt;
    wire        packet_td;
    wire  [2:0] header_len;
    wire  [9:0] payload_len;
    wire [13:0] packet_len;
    wire        pause_needed;
    assign packet_fmt  = s_axis_tx_tdata[30:29];
    assign packet_td   = s_axis_tx_tdata[15];
    assign header_len  = packet_fmt[0] ? 3'd4 : 3'd3;
    assign payload_len = packet_fmt[1] ? s_axis_tx_tdata[9:0] : 10'h0;
    assign packet_len  = {10'h000, header_len} + {4'h0, payload_len};
    if(C_DATA_WIDTH == 128) begin : packet_len_check_128
      assign pause_needed = (packet_len[1:0] == 2'b00) && !packet_td;
    end
    else begin : packet_len_check_64
      assign pause_needed = (packet_len[0] == 1'b0) && !packet_td;
    end
    assign tx_ecrc_pkt = s_axis_tx_tuser[0] && pause_needed &&
                            tready_thrtl && s_axis_tx_tvalid && !reg_axi_in_pkt;
    always @(posedge user_clk) begin
      if(user_rst) begin
        reg_tx_ecrc_pkt <= #TCQ 1'b0;
      end
      else begin
        if(tx_ecrc_pkt && !s_axis_tx_tlast) begin
          reg_tx_ecrc_pkt <= #TCQ 1'b1;
        end
        else if(tready_thrtl && s_axis_tx_tvalid && s_axis_tx_tlast) begin
          reg_tx_ecrc_pkt <= #TCQ 1'b0;
        end
      end
    end
    assign tx_ecrc_pause = ((tx_ecrc_pkt || reg_tx_ecrc_pkt) &&
                           s_axis_tx_tlast && s_axis_tx_tvalid && tready_thrtl);
  end
  else begin : ecrc_pause_disabled
    assign tx_ecrc_pause = 1'b0;
  end
endgenerate
generate
  if(C_DATA_WIDTH == 128 && C_FAMILY == "V6") begin : tcfg_gnt_pipeline
    genvar stage;
    reg tcfg_gnt_pipe [TCFG_GNT_PIPE_STAGES:0];
    for(stage = 0; stage < TCFG_GNT_PIPE_STAGES; stage = stage + 1)
    begin : tcfg_gnt_pipeline_stage
      always @(posedge user_clk) begin
        if(user_rst) begin
          tcfg_gnt_pipe[stage] <= #TCQ 1'b0;
        end
        else begin
          if(stage == 0) begin
            tcfg_gnt_pipe[stage] <= #TCQ tcfg_gnt_log;
          end
          else begin
            tcfg_gnt_pipe[stage] <= #TCQ tcfg_gnt_pipe[stage - 1];
          end
        end
      end
      assign trn_tcfg_gnt = tcfg_gnt_pipe[TCFG_GNT_PIPE_STAGES-1];
    end
  end
  else begin : tcfg_gnt_no_pipeline
    assign trn_tcfg_gnt = tcfg_gnt_log;
  end
endgenerate
endmodule
