`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module rank_cntrl #
  (
   parameter TCQ = 100,
   parameter BURST_MODE               = "8",
   parameter ID                       = 0,
   parameter nBANK_MACHS              = 4,
   parameter nCK_PER_CLK              = 2,
   parameter CL                       = 5,
   parameter nFAW                     = 30,
   parameter nREFRESH_BANK            = 8,
   parameter nRRD                     = 4,
   parameter nWTR                     = 4,
   parameter PERIODIC_RD_TIMER_DIV    = 20,
   parameter RANK_BM_BV_WIDTH         = 16,
   parameter RANK_WIDTH               = 2,
   parameter RANKS                    = 4,
   parameter PHASE_DETECT             = "OFF",
   parameter REFRESH_TIMER_DIV        = 39
  )
  (
  inhbt_act_faw_r, inhbt_rd_r, wtr_inhbt_config_r, refresh_request,
  periodic_rd_request,
  clk, rst, sending_row, act_this_rank_r, sending_col, wr_this_rank_r,
  app_ref_req, dfi_init_complete, rank_busy_r, refresh_tick,
  insert_maint_r1, maint_zq_r, maint_rank_r, app_periodic_rd_req,
  maint_prescaler_tick_r, clear_periodic_rd_request, rd_this_rank_r
  );
  input clk;
  input rst;
  function integer clogb2 (input integer size); 
    begin
      size = size - 1;
      for (clogb2=1; size>1; clogb2=clogb2+1)
            size = size >> 1;
    end
  endfunction 
  input [nBANK_MACHS-1:0] sending_row;
  input [RANK_BM_BV_WIDTH-1:0] act_this_rank_r;
  reg act_this_rank;
  integer i;
  always @(act_this_rank_r or sending_row) begin
    act_this_rank = 1'b0;
    for (i=0; i<nBANK_MACHS; i=i+1)
      act_this_rank =
         act_this_rank || (sending_row[i] && act_this_rank_r[(i*RANKS)+ID]);
  end
  localparam nADD_RRD = nRRD - ((nCK_PER_CLK == 1) ? 2 : 4);
  localparam nRRD_CLKS = (nCK_PER_CLK == 1)
                            ? nADD_RRD
                            : ((nADD_RRD/2) + (nADD_RRD%2));
  localparam ADD_RRD_CNTR_WIDTH = clogb2(nRRD_CLKS +  1);
  reg add_rrd_inhbt = 1'b0;
  generate
    if (nADD_RRD > 0) begin :add_rdd
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
  endgenerate
  localparam nFAW_CLKS = (nCK_PER_CLK == 1)
                           ? nFAW
                           : ((nFAW/2) + (nFAW%2));
  output reg inhbt_act_faw_r;
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
  localparam CASWR2CASRD = ((BURST_MODE == "4") ? 2 : 4) + nWTR + CL;
  localparam CASWR2CASRD_CLKS = (nCK_PER_CLK == 1)
                                    ? CASWR2CASRD
                                    : ((CASWR2CASRD / 2) + (CASWR2CASRD %2));
  localparam WTR_CNT_WIDTH = clogb2(CASWR2CASRD_CLKS -  1);
  localparam TWO = 2;
  input [nBANK_MACHS-1:0] sending_col;
  input [RANK_BM_BV_WIDTH-1:0] wr_this_rank_r;
  output reg inhbt_rd_r;
  output reg wtr_inhbt_config_r;
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
                 CASWR2CASRD_CLKS[WTR_CNT_WIDTH-1:0] - TWO[WTR_CNT_WIDTH-1:0];
          else if (|wtr_cnt_r) wtr_cnt_ns = wtr_cnt_r - ONE[WTR_CNT_WIDTH-1:0];
        end
      wire inhbt_rd_ns = |wtr_cnt_ns;
      wire wtr_inhbt_config_ns = wtr_cnt_ns >= TWO[WTR_CNT_WIDTH-1:0];
      always @(posedge clk) wtr_cnt_r <= #TCQ wtr_cnt_ns;
      always @(posedge clk) inhbt_rd_r <= #TCQ inhbt_rd_ns;
      always @(posedge clk) wtr_inhbt_config_r <= #TCQ wtr_inhbt_config_ns;
    end
  endgenerate
  localparam REFRESH_BANK_WIDTH = clogb2(nREFRESH_BANK + 1);
  input app_ref_req;
  input dfi_init_complete;
  input [(RANKS*nBANK_MACHS)-1:0] rank_busy_r;
  input refresh_tick;
  input insert_maint_r1;
  input maint_zq_r;
  input [RANK_WIDTH-1:0] maint_rank_r;
  output wire refresh_request;
  generate begin : refresh_generation
      reg my_rank_busy;
      always @(rank_busy_r) begin
        my_rank_busy = 1'b0;
        for (i=0; i < nBANK_MACHS; i=i+1)
          my_rank_busy = my_rank_busy || rank_busy_r[(i*RANKS)+ID];
      end
      wire my_refresh =
        insert_maint_r1 && ~maint_zq_r && (maint_rank_r == ID[RANK_WIDTH-1:0]);
      reg [REFRESH_BANK_WIDTH-1:0] refresh_bank_r;
      reg [REFRESH_BANK_WIDTH-1:0] refresh_bank_ns;
      always @(app_ref_req or dfi_init_complete or my_refresh
               or refresh_bank_r or refresh_tick)
        if (~dfi_init_complete)
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
      assign refresh_request = dfi_init_complete &&
              (~|refresh_bank_r ||
  ((refresh_bank_r != nREFRESH_BANK[0+:REFRESH_BANK_WIDTH]) && ~my_rank_busy));
    end
  endgenerate
  localparam PERIODIC_RD_TIMER_WIDTH = clogb2(PERIODIC_RD_TIMER_DIV +  1);
  input app_periodic_rd_req;
  input maint_prescaler_tick_r;
  output periodic_rd_request;
  input clear_periodic_rd_request;
  input [RANK_BM_BV_WIDTH-1:0] rd_this_rank_r;
  generate begin : periodic_rd_generation
    if ( PHASE_DETECT != "OFF" ) begin 
      reg read_this_rank;
      always @(rd_this_rank_r or sending_col) begin
        read_this_rank = 1'b0;
        for (i = 0; i < nBANK_MACHS; i = i + 1)
        read_this_rank =
           read_this_rank || (sending_col[i] && rd_this_rank_r[(i*RANKS)+ID]);
      end
      reg [PERIODIC_RD_TIMER_WIDTH-1:0] periodic_rd_timer_r;
      reg [PERIODIC_RD_TIMER_WIDTH-1:0] periodic_rd_timer_ns;
      always @(dfi_init_complete or maint_prescaler_tick_r
               or periodic_rd_timer_r or read_this_rank) begin
        periodic_rd_timer_ns = periodic_rd_timer_r;
        if (~dfi_init_complete)
          periodic_rd_timer_ns = {PERIODIC_RD_TIMER_WIDTH{1'b0}};
        else if (read_this_rank)
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
                     ((app_periodic_rd_req && dfi_init_complete) ||
                      ((PERIODIC_RD_TIMER_DIV != 0) && ~dfi_init_complete) ||
                      (~(read_this_rank || clear_periodic_rd_request) &&
                      (periodic_rd_request_r || periodic_rd_timer_one)));
      always @(posedge clk) periodic_rd_request_r <=
                              #TCQ periodic_rd_request_ns;
   `ifdef MC_SVA
      read_clears_periodic_rd_request: cover property (@(posedge clk)
               (rst && (periodic_rd_request_r && read_this_rank)));
   `endif
      assign periodic_rd_request = dfi_init_complete && periodic_rd_request_r;
    end else
      assign periodic_rd_request = 1'b0; 
  end
  endgenerate
endmodule
