`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v4_0_ddr_phy_ck_addr_cmd_delay #
  (
   parameter TCQ            = 100,
   parameter tCK            = 3636,
   parameter DQS_CNT_WIDTH  = 3,
   parameter N_CTL_LANES    = 3,
   parameter SIM_CAL_OPTION = "NONE"
   )
  (
   input                        clk,
   input                        rst,
   input                        cmd_delay_start,
   output reg [N_CTL_LANES-1:0] ctl_lane_cnt,
   output reg       po_stg2_f_incdec,
   output reg       po_en_stg2_f,
   output reg       po_stg2_c_incdec,
   output reg       po_en_stg2_c,
   output           po_ck_addr_cmd_delay_done
   );
   localparam TAP_CNT_LIMIT = 63;
   localparam FREQ_REF_DIV           = (tCK > 5000 ? 4 :
                                        tCK > 2500 ? 2 : 1);
   localparam integer PHASER_TAP_RES = ((tCK/2)/64);
   localparam CALC_TAP_CNT = (tCK >= 1250) ? 350 : 300;
   localparam TAP_CNT = 0;
   localparam TAP_DEC = (SIM_CAL_OPTION == "FAST_CAL") ? 0 : 29;
   reg       delay_dec_done;
   reg       delay_done_r1;
   reg       delay_done_r2;
   reg       delay_done_r3;
   reg       delay_done_r4 ;
   reg [5:0] delay_cnt_r;
   reg [5:0] delaydec_cnt_r;
   reg       po_cnt_inc;
   reg       po_cnt_dec;
   reg [3:0] wait_cnt_r;
   assign po_ck_addr_cmd_delay_done = ((TAP_CNT == 0) && (TAP_DEC == 0)) ? 1'b1 : delay_done_r4;
   always @(posedge clk) begin
     if (rst || po_cnt_dec || po_cnt_inc)
       wait_cnt_r <= #TCQ 'd8;
     else if (cmd_delay_start && (wait_cnt_r > 'd0))
       wait_cnt_r <= #TCQ wait_cnt_r - 1;
   end
   always @(posedge clk) begin
     if (rst || (delaydec_cnt_r > 6'd0) || (delay_cnt_r == 'd0) || (TAP_DEC == 0))
       po_cnt_inc      <= #TCQ 1'b0;
     else if ((delay_cnt_r > 'd0) && (wait_cnt_r == 'd1))
       po_cnt_inc      <= #TCQ 1'b1;
     else
       po_cnt_inc      <= #TCQ 1'b0;
   end
   always @(posedge clk) begin
     if (rst || (delaydec_cnt_r == 'd0))
       po_cnt_dec      <= #TCQ 1'b0;
     else if (cmd_delay_start && (delaydec_cnt_r > 'd0) && (wait_cnt_r == 'd1))
       po_cnt_dec      <= #TCQ 1'b1;
     else
       po_cnt_dec      <= #TCQ 1'b0;
   end
   always @(posedge clk) begin
     if (rst) begin
       po_stg2_f_incdec <= #TCQ 1'b0;
       po_en_stg2_f     <= #TCQ 1'b0;
       po_stg2_c_incdec <= #TCQ 1'b0;
       po_en_stg2_c     <= #TCQ 1'b0;
     end else begin
       if (po_cnt_dec) begin
         po_stg2_f_incdec <= #TCQ 1'b0;
         po_en_stg2_f     <= #TCQ 1'b1;
       end else begin
         po_stg2_f_incdec <= #TCQ 1'b0;
         po_en_stg2_f     <= #TCQ 1'b0;
       end
       if (po_cnt_inc) begin
         po_stg2_c_incdec <= #TCQ 1'b1;
         po_en_stg2_c     <= #TCQ 1'b1;
       end else begin
         po_stg2_c_incdec <= #TCQ 1'b0;
         po_en_stg2_c     <= #TCQ 1'b0;
       end
     end
   end
   always @(posedge clk) begin
     if (rst || (tCK >= 2500) || (SIM_CAL_OPTION == "FAST_CAL"))
       delay_cnt_r  <= #TCQ 'd0;
     else if ((delaydec_cnt_r > 6'd0) ||((delay_cnt_r == 6'd0) && (ctl_lane_cnt != N_CTL_LANES-1)))
       delay_cnt_r  <= #TCQ 'd1;
     else if (po_cnt_inc && (delay_cnt_r > 6'd0))
       delay_cnt_r  <= #TCQ delay_cnt_r - 1;
   end
   always @(posedge clk) begin
     if (rst || ~cmd_delay_start ||((delaydec_cnt_r == 6'd0) && (delay_cnt_r == 6'd0) && (ctl_lane_cnt != N_CTL_LANES-1)))
       delaydec_cnt_r  <= #TCQ TAP_DEC;
     else if (po_cnt_dec && (delaydec_cnt_r > 6'd0))
       delaydec_cnt_r  <= #TCQ delaydec_cnt_r - 1;
   end
   always @(posedge clk) begin
     if (rst || ~cmd_delay_start )
       ctl_lane_cnt <= #TCQ 6'b0;
     else if (~delay_dec_done && (ctl_lane_cnt == N_CTL_LANES-1) && (delaydec_cnt_r == 6'd1))
       ctl_lane_cnt <= #TCQ ctl_lane_cnt;
     else if ((ctl_lane_cnt != N_CTL_LANES-1) && (delaydec_cnt_r == 6'd0) && (delay_cnt_r == 'd0))
       ctl_lane_cnt <= #TCQ ctl_lane_cnt + 1;
   end
   always @(posedge clk) begin
     if (rst || ~cmd_delay_start)  begin
       delay_dec_done    <= #TCQ 1'b0;
     end else if (((TAP_CNT == 0) && (TAP_DEC == 0)) ||
                 ((delaydec_cnt_r == 6'd0) && (delay_cnt_r == 'd0) && (ctl_lane_cnt == N_CTL_LANES-1))) begin
       delay_dec_done    <= #TCQ 1'b1;
     end
   end
   always @(posedge clk) begin
     delay_done_r1 <= #TCQ delay_dec_done;
     delay_done_r2 <= #TCQ delay_done_r1;
     delay_done_r3 <= #TCQ delay_done_r2;
     delay_done_r4 <= #TCQ delay_done_r3;
   end
endmodule
