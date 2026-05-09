`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_crossbar_v2_1_8_si_transactor #
  (
   parameter         C_FAMILY                       = "none", 
   parameter integer C_SI             =   0, 
   parameter integer C_DIR             =   0, 
   parameter integer C_NUM_ADDR_RANGES = 1,
   parameter integer C_NUM_M             =   2, 
   parameter integer C_NUM_M_LOG             =   1, 
   parameter integer C_ACCEPTANCE             =   1,  
   parameter integer C_ACCEPTANCE_LOG             =   0,  
   parameter integer C_ID_WIDTH                   = 1, 
   parameter integer C_THREAD_ID_WIDTH                  = 0,
   parameter integer C_ADDR_WIDTH                 = 32, 
   parameter integer C_AMESG_WIDTH = 1,  
   parameter integer C_RMESG_WIDTH = 1,  
   parameter [C_ID_WIDTH-1:0]  C_BASE_ID                  = {C_ID_WIDTH{1'b0}},
   parameter [C_ID_WIDTH-1:0]  C_HIGH_ID                  = {C_ID_WIDTH{1'b0}},
   parameter [C_NUM_M*C_NUM_ADDR_RANGES*64-1:0] C_BASE_ADDR = {C_NUM_M*C_NUM_ADDR_RANGES*64{1'b1}}, 
   parameter [C_NUM_M*C_NUM_ADDR_RANGES*64-1:0] C_HIGH_ADDR = {C_NUM_M*C_NUM_ADDR_RANGES*64{1'b0}}, 
   parameter integer C_SINGLE_THREAD             =   0,
   parameter [C_NUM_M-1:0]    C_TARGET_QUAL                 = {C_NUM_M{1'b1}},
   parameter [C_NUM_M*32-1:0] C_M_AXI_SECURE                   = {C_NUM_M{32'h00000000}},
   parameter integer C_RANGE_CHECK                    = 0,
   parameter integer C_ADDR_DECODE           =0,
   parameter [C_NUM_M*32-1:0] C_ERR_MODE            = {C_NUM_M{32'h00000000}},
   parameter integer C_DEBUG                = 1
   )
  (
   input  wire                                                    ACLK,
   input  wire                                                    ARESET,
   input  wire [C_ID_WIDTH-1:0]           S_AID,
   input  wire [C_ADDR_WIDTH-1:0]          S_AADDR,
   input  wire [8-1:0]                    S_ALEN,
   input  wire [3-1:0]                    S_ASIZE,
   input  wire [2-1:0]                    S_ABURST,
   input  wire [2-1:0]                    S_ALOCK,
   input  wire [3-1:0]                    S_APROT,
   input  wire [C_AMESG_WIDTH-1:0]         S_AMESG,
   input  wire                             S_AVALID,
   output wire                             S_AREADY,
   output wire [C_ID_WIDTH-1:0]          M_AID,
   output wire [C_ADDR_WIDTH-1:0]          M_AADDR,
   output  wire [8-1:0]                    M_ALEN,
   output  wire [3-1:0]                    M_ASIZE,
   output  wire [2-1:0]                    M_ALOCK,
   output  wire [3-1:0]                    M_APROT,
   output wire [4-1:0]                         M_AREGION,
   output wire [C_AMESG_WIDTH-1:0]                         M_AMESG,
   output wire [(C_NUM_M+1)-1:0]                         M_ATARGET_HOT,
   output wire [(C_NUM_M_LOG+1)-1:0]                         M_ATARGET_ENC,
   output wire [7:0]                         M_AERROR,
   output wire                            M_AVALID_QUAL,
   output wire                            M_AVALID,
   input  wire                            M_AREADY,
   output  wire [C_ID_WIDTH-1:0]           S_RID,
   output  wire [C_RMESG_WIDTH-1:0]         S_RMESG,
   output  wire                             S_RLAST,
   output  wire                             S_RVALID,
   input wire                             S_RREADY,
   input wire [(C_NUM_M+1)*C_ID_WIDTH-1:0]          M_RID,
   input wire [(C_NUM_M+1)*C_RMESG_WIDTH-1:0]             M_RMESG,
   input wire [(C_NUM_M+1)-1:0]                           M_RLAST,
   input wire [(C_NUM_M+1)-1:0]                           M_RVALID,
   output  wire [(C_NUM_M+1)-1:0]                           M_RREADY,
   input wire [(C_NUM_M+1)-1:0]           M_RTARGET,  
   input wire [8-1:0]                        DEBUG_A_TRANS_SEQ
   );
  localparam integer P_WRITE = 0;
  localparam integer P_READ = 1;
  localparam integer P_RMUX_MESG_WIDTH = C_ID_WIDTH + C_RMESG_WIDTH + 1;
  localparam [31:0]   P_AXILITE_ERRMODE = 32'h00000001;
  localparam integer P_NONSECURE_BIT = 1; 
  localparam integer P_NUM_M_LOG_M1 = C_NUM_M_LOG ? C_NUM_M_LOG : 1;
  localparam [C_NUM_M-1:0] P_M_AXILITE = f_m_axilite(0);  
  localparam [1:0]   P_FIXED = 2'b00;
  localparam integer P_NUM_M_DE_LOG = f_ceil_log2(C_NUM_M+1);
  localparam integer P_THREAD_ID_WIDTH_M1 = (C_THREAD_ID_WIDTH > 0) ? C_THREAD_ID_WIDTH : 1; 
  localparam integer P_NUM_ID_VAL = 2**C_THREAD_ID_WIDTH;
  localparam integer P_NUM_THREADS = (P_NUM_ID_VAL < C_ACCEPTANCE) ? P_NUM_ID_VAL : C_ACCEPTANCE;
  localparam [C_NUM_M-1:0] P_M_SECURE_MASK = f_bit32to1_mi(C_M_AXI_SECURE);  
  function integer f_ceil_log2
    (
     input integer x
     );
    integer acc;
    begin
      acc=0;
      while ((2**acc) < x)
        acc = acc + 1;
      f_ceil_log2 = acc;
    end
  endfunction
  function [C_NUM_M-1:0] f_m_axilite
    (
      input integer null_arg
    );
    integer mi;
    begin
      for (mi=0; mi<C_NUM_M; mi=mi+1) begin
        f_m_axilite[mi] = (C_ERR_MODE[mi*32+:32] == P_AXILITE_ERRMODE);
      end
    end
  endfunction
  function [C_NUM_M-1:0] f_bit32to1_mi
    (input [C_NUM_M*32-1:0] vec32);
    integer mi;
    begin
      for (mi=0; mi<C_NUM_M; mi=mi+1) begin
        f_bit32to1_mi[mi] = vec32[mi*32];
      end
    end
  endfunction
  wire [C_NUM_M-1:0] target_mi_hot;
  wire [P_NUM_M_LOG_M1-1:0] target_mi_enc;
  wire [(C_NUM_M+1)-1:0] m_atarget_hot_i;
  wire [(P_NUM_M_DE_LOG)-1:0] m_atarget_enc_i;
  wire match;
  wire [3:0] target_region;
  wire [3:0] m_aregion_i;
  wire m_avalid_i;
  wire s_aready_i;
  wire any_error;
  wire s_rvalid_i;
  wire [C_ID_WIDTH-1:0] s_rid_i;
  wire s_rlast_i;
  wire [P_RMUX_MESG_WIDTH-1:0] si_rmux_mesg;
  wire [(C_NUM_M+1)*P_RMUX_MESG_WIDTH-1:0] mi_rmux_mesg;
  wire [(C_NUM_M+1)-1:0] m_rvalid_qual;
  wire [(C_NUM_M+1)-1:0] m_rready_arb;
  wire [(C_NUM_M+1)-1:0] m_rready_i;
  wire target_secure;
  wire target_axilite;
  wire m_avalid_qual_i;
  wire [7:0] m_aerror_i;
  genvar gen_mi;
  genvar gen_thread;
  generate
    if (C_ADDR_DECODE) begin : gen_addr_decoder
      axi_crossbar_v2_1_8_addr_decoder #
        (
          .C_FAMILY          (C_FAMILY),
          .C_NUM_TARGETS     (C_NUM_M),
          .C_NUM_TARGETS_LOG (P_NUM_M_LOG_M1),
          .C_NUM_RANGES      (C_NUM_ADDR_RANGES),
          .C_ADDR_WIDTH      (C_ADDR_WIDTH),
          .C_TARGET_ENC      (1),
          .C_TARGET_HOT      (1),
          .C_REGION_ENC      (1),
          .C_BASE_ADDR      (C_BASE_ADDR),
          .C_HIGH_ADDR      (C_HIGH_ADDR),
          .C_TARGET_QUAL     (C_TARGET_QUAL),
          .C_RESOLUTION      (2)
        ) 
        addr_decoder_inst 
        (
          .ADDR             (S_AADDR),        
          .TARGET_HOT       (target_mi_hot),  
          .TARGET_ENC       (target_mi_enc),  
          .MATCH            (match),       
          .REGION           (target_region)      
        );
    end else begin : gen_no_addr_decoder
      assign target_mi_hot = 1;
      assign target_mi_enc = 0;
      assign match = 1'b1;
      assign target_region = 4'b0000;
    end
  endgenerate
  assign target_secure = |(target_mi_hot & P_M_SECURE_MASK);
  assign target_axilite = |(target_mi_hot & P_M_AXILITE);
  assign any_error = C_RANGE_CHECK && (m_aerror_i != 0);            
  assign m_aerror_i[0] = ~match;                                    
  assign m_aerror_i[1] = target_secure && S_APROT[P_NONSECURE_BIT]; 
  assign m_aerror_i[2] = target_axilite && ((S_ALEN != 0) || 
    (S_ASIZE[1:0] == 2'b11) || (S_ASIZE[2] == 1'b1));               
  assign m_aerror_i[7:3] = 5'b00000;                                    
  assign M_ATARGET_HOT = m_atarget_hot_i;
  assign m_atarget_hot_i = (any_error ? {1'b1, {C_NUM_M{1'b0}}} : {1'b0, target_mi_hot});
  assign m_atarget_enc_i = (any_error ? C_NUM_M : target_mi_enc);
  assign M_AVALID = m_avalid_i;
  assign m_avalid_i = S_AVALID;
  assign M_AVALID_QUAL = m_avalid_qual_i; 
  assign S_AREADY = s_aready_i;
  assign s_aready_i = M_AREADY;
  assign M_AERROR = m_aerror_i;
  assign M_ATARGET_ENC = m_atarget_enc_i;
  assign m_aregion_i = any_error ? 4'b0000 : (C_ADDR_DECODE != 0) ? target_region : 4'b0000;
  assign M_AREGION = m_aregion_i;
  assign M_AID = S_AID;
  assign M_AADDR = S_AADDR;
  assign M_ALEN = S_ALEN;
  assign M_ASIZE = S_ASIZE;
  assign M_ALOCK = S_ALOCK;
  assign M_APROT = S_APROT;
  assign M_AMESG = S_AMESG;
  assign S_RVALID = s_rvalid_i;
  assign M_RREADY = m_rready_i;
  assign s_rid_i = si_rmux_mesg[0+:C_ID_WIDTH];
  assign S_RMESG = si_rmux_mesg[C_ID_WIDTH+:C_RMESG_WIDTH];
  assign s_rlast_i = si_rmux_mesg[C_ID_WIDTH+C_RMESG_WIDTH+:1];
  assign S_RID = s_rid_i;
  assign S_RLAST = s_rlast_i;
  assign m_rvalid_qual = M_RVALID & M_RTARGET;
  assign m_rready_i = m_rready_arb & M_RTARGET;
  generate
    for (gen_mi=0; gen_mi<(C_NUM_M+1); gen_mi=gen_mi+1) begin : gen_rmesg_mi
      assign mi_rmux_mesg[gen_mi*P_RMUX_MESG_WIDTH+:P_RMUX_MESG_WIDTH] = {
               M_RLAST[gen_mi],
               M_RMESG[gen_mi*C_RMESG_WIDTH+:C_RMESG_WIDTH],
               M_RID[gen_mi*C_ID_WIDTH+:C_ID_WIDTH]
               };
    end  
    if (C_ACCEPTANCE == 1) begin : gen_single_issue
      wire  cmd_push;
      wire  cmd_pop;
      reg  [(C_NUM_M+1)-1:0] active_target_hot;
      reg  [P_NUM_M_DE_LOG-1:0] active_target_enc;
      reg  accept_cnt;
      reg  [8-1:0] debug_r_beat_cnt_i;
      wire [8-1:0] debug_r_trans_seq_i;
      assign cmd_push = M_AREADY;
      assign cmd_pop = s_rvalid_i && S_RREADY && s_rlast_i;  
      assign m_avalid_qual_i = ~accept_cnt | cmd_pop;  
      always @(posedge ACLK) begin 
        if (ARESET) begin
          accept_cnt <= 1'b0;
          active_target_enc <= 0;
          active_target_hot <= 0;
        end else begin
          if (cmd_push) begin
            active_target_enc <= m_atarget_enc_i;
            active_target_hot <= m_atarget_hot_i;
            accept_cnt <= 1'b1;
          end else if (cmd_pop) begin
            accept_cnt <= 1'b0;
          end
        end 
      end  
      assign m_rready_arb = active_target_hot & {(C_NUM_M+1){S_RREADY}};
      assign s_rvalid_i = |(active_target_hot & m_rvalid_qual);
      generic_baseblocks_v2_1_0_mux_enc # 
        (
         .C_FAMILY      (C_FAMILY),
         .C_RATIO       (C_NUM_M+1),
         .C_SEL_WIDTH   (P_NUM_M_DE_LOG),
         .C_DATA_WIDTH  (P_RMUX_MESG_WIDTH)
        ) mux_resp_single_issue
        (
         .S   (active_target_enc),
         .A   (mi_rmux_mesg),
         .O   (si_rmux_mesg),
         .OE  (1'b1)
        ); 
      if (C_DEBUG) begin : gen_debug_r_single_issue
        always @(posedge ACLK) begin
          if (ARESET) begin
            debug_r_beat_cnt_i <= 0;
          end else if (C_DIR == P_READ) begin
            if (s_rvalid_i && S_RREADY) begin
              if (s_rlast_i) begin
                debug_r_beat_cnt_i <= 0;
              end else begin
                debug_r_beat_cnt_i <= debug_r_beat_cnt_i + 1;
              end
            end
          end else begin
            debug_r_beat_cnt_i <= 0;            
          end
        end  
        axi_data_fifo_v2_1_6_axic_srl_fifo #
          (
           .C_FAMILY          (C_FAMILY),
           .C_FIFO_WIDTH      (8),
           .C_FIFO_DEPTH_LOG  (C_ACCEPTANCE_LOG+1),
           .C_USE_FULL        (0)
           )
          debug_r_seq_fifo_single_issue
            (
             .ACLK    (ACLK),
             .ARESET  (ARESET),
             .S_MESG  (DEBUG_A_TRANS_SEQ),
             .S_VALID (cmd_push),
             .S_READY (),
             .M_MESG  (debug_r_trans_seq_i),
             .M_VALID (),
             .M_READY (cmd_pop)
            );
      end  
    end else if (C_SINGLE_THREAD || (P_NUM_ID_VAL==1)) begin : gen_single_thread
      wire  s_avalid_en;
      wire  cmd_push;
      wire  cmd_pop;
      reg  [C_ID_WIDTH-1:0] active_id;
      reg  [(C_NUM_M+1)-1:0] active_target_hot;
      reg  [P_NUM_M_DE_LOG-1:0] active_target_enc;
      reg  [4-1:0] active_region;
      reg  [(C_ACCEPTANCE_LOG+1)-1:0] accept_cnt;
      reg  [8-1:0] debug_r_beat_cnt_i;
      wire [8-1:0] debug_r_trans_seq_i;
      wire accept_limit ;
      assign s_avalid_en =  
        (accept_cnt == 0) ||  
        (((P_NUM_ID_VAL==1) || (S_AID[P_THREAD_ID_WIDTH_M1-1:0] == active_id[P_THREAD_ID_WIDTH_M1-1:0])) &&  
        (active_target_enc == m_atarget_enc_i) &&  
        (active_region == m_aregion_i));  
      assign cmd_push = M_AREADY;
      assign cmd_pop = s_rvalid_i && S_RREADY && s_rlast_i;  
      assign accept_limit = (accept_cnt == C_ACCEPTANCE) & ~cmd_pop;  
      assign m_avalid_qual_i = s_avalid_en & ~accept_limit; 
      always @(posedge ACLK) begin 
        if (ARESET) begin
          accept_cnt <= 0;
          active_id <= 0;
          active_target_enc <= 0;
          active_target_hot <= 0;
          active_region <= 0;
        end else begin
          if (cmd_push) begin
            active_id <= S_AID[P_THREAD_ID_WIDTH_M1-1:0];
            active_target_enc <= m_atarget_enc_i;
            active_target_hot <= m_atarget_hot_i;
            active_region <= m_aregion_i;
            if (~cmd_pop) begin
              accept_cnt <= accept_cnt + 1;
            end
          end else begin
            if (cmd_pop & (accept_cnt != 0)) begin
              accept_cnt <= accept_cnt - 1;
            end
          end
        end 
      end  
      assign m_rready_arb = active_target_hot & {(C_NUM_M+1){S_RREADY}};
      assign s_rvalid_i = |(active_target_hot & m_rvalid_qual);
      generic_baseblocks_v2_1_0_mux_enc # 
        (
         .C_FAMILY      (C_FAMILY),
         .C_RATIO       (C_NUM_M+1),
         .C_SEL_WIDTH   (P_NUM_M_DE_LOG),
         .C_DATA_WIDTH  (P_RMUX_MESG_WIDTH)
        ) mux_resp_single_thread
        (
         .S   (active_target_enc),
         .A   (mi_rmux_mesg),
         .O   (si_rmux_mesg),
         .OE  (1'b1)
        ); 
      if (C_DEBUG) begin : gen_debug_r_single_thread
        always @(posedge ACLK) begin
          if (ARESET) begin
            debug_r_beat_cnt_i <= 0;
          end else if (C_DIR == P_READ) begin
            if (s_rvalid_i && S_RREADY) begin
              if (s_rlast_i) begin
                debug_r_beat_cnt_i <= 0;
              end else begin
                debug_r_beat_cnt_i <= debug_r_beat_cnt_i + 1;
              end
            end
          end else begin
            debug_r_beat_cnt_i <= 0;            
          end
        end  
        axi_data_fifo_v2_1_6_axic_srl_fifo #
          (
           .C_FAMILY          (C_FAMILY),
           .C_FIFO_WIDTH      (8),
           .C_FIFO_DEPTH_LOG  (C_ACCEPTANCE_LOG+1),
           .C_USE_FULL        (0)
           )
          debug_r_seq_fifo_single_thread
            (
             .ACLK    (ACLK),
             .ARESET  (ARESET),
             .S_MESG  (DEBUG_A_TRANS_SEQ),
             .S_VALID (cmd_push),
             .S_READY (),
             .M_MESG  (debug_r_trans_seq_i),
             .M_VALID (),
             .M_READY (cmd_pop)
            );
      end  
    end else begin : gen_multi_thread
      wire [(P_NUM_M_DE_LOG)-1:0] resp_select;
      reg  [(C_ACCEPTANCE_LOG+1)-1:0] accept_cnt;
      wire [P_NUM_THREADS-1:0] s_avalid_en;
      wire [P_NUM_THREADS-1:0] thread_valid;
      wire [P_NUM_THREADS-1:0] aid_match;
      wire [P_NUM_THREADS-1:0] rid_match;
      wire [P_NUM_THREADS-1:0] cmd_push;
      wire [P_NUM_THREADS-1:0] cmd_pop;
      wire [P_NUM_THREADS:0]   accum_push;
      reg  [P_NUM_THREADS*C_ID_WIDTH-1:0] active_id;
      reg  [P_NUM_THREADS*8-1:0] active_target;
      reg  [P_NUM_THREADS*8-1:0] active_region;
      reg  [P_NUM_THREADS*8-1:0] active_cnt;
      reg  [P_NUM_THREADS*8-1:0] debug_r_beat_cnt_i;
      wire [P_NUM_THREADS*8-1:0] debug_r_trans_seq_i;
      wire any_aid_match;
      wire any_rid_match;
      wire accept_limit;
      wire any_push;
      wire any_pop;
      axi_crossbar_v2_1_8_arbiter_resp #  
        (
         .C_FAMILY                (C_FAMILY),
         .C_NUM_S                 (C_NUM_M+1),
         .C_NUM_S_LOG             (P_NUM_M_DE_LOG),
         .C_GRANT_ENC            (1),
         .C_GRANT_HOT            (0)
         )
        arbiter_resp_inst
          (
           .ACLK                  (ACLK),
           .ARESET                (ARESET),
           .S_VALID               (m_rvalid_qual),
           .S_READY               (m_rready_arb),
           .M_GRANT_HOT           (),
           .M_GRANT_ENC           (resp_select),
           .M_VALID               (s_rvalid_i),
           .M_READY               (S_RREADY)
           );
      generic_baseblocks_v2_1_0_mux_enc # 
        (
         .C_FAMILY      (C_FAMILY),
         .C_RATIO       (C_NUM_M+1),
         .C_SEL_WIDTH   (P_NUM_M_DE_LOG),
         .C_DATA_WIDTH  (P_RMUX_MESG_WIDTH)
        ) mux_resp_multi_thread
        (
         .S   (resp_select),
         .A   (mi_rmux_mesg),
         .O   (si_rmux_mesg),
         .OE  (1'b1)
        ); 
      assign any_push = M_AREADY;
      assign any_pop = s_rvalid_i & S_RREADY & s_rlast_i;
      assign accept_limit = (accept_cnt == C_ACCEPTANCE) & ~any_pop;  
        assign m_avalid_qual_i = (&s_avalid_en) & ~accept_limit;  
        assign any_aid_match = |aid_match;
        assign any_rid_match = |rid_match;
        assign accum_push[0] = 1'b0;
        always @(posedge ACLK) begin
          if (ARESET) begin
            accept_cnt <= 0; 
          end else begin
            if (any_push & ~any_pop) begin
              accept_cnt <= accept_cnt + 1;
          end else if (any_pop & ~any_push & (accept_cnt != 0)) begin
              accept_cnt <= accept_cnt - 1;
            end
          end 
        end  
        for (gen_thread=0; gen_thread<P_NUM_THREADS; gen_thread=gen_thread+1) begin : gen_thread_loop
          assign thread_valid[gen_thread] = (active_cnt[gen_thread*8 +: C_ACCEPTANCE_LOG+1] != 0);
          assign aid_match[gen_thread] =  
            thread_valid[gen_thread] &&  
          ((S_AID[P_THREAD_ID_WIDTH_M1-1:0]) == active_id[gen_thread*C_ID_WIDTH+:P_THREAD_ID_WIDTH_M1]);  
          assign s_avalid_en[gen_thread] =  
            (~aid_match[gen_thread]) ||  
            ((m_atarget_enc_i == active_target[gen_thread*8+:P_NUM_M_DE_LOG]) &&  
            (m_aregion_i == active_region[gen_thread*8+:4]));  
          assign accum_push[gen_thread+1] = accum_push[gen_thread] | ~thread_valid[gen_thread];
          assign cmd_push[gen_thread] = any_push & (aid_match[gen_thread] | ((~any_aid_match) & ~thread_valid[gen_thread] & ~accum_push[gen_thread]));
        assign rid_match[gen_thread] = thread_valid[gen_thread] & ((s_rid_i[P_THREAD_ID_WIDTH_M1-1:0]) == active_id[gen_thread*C_ID_WIDTH+:P_THREAD_ID_WIDTH_M1]);
          assign cmd_pop[gen_thread] = any_pop & rid_match[gen_thread];
          always @(posedge ACLK) begin
            if (ARESET) begin
              active_id[gen_thread*C_ID_WIDTH+:C_ID_WIDTH] <= 0;
              active_target[gen_thread*8+:8] <= 0;
              active_region[gen_thread*8+:8] <= 0;
              active_cnt[gen_thread*8+:8] <= 0; 
            end else begin
              if (cmd_push[gen_thread]) begin
              active_id[gen_thread*C_ID_WIDTH+:P_THREAD_ID_WIDTH_M1] <= S_AID[P_THREAD_ID_WIDTH_M1-1:0];
                active_target[gen_thread*8+:P_NUM_M_DE_LOG] <= m_atarget_enc_i;
                active_region[gen_thread*8+:4] <= m_aregion_i;
                if (~cmd_pop[gen_thread]) begin
                  active_cnt[gen_thread*8+:C_ACCEPTANCE_LOG+1] <= active_cnt[gen_thread*8+:C_ACCEPTANCE_LOG+1] + 1;
                end
              end else if (cmd_pop[gen_thread]) begin
                  active_cnt[gen_thread*8+:C_ACCEPTANCE_LOG+1] <= active_cnt[gen_thread*8+:C_ACCEPTANCE_LOG+1] - 1;
              end
            end 
          end  
        if (C_DEBUG) begin : gen_debug_r_multi_thread
            always @(posedge ACLK) begin
              if (ARESET) begin
                debug_r_beat_cnt_i[gen_thread*8+:8] <= 0;
              end else if (C_DIR == P_READ) begin
                if (s_rvalid_i & S_RREADY & rid_match[gen_thread]) begin
                  if (s_rlast_i) begin
                    debug_r_beat_cnt_i[gen_thread*8+:8] <= 0;
                  end else begin
                    debug_r_beat_cnt_i[gen_thread*8+:8] <= debug_r_beat_cnt_i[gen_thread*8+:8] + 1;
                  end
                end
              end else begin
                debug_r_beat_cnt_i[gen_thread*8+:8] <= 0;            
              end
            end  
            axi_data_fifo_v2_1_6_axic_srl_fifo #
              (
               .C_FAMILY          (C_FAMILY),
               .C_FIFO_WIDTH      (8),
               .C_FIFO_DEPTH_LOG  (C_ACCEPTANCE_LOG+1),
               .C_USE_FULL        (0)
               )
            debug_r_seq_fifo_multi_thread
                (
                 .ACLK    (ACLK),
                 .ARESET  (ARESET),
                 .S_MESG  (DEBUG_A_TRANS_SEQ),
                 .S_VALID (cmd_push[gen_thread]),
                 .S_READY (),
                 .M_MESG  (debug_r_trans_seq_i[gen_thread*8+:8]),
                 .M_VALID (),
                 .M_READY (cmd_pop[gen_thread])
                );
        end  
      end  
    end  
  endgenerate
endmodule
`default_nettype wire
