`timescale 1ps/1ps
`define BM_SHARED_BV (ID+nBANK_MACHS-1):(ID+1)
`timescale 1ps/1ps
`define BM_SHARED_BV (ID+nBANK_MACHS-1):(ID+1)
module mig_7series_v1_9_bank_state #
  (
   parameter TCQ = 100,
   parameter ADDR_CMD_MODE            = "1T",
   parameter BM_CNT_WIDTH             = 2,
   parameter BURST_MODE               = "8",
   parameter CWL                      = 5,
   parameter DATA_BUF_ADDR_WIDTH      = 8,
   parameter DRAM_TYPE                = "DDR3",
   parameter ECC                      = "OFF",
   parameter ID                       = 0,
   parameter nBANK_MACHS              = 4,
   parameter nCK_PER_CLK              = 2,
   parameter nOP_WAIT                 = 0,
   parameter nRAS_CLKS                = 10,
   parameter nRP                      = 10,
   parameter nRTP                     = 4,
   parameter nRCD                     = 5,
   parameter nWTP_CLKS                = 5,
   parameter ORDERING                 = "NORM",
   parameter RANKS                    = 4,
   parameter RANK_WIDTH               = 4,
   parameter RAS_TIMER_WIDTH          = 5,
   parameter STARVE_LIMIT             = 2
  )
  (
  start_rcd, act_wait_r, rd_half_rmw, ras_timer_ns, end_rtp,
  bank_wait_in_progress, start_pre_wait, op_exit_req, pre_wait_r,
  allow_auto_pre, precharge_bm_end, demand_act_priority, rts_row,
  act_this_rank_r, demand_priority, col_rdy_wr, rts_col, wr_this_rank_r,
  rd_this_rank_r, rts_pre, rtc,
  clk, rst, bm_end, pass_open_bank_r, sending_row, sending_pre, rcv_open_bank,
  sending_col, rd_wr_r, req_wr_r, rd_data_addr, req_data_buf_addr_r,
  phy_rddata_valid, rd_rmw, ras_timer_ns_in, rb_hit_busies_r, idle_r,
  passing_open_bank, low_idle_cnt_r, op_exit_grant, tail_r,
  auto_pre_r, pass_open_bank_ns, req_rank_r, req_rank_r_in,
  start_rcd_in, inhbt_act_faw_r, wait_for_maint_r, head_r, sent_row,
  demand_act_priority_in, order_q_zero, sent_col, q_has_rd,
  q_has_priority, req_priority_r, idle_ns, demand_priority_in, inhbt_rd,
  inhbt_wr, dq_busy_data, rnk_config_strobe, rnk_config_valid_r, rnk_config,
  rnk_config_kill_rts_col, phy_mc_cmd_full, phy_mc_ctl_full, phy_mc_data_full
  );
  function integer clogb2 (input integer size); 
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
            size = size >> 1;
    end
  endfunction 
  input clk;
  input rst;
  input bm_end;
  reg bm_end_r1;
  always @(posedge clk) bm_end_r1 <= #TCQ bm_end;
  reg col_wait_r;
  input pass_open_bank_r;
  input sending_row;
  reg act_wait_r_lcl;
  input rcv_open_bank;
  wire start_rcd_lcl = act_wait_r_lcl && sending_row;
  output wire start_rcd;
  assign start_rcd = start_rcd_lcl;
  wire act_wait_ns = rst ||
                     ((act_wait_r_lcl && ~start_rcd_lcl && ~rcv_open_bank) ||
                      bm_end_r1 || (pass_open_bank_r && bm_end));
  always @(posedge clk) act_wait_r_lcl <= #TCQ act_wait_ns;
  output wire act_wait_r;
  assign act_wait_r = act_wait_r_lcl;
  localparam nRCD_CLKS =
    nCK_PER_CLK == 1 ?
      nRCD :
    nCK_PER_CLK == 2 ?
      ADDR_CMD_MODE == "2T" ?
        (nRCD/2) + (nRCD%2) :
          CWL % 2 ?
            (nRCD/2) :
            (nRCD+2) / 2 :
      ADDR_CMD_MODE == "2T" ? 
        (nRCD/4) + (nRCD%4 > 2 ? 1 : 0) :
        CWL % 2 ?
          (nRCD-2 ? (nRCD-2) / 4 + 1 : 1) :
          nRCD/4 + 1;
  localparam nRCD_CLKS_M2 = (nRCD_CLKS-2 <0) ? 0 : nRCD_CLKS-2;
  localparam RCD_TIMER_WIDTH = clogb2(nRCD_CLKS_M2+1);
  localparam ZERO = 0;
  localparam ONE = 1;
  reg [RCD_TIMER_WIDTH-1:0] rcd_timer_r = {RCD_TIMER_WIDTH{1'b0}};
  reg end_rcd;
  reg rcd_active_r = 1'b0;
  generate
    if (nRCD_CLKS <= 2) begin : rcd_timer_leq_2
      always @(start_rcd_lcl) end_rcd = start_rcd_lcl;
    end
    else if (nRCD_CLKS > 2) begin : rcd_timer_gt_2
      reg [RCD_TIMER_WIDTH-1:0] rcd_timer_ns;
      always @(rcd_timer_r or rst or start_rcd_lcl) begin
        if (rst) rcd_timer_ns = ZERO[RCD_TIMER_WIDTH-1:0];
        else begin
          rcd_timer_ns = rcd_timer_r;
          if (start_rcd_lcl) rcd_timer_ns = nRCD_CLKS_M2[RCD_TIMER_WIDTH-1:0];
          else if (|rcd_timer_r) rcd_timer_ns =
                                   rcd_timer_r - ONE[RCD_TIMER_WIDTH-1:0];
        end
      end
      always @(posedge clk) rcd_timer_r <= #TCQ rcd_timer_ns;
      wire end_rcd_ns = (rcd_timer_ns == ONE[RCD_TIMER_WIDTH-1:0]);
      always @(posedge clk) end_rcd = end_rcd_ns;
      wire rcd_active_ns = |rcd_timer_ns;
      always @(posedge clk) rcd_active_r <= #TCQ rcd_active_ns;
    end
  endgenerate
  input sending_col;
  input rd_wr_r;
  input req_wr_r;
  input [DATA_BUF_ADDR_WIDTH-1:0] rd_data_addr;
  input [DATA_BUF_ADDR_WIDTH-1:0] req_data_buf_addr_r;
  input phy_rddata_valid;
  input rd_rmw;
  reg rmw_rd_done = 1'b0;
  reg rd_half_rmw_lcl = 1'b0;
  output wire rd_half_rmw;
  assign rd_half_rmw = rd_half_rmw_lcl;
  reg rmw_wait_r = 1'b0;
  generate
    if (ECC != "OFF") begin : rmw_on
      reg phy_rddata_valid_r;
      reg rd_rmw_r;
      always @(posedge clk) begin
        phy_rddata_valid_r <= #TCQ phy_rddata_valid;
        rd_rmw_r <= #TCQ rd_rmw;
      end   
      wire my_rmw_rd_ns = phy_rddata_valid_r && rd_rmw_r && 
                            (rd_data_addr == req_data_buf_addr_r); 
      if (CWL == 8) always @(my_rmw_rd_ns) rmw_rd_done = my_rmw_rd_ns;
      else always @(posedge clk) rmw_rd_done = #TCQ my_rmw_rd_ns;
      always @(rd_wr_r or req_wr_r) rd_half_rmw_lcl = req_wr_r && rd_wr_r;
      wire rmw_wait_ns = ~rst && 
             ((rmw_wait_r && ~rmw_rd_done) || (rd_half_rmw_lcl && sending_col));
      always @(posedge clk) rmw_wait_r <= #TCQ rmw_wait_ns;
    end
  endgenerate
  wire col_wait_ns = ~rst && ((col_wait_r && ~sending_col) || end_rcd
                            || rcv_open_bank || (rmw_rd_done && rmw_wait_r));
  always @(posedge clk) col_wait_r <= #TCQ col_wait_ns;
  localparam TWO = 2;
  output reg [RAS_TIMER_WIDTH-1:0] ras_timer_ns;
  reg [RAS_TIMER_WIDTH-1:0] ras_timer_r;
  input [(2*(RAS_TIMER_WIDTH*nBANK_MACHS))-1:0] ras_timer_ns_in;
  input [(nBANK_MACHS*2)-1:0] rb_hit_busies_r;
  reg [RAS_TIMER_WIDTH-1:0] passed_ras_timer;
  integer i;
  always @(ras_timer_ns_in or rb_hit_busies_r) begin
    passed_ras_timer = {RAS_TIMER_WIDTH{1'b0}};
    for (i=ID+1; i<(ID+nBANK_MACHS); i=i+1)
      if (rb_hit_busies_r[i])
        passed_ras_timer = ras_timer_ns_in[i*RAS_TIMER_WIDTH+:RAS_TIMER_WIDTH];
  end
  wire start_wtp_timer = sending_col && ~rd_wr_r;
  input idle_r;
  always @(bm_end_r1 or ras_timer_r or rst or start_rcd_lcl
           or start_wtp_timer) begin
    if (bm_end_r1 || rst) ras_timer_ns = ZERO[RAS_TIMER_WIDTH-1:0];
    else begin
      ras_timer_ns = ras_timer_r;
      if (start_rcd_lcl) ras_timer_ns =
           nRAS_CLKS[RAS_TIMER_WIDTH-1:0] - TWO[RAS_TIMER_WIDTH-1:0];
      if (start_wtp_timer) ras_timer_ns =
           (ras_timer_r <= (nWTP_CLKS-2)) ? nWTP_CLKS[RAS_TIMER_WIDTH-1:0] - TWO[RAS_TIMER_WIDTH-1:0]
                                          : ras_timer_r - ONE[RAS_TIMER_WIDTH-1:0];
      if (|ras_timer_r && ~start_wtp_timer) ras_timer_ns =
           ras_timer_r - ONE[RAS_TIMER_WIDTH-1:0];
    end
  end 
  wire [RAS_TIMER_WIDTH-1:0] ras_timer_passed_ns = rcv_open_bank
                                                     ? passed_ras_timer
                                                     : ras_timer_ns;
  always @(posedge clk) ras_timer_r <= #TCQ ras_timer_passed_ns;
  wire ras_timer_zero_ns = (ras_timer_ns == ZERO[RAS_TIMER_WIDTH-1:0]);
  reg ras_timer_zero_r;
  always @(posedge clk) ras_timer_zero_r <= #TCQ ras_timer_zero_ns;
  localparam nRTP_CLKS = (nCK_PER_CLK == 1)
                            ? nRTP :
                         (nCK_PER_CLK == 2)
                            ? (nRTP/2) + ((ADDR_CMD_MODE == "2T") ? nRTP%2 : 1) :
                              (nRTP/4) + ((ADDR_CMD_MODE == "2T") ? (nRTP%4 > 2 ? 2 : 1) : 2);
  localparam nRTP_CLKS_M1 = ((nRTP_CLKS-1) <= 0) ? 0 : nRTP_CLKS-1;
  localparam RTP_TIMER_WIDTH = clogb2(nRTP_CLKS_M1 + 1);
  reg [RTP_TIMER_WIDTH-1:0] rtp_timer_ns;
  reg [RTP_TIMER_WIDTH-1:0] rtp_timer_r;
  wire sending_col_not_rmw_rd = sending_col && ~rd_half_rmw_lcl;
  always @(pass_open_bank_r or rst or rtp_timer_r
           or sending_col_not_rmw_rd) begin
    rtp_timer_ns = rtp_timer_r;
    if (rst || pass_open_bank_r)
      rtp_timer_ns = ZERO[RTP_TIMER_WIDTH-1:0];
    else begin
      if (sending_col_not_rmw_rd) 
         rtp_timer_ns = nRTP_CLKS_M1[RTP_TIMER_WIDTH-1:0];
      if (|rtp_timer_r) rtp_timer_ns = rtp_timer_r - ONE[RTP_TIMER_WIDTH-1:0];
    end
  end
  always @(posedge clk) rtp_timer_r <= #TCQ rtp_timer_ns;
  wire end_rtp_lcl =   ~pass_open_bank_r &&
                       ((rtp_timer_r == ONE[RTP_TIMER_WIDTH-1:0]) ||
                       ((nRTP_CLKS_M1 == 0) && sending_col_not_rmw_rd));
  output wire end_rtp;
  assign end_rtp = end_rtp_lcl;
  localparam OP_WIDTH = clogb2(nOP_WAIT + 1);
  output wire bank_wait_in_progress;
  output wire start_pre_wait;
  input passing_open_bank;
  input low_idle_cnt_r;
  output wire op_exit_req;
  input op_exit_grant;
  input tail_r;
  output reg pre_wait_r;
  generate
    if (nOP_WAIT == 0) begin : op_mode_disabled
      assign bank_wait_in_progress = sending_col_not_rmw_rd || |rtp_timer_r ||
                                     (pre_wait_r && ~ras_timer_zero_r);
      assign start_pre_wait = end_rtp_lcl;
      assign op_exit_req = 1'b0;
    end
    else begin : op_mode_enabled
      reg op_wait_r;
      assign bank_wait_in_progress = sending_col || |rtp_timer_r ||
                                     (pre_wait_r && ~ras_timer_zero_r) ||
                                     op_wait_r;
      wire op_active = ~rst && ~passing_open_bank && ((end_rtp_lcl && tail_r)
                                || op_wait_r);
      wire op_wait_ns = ~op_exit_grant && op_active;
      always @(posedge clk) op_wait_r <= #TCQ op_wait_ns;
      assign start_pre_wait = op_exit_grant ||
                              (end_rtp_lcl && ~tail_r && ~passing_open_bank);
      if (nOP_WAIT == -1)
        assign op_exit_req = (low_idle_cnt_r && op_active);
      else begin : op_cnt
        reg [OP_WIDTH-1:0] op_cnt_r;
        wire [OP_WIDTH-1:0] op_cnt_ns =
                                   (passing_open_bank || op_exit_grant || rst)
                                       ? ZERO[OP_WIDTH-1:0]
                                       : end_rtp_lcl
                                         ? nOP_WAIT[OP_WIDTH-1:0]
                                         : |op_cnt_r
                                            ? op_cnt_r - ONE[OP_WIDTH-1:0]
                                            : op_cnt_r;
        always @(posedge clk) op_cnt_r <= #TCQ op_cnt_ns;
        assign op_exit_req = (low_idle_cnt_r && op_active) ||
                             (op_wait_r && ~|op_cnt_r);
      end
    end
  endgenerate
  output allow_auto_pre;
  wire allow_auto_pre = act_wait_r_lcl || rcd_active_r ||
                        (col_wait_r && ~sending_col);
  input auto_pre_r;
  wire start_pre;
  input pass_open_bank_ns;
  wire pre_wait_ns = ~rst && (~pass_open_bank_ns &&
                     (start_pre_wait || (pre_wait_r && ~start_pre)));
  always @(posedge clk) pre_wait_r <= #TCQ pre_wait_ns;
  wire pre_request = pre_wait_r && ras_timer_zero_r && ~auto_pre_r;
  localparam nRP_CLKS = (nCK_PER_CLK == 1) ? nRP : 
                        (nCK_PER_CLK == 2) ? ((nRP/2) + (nRP%2)) : 
                       ((nRP/4) + ((nRP%4) ? 1 : 0));
  localparam nRP_CLKS_M2 = (nRP_CLKS-2 < 0) ? 0 : nRP_CLKS-2;
  localparam RP_TIMER_WIDTH = clogb2(nRP_CLKS_M2 + 1);
  input sending_pre;
  output rts_pre;
  generate
    if((nCK_PER_CLK == 4) && (ADDR_CMD_MODE != "2T")) begin
      assign start_pre =  pre_wait_r && ras_timer_zero_r &&
                          (sending_pre || auto_pre_r);
      assign rts_pre = ~sending_pre && pre_request;
    end
    else begin
      assign start_pre =  pre_wait_r && ras_timer_zero_r &&
                          (sending_row || auto_pre_r);
      assign rts_pre = 1'b0;
    end
  endgenerate
  reg [RP_TIMER_WIDTH-1:0] rp_timer_r = ZERO[RP_TIMER_WIDTH-1:0];
  generate
    if (nRP_CLKS_M2 > ZERO) begin : rp_timer
      reg [RP_TIMER_WIDTH-1:0] rp_timer_ns;
      always @(rp_timer_r or rst or start_pre)
        if (rst) rp_timer_ns = ZERO[RP_TIMER_WIDTH-1:0];
        else begin
          rp_timer_ns = rp_timer_r;
          if (start_pre) rp_timer_ns = nRP_CLKS_M2[RP_TIMER_WIDTH-1:0];
          else if (|rp_timer_r) rp_timer_ns =
                                  rp_timer_r - ONE[RP_TIMER_WIDTH-1:0];
        end
      always @(posedge clk) rp_timer_r <= #TCQ rp_timer_ns;
    end 
  endgenerate
  output wire precharge_bm_end;
  assign precharge_bm_end = (rp_timer_r == ONE[RP_TIMER_WIDTH-1:0]) ||
                            (start_pre && (nRP_CLKS_M2 == ZERO));
  input [RANK_WIDTH-1:0] req_rank_r;
  input [(RANK_WIDTH*nBANK_MACHS*2)-1:0] req_rank_r_in;
  reg inhbt_act_rrd;
  input [(nBANK_MACHS*2)-1:0] start_rcd_in;
  generate
    integer j;
    if (RANKS == 1)
      always @(req_rank_r or req_rank_r_in or start_rcd_in) begin
        inhbt_act_rrd = 1'b0;
        for (j=(ID+1); j<(ID+nBANK_MACHS); j=j+1)
          inhbt_act_rrd = inhbt_act_rrd || start_rcd_in[j];
      end
    else begin
      always @(req_rank_r or req_rank_r_in or start_rcd_in) begin
        inhbt_act_rrd = 1'b0;
        for (j=(ID+1); j<(ID+nBANK_MACHS); j=j+1)
          inhbt_act_rrd = inhbt_act_rrd ||
             (start_rcd_in[j] &&
              (req_rank_r_in[(j*RANK_WIDTH)+:RANK_WIDTH] == req_rank_r));
      end
    end
  endgenerate
  input [RANKS-1:0] inhbt_act_faw_r;
  wire my_inhbt_act_faw = inhbt_act_faw_r[req_rank_r];
  input wait_for_maint_r;
  input head_r;
  wire act_req = ~idle_r && head_r && act_wait_r && ras_timer_zero_r &&
                 ~wait_for_maint_r;
  input sent_row;
  wire rts_act_denied = act_req && sent_row && ~sending_row;
  reg [BM_CNT_WIDTH-1:0] act_starve_limit_cntr_ns;
  reg [BM_CNT_WIDTH-1:0] act_starve_limit_cntr_r;
  generate
    if (BM_CNT_WIDTH > 1) 
    begin :BM_MORE_THAN_2 
       always @(act_req or act_starve_limit_cntr_r or rts_act_denied)
         begin
           act_starve_limit_cntr_ns = act_starve_limit_cntr_r;
           if (~act_req)
             act_starve_limit_cntr_ns = {BM_CNT_WIDTH{1'b0}};
           else
             if (rts_act_denied && &act_starve_limit_cntr_r)
               act_starve_limit_cntr_ns = act_starve_limit_cntr_r +
                                          {{BM_CNT_WIDTH-1{1'b0}}, 1'b1};
         end
    end 
    else 
    begin :BM_EQUAL_2 
       always @(act_req or act_starve_limit_cntr_r or rts_act_denied)
         begin
           act_starve_limit_cntr_ns = act_starve_limit_cntr_r;
           if (~act_req)
             act_starve_limit_cntr_ns = {BM_CNT_WIDTH{1'b0}};
           else
             if (rts_act_denied && &act_starve_limit_cntr_r)
               act_starve_limit_cntr_ns = act_starve_limit_cntr_r +
                                          {1'b1};
         end
    end 
  endgenerate
  always @(posedge clk) act_starve_limit_cntr_r <=
                        #TCQ act_starve_limit_cntr_ns;
  reg demand_act_priority_r;
  wire demand_act_priority_ns = act_req &&
      (demand_act_priority_r || (rts_act_denied && &act_starve_limit_cntr_r));
  always @(posedge clk) demand_act_priority_r <= #TCQ demand_act_priority_ns;
`ifdef MC_SVA
  cover_demand_act_priority:
    cover property (@(posedge clk) (~rst && demand_act_priority_r));
`endif
  output wire demand_act_priority;
  assign demand_act_priority = demand_act_priority_r && ~sending_row;
  input [(nBANK_MACHS*2)-1:0] demand_act_priority_in;
  reg act_demanded = 1'b0;
  generate
    if (nBANK_MACHS > 1) begin : compute_act_demanded
      always @(demand_act_priority_in[`BM_SHARED_BV])
           act_demanded = |demand_act_priority_in[`BM_SHARED_BV];
    end
  endgenerate
  wire row_demand_ok = demand_act_priority_r || ~act_demanded;
  output wire rts_row;
  generate
    if((nCK_PER_CLK == 4) && (ADDR_CMD_MODE != "2T"))
      assign rts_row = ~sending_row && row_demand_ok &&
                      (act_req && ~my_inhbt_act_faw && ~inhbt_act_rrd);
    else
      assign rts_row = ~sending_row && row_demand_ok &&
                      ((act_req && ~my_inhbt_act_faw && ~inhbt_act_rrd) ||
                        pre_request);
  endgenerate
`ifdef MC_SVA
  four_activate_window_wait:
    cover property (@(posedge clk)
      (~rst && ~sending_row && act_req &&  my_inhbt_act_faw));
  ras_ras_delay_wait:
    cover property (@(posedge clk)
      (~rst && ~sending_row && act_req && inhbt_act_rrd));
`endif
  output reg [RANKS-1:0] act_this_rank_r;
  reg [RANKS-1:0] act_this_rank_ns;
  always @(act_wait_r or req_rank_r) begin
    act_this_rank_ns = {RANKS{1'b0}};
    for (i = 0; i < RANKS; i = i + 1)
      act_this_rank_ns[i] = act_wait_r && (i[RANK_WIDTH-1:0] == req_rank_r);
  end
  always @(posedge clk) act_this_rank_r <= #TCQ act_this_rank_ns;
  input order_q_zero;
  wire req_bank_rdy_ns = order_q_zero && col_wait_r;
  reg req_bank_rdy_r;
  always @(posedge clk) req_bank_rdy_r <= #TCQ req_bank_rdy_ns;
  input sent_col;
  wire rts_col_denied = req_bank_rdy_r && sent_col && ~sending_col;
  localparam STARVE_LIMIT_CNT      = STARVE_LIMIT * nBANK_MACHS;
  localparam STARVE_LIMIT_WIDTH    = clogb2(STARVE_LIMIT_CNT);
  reg [STARVE_LIMIT_WIDTH-1:0] starve_limit_cntr_r;
  reg [STARVE_LIMIT_WIDTH-1:0] starve_limit_cntr_ns;
  always @(col_wait_r or rts_col_denied or starve_limit_cntr_r)
   if (~col_wait_r)
     starve_limit_cntr_ns = {STARVE_LIMIT_WIDTH{1'b0}};
   else
     if (rts_col_denied && (starve_limit_cntr_r != STARVE_LIMIT_CNT-1))
       starve_limit_cntr_ns = starve_limit_cntr_r +
                              {{STARVE_LIMIT_WIDTH-1{1'b0}}, 1'b1};
     else starve_limit_cntr_ns = starve_limit_cntr_r;
  always @(posedge clk) starve_limit_cntr_r <= #TCQ starve_limit_cntr_ns;
  input q_has_rd;
  input q_has_priority;
  wire starved = ((starve_limit_cntr_r == (STARVE_LIMIT_CNT-1)) &&
                 rts_col_denied);
  input req_priority_r;
  input idle_ns;
  reg demand_priority_r;
  wire demand_priority_ns = ~idle_ns && col_wait_ns &&
                              (demand_priority_r ||
                              (order_q_zero &&
                               (req_priority_r || q_has_priority)) ||
                               (starved && (q_has_rd || ~req_wr_r)));
  always @(posedge clk) demand_priority_r <= #TCQ demand_priority_ns;
`ifdef MC_SVA
  wire rdy_for_priority = ~rst && ~demand_priority_r && ~idle_ns &&
                          col_wait_ns;
  req_triggers_demand_priority:
    cover property (@(posedge clk)
       (rdy_for_priority && req_priority_r && ~q_has_priority && ~starved));
  q_priority_triggers_demand_priority:
    cover property (@(posedge clk)
       (rdy_for_priority && ~req_priority_r && q_has_priority && ~starved));
  wire not_req_or_q_rdy_for_priority =
        rdy_for_priority && ~req_priority_r && ~q_has_priority;
  starved_req_triggers_demand_priority:
    cover property (@(posedge clk)
       (not_req_or_q_rdy_for_priority && starved && ~q_has_rd && ~req_wr_r));
  starved_q_triggers_demand_priority:
    cover property (@(posedge clk)
       (not_req_or_q_rdy_for_priority && starved && q_has_rd && req_wr_r));
`endif
  input [(nBANK_MACHS*2)-1:0] demand_priority_in;
  reg demanded = 1'b0;
  generate
    if (nBANK_MACHS > 1) begin : compute_demanded
      always @(demand_priority_in[`BM_SHARED_BV]) demanded =
                                    |demand_priority_in[`BM_SHARED_BV];
    end
  endgenerate
  reg demanded_prior_r;
  wire demanded_prior_ns = demanded &&
                          (demanded_prior_r || ~demand_priority_r);
  always @(posedge clk) demanded_prior_r <= #TCQ demanded_prior_ns;
  output wire demand_priority;
  assign demand_priority = demand_priority_r && ~demanded_prior_r &&
                           ~sending_col;
`ifdef MC_SVA
  demand_priority_gated:
    cover property (@(posedge clk) (demand_priority_r && ~demand_priority));
  generate
    if (nBANK_MACHS >1) multiple_demand_priority:
         cover property (@(posedge clk)
           ($countones(demand_priority_in[`BM_SHARED_BV]) > 1));
  endgenerate
`endif
  wire demand_ok = demand_priority_r || ~demanded;
  input rnk_config_strobe;
  input rnk_config_kill_rts_col;
  input rnk_config_valid_r;
  input [RANK_WIDTH-1:0] rnk_config;
  output wire rtc;
  wire rnk_config_match = rnk_config_valid_r && (rnk_config == req_rank_r);
  assign rtc = ~rnk_config_match && ~rnk_config_kill_rts_col && order_q_zero && col_wait_r && demand_ok;
  input [RANKS-1:0] inhbt_rd;
  wire my_inhbt_rd = inhbt_rd[req_rank_r];
  input [RANKS-1:0] inhbt_wr;
  wire my_inhbt_wr = inhbt_wr[req_rank_r];
  wire allow_rw = ~rd_wr_r ? ~my_inhbt_wr : ~my_inhbt_rd;
  input dq_busy_data;
  wire col_rdy = (col_wait_r || ((nRCD_CLKS <= 1) && end_rcd) ||
               (rcv_open_bank && nCK_PER_CLK == 2 && DRAM_TYPE=="DDR2" && BURST_MODE == "4") || 
               (rcv_open_bank && nCK_PER_CLK == 4 && BURST_MODE == "8")) &&
                order_q_zero;
  output wire col_rdy_wr;
  assign col_rdy_wr = col_rdy && ~rd_wr_r;
  wire col_cmd_rts = col_rdy && ~dq_busy_data && allow_rw && rnk_config_match;
`ifdef MC_SVA
  col_wait_for_order_q: cover property
    (@(posedge clk)
        (~rst && col_wait_r && ~order_q_zero && ~dq_busy_data &&
         allow_rw));
  col_wait_for_dq_busy: cover property
    (@(posedge clk)
        (~rst && col_wait_r && order_q_zero && dq_busy_data &&
         allow_rw));
  col_wait_for_allow_rw: cover property
    (@(posedge clk)
        (~rst && col_wait_r && order_q_zero && ~dq_busy_data &&
         ~allow_rw));
`endif
  input phy_mc_ctl_full;
  input phy_mc_cmd_full;
  input phy_mc_data_full;
  reg phy_mc_ctl_full_r = 1'b0;
  reg phy_mc_cmd_full_r = 1'b0;
  always @(posedge clk)
    if(rst) begin
      phy_mc_ctl_full_r <= #TCQ 1'b0;
      phy_mc_cmd_full_r <= #TCQ 1'b0;
    end else begin
      phy_mc_ctl_full_r <= #TCQ phy_mc_ctl_full;
      phy_mc_cmd_full_r <= #TCQ phy_mc_cmd_full;
    end
  reg ofs_rdy_r = 1'b0;
  always @(posedge clk)
    if(rst)
      ofs_rdy_r <= #TCQ 1'b0;
    else
      ofs_rdy_r <= #TCQ ~phy_mc_cmd_full_r && ~phy_mc_ctl_full_r && ~(phy_mc_data_full && ~rd_wr_r);
  reg override_demand_r;
  wire override_demand_ns = rnk_config_strobe || rnk_config_kill_rts_col;
  always @(posedge clk) override_demand_r <= override_demand_ns;
  output wire rts_col;
  assign rts_col = ~sending_col && (demand_ok || override_demand_r) &&
                   col_cmd_rts && ofs_rdy_r;
  reg [RANKS-1:0] wr_this_rank_ns;
  reg [RANKS-1:0] rd_this_rank_ns;
  always @(rd_wr_r or req_rank_r) begin
    wr_this_rank_ns = {RANKS{1'b0}};
    rd_this_rank_ns = {RANKS{1'b0}};
    for (i=0; i<RANKS; i=i+1) begin
      wr_this_rank_ns[i] = ~rd_wr_r && (i[RANK_WIDTH-1:0] == req_rank_r);
      rd_this_rank_ns[i] = rd_wr_r && (i[RANK_WIDTH-1:0] == req_rank_r);
    end
  end
  output reg [RANKS-1:0] wr_this_rank_r;
  always @(posedge clk) wr_this_rank_r <= #TCQ wr_this_rank_ns;
  output reg [RANKS-1:0] rd_this_rank_r;
  always @(posedge clk) rd_this_rank_r <= #TCQ rd_this_rank_ns;
endmodule 
