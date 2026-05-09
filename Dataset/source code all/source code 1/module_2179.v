`timescale 1ps/1ps
`timescale 1ps/1ps
module phy_dqs_found_cal #
  (
   parameter TCQ             = 100,    
   parameter nCK_PER_CLK     = 2,      
   parameter nCL             = 5,      
   parameter AL              = "0",
   parameter nCWL            = 5,      
   parameter RANKS           = 1,      
   parameter DQS_CNT_WIDTH   = 3,      
   parameter DQS_WIDTH       = 8,      
   parameter DRAM_WIDTH      = 8,      
   parameter REG_CTRL         = "ON",   
   parameter NUM_DQSFOUND_CAL = 3       
   )
  (
   input                        clk,
   input                        rst,
   input                        dqsfound_retry,
   input                        pi_dqs_found_start,
   input                        detect_pi_found_dqs,
   input                        pi_found_dqs,
   input                        pi_dqs_found_all,
   output reg                   pi_rst_stg1_cal,
   output [5:0]                 rd_data_offset,
   output                       pi_dqs_found_rank_done,
   output                       pi_dqs_found_done,
   output reg                   pi_dqs_found_err,
   output [6*RANKS-1:0]         rd_data_offset_ranks,
   output reg                   dqsfound_retry_done,
   output [6*RANKS-1:0]         rd_data_offset_ranks_mc
  );
   localparam nAL = (AL == "CL-1") ? nCL - 1 : 0;   
   localparam CWL_M = (REG_CTRL == "ON") ? nCWL + nAL + 1 : nCWL + nAL;
  integer l;
  reg                     dqs_found_start_r;
  reg [5:0]               rd_byte_data_offset[0:RANKS-1];
  reg                     rank_done_r;
  reg                     rank_done_r1;
  reg                     dqs_found_done_r;
  reg                     init_dqsfound_done_r;
  reg                     init_dqsfound_done_r1;
  reg                     init_dqsfound_done_r2;
  reg                     init_dqsfound_done_r3;
  reg [1:0]               rnk_cnt_r;
  reg [5:0]               final_data_offset[0:RANKS-1];
  reg [5:0]               final_data_offset_mc[0:RANKS-1];
  reg                     reg_pi_found_dqs;
  reg                     reg_pi_found_dqs_all;
  reg                     reg_pi_found_dqs_all_r1;
  reg                     pi_rst_stg1_cal_r;
  reg [2:0]               calib_cnt;
  reg                     dqsfound_retry_r1;
  assign pi_dqs_found_rank_done    = rank_done_r;
  assign pi_dqs_found_done         = dqs_found_done_r;
  generate
  genvar rnk_cnt;
    for (rnk_cnt = 0; rnk_cnt < RANKS; rnk_cnt = rnk_cnt + 1) begin: rnk_loop
      assign rd_data_offset_ranks[6*rnk_cnt+:6] = final_data_offset[rnk_cnt];
      assign rd_data_offset_ranks_mc[6*rnk_cnt+:6] = final_data_offset_mc[rnk_cnt];
    end
  endgenerate
  assign rd_data_offset = (~init_dqsfound_done_r2) ? rd_byte_data_offset[rnk_cnt_r] :
                          final_data_offset[rnk_cnt_r];
  always @(posedge clk) begin
    if (rst || pi_rst_stg1_cal_r) begin
      reg_pi_found_dqs     <= #TCQ 'b0;
      reg_pi_found_dqs_all <= #TCQ 1'b0;
    end else if (pi_dqs_found_start) begin
      reg_pi_found_dqs     <= #TCQ pi_found_dqs;
      reg_pi_found_dqs_all <= #TCQ pi_dqs_found_all;
    end
  end
  always@(posedge clk)
    dqs_found_start_r <= #TCQ pi_dqs_found_start;
  always @(posedge clk) begin
    if (rst || rank_done_r)
      calib_cnt <= #TCQ 'b0;
    else if ((rd_byte_data_offset[rnk_cnt_r] < (nCL + nAL -1)) &&
             (calib_cnt < NUM_DQSFOUND_CAL))
      calib_cnt <= #TCQ calib_cnt + 1;
    else
      calib_cnt <= #TCQ calib_cnt;
  end      
  always @(posedge clk) begin
    if (rst || dqsfound_retry) begin
      for (l = 0; l < RANKS; l = l + 1) begin: rst_rd_data_offset_loop
        rd_byte_data_offset[l] <= #TCQ nCL + nAL + 13;
      end
    end else if ((rank_done_r1 && ~init_dqsfound_done_r) ||
       (rd_byte_data_offset[rnk_cnt_r] < (nCL + nAL -1))) begin
          rd_byte_data_offset[rnk_cnt_r] <= #TCQ nCL + nAL + 13;
    end else if (dqs_found_start_r && ~reg_pi_found_dqs_all &&
             detect_pi_found_dqs && ~init_dqsfound_done_r)
      rd_byte_data_offset[rnk_cnt_r] 
      <= #TCQ rd_byte_data_offset[rnk_cnt_r] - 1;
  end
  always @(posedge clk) begin
    if (rst)
      rnk_cnt_r <= #TCQ 2'b00;
    else if (init_dqsfound_done_r)
      rnk_cnt_r <= #TCQ rnk_cnt_r;
    else if (rank_done_r)
      rnk_cnt_r <= #TCQ rnk_cnt_r + 1;
  end
  always @(posedge clk) begin
    if (rst || pi_rst_stg1_cal_r)
      init_dqsfound_done_r  <= #TCQ 1'b0;
    else if (reg_pi_found_dqs_all && ~reg_pi_found_dqs_all_r1) begin
      if (rnk_cnt_r == RANKS-1)
        init_dqsfound_done_r  <= #TCQ 1'b1;
      else
        init_dqsfound_done_r  <= #TCQ 1'b0;
    end
  end
  always @(posedge clk) begin
    if (rst  || pi_rst_stg1_cal_r ||
       (init_dqsfound_done_r && (rnk_cnt_r == RANKS-1)))
      rank_done_r       <= #TCQ 1'b0;
    else if (reg_pi_found_dqs_all && ~reg_pi_found_dqs_all_r1)
      rank_done_r <= #TCQ 1'b1;
    else
      rank_done_r       <= #TCQ 1'b0;
  end
  always @(posedge clk) begin
    init_dqsfound_done_r1   <= #TCQ init_dqsfound_done_r;
    init_dqsfound_done_r2   <= #TCQ init_dqsfound_done_r1;
    init_dqsfound_done_r3   <= #TCQ init_dqsfound_done_r2;
    reg_pi_found_dqs_all_r1 <= #TCQ reg_pi_found_dqs_all;
    rank_done_r1            <= #TCQ rank_done_r;
    dqsfound_retry_r1       <= #TCQ dqsfound_retry;
  end
  always @(posedge clk) begin
    if (rst || dqsfound_retry || dqsfound_retry_r1 || pi_rst_stg1_cal_r)
      dqsfound_retry_done <= #TCQ 1'b0;
    else if (init_dqsfound_done_r)
      dqsfound_retry_done <= #TCQ 1'b1;
  end
  always @(posedge clk) begin
    if (rst)
      dqs_found_done_r <= #TCQ 1'b0;
    else if (reg_pi_found_dqs_all && (rnk_cnt_r == RANKS-1) && init_dqsfound_done_r1)
      dqs_found_done_r <= #TCQ 1'b1;
    else
      dqs_found_done_r <= #TCQ 1'b0;
  end
  always @(posedge clk) begin
    if (rst || pi_rst_stg1_cal_r)
      pi_rst_stg1_cal <= #TCQ 1'b0;
    else if ((pi_dqs_found_start && ~dqs_found_start_r) ||
             (dqsfound_retry) ||
             (reg_pi_found_dqs && ~pi_dqs_found_all) ||
             (rd_byte_data_offset[rnk_cnt_r] < (nCL + nAL -1)))
      pi_rst_stg1_cal <= #TCQ 1'b1;
  end
  always @(posedge clk)
    pi_rst_stg1_cal_r     <= #TCQ pi_rst_stg1_cal;
  generate
  genvar i;
    for (i = 0; i < RANKS; i = i + 1) begin: smallest_final_loop
      always @(posedge clk) begin
        if (rst)
          final_data_offset[i]    <= #TCQ 'b0;
        else if (dqsfound_retry)
          final_data_offset[i] <= #TCQ rd_byte_data_offset[i];
        else if (init_dqsfound_done_r && ~init_dqsfound_done_r1) begin
          final_data_offset[i] <= #TCQ rd_byte_data_offset[i];
          if (CWL_M % 2) 
            final_data_offset_mc[i] <= #TCQ rd_byte_data_offset[i] - 1;
          else 
            final_data_offset_mc[i] <= #TCQ rd_byte_data_offset[i];
        end
      end
    end
  endgenerate
  always @(posedge clk) begin
    if (rst)
      pi_dqs_found_err <= #TCQ 1'b0;
    else if (!reg_pi_found_dqs_all && (calib_cnt == NUM_DQSFOUND_CAL) &&
            (rd_byte_data_offset[rnk_cnt_r] < (nCL + nAL -1)))
      pi_dqs_found_err <= #TCQ 1'b1;
  end
endmodule
