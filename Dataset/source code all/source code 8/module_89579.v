`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v1_9_ddr_phy_wrlvl_off_delay #
  (
   parameter TCQ           = 100,
   parameter tCK           = 3636,
   parameter nCK_PER_CLK   = 2, 
   parameter CLK_PERIOD    = 4,
   parameter PO_INITIAL_DLY= 46,
   parameter DQS_CNT_WIDTH = 3,
   parameter DQS_WIDTH     = 8, 
   parameter N_CTL_LANES   = 3
   )
  (
   input                        clk,
   input                        rst,
   input                        pi_fine_dly_dec_done,
   input                        cmd_delay_start,
   output reg [DQS_CNT_WIDTH:0] ctl_lane_cnt,
   output reg                   po_s2_incdec_f,
   output reg                   po_en_s2_f,
   output reg                   po_s2_incdec_c,
   output reg                   po_en_s2_c,
   output                      po_ck_addr_cmd_delay_done,
   output                      po_dec_done,
   output                      phy_ctl_rdy_dly
   );
  localparam TAP_LIMIT = 63; 
 localparam TDQSS_DLY = (tCK > 2500 )? 2: 1;
   reg       delay_done;
   reg       delay_done_r1;
   reg       delay_done_r2;
   reg       delay_done_r3;
   reg       delay_done_r4;
   reg [5:0] po_delay_cnt_r;
   reg       po_cnt_inc;
   reg       cmd_delay_start_r1;
   reg       cmd_delay_start_r2;
   reg       cmd_delay_start_r3;
   reg       cmd_delay_start_r4;
   reg       cmd_delay_start_r5;
   reg       cmd_delay_start_r6;
   reg 	     po_delay_done;
   reg       po_delay_done_r1;
   reg       po_delay_done_r2;
   reg       po_delay_done_r3;
   reg       po_delay_done_r4;
   reg 	     pi_fine_dly_dec_done_r;
   reg 	     po_en_stg2_c;
   reg       po_en_stg2_f;
   reg 	     po_stg2_incdec_c;
   reg 	     po_stg2_f_incdec;
   reg [DQS_CNT_WIDTH:0] lane_cnt_dqs_c_r;
   reg [DQS_CNT_WIDTH:0] lane_cnt_po_r;
   reg [5:0] 		 delay_cnt_r;
   always @(posedge clk) begin
      cmd_delay_start_r1     <= #TCQ cmd_delay_start;
      cmd_delay_start_r2     <= #TCQ cmd_delay_start_r1;
      cmd_delay_start_r3     <= #TCQ cmd_delay_start_r2;
      cmd_delay_start_r4     <= #TCQ cmd_delay_start_r3;
      cmd_delay_start_r5     <= #TCQ cmd_delay_start_r4;
      cmd_delay_start_r6     <= #TCQ cmd_delay_start_r5;
      pi_fine_dly_dec_done_r <= #TCQ pi_fine_dly_dec_done;
    end 
   assign phy_ctl_rdy_dly  = cmd_delay_start_r6; 
  assign po_dec_done = (PO_INITIAL_DLY == 0) ? 1 : po_delay_done_r4;
  always @(posedge clk)
    if (rst || ~cmd_delay_start_r6 || po_delay_done) begin
      po_stg2_f_incdec  <= #TCQ 1'b0;
      po_en_stg2_f    <= #TCQ 1'b0;
    end else if (po_delay_cnt_r > 6'd0) begin 
      po_en_stg2_f    <= #TCQ ~po_en_stg2_f;
    end
  always @(posedge clk)
    if (rst || ~cmd_delay_start_r6 || (po_delay_cnt_r == 6'd0))
      po_delay_cnt_r  <= #TCQ (PO_INITIAL_DLY - 31);
    else if ( po_en_stg2_f && (po_delay_cnt_r > 6'd0))
      po_delay_cnt_r  <= #TCQ po_delay_cnt_r - 1;
  always @(posedge clk)
    if (rst) 
      lane_cnt_po_r  <= #TCQ 'd0;
    else if ( po_en_stg2_f  && (po_delay_cnt_r == 6'd1))
      lane_cnt_po_r  <= #TCQ lane_cnt_po_r + 1;
  always @(posedge clk)
    if (rst || ~cmd_delay_start_r6 )
      po_delay_done    <= #TCQ 1'b0;
    else if ((po_delay_cnt_r == 6'd1) && (lane_cnt_po_r ==1'b0))
      po_delay_done    <= #TCQ 1'b1;
  always @(posedge clk) begin
    po_delay_done_r1 <= #TCQ po_delay_done;
    po_delay_done_r2 <= #TCQ po_delay_done_r1;
    po_delay_done_r3 <= #TCQ po_delay_done_r2;
    po_delay_done_r4 <= #TCQ po_delay_done_r3;
  end
  always @(posedge clk) begin
    po_s2_incdec_f <= #TCQ po_stg2_f_incdec;
    po_en_s2_f <= #TCQ po_en_stg2_f;
  end 
   assign po_ck_addr_cmd_delay_done = (TDQSS_DLY == 0) ? pi_fine_dly_dec_done_r 
                                     : delay_done_r4;
  always @(posedge clk)
    if (rst || ~pi_fine_dly_dec_done_r || delay_done) begin
      po_stg2_incdec_c   <= #TCQ 1'b1;
      po_en_stg2_c    <= #TCQ 1'b0;
    end else if (delay_cnt_r > 6'd0) begin 
      po_en_stg2_c    <= #TCQ ~po_en_stg2_c;
    end
  always @(posedge clk)
    if (rst || ~pi_fine_dly_dec_done_r || (delay_cnt_r == 6'd0)) 
     delay_cnt_r  <= #TCQ TDQSS_DLY;
    else if ( po_en_stg2_c && (delay_cnt_r > 6'd0))
      delay_cnt_r  <= #TCQ delay_cnt_r - 1;
  always @(posedge clk)
    if (rst) 
      lane_cnt_dqs_c_r  <= #TCQ 'd0;
    else if ( po_en_stg2_c && (delay_cnt_r == 6'd1))
      lane_cnt_dqs_c_r  <= #TCQ lane_cnt_dqs_c_r + 1;
  always @(posedge clk)
    if (rst || ~pi_fine_dly_dec_done_r)
      delay_done    <= #TCQ 1'b0;
    else if ((delay_cnt_r == 6'd1) && (lane_cnt_dqs_c_r == 1'b0))
      delay_done    <= #TCQ 1'b1;
   always @(posedge clk) begin
     delay_done_r1 <= #TCQ delay_done;
     delay_done_r2 <= #TCQ delay_done_r1;
     delay_done_r3 <= #TCQ delay_done_r2;
     delay_done_r4 <= #TCQ delay_done_r3;
   end
  always @(posedge clk) begin
    po_s2_incdec_c <= #TCQ po_stg2_incdec_c;
    po_en_s2_c <= #TCQ po_en_stg2_c;
    ctl_lane_cnt <= #TCQ lane_cnt_dqs_c_r; 
  end 
endmodule
