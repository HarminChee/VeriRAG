`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif
`timescale 1ns/1ns
`ifndef TCQ
 `define TCQ 1
`endif
module pcie_blk_ll_arb
#(
       parameter C_STREAMING                   = 0,
       parameter CPL_STREAMING_PRIORITIZE_P_NP = 0
 )
 (
       input wire         clk,
       input wire         rst_n,
       output reg         llk_rx_dst_req_n,
       output reg  [2:0]  llk_rx_ch_tc     = 0,
       output wire [1:0]  llk_rx_ch_fifo,
       output wire        fifo_np_req,
       output wire        fifo_pcpl_req,
       input  wire        fifo_np_ok,
       input  wire        fifo_pcpl_ok,
       input  wire        trn_rnp_ok_n,
       input  wire        llk_rx_src_last_req_n,
       input  wire [7:0]  llk_rx_ch_posted_available_n,
       input  wire [7:0]  llk_rx_ch_non_posted_available_n,
       input  wire [7:0]  llk_rx_ch_completion_available_n,
       input  wire [15:0] llk_rx_preferred_type,  
       output reg         llk_rx_dst_cont_req_n,
       input  wire        trn_rcpl_streaming_n,
       input  wire [7:0]  cpl_tlp_cntr,
       input  wire        cpl_tlp_cntr_inc
); 
reg  [7:0] any_queue_available       = 8'b0;
reg  [7:0] any_queue_available_int;
reg  [7:0] high_mask                 = 8'b0;
reg        any_available             = 0;
reg        any_available_d           = 0;
reg  [2:0] next_tc                   = 3'b0; 
reg  [2:0] next_tc_high              = 3'b0; 
reg  [2:0] next_tc_low               = 3'b0; 
reg  [2:0] next_tc_high_pre          = 3'b0; 
reg  [2:0] next_tc_low_pre           = 3'b0; 
reg        next_tc_avail_high        = 0;
reg        next_tc_avail_low         = 0;
reg        next_tc_avail_high_pre    = 0;
reg        next_tc_avail_low_pre     = 0;
reg        transaction               = 0;
reg        llk_rx_dst_req_n_q1       = 1;
reg        llk_rx_dst_req_n_q2       = 1;
reg        final_xfer_d              = 0;
reg        fifo_pcpl_ok_final        = 1;
reg        transaction_first         = 0;
reg        transaction_stream        = 0;
reg        completion_available      = 0;
reg        last_completion           = 1;
reg  [7:0] cpl_tlp_rcntr             = 8'h00;
reg  [7:0] cpl_tlp_rcntr_p1          = 8'h01;
reg  [7:0] cpl_tlp_rcntr_p2          = 8'h02;
reg        llk_rx_src_last_req_n_dly = 1;
reg        llk_rx_src_last_req_n_q   = 1;
reg        current_posted_available_n_d     = 1;
reg        current_non_posted_available_n_d = 1;
reg        current_completion_available_n_d = 1;
reg        trn_rcpl_streaming_n_reg  = 1;
reg        next_tc_is_same_rdy       = 0;
reg        next_tc_is_same_lock      = 0;
reg        transaction_second        = 0;
reg        transaction_third         = 0;
reg  [1:0] preferred_timer           = 'd3;
reg        preferred_vld             = 1;
reg  [7:0] preferred_avail_tc;
reg        preferred_avail           = 0;
reg        posted_avail              = 0;
reg  [1:0] llk_rx_ch_fifo_int        = 0;
reg        force_streaming           = 0;
reg        preferred_avail_chosen    = 0;
reg [47:0] transaction_status        = "RESET";
reg        pnp_waiting               = 0;
reg        force_service_pnp_queues  = 0;
reg  [1:0] preferred_alt             = 2'd0;
reg        rnp_rob                   = 0;
reg        rnp_rr                    = 0;
reg  [1:0] llk_rx_preferred_type_d             = 0;
reg        llk_rx_ch_posted_available_n_d      = 0;
reg        llk_rx_ch_non_posted_available_n_d  = 0;
reg        llk_rx_ch_completion_available_n_d  = 0;
reg        cpl_avail                 = 0;
reg        np_rnp_stall              = 0;
wire       final_xfer;
wire       trigger_xfer;
wire       transaction_init_cpl;
wire       llk_rx_src_last_req_fell = llk_rx_src_last_req_n_q &&
                                     !llk_rx_src_last_req_n_dly;
integer    i,j,k,m;
  always @* begin
    if (!trn_rcpl_streaming_n_reg) begin : dst_stream
    llk_rx_dst_req_n = 
      !(transaction && (llk_rx_ch_fifo[1]? 
                        (!last_completion || llk_rx_src_last_req_n_dly):  
                        (llk_rx_src_last_req_n_dly &&                     
                         (preferred_avail || posted_avail))));
    llk_rx_dst_cont_req_n = !(transaction && 
                              (llk_rx_ch_fifo[1]?  !last_completion: 1'b0));
    end else begin:dst_normal
    llk_rx_dst_req_n = !(transaction && llk_rx_src_last_req_n_dly &&
                         (preferred_avail || posted_avail || cpl_avail));
    llk_rx_dst_cont_req_n = 1'b1;    
    end
  end
always @(posedge clk) begin
  if (!rst_n) begin
    llk_rx_ch_tc       <= #`TCQ 0;
    llk_rx_ch_fifo_int <= #`TCQ 0;
  end else begin
    if (transaction_init_cpl) begin
      llk_rx_ch_tc       <= #`TCQ 0;
      llk_rx_ch_fifo_int <= #`TCQ 2'd2;
    end else if (trigger_xfer) begin
      llk_rx_ch_tc   <= #`TCQ next_tc;
      case (next_tc)
      3'd0: llk_rx_ch_fifo_int <= #`TCQ llk_rx_preferred_type[1:0];
      3'd1: llk_rx_ch_fifo_int <= #`TCQ llk_rx_preferred_type[3:2];
      3'd2: llk_rx_ch_fifo_int <= #`TCQ llk_rx_preferred_type[5:4];
      3'd3: llk_rx_ch_fifo_int <= #`TCQ llk_rx_preferred_type[7:6];
      3'd4: llk_rx_ch_fifo_int <= #`TCQ llk_rx_preferred_type[9:8];
      3'd5: llk_rx_ch_fifo_int <= #`TCQ llk_rx_preferred_type[11:10];
      3'd6: llk_rx_ch_fifo_int <= #`TCQ llk_rx_preferred_type[13:12];
      3'd7: llk_rx_ch_fifo_int <= #`TCQ llk_rx_preferred_type[15:14];
      endcase
    end
  end
end
always @(posedge clk) begin
  if (!rst_n) begin
    preferred_avail_chosen <= #`TCQ 0;
    force_streaming        <= #`TCQ 0;
  end else begin
    if (transaction_init_cpl)
      force_streaming      <= #`TCQ 1;
    else if (trigger_xfer)
      force_streaming      <= #`TCQ 0;
    if (transaction_first && preferred_avail)  
      preferred_avail_chosen <= #`TCQ 1;
    else if (final_xfer)
      preferred_avail_chosen <= #`TCQ 0;
  end
end
assign llk_rx_ch_fifo = (force_streaming || 
                         preferred_avail ||
                         preferred_avail_chosen) ?
                         llk_rx_ch_fifo_int : np_rnp_stall ? preferred_alt : 2'd0;
always @* begin
  any_queue_available_int[0] = 
     (!llk_rx_ch_non_posted_available_n[0] && fifo_np_ok) ||
     ((!llk_rx_ch_posted_available_n[0] ||
      (!llk_rx_ch_completion_available_n[0] && trn_rcpl_streaming_n_reg)) && 
        fifo_pcpl_ok);
  for (i=1; i<=7; i=i+1) begin
    any_queue_available_int[i] = 
       (!llk_rx_ch_non_posted_available_n[i] && fifo_np_ok) ||
       (!llk_rx_ch_posted_available_n[i]     && fifo_pcpl_ok);
  end
end 
always @(posedge clk) begin
  if (!rst_n) begin
    next_tc_high                       <= #`TCQ 3'b000;
    next_tc_low                        <= #`TCQ 3'b000;
    next_tc_avail_high                 <= #`TCQ 0;
    next_tc_avail_low                  <= #`TCQ 0;
    any_queue_available                <= #`TCQ 8'b00000000;
    any_available                      <= #`TCQ 0;
    any_available_d                    <= #`TCQ 0;
    next_tc                            <= #`TCQ 0; 
  end else begin
    for (i=0; i<=7; i=i+1) begin
      any_queue_available[i]             <= #`TCQ any_queue_available_int[i];
    end
    any_available                      <= #`TCQ |any_queue_available;
    any_available_d                    <= #`TCQ any_available;
    next_tc_avail_high                 <= #`TCQ next_tc_avail_high_pre;
    next_tc_high                       <= #`TCQ next_tc_high_pre;
    next_tc_avail_low                  <= #`TCQ next_tc_avail_low_pre;
    next_tc_low                        <= #`TCQ next_tc_low_pre;
    current_posted_available_n_d       <= #`TCQ 
                                          llk_rx_ch_posted_available_n[llk_rx_ch_tc];
    current_non_posted_available_n_d   <= #`TCQ 
                                          llk_rx_ch_non_posted_available_n[llk_rx_ch_tc];
    if (!trn_rcpl_streaming_n_reg)
      current_completion_available_n_d   <= #`TCQ 0;
    else
      current_completion_available_n_d   <= #`TCQ
                                            llk_rx_ch_completion_available_n[llk_rx_ch_tc];
    if (next_tc_avail_high) begin
      next_tc              <= #`TCQ next_tc_high;
    end else begin
      next_tc              <= #`TCQ next_tc_low;
    end
  end
end
always @(posedge clk) begin
  if (!rst_n)
    high_mask <= #`TCQ 8'b00000000;
  else begin
    for (k=0; k<= 7; k=k+1)
      high_mask[k] <= #`TCQ (llk_rx_ch_tc < k);
  end
end
always @* begin
  next_tc_high_pre        = llk_rx_ch_tc; 
  next_tc_low_pre         = llk_rx_ch_tc; 
  next_tc_avail_high_pre  = 0;
  next_tc_avail_low_pre   = 0;
  for (j=7; j>=0; j=j-1)
  begin
    if (high_mask[j] && any_queue_available[j])
    begin
      next_tc_high_pre       = j; 
      next_tc_avail_high_pre = 1;
    end
    if (any_queue_available[j])
    begin
      next_tc_low_pre       = j; 
      next_tc_avail_low_pre = 1;
    end
  end
end
assign final_xfer     = !llk_rx_src_last_req_n_dly;
assign fifo_np_req    = transaction_first &&  llk_rx_ch_fifo[0];
assign fifo_pcpl_req  = transaction_first && !llk_rx_ch_fifo[0];
assign transaction_init_cpl = (!trn_rcpl_streaming_n_reg && completion_available && 
                               (!transaction || (final_xfer && !last_completion)));
assign trigger_xfer   = ((any_available_d || next_tc_is_same_rdy) &&
                         (!transaction    || final_xfer));
always @(posedge clk)
begin
  if (!rst_n) begin
    transaction        <= #`TCQ 0;
    transaction_first  <= #`TCQ 0;
    transaction_stream <= #`TCQ 0;
      transaction_status <= #`TCQ "RESET";
  end else if (transaction_init_cpl) begin
    transaction        <= #`TCQ 1;
    transaction_first  <= #`TCQ 1;
    transaction_stream <= #`TCQ 1;
      transaction_status <= #`TCQ "INCPL";
  end else if (transaction_first && 
      !(preferred_avail || posted_avail || cpl_avail || transaction_stream)) begin
    transaction        <= #`TCQ 0;
    transaction_first  <= #`TCQ 0;
    transaction_stream <= #`TCQ 0;
      transaction_status <= #`TCQ "ABORT";
  end else if (next_tc_is_same_lock && (final_xfer || !transaction)) begin
    transaction        <= #`TCQ 0;
    transaction_first  <= #`TCQ 0;
    transaction_stream <= #`TCQ 0;
      transaction_status <= #`TCQ "LOCK";
  end else if (trigger_xfer) begin
    transaction        <= #`TCQ 1;
    transaction_first  <= #`TCQ 1;
    transaction_stream <= #`TCQ 0;
      transaction_status <= #`TCQ "TRIG";
  end else if (final_xfer) begin
    transaction        <= #`TCQ 0;
    transaction_first  <= #`TCQ 0;
    transaction_stream <= #`TCQ 0;
      transaction_status <= #`TCQ "LAST";
  end else if (!llk_rx_dst_req_n) begin
    transaction        <= #`TCQ transaction;
    transaction_first  <= #`TCQ 0;
    transaction_stream <= #`TCQ transaction_stream;
      transaction_status <= #`TCQ "REQ";
  end
    else begin
      transaction_status <= #`TCQ "OFF";
    end
end
always @(posedge clk)
begin
  if (!rst_n) begin
    next_tc_is_same_rdy  <= #`TCQ 1'b0;
    next_tc_is_same_lock <= #`TCQ 1'b0;
  end else begin
    next_tc_is_same_rdy  <= #`TCQ (next_tc == llk_rx_ch_tc) && 
                                  any_queue_available_int[next_tc]; 
    next_tc_is_same_lock <= #`TCQ (next_tc == llk_rx_ch_tc) && !preferred_vld;
  end
end
always @(posedge clk)
begin
  if (!rst_n) begin
    llk_rx_dst_req_n_q1 <= #`TCQ 1;
    llk_rx_dst_req_n_q2 <= #`TCQ 1;
    final_xfer_d        <= #`TCQ 0;
  end else begin
    llk_rx_dst_req_n_q1 <= #`TCQ llk_rx_dst_req_n;
    llk_rx_dst_req_n_q2 <= #`TCQ llk_rx_dst_req_n_q1;
    final_xfer_d        <= #`TCQ final_xfer;
  end
end
always @(posedge clk) begin
  if (!rst_n) begin
    completion_available <= #`TCQ 0;
  end else if (force_service_pnp_queues && llk_rx_dst_cont_req_n) begin
    completion_available <= #`TCQ 0;
  end else if (!llk_rx_src_last_req_n?(cpl_tlp_cntr[3:0] == cpl_tlp_rcntr_p1[3:0]):
                                      (cpl_tlp_cntr[3:0] == cpl_tlp_rcntr[3:0])) begin
    completion_available <= #`TCQ 0;
  end else if (cpl_tlp_cntr[3:0] != cpl_tlp_rcntr[3:0]) begin
    completion_available <= #`TCQ fifo_pcpl_ok_final;
  end
end
always @(posedge clk) begin
  if (!rst_n) begin
    pnp_waiting              <= #`TCQ 0;
    force_service_pnp_queues <= #`TCQ 0;
  end else begin
    pnp_waiting              <= #`TCQ !llk_rx_ch_posted_available_n[0] ||
                                      !llk_rx_ch_non_posted_available_n[0];
    force_service_pnp_queues <= #`TCQ pnp_waiting && CPL_STREAMING_PRIORITIZE_P_NP;
  end
end
always @(posedge clk) begin
  if (!rst_n) begin
    last_completion         <= #`TCQ 1;
    llk_rx_src_last_req_n_q <= #`TCQ 1;
  end else begin
    if ((llk_rx_ch_fifo == 2'd2) && !llk_rx_src_last_req_n)
      last_completion         <= #`TCQ (cpl_tlp_cntr[3:0] == cpl_tlp_rcntr_p2[3:0]) ||
                                        !fifo_pcpl_ok || force_service_pnp_queues;
    else if (transaction_init_cpl)
      last_completion         <= #`TCQ (cpl_tlp_cntr[3:0] == cpl_tlp_rcntr_p1[3:0]) ||
                                        !fifo_pcpl_ok || force_service_pnp_queues;
    llk_rx_src_last_req_n_q <= #`TCQ llk_rx_src_last_req_n;
  end
end
always @(posedge clk) begin
  if (!rst_n) begin
    fifo_pcpl_ok_final <= #`TCQ 1;
  end else begin
    if (!fifo_pcpl_ok && !llk_rx_src_last_req_n)
      fifo_pcpl_ok_final <= #`TCQ 0;
    else if (fifo_pcpl_ok)
      fifo_pcpl_ok_final <= #`TCQ 1;
  end
end
always @(posedge clk) begin
  if (!rst_n) begin
    cpl_tlp_rcntr        <= #`TCQ 8'h00;
    cpl_tlp_rcntr_p1     <= #`TCQ 8'h01;
    cpl_tlp_rcntr_p2     <= #`TCQ 8'h02;
  end else if ((llk_rx_ch_fifo == 2'd2) && !llk_rx_src_last_req_n) begin
    cpl_tlp_rcntr        <= #`TCQ cpl_tlp_rcntr    + 1;
    cpl_tlp_rcntr_p1     <= #`TCQ cpl_tlp_rcntr_p1 + 1;
    cpl_tlp_rcntr_p2     <= #`TCQ cpl_tlp_rcntr_p2 + 1;
  end
end
always @(posedge clk) begin
  if (!rst_n) begin
    trn_rcpl_streaming_n_reg <= #`TCQ 1;
  end else if (trn_rcpl_streaming_n && !trn_rcpl_streaming_n_reg) begin
    trn_rcpl_streaming_n_reg <= #`TCQ !((llk_rx_ch_fifo == 2'd2) && !llk_rx_dst_cont_req_n);
  end else begin
    trn_rcpl_streaming_n_reg <= #`TCQ trn_rcpl_streaming_n;
  end
end
always @(posedge clk) begin
  if (!rst_n) begin
    preferred_vld      <= #`TCQ 1;
    preferred_timer    <= #`TCQ 'd3;
    transaction_second <= #`TCQ 0;
    transaction_third  <= #`TCQ 0;
  end else begin
   if (transaction_first && (preferred_avail || posted_avail || cpl_avail || transaction_stream)) begin
      preferred_vld      <= #`TCQ 0;
      preferred_timer    <= #`TCQ 'd3;
      transaction_second <= #`TCQ 1;
      transaction_third  <= #`TCQ 0;
    end else if (transaction_second) begin
      preferred_vld      <= #`TCQ 0;
      preferred_timer    <= #`TCQ 'd3;
      transaction_second <= #`TCQ 0;
      transaction_third  <= #`TCQ transaction && !transaction_stream; 
    end else if (transaction_third && transaction) begin
      preferred_vld      <= #`TCQ 0;
      transaction_second <= #`TCQ 0;
      casex ({llk_rx_ch_fifo,
              current_posted_available_n_d,
              current_non_posted_available_n_d,
              current_completion_available_n_d})
      5'b00_0xx: begin
          preferred_timer    <= #`TCQ preferred_timer - 1;
          transaction_third  <= #`TCQ 0;
        end
      5'b01_x0x: begin
          preferred_timer    <= #`TCQ preferred_timer - 1;
          transaction_third  <= #`TCQ 0;
        end
      5'b1x_xx0: begin
          preferred_timer    <= #`TCQ preferred_timer - 1;
          transaction_third  <= #`TCQ 0;
        end
      default: begin
          preferred_timer    <= #`TCQ preferred_timer;
          transaction_third  <= #`TCQ 1;
        end
      endcase
    end else if (|preferred_timer) begin
      preferred_vld      <= #`TCQ (preferred_timer <= 3'd1);
      preferred_timer    <= #`TCQ preferred_timer - 1;
      transaction_second <= #`TCQ 0;
      transaction_third  <= #`TCQ 0;
    end
  end
end
always @(posedge clk) begin
  if (!rst_n) begin
    preferred_avail <= #`TCQ 0;
    posted_avail    <= #`TCQ 0;
  end else if (trigger_xfer) begin
    case (next_tc)
    3'd0: preferred_avail <= #`TCQ preferred_avail_tc[0] && preferred_vld; 
    3'd1: preferred_avail <= #`TCQ preferred_avail_tc[1] && preferred_vld; 
    3'd2: preferred_avail <= #`TCQ preferred_avail_tc[2] && preferred_vld; 
    3'd3: preferred_avail <= #`TCQ preferred_avail_tc[3] && preferred_vld; 
    3'd4: preferred_avail <= #`TCQ preferred_avail_tc[4] && preferred_vld; 
    3'd5: preferred_avail <= #`TCQ preferred_avail_tc[5] && preferred_vld; 
    3'd6: preferred_avail <= #`TCQ preferred_avail_tc[6] && preferred_vld; 
    3'd7: preferred_avail <= #`TCQ preferred_avail_tc[7] && preferred_vld; 
    endcase
    case (next_tc)
    3'd0: posted_avail <= #`TCQ !llk_rx_ch_posted_available_n[0] && !fifo_np_ok && fifo_pcpl_ok; 
    3'd1: posted_avail <= #`TCQ !llk_rx_ch_posted_available_n[1] && !fifo_np_ok && fifo_pcpl_ok; 
    3'd2: posted_avail <= #`TCQ !llk_rx_ch_posted_available_n[2] && !fifo_np_ok && fifo_pcpl_ok; 
    3'd3: posted_avail <= #`TCQ !llk_rx_ch_posted_available_n[3] && !fifo_np_ok && fifo_pcpl_ok; 
    3'd4: posted_avail <= #`TCQ !llk_rx_ch_posted_available_n[4] && !fifo_np_ok && fifo_pcpl_ok; 
    3'd5: posted_avail <= #`TCQ !llk_rx_ch_posted_available_n[5] && !fifo_np_ok && fifo_pcpl_ok; 
    3'd6: posted_avail <= #`TCQ !llk_rx_ch_posted_available_n[6] && !fifo_np_ok && fifo_pcpl_ok; 
    3'd7: posted_avail <= #`TCQ !llk_rx_ch_posted_available_n[7] && !fifo_np_ok && fifo_pcpl_ok; 
    endcase
   cpl_avail <= #`TCQ  !llk_rx_ch_completion_available_n[0] && !fifo_np_ok && fifo_pcpl_ok;
  end
end
always @* begin
  casex ({llk_rx_preferred_type[1:0],
          llk_rx_ch_posted_available_n[0],
          llk_rx_ch_non_posted_available_n[0],
          llk_rx_ch_completion_available_n[0]})
  5'b00_0xx: preferred_avail_tc[0] = fifo_pcpl_ok;
  5'b01_x0x: preferred_avail_tc[0] = fifo_pcpl_ok && fifo_np_ok;
  5'b1x_xx0: preferred_avail_tc[0] = fifo_pcpl_ok;
  default:   preferred_avail_tc[0] = 0;
  endcase
  for (m=1; m<8; m=m+1) begin
    casex ({llk_rx_preferred_type[m*2],
            llk_rx_ch_posted_available_n[m],
            llk_rx_ch_non_posted_available_n[m]})
    3'b0_0x: preferred_avail_tc[m] = fifo_pcpl_ok;
    3'b1_x0: preferred_avail_tc[m] = fifo_pcpl_ok && fifo_np_ok;
    default: preferred_avail_tc[m] = 0;
    endcase
  end
end
always @(posedge clk) begin
   if (!rst_n) begin
      llk_rx_preferred_type_d <= #`TCQ 2'b0;
      llk_rx_ch_posted_available_n_d            <= #`TCQ 0;
      llk_rx_ch_non_posted_available_n_d        <= #`TCQ 0;
      llk_rx_ch_completion_available_n_d        <= #`TCQ 0;
      preferred_alt <= #`TCQ 0;
   end else begin
      if (~llk_rx_src_last_req_n) begin
         case  ({llk_rx_preferred_type_d[1:0],
                 llk_rx_ch_posted_available_n_d,
                 llk_rx_ch_non_posted_available_n_d,
                 llk_rx_ch_completion_available_n_d,
         fifo_np_ok})
         6'b01_000_0 : preferred_alt <= #`TCQ {rnp_rob, 1'b0};
         6'b01_100_0 : preferred_alt <= #`TCQ 2'b10;
         6'b01_001_0 : preferred_alt <= #`TCQ 2'b00;
         default     : preferred_alt <= #`TCQ 2'd0;
         endcase
      end
   llk_rx_preferred_type_d            <= #`TCQ llk_rx_preferred_type[1:0];
   llk_rx_ch_posted_available_n_d     <= #`TCQ llk_rx_ch_posted_available_n[0];
   llk_rx_ch_non_posted_available_n_d <= #`TCQ llk_rx_ch_non_posted_available_n[0];
   llk_rx_ch_completion_available_n_d <= #`TCQ llk_rx_ch_completion_available_n[0];
   end
end
always @(posedge clk) begin
  if (!rst_n) begin
    rnp_rob         <= #`TCQ 0;
    np_rnp_stall    <= #`TCQ 0;
  end else begin
    if ((llk_rx_preferred_type[1:0] == 2'b01) & ~llk_rx_ch_posted_available_n[0] &
       ~llk_rx_ch_non_posted_available_n[0] & ~llk_rx_ch_completion_available_n[0] & ~fifo_np_ok)
         rnp_rr <= #`TCQ 1;
     else 
         rnp_rr <= #`TCQ 0;
      if (rnp_rr & ~llk_rx_src_last_req_n) 
           rnp_rob <= #`TCQ rnp_rob + 1;
    if ((llk_rx_preferred_type[1:0] == 2'b01) &  
         ~llk_rx_ch_non_posted_available_n[0] & ~fifo_np_ok & trn_rnp_ok_n &
        (~llk_rx_ch_posted_available_n[0] | ~llk_rx_ch_completion_available_n[0])) 
        np_rnp_stall  <= #`TCQ 1'b1;
    else if (~transaction) 
        np_rnp_stall <= #`TCQ 1'b0;
  end
end
always @(llk_rx_src_last_req_n)
  llk_rx_src_last_req_n_dly <= #`TCQ llk_rx_src_last_req_n;
`ifdef SV
  ASSERT_STALL_NP1:        assert property (@(posedge clk)
    !fifo_np_ok   |-> ##2 !fifo_np_req   || fifo_np_ok
                                        ) else $fatal;
  ASSERT_STALL_PCPL1:      assert property (@(posedge clk)
    !fifo_pcpl_ok |-> ##2 !fifo_pcpl_req || fifo_pcpl_ok
                                        ) else $fatal;
  ASSERT_2CYCLE_LLKRXLAST: assert property (@(posedge clk)
    !llk_rx_src_last_req_n |-> ##1 llk_rx_src_last_req_n
                                        ) else $fatal;
  ASSERT_LLKRXREQ_ROSE_WO_LAST: assert property (@(posedge clk)
    !llk_rx_dst_req_n ##1 llk_rx_dst_req_n |-> !llk_rx_src_last_req_n
                                        ) else $fatal;
`else
  always @(posedge clk) begin
    if (!llk_rx_src_last_req_n_q && !llk_rx_src_last_req_n)
       $strobe("FAIL: 2-cycle assertion of Llk Rx Last ");
    if (!llk_rx_dst_req_n_q1 && llk_rx_dst_req_n && llk_rx_src_last_req_n)
       $strobe("FAIL: Deassertion of Llk Rx DstReq w/o Last");
  end
`endif
endmodule 
