`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v2_0_ddr_phy_dqs_found_cal_hr #
  (
   parameter TCQ              = 100,    
   parameter nCK_PER_CLK      = 2,      
   parameter nCL              = 5,      
   parameter AL               = "0",
   parameter nCWL             = 5,      
   parameter DRAM_TYPE        = "DDR3",  
   parameter RANKS            = 1,      
   parameter DQS_CNT_WIDTH    = 3,      
   parameter DQS_WIDTH        = 8,      
   parameter DRAM_WIDTH       = 8,      
   parameter REG_CTRL         = "ON",   
   parameter SIM_CAL_OPTION   = "NONE",  
   parameter NUM_DQSFOUND_CAL = 3,      
   parameter N_CTL_LANES      = 3,      
   parameter HIGHEST_LANE     = 12,     
   parameter HIGHEST_BANK     = 3,      
   parameter BYTE_LANES_B0    = 4'b1111,
   parameter BYTE_LANES_B1    = 4'b0000,
   parameter BYTE_LANES_B2    = 4'b0000,
   parameter BYTE_LANES_B3    = 4'b0000,
   parameter BYTE_LANES_B4    = 4'b0000,
   parameter DATA_CTL_B0      = 4'hc,
   parameter DATA_CTL_B1      = 4'hf,
   parameter DATA_CTL_B2      = 4'hf,
   parameter DATA_CTL_B3      = 4'hf,
   parameter DATA_CTL_B4      = 4'hf
   )
  (
   input                         clk,
   input                         rst,
   input                         dqsfound_retry,
   input                         pi_dqs_found_start,
   input                         detect_pi_found_dqs,
   input                         prech_done,
   input [HIGHEST_LANE-1:0]      pi_dqs_found_lanes,
   output reg [HIGHEST_BANK-1:0] pi_rst_stg1_cal,
   output [5:0]                  rd_data_offset_0,
   output [5:0]                  rd_data_offset_1,
   output [5:0]                  rd_data_offset_2,
   output                        pi_dqs_found_rank_done,
   output                        pi_dqs_found_done,
   output reg                    pi_dqs_found_err,
   output [6*RANKS-1:0]          rd_data_offset_ranks_0,
   output [6*RANKS-1:0]          rd_data_offset_ranks_1,
   output [6*RANKS-1:0]          rd_data_offset_ranks_2,
   output reg                    dqsfound_retry_done,
   output reg                    dqs_found_prech_req,
   output [6*RANKS-1:0]          rd_data_offset_ranks_mc_0,
   output [6*RANKS-1:0]          rd_data_offset_ranks_mc_1,
   output [6*RANKS-1:0]          rd_data_offset_ranks_mc_2,
   input [8:0]                   po_counter_read_val,
   output                        rd_data_offset_cal_done,
   output                        fine_adjust_done,
   output [N_CTL_LANES-1:0]      fine_adjust_lane_cnt,
   output reg                    ck_po_stg2_f_indec,
   output reg                    ck_po_stg2_f_en,
   output [255:0]                dbg_dqs_found_cal
  );
   localparam nAL = (AL == "CL-1") ? nCL - 1 : 0;   
   localparam CWL_M = (REG_CTRL == "ON") ? nCWL + nAL + 1 : nCWL + nAL;
   localparam LATENCY_FACTOR = 13;
   localparam NUM_READS = (SIM_CAL_OPTION == "NONE") ? 7 : 1;
   localparam [19:0] DATA_PRESENT = {(DATA_CTL_B4[3] & BYTE_LANES_B4[3]),
                                     (DATA_CTL_B4[2] & BYTE_LANES_B4[2]),
                                     (DATA_CTL_B4[1] & BYTE_LANES_B4[1]),
                                     (DATA_CTL_B4[0] & BYTE_LANES_B4[0]),
                                     (DATA_CTL_B3[3] & BYTE_LANES_B3[3]),
                                     (DATA_CTL_B3[2] & BYTE_LANES_B3[2]),
                                     (DATA_CTL_B3[1] & BYTE_LANES_B3[1]),
                                     (DATA_CTL_B3[0] & BYTE_LANES_B3[0]),
                                     (DATA_CTL_B2[3] & BYTE_LANES_B2[3]),
                                     (DATA_CTL_B2[2] & BYTE_LANES_B2[2]),
                                     (DATA_CTL_B2[1] & BYTE_LANES_B2[1]),
                                     (DATA_CTL_B2[0] & BYTE_LANES_B2[0]),
                                     (DATA_CTL_B1[3] & BYTE_LANES_B1[3]),
                                     (DATA_CTL_B1[2] & BYTE_LANES_B1[2]),
                                     (DATA_CTL_B1[1] & BYTE_LANES_B1[1]),
                                     (DATA_CTL_B1[0] & BYTE_LANES_B1[0]),
                                     (DATA_CTL_B0[3] & BYTE_LANES_B0[3]),
                                     (DATA_CTL_B0[2] & BYTE_LANES_B0[2]),
                                     (DATA_CTL_B0[1] & BYTE_LANES_B0[1]),
                                     (DATA_CTL_B0[0] & BYTE_LANES_B0[0])};
   localparam FINE_ADJ_IDLE    = 4'h0;
   localparam RST_POSTWAIT     = 4'h1;
   localparam RST_POSTWAIT1    = 4'h2;
   localparam RST_WAIT         = 4'h3;
   localparam FINE_ADJ_INIT    = 4'h4;
   localparam FINE_INC         = 4'h5;
   localparam FINE_INC_WAIT    = 4'h6;
   localparam FINE_INC_PREWAIT = 4'h7;
   localparam DETECT_PREWAIT   = 4'h8;
   localparam DETECT_DQSFOUND  = 4'h9;
   localparam PRECH_WAIT       = 4'hA;
   localparam FINE_DEC         = 4'hB;
   localparam FINE_DEC_WAIT    = 4'hC;
   localparam FINE_DEC_PREWAIT = 4'hD;
   localparam FINAL_WAIT       = 4'hE;
   localparam FINE_ADJ_DONE    = 4'hF;
  integer k,l,m,n,p,q,r,s;
  reg                       dqs_found_start_r;
  reg [6*HIGHEST_BANK-1:0]  rd_byte_data_offset[0:RANKS-1];
  reg                       rank_done_r;
  reg                       rank_done_r1;
  reg                       dqs_found_done_r;
  (* ASYNC_REG = "TRUE" *) reg [HIGHEST_LANE-1:0] pi_dqs_found_lanes_r1;
  (* ASYNC_REG = "TRUE" *) reg [HIGHEST_LANE-1:0] pi_dqs_found_lanes_r2;
  (* ASYNC_REG = "TRUE" *) reg [HIGHEST_LANE-1:0] pi_dqs_found_lanes_r3;
  reg                       init_dqsfound_done_r;
  reg                       init_dqsfound_done_r1;
  reg                       init_dqsfound_done_r2;
  reg                       init_dqsfound_done_r3;
  reg                       init_dqsfound_done_r4;
  reg                       init_dqsfound_done_r5;
  reg [1:0]                 rnk_cnt_r;
  reg [2:0 ]                final_do_index[0:RANKS-1];
  reg [5:0 ]                final_do_max[0:RANKS-1];
  reg [6*HIGHEST_BANK-1:0]  final_data_offset[0:RANKS-1];
  reg [6*HIGHEST_BANK-1:0]  final_data_offset_mc[0:RANKS-1];
  reg [HIGHEST_BANK-1:0]    pi_rst_stg1_cal_r;
  reg [HIGHEST_BANK-1:0]    pi_rst_stg1_cal_r1;
  reg [10*HIGHEST_BANK-1:0] retry_cnt;
  reg                       dqsfound_retry_r1;
  wire [4*HIGHEST_BANK-1:0] pi_dqs_found_lanes_int;
  reg [HIGHEST_BANK-1:0]    pi_dqs_found_all_bank;
  reg [HIGHEST_BANK-1:0]    pi_dqs_found_all_bank_r;
  reg [HIGHEST_BANK-1:0]    pi_dqs_found_any_bank;
  reg [HIGHEST_BANK-1:0]    pi_dqs_found_any_bank_r;
  reg [HIGHEST_BANK-1:0]    pi_dqs_found_err_r;
  reg                       fine_adjust;
  reg [N_CTL_LANES-1:0]     ctl_lane_cnt;
  reg [3:0]                 fine_adj_state_r;
  reg                       fine_adjust_done_r;
  reg                       rst_dqs_find;
  reg                       rst_dqs_find_r1;
  reg                       rst_dqs_find_r2;
  reg [5:0]                 init_dec_cnt;
  reg [5:0]                 dec_cnt;
  reg [5:0]                 inc_cnt;
  reg                       final_dec_done;
  reg                       init_dec_done;
  reg                       first_fail_detect;
  reg                       second_fail_detect;
  reg [5:0]                 first_fail_taps;
  reg [5:0]                 second_fail_taps;
  reg [5:0]                 stable_pass_cnt;
  reg [3:0]                 detect_rd_cnt;
  assign dbg_dqs_found_cal[5:0]  = first_fail_taps;
  assign dbg_dqs_found_cal[11:6] = second_fail_taps;
  assign dbg_dqs_found_cal[12]   = first_fail_detect;
  assign dbg_dqs_found_cal[13]   = second_fail_detect;
  assign dbg_dqs_found_cal[14]   = fine_adjust_done_r;
  assign pi_dqs_found_rank_done    = rank_done_r;
  assign pi_dqs_found_done         = dqs_found_done_r;
  generate
  genvar rnk_cnt;
    if (HIGHEST_BANK == 3) begin 
      for (rnk_cnt = 0; rnk_cnt < RANKS; rnk_cnt = rnk_cnt + 1) begin: rnk_loop
        assign rd_data_offset_ranks_0[6*rnk_cnt+:6] = final_data_offset[rnk_cnt][5:0];
        assign rd_data_offset_ranks_1[6*rnk_cnt+:6] = final_data_offset[rnk_cnt][11:6];
        assign rd_data_offset_ranks_2[6*rnk_cnt+:6] = final_data_offset[rnk_cnt][17:12];
        assign rd_data_offset_ranks_mc_0[6*rnk_cnt+:6] = final_data_offset_mc[rnk_cnt][5:0];
        assign rd_data_offset_ranks_mc_1[6*rnk_cnt+:6] = final_data_offset_mc[rnk_cnt][11:6];
        assign rd_data_offset_ranks_mc_2[6*rnk_cnt+:6] = final_data_offset_mc[rnk_cnt][17:12];
      end
    end else if (HIGHEST_BANK == 2) begin 
      for (rnk_cnt = 0; rnk_cnt < RANKS; rnk_cnt = rnk_cnt + 1) begin: rnk_loop
        assign rd_data_offset_ranks_0[6*rnk_cnt+:6] = final_data_offset[rnk_cnt][5:0];
        assign rd_data_offset_ranks_1[6*rnk_cnt+:6] = final_data_offset[rnk_cnt][11:6];
        assign rd_data_offset_ranks_2[6*rnk_cnt+:6] = 'd0;
        assign rd_data_offset_ranks_mc_0[6*rnk_cnt+:6] = final_data_offset_mc[rnk_cnt][5:0];
        assign rd_data_offset_ranks_mc_1[6*rnk_cnt+:6] = final_data_offset_mc[rnk_cnt][11:6];
        assign rd_data_offset_ranks_mc_2[6*rnk_cnt+:6] = 'd0;
      end
    end else begin 
      for (rnk_cnt = 0; rnk_cnt < RANKS; rnk_cnt = rnk_cnt + 1) begin: rnk_loop
        assign rd_data_offset_ranks_0[6*rnk_cnt+:6] = final_data_offset[rnk_cnt][5:0];
        assign rd_data_offset_ranks_1[6*rnk_cnt+:6] = 'd0;
        assign rd_data_offset_ranks_2[6*rnk_cnt+:6] = 'd0;
        assign rd_data_offset_ranks_mc_0[6*rnk_cnt+:6] = final_data_offset_mc[rnk_cnt][5:0];
        assign rd_data_offset_ranks_mc_1[6*rnk_cnt+:6] = 'd0;
        assign rd_data_offset_ranks_mc_2[6*rnk_cnt+:6] = 'd0;
      end
    end
  endgenerate
  generate
  if (HIGHEST_BANK == 3) begin 
    assign rd_data_offset_0 = (~init_dqsfound_done_r2) ? rd_byte_data_offset[rnk_cnt_r][0+:6] :
                               final_data_offset[rnk_cnt_r][0+:6];
    assign rd_data_offset_1 = (~init_dqsfound_done_r2) ? rd_byte_data_offset[rnk_cnt_r][6+:6] :
                               final_data_offset[rnk_cnt_r][6+:6];
    assign rd_data_offset_2 = (~init_dqsfound_done_r2) ? rd_byte_data_offset[rnk_cnt_r][12+:6] :
                               final_data_offset[rnk_cnt_r][12+:6];
  end else if (HIGHEST_BANK == 2) begin 
    assign rd_data_offset_0 = (~init_dqsfound_done_r2) ? rd_byte_data_offset[rnk_cnt_r][0+:6] :
                               final_data_offset[rnk_cnt_r][0+:6];
    assign rd_data_offset_1 = (~init_dqsfound_done_r2) ? rd_byte_data_offset[rnk_cnt_r][6+:6] :
                               final_data_offset[rnk_cnt_r][6+:6];
    assign rd_data_offset_2 = 'd0;
  end else begin
    assign rd_data_offset_0 = (~init_dqsfound_done_r2) ? rd_byte_data_offset[rnk_cnt_r][0+:6] :
                               final_data_offset[rnk_cnt_r][0+:6];
    assign rd_data_offset_1 = 'd0;
    assign rd_data_offset_2 = 'd0;
  end
  endgenerate
  assign rd_data_offset_cal_done = init_dqsfound_done_r;
  assign fine_adjust_lane_cnt    = ctl_lane_cnt;
  generate
  if ((HIGHEST_LANE == 4) || (HIGHEST_LANE == 8) || (HIGHEST_LANE == 12))
    assign pi_dqs_found_lanes_int = pi_dqs_found_lanes_r3;
  else if ((HIGHEST_LANE == 7) || (HIGHEST_LANE == 11))
    assign pi_dqs_found_lanes_int = {1'b0, pi_dqs_found_lanes_r3};
  else if ((HIGHEST_LANE == 6) || (HIGHEST_LANE == 10))
    assign pi_dqs_found_lanes_int = {2'b00, pi_dqs_found_lanes_r3};
  else if ((HIGHEST_LANE == 5) || (HIGHEST_LANE == 9))
    assign pi_dqs_found_lanes_int = {3'b000, pi_dqs_found_lanes_r3};
  endgenerate
  always @(posedge clk) begin
    if (rst) begin
      for (k = 0; k < HIGHEST_BANK; k = k + 1) begin: rst_pi_dqs_found
        pi_dqs_found_all_bank[k] <= #TCQ 'b0;
        pi_dqs_found_any_bank[k] <= #TCQ 'b0;
      end
    end else if (pi_dqs_found_start) begin
      for (p = 0; p < HIGHEST_BANK; p = p +1) begin: assign_pi_dqs_found
          pi_dqs_found_all_bank[p] <= #TCQ (!DATA_PRESENT[4*p+0] | pi_dqs_found_lanes_int[4*p+0]) &
                                           (!DATA_PRESENT[4*p+1] | pi_dqs_found_lanes_int[4*p+1]) &
                                           (!DATA_PRESENT[4*p+2] | pi_dqs_found_lanes_int[4*p+2]) &
                                           (!DATA_PRESENT[4*p+3] | pi_dqs_found_lanes_int[4*p+3]);
          pi_dqs_found_any_bank[p] <= #TCQ (DATA_PRESENT[4*p+0] & pi_dqs_found_lanes_int[4*p+0]) |
                                           (DATA_PRESENT[4*p+1] & pi_dqs_found_lanes_int[4*p+1]) |
                                           (DATA_PRESENT[4*p+2] & pi_dqs_found_lanes_int[4*p+2]) |
                                           (DATA_PRESENT[4*p+3] & pi_dqs_found_lanes_int[4*p+3]);
      end
    end
  end
  always @(posedge clk) begin
    pi_dqs_found_all_bank_r <= #TCQ pi_dqs_found_all_bank;
    pi_dqs_found_any_bank_r <= #TCQ pi_dqs_found_any_bank;
  end
  always @(posedge clk) begin
    if (rst || (detect_rd_cnt == 'd0))
	  detect_rd_cnt <= #TCQ NUM_READS;
	else if (detect_pi_found_dqs && (detect_rd_cnt > 'd0))
	  detect_rd_cnt <= #TCQ detect_rd_cnt - 1;
  end
   assign fine_adjust_done = fine_adjust_done_r;
   always @(posedge clk) begin
     rst_dqs_find_r1 <= #TCQ rst_dqs_find;
	 rst_dqs_find_r2 <= #TCQ rst_dqs_find_r1;
   end
   always @(posedge clk) begin
      if(rst)begin
        fine_adjust        <= #TCQ 1'b0;
        ctl_lane_cnt       <= #TCQ 'd0;
        fine_adj_state_r   <= #TCQ FINE_ADJ_IDLE;
        fine_adjust_done_r <= #TCQ 1'b0;
        ck_po_stg2_f_indec <= #TCQ 1'b0;
        ck_po_stg2_f_en    <= #TCQ 1'b0;
        rst_dqs_find       <= #TCQ 1'b0;
        init_dec_cnt       <= #TCQ 'd31;
        dec_cnt            <= #TCQ 'd0;
        inc_cnt            <= #TCQ 'd0;
        init_dec_done      <= #TCQ 1'b0;
        final_dec_done     <= #TCQ 1'b0;
        first_fail_detect  <= #TCQ 1'b0;
        second_fail_detect <= #TCQ 1'b0;
        first_fail_taps    <= #TCQ 'd0;
        second_fail_taps   <= #TCQ 'd0;
        stable_pass_cnt    <= #TCQ 'd0;
        dqs_found_prech_req<= #TCQ 1'b0;
      end else begin
        case (fine_adj_state_r)
           FINE_ADJ_IDLE: begin
             if (init_dqsfound_done_r5) begin
               if (SIM_CAL_OPTION == "FAST_CAL") begin
                 fine_adjust      <= #TCQ 1'b1;
                 fine_adj_state_r <= #TCQ FINE_ADJ_DONE;
                 rst_dqs_find     <= #TCQ 1'b0;
               end else begin
                 fine_adjust      <= #TCQ 1'b1;
                 fine_adj_state_r <= #TCQ RST_WAIT;
                 rst_dqs_find     <= #TCQ 1'b1;
               end
             end
           end
           RST_WAIT: begin
             if (~(|pi_dqs_found_any_bank) && rst_dqs_find_r2) begin
               rst_dqs_find     <= #TCQ 1'b0;
               if (|init_dec_cnt)
                 fine_adj_state_r <= #TCQ FINE_DEC_PREWAIT;
               else if (final_dec_done)
                 fine_adj_state_r <= #TCQ FINE_ADJ_DONE;
               else
                 fine_adj_state_r <= #TCQ RST_POSTWAIT;
             end
           end
           RST_POSTWAIT: begin
             fine_adj_state_r <= #TCQ RST_POSTWAIT1;
           end
           RST_POSTWAIT1: begin
             fine_adj_state_r <= #TCQ FINE_ADJ_INIT;
           end
           FINE_ADJ_INIT: begin
               fine_adj_state_r <= #TCQ FINE_INC;
           end
           FINE_INC: begin
             fine_adj_state_r   <= #TCQ FINE_INC_WAIT;
             ck_po_stg2_f_indec <= #TCQ 1'b1;
             ck_po_stg2_f_en    <= #TCQ 1'b1;
             if (ctl_lane_cnt == N_CTL_LANES-1)
               inc_cnt          <= #TCQ inc_cnt + 1;
           end
           FINE_INC_WAIT: begin
             ck_po_stg2_f_indec <= #TCQ 1'b0;
             ck_po_stg2_f_en    <= #TCQ 1'b0;
             if (ctl_lane_cnt != N_CTL_LANES-1) begin
               ctl_lane_cnt     <= #TCQ ctl_lane_cnt + 1;
               fine_adj_state_r <= #TCQ FINE_INC_PREWAIT;
             end else if (ctl_lane_cnt == N_CTL_LANES-1) begin
               ctl_lane_cnt     <= #TCQ 'd0;
               fine_adj_state_r <= #TCQ DETECT_PREWAIT;
             end
           end
           FINE_INC_PREWAIT: begin
             fine_adj_state_r <= #TCQ FINE_INC;
           end
           DETECT_PREWAIT: begin
             if (detect_pi_found_dqs && (detect_rd_cnt == 'd1))
               fine_adj_state_r <= #TCQ DETECT_DQSFOUND;
			 else
			   fine_adj_state_r <= #TCQ DETECT_PREWAIT;
           end
           DETECT_DQSFOUND: begin
             if (detect_pi_found_dqs && ~(&pi_dqs_found_all_bank)) begin
               stable_pass_cnt     <= #TCQ 'd0;
               if (~first_fail_detect && (inc_cnt == 'd63)) begin
                 first_fail_detect <= #TCQ 1'b1;
                 first_fail_taps   <= #TCQ inc_cnt;
                 fine_adj_state_r  <= #TCQ FINE_DEC;
                 dec_cnt           <= #TCQ 'd32;
               end else if (~first_fail_detect && (inc_cnt > 'd30) && (stable_pass_cnt > 'd29)) begin
                 first_fail_detect <= #TCQ 1'b1;
                 first_fail_taps   <= #TCQ inc_cnt;
                 fine_adj_state_r  <= #TCQ FINE_DEC;
                 dec_cnt           <= #TCQ (inc_cnt>>1) + 1;				 
			   end else if (~first_fail_detect || (first_fail_detect && (stable_pass_cnt < 'd30) && (inc_cnt <= 'd32))) begin
                 first_fail_detect <= #TCQ 1'b1;
                 first_fail_taps   <= #TCQ inc_cnt;
                 rst_dqs_find      <= #TCQ 1'b1;
                 if ((inc_cnt == 'd12) || (inc_cnt == 'd24)) begin
                   dqs_found_prech_req <= #TCQ 1'b1;
                   fine_adj_state_r    <= #TCQ PRECH_WAIT;
                 end else
                 fine_adj_state_r  <= #TCQ RST_WAIT;
               end else if (first_fail_detect && (inc_cnt > 'd32) && (inc_cnt < 'd63) && (stable_pass_cnt < 'd30)) begin
                 first_fail_detect <= #TCQ 1'b1;
                 first_fail_taps   <= #TCQ inc_cnt;
                 rst_dqs_find      <= #TCQ 1'b1;
                 if ((inc_cnt == 'd36) || (inc_cnt == 'd48) || (inc_cnt == 'd60)) begin
                   dqs_found_prech_req <= #TCQ 1'b1;
                   fine_adj_state_r    <= #TCQ PRECH_WAIT;
                 end else
                   fine_adj_state_r  <= #TCQ RST_WAIT;
               end else if (first_fail_detect && (inc_cnt == 'd63)) begin
                 if (stable_pass_cnt < 'd30) begin
                   first_fail_detect <= #TCQ 1'b1;
                   first_fail_taps   <= #TCQ inc_cnt;
                   fine_adj_state_r  <= #TCQ FINE_DEC;
                   dec_cnt           <= #TCQ 'd32;
                 end else begin
                   fine_adj_state_r  <= #TCQ FINE_DEC;
                   dec_cnt           <= #TCQ ((inc_cnt - first_fail_taps)>>1);
                 end
               end else begin
                 second_fail_detect <= #TCQ 1'b1;
                 second_fail_taps   <= #TCQ inc_cnt;
                 dec_cnt            <= #TCQ ((inc_cnt - first_fail_taps)>>1);
                 fine_adj_state_r   <= #TCQ FINE_DEC;
               end
             end else if (detect_pi_found_dqs && (&pi_dqs_found_all_bank)) begin
               stable_pass_cnt    <= #TCQ stable_pass_cnt + 1;
               if ((inc_cnt == 'd12) || (inc_cnt == 'd24) || (inc_cnt == 'd36) || 
                   (inc_cnt == 'd48) || (inc_cnt == 'd60)) begin
                 dqs_found_prech_req <= #TCQ 1'b1;
                 fine_adj_state_r    <= #TCQ PRECH_WAIT;
               end else if (inc_cnt < 'd63) begin
                 rst_dqs_find     <= #TCQ 1'b1;
                 fine_adj_state_r <= #TCQ RST_WAIT;
               end else begin
                 fine_adj_state_r <= #TCQ FINE_DEC;
                 if (~first_fail_detect || (first_fail_taps > 'd33))
                   dec_cnt <= #TCQ 'd32;
                 else
                   dec_cnt <= #TCQ ((inc_cnt - first_fail_taps)>>1);
               end
             end
           end
           PRECH_WAIT: begin
             if (prech_done) begin
               dqs_found_prech_req <= #TCQ 1'b0;
               rst_dqs_find        <= #TCQ 1'b1;
               fine_adj_state_r    <= #TCQ RST_WAIT;
             end
           end
           FINE_DEC: begin
             fine_adj_state_r   <= #TCQ FINE_DEC_WAIT;
             ck_po_stg2_f_indec <= #TCQ 1'b0;
             ck_po_stg2_f_en    <= #TCQ 1'b1;
             if ((ctl_lane_cnt == N_CTL_LANES-1) && (init_dec_cnt > 'd0))
               init_dec_cnt     <= #TCQ init_dec_cnt - 1;
             else if ((ctl_lane_cnt == N_CTL_LANES-1) && (dec_cnt > 'd0))
               dec_cnt          <= #TCQ dec_cnt - 1;
           end
           FINE_DEC_WAIT: begin
             ck_po_stg2_f_indec <= #TCQ 1'b0;
             ck_po_stg2_f_en    <= #TCQ 1'b0;
             if (ctl_lane_cnt != N_CTL_LANES-1) begin
               ctl_lane_cnt     <= #TCQ ctl_lane_cnt + 1;
               fine_adj_state_r <= #TCQ FINE_DEC_PREWAIT;
             end else if (ctl_lane_cnt == N_CTL_LANES-1) begin
               ctl_lane_cnt     <= #TCQ 'd0;
               if ((dec_cnt > 'd0) || (init_dec_cnt > 'd0))
                 fine_adj_state_r <= #TCQ FINE_DEC_PREWAIT;
               else begin
                 fine_adj_state_r <= #TCQ FINAL_WAIT;
                 if ((init_dec_cnt == 'd0) && ~init_dec_done)
                   init_dec_done <= #TCQ 1'b1;
                 else
                   final_dec_done   <= #TCQ 1'b1;
               end
             end
           end
           FINE_DEC_PREWAIT: begin
             fine_adj_state_r <= #TCQ FINE_DEC;
           end
           FINAL_WAIT: begin
             rst_dqs_find     <= #TCQ 1'b1;
             fine_adj_state_r <= #TCQ RST_WAIT;
           end
           FINE_ADJ_DONE: begin
             if (&pi_dqs_found_all_bank) begin
               fine_adjust_done_r <= #TCQ 1'b1;
               rst_dqs_find       <= #TCQ 1'b0;
               fine_adj_state_r   <= #TCQ FINE_ADJ_DONE;
             end
           end
        endcase
      end
   end
  always@(posedge clk)
    dqs_found_start_r <= #TCQ pi_dqs_found_start;
  always @(posedge clk) begin
    if (rst)
      rnk_cnt_r <= #TCQ 2'b00;
    else if (init_dqsfound_done_r)
      rnk_cnt_r <= #TCQ rnk_cnt_r;
    else if (rank_done_r)
      rnk_cnt_r <= #TCQ rnk_cnt_r + 1;
  end
    always @(posedge clk) begin
    if (rst || (|pi_rst_stg1_cal_r))
      init_dqsfound_done_r  <= #TCQ 1'b0;
    else if (&pi_dqs_found_all_bank) begin
      if (rnk_cnt_r == RANKS-1)
        init_dqsfound_done_r  <= #TCQ 1'b1;
      else
        init_dqsfound_done_r  <= #TCQ 1'b0;
    end
  end
  always @(posedge clk) begin
    if (rst  ||
       (init_dqsfound_done_r && (rnk_cnt_r == RANKS-1)))
      rank_done_r       <= #TCQ 1'b0;
    else if (&pi_dqs_found_all_bank && ~(&pi_dqs_found_all_bank_r))
      rank_done_r <= #TCQ 1'b1;
    else
      rank_done_r       <= #TCQ 1'b0;
  end
  always @(posedge clk) begin
    pi_dqs_found_lanes_r1   <= #TCQ pi_dqs_found_lanes;
    pi_dqs_found_lanes_r2   <= #TCQ pi_dqs_found_lanes_r1;
    pi_dqs_found_lanes_r3   <= #TCQ pi_dqs_found_lanes_r2;
    init_dqsfound_done_r1   <= #TCQ init_dqsfound_done_r;
    init_dqsfound_done_r2   <= #TCQ init_dqsfound_done_r1;
    init_dqsfound_done_r3   <= #TCQ init_dqsfound_done_r2;
    init_dqsfound_done_r4   <= #TCQ init_dqsfound_done_r3;
    init_dqsfound_done_r5   <= #TCQ init_dqsfound_done_r4;
    rank_done_r1            <= #TCQ rank_done_r;
    dqsfound_retry_r1       <= #TCQ dqsfound_retry;
  end
  always @(posedge clk) begin
    if (rst)
      dqs_found_done_r <= #TCQ 1'b0;
    else if (&pi_dqs_found_all_bank && (rnk_cnt_r == RANKS-1) && init_dqsfound_done_r1 &&
             (fine_adj_state_r == FINE_ADJ_DONE))
      dqs_found_done_r <= #TCQ 1'b1;
    else
      dqs_found_done_r <= #TCQ 1'b0;
  end
  generate
    if (HIGHEST_BANK == 3) begin 
      always @(posedge clk) begin
        if (rst || pi_rst_stg1_cal_r1[0] || fine_adjust)
          pi_rst_stg1_cal_r[0] <= #TCQ 1'b0;
        else if ((pi_dqs_found_start && ~dqs_found_start_r) ||
                 (pi_dqs_found_any_bank_r[0] && ~pi_dqs_found_all_bank[0]) ||
                 (rd_byte_data_offset[rnk_cnt_r][0+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_rst_stg1_cal_r[0] <= #TCQ 1'b1;
      end
      always @(posedge clk) begin
        if (rst || pi_rst_stg1_cal_r1[1] || fine_adjust)
          pi_rst_stg1_cal_r[1] <= #TCQ 1'b0;
        else if ((pi_dqs_found_start && ~dqs_found_start_r) ||
                 (pi_dqs_found_any_bank_r[1] && ~pi_dqs_found_all_bank[1]) ||
                 (rd_byte_data_offset[rnk_cnt_r][6+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_rst_stg1_cal_r[1] <= #TCQ 1'b1;
      end
      always @(posedge clk) begin
        if (rst || pi_rst_stg1_cal_r1[2] || fine_adjust)
          pi_rst_stg1_cal_r[2] <= #TCQ 1'b0;
        else if ((pi_dqs_found_start && ~dqs_found_start_r) ||
                 (pi_dqs_found_any_bank_r[2] && ~pi_dqs_found_all_bank[2]) ||
                 (rd_byte_data_offset[rnk_cnt_r][12+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_rst_stg1_cal_r[2] <= #TCQ 1'b1;
      end
      always @(posedge clk) begin
        if (rst || fine_adjust)
          pi_rst_stg1_cal_r1[0]  <= #TCQ 1'b0;
        else if (pi_rst_stg1_cal_r[0])
          pi_rst_stg1_cal_r1[0]  <= #TCQ 1'b1;
        else if (~pi_dqs_found_any_bank_r[0] && ~pi_dqs_found_all_bank[0])
          pi_rst_stg1_cal_r1[0]  <= #TCQ 1'b0;
      end
      always @(posedge clk) begin
        if (rst || fine_adjust)
          pi_rst_stg1_cal_r1[1]  <= #TCQ 1'b0;
        else if (pi_rst_stg1_cal_r[1])
          pi_rst_stg1_cal_r1[1]  <= #TCQ 1'b1;
        else if (~pi_dqs_found_any_bank_r[1] && ~pi_dqs_found_all_bank[1])
          pi_rst_stg1_cal_r1[1]  <= #TCQ 1'b0;
      end
      always @(posedge clk) begin
        if (rst || fine_adjust)
          pi_rst_stg1_cal_r1[2]  <= #TCQ 1'b0;
        else if (pi_rst_stg1_cal_r[2])
          pi_rst_stg1_cal_r1[2]  <= #TCQ 1'b1;
        else if (~pi_dqs_found_any_bank_r[2] && ~pi_dqs_found_all_bank[2])
          pi_rst_stg1_cal_r1[2]  <= #TCQ 1'b0;
      end
      always @(posedge clk) begin
        if (rst || rank_done_r)
          retry_cnt[0+:10] <= #TCQ 'b0;
        else if ((rd_byte_data_offset[rnk_cnt_r][0+:6] > (nCL + nAL + LATENCY_FACTOR - 1)) &&
                 ~pi_dqs_found_all_bank[0])
          retry_cnt[0+:10] <= #TCQ retry_cnt[0+:10] + 1;
        else
          retry_cnt[0+:10] <= #TCQ retry_cnt[0+:10];
      end
	  always @(posedge clk) begin
        if (rst || rank_done_r)
          retry_cnt[10+:10] <= #TCQ 'b0;
        else if ((rd_byte_data_offset[rnk_cnt_r][6+:6] > (nCL + nAL + LATENCY_FACTOR - 1)) &&
                 ~pi_dqs_found_all_bank[1])
          retry_cnt[10+:10] <= #TCQ retry_cnt[10+:10] + 1;
        else
          retry_cnt[10+:10] <= #TCQ retry_cnt[10+:10];
      end
	  always @(posedge clk) begin
        if (rst || rank_done_r)
          retry_cnt[20+:10] <= #TCQ 'b0;
        else if ((rd_byte_data_offset[rnk_cnt_r][12+:6] > (nCL + nAL + LATENCY_FACTOR - 1)) &&
                 ~pi_dqs_found_all_bank[2])
          retry_cnt[20+:10] <= #TCQ retry_cnt[20+:10] + 1;
        else
          retry_cnt[20+:10] <= #TCQ retry_cnt[20+:10];
      end
      always @(posedge clk) begin
        if (rst)
          pi_dqs_found_err_r[0] <= #TCQ 1'b0;
        else if (~pi_dqs_found_all_bank[0] && (retry_cnt[0+:10] == NUM_DQSFOUND_CAL) &&
                (rd_byte_data_offset[rnk_cnt_r][0+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_dqs_found_err_r[0] <= #TCQ 1'b1;
      end
      always @(posedge clk) begin
        if (rst)
          pi_dqs_found_err_r[1] <= #TCQ 1'b0;
        else if (~pi_dqs_found_all_bank[1] && (retry_cnt[10+:10] == NUM_DQSFOUND_CAL) &&
                (rd_byte_data_offset[rnk_cnt_r][6+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_dqs_found_err_r[1] <= #TCQ 1'b1;
      end
      always @(posedge clk) begin
        if (rst)
          pi_dqs_found_err_r[2] <= #TCQ 1'b0;
        else if (~pi_dqs_found_all_bank[2] && (retry_cnt[20+:10] == NUM_DQSFOUND_CAL) &&
                (rd_byte_data_offset[rnk_cnt_r][12+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_dqs_found_err_r[2] <= #TCQ 1'b1;
      end
      always @(posedge clk) begin
        if (rst) begin
          for (q = 0; q < RANKS; q = q + 1) begin: three_bank0_rst_loop
            rd_byte_data_offset[q][0+:6] <= #TCQ nCL + nAL - 2;
          end
        end else if ((rank_done_r1 && ~init_dqsfound_done_r) ||
		             (rd_byte_data_offset[rnk_cnt_r][0+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
            rd_byte_data_offset[rnk_cnt_r][0+:6] <= #TCQ nCL + nAL - 2;
        else if (dqs_found_start_r && ~pi_dqs_found_all_bank[0] &&
                 (detect_pi_found_dqs && (detect_rd_cnt == 'd1)) && ~init_dqsfound_done_r && ~fine_adjust)
          rd_byte_data_offset[rnk_cnt_r][0+:6]
          <= #TCQ rd_byte_data_offset[rnk_cnt_r][0+:6] + 1;
      end
      always @(posedge clk) begin
        if (rst) begin
          for (r = 0; r < RANKS; r = r + 1) begin: three_bank1_rst_loop
            rd_byte_data_offset[r][6+:6] <= #TCQ nCL + nAL - 2;
          end
        end else if ((rank_done_r1 && ~init_dqsfound_done_r) ||
		             (rd_byte_data_offset[rnk_cnt_r][6+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
            rd_byte_data_offset[rnk_cnt_r][6+:6] <= #TCQ nCL + nAL - 2;
        else if (dqs_found_start_r && ~pi_dqs_found_all_bank[1] &&
                 (detect_pi_found_dqs && (detect_rd_cnt == 'd1)) && ~init_dqsfound_done_r && ~fine_adjust)
          rd_byte_data_offset[rnk_cnt_r][6+:6]
          <= #TCQ rd_byte_data_offset[rnk_cnt_r][6+:6] + 1;
      end
      always @(posedge clk) begin
        if (rst) begin
          for (s = 0; s < RANKS; s = s + 1) begin: three_bank2_rst_loop
            rd_byte_data_offset[s][12+:6] <= #TCQ nCL + nAL - 2;
          end
        end else if ((rank_done_r1 && ~init_dqsfound_done_r) ||
		             (rd_byte_data_offset[rnk_cnt_r][12+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
            rd_byte_data_offset[rnk_cnt_r][12+:6] <= #TCQ nCL + nAL - 2;
        else if (dqs_found_start_r && ~pi_dqs_found_all_bank[2] &&
                 (detect_pi_found_dqs && (detect_rd_cnt == 'd1)) && ~init_dqsfound_done_r && ~fine_adjust)
          rd_byte_data_offset[rnk_cnt_r][12+:6]
          <= #TCQ rd_byte_data_offset[rnk_cnt_r][12+:6] + 1;
      end
    end else if (HIGHEST_BANK == 2) begin  
      always @(posedge clk) begin
        if (rst || pi_rst_stg1_cal_r1[0] || fine_adjust)
          pi_rst_stg1_cal_r[0] <= #TCQ 1'b0;
        else if ((pi_dqs_found_start && ~dqs_found_start_r) ||
                 (pi_dqs_found_any_bank_r[0] && ~pi_dqs_found_all_bank[0]) ||
                 (rd_byte_data_offset[rnk_cnt_r][0+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_rst_stg1_cal_r[0] <= #TCQ 1'b1;
      end
      always @(posedge clk) begin
        if (rst || pi_rst_stg1_cal_r1[1] || fine_adjust)
          pi_rst_stg1_cal_r[1] <= #TCQ 1'b0;
        else if ((pi_dqs_found_start && ~dqs_found_start_r) ||
                 (pi_dqs_found_any_bank_r[1] && ~pi_dqs_found_all_bank[1]) ||
                 (rd_byte_data_offset[rnk_cnt_r][6+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_rst_stg1_cal_r[1] <= #TCQ 1'b1;
      end
      always @(posedge clk) begin
        if (rst || fine_adjust)
          pi_rst_stg1_cal_r1[0]  <= #TCQ 1'b0;
        else if (pi_rst_stg1_cal_r[0])
          pi_rst_stg1_cal_r1[0]  <= #TCQ 1'b1;
        else if (~pi_dqs_found_any_bank_r[0] && ~pi_dqs_found_all_bank[0])
          pi_rst_stg1_cal_r1[0]  <= #TCQ 1'b0;
      end
      always @(posedge clk) begin
        if (rst || fine_adjust)
          pi_rst_stg1_cal_r1[1]  <= #TCQ 1'b0;
        else if (pi_rst_stg1_cal_r[1])
          pi_rst_stg1_cal_r1[1]  <= #TCQ 1'b1;
        else if (~pi_dqs_found_any_bank_r[1] && ~pi_dqs_found_all_bank[1])
          pi_rst_stg1_cal_r1[1]  <= #TCQ 1'b0;
      end
      always @(posedge clk) begin
        if (rst || rank_done_r)
          retry_cnt[0+:10] <= #TCQ 'b0;
        else if ((rd_byte_data_offset[rnk_cnt_r][0+:6] > (nCL + nAL + LATENCY_FACTOR - 1)) &&
                 ~pi_dqs_found_all_bank[0])
          retry_cnt[0+:10] <= #TCQ retry_cnt[0+:10] + 1;
        else
          retry_cnt[0+:10] <= #TCQ retry_cnt[0+:10];
      end
	  always @(posedge clk) begin
        if (rst || rank_done_r)
          retry_cnt[10+:10] <= #TCQ 'b0;
        else if ((rd_byte_data_offset[rnk_cnt_r][6+:6] > (nCL + nAL + LATENCY_FACTOR - 1)) &&
                 ~pi_dqs_found_all_bank[1])
          retry_cnt[10+:10] <= #TCQ retry_cnt[10+:10] + 1;
        else
          retry_cnt[10+:10] <= #TCQ retry_cnt[10+:10];
      end
      always @(posedge clk) begin
        if (rst)
          pi_dqs_found_err_r[0] <= #TCQ 1'b0;
        else if (~pi_dqs_found_all_bank[0] && (retry_cnt[0+:10] == NUM_DQSFOUND_CAL) &&
                (rd_byte_data_offset[rnk_cnt_r][0+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_dqs_found_err_r[0] <= #TCQ 1'b1;
      end
      always @(posedge clk) begin
        if (rst)
          pi_dqs_found_err_r[1] <= #TCQ 1'b0;
        else if (~pi_dqs_found_all_bank[1] && (retry_cnt[10+:10] == NUM_DQSFOUND_CAL) &&
                (rd_byte_data_offset[rnk_cnt_r][6+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_dqs_found_err_r[1] <= #TCQ 1'b1;
      end
      always @(posedge clk) begin
        if (rst) begin
          for (q = 0; q < RANKS; q = q + 1) begin: two_bank0_rst_loop
            rd_byte_data_offset[q][0+:6] <= #TCQ nCL + nAL - 2;
          end
        end else if ((rank_done_r1 && ~init_dqsfound_done_r) ||
		             (rd_byte_data_offset[rnk_cnt_r][0+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
            rd_byte_data_offset[rnk_cnt_r][0+:6] <= #TCQ nCL + nAL - 2;
        else if (dqs_found_start_r && ~pi_dqs_found_all_bank[0] &&
                 (detect_pi_found_dqs && (detect_rd_cnt == 'd1)) && ~init_dqsfound_done_r && ~fine_adjust)
          rd_byte_data_offset[rnk_cnt_r][0+:6]
          <= #TCQ rd_byte_data_offset[rnk_cnt_r][0+:6] + 1;
      end
      always @(posedge clk) begin
        if (rst) begin
          for (r = 0; r < RANKS; r = r + 1) begin: two_bank1_rst_loop
            rd_byte_data_offset[r][6+:6] <= #TCQ nCL + nAL - 2;
          end
        end else if ((rank_done_r1 && ~init_dqsfound_done_r) ||
		             (rd_byte_data_offset[rnk_cnt_r][6+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
            rd_byte_data_offset[rnk_cnt_r][6+:6] <= #TCQ nCL + nAL - 2;
        else if (dqs_found_start_r && ~pi_dqs_found_all_bank[1] &&
                 (detect_pi_found_dqs && (detect_rd_cnt == 'd1)) && ~init_dqsfound_done_r && ~fine_adjust)
          rd_byte_data_offset[rnk_cnt_r][6+:6]
          <= #TCQ rd_byte_data_offset[rnk_cnt_r][6+:6] + 1;
      end
    end else begin 
      always @(posedge clk) begin
        if (rst) begin
          for (l = 0; l < RANKS; l = l + 1) begin: bank_rst_loop
            rd_byte_data_offset[l] <= #TCQ nCL + nAL - 2;
          end
        end else if ((rank_done_r1 && ~init_dqsfound_done_r) ||
		             (rd_byte_data_offset[rnk_cnt_r] > (nCL + nAL + LATENCY_FACTOR - 1)))
          rd_byte_data_offset[rnk_cnt_r] <= #TCQ nCL + nAL - 2;
        else if (dqs_found_start_r && ~pi_dqs_found_all_bank[0] &&
                 (detect_pi_found_dqs && (detect_rd_cnt == 'd1)) && ~init_dqsfound_done_r && ~fine_adjust)
          rd_byte_data_offset[rnk_cnt_r]
          <= #TCQ rd_byte_data_offset[rnk_cnt_r] + 1;
      end
       always @(posedge clk) begin
        if (rst || pi_rst_stg1_cal_r1[0] || fine_adjust)
          pi_rst_stg1_cal_r[0] <= #TCQ 1'b0;
        else if ((pi_dqs_found_start && ~dqs_found_start_r) ||
                 (pi_dqs_found_any_bank_r[0] && ~pi_dqs_found_all_bank[0]) ||
                 (rd_byte_data_offset[rnk_cnt_r][0+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_rst_stg1_cal_r[0] <= #TCQ 1'b1;
      end
      always @(posedge clk) begin
        if (rst || fine_adjust)
          pi_rst_stg1_cal_r1[0]  <= #TCQ 1'b0;
        else if (pi_rst_stg1_cal_r[0])
          pi_rst_stg1_cal_r1[0]  <= #TCQ 1'b1;
        else if (~pi_dqs_found_any_bank_r[0] && ~pi_dqs_found_all_bank[0])
          pi_rst_stg1_cal_r1[0]  <= #TCQ 1'b0;
      end
      always @(posedge clk) begin
        if (rst || rank_done_r)
          retry_cnt[0+:10] <= #TCQ 'b0;
        else if ((rd_byte_data_offset[rnk_cnt_r][0+:6] > (nCL + nAL + LATENCY_FACTOR - 1)) &&
                 ~pi_dqs_found_all_bank[0])
          retry_cnt[0+:10] <= #TCQ retry_cnt[0+:10] + 1;
        else
          retry_cnt[0+:10] <= #TCQ retry_cnt[0+:10];
      end
       always @(posedge clk) begin
        if (rst)
          pi_dqs_found_err_r[0] <= #TCQ 1'b0;
        else if (~pi_dqs_found_all_bank[0] && (retry_cnt[0+:10] == NUM_DQSFOUND_CAL) &&
                (rd_byte_data_offset[rnk_cnt_r][0+:6] > (nCL + nAL + LATENCY_FACTOR - 1)))
          pi_dqs_found_err_r[0] <= #TCQ 1'b1;
      end
    end
  endgenerate
  always @(posedge clk) begin
    if (rst)
      pi_rst_stg1_cal <= #TCQ {HIGHEST_BANK{1'b0}};
    else if (rst_dqs_find)
      pi_rst_stg1_cal <= #TCQ {HIGHEST_BANK{1'b1}};
    else
      pi_rst_stg1_cal <= #TCQ pi_rst_stg1_cal_r;
  end
  generate
  genvar i;
  genvar j;
    for (i = 0; i < RANKS; i = i + 1) begin: rank_final_loop
       reg [5:0] final_do_cand [RANKS-1:0];
       if (HIGHEST_BANK == 3) begin
         always @(*) begin
            case (final_do_index[i])
	      3'b000:  final_do_cand[i]  = final_data_offset[i][5:0];
	      3'b001:  final_do_cand[i]  = final_data_offset[i][11:6];
	      3'b010:  final_do_cand[i]  = final_data_offset[i][17:12];
	      default: final_do_cand[i]  = 'd0;
	    endcase
         end
       end else if (HIGHEST_BANK == 2) begin
         always @(*) begin
            case (final_do_index[i])
	      3'b000:  final_do_cand[i]  = final_data_offset[i][5:0];
	      3'b001:  final_do_cand[i]  = final_data_offset[i][11:6];
	      3'b010:  final_do_cand[i]  = 'd0;
	      default: final_do_cand[i]  = 'd0;
	    endcase
         end
       end else begin
         always @(*) begin
            case (final_do_index[i])
	      3'b000:  final_do_cand[i]  = final_data_offset[i][5:0];
	      3'b001:  final_do_cand[i]  = 'd0;
	      3'b010:  final_do_cand[i]  = 'd0;
	      default: final_do_cand[i]  = 'd0;
	    endcase
         end
       end
       always @(posedge clk)  begin
          if (rst) 
	      final_do_max[i] <= #TCQ 0;
	  else begin
	     final_do_max[i] <= #TCQ final_do_max[i]; 
             case (final_do_index[i])
	        3'b000: if ( | DATA_PRESENT[3:0]) 
	               if (final_do_max[i] < final_do_cand[i])
	                 if (CWL_M % 2) 
		            final_do_max[i] <= #TCQ final_do_cand[i] - 1;
		         else
		            final_do_max[i] <= #TCQ final_do_cand[i];
	        3'b001: if ( | DATA_PRESENT[7:4]) 
	               if (final_do_max[i] < final_do_cand[i])
		         if (CWL_M % 2) 
		            final_do_max[i] <= #TCQ final_do_cand[i] - 1;
		         else
		            final_do_max[i] <= #TCQ final_do_cand[i];
	        3'b010: if ( | DATA_PRESENT[11:8]) 
	               if (final_do_max[i] < final_do_cand[i])
		         if (CWL_M % 2) 
		            final_do_max[i] <= #TCQ final_do_cand[i] - 1;
		         else
		            final_do_max[i] <= #TCQ final_do_cand[i];
                default:
	               final_do_max[i] <= #TCQ final_do_max[i];
	      endcase
	   end
	end
	always @(posedge clk) 
	    if (rst) begin
	       final_do_index[i] <= #TCQ 0;
	    end
	    else begin
	       final_do_index[i] <= #TCQ final_do_index[i] + 1;
	    end
      for (j = 0; j < HIGHEST_BANK; j = j + 1) begin: bank_final_loop
        always @(posedge clk) begin
          if (rst) begin
            final_data_offset[i][6*j+:6] <= #TCQ 'b0;
	  end
          else begin
          if (init_dqsfound_done_r && ~init_dqsfound_done_r1) begin
	    if ( DATA_PRESENT [ j*4+:4] != 0) begin 
               final_data_offset[i][6*j+:6] <= #TCQ rd_byte_data_offset[i][6*j+:6];
               if (CWL_M % 2) 
                 final_data_offset_mc[i][6*j+:6] <= #TCQ rd_byte_data_offset[i][6*j+:6] - 1;
               else 
                 final_data_offset_mc[i][6*j+:6] <= #TCQ rd_byte_data_offset[i][6*j+:6];
            end 
	  end
          else if (init_dqsfound_done_r5 ) begin
	       if ( DATA_PRESENT [ j*4+:4] == 0) begin 
                  final_data_offset[i][6*j+:6] <= #TCQ final_do_max[i];
                  final_data_offset_mc[i][6*j+:6] <= #TCQ final_do_max[i];
               end	
          end
	  end
        end
      end
    end
  endgenerate
  always @(posedge clk) begin
    pi_dqs_found_err    <= #TCQ |pi_dqs_found_err_r;
  end
endmodule
