`timescale 1ps/1ps
`timescale 1ps/1ps
module phy_dly_ctrl #
  (
   parameter TCQ            = 100,    
   parameter DQ_WIDTH       = 64,     
   parameter DQS_CNT_WIDTH  = 3,      
   parameter DQS_WIDTH      = 8,      
   parameter RANK_WIDTH     = 1,      
   parameter nCWL           = 5,      
   parameter WRLVL          = "ON",   
   parameter PHASE_DETECT   = "ON",   
   parameter DRAM_TYPE      = "DDR3",  
   parameter nDQS_COL0      = 4,      
   parameter nDQS_COL1      = 4,      
   parameter nDQS_COL2      = 0,      
   parameter nDQS_COL3      = 0,      
   parameter DQS_LOC_COL0   = 32'h03020100, 
   parameter DQS_LOC_COL1   = 32'h07060504, 
   parameter DQS_LOC_COL2   = 0,            
   parameter DQS_LOC_COL3   = 0,            
   parameter DEBUG_PORT     = "OFF"   
   )
  (
   input                        clk,
   input                        rst,
   input [3:0]                  clk_rsync,
   input [3:0]                  rst_rsync,
   input                        wrlvl_done,
   input [1:0]                  rdlvl_done,
   input                        pd_cal_done,
   input                        mc_data_sel,
   input [RANK_WIDTH:0]         mc_ioconfig,
   input                        mc_ioconfig_en,
   input [0:0]                  phy_ioconfig,
   input                        phy_ioconfig_en,
   input                        dqs_oe,
   input [5*DQS_WIDTH-1:0]      dlyval_wrlvl_dqs,
   input [5*DQS_WIDTH-1:0]      dlyval_wrlvl_dq,
   input [DQS_WIDTH-1:0]        dlyce_rdlvl_cpt,
   input                        dlyinc_rdlvl_cpt,
   input [3:0]                  dlyce_rdlvl_rsync,
   input                        dlyinc_rdlvl_rsync,
   input [5*DQS_WIDTH-1:0]      dlyval_rdlvl_dq,
   input [5*DQS_WIDTH-1:0]      dlyval_rdlvl_dqs,
   input [DQS_WIDTH-1:0]        dlyce_pd_cpt,
   input [DQS_WIDTH-1:0]        dlyinc_pd_cpt,
   input [5*DQS_WIDTH-1:0]      dlyval_pd_dqs,
   output reg [5*DQS_WIDTH-1:0] dlyval_dqs,
   output reg [5*DQS_WIDTH-1:0] dlyval_dq,
   output                       dlyrst_cpt,
   output [DQS_WIDTH-1:0]       dlyce_cpt,
   output [DQS_WIDTH-1:0]       dlyinc_cpt,
   output                       dlyrst_rsync,
   output [3:0]                 dlyce_rsync,
   output [3:0]                 dlyinc_rsync,
   input                        dbg_pd_off
   );
  localparam COL1_VECT_WIDTH = (nDQS_COL1 > 0) ? nDQS_COL1 : 1;
  localparam COL2_VECT_WIDTH = (nDQS_COL2 > 0) ? nDQS_COL2 : 1;
  localparam COL3_VECT_WIDTH = (nDQS_COL3 > 0) ? nDQS_COL3 : 1;
  reg [DQS_WIDTH-1:0]        dlyce_cpt_mux;
  reg [3:0]                  dlyce_rsync_mux;
  reg [DQS_WIDTH-1:0]        dlyinc_cpt_mux;
  reg [3:0]                  dlyinc_rsync_mux;
  reg                        dqs_oe_r;
  reg                        dqs_wr;
  wire [0:0]                 mux_ioconfig;
  wire                       mux_ioconfig_en;
  wire                       mux_rd_wr;
  reg                        mux_rd_wr_last_r;
  reg                        rd_wr_r;
  reg [3:0]                  rd_wr_rsync_r;
  reg [3:0]                  rd_wr_rsync_tmp_r;
  reg [3:0]                  rd_wr_rsync_tmp_r1;
  assign dlyrst_cpt   = rst;
  assign dlyrst_rsync = rst;
  assign mux_ioconfig    = (mc_data_sel) ?
                           mc_ioconfig[RANK_WIDTH] :
                           phy_ioconfig;
  assign mux_ioconfig_en = (mc_data_sel) ?
                           mc_ioconfig_en :
                           phy_ioconfig_en;
  assign mux_rd_wr = mux_ioconfig[0];
  always @(posedge clk)
    dqs_oe_r <= #TCQ dqs_oe;
  always @(dqs_oe or mux_rd_wr_last_r)
    dqs_wr = mux_rd_wr_last_r | dqs_oe;
  always @(posedge clk)
    if (mux_ioconfig_en)
      mux_rd_wr_last_r <= #TCQ mux_rd_wr;
  always @(posedge clk) begin
    if (mux_ioconfig_en) begin
      if ((dqs_wr)&& (DRAM_TYPE == "DDR3"))
        rd_wr_r <= #TCQ 1'b1;
      else
        rd_wr_r <= #TCQ mux_rd_wr;
    end else begin
      if ((dqs_wr)&& (DRAM_TYPE == "DDR3"))
        rd_wr_r <= #TCQ 1'b1;
      else
        rd_wr_r <= #TCQ mux_rd_wr;
    end
  end
  genvar r_i;
  generate
    for (r_i = 0; r_i < 4; r_i = r_i + 1) begin: gen_sync_rd_wr
      if (DRAM_TYPE == "DDR2") begin :  gen_cwl_ddr2
         if(nCWL <= 3) begin: gen_cwl_ddr2_ls_4
           always @(posedge clk_rsync[r_i]) begin
             rd_wr_rsync_tmp_r[r_i] <= #TCQ rd_wr_r;
             rd_wr_rsync_r[r_i]     <= #TCQ rd_wr_rsync_tmp_r[r_i];      
           end
         end else begin  
           always @(posedge clk_rsync[r_i]) begin:gen_cwl_ddr2_gt_3
             rd_wr_rsync_tmp_r[r_i] <= #TCQ rd_wr_r;
             rd_wr_rsync_tmp_r1[r_i] <= #TCQ rd_wr_rsync_tmp_r[r_i];
             rd_wr_rsync_r[r_i]     <= #TCQ rd_wr_rsync_tmp_r1[r_i];     
           end
         end 
      end else if (nCWL == 5) begin: gen_cwl_5_ddr3
        always @(posedge clk_rsync[r_i])
          rd_wr_rsync_r[r_i] <= #TCQ rd_wr_r;
      end else begin: gen_cwl_gt_5_ddr3
        always @(posedge clk_rsync[r_i]) begin
          rd_wr_rsync_tmp_r[r_i] <= #TCQ rd_wr_r;
          rd_wr_rsync_r[r_i]     <= #TCQ rd_wr_rsync_tmp_r[r_i];
        end
      end
    end
  endgenerate
  always @(posedge clk) begin
    if (!rdlvl_done[1]) begin
      dlyce_cpt_mux        <= #TCQ dlyce_rdlvl_cpt;
      dlyinc_cpt_mux       <= #TCQ {DQS_WIDTH{dlyinc_rdlvl_cpt}};
      dlyce_rsync_mux      <= #TCQ dlyce_rdlvl_rsync;
      dlyinc_rsync_mux     <= #TCQ {4{dlyinc_rdlvl_rsync}};
    end else begin
      if ((PHASE_DETECT == "OFF") || 
          ((DEBUG_PORT == "ON") && dbg_pd_off)) begin
        dlyce_cpt_mux        <= #TCQ dlyce_rdlvl_cpt;
        dlyinc_cpt_mux       <= #TCQ {DQS_WIDTH{dlyinc_rdlvl_cpt}};
        dlyce_rsync_mux      <= #TCQ dlyce_rdlvl_rsync;
        dlyinc_rsync_mux     <= #TCQ {4{dlyinc_rdlvl_rsync}};
      end else begin
        dlyce_cpt_mux    <= #TCQ dlyce_pd_cpt;
        dlyinc_cpt_mux   <= #TCQ dlyinc_pd_cpt;
        dlyce_rsync_mux  <= #TCQ 'b0;
        dlyinc_rsync_mux <= #TCQ 'b0;
      end
    end
  end
  assign dlyce_cpt     = dlyce_cpt_mux;
  assign dlyinc_cpt    = dlyinc_cpt_mux;
  assign dlyce_rsync   = dlyce_rsync_mux;
  assign dlyinc_rsync  = dlyinc_rsync_mux;
  generate
    genvar c0_i;
    for (c0_i = 0; c0_i < nDQS_COL0; c0_i = c0_i + 1) begin: gen_loop_c0
      always @ (posedge clk_rsync[0]) begin
        if (rd_wr_rsync_r[0]) begin
          dlyval_dqs[5*(DQS_LOC_COL0[8*c0_i+:8])+:5]
            <= #TCQ dlyval_wrlvl_dqs[5*(DQS_LOC_COL0[8*c0_i+:8])+:5];
          dlyval_dq[5*(DQS_LOC_COL0[8*c0_i+:8])+:5]
            <= #TCQ dlyval_wrlvl_dq[5*(DQS_LOC_COL0[8*c0_i+:8])+:5];
        end else begin
          if ((PHASE_DETECT == "ON") && rdlvl_done[1]) begin 
            dlyval_dqs[5*(DQS_LOC_COL0[8*c0_i+:8])+:5]
              <= #TCQ dlyval_pd_dqs[5*(DQS_LOC_COL0[8*c0_i+:8])+:5];
          end else begin 
            dlyval_dqs[5*(DQS_LOC_COL0[8*c0_i+:8])+:5]
              <= #TCQ dlyval_rdlvl_dqs[5*(DQS_LOC_COL0[8*c0_i+:8])+:5];
          end     
          dlyval_dq[5*(DQS_LOC_COL0[8*c0_i+:8])+:5]
            <= #TCQ dlyval_rdlvl_dq[5*(DQS_LOC_COL0[8*c0_i+:8])+:5];
        end
      end
    end
  endgenerate
  generate
    genvar c1_i;
    if (nDQS_COL1 > 0) begin: gen_c1
      for (c1_i = 0; c1_i < nDQS_COL1; c1_i = c1_i + 1) begin: gen_loop_c1
        always @(posedge clk_rsync[1]) begin
          if (rd_wr_rsync_r[1]) begin
            dlyval_dqs[5*(DQS_LOC_COL1[8*c1_i+7-:8])+:5]
              <= #TCQ dlyval_wrlvl_dqs[5*(DQS_LOC_COL1[8*c1_i+7-:8])+:5];
            dlyval_dq[5*(DQS_LOC_COL1[8*c1_i+7-:8])+:5]
              <= #TCQ dlyval_wrlvl_dq[5*(DQS_LOC_COL1[8*c1_i+:8])+:5];
          end else begin
            if ((PHASE_DETECT == "ON") && rdlvl_done[1]) begin 
              dlyval_dqs[5*(DQS_LOC_COL1[8*c1_i+:8])+:5]
                <= #TCQ dlyval_pd_dqs[5*(DQS_LOC_COL1[8*c1_i+:8])+:5];
            end else begin
              dlyval_dqs[5*(DQS_LOC_COL1[8*c1_i+:8])+:5]
                <= #TCQ dlyval_rdlvl_dqs[5*(DQS_LOC_COL1[8*c1_i+:8])+:5];
            end                
            dlyval_dq[5*(DQS_LOC_COL1[8*c1_i+:8])+:5]
              <= #TCQ dlyval_rdlvl_dq[5*(DQS_LOC_COL1[8*c1_i+:8])+:5];
          end
        end
      end
    end
  endgenerate
  generate
    genvar c2_i;
    if (nDQS_COL2 > 0) begin: gen_c2
      for (c2_i = 0; c2_i < nDQS_COL2; c2_i = c2_i + 1) begin: gen_loop_c2
        always @(posedge clk_rsync[2]) begin
          if (rd_wr_rsync_r[2]) begin
            dlyval_dqs[5*(DQS_LOC_COL2[8*c2_i+7-:8])+:5]
              <= #TCQ dlyval_wrlvl_dqs[5*(DQS_LOC_COL2[8*c2_i+7-:8])+:5];
            dlyval_dq[5*(DQS_LOC_COL2[8*c2_i+7-:8])+:5]
              <= #TCQ dlyval_wrlvl_dq[5*(DQS_LOC_COL2[8*c2_i+:8])+:5];
          end else begin
            if ((PHASE_DETECT == "ON") && rdlvl_done[1]) begin 
              dlyval_dqs[5*(DQS_LOC_COL2[8*c2_i+:8])+:5]
                <= #TCQ dlyval_pd_dqs[5*(DQS_LOC_COL2[8*c2_i+:8])+:5];
            end else begin
              dlyval_dqs[5*(DQS_LOC_COL2[8*c2_i+:8])+:5]
                <= #TCQ dlyval_rdlvl_dqs[5*(DQS_LOC_COL2[8*c2_i+:8])+:5];
            end                
            dlyval_dq[5*(DQS_LOC_COL2[8*c2_i+:8])+:5]
              <= #TCQ dlyval_rdlvl_dq[5*(DQS_LOC_COL2[8*c2_i+:8])+:5];
          end
        end
      end
    end
  endgenerate
  generate
    genvar c3_i;
    if (nDQS_COL3 > 0) begin: gen_c3
      for (c3_i = 0; c3_i < nDQS_COL3; c3_i = c3_i + 1) begin: gen_loop_c3
        always @(posedge clk_rsync[3]) begin
          if (rd_wr_rsync_r[3]) begin
            dlyval_dqs[5*(DQS_LOC_COL3[8*c3_i+7-:8])+:5]
              <= #TCQ dlyval_wrlvl_dqs[5*(DQS_LOC_COL3[8*c3_i+7-:8])+:5];
            dlyval_dq[5*(DQS_LOC_COL3[8*c3_i+7-:8])+:5]
              <= #TCQ dlyval_wrlvl_dq[5*(DQS_LOC_COL3[8*c3_i+:8])+:5];
          end else begin
            if ((PHASE_DETECT == "ON") && rdlvl_done[1]) begin
              dlyval_dqs[5*(DQS_LOC_COL3[8*c3_i+:8])+:5]
                <= #TCQ dlyval_pd_dqs[5*(DQS_LOC_COL3[8*c3_i+:8])+:5];
            end else begin
              dlyval_dqs[5*(DQS_LOC_COL3[8*c3_i+:8])+:5]
                <= #TCQ dlyval_rdlvl_dqs[5*(DQS_LOC_COL3[8*c3_i+:8])+:5];
            end                
            dlyval_dq[5*(DQS_LOC_COL3[8*c3_i+:8])+:5]
              <= #TCQ dlyval_rdlvl_dq[5*(DQS_LOC_COL3[8*c3_i+:8])+:5];
          end
        end
      end
    end
  endgenerate
endmodule
