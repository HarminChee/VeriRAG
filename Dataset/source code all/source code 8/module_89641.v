`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module mig_7series_v1_9_rank_cntrl #
  (
    parameter TCQ                      = 100, 
    parameter BURST_MODE               = "8", 
    parameter DQRD2DQWR_DLY            = 2,   
    parameter CL                       = 5,   
    parameter CWL                      = 5,   
    parameter ID                       = 0,   
    parameter nBANK_MACHS              = 4,   
    parameter nCK_PER_CLK              = 2,   
    parameter nFAW                     = 30,  
    parameter nREFRESH_BANK            = 8,   
    parameter nRRD                     = 4,   
    parameter nWTR                     = 4,   
    parameter PERIODIC_RD_TIMER_DIV    = 20,  
    parameter RANK_BM_BV_WIDTH         = 16,  
    parameter RANK_WIDTH               = 2,   
    parameter RANKS                    = 4,   
    parameter REFRESH_TIMER_DIV        = 39   
  )
  (
    output                            periodic_rd_request,
    output  wire                      refresh_request,
    output  reg                       inhbt_act_faw_r,
    output  reg                       inhbt_rd,
    output  reg                       inhbt_wr,
    input                             clk,
    input                             rst,
    input                             app_periodic_rd_req,
    input                             app_ref_req,
    input   [RANK_BM_BV_WIDTH-1:0]    act_this_rank_r,
    input                             clear_periodic_rd_request,
    input                             col_rd_wr,
    input                             init_calib_complete,
    input                             insert_maint_r1,
    input                             maint_prescaler_tick_r,
    input   [RANK_WIDTH-1:0]          maint_rank_r,
    input                             maint_zq_r,
    input                             maint_sre_r,
    input                             maint_srx_r,
    input   [(RANKS*nBANK_MACHS)-1:0] rank_busy_r,
    input                             refresh_tick,  
    input   [nBANK_MACHS-1:0]         sending_col,
    input   [nBANK_MACHS-1:0]         sending_row,
    input   [RANK_BM_BV_WIDTH-1:0]    rd_this_rank_r,
    input   [RANK_BM_BV_WIDTH-1:0]    wr_this_rank_r
  );
  localparam nADD_RRD = nRRD -
    (
      (nCK_PER_CLK == 1) ?  2 :
      (nCK_PER_CLK == 2) ?  4 :
      8
    );
  localparam nRRD_CLKS = 
    (nCK_PER_CLK == 1) ?  nADD_RRD                    :
    (nCK_PER_CLK == 2) ?  ((nADD_RRD/2)+(nADD_RRD%2)) :
    ((nADD_RRD/4)+((nADD_RRD%4) ? 1 : 0));
  localparam ADD_RRD_CNTR_WIDTH = clogb2(nRRD_CLKS +  1);
  reg                                 act_this_rank;
  integer                             i;  
  function integer clogb2 (input integer size);
    begin
    size = size - 1;
    for (clogb2 = 1; size > 1; clogb2 = clogb2 + 1)
      size = size >> 1;
    end
  endfunction 
  always @(act_this_rank_r or sending_row) begin
    act_this_rank = 1'b0;
    for (i = 0; i < nBANK_MACHS; i = i + 1)
      act_this_rank =
         act_this_rank || (sending_row[i] && act_this_rank_r[(i*RANKS)+ID]);
  end
  reg add_rrd_inhbt = 1'b0;
  generate
    if (nADD_RRD > 0 && ADD_RRD_CNTR_WIDTH > 1) begin :add_rdd1
      reg[ADD_RRD_CNTR_WIDTH-1:0] add_rrd_ns;
      reg[ADD_RRD_CNTR_WIDTH-1:0] add_rrd_r;
      always @(act_this_rank or add_rrd_r or rst) begin
        add_rrd_ns = add_rrd_r;
        if (rst) add_rrd_ns = {ADD_RRD_CNTR_WIDTH{1'b0}};
        else
          if (act_this_rank)
            add_rrd_ns = nRRD_CLKS[0+:ADD_RRD_CNTR_WIDTH];
          else if (|add_rrd_r) add_rrd_ns =
                            add_rrd_r - {{ADD_RRD_CNTR_WIDTH-1{1'b0}}, 1'b1};
      end
      always @(posedge clk) add_rrd_r <= #TCQ add_rrd_ns;
      always @(add_rrd_ns) add_rrd_inhbt = |add_rrd_ns;
    end 
    else if (nADD_RRD > 0) begin :add_rdd0
      reg[ADD_RRD_CNTR_WIDTH-1:0] add_rrd_ns;
      reg[ADD_RRD_CNTR_WIDTH-1:0] add_rrd_r;
      always @(act_this_rank or add_rrd_r or rst) begin
        add_rrd_ns = add_rrd_r;
        if (rst) add_rrd_ns = {ADD_RRD_CNTR_WIDTH{1'b0}};
        else
          if (act_this_rank)
            add_rrd_ns = nRRD_CLKS[0+:ADD_RRD_CNTR_WIDTH];
          else if (|add_rrd_r) add_rrd_ns =
                            add_rrd_r - {1'b1};
      end
      always @(posedge clk) add_rrd_r <= #TCQ add_rrd_ns;
      always @(add_rrd_ns) add_rrd_inhbt = |add_rrd_ns;
    end 
  endgenerate
  localparam nFAW_CLKS = (nCK_PER_CLK == 1)
                           ? nFAW
                           : (nCK_PER_CLK == 2) ? ((nFAW/2) + (nFAW%2)) : 
                           ((nFAW/4) + ((nFAW%4) ? 1 : 0));
  generate
    begin : inhbt_act_faw
      wire act_delayed;
      wire [4:0] shift_depth = nFAW_CLKS[4:0] - 5'd3;
      SRLC32E #(.INIT(32'h00000000) ) SRLC32E0
        (.Q(act_delayed), 
         .Q31(), 
         .A(shift_depth), 
         .CE(1'b1), 
         .CLK(clk), 
         .D(act_this_rank) 
        );
      reg [2:0] faw_cnt_ns;
      reg [2:0] faw_cnt_r;
      reg inhbt_act_faw_ns;
      always @(act_delayed or act_this_rank or add_rrd_inhbt
               or faw_cnt_r or rst) begin
        if (rst) faw_cnt_ns = 3'b0;
        else begin
          faw_cnt_ns = faw_cnt_r;
          if (act_this_rank) faw_cnt_ns = faw_cnt_r + 3'b1;
          if (act_delayed) faw_cnt_ns = faw_cnt_ns - 3'b1;
        end
        inhbt_act_faw_ns = (faw_cnt_ns == 3'h4) || add_rrd_inhbt;
      end
      always @(posedge clk) faw_cnt_r <= #TCQ faw_cnt_ns;
      always @(posedge clk) inhbt_act_faw_r <= #TCQ inhbt_act_faw_ns;
    end 
  endgenerate
  localparam ONE = 1;
  localparam TWO = 2;
  localparam CASWR2CASRD = CWL + (BURST_MODE == "4" ? 2 : 4) + nWTR;
  localparam CASWR2CASRD_CLKS = (nCK_PER_CLK == 1)
                                    ? CASWR2CASRD :
                                 (nCK_PER_CLK == 2)
                                    ? ((CASWR2CASRD / 2) + (CASWR2CASRD % 2)) :
                                      ((CASWR2CASRD / 4) + ((CASWR2CASRD % 4) ? 1 :0));
  localparam WTR_CNT_WIDTH = clogb2(CASWR2CASRD_CLKS);
  generate
    begin : wtr_timer
      reg write_this_rank;
      always @(sending_col or wr_this_rank_r) begin
        write_this_rank = 1'b0;
        for (i = 0; i < nBANK_MACHS; i = i + 1)
        write_this_rank =
           write_this_rank || (sending_col[i] && wr_this_rank_r[(i*RANKS)+ID]);
      end
      reg [WTR_CNT_WIDTH-1:0] wtr_cnt_r;
      reg [WTR_CNT_WIDTH-1:0] wtr_cnt_ns;
      always @(rst or write_this_rank or wtr_cnt_r)
        if (rst) wtr_cnt_ns = {WTR_CNT_WIDTH{1'b0}};
        else begin
          wtr_cnt_ns = wtr_cnt_r;
          if (write_this_rank) wtr_cnt_ns =
                 CASWR2CASRD_CLKS[WTR_CNT_WIDTH-1:0] - ONE[WTR_CNT_WIDTH-1:0];
          else if (|wtr_cnt_r) wtr_cnt_ns = wtr_cnt_r - ONE[WTR_CNT_WIDTH-1:0];
        end
      wire inhbt_rd_ns = |wtr_cnt_ns;
      always @(posedge clk) wtr_cnt_r <= #TCQ wtr_cnt_ns;
      always @(inhbt_rd_ns) inhbt_rd = inhbt_rd_ns;
    end
  endgenerate
  localparam CASRD2CASWR = CL + (BURST_MODE == "4" ? 2 : 4) + DQRD2DQWR_DLY - CWL;
  localparam CASRD2CASWR_CLKS = (nCK_PER_CLK == 1)
                                    ? CASRD2CASWR :
                                 (nCK_PER_CLK == 2)
                                    ? ((CASRD2CASWR / 2) + (CASRD2CASWR % 2)) :
                                      ((CASRD2CASWR / 4) + ((CASRD2CASWR % 4) ? 1 :0));
  localparam RTW_CNT_WIDTH = clogb2(CASRD2CASWR_CLKS);
  generate
    begin : rtw_timer
      reg read_this_rank;
      always @(sending_col or rd_this_rank_r) begin
        read_this_rank = 1'b0;
        for (i = 0; i < nBANK_MACHS; i = i + 1)
        read_this_rank =
           read_this_rank || (sending_col[i] && rd_this_rank_r[(i*RANKS)+ID]);
      end
      reg [RTW_CNT_WIDTH-1:0] rtw_cnt_r;
      reg [RTW_CNT_WIDTH-1:0] rtw_cnt_ns;
      always @(rst or col_rd_wr or sending_col or rtw_cnt_r)
        if (rst) rtw_cnt_ns = {RTW_CNT_WIDTH{1'b0}};
        else begin
          rtw_cnt_ns = rtw_cnt_r;
          if (col_rd_wr && |sending_col) rtw_cnt_ns =
                 CASRD2CASWR_CLKS[RTW_CNT_WIDTH-1:0] - ONE[RTW_CNT_WIDTH-1:0];
          else if (|rtw_cnt_r) rtw_cnt_ns = rtw_cnt_r - ONE[RTW_CNT_WIDTH-1:0];
        end
      wire inhbt_wr_ns = |rtw_cnt_ns;
      always @(posedge clk) rtw_cnt_r <= #TCQ rtw_cnt_ns;
      always @(inhbt_wr_ns) inhbt_wr = inhbt_wr_ns;
    end
  endgenerate
  localparam REFRESH_BANK_WIDTH = clogb2(nREFRESH_BANK + 1);
  generate begin : refresh_generation
      reg my_rank_busy;
      always @(rank_busy_r) begin
        my_rank_busy = 1'b0;
        for (i=0; i < nBANK_MACHS; i=i+1)
          my_rank_busy = my_rank_busy || rank_busy_r[(i*RANKS)+ID];
      end
      wire my_refresh =
        insert_maint_r1 && ~maint_zq_r && ~maint_sre_r && ~maint_srx_r &&
        (maint_rank_r == ID[RANK_WIDTH-1:0]);
      reg [REFRESH_BANK_WIDTH-1:0] refresh_bank_r;
      reg [REFRESH_BANK_WIDTH-1:0] refresh_bank_ns;
      always @(app_ref_req or init_calib_complete or my_refresh
               or refresh_bank_r or refresh_tick)
        if (~init_calib_complete)
          if (REFRESH_TIMER_DIV == 0)
                refresh_bank_ns = nREFRESH_BANK[0+:REFRESH_BANK_WIDTH];
          else refresh_bank_ns = {REFRESH_BANK_WIDTH{1'b0}};
        else
          case ({my_refresh, refresh_tick, app_ref_req})
            3'b000, 3'b110, 3'b101, 3'b111 : refresh_bank_ns = refresh_bank_r;
            3'b010, 3'b001, 3'b011 : refresh_bank_ns =
                                          (|refresh_bank_r)?
                                          refresh_bank_r - ONE[0+:REFRESH_BANK_WIDTH]:
                                          refresh_bank_r;
            3'b100                 : refresh_bank_ns =
                                   refresh_bank_r + ONE[0+:REFRESH_BANK_WIDTH];
          endcase 
      always @(posedge clk) refresh_bank_r <= #TCQ refresh_bank_ns;
   `ifdef MC_SVA
      refresh_bank_overflow: assert property (@(posedge clk)
               (rst || (refresh_bank_r <= nREFRESH_BANK)));
      refresh_bank_underflow: assert property (@(posedge clk)
               (rst || ~(~|refresh_bank_r && ~my_refresh && refresh_tick)));
      refresh_hi_priority: cover property (@(posedge clk)
               (rst && ~|refresh_bank_ns && (refresh_bank_r ==
                       ONE[0+:REFRESH_BANK_WIDTH])));
      refresh_bank_full: cover property (@(posedge clk)
               (rst && (refresh_bank_r ==
                        nREFRESH_BANK[0+:REFRESH_BANK_WIDTH])));
   `endif
      assign refresh_request = init_calib_complete &&
              (~|refresh_bank_r ||
  ((refresh_bank_r != nREFRESH_BANK[0+:REFRESH_BANK_WIDTH]) && ~my_rank_busy));
    end
  endgenerate
  localparam PERIODIC_RD_TIMER_WIDTH = clogb2(PERIODIC_RD_TIMER_DIV +  1);
  generate begin : periodic_rd_generation
    if ( PERIODIC_RD_TIMER_DIV != 0 ) begin  
      reg read_this_rank;
      always @(rd_this_rank_r or sending_col) begin
        read_this_rank = 1'b0;
        for (i = 0; i < nBANK_MACHS; i = i + 1)
        read_this_rank =
           read_this_rank || (sending_col[i] && rd_this_rank_r[(i*RANKS)+ID]);
      end
      reg read_this_rank_r;
      reg read_this_rank_r1;
      always @(posedge clk) read_this_rank_r  <= #TCQ read_this_rank;
      always @(posedge clk) read_this_rank_r1 <= #TCQ read_this_rank_r;
      wire int_read_this_rank = read_this_rank &&
                                (((nCK_PER_CLK == 4) && read_this_rank_r)  ||
				 ((nCK_PER_CLK != 4) && read_this_rank_r1));
      reg periodic_rd_cntr1_ns;
      reg periodic_rd_cntr1_r;
      always @(clear_periodic_rd_request or periodic_rd_cntr1_r) begin
        periodic_rd_cntr1_ns = periodic_rd_cntr1_r;
        if (clear_periodic_rd_request)
          periodic_rd_cntr1_ns = periodic_rd_cntr1_r + 1'b1;
      end
      always @(posedge clk) begin
        if (rst) periodic_rd_cntr1_r <= #TCQ 1'b0;
        else     periodic_rd_cntr1_r <= #TCQ periodic_rd_cntr1_ns;
      end
      reg [PERIODIC_RD_TIMER_WIDTH-1:0] periodic_rd_timer_r;
      reg [PERIODIC_RD_TIMER_WIDTH-1:0] periodic_rd_timer_ns;
      always @(init_calib_complete or maint_prescaler_tick_r
               or periodic_rd_timer_r or int_read_this_rank) begin
        periodic_rd_timer_ns = periodic_rd_timer_r;
        if (~init_calib_complete)
          periodic_rd_timer_ns = {PERIODIC_RD_TIMER_WIDTH{1'b0}};
        else if (int_read_this_rank)
                periodic_rd_timer_ns =
                   PERIODIC_RD_TIMER_DIV[0+:PERIODIC_RD_TIMER_WIDTH];
             else if (|periodic_rd_timer_r && maint_prescaler_tick_r)
                 periodic_rd_timer_ns =
                   periodic_rd_timer_r - ONE[0+:PERIODIC_RD_TIMER_WIDTH];
      end
      always @(posedge clk) periodic_rd_timer_r <= #TCQ periodic_rd_timer_ns;
      wire periodic_rd_timer_one = maint_prescaler_tick_r &&
                 (periodic_rd_timer_r == ONE[0+:PERIODIC_RD_TIMER_WIDTH]);
      reg periodic_rd_request_r;
      wire periodic_rd_request_ns = ~rst &&
                     ((app_periodic_rd_req && init_calib_complete) ||
                      ((PERIODIC_RD_TIMER_DIV != 0) && ~init_calib_complete) ||
                      (~((int_read_this_rank) || (clear_periodic_rd_request && periodic_rd_cntr1_r)) &&
                      (periodic_rd_request_r || periodic_rd_timer_one)));
      always @(posedge clk) periodic_rd_request_r <=
                              #TCQ periodic_rd_request_ns;
   `ifdef MC_SVA
      read_clears_periodic_rd_request: cover property (@(posedge clk)
               (rst && (periodic_rd_request_r && read_this_rank)));
   `endif
      assign periodic_rd_request = init_calib_complete && periodic_rd_request_r;
    end else
      assign periodic_rd_request = 1'b0; 
  end
  endgenerate
endmodule
