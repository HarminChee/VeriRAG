`timescale 1ps/1ps
`timescale 1ps/1ps
module phy_wrlvl #
  (
   parameter TCQ = 100,
   parameter DQS_CNT_WIDTH     = 3,
   parameter DQ_WIDTH          = 64,
   parameter DQS_WIDTH         = 2,
   parameter DRAM_WIDTH        = 8,
   parameter RANKS             = 1,
   parameter nCK_PER_CLK       = 4,
   parameter CLK_PERIOD        = 4,
   parameter SIM_CAL_OPTION    = "NONE"
   )
  (
   input                        clk,
   input                        rst,
   input                        phy_ctl_ready,
   input                        wr_level_start,
   input                        wl_sm_start,
   input [(DQ_WIDTH)-1:0]       rd_data_rise0,
   output reg                   dqs_po_dec_done,
   output                       phy_ctl_rdy_dly,
   output reg                   wr_level_done,
   output                       wrlvl_rank_done,
   output                       done_dqs_tap_inc,
   output [DQS_CNT_WIDTH:0]     po_stg2_wl_cnt,
   output reg                   dqs_po_stg2_f_incdec,
   output reg                   dqs_po_en_stg2_f,
   output reg                   dqs_wl_po_stg2_c_incdec,
   output reg                   dqs_wl_po_en_stg2_c,
   output reg                   po_counter_read_en,
   input [8:0]                  po_counter_read_val,
   output reg                   wrlvl_err,
   output reg [3*DQS_WIDTH-1:0] wl_po_coarse_cnt,
   output reg [6*DQS_WIDTH-1:0] wl_po_fine_cnt,
   output [5:0]                 dbg_wl_tap_cnt,
   output                       dbg_wl_edge_detect_valid,
   output [(DQS_WIDTH)-1:0]     dbg_rd_data_edge_detect,
   output [DQS_CNT_WIDTH:0]     dbg_dqs_count,
   output [4:0]                 dbg_wl_state
   );
   localparam WL_IDLE            = 5'h0;
   localparam WL_INIT            = 5'h1;
   localparam WL_FINE_INC        = 5'h2;
   localparam WL_WAIT            = 5'h3;
   localparam WL_EDGE_CHECK      = 5'h4;
   localparam WL_DQS_CHECK       = 5'h5;
   localparam WL_DQS_CNT         = 5'h6;
   localparam WL_2RANK_TAP_DEC   = 5'h7;
   localparam WL_2RANK_DQS_CNT   = 5'h8;
   localparam WL_FINE_DEC        = 5'h9;
   localparam WL_FINE_DEC_WAIT   = 5'hA;
   localparam WL_CORSE_INC       = 5'hB;
   localparam WL_CORSE_INC_WAIT  = 5'hC;
   localparam WL_CORSE_INC_WAIT1 = 5'hD;
   localparam WL_CORSE_INC_WAIT2 = 5'hE;
   localparam WL_CORSE_DEC       = 5'hF;
   localparam WL_CORSE_DEC_WAIT  = 5'h10;
   localparam WL_FINE_INC_WAIT   = 5'h11;
   localparam WL_2RANK_FINAL_TAP = 5'h12;
  localparam  COARSE_TAPS = (CLK_PERIOD/nCK_PER_CLK <= 2500) ? 4 : 7;
   integer     i, j, k, l, p, q;
   reg                   phy_ctl_ready_r1;
   reg                   phy_ctl_ready_r2;
   reg                   phy_ctl_ready_r3;
   reg                   phy_ctl_ready_r4;
   reg                   phy_ctl_ready_r5;
   reg                   phy_ctl_ready_r6;
   reg [DQS_CNT_WIDTH:0] dqs_count_r;
   reg [1:0]             rank_cnt_r;
   reg [DQS_WIDTH-1:0]   rd_data_rise_wl_r;
   reg [DQS_WIDTH-1:0]   rd_data_previous_r;
   reg [DQS_WIDTH-1:0]   rd_data_edge_detect_r;
   reg                   wr_level_done_r;
   reg                   wrlvl_rank_done_r;
   reg                   wr_level_start_r;
   reg [4:0]             wl_state_r, wl_state_r1;
   reg                   wl_edge_detect_valid_r;
   reg [5:0]             wl_tap_count_r;
   reg [5:0]             fine_dec_cnt;
   reg [6*DQS_WIDTH-1:0] fine_inc;
   reg [3*DQS_WIDTH-1:0] corse_dec;
   reg [3*DQS_WIDTH-1:0] corse_inc;
   reg                   dq_cnt_inc;
   reg [2:0]             stable_cnt;
   reg                   flag_ck_negedge;
   reg                   flag_init;
   reg [3*DQS_WIDTH-1:0] corse_cnt;
   reg [3*DQS_WIDTH-1:0] wl_corse_cnt[0:RANKS-1];
   reg [3*DQS_WIDTH-1:0] final_coarse_tap;
   reg [6*DQS_WIDTH-1:0] add_smallest;
   reg [6*DQS_WIDTH-1:0] add_largest;
   reg                   wr_level_done_r1;
   reg                   wr_level_done_r2;
   reg                   wr_level_done_r3;
   reg                   wr_level_done_r4;
   reg                   wr_level_done_r5;
   reg [6*DQS_WIDTH-1:0] wl_dqs_tap_count_r[0:RANKS-1];
   reg [6*DQS_WIDTH-1:0] smallest;
   reg [6*DQS_WIDTH-1:0] largest;
   reg [6*DQS_WIDTH-1:0] final_val;
   reg [5:0]             po_dec_cnt[0:DQS_WIDTH-1];
   reg                   done_dqs_dec;
   reg [8:0]             po_rdval_cnt;
   reg                   po_cnt_dec;
   reg                   dual_rnk_dec;
   wire [DQS_CNT_WIDTH+2:0] dqs_count_w;
   assign dbg_wl_edge_detect_valid = wl_edge_detect_valid_r;
   assign dbg_rd_data_edge_detect  = rd_data_edge_detect_r;
   assign dbg_wl_tap_cnt = wl_tap_count_r;
   assign dbg_dqs_count = dqs_count_r;
   assign dbg_wl_state = wl_state_r;
   assign po_stg2_wl_cnt = dqs_count_r;
   assign wrlvl_rank_done = wrlvl_rank_done_r;
   assign done_dqs_tap_inc = done_dqs_dec;
   assign phy_ctl_rdy_dly = phy_ctl_ready_r6;
   always @(posedge clk) begin
     phy_ctl_ready_r1 <= #TCQ phy_ctl_ready;
     phy_ctl_ready_r2 <= #TCQ phy_ctl_ready_r1;
     phy_ctl_ready_r3 <= #TCQ phy_ctl_ready_r2;
     phy_ctl_ready_r4 <= #TCQ phy_ctl_ready_r3;
     phy_ctl_ready_r5 <= #TCQ phy_ctl_ready_r4;
     phy_ctl_ready_r6 <= #TCQ phy_ctl_ready_r5;   
     wr_level_done    <= #TCQ done_dqs_dec;
   end
   always @(posedge clk) begin
     if (rst)
       po_counter_read_en <= #TCQ 1'b0;
     else if (phy_ctl_ready_r1 && ~phy_ctl_ready_r2)
       po_counter_read_en <= #TCQ 1'b1;
     else
       po_counter_read_en <= #TCQ 1'b0;
   end
   always @(posedge clk) begin
     if (rst) begin
       po_rdval_cnt    <= #TCQ 'd0;
     end else if (phy_ctl_ready_r5 && ~phy_ctl_ready_r6) begin
       po_rdval_cnt    <= #TCQ po_counter_read_val;
     end else if (po_rdval_cnt > 'd0) begin
       if (po_cnt_dec)
         po_rdval_cnt  <= #TCQ po_rdval_cnt - 1;
       else            
         po_rdval_cnt  <= #TCQ po_rdval_cnt;
     end else if (po_rdval_cnt == 'd0) begin
       po_rdval_cnt    <= #TCQ po_rdval_cnt;
     end
   end
   always @(posedge clk) begin
     if (rst) begin
       po_cnt_dec      <= #TCQ 1'b0;
     end else if (phy_ctl_ready_r6 && (po_rdval_cnt > 'd0)) begin
       po_cnt_dec      <= #TCQ ~po_cnt_dec;
     end else if (po_rdval_cnt == 'd0) begin
       po_cnt_dec      <= #TCQ 1'b0;
     end
   end
   always @(posedge clk) begin
     if (rst) begin
       dqs_po_dec_done <= #TCQ 1'b0;
     end else if (((po_cnt_dec == 'd1) && (po_rdval_cnt == 'd1)) ||
                  (phy_ctl_ready_r6 && (po_rdval_cnt == 'd0))) begin
       dqs_po_dec_done <= #TCQ 1'b1;
     end
   end
   always @(posedge clk) begin
     wr_level_done_r1 <= #TCQ wr_level_done_r;
     wr_level_done_r2 <= #TCQ wr_level_done_r1;
     wr_level_done_r3 <= #TCQ wr_level_done_r2;
     wr_level_done_r4 <= #TCQ wr_level_done_r3;
     wr_level_done_r5 <= #TCQ wr_level_done_r4;
     wl_po_coarse_cnt <= #TCQ final_coarse_tap;
     for (l = 0; l < DQS_WIDTH; l = l + 1) begin 
       if (RANKS == 1)
         wl_po_fine_cnt[6*l+:6] <= #TCQ smallest[6*l+:6];
       else 
         wl_po_fine_cnt[6*l+:6] <= #TCQ final_val[6*l+:6];
     end
   end
   generate
   if (RANKS == 2) begin: dual_rank
     always @(posedge clk) begin
       if (rst)
         done_dqs_dec <= #TCQ 1'b0;
       else if (SIM_CAL_OPTION == "FAST_CAL")
         done_dqs_dec <= #TCQ wr_level_done_r;
       else if (wr_level_done_r5 && (wl_state_r == WL_IDLE))
         done_dqs_dec <= #TCQ 1'b1;
     end
   end else begin: single_rank
     always @(posedge clk) begin
       if (rst)
         done_dqs_dec <= #TCQ 1'b0;
       else if (wr_level_done_r3)
         done_dqs_dec <= #TCQ 1'b1;
     end
   end
   endgenerate
   always @(posedge clk) begin
     if (rst) begin
       for (k = 0; k < RANKS; k = k + 1) begin: rst_wl_dqs_tap_count_loop
         wl_dqs_tap_count_r[k] <= #TCQ 'b0;
         wl_corse_cnt[k] <= #TCQ 'b0;
       end
     end else if ((wl_state_r == WL_DQS_CNT) | (wl_state_r == WL_WAIT) |
                  (wl_state_r == WL_2RANK_TAP_DEC)) begin
         wl_dqs_tap_count_r[rank_cnt_r][(6*dqs_count_r)+:6]
           <= #TCQ wl_tap_count_r;
         wl_corse_cnt[rank_cnt_r][3*dqs_count_r+:3]
           <= #TCQ corse_cnt[3*dqs_count_r+:3];
     end else if ((SIM_CAL_OPTION == "FAST_CAL") & (wl_state_r == WL_DQS_CHECK)) begin
       for (p = 0; p < RANKS; p = p +1) begin: dqs_tap_rank_cnt   
         for(q = 0; q < DQS_WIDTH; q = q +1) begin: dqs_tap_dqs_cnt
           wl_dqs_tap_count_r[p][(6*q)+:6] <= #TCQ wl_tap_count_r;
           wl_corse_cnt[p][3*q+:3] <= #TCQ corse_cnt[2:0];
         end
       end
     end
   end
   generate
   genvar cnt;
   if (RANKS == 2) begin 
     for(cnt = 0; cnt < DQS_WIDTH; cnt = cnt +1) begin: coarse_dqs_cnt
       always @(posedge clk) begin
         if (rst) begin
           add_smallest[6*cnt+:6]    <= #TCQ 'd0;
           add_largest[6*cnt+:6]     <= #TCQ 'd0;
           final_coarse_tap[3*cnt+:3]<= #TCQ 'd0;
         end else if (wr_level_done_r1 & ~wr_level_done_r2) begin
           if (wl_corse_cnt[0][3*cnt+:3] == wl_corse_cnt[1][3*cnt+:3]) begin
             final_coarse_tap[3*cnt+:3]<= #TCQ wl_corse_cnt[1][3*cnt+:3];
             add_smallest[6*cnt+:6]    <= #TCQ 'd0;
             add_largest[6*cnt+:6]     <= #TCQ 'd0;
           end else if (wl_corse_cnt[0][3*cnt+:3] < wl_corse_cnt[1][3*cnt+:3]) begin
             final_coarse_tap[3*cnt+:3]<= #TCQ wl_corse_cnt[1][3*cnt+:3] - 1;
             if (wl_corse_cnt[0][3*cnt+:3] > 3'b000)
               add_largest[6*cnt+:6] <= #TCQ 'd38;
             else
               add_largest[6*cnt+:6] <= #TCQ 'd34;
           end else if (wl_corse_cnt[0][3*cnt+:3] > wl_corse_cnt[1][3*cnt+:3]) begin
             final_coarse_tap[3*cnt+:3]<= #TCQ wl_corse_cnt[1][3*cnt+:3];
             if (wl_corse_cnt[1][3*cnt+:3] > 3'b000)
               add_smallest[6*cnt+:6] <= #TCQ 'd38;
             else
               add_smallest[6*cnt+:6] <= #TCQ 'd34;
           end
         end
       end
     end
   end else begin
     always @(posedge clk) begin
       final_coarse_tap <= #TCQ wl_corse_cnt[0];
       add_smallest     <= #TCQ 'd0;
       add_largest      <= #TCQ 'd0;
     end
   end
   endgenerate
   always @(posedge clk) begin
     if (rst) begin
       smallest <= #TCQ 'b0;
       largest  <= #TCQ 'b0;
     end else if ((wl_state_r == WL_DQS_CNT) | 
                  (wl_state_r == WL_2RANK_TAP_DEC)) begin
       smallest[6*dqs_count_r+:6] 
       <= #TCQ wl_dqs_tap_count_r[0][6*dqs_count_r+:6];
       largest[6*dqs_count_r+:6] 
        <= #TCQ wl_dqs_tap_count_r[RANKS-1][6*dqs_count_r+:6];
     end else if ((SIM_CAL_OPTION == "FAST_CAL") & 
                  wr_level_done_r1 & ~wr_level_done_r2) begin
       for(i = 0; i < DQS_WIDTH; i = i +1) begin: smallest_dqs
         smallest[6*i+:6] 
         <= #TCQ wl_dqs_tap_count_r[0][6*i+:6];
         largest[6*i+:6] 
         <= #TCQ wl_dqs_tap_count_r[0][6*i+:6];
       end
     end
   end
    genvar wr_i;
    generate
      for (wr_i = 0; wr_i < DQS_WIDTH; wr_i = wr_i +1) begin: gen_final_tap
       always @(posedge clk) begin
         if (rst)
           final_val[6*wr_i+:6] <= #TCQ 'b0;
         else if (wr_level_done_r2 && ~wr_level_done_r3) begin
           if ((smallest[6*wr_i+:6] + add_smallest[6*wr_i+:6]) < 
               (largest[6*wr_i+:6] + add_largest[6*wr_i+:6]))
             final_val[6*wr_i+:6] <= #TCQ 
                     ((smallest[6*wr_i+:6] + add_smallest[6*wr_i+:6]) + 
                     (((largest[6*wr_i+:6] + add_largest[6*wr_i+:6]) -
                      (smallest[6*wr_i+:6] + add_smallest[6*wr_i+:6]))/2));
           else if ((smallest[6*wr_i+:6] + add_smallest[6*wr_i+:6]) >
               (largest[6*wr_i+:6] + add_largest[6*wr_i+:6]))
             final_val[6*wr_i+:6] <= #TCQ 
                     ((largest[6*wr_i+:6] + add_largest[6*wr_i+:6]) + 
                     (((smallest[6*wr_i+:6] + add_smallest[6*wr_i+:6]) -
                      (largest[6*wr_i+:6] + add_largest[6*wr_i+:6]))/2));
           else if ((smallest[6*wr_i+:6] + add_smallest[6*wr_i+:6]) ==
               (largest[6*wr_i+:6] + add_largest[6*wr_i+:6]))
             final_val[6*wr_i+:6] <= #TCQ 
                     (largest[6*wr_i+:6] + add_largest[6*wr_i+:6]);
         end
       end
      end
    endgenerate
   always @(posedge clk) begin
     if (rst) begin
       dqs_po_stg2_f_incdec   <= #TCQ 1'b0;
       dqs_po_en_stg2_f       <= #TCQ 1'b0;
     end else if (po_cnt_dec || (wl_state_r == WL_FINE_DEC)) begin
       dqs_po_stg2_f_incdec <= #TCQ 1'b0;
       dqs_po_en_stg2_f     <= #TCQ 1'b1;
     end else if (wl_state_r == WL_FINE_INC) begin
       dqs_po_stg2_f_incdec <= #TCQ 1'b1;
       dqs_po_en_stg2_f     <= #TCQ 1'b1;
     end else begin
       dqs_po_stg2_f_incdec <= #TCQ 1'b0;
       dqs_po_en_stg2_f     <= #TCQ 1'b0; 
     end
   end
   always @(posedge clk) begin
     if (rst) begin
       dqs_wl_po_stg2_c_incdec   <= #TCQ 1'b0;
       dqs_wl_po_en_stg2_c       <= #TCQ 1'b0;
     end else if (wl_state_r == WL_CORSE_INC) begin
       dqs_wl_po_stg2_c_incdec <= #TCQ 1'b1;
       dqs_wl_po_en_stg2_c     <= #TCQ 1'b1;
     end else if (wl_state_r == WL_CORSE_DEC) begin
       dqs_wl_po_stg2_c_incdec <= #TCQ 1'b0;
       dqs_wl_po_en_stg2_c     <= #TCQ 1'b1;
     end else begin
       dqs_wl_po_stg2_c_incdec <= #TCQ 1'b0;
       dqs_wl_po_en_stg2_c     <= #TCQ 1'b0; 
     end
   end
genvar rd_i;
generate
  for(rd_i = 0; rd_i < DQS_WIDTH; rd_i = rd_i +1)begin: gen_rd
   always @(posedge clk)
     rd_data_rise_wl_r[rd_i] <=
     #TCQ |rd_data_rise0[(rd_i*DRAM_WIDTH)+DRAM_WIDTH-1:rd_i*DRAM_WIDTH];
  end
endgenerate
   always @(posedge clk)begin
     if ((wl_state_r == WL_INIT) || (wl_state_r == WL_CORSE_INC_WAIT2) ||
         (wl_state_r == WL_FINE_DEC) || (wl_state_r == WL_FINE_DEC_WAIT) ||
         (wl_state_r == WL_CORSE_INC) || (wl_state_r == WL_CORSE_INC_WAIT) || 
         (wl_state_r == WL_CORSE_INC_WAIT1) || 
         ((wl_state_r == WL_EDGE_CHECK) & (wl_edge_detect_valid_r)))
       rd_data_previous_r         <= #TCQ rd_data_rise_wl_r;
   end
   always @(posedge clk)begin
      if (rst | (wl_state_r == WL_DQS_CNT) |
         (wl_state_r == WL_2RANK_TAP_DEC) |
         (wl_state_r == WL_FINE_DEC))
        stable_cnt <= #TCQ 3'd0;
      else if ((wl_tap_count_r > 6'd0) & 
         (wl_state_r == WL_EDGE_CHECK) & (wl_edge_detect_valid_r)) begin
        if ((rd_data_previous_r[dqs_count_r] == rd_data_rise_wl_r[dqs_count_r])
           & (stable_cnt < 3'd7))
          stable_cnt <= #TCQ stable_cnt + 1;
        else if (rd_data_previous_r[dqs_count_r] != rd_data_rise_wl_r[dqs_count_r])
          stable_cnt <= #TCQ 3'd0;
      end
   end
   always @(posedge clk)begin
      if (rst | (wl_state_r == WL_DQS_CNT) |
         (wl_state_r == WL_DQS_CHECK) | wr_level_done_r)
        flag_ck_negedge <= #TCQ 1'd0;
      else if (rd_data_previous_r[dqs_count_r] && ((stable_cnt > 3'd0) |
              (wl_state_r == WL_FINE_DEC) | (wl_state_r == WL_FINE_DEC_WAIT)))
        flag_ck_negedge <= #TCQ 1'd1;
      else if (~rd_data_previous_r[dqs_count_r] && (stable_cnt == 3'd7))
        flag_ck_negedge <= #TCQ 1'd0;
   end
   always @(posedge clk) begin
     if (rst)
       flag_init <= #TCQ 1'b1;
     else if (wl_state_r == WL_INIT)
       flag_init <= #TCQ 1'b0;
   end
   always @(posedge clk)begin
     if (rst | flag_ck_negedge | flag_init | (wl_tap_count_r < 'd1))
       rd_data_edge_detect_r     <= #TCQ {DQS_WIDTH{1'b0}};
     else if (rd_data_edge_detect_r[dqs_count_r] == 1'b1) begin
       if ((wl_state_r == WL_FINE_DEC) || (wl_state_r == WL_FINE_DEC_WAIT) ||
           (wl_state_r == WL_CORSE_INC) || (wl_state_r == WL_CORSE_INC_WAIT) ||
           (wl_state_r == WL_CORSE_INC_WAIT1) || (wl_state_r == WL_CORSE_INC_WAIT2))
         rd_data_edge_detect_r <= #TCQ {DQS_WIDTH{1'b0}};
       else
         rd_data_edge_detect_r <= #TCQ rd_data_edge_detect_r;
     end else if (rd_data_previous_r[dqs_count_r] && (stable_cnt < 3'd7))
       rd_data_edge_detect_r     <= #TCQ {DQS_WIDTH{1'b0}};
     else
       rd_data_edge_detect_r <= #TCQ (~rd_data_previous_r &
                                       rd_data_rise_wl_r);
   end
   always@(posedge clk) begin
     wr_level_start_r <= #TCQ wr_level_start;
   end
   assign dqs_count_w = {2'b00, dqs_count_r};
   always @(posedge clk) begin
      if(rst)begin
         wrlvl_err              <= #TCQ 1'b0;
         wr_level_done_r        <= #TCQ 1'b0;
         wrlvl_rank_done_r      <= #TCQ 1'b0;
         dqs_count_r            <= #TCQ {DQS_CNT_WIDTH+1{1'b0}};
         dq_cnt_inc             <= #TCQ 1'b1;
         rank_cnt_r             <= #TCQ 2'b00;
         wl_state_r             <= #TCQ WL_IDLE;
         wl_state_r1            <= #TCQ WL_IDLE;
         wl_edge_detect_valid_r <= #TCQ 1'b0;
         wl_tap_count_r         <= #TCQ 6'b0;
         fine_dec_cnt           <= #TCQ 6'b0;
         fine_inc               <= #TCQ {6*DQS_WIDTH{1'b0}};
         corse_dec              <= #TCQ {3*DQS_WIDTH{1'b0}};
         corse_inc              <= #TCQ {3*DQS_WIDTH{1'b0}};
         corse_cnt              <= #TCQ {3*DQS_WIDTH{1'b0}};
         dual_rnk_dec           <= #TCQ 1'b0;
      end else begin
         wl_state_r1            <= #TCQ wl_state_r;
         case (wl_state_r)
           WL_IDLE: begin
              wrlvl_rank_done_r <= #TCQ 1'd0;
              if(!wr_level_done_r & wr_level_start_r & wl_sm_start)
                wl_state_r <= #TCQ WL_INIT;
           end
           WL_INIT: begin
              wl_edge_detect_valid_r <= #TCQ 1'b0;
              wrlvl_rank_done_r      <= #TCQ 1'd0;
              if(wl_sm_start)
                 wl_state_r <= #TCQ WL_EDGE_CHECK; 
           end
           WL_FINE_INC: begin
              wl_edge_detect_valid_r <= #TCQ 1'b0;
              if (wr_level_done_r5) begin
                wl_tap_count_r <= #TCQ 'd0;
                wl_state_r <= #TCQ WL_FINE_INC_WAIT;
                if (fine_inc[(dqs_count_w << 2 + dqs_count_w << 1)+:6] > 'd0)
                  fine_inc[(dqs_count_w << 2 + dqs_count_w << 1)+:6] <= 
                   #TCQ fine_inc[(dqs_count_w << 2 + dqs_count_w << 1)+:6] - 1;
                else
                  fine_inc[(dqs_count_w << 2 + dqs_count_w << 1)+:6] <= 
                   #TCQ fine_inc[(dqs_count_w << 2 + dqs_count_w << 1)+:6];
              end else begin
                wl_state_r <= #TCQ WL_WAIT;
                wl_tap_count_r <= #TCQ wl_tap_count_r + 1'b1;
              end
           end
           WL_FINE_INC_WAIT: begin
              if (fine_inc[(dqs_count_w << 2 + dqs_count_w << 1)+:6] > 'd0)
                wl_state_r   <= #TCQ WL_FINE_INC;
              else if (dqs_count_r == (DQS_WIDTH-1))
                wl_state_r   <= #TCQ WL_IDLE;
              else begin
                wl_state_r   <= #TCQ WL_2RANK_FINAL_TAP;
                dqs_count_r  <= #TCQ dqs_count_r + 1;
              end
           end
           WL_FINE_DEC: begin
              wl_edge_detect_valid_r <= #TCQ 1'b0;
              wl_tap_count_r <= #TCQ 'd0;
              wl_state_r   <= #TCQ WL_FINE_DEC_WAIT;
              if (fine_dec_cnt > 6'd0)
                fine_dec_cnt <= #TCQ fine_dec_cnt - 1;
              else
                fine_dec_cnt <= #TCQ fine_dec_cnt;
           end
           WL_FINE_DEC_WAIT: begin
              if (fine_dec_cnt > 6'd0)
                wl_state_r   <= #TCQ WL_FINE_DEC;
              else if (dual_rnk_dec) begin 
                if (corse_dec[3*dqs_count_r+:3] > 'd0)
                  wl_state_r <= #TCQ WL_CORSE_DEC;
                else
                  wl_state_r <= #TCQ WL_2RANK_DQS_CNT;
              end else
                  wl_state_r <= #TCQ WL_CORSE_INC;
           end
           WL_CORSE_DEC: begin
              wl_state_r   <= #TCQ WL_CORSE_DEC_WAIT;
              dual_rnk_dec <= #TCQ 1'b0;
              if (corse_dec[3*dqs_count_r+:3] > 6'd0)
                corse_dec[3*dqs_count_r+:3] <= 
                #TCQ corse_dec[3*dqs_count_r+:3] - 1;
              else
                corse_dec <= #TCQ corse_dec;
           end
           WL_CORSE_DEC_WAIT: begin
              if (corse_dec[3*dqs_count_r+:3] > 6'd0)
                wl_state_r <= #TCQ WL_CORSE_DEC;
              else
                wl_state_r <= #TCQ WL_2RANK_DQS_CNT;
           end
           WL_CORSE_INC: begin
              wl_state_r <= #TCQ WL_CORSE_INC_WAIT;
              if (~wr_level_done_r5)
                corse_cnt[3*dqs_count_r+:3]  <= 
                 #TCQ corse_cnt[3*dqs_count_r+:3] + 1;
              else if (corse_inc[3*dqs_count_r+:3] > 'd0)
                corse_inc[3*dqs_count_r+:3] <= 
                 #TCQ corse_inc[3*dqs_count_r+:3] - 1;
           end
           WL_CORSE_INC_WAIT: begin
              if (~wr_level_done_r5 && wl_sm_start)
                wl_state_r <= #TCQ WL_CORSE_INC_WAIT1;
              else if (wr_level_done_r5) begin
                if (corse_inc[3*dqs_count_r+:3] > 'd0)
                  wl_state_r   <= #TCQ WL_CORSE_INC;
                else if (fine_inc[(dqs_count_w << 2 + dqs_count_w << 1)+:6] > 'd0)
                  wl_state_r   <= #TCQ WL_FINE_INC;
                else if (dqs_count_r == (DQS_WIDTH-1))
                  wl_state_r   <= #TCQ WL_IDLE;
                else begin
                  wl_state_r   <= #TCQ WL_2RANK_FINAL_TAP;
                  dqs_count_r  <= #TCQ dqs_count_r + 1;
                end
              end
           end
           WL_CORSE_INC_WAIT1: begin
              if (wl_sm_start)
                wl_state_r <= #TCQ WL_CORSE_INC_WAIT2;
           end
           WL_CORSE_INC_WAIT2: begin
             if (wl_sm_start)
                wl_state_r <= #TCQ WL_WAIT;
           end
           WL_WAIT: begin
              if (wl_sm_start)
              wl_state_r <= #TCQ WL_EDGE_CHECK;
           end
           WL_EDGE_CHECK: begin 
              if (wl_edge_detect_valid_r == 1'b0) begin
                wl_state_r <= #TCQ WL_WAIT;
                wl_edge_detect_valid_r <= #TCQ 1'b1;
              end
              else if(rd_data_edge_detect_r[dqs_count_r] &&
                      wl_edge_detect_valid_r)
                begin
                  wl_tap_count_r <= #TCQ wl_tap_count_r;
                  if ((SIM_CAL_OPTION == "FAST_CAL") || (RANKS < 2))
                    wl_state_r <= #TCQ WL_DQS_CNT;
                  else
                    wl_state_r <= #TCQ WL_2RANK_TAP_DEC;
                end
              else if (wl_tap_count_r > 6'd40) begin
                if (corse_cnt[3*dqs_count_r+:3] < COARSE_TAPS) begin
                  wl_state_r   <= #TCQ WL_FINE_DEC;
                  fine_dec_cnt <= #TCQ wl_tap_count_r;
                end else
                  wrlvl_err <= #TCQ 1'b1;
              end else
                wl_state_r <= #TCQ WL_FINE_INC;
           end
           WL_2RANK_TAP_DEC: begin
              wl_state_r    <= #TCQ WL_FINE_DEC;
              fine_dec_cnt  <= #TCQ wl_tap_count_r;
              corse_dec <= #TCQ corse_cnt;
              wl_edge_detect_valid_r <= #TCQ 1'b0;
              dual_rnk_dec <= #TCQ 1'b1;
           end
           WL_DQS_CNT: begin
              if ((SIM_CAL_OPTION == "FAST_CAL") ||
                  (dqs_count_r == (DQS_WIDTH-1))) begin
                dqs_count_r <= #TCQ dqs_count_r;
                dq_cnt_inc  <= #TCQ 1'b0;
              end else begin
                dqs_count_r <= #TCQ dqs_count_r + 1'b1;
                dq_cnt_inc  <= #TCQ 1'b1;
              end
              wl_state_r <= #TCQ WL_DQS_CHECK;
              wl_edge_detect_valid_r <= #TCQ 1'b0;
           end
           WL_2RANK_DQS_CNT: begin
              if ((SIM_CAL_OPTION == "FAST_CAL") ||
                 (dqs_count_r == (DQS_WIDTH-1))) begin
                dqs_count_r <= #TCQ dqs_count_r;
                dq_cnt_inc  <= #TCQ 1'b0;
              end else begin
                dqs_count_r <= #TCQ dqs_count_r + 1'b1;
                dq_cnt_inc  <= #TCQ 1'b1;
              end
              wl_state_r <= #TCQ WL_DQS_CHECK;
              wl_edge_detect_valid_r <= #TCQ 1'b0;
              dual_rnk_dec <= #TCQ 1'b0;
           end   
           WL_DQS_CHECK: begin 
              wl_tap_count_r <= #TCQ 5'b0;
              if (dq_cnt_inc == 1'b0)begin
                wrlvl_rank_done_r <= #TCQ 1'd1;
                corse_cnt         <= #TCQ {3*DQS_WIDTH{1'b0}};
                if ((SIM_CAL_OPTION == "FAST_CAL") || (RANKS < 2)) begin
                  wl_state_r  <= #TCQ WL_IDLE;
                  dqs_count_r <= #TCQ 5'd0;
                end else if (rank_cnt_r == RANKS-1) begin
                  wl_state_r  <= #TCQ WL_IDLE;
                  dqs_count_r <= #TCQ dqs_count_r;
                end else begin
                  wl_state_r  <= #TCQ WL_INIT;
                  dqs_count_r <= #TCQ 5'd0;
                end
                if ((SIM_CAL_OPTION == "FAST_CAL") ||
                    (rank_cnt_r == RANKS-1)) begin
                  wr_level_done_r <= #TCQ 1'd1;
                  rank_cnt_r      <= #TCQ 2'b00;
                end else begin
                  wr_level_done_r <= #TCQ 1'd0;
                  rank_cnt_r      <= #TCQ rank_cnt_r + 1'b1;
                end
              end else
                wl_state_r  <= #TCQ WL_INIT;
           end
           WL_2RANK_FINAL_TAP: begin
              if (wr_level_done_r4 && ~wr_level_done_r5) begin
                corse_inc      <= #TCQ final_coarse_tap;
                fine_inc       <= #TCQ final_val;
                dqs_count_r    <= #TCQ 5'd0;
              end else if (wr_level_done_r5) begin
                if (corse_inc[3*dqs_count_r+:3] > 'd0)
                  wl_state_r   <= #TCQ WL_CORSE_INC;
                else if (fine_inc[(dqs_count_w << 2 + dqs_count_w << 1)+:6] > 'd0)
                  wl_state_r   <= #TCQ WL_FINE_INC;
              end  
           end
        endcase
     end
   end 
endmodule
