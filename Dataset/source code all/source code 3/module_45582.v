`timescale 1ps/1ps
`timescale 1ps/1ps
module phy_data_io #
  (
   parameter TCQ             = 100,     
   parameter nCK_PER_CLK     = 2,       
   parameter CLK_PERIOD      = 3000,    
   parameter DRAM_WIDTH      = 8,       
   parameter DM_WIDTH        = 9,       
   parameter DQ_WIDTH        = 72,      
   parameter DQS_WIDTH       = 9,       
   parameter DRAM_TYPE       = "DDR3",
   parameter nCWL            = 5,       
   parameter WRLVL           = "OFF",   
   parameter REFCLK_FREQ     = 300.0,   
   parameter IBUF_LPWR_MODE  = "OFF",   
   parameter IODELAY_HP_MODE = "ON",    
   parameter IODELAY_GRP     = "IODELAY_MIG",
   parameter nDQS_COL0       = 4,       
   parameter nDQS_COL1       = 4,       
   parameter nDQS_COL2       = 0,       
   parameter nDQS_COL3       = 0,       
   parameter DQS_LOC_COL0    = 32'h03020100,          
   parameter DQS_LOC_COL1    = 32'h07060504,          
   parameter DQS_LOC_COL2    = 0,                     
   parameter DQS_LOC_COL3    = 0,                     
   parameter USE_DM_PORT     = 1       
   )
  (
   input                     clk_mem,
   input                     clk,
   input [DQS_WIDTH-1:0]     clk_cpt,
   input [3:0]               clk_rsync,
   input                     rst,
   input [3:0]               rst_rsync,
   input [5*DQS_WIDTH-1:0]   dlyval_dq,
   input [5*DQS_WIDTH-1:0]   dlyval_dqs,
   input [DQS_WIDTH-1:0]     inv_dqs,
   input [2*DQS_WIDTH-1:0]   wr_calib_dly,
   input [4*DQS_WIDTH-1:0]   dqs_oe_n,
   input [4*DQS_WIDTH-1:0]   dq_oe_n,
   input [(DQS_WIDTH*4)-1:0] dqs_rst,
   input [DQS_WIDTH-1:0]     dm_ce,
   input [(DQ_WIDTH/8)-1:0]  mask_data_rise0,
   input [(DQ_WIDTH/8)-1:0]  mask_data_fall0,
   input [(DQ_WIDTH/8)-1:0]  mask_data_rise1,
   input [(DQ_WIDTH/8)-1:0]  mask_data_fall1,
   input [DQ_WIDTH-1:0]      wr_data_rise0,
   input [DQ_WIDTH-1:0]      wr_data_rise1,
   input [DQ_WIDTH-1:0]      wr_data_fall0,
   input [DQ_WIDTH-1:0]      wr_data_fall1,
   input [2*DQS_WIDTH-1:0]   rd_bitslip_cnt,
   input [2*DQS_WIDTH-1:0]   rd_clkdly_cnt,
   output [DQ_WIDTH-1:0]     rd_data_rise0,
   output [DQ_WIDTH-1:0]     rd_data_fall0,
   output [DQ_WIDTH-1:0]     rd_data_rise1,
   output [DQ_WIDTH-1:0]     rd_data_fall1,
   output [DQS_WIDTH-1:0]    rd_dqs_rise0,
   output [DQS_WIDTH-1:0]    rd_dqs_fall0,
   output [DQS_WIDTH-1:0]    rd_dqs_rise1,
   output [DQS_WIDTH-1:0]    rd_dqs_fall1,
   output [DM_WIDTH-1:0]     ddr_dm,
   inout [DQS_WIDTH-1:0]     ddr_dqs_p,
   inout [DQS_WIDTH-1:0]     ddr_dqs_n,
   inout [DQ_WIDTH-1:0]      ddr_dq,
   output [5*DQS_WIDTH-1:0]  dbg_dqs_tap_cnt,
   output [5*DQS_WIDTH-1:0]  dbg_dq_tap_cnt   
   );
  localparam DM_TO_BYTE_RATIO = DM_WIDTH/(DQ_WIDTH/8);
  reg [DQS_WIDTH-1:0]   clk_rsync_dqs;
  wire [5*DQ_WIDTH-1:0] dq_tap_cnt;  
  reg [DQS_WIDTH-1:0]   rst_r ;
  reg [DQS_WIDTH-1:0]   rst_rsync_dqs;
  generate
    genvar c0_i;
    for (c0_i = 0; c0_i < nDQS_COL0; c0_i = c0_i + 1) begin: gen_loop_c0
      always @(clk_rsync[0])
        clk_rsync_dqs[DQS_LOC_COL0[8*c0_i+7-:8]] = clk_rsync[0];
      always @(rst_rsync[0])
        rst_rsync_dqs[DQS_LOC_COL0[8*c0_i+7-:8]] = rst_rsync[0];
    end
  endgenerate
  generate
    genvar c1_i;
    if (nDQS_COL1 > 0) begin: gen_c1
      for (c1_i = 0; c1_i < nDQS_COL1; c1_i = c1_i + 1) begin: gen_loop_c1
        always @(clk_rsync[1])
          clk_rsync_dqs[DQS_LOC_COL1[8*c1_i+7-:8]] = clk_rsync[1];
        always @(rst_rsync[1])
          rst_rsync_dqs[DQS_LOC_COL1[8*c1_i+7-:8]] = rst_rsync[1];
      end
    end
  endgenerate
  generate
    genvar c2_i;
    if (nDQS_COL2 > 0) begin: gen_c2
      for (c2_i = 0; c2_i < nDQS_COL2; c2_i = c2_i + 1) begin: gen_loop_c2
        always @(clk_rsync[2])
          clk_rsync_dqs[DQS_LOC_COL2[8*c2_i+7-:8]] = clk_rsync[2];
        always @(rst_rsync[2])
          rst_rsync_dqs[DQS_LOC_COL2[8*c2_i+7-:8]] = rst_rsync[2];
      end
    end
  endgenerate
  generate
    genvar c3_i;
    if (nDQS_COL3 > 0) begin: gen_c3
      for (c3_i = 0; c3_i < nDQS_COL3; c3_i = c3_i + 1) begin: gen_loop_c3
        always @(clk_rsync[3])
          clk_rsync_dqs[DQS_LOC_COL3[8*c3_i+7-:8]] = clk_rsync[3];
        always @(rst_rsync[3])
          rst_rsync_dqs[DQS_LOC_COL3[8*c3_i+7-:8]] = rst_rsync[3];
      end
    end
  endgenerate
  always @(posedge clk)
    if (rst)
      rst_r <= #TCQ {DQS_WIDTH{1'b1}};
    else
      rst_r <= #TCQ 'b0;
  generate
    genvar dqs_i;
    reg rst_dqs_r;
    always @(posedge clk)
      if (rst)
        rst_dqs_r <= #TCQ 1'b1;
      else
        rst_dqs_r <= #TCQ 'b0;
    for (dqs_i = 0; dqs_i < DQS_WIDTH; dqs_i = dqs_i+1) begin: gen_dqs
      phy_dqs_iob #
        (
         .DRAM_TYPE       (DRAM_TYPE),
         .REFCLK_FREQ     (REFCLK_FREQ),
         .IBUF_LPWR_MODE  (IBUF_LPWR_MODE),
         .IODELAY_HP_MODE (IODELAY_HP_MODE),
         .IODELAY_GRP     (IODELAY_GRP)
         )
        u_phy_dqs_iob
          (
           .clk_mem         (clk_mem),
           .clk             (clk),
           .clk_cpt         (clk_cpt[dqs_i]),
           .clk_rsync       (clk_rsync_dqs[dqs_i]),
           .rst             (rst_dqs_r),
           .rst_rsync       (rst_rsync_dqs[dqs_i]),
           .dlyval          (dlyval_dqs[5*dqs_i+:5]),
           .dqs_oe_n        (dqs_oe_n[4*dqs_i+:4]),
           .dqs_rst         (dqs_rst[4*dqs_i+:4]),
           .rd_bitslip_cnt  (rd_bitslip_cnt[2*dqs_i+:2]),
           .rd_clkdly_cnt   (rd_clkdly_cnt[2*dqs_i+:2]),
           .rd_dqs_rise0    (rd_dqs_rise0[dqs_i]),
           .rd_dqs_fall0    (rd_dqs_fall0[dqs_i]),
           .rd_dqs_rise1    (rd_dqs_rise1[dqs_i]),
           .rd_dqs_fall1    (rd_dqs_fall1[dqs_i]),
           .ddr_dqs_p       (ddr_dqs_p[dqs_i]),
           .ddr_dqs_n       (ddr_dqs_n[dqs_i]),
           .dqs_tap_cnt     (dbg_dqs_tap_cnt[5*dqs_i+:5])
           );
    end
  endgenerate
  generate
    genvar dm_i;
    reg rst_dm_r;
    always @(posedge clk)
      if (rst)
        rst_dm_r <= #TCQ 1'b1;
      else
        rst_dm_r <= #TCQ 'b0;
    if (USE_DM_PORT) begin: gen_dm_inst
      for (dm_i = 0; dm_i < DM_WIDTH; dm_i = dm_i+1) begin: gen_dm
        phy_dm_iob #
          (
           .TCQ             (TCQ),
           .nCWL            (nCWL),
           .DRAM_TYPE       (DRAM_TYPE),
           .WRLVL           (WRLVL),
           .REFCLK_FREQ     (REFCLK_FREQ),
           .IODELAY_HP_MODE (IODELAY_HP_MODE),
           .IODELAY_GRP     (IODELAY_GRP)
           )
          u_phy_dm_iob
            (
             .clk_mem         (clk_mem),
             .clk             (clk),
             .clk_rsync       (clk_rsync_dqs[dm_i]),
             .rst             (rst_dm_r),
             .dlyval          (dlyval_dq[5*(dm_i)+:5]),
             .dm_ce           (dm_ce[dm_i]),
             .inv_dqs         (inv_dqs[dm_i]),
             .wr_calib_dly    (wr_calib_dly[2*(dm_i)+:2]),
             .mask_data_rise0 (mask_data_rise0[dm_i/DM_TO_BYTE_RATIO]),
             .mask_data_fall0 (mask_data_fall0[dm_i/DM_TO_BYTE_RATIO]),
             .mask_data_rise1 (mask_data_rise1[dm_i/DM_TO_BYTE_RATIO]),
             .mask_data_fall1 (mask_data_fall1[dm_i/DM_TO_BYTE_RATIO]),
             .ddr_dm          (ddr_dm[dm_i])
             );
      end 
    end 
  endgenerate
  generate
    genvar dq_i;
    reg rst_dq_r;
    always @(posedge clk)
      if (rst)
        rst_dq_r <= #TCQ 1'b1;
      else
        rst_dq_r <= #TCQ 'b0;
    for (dq_i = 0; dq_i < DQ_WIDTH; dq_i = dq_i+1) begin: gen_dq
      phy_dq_iob #
        (
         .TCQ             (TCQ),
         .nCWL            (nCWL),
         .DRAM_TYPE       (DRAM_TYPE),
         .WRLVL           (WRLVL),
         .REFCLK_FREQ     (REFCLK_FREQ),
         .IBUF_LPWR_MODE  (IBUF_LPWR_MODE),
         .IODELAY_HP_MODE (IODELAY_HP_MODE),
         .IODELAY_GRP     (IODELAY_GRP)
         )
        u_iob_dq
          (
           .clk_mem        (clk_mem),
           .clk            (clk),
           .rst            (rst_dq_r),
           .clk_cpt        (clk_cpt[dq_i/DRAM_WIDTH]),
           .clk_rsync      (clk_rsync_dqs[dq_i/DRAM_WIDTH]),
           .rst_rsync      (rst_rsync_dqs[dq_i/DRAM_WIDTH]),
           .dlyval         (dlyval_dq[5*(dq_i/DRAM_WIDTH)+:5]),
           .inv_dqs        (inv_dqs[dq_i/DRAM_WIDTH]),
           .wr_calib_dly   (wr_calib_dly[2*(dq_i/DRAM_WIDTH)+:2]),
           .dq_oe_n        (dq_oe_n[4*(dq_i/DRAM_WIDTH)+:4]),
           .wr_data_rise0  (wr_data_rise0[dq_i]),
           .wr_data_fall0  (wr_data_fall0[dq_i]),
           .wr_data_rise1  (wr_data_rise1[dq_i]),
           .wr_data_fall1  (wr_data_fall1[dq_i]),
           .rd_bitslip_cnt (rd_bitslip_cnt[2*(dq_i/DRAM_WIDTH)+:2]),
           .rd_clkdly_cnt  (rd_clkdly_cnt[2*(dq_i/DRAM_WIDTH)+:2]),
           .rd_data_rise0  (rd_data_rise0[dq_i]),
           .rd_data_fall0  (rd_data_fall0[dq_i]),
           .rd_data_rise1  (rd_data_rise1[dq_i]),
           .rd_data_fall1  (rd_data_fall1[dq_i]),
           .ddr_dq         (ddr_dq[dq_i]),
           .dq_tap_cnt     (dq_tap_cnt[5*dq_i+:5])    
           );
    end
  endgenerate
  generate
    genvar dbg_i;
    for (dbg_i = 0; dbg_i < DQS_WIDTH; dbg_i = dbg_i+1) begin: gen_dbg
      assign dbg_dq_tap_cnt[5*dbg_i+:5] = dq_tap_cnt[5*DRAM_WIDTH*dbg_i+:5];
    end
  endgenerate
endmodule
