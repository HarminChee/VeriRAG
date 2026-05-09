`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module mig_7series_v1_9_bank_common #
  (
   parameter TCQ = 100,
   parameter BM_CNT_WIDTH             = 2,
   parameter LOW_IDLE_CNT             = 1,
   parameter nBANK_MACHS              = 4,
   parameter nCK_PER_CLK              = 2,
   parameter nOP_WAIT                 = 0,
   parameter nRFC                     = 44,
   parameter nXSDLL                   = 512,
   parameter RANK_WIDTH               = 2,
   parameter RANKS                    = 4,
   parameter CWL                      = 5,
   parameter tZQCS                    = 64
  )
  (
  accept_internal_r, accept_ns, accept, periodic_rd_insert,
  periodic_rd_ack_r, accept_req, rb_hit_busy_cnt, idle, idle_cnt, order_cnt,
  adv_order_q, bank_mach_next, op_exit_grant, low_idle_cnt_r, was_wr,
  was_priority, maint_wip_r, maint_idle, insert_maint_r,
  clk, rst, idle_ns, init_calib_complete, periodic_rd_r, use_addr,
  rb_hit_busy_r, idle_r, ordered_r, ordered_issued, head_r, end_rtp,
  passing_open_bank, op_exit_req, start_pre_wait, cmd, hi_priority, maint_req_r,
  maint_zq_r, maint_sre_r, maint_srx_r, maint_hit, bm_end,
  slot_0_present, slot_1_present
  );
  function integer clogb2 (input integer size); 
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
            size = size >> 1;
    end
  endfunction 
  localparam ZERO = 0;
  localparam ONE = 1;
  localparam [BM_CNT_WIDTH-1:0] BM_CNT_ZERO = ZERO[0+:BM_CNT_WIDTH];
  localparam [BM_CNT_WIDTH-1:0] BM_CNT_ONE = ONE[0+:BM_CNT_WIDTH];
  input clk;
  input rst;
  input [nBANK_MACHS-1:0] idle_ns;
  input init_calib_complete;
  wire accept_internal_ns = init_calib_complete && |idle_ns;
  output reg accept_internal_r;
  always @(posedge clk) accept_internal_r <= accept_internal_ns;
  wire periodic_rd_ack_ns;
  wire accept_ns_lcl = accept_internal_ns && ~periodic_rd_ack_ns;
  output wire accept_ns;
  assign accept_ns = accept_ns_lcl;
  reg accept_r;
  always @(posedge clk) accept_r <= #TCQ accept_ns_lcl;
  output wire accept;
  assign accept = accept_r;
`ifdef MC_SVA
  property none_idle;
    @(posedge clk) (init_calib_complete && ~|idle_r);
  endproperty
  all_bank_machines_busy: cover property (none_idle);
`endif
  input periodic_rd_r;
  reg periodic_rd_ack_r_lcl;
  reg periodic_rd_cntr_r ;
  always @(posedge clk) begin
    if (rst) periodic_rd_cntr_r <= #TCQ 1'b0;
    else if (periodic_rd_r && periodic_rd_ack_r_lcl)
       periodic_rd_cntr_r <= #TCQ ~periodic_rd_cntr_r;
  end
  wire internal_periodic_rd_ack_r_lcl = (periodic_rd_cntr_r && periodic_rd_ack_r_lcl);
  wire periodic_rd_insert_lcl = periodic_rd_r && ~internal_periodic_rd_ack_r_lcl;
  output wire periodic_rd_insert;
  assign periodic_rd_insert = periodic_rd_insert_lcl;
  assign periodic_rd_ack_ns = periodic_rd_insert_lcl && accept_internal_ns;
  always @(posedge clk) periodic_rd_ack_r_lcl <= #TCQ periodic_rd_ack_ns;
  output wire periodic_rd_ack_r;
  assign periodic_rd_ack_r = periodic_rd_ack_r_lcl;
  input use_addr;
  wire accept_req_lcl = periodic_rd_ack_r_lcl || (accept_r && use_addr);
  output wire accept_req;
  assign accept_req = accept_req_lcl;
  input [nBANK_MACHS-1:0] rb_hit_busy_r;
  output reg [BM_CNT_WIDTH-1:0] rb_hit_busy_cnt;
  integer i;
  always @(rb_hit_busy_r) begin
    rb_hit_busy_cnt = BM_CNT_ZERO;
    for (i = 0; i < nBANK_MACHS; i = i + 1)
      if (rb_hit_busy_r[i]) rb_hit_busy_cnt = rb_hit_busy_cnt + BM_CNT_ONE;
  end
  input [nBANK_MACHS-1:0] idle_r;
  output reg [BM_CNT_WIDTH-1:0] idle_cnt;
  always @(idle_r) begin
    idle_cnt = BM_CNT_ZERO;
    for (i = 0; i < nBANK_MACHS; i = i + 1)
      if (idle_r[i]) idle_cnt = idle_cnt + BM_CNT_ONE;
  end
  output idle;
  assign idle = init_calib_complete && &idle_r;
  input [nBANK_MACHS-1:0] ordered_r;
  output reg [BM_CNT_WIDTH-1:0] order_cnt;
  always @(ordered_r) begin
    order_cnt = BM_CNT_ZERO;
    for (i = 0; i < nBANK_MACHS; i = i + 1)
      if (ordered_r[i]) order_cnt = order_cnt + BM_CNT_ONE;
  end
  input [nBANK_MACHS-1:0] ordered_issued;
  output wire adv_order_q;
  assign adv_order_q = |ordered_issued;
  input [nBANK_MACHS-1:0] head_r;
  wire [nBANK_MACHS-1:0] next = idle_r & head_r;
  output reg[BM_CNT_WIDTH-1:0] bank_mach_next;
  always @(next) begin
     bank_mach_next = BM_CNT_ZERO;
    for (i = 0; i <= nBANK_MACHS-1; i = i + 1)
      if (next[i]) bank_mach_next = i[BM_CNT_WIDTH-1:0];
  end
  input [nBANK_MACHS-1:0] end_rtp;
  input [nBANK_MACHS-1:0] passing_open_bank;
  input [nBANK_MACHS-1:0] op_exit_req;
  output wire [nBANK_MACHS-1:0] op_exit_grant;
  output reg low_idle_cnt_r = 1'b0;
  input [nBANK_MACHS-1:0] start_pre_wait;
  generate
    if (nOP_WAIT == 0) begin : op_mode_disabled
      assign op_exit_grant = {nBANK_MACHS{1'b0}};
    end
    else begin : op_mode_enabled
      reg [BM_CNT_WIDTH:0] idle_cnt_r;
      reg [BM_CNT_WIDTH:0] idle_cnt_ns;
      always @(accept_req_lcl or idle_cnt_r or passing_open_bank
               or rst or start_pre_wait)
        if (rst) idle_cnt_ns = nBANK_MACHS;
        else begin
          idle_cnt_ns = idle_cnt_r - accept_req_lcl;
          for (i = 0; i <= nBANK_MACHS-1; i = i + 1) begin
            idle_cnt_ns = idle_cnt_ns + passing_open_bank[i];
          end
          idle_cnt_ns = idle_cnt_ns + |start_pre_wait;
        end
      always @(posedge clk) idle_cnt_r <= #TCQ idle_cnt_ns;
      wire low_idle_cnt_ns = (idle_cnt_ns <= LOW_IDLE_CNT[0+:BM_CNT_WIDTH]);
      always @(posedge clk) low_idle_cnt_r <= #TCQ low_idle_cnt_ns;
  wire upd_last_master = |end_rtp;  
  mig_7series_v1_9_round_robin_arb #
    (.WIDTH                             (nBANK_MACHS))
    op_arb0
    (.grant_ns                          (op_exit_grant[nBANK_MACHS-1:0]),
     .grant_r                           (),
     .upd_last_master                   (upd_last_master),
     .current_master                    (end_rtp[nBANK_MACHS-1:0]),
     .clk                               (clk),
     .rst                               (rst),
     .req                               (op_exit_req[nBANK_MACHS-1:0]),
     .disable_grant                     (1'b0));
    end
  endgenerate
  input [2:0] cmd;
  output reg was_wr;
  always @(posedge clk) was_wr <= #TCQ
             cmd[0] && ~(periodic_rd_r && ~periodic_rd_ack_r_lcl);
  input hi_priority;
  output reg was_priority;
  always @(posedge clk) begin
     if (hi_priority)
        was_priority <= #TCQ 1'b1;
     else
        was_priority <= #TCQ 1'b0;
  end
  input maint_req_r;
  reg maint_wip_r_lcl;
  output wire maint_wip_r;
  assign maint_wip_r = maint_wip_r_lcl;
  wire maint_idle_lcl;
  output wire maint_idle;
  assign maint_idle = maint_idle_lcl;
  input maint_zq_r;
  input maint_sre_r;
  input maint_srx_r;
  input [nBANK_MACHS-1:0] maint_hit;
  input [nBANK_MACHS-1:0] bm_end;
  wire start_maint;
  wire maint_end;
  generate begin : maint_controller
      assign maint_idle_lcl = ~(maint_req_r || maint_wip_r_lcl);
      wire maint_wip_ns =
            ~rst && ~maint_end && (maint_wip_r_lcl || maint_req_r);
      always @(posedge clk) maint_wip_r_lcl <= #TCQ maint_wip_ns;
      wire [nBANK_MACHS-1:0] clear_vector = {nBANK_MACHS{rst}} | bm_end;
      wire [nBANK_MACHS-1:0] maint_zq_hits = {nBANK_MACHS{maint_idle_lcl}} &
                            (maint_hit | {nBANK_MACHS{maint_zq_r}}) & ~idle_ns;
      wire [nBANK_MACHS-1:0] maint_sre_hits = {nBANK_MACHS{maint_idle_lcl}} &
                            (maint_hit | {nBANK_MACHS{maint_sre_r}}) & ~idle_ns;
      reg [nBANK_MACHS-1:0] maint_hit_busies_r;
      wire [nBANK_MACHS-1:0] maint_hit_busies_ns =
                       ~clear_vector & (maint_hit_busies_r | maint_zq_hits | maint_sre_hits);
      always @(posedge clk) maint_hit_busies_r <= #TCQ maint_hit_busies_ns;
      wire maint_clear = ~maint_idle_lcl && ~|maint_hit_busies_ns;
    wire maint_rdy = maint_clear;
    reg maint_rdy_r1;
    reg maint_srx_r1;
    always @(posedge clk) maint_rdy_r1 <= #TCQ maint_rdy;
    always @(posedge clk) maint_srx_r1 <= #TCQ maint_srx_r;
    assign start_maint = maint_rdy && ~maint_rdy_r1 || maint_srx_r && ~maint_srx_r1;
    end 
  endgenerate
  input [7:0] slot_0_present;
  input [7:0] slot_1_present;
  reg insert_maint_r_lcl;
  output wire insert_maint_r;
  assign insert_maint_r = insert_maint_r_lcl;
  generate begin : generate_maint_cmds
      reg [RANK_WIDTH:0] present_count;
      wire [7:0] present = slot_0_present | slot_1_present;
      always @(present) begin
        present_count = {RANK_WIDTH{1'b0}};
        for (i=0; i<8; i=i+1)
          present_count = present_count + {{RANK_WIDTH{1'b0}}, present[i]};
      end
      reg [RANK_WIDTH:0] send_cnt_ns;
      reg [RANK_WIDTH:0] send_cnt_r;
      always @(maint_zq_r or maint_sre_r or maint_srx_r or present_count
          or rst or send_cnt_r or start_maint)
        if (rst) send_cnt_ns = 4'b0;
        else begin
          send_cnt_ns = send_cnt_r;
          if (start_maint && (maint_zq_r || maint_sre_r || maint_srx_r)) send_cnt_ns = present_count;
          if (|send_cnt_ns)
            send_cnt_ns = send_cnt_ns - ONE[RANK_WIDTH-1:0];
        end
      always @(posedge clk) send_cnt_r <= #TCQ send_cnt_ns;
      wire insert_maint_ns = start_maint || |send_cnt_r;
      always @(posedge clk) insert_maint_r_lcl <= #TCQ insert_maint_ns;
    end 
  endgenerate
  localparam nRFC_CLKS =  (nCK_PER_CLK == 1) ?
                            nRFC :
                          (nCK_PER_CLK == 2) ?
                            ((nRFC/2) + (nRFC%2)) :
                            ((nRFC/4) + ((nRFC%4) ? 1 : 0));
  localparam nZQCS_CLKS = (nCK_PER_CLK == 1) ?
                            tZQCS :
                          (nCK_PER_CLK == 2) ?
                            ((tZQCS/2) + (tZQCS%2)) :
                            ((tZQCS/4) + ((tZQCS%4) ? 1 : 0));
  localparam nXSDLL_CLKS =  (nCK_PER_CLK == 1) ?
                              nXSDLL :
                            (nCK_PER_CLK == 2) ?
                              ((nXSDLL/2) + (nXSDLL%2)) :
                              ((nXSDLL/4) + ((nXSDLL%4) ? 1 : 0));
  localparam RFC_ZQ_TIMER_WIDTH = clogb2(nXSDLL_CLKS + 1);
  localparam THREE = 3;
  generate begin : rfc_zq_xsdll_timer
      reg [RFC_ZQ_TIMER_WIDTH-1:0] rfc_zq_xsdll_timer_ns;
      reg [RFC_ZQ_TIMER_WIDTH-1:0] rfc_zq_xsdll_timer_r;
      always @(insert_maint_r_lcl or maint_zq_r or maint_sre_r or maint_srx_r
               or rfc_zq_xsdll_timer_r or rst) begin
        rfc_zq_xsdll_timer_ns = rfc_zq_xsdll_timer_r;
        if (rst) rfc_zq_xsdll_timer_ns = {RFC_ZQ_TIMER_WIDTH{1'b0}};
        else if (insert_maint_r_lcl) rfc_zq_xsdll_timer_ns =  maint_zq_r ?
                                                                nZQCS_CLKS :
                                                              maint_sre_r ?
                                                                {RFC_ZQ_TIMER_WIDTH{1'b0}} :
                                                              maint_srx_r ?
                                                                nXSDLL_CLKS :
                                                                nRFC_CLKS;
        else if (|rfc_zq_xsdll_timer_r) rfc_zq_xsdll_timer_ns =
                                  rfc_zq_xsdll_timer_r - ONE[RFC_ZQ_TIMER_WIDTH-1:0];
      end
      always @(posedge clk) rfc_zq_xsdll_timer_r <= #TCQ rfc_zq_xsdll_timer_ns;
      assign maint_end = (rfc_zq_xsdll_timer_r == THREE[RFC_ZQ_TIMER_WIDTH-1:0]);
    end 
  endgenerate
endmodule 
