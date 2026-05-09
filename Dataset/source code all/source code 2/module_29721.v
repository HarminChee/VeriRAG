`timescale 1ps/1ps
`timescale 1ps/1ps
module phy_wrcal #
  (
   parameter TCQ             = 100,    
   parameter nCK_PER_CLK     = 2,      
   parameter DQ_WIDTH        = 64,     
   parameter DQS_CNT_WIDTH   = 3,      
   parameter DQS_WIDTH       = 8,      
   parameter DRAM_WIDTH      = 8,      
   parameter SIM_CAL_OPTION  = "NONE"  
   )
  (
   input                        clk,
   input                        rst,
   input                        wrcal_start,
   input                        phy_rddata_en,
   output reg                   wrcal_done,
   output reg                   wrcal_pat_err,
   output reg                   wrcal_prech_req,
   input                        prech_done,
   input [DQ_WIDTH-1:0]         rd_data_rise0,
   input [DQ_WIDTH-1:0]         rd_data_fall0,
   input [DQ_WIDTH-1:0]         rd_data_rise1,
   input [DQ_WIDTH-1:0]         rd_data_fall1,
   input [DQ_WIDTH-1:0]         rd_data_rise2,
   input [DQ_WIDTH-1:0]         rd_data_fall2,
   input [DQ_WIDTH-1:0]         rd_data_rise3,
   input [DQ_WIDTH-1:0]         rd_data_fall3,
   input [3*DQS_WIDTH-1:0]      wl_po_coarse_cnt,
   input [6*DQS_WIDTH-1:0]      wl_po_fine_cnt,
   output reg                   dqs_po_stg2_c_incdec,
   output reg                   dqs_po_en_stg2_c,
   output reg                   dqs_po_stg2_load,
   output reg [8:0]             dqs_po_stg2_reg_l,
   output                       wrcal_pat_resume,   
   output [DQS_CNT_WIDTH:0]     po_stg2_wrcal_cnt,
   output [15:0]                dbg_phy_wrcal
   );
  localparam CAL_PAT_LEN = 8;
  localparam RD_SHIFT_LEN = (nCK_PER_CLK == 4) ? 1 : 2;
  localparam RDEN_WAIT_CNT = 12;
  localparam CAL2_IDLE           = 3'h0;
  localparam CAL2_READ_WAIT      = 3'h1;
  localparam CAL2_DETECT_MATCH   = 3'h2;
  localparam CAL2_CORSE_INC      = 3'h3;
  localparam CAL2_CORSE_INC_WAIT = 3'h4;
  localparam CAL2_NEXT_DQS       = 3'h5;
  localparam CAL2_DONE           = 3'h6;
  localparam CAL2_ERROR_TO       = 3'h7;
  integer  i;
  reg [DQS_CNT_WIDTH:0]   wrcal_dqs_cnt_r;
  reg [DQS_CNT_WIDTH:0]   wrcal_regl_dqs_cnt;
  reg [3:0]               wrcal_done_cnt;
  reg                     cal2_done_r;
  reg                     cal2_done_r1;
  reg                     cal2_done_r2;
  reg                     cal2_done_r3;  
  reg                     cal2_prech_req_r;
  reg [2:0]               cal2_state_r;
  reg [3*DQS_WIDTH-1:0]   cal2_corse_cnt;
  reg                     wrcal_pat_resume_r;
  reg                     wrcal_pat_resume_r1;
  reg                     wrcal_pat_resume_r2;
  reg                     wrcal_pat_resume_r3;
  reg [3:0]               cnt_rden_wait_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall0_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall1_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise0_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise1_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall2_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_fall3_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise2_r;
  reg [DRAM_WIDTH-1:0]    mux_rd_rise3_r;
  reg                     pat_data_match_r;
  wire [RD_SHIFT_LEN-1:0] pat_fall0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_fall1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_fall2 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_fall3 [3:0];
  reg [DRAM_WIDTH-1:0]    pat_match_fall0_r;
  reg                     pat_match_fall0_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_fall1_r;
  reg                     pat_match_fall1_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_fall2_r;
  reg                     pat_match_fall2_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_fall3_r;
  reg                     pat_match_fall3_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_rise0_r;
  reg                     pat_match_rise0_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_rise1_r;
  reg                     pat_match_rise1_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_rise2_r;
  reg                     pat_match_rise2_and_r;
  reg [DRAM_WIDTH-1:0]    pat_match_rise3_r;
  reg                     pat_match_rise3_and_r;
  wire [RD_SHIFT_LEN-1:0] pat_rise0 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_rise1 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_rise2 [3:0];
  wire [RD_SHIFT_LEN-1:0] pat_rise3 [3:0];
  reg [DQS_CNT_WIDTH:0]   rd_mux_sel_r;
  reg                     rd_active_posedge_r;
  reg                     rd_active_r;
  reg                     rden_wait_r;
  reg [RD_SHIFT_LEN-1:0]  sr_fall0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_fall1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise0_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise1_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_fall2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_fall3_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise2_r [DRAM_WIDTH-1:0];
  reg [RD_SHIFT_LEN-1:0]  sr_rise3_r [DRAM_WIDTH-1:0];
  assign dbg_phy_wrcal[0]    = pat_data_match_r;
  assign dbg_phy_wrcal[4:2]  = cal2_state_r[2:0];
generate
  if (nCK_PER_CLK == 4) begin: div4_clk
    assign dbg_phy_wrcal[12:5] = {sr_fall3_r[0][RD_SHIFT_LEN-1:0],
                                  sr_rise3_r[0][RD_SHIFT_LEN-1:0],
                                  sr_fall2_r[0][RD_SHIFT_LEN-1:0],
                                  sr_rise2_r[0][RD_SHIFT_LEN-1:0],
                                  sr_fall1_r[0][RD_SHIFT_LEN-1:0],
                                  sr_rise1_r[0][RD_SHIFT_LEN-1:0],
                                  sr_fall0_r[0][RD_SHIFT_LEN-1:0],
                                  sr_rise0_r[0][RD_SHIFT_LEN-1:0]};
  end else begin: div2_clk
    assign dbg_phy_wrcal[12:5] = {sr_fall1_r[0][RD_SHIFT_LEN-1:0],
                                  sr_rise1_r[0][RD_SHIFT_LEN-1:0],
                                  sr_fall0_r[0][RD_SHIFT_LEN-1:0],
                                  sr_rise0_r[0][RD_SHIFT_LEN-1:0]};
  end
endgenerate  
  assign dbg_phy_wrcal[15:13]= wrcal_dqs_cnt_r;
   assign po_stg2_wrcal_cnt = (cal2_done_r1) ? wrcal_regl_dqs_cnt : wrcal_dqs_cnt_r;
  always @(posedge clk) begin
    rd_mux_sel_r <= #TCQ wrcal_dqs_cnt_r;
  end
  generate
    genvar mux_i;
    for (mux_i = 0; mux_i < DRAM_WIDTH; mux_i = mux_i + 1) begin: gen_mux_rd
      always @(posedge clk) begin
        mux_rd_rise0_r[mux_i] <= #TCQ rd_data_rise0[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_fall0_r[mux_i] <= #TCQ rd_data_fall0[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_rise1_r[mux_i] <= #TCQ rd_data_rise1[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_fall1_r[mux_i] <= #TCQ rd_data_fall1[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_rise2_r[mux_i] <= #TCQ rd_data_rise2[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_fall2_r[mux_i] <= #TCQ rd_data_fall2[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_rise3_r[mux_i] <= #TCQ rd_data_rise3[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
        mux_rd_fall3_r[mux_i] <= #TCQ rd_data_fall3[DRAM_WIDTH*rd_mux_sel_r + 
                                                    mux_i];
      end
    end
  endgenerate
  always @(posedge clk)
    if (rst)
      wrcal_prech_req <= #TCQ 1'b0;
    else
      wrcal_prech_req <= #TCQ cal2_prech_req_r;
  generate
    genvar rd_i;
    if (nCK_PER_CLK == 4) begin: div4_logic_clk
      for (rd_i = 0; rd_i < DRAM_WIDTH; rd_i = rd_i + 1) begin: gen_sr
        always @(posedge clk) begin
          sr_rise0_r[rd_i] <= #TCQ mux_rd_rise0_r[rd_i];
          sr_fall0_r[rd_i] <= #TCQ mux_rd_fall0_r[rd_i];
          sr_rise1_r[rd_i] <= #TCQ mux_rd_rise1_r[rd_i];
          sr_fall1_r[rd_i] <= #TCQ mux_rd_fall1_r[rd_i];
          sr_rise2_r[rd_i] <= #TCQ mux_rd_rise2_r[rd_i];
          sr_fall2_r[rd_i] <= #TCQ mux_rd_fall2_r[rd_i];
          sr_rise3_r[rd_i] <= #TCQ mux_rd_rise3_r[rd_i];
          sr_fall3_r[rd_i] <= #TCQ mux_rd_fall3_r[rd_i];
        end
      end    
    end else begin: div2_logic_clk  
      for (rd_i = 0; rd_i < DRAM_WIDTH; rd_i = rd_i + 1) begin: gen_sr
        always @(posedge clk) begin
          sr_rise0_r[rd_i] <= #TCQ {sr_rise0_r[rd_i][RD_SHIFT_LEN-2:0],
                                     mux_rd_rise0_r[rd_i]};
          sr_fall0_r[rd_i] <= #TCQ {sr_fall0_r[rd_i][RD_SHIFT_LEN-2:0],
                                     mux_rd_fall0_r[rd_i]};
          sr_rise1_r[rd_i] <= #TCQ {sr_rise1_r[rd_i][RD_SHIFT_LEN-2:0],
                                     mux_rd_rise1_r[rd_i]};
          sr_fall1_r[rd_i] <= #TCQ {sr_fall1_r[rd_i][RD_SHIFT_LEN-2:0],
                                     mux_rd_fall1_r[rd_i]};
        end
      end
    end
  endgenerate
  always @(posedge clk)
    if (wrcal_start) begin
      rd_active_r         <= #TCQ phy_rddata_en;
      rd_active_posedge_r <= #TCQ phy_rddata_en & ~rd_active_r;
    end
generate
  if (nCK_PER_CLK == 2) begin: DIV2
    assign pat_rise0[3] = 2'b10;
    assign pat_fall0[3] = 2'b01;
    assign pat_rise1[3] = 2'b11;
    assign pat_fall1[3] = 2'b00;
    assign pat_rise0[2] = 2'b11;
    assign pat_fall0[2] = 2'b00;
    assign pat_rise1[2] = 2'b00;
    assign pat_fall1[2] = 2'b11;
    assign pat_rise0[1] = 2'b10;
    assign pat_fall0[1] = 2'b01;
    assign pat_rise1[1] = 2'b10;
    assign pat_fall1[1] = 2'b01;
    assign pat_rise0[0] = 2'b11;
    assign pat_fall0[0] = 2'b00;
    assign pat_rise1[0] = 2'b01;
    assign pat_fall1[0] = 2'b10;
  end else begin: DIV4
    assign pat_rise0[3] = 1'b1;
    assign pat_fall0[3] = 1'b0;
    assign pat_rise1[3] = 1'b1;
    assign pat_fall1[3] = 1'b0;
    assign pat_rise2[3] = 1'b0;
    assign pat_fall2[3] = 1'b1;
    assign pat_rise3[3] = 1'b1;
    assign pat_fall3[3] = 1'b0;
    assign pat_rise0[2] = 1'b1;
    assign pat_fall0[2] = 1'b0;
    assign pat_rise1[2] = 1'b0;
    assign pat_fall1[2] = 1'b1;
    assign pat_rise2[2] = 1'b1;
    assign pat_fall2[2] = 1'b0;
    assign pat_rise3[2] = 1'b0;
    assign pat_fall3[2] = 1'b1;
    assign pat_rise0[1] = 1'b1;
    assign pat_fall0[1] = 1'b0;
    assign pat_rise1[1] = 1'b1;
    assign pat_fall1[1] = 1'b0;
    assign pat_rise2[1] = 1'b0;
    assign pat_fall2[1] = 1'b1;
    assign pat_rise3[1] = 1'b0;
    assign pat_fall3[1] = 1'b1;
    assign pat_rise0[0] = 1'b1;
    assign pat_fall0[0] = 1'b0;
    assign pat_rise1[0] = 1'b0;
    assign pat_fall1[0] = 1'b1;
    assign pat_rise2[0] = 1'b1;
    assign pat_fall2[0] = 1'b0;
    assign pat_rise3[0] = 1'b1;
    assign pat_fall3[0] = 1'b0;
  end
endgenerate
  generate
    genvar pt_i;
    for (pt_i = 0; pt_i < DRAM_WIDTH; pt_i = pt_i + 1) begin: gen_pat_match
      always @(posedge clk) begin
        if (sr_rise0_r[pt_i] == pat_rise0[pt_i%4])
          pat_match_rise0_r[pt_i] <= #TCQ 1'b1;
        else
          pat_match_rise0_r[pt_i] <= #TCQ 1'b0;
        if (sr_fall0_r[pt_i] == pat_fall0[pt_i%4])
          pat_match_fall0_r[pt_i] <= #TCQ 1'b1;
        else
          pat_match_fall0_r[pt_i] <= #TCQ 1'b0;
        if (sr_rise1_r[pt_i] == pat_rise1[pt_i%4])
          pat_match_rise1_r[pt_i] <= #TCQ 1'b1;
        else
          pat_match_rise1_r[pt_i] <= #TCQ 1'b0;
        if (sr_fall1_r[pt_i] == pat_fall1[pt_i%4])
          pat_match_fall1_r[pt_i] <= #TCQ 1'b1;
        else
          pat_match_fall1_r[pt_i] <= #TCQ 1'b0;
        if (sr_rise2_r[pt_i] == pat_rise2[pt_i%4])
          pat_match_rise2_r[pt_i] <= #TCQ 1'b1;
        else
          pat_match_rise2_r[pt_i] <= #TCQ 1'b0;
        if (sr_fall2_r[pt_i] == pat_fall2[pt_i%4])
          pat_match_fall2_r[pt_i] <= #TCQ 1'b1;
        else
          pat_match_fall2_r[pt_i] <= #TCQ 1'b0;
        if (sr_rise3_r[pt_i] == pat_rise3[pt_i%4])
          pat_match_rise3_r[pt_i] <= #TCQ 1'b1;
        else
          pat_match_rise3_r[pt_i] <= #TCQ 1'b0;
        if (sr_fall3_r[pt_i] == pat_fall3[pt_i%4])
          pat_match_fall3_r[pt_i] <= #TCQ 1'b1;
        else
          pat_match_fall3_r[pt_i] <= #TCQ 1'b0;
      end
    end
  endgenerate
  always @(posedge clk) begin
    pat_match_rise0_and_r <= #TCQ &pat_match_rise0_r;
    pat_match_fall0_and_r <= #TCQ &pat_match_fall0_r;
    pat_match_rise1_and_r <= #TCQ &pat_match_rise1_r;
    pat_match_fall1_and_r <= #TCQ &pat_match_fall1_r;
    pat_match_rise2_and_r <= #TCQ &pat_match_rise2_r;
    pat_match_fall2_and_r <= #TCQ &pat_match_fall2_r;
    pat_match_rise3_and_r <= #TCQ &pat_match_rise3_r;
    pat_match_fall3_and_r <= #TCQ &pat_match_fall3_r;
    pat_data_match_r <= #TCQ (pat_match_rise0_and_r &&
                              pat_match_fall0_and_r &&
                              pat_match_rise1_and_r &&
                              pat_match_fall1_and_r &&
                              pat_match_rise2_and_r &&
                              pat_match_fall2_and_r &&
                              pat_match_rise3_and_r &&
                              pat_match_fall3_and_r);
  end
  always @(posedge clk)
    if (rst || ((cal2_state_r == CAL2_READ_WAIT) 
                && (cnt_rden_wait_r == 'b1)))
      cnt_rden_wait_r <= #TCQ 'b0;
    else if (rd_active_posedge_r)
        cnt_rden_wait_r <= #TCQ RDEN_WAIT_CNT;
    else if (cnt_rden_wait_r > 'b1)
        cnt_rden_wait_r <= #TCQ cnt_rden_wait_r - 1;
  always @(posedge clk)
    if (rst || (cnt_rden_wait_r == 'b1))
      rden_wait_r <= #TCQ 1'b0;
    else if (cal2_state_r != CAL2_READ_WAIT)
      rden_wait_r <= #TCQ 1'b1;
  always @(posedge clk) begin
    wrcal_pat_resume_r1 <= #TCQ wrcal_pat_resume_r;
    wrcal_pat_resume_r2 <= #TCQ wrcal_pat_resume_r1;
    wrcal_pat_resume_r3 <= #TCQ wrcal_pat_resume_r2;
  end
  assign wrcal_pat_resume = wrcal_pat_resume_r3;
   always @(posedge clk) begin
     if (rst) begin
       dqs_po_stg2_c_incdec   <= #TCQ 1'b0;
       dqs_po_en_stg2_c       <= #TCQ 1'b0;
     end else if (cal2_state_r == CAL2_CORSE_INC) begin
       dqs_po_stg2_c_incdec <= #TCQ 1'b1;
       dqs_po_en_stg2_c     <= #TCQ 1'b1;
     end else if (cal2_state_r == CAL2_CORSE_INC_WAIT) begin
       dqs_po_stg2_c_incdec <= #TCQ 1'b0;
       dqs_po_en_stg2_c     <= #TCQ 1'b0; 
     end
   end
   always @(posedge clk) begin
     if (rst || ((wrcal_regl_dqs_cnt == DQS_WIDTH-1)
              && (wrcal_done_cnt == 4'd1)))
       wrcal_done_cnt <= #TCQ 'b0;
     else if ((cal2_done_r && ~cal2_done_r1)
              || (wrcal_done_cnt == 4'd1))
       wrcal_done_cnt <= #TCQ 4'b1010;
     else if (wrcal_done_cnt > 'b0)
       wrcal_done_cnt <= #TCQ wrcal_done_cnt - 1;
   end
   always @(posedge clk) begin
     if (rst || (wrcal_done_cnt == 4'd0))
       wrcal_regl_dqs_cnt    <= #TCQ {DQS_CNT_WIDTH+1{1'b0}};
     else if (cal2_done_r && (wrcal_regl_dqs_cnt != DQS_WIDTH-1)
                  && (wrcal_done_cnt == 4'd1))
       wrcal_regl_dqs_cnt  <= #TCQ wrcal_regl_dqs_cnt + 1;
     else
       wrcal_regl_dqs_cnt  <= #TCQ wrcal_regl_dqs_cnt;
   end
   always @(posedge clk) begin
     if (rst || (wrcal_done_cnt == 4'd0)) begin
       dqs_po_stg2_load  <= #TCQ 'b0;
       dqs_po_stg2_reg_l <= #TCQ 'b0;
     end else if (cal2_done_r && (wrcal_regl_dqs_cnt <= DQS_WIDTH-1)
                  && (wrcal_done_cnt == 4'd2)) begin
       dqs_po_stg2_load  <= #TCQ 'b1;
       dqs_po_stg2_reg_l <= #TCQ {(cal2_corse_cnt[3*wrcal_regl_dqs_cnt+:3] + wl_po_coarse_cnt[3*wrcal_regl_dqs_cnt+:3]),
                                  wl_po_fine_cnt[6*wrcal_regl_dqs_cnt+:6]};
     end else begin
       dqs_po_stg2_load  <= #TCQ 'b0;
       dqs_po_stg2_reg_l <= #TCQ 'b0;
     end
   end     
  always @(posedge clk) begin
    if (rst) begin
      wrcal_dqs_cnt_r       <= #TCQ 'b0;
      cal2_done_r           <= #TCQ 1'b0;
      cal2_prech_req_r      <= #TCQ 1'b0;
      cal2_state_r          <= #TCQ CAL2_IDLE;
      cal2_corse_cnt        <= #TCQ {3*DQS_WIDTH{1'b0}};
      wrcal_pat_err         <= #TCQ 1'b0;
      wrcal_pat_resume_r      <= #TCQ 1'b0;
    end else begin
      cal2_prech_req_r <= #TCQ 1'b0;
      case (cal2_state_r)
        CAL2_IDLE:
          if (wrcal_start) begin
            if (SIM_CAL_OPTION == "SKIP_CAL")
              cal2_state_r <= #TCQ CAL2_DONE;
            else
              cal2_state_r <= #TCQ CAL2_READ_WAIT;
          end
        CAL2_READ_WAIT: begin
          wrcal_pat_resume_r <= #TCQ 1'b0;
          if (!rden_wait_r)
            cal2_state_r <= #TCQ CAL2_DETECT_MATCH;
        end
        CAL2_DETECT_MATCH: begin
          if (pat_data_match_r)
            cal2_state_r <= #TCQ CAL2_NEXT_DQS;
          else begin
              if (cal2_corse_cnt[3*wrcal_dqs_cnt_r+:3] == 'd0)
                cal2_state_r <= #TCQ CAL2_CORSE_INC;
              else
                cal2_state_r <= #TCQ CAL2_ERROR_TO;
           end
        end
        CAL2_CORSE_INC: begin
          cal2_state_r <= #TCQ CAL2_CORSE_INC_WAIT;
          cal2_corse_cnt[3*wrcal_dqs_cnt_r+:3]  <= 
            #TCQ cal2_corse_cnt[3*wrcal_dqs_cnt_r+:3] + 1;
        end
        CAL2_CORSE_INC_WAIT: begin
          if (cal2_corse_cnt[3*wrcal_dqs_cnt_r+:3] == 'd3) begin
            cal2_state_r <= #TCQ CAL2_READ_WAIT;
            wrcal_pat_resume_r <= #TCQ 1'b1;
          end else begin
            cal2_state_r <= #TCQ CAL2_CORSE_INC;
            wrcal_pat_resume_r <= #TCQ 1'b0;
          end
        end
        CAL2_NEXT_DQS: begin
          cal2_prech_req_r  <= #TCQ 1'b1;
          if (prech_done)
            if (((DQS_WIDTH == 1) || (SIM_CAL_OPTION == "FAST_CAL")) ||
                (wrcal_dqs_cnt_r == DQS_WIDTH-1)) begin
              cal2_state_r       <= #TCQ CAL2_DONE;
            end else begin
              wrcal_dqs_cnt_r    <= #TCQ wrcal_dqs_cnt_r + 1;
              cal2_state_r       <= #TCQ CAL2_READ_WAIT;
            end
        end
        CAL2_DONE:
          cal2_done_r <= #TCQ 1'b1;
        CAL2_ERROR_TO: begin
          wrcal_pat_resume_r <= #TCQ 1'b0;
          wrcal_pat_err    <= #TCQ 1'b1;
          cal2_state_r     <= #TCQ CAL2_ERROR_TO;
        end
      endcase
    end
  end
  always @(posedge clk)
    if (rst) begin 
      cal2_done_r1  <= #TCQ 1'b0;
      cal2_done_r2  <= #TCQ 1'b0;
      cal2_done_r3  <= #TCQ 1'b0;
    end else begin
      cal2_done_r1  <= #TCQ cal2_done_r;
      cal2_done_r2  <= #TCQ cal2_done_r1;
      cal2_done_r3  <= #TCQ cal2_done_r2;
    end 
  always @(posedge clk)
    if (rst)
      wrcal_done <= #TCQ 1'b0;
    else if ((wrcal_regl_dqs_cnt == DQS_WIDTH-1) && (wrcal_done_cnt == 'd1))
      wrcal_done <= #TCQ 1'b1;
endmodule
