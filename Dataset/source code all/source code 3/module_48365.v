`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module rank_common #
  (
   parameter TCQ = 100,
   parameter DRAM_TYPE                = "DDR3",
   parameter MAINT_PRESCALER_DIV      = 40,
   parameter nBANK_MACHS              = 4,
   parameter RANK_WIDTH               = 2,
   parameter RANKS                    = 4,
   parameter REFRESH_TIMER_DIV        = 39,
   parameter ZQ_TIMER_DIV             = 640000
  )
  (
  maint_prescaler_tick_r, refresh_tick, maint_zq_r, maint_req_r,
  maint_rank_r, clear_periodic_rd_request, periodic_rd_r,
  periodic_rd_rank_r,
  clk, rst, dfi_init_complete, app_zq_req, insert_maint_r1,
  refresh_request, maint_wip_r, slot_0_present, slot_1_present,
  periodic_rd_request, periodic_rd_ack_r
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
  localparam ONE = 1;
  localparam MAINT_PRESCALER_WIDTH = clogb2(MAINT_PRESCALER_DIV + 1);
  input dfi_init_complete;
  reg maint_prescaler_tick_r_lcl;
  generate
    begin : maint_prescaler
      reg [MAINT_PRESCALER_WIDTH-1:0] maint_prescaler_r;
      reg [MAINT_PRESCALER_WIDTH-1:0] maint_prescaler_ns;
      wire maint_prescaler_tick_ns =
             (maint_prescaler_r == ONE[MAINT_PRESCALER_WIDTH-1:0]);
      always @(dfi_init_complete or maint_prescaler_r
               or maint_prescaler_tick_ns) begin
        maint_prescaler_ns = maint_prescaler_r;
        if (~dfi_init_complete || maint_prescaler_tick_ns)
           maint_prescaler_ns = MAINT_PRESCALER_DIV[MAINT_PRESCALER_WIDTH-1:0];
        else if (|maint_prescaler_r)
       maint_prescaler_ns = maint_prescaler_r - ONE[MAINT_PRESCALER_WIDTH-1:0];
      end
      always @(posedge clk) maint_prescaler_r <= #TCQ maint_prescaler_ns;
      always @(posedge clk) maint_prescaler_tick_r_lcl <=
                             #TCQ maint_prescaler_tick_ns;
    end
  endgenerate
  output wire maint_prescaler_tick_r;
  assign maint_prescaler_tick_r = maint_prescaler_tick_r_lcl;
  localparam REFRESH_TIMER_WIDTH = clogb2(REFRESH_TIMER_DIV +  1);
  wire refresh_tick_lcl;
  generate
    begin : refresh_timer
      reg [REFRESH_TIMER_WIDTH-1:0] refresh_timer_r;
      reg [REFRESH_TIMER_WIDTH-1:0] refresh_timer_ns;
      always @(dfi_init_complete or maint_prescaler_tick_r_lcl
               or refresh_tick_lcl or refresh_timer_r) begin
        refresh_timer_ns = refresh_timer_r;
        if (~dfi_init_complete || refresh_tick_lcl)
              refresh_timer_ns = REFRESH_TIMER_DIV[REFRESH_TIMER_WIDTH-1:0];
        else if (|refresh_timer_r && maint_prescaler_tick_r_lcl)
                 refresh_timer_ns =
                   refresh_timer_r - ONE[REFRESH_TIMER_WIDTH-1:0];
      end
      always @(posedge clk) refresh_timer_r <= #TCQ refresh_timer_ns;
      assign refresh_tick_lcl = (refresh_timer_r ==
                  ONE[REFRESH_TIMER_WIDTH-1:0]) && maint_prescaler_tick_r_lcl;
    end
  endgenerate
  output wire refresh_tick;
  assign refresh_tick = refresh_tick_lcl;
  localparam ZQ_TIMER_WIDTH = clogb2(ZQ_TIMER_DIV + 1);
  input app_zq_req;
  input insert_maint_r1;
  reg maint_zq_r_lcl;
  reg zq_request = 1'b0;
  generate
    if (DRAM_TYPE == "DDR3") begin : zq_cntrl
      reg zq_tick = 1'b0;
      if (ZQ_TIMER_DIV !=0) begin : zq_timer
        reg [ZQ_TIMER_WIDTH-1:0] zq_timer_r;
        reg [ZQ_TIMER_WIDTH-1:0] zq_timer_ns;
        always @(dfi_init_complete or maint_prescaler_tick_r_lcl
                 or zq_tick or zq_timer_r) begin
          zq_timer_ns = zq_timer_r;
          if (~dfi_init_complete || zq_tick)
                zq_timer_ns = ZQ_TIMER_DIV[ZQ_TIMER_WIDTH-1:0];
          else if (|zq_timer_r && maint_prescaler_tick_r_lcl)
                   zq_timer_ns = zq_timer_r - ONE[ZQ_TIMER_WIDTH-1:0];
        end
        always @(posedge clk) zq_timer_r <= #TCQ zq_timer_ns;
        always @(maint_prescaler_tick_r_lcl or zq_timer_r)
                  zq_tick = (zq_timer_r ==
                       ONE[ZQ_TIMER_WIDTH-1:0] && maint_prescaler_tick_r_lcl);
      end 
      begin : zq_request_logic
        wire zq_clears_zq_request = insert_maint_r1 && maint_zq_r_lcl;
        reg zq_request_r;
        wire zq_request_ns = ~rst && (DRAM_TYPE == "DDR3") &&
                           ((~dfi_init_complete && (ZQ_TIMER_DIV != 0)) ||
                            (zq_request_r && ~zq_clears_zq_request) ||
                            zq_tick ||
                            (app_zq_req && dfi_init_complete));
        always @(posedge clk) zq_request_r <= #TCQ zq_request_ns;
        always @(dfi_init_complete or zq_request_r)
                  zq_request = dfi_init_complete && zq_request_r;
      end 
    end
  endgenerate
  input[RANKS-1:0] refresh_request;
  input maint_wip_r;
  reg maint_req_r_lcl;
  reg [RANK_WIDTH-1:0] maint_rank_r_lcl;
  input [7:0] slot_0_present;
  input [7:0] slot_1_present;
  generate
    begin : maintenance_request
      reg upd_last_master_r;
      reg new_maint_rank_r;
      wire maint_busy = upd_last_master_r || new_maint_rank_r ||
                        maint_req_r_lcl || maint_wip_r;
      wire [RANKS:0] maint_request = {zq_request, refresh_request[RANKS-1:0]};
      wire upd_last_master_ns = |maint_request && ~maint_busy;
      always @(posedge clk) upd_last_master_r <= #TCQ upd_last_master_ns;
      always @(posedge clk) new_maint_rank_r <= #TCQ upd_last_master_r;
      always @(posedge clk) maint_req_r_lcl <= #TCQ new_maint_rank_r;
      wire [RANKS:0] maint_grant_ns;
      wire [RANKS:0] maint_grant_r;
      round_robin_arb #
     (.WIDTH                            (RANKS+1))
      maint_arb0
      (.grant_ns                        (maint_grant_ns),
       .grant_r                         (maint_grant_r),
       .upd_last_master                 (upd_last_master_r),
       .current_master                  (maint_grant_r),
       .req                             (maint_request),
       .disable_grant                   (1'b0),
       .clk                             (clk),
       .rst                             (rst));
      wire [7:0] present = slot_0_present | slot_1_present;
      integer i;
      reg [RANK_WIDTH-1:0] maint_rank_ns;
      wire maint_zq_ns = ~rst && (upd_last_master_r
                                    ? maint_grant_r[RANKS]
                                    : maint_zq_r_lcl);
      always @(maint_grant_r or maint_rank_r_lcl or maint_zq_ns
               or present or rst or upd_last_master_r) begin
        if (rst) maint_rank_ns = {RANK_WIDTH{1'b0}};
        else begin
          maint_rank_ns = maint_rank_r_lcl;
          if (maint_zq_ns) begin
            maint_rank_ns = maint_rank_r_lcl + ONE[RANK_WIDTH-1:0];
            for (i=0; i<8; i=i+1)
              if (~present[maint_rank_ns])
                     maint_rank_ns = maint_rank_ns + ONE[RANK_WIDTH-1:0];
          end
          else
            if (upd_last_master_r)
              for (i=0; i<RANKS; i=i+1)
                if (maint_grant_r[i]) maint_rank_ns = i[RANK_WIDTH-1:0];
        end
      end
      always @(posedge clk) maint_rank_r_lcl <= #TCQ maint_rank_ns;
      always @(posedge clk) maint_zq_r_lcl <= #TCQ maint_zq_ns;
    end 
  endgenerate
  output wire maint_zq_r;
  assign maint_zq_r = maint_zq_r_lcl;
  output wire maint_req_r;
  assign maint_req_r = maint_req_r_lcl;
  output wire [RANK_WIDTH-1:0] maint_rank_r;
  assign maint_rank_r = maint_rank_r_lcl;
  input [RANKS-1:0] periodic_rd_request;
  reg periodic_rd_r_lcl;
  reg [RANK_WIDTH-1:0] periodic_rd_rank_r_lcl;
  input periodic_rd_ack_r;
  output wire [RANKS-1:0] clear_periodic_rd_request;
  generate
    begin : periodic_read_request
      reg upd_last_master_r;
      wire periodic_rd_busy = upd_last_master_r || periodic_rd_r_lcl;
      wire upd_last_master_ns =
             dfi_init_complete && (|periodic_rd_request && ~periodic_rd_busy);
      always @(posedge clk) upd_last_master_r <= #TCQ upd_last_master_ns;
      wire periodic_rd_ns = dfi_init_complete &&
             (upd_last_master_r || (periodic_rd_r_lcl && ~periodic_rd_ack_r));
      always @(posedge clk) periodic_rd_r_lcl <= #TCQ periodic_rd_ns;
      wire [RANKS-1:0] periodic_rd_grant_ns;
      reg [RANKS-1:0] periodic_rd_grant_r;
      round_robin_arb #
     (.WIDTH                            (RANKS))
      periodic_rd_arb0
      (.grant_ns                        (periodic_rd_grant_ns[RANKS-1:0]),
       .grant_r                         (),
       .upd_last_master                 (upd_last_master_r),
       .current_master                  (periodic_rd_grant_r[RANKS-1:0]),
       .req                             (periodic_rd_request[RANKS-1:0]),
       .disable_grant                   (1'b0),
       .clk                             (clk),
       .rst                             (rst));
      always @(posedge clk) periodic_rd_grant_r = upd_last_master_ns
                                                   ? periodic_rd_grant_ns
                                                   : periodic_rd_grant_r;
      integer i;
      reg [RANK_WIDTH-1:0] periodic_rd_rank_ns;
      always @(periodic_rd_grant_r or periodic_rd_rank_r_lcl
               or upd_last_master_r) begin
        periodic_rd_rank_ns = periodic_rd_rank_r_lcl;
        if (upd_last_master_r)
          for (i=0; i<RANKS; i=i+1)
            if (periodic_rd_grant_r[i])
                  periodic_rd_rank_ns = i[RANK_WIDTH-1:0];
      end
      always @(posedge clk) periodic_rd_rank_r_lcl <=
                             #TCQ periodic_rd_rank_ns;
      assign clear_periodic_rd_request =
               periodic_rd_grant_r & {RANKS{periodic_rd_ack_r}};
    end 
  endgenerate
  output wire periodic_rd_r;
  assign periodic_rd_r = periodic_rd_r_lcl;
  output wire [RANK_WIDTH-1:0] periodic_rd_rank_r;
  assign periodic_rd_rank_r = periodic_rd_rank_r_lcl;
endmodule
