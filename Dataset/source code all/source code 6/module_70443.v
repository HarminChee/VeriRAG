`timescale 1ps/1ps
`define BM_SHARED_BV (ID+nBANK_MACHS-1):(ID+1)
`timescale 1ps/1ps
`define BM_SHARED_BV (ID+nBANK_MACHS-1):(ID+1)
module mig_7series_v1_8_bank_queue #
  (
   parameter TCQ = 100,
   parameter BM_CNT_WIDTH             = 2,
   parameter nBANK_MACHS              = 4,
   parameter ORDERING                 = "NORM",
   parameter ID                       = 0
  )
  (
  head_r, tail_r, idle_ns, idle_r, pass_open_bank_ns,
  pass_open_bank_r, auto_pre_r, bm_end, passing_open_bank,
  ordered_issued, ordered_r, order_q_zero, rcv_open_bank,
  rb_hit_busies_r, q_has_rd, q_has_priority, wait_for_maint_r,
  clk, rst, accept_internal_r, use_addr, periodic_rd_ack_r, bm_end_in,
  idle_cnt, rb_hit_busy_cnt, accept_req, rb_hit_busy_r, maint_idle,
  maint_hit, row_hit_r, pre_wait_r, allow_auto_pre, sending_col,
  bank_wait_in_progress, precharge_bm_end, req_wr_r, rd_wr_r,
  adv_order_q, order_cnt, rb_hit_busy_ns_in, passing_open_bank_in,
  was_wr, maint_req_r, was_priority
  );
  localparam ZERO = 0;
  localparam ONE = 1;
  localparam [BM_CNT_WIDTH-1:0] BM_CNT_ZERO = ZERO[0+:BM_CNT_WIDTH];
  localparam [BM_CNT_WIDTH-1:0] BM_CNT_ONE = ONE[0+:BM_CNT_WIDTH];
  input clk;
  input rst;
  reg idle_r_lcl;
  reg head_r_lcl;
  input accept_internal_r;
  wire bm_ready = idle_r_lcl && head_r_lcl && accept_internal_r;
  input use_addr;
  input periodic_rd_ack_r;
  wire accept_this_bm = bm_ready && (use_addr || periodic_rd_ack_r);
  input [(nBANK_MACHS*2)-1:0] bm_end_in;
  reg [BM_CNT_WIDTH-1:0] idlers_below;
  integer i;
  always @(bm_end_in) begin
    idlers_below = BM_CNT_ZERO;
    for (i=0; i<ID; i=i+1)
      idlers_below = idlers_below + bm_end_in[i];
   end
  reg idlers_above;
  always @(bm_end_in) begin
    idlers_above = 1'b0;
    for (i=ID+1; i<ID+nBANK_MACHS; i=i+1)
      idlers_above = idlers_above || bm_end_in[i];
  end
`ifdef MC_SVA
  bm_end_and_idlers_above: cover property (@(posedge clk)
         (~rst && bm_end && idlers_above));
  bm_end_and_idlers_below: cover property (@(posedge clk)
         (~rst && bm_end && |idlers_below));
`endif
  input [BM_CNT_WIDTH-1:0] idle_cnt;
  input [BM_CNT_WIDTH-1:0] rb_hit_busy_cnt;
  input accept_req;
  wire bm_end_lcl;
  reg adv_queue = 1'b0;
  reg [BM_CNT_WIDTH-1:0] q_entry_r;
  reg [BM_CNT_WIDTH-1:0] q_entry_ns;
  wire [BM_CNT_WIDTH-1:0] temp;
assign temp = idle_cnt + idlers_below;
always @ (*)
begin
  if (accept_req & bm_end_lcl)
    q_entry_ns  = temp - BM_CNT_ONE;
  else if (bm_end_lcl)
    q_entry_ns = temp;
  else if (accept_this_bm) 
    q_entry_ns = adv_queue ? (rb_hit_busy_cnt - BM_CNT_ONE) :  (rb_hit_busy_cnt -BM_CNT_ZERO);
  else if ((!idle_r_lcl & adv_queue) |
          (idle_r_lcl & accept_req & !accept_this_bm))
    q_entry_ns = q_entry_r - BM_CNT_ONE;
  else
  q_entry_ns = q_entry_r;
end
  always @(posedge clk)
  if (rst)
    q_entry_r <= #TCQ ID[BM_CNT_WIDTH-1:0];
  else
    q_entry_r <= #TCQ q_entry_ns;
  reg head_ns;
  always @(accept_req or accept_this_bm or adv_queue
           or bm_end_lcl or head_r_lcl or idle_cnt or idle_r_lcl
           or idlers_below or q_entry_r or rb_hit_busy_cnt or rst) begin
    if (rst) head_ns = ~|ID[BM_CNT_WIDTH-1:0];
    else begin
      head_ns = head_r_lcl;
      if (accept_this_bm)
        head_ns = ~|(rb_hit_busy_cnt - (adv_queue ? BM_CNT_ONE : BM_CNT_ZERO));
      if ((~idle_r_lcl && adv_queue) ||
           (idle_r_lcl && accept_req && ~accept_this_bm))
        head_ns = ~|(q_entry_r - BM_CNT_ONE);
      if (bm_end_lcl) begin
        head_ns = ~|(idle_cnt - (accept_req ? BM_CNT_ONE : BM_CNT_ZERO)) &&
                   ~|idlers_below;
      end
    end
  end
  always @(posedge clk) head_r_lcl <= #TCQ head_ns;
  output wire head_r;
  assign head_r = head_r_lcl;
  input rb_hit_busy_r;
  reg tail_r_lcl = 1'b1;
  generate
    if (nBANK_MACHS > 1) begin : compute_tail
      reg tail_ns;
      always @(accept_req or accept_this_bm
               or bm_end_in or bm_end_lcl or idle_r_lcl
               or idlers_above or rb_hit_busy_r or rst or tail_r_lcl) begin
        if (rst) tail_ns = (ID == nBANK_MACHS);
        else begin
          tail_ns = tail_r_lcl;
          if ((accept_req && rb_hit_busy_r) ||
               (|bm_end_in[`BM_SHARED_BV] && idle_r_lcl))
            tail_ns = 1'b0;
          if (accept_this_bm || (bm_end_lcl && ~idlers_above)) tail_ns = 1'b1;
         end
       end
       always @(posedge clk) tail_r_lcl <= #TCQ tail_ns;
    end 
  endgenerate
  output wire tail_r;
  assign tail_r = tail_r_lcl;
  wire clear_req = bm_end_lcl || rst;
  reg idle_ns_lcl;
  always @(accept_this_bm or clear_req or idle_r_lcl) begin
    idle_ns_lcl = idle_r_lcl;
    if (accept_this_bm) idle_ns_lcl = 1'b0;
    if (clear_req) idle_ns_lcl = 1'b1;
  end
  always @(posedge clk) idle_r_lcl <= #TCQ idle_ns_lcl;
  output wire idle_ns;
  assign idle_ns = idle_ns_lcl;
  output wire idle_r;
  assign idle_r = idle_r_lcl;
  input maint_idle;
  input maint_hit;
  wire maint_hit_this_bm = ~maint_idle && maint_hit;
  input row_hit_r;
  input pre_wait_r;
  wire pass_open_bank_eligible =
         tail_r_lcl && rb_hit_busy_r && row_hit_r && ~pre_wait_r;
  reg wait_for_maint_r_lcl;
  reg pass_open_bank_r_lcl;
  wire pass_open_bank_ns_lcl = ~clear_req &&
          (pass_open_bank_r_lcl ||
           (accept_req && pass_open_bank_eligible &&
             (~maint_hit_this_bm || wait_for_maint_r_lcl)));
  always @(posedge clk) pass_open_bank_r_lcl <= #TCQ pass_open_bank_ns_lcl;
  output wire pass_open_bank_ns;
  assign pass_open_bank_ns = pass_open_bank_ns_lcl;
  output wire pass_open_bank_r;
  assign pass_open_bank_r = pass_open_bank_r_lcl;
`ifdef MC_SVA
  pass_open_bank: cover property (@(posedge clk) (~rst && pass_open_bank_ns));
  pass_open_bank_killed_by_maint: cover property (@(posedge clk)
     (~rst && accept_req && pass_open_bank_eligible &&
       maint_hit_this_bm && ~wait_for_maint_r_lcl));
  pass_open_bank_following_maint: cover property (@(posedge clk)
     (~rst && accept_req && pass_open_bank_eligible &&
        maint_hit_this_bm && wait_for_maint_r_lcl));
`endif
  reg auto_pre_r_lcl;
  reg auto_pre_ns;
  input allow_auto_pre;
  always @(accept_req or allow_auto_pre or auto_pre_r_lcl
           or clear_req or maint_hit_this_bm or rb_hit_busy_r
           or row_hit_r or tail_r_lcl or wait_for_maint_r_lcl) begin
    auto_pre_ns = auto_pre_r_lcl;
    if (clear_req) auto_pre_ns = 1'b0;
    else
      if (accept_req && tail_r_lcl && allow_auto_pre && rb_hit_busy_r &&
          (~row_hit_r || (maint_hit_this_bm && ~wait_for_maint_r_lcl)))
        auto_pre_ns = 1'b1;
  end
  always @(posedge clk) auto_pre_r_lcl <= #TCQ auto_pre_ns;
  output wire auto_pre_r;
  assign auto_pre_r = auto_pre_r_lcl;
`ifdef MC_SVA
  auto_precharge: cover property (@(posedge clk) (~rst && auto_pre_ns));
  maint_triggers_auto_precharge: cover property (@(posedge clk)
    (~rst && auto_pre_ns && ~auto_pre_r && row_hit_r));
`endif
  input sending_col;
  input req_wr_r;
  input rd_wr_r;
  wire sending_col_not_rmw_rd = sending_col && !(req_wr_r && rd_wr_r);
  input bank_wait_in_progress;
  input precharge_bm_end;
  reg pre_bm_end_r;
  wire pre_bm_end_ns = precharge_bm_end ||
                       (bank_wait_in_progress && pass_open_bank_ns_lcl);
  always @(posedge clk) pre_bm_end_r <= #TCQ pre_bm_end_ns;
  assign bm_end_lcl = 
          pre_bm_end_r || (sending_col_not_rmw_rd && pass_open_bank_r_lcl);
  output wire bm_end;
  assign bm_end = bm_end_lcl;
  reg pre_passing_open_bank_r;
  wire pre_passing_open_bank_ns =
            bank_wait_in_progress && pass_open_bank_ns_lcl;
  always @(posedge clk) pre_passing_open_bank_r <= #TCQ
                         pre_passing_open_bank_ns;
  output wire passing_open_bank;
  assign passing_open_bank =
  pre_passing_open_bank_r || (sending_col_not_rmw_rd && pass_open_bank_r_lcl);
  reg ordered_ns;
  wire set_order_q = ((ORDERING == "STRICT") || ((ORDERING == "NORM") &&
                       req_wr_r)) && accept_this_bm;
  wire ordered_issued_lcl = 
            sending_col_not_rmw_rd && !(req_wr_r && rd_wr_r) &&
            ((ORDERING == "STRICT") || ((ORDERING == "NORM") && req_wr_r));
  output wire ordered_issued;
  assign ordered_issued = ordered_issued_lcl;
  reg ordered_r_lcl;
  always @(ordered_issued_lcl or ordered_r_lcl or rst
           or set_order_q) begin
    if (rst) ordered_ns = 1'b0;
    else begin
      ordered_ns = ordered_r_lcl;
      if (set_order_q) ordered_ns = 1'b1;
      if (ordered_issued_lcl) ordered_ns = 1'b0;
    end
  end
  always @(posedge clk) ordered_r_lcl <= #TCQ ordered_ns;
  output wire ordered_r;
  assign ordered_r = ordered_r_lcl;
  input adv_order_q;
  input [BM_CNT_WIDTH-1:0] order_cnt;
  reg [BM_CNT_WIDTH-1:0] order_q_r;
  reg [BM_CNT_WIDTH-1:0] order_q_ns;
  always @(adv_order_q or order_cnt or order_q_r or rst
           or set_order_q) begin
    order_q_ns = order_q_r;
    if (rst) order_q_ns = BM_CNT_ZERO;
    if (set_order_q)
      if (adv_order_q) order_q_ns = order_cnt - BM_CNT_ONE;
      else order_q_ns = order_cnt;
    if (adv_order_q && |order_q_r) order_q_ns = order_q_r - BM_CNT_ONE;
  end
  always @(posedge clk) order_q_r <= #TCQ order_q_ns;
  output wire order_q_zero;
  assign order_q_zero = ~|order_q_r ||
                        (adv_order_q && (order_q_r == BM_CNT_ONE)) ||
                        ((ORDERING == "NORM") && rd_wr_r);
  input [(nBANK_MACHS*2)-1:0] rb_hit_busy_ns_in;
  reg [(nBANK_MACHS*2)-1:0] rb_hit_busies_r_lcl = {nBANK_MACHS*2{1'b0}};
  input [(nBANK_MACHS*2)-1:0] passing_open_bank_in;
  output reg rcv_open_bank = 1'b0;
  generate
    if (nBANK_MACHS > 1) begin : rb_hit_busies
      wire [nBANK_MACHS-2:0] clear_vector =
                ({nBANK_MACHS-1{rst}} | bm_end_in[`BM_SHARED_BV]);
      wire [`BM_SHARED_BV] rb_hit_busies_ns =
                ~clear_vector &
                (idle_ns_lcl
                   ? rb_hit_busy_ns_in[`BM_SHARED_BV]
                   : rb_hit_busies_r_lcl[`BM_SHARED_BV]);
      always @(posedge clk) rb_hit_busies_r_lcl[`BM_SHARED_BV] <=
                             #TCQ rb_hit_busies_ns;
      always @(bm_end_in or rb_hit_busies_r_lcl)
        adv_queue =
            |(bm_end_in[`BM_SHARED_BV] & rb_hit_busies_r_lcl[`BM_SHARED_BV]);
      always @(idle_r_lcl
               or passing_open_bank_in or q_entry_r
               or rb_hit_busies_r_lcl) rcv_open_bank =
    |(rb_hit_busies_r_lcl[`BM_SHARED_BV] & passing_open_bank_in[`BM_SHARED_BV])
      && (q_entry_r == BM_CNT_ONE) && ~idle_r_lcl;
    end
  endgenerate
  output wire [nBANK_MACHS*2-1:0] rb_hit_busies_r;
  assign rb_hit_busies_r = rb_hit_busies_r_lcl;
  input was_wr;
  input maint_req_r;
  reg q_has_rd_r;
  wire q_has_rd_ns = ~clear_req &&
              (q_has_rd_r || (accept_req && rb_hit_busy_r && ~was_wr) ||
               (maint_req_r && maint_hit && ~idle_r_lcl));
  always @(posedge clk) q_has_rd_r <= #TCQ q_has_rd_ns;
  output wire q_has_rd;
  assign q_has_rd = q_has_rd_r;
  input was_priority;
  reg q_has_priority_r;
  wire q_has_priority_ns = ~clear_req &&
          (q_has_priority_r || (accept_req && rb_hit_busy_r && was_priority));
  always @(posedge clk) q_has_priority_r <= #TCQ q_has_priority_ns;
  output wire q_has_priority;
  assign q_has_priority = q_has_priority_r;
  wire wait_for_maint_ns = ~rst && ~maint_idle &&
                      (wait_for_maint_r_lcl || (maint_hit && accept_this_bm));
  always @(posedge clk) wait_for_maint_r_lcl <= #TCQ wait_for_maint_ns;
  output wire wait_for_maint_r;
  assign wait_for_maint_r = wait_for_maint_r_lcl;
endmodule 
