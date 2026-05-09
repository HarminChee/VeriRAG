`timescale 1ns / 1ps
`timescale 1ns / 1ps
module altpcierd_cdma_ast_rx_64 #(
   parameter INTENDED_DEVICE_FAMILY="Cyclone IV GX",
   parameter ECRC_FORWARD_CHECK=0
   )(
   input clk_in,
   input srst,
   input[139:0]      rxdata,
   input[15:0]       rxdata_be,
   input             rx_stream_valid0,
   output            rx_stream_ready0,
   input              rx_ack0  ,
   input              rx_ws0   ,
   output reg         rx_req0  ,
   output reg [135:0] rx_desc0 ,
   output reg [63:0]  rx_data0 ,
   output reg [7:0]   rx_be0,
   output reg         rx_dv0   ,
   output             rx_dfr0  ,
   output             rx_ecrc_check_valid,
   output [15:0]      ecrc_bad_cnt
   );
   localparam RXFIFO_WIDTH=156;
   localparam RXFIFO_DEPTH=64;
   localparam RXFIFO_WIDTHU=6;
   wire [RXFIFO_WIDTHU-1:0]   rxfifo_usedw;
   wire [RXFIFO_WIDTH-1:0] rxfifo_d ;
   wire         rxfifo_full;
   wire         rxfifo_empty;
   wire         rxfifo_rreq;
   reg          rxfifo_rreq_reg;
   wire         rxfifo_wrreq;
   wire [RXFIFO_WIDTH-1:0] rxfifo_q ;
   reg  [RXFIFO_WIDTH-1:0] rxfifo_q_reg;
   reg          rx_stream_ready0_reg;
   wire[139:0]  rxdata_ecrc;
   wire[15:0]   rxdata_be_ecrc;
   wire         rx_stream_valid0_ecrc;
   wire         rx_stream_ready0_ecrc;
   reg          rx_ack_pending_del;
   wire         rx_ack_pending;
   reg          ctrlrx_single_cycle;
   wire         rx_rd_req;
   reg          rx_rd_req_del;
   wire         rx_sop;
   wire         rx_sop_p0;
   wire        rx_sop_p1;
   wire        rx_eop;
   wire        rx_eop_p0;
   reg         ctrlrx_3dw;
   reg         ctrlrx_3dw_reg;
   reg [9:0]  ctrlrx_length;
   reg [9:0]   ctrlrx_length_reg;
   reg [9:0]   ctrlrx_count_length_dqword;
   reg [9:0]   ctrlrx_count_length_dword;
   reg         ctrlrx_payload;
   reg         ctrlrx_payload_reg;
  wire        ctrlrx_qword_aligned;
   reg         ctrlrx_qword_aligned_reg;
   reg         ctrlrx_digest;
   reg         ctrlrx_digest_reg;
   reg [2:0]   ctrl_next_rx_req;
   reg [RXFIFO_WIDTHU-1:0] count_eop_in_rxfifo;
   wire        count_eop_nop;
   wire        last_eop_in_fifo;
   wire        tlp_in_rxfifo;
   reg         wait_rdreq_reg;
   wire        wait_rdreq;
   wire        rx_req_cycle;
   reg        ctrlrx_single_cycle_reg;
   reg        rx_req_del;
   reg        rx_req_phase2;
   reg        rx_sop_last;     
   reg        rx_sop2_last;   
   reg        rx_sop_hold2;   
   reg        count_eop_in_rxfifo_is_one;
   reg        count_eop_in_rxfifo_is_zero;
   wire       debug_3dw_aligned_dataless;
   wire       debug_3dw_nonaligned_dataless;
   wire       debug_4dw_aligned_dataless;
   wire       debug_4dw_nonaligned_dataless;
   wire       debug_3dw_aligned_withdata;
   wire       debug_3dw_nonaligned_withdata;
   wire       debug_4dw_aligned_withdata;
   wire       debug_4dw_nonaligned_withdata;
   reg[63:0]  rx_desc_hi_hold;
   wire       rx_data_fifo_almostfull;
   wire       pop_partial_tlp;
   reg        pop_partial_tlp_reg;
   wire[3:0]  zeros_4;   assign zeros_4 = 4'h0;
   assign debug_3dw_aligned_dataless     = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b00) & (rx_desc0[34]==1'b0);
   assign debug_3dw_nonaligned_dataless  = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b00) & (rx_desc0[34]==1'b1);
   assign debug_3dw_aligned_withdata     = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b10) & (rx_desc0[34]==1'b0);
   assign debug_3dw_nonaligned_withdata  = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b10) & (rx_desc0[34]==1'b1);
   assign debug_4dw_aligned_dataless     = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b01) & (rx_desc0[2]==1'b0);
   assign debug_4dw_nonaligned_dataless  = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b01) & (rx_desc0[2]==1'b1);
   assign debug_4dw_aligned_withdata     = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b11) & (rx_desc0[2]==1'b0);
   assign debug_4dw_nonaligned_withdata  = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b11) & (rx_desc0[2]==1'b1);
   always @(posedge clk_in) begin
      if (srst==1'b1)
         rx_stream_ready0_reg <=1'b1;
       else begin
         if ((rxfifo_usedw>(RXFIFO_DEPTH/2))) 
            rx_stream_ready0_reg <=1'b0;
         else
            rx_stream_ready0_reg <=1'b1;
       end
   end
   scfifo # (
             .add_ram_output_register ("ON")          ,
             .intended_device_family  (INTENDED_DEVICE_FAMILY),
             .lpm_numwords            (RXFIFO_DEPTH),
             .lpm_showahead           ("OFF")          ,
             .lpm_type                ("scfifo")       ,
             .lpm_width               (RXFIFO_WIDTH) ,
             .lpm_widthu              (RXFIFO_WIDTHU),
             .overflow_checking       ("ON")           ,
             .underflow_checking      ("ON")           ,
             .almost_full_value       (RXFIFO_DEPTH/2) ,
             .use_eab                 ("ON")
             )
             rx_data_fifo_128 (
            .clock (clk_in),
            .sclr  (srst ),
            .data  (rxfifo_d),
            .wrreq (rxfifo_wrreq),
            .rdreq (rxfifo_rreq),
            .q     (rxfifo_q),
            .empty (rxfifo_empty),
            .full  (rxfifo_full ),
            .usedw (rxfifo_usedw),
         .almost_full (rx_data_fifo_almostfull)
            ,
            .aclr (),
            .almost_empty ()
            );
   assign rx_stream_ready0 = (ECRC_FORWARD_CHECK==0)?rx_stream_ready0_reg:rx_stream_ready0_ecrc;
   assign rxfifo_wrreq     = (ECRC_FORWARD_CHECK==0)?rx_stream_valid0:rx_stream_valid0_ecrc;
   assign rxfifo_d         = (ECRC_FORWARD_CHECK==0)?{rxdata_be, rxdata}: {rxdata_be_ecrc, rxdata_ecrc};
   assign rx_rd_req =  ((rx_ack_pending==1'b0) && ((rx_dv0==1'b0) | (rx_ws0==1'b0)) ) ?1'b1:1'b0;  
   assign rxfifo_rreq = ((rxfifo_empty==1'b0)&&
                         (tlp_in_rxfifo==1'b1)&&
                         (rx_rd_req==1'b1) &&  (wait_rdreq==1'b0)
                         ) ?1'b1:1'b0;                             
   always @(posedge clk_in) begin
      rxfifo_q_reg <= rxfifo_q;
      if (srst==1'b1)  begin
          rx_rd_req_del   <= 1'b0;
          rxfifo_rreq_reg <= 1'b0;
      end
      else begin
          rx_rd_req_del   <= rx_rd_req;             
          rxfifo_rreq_reg <= rxfifo_rreq;           
      end
   end
   assign rx_sop = ((rxfifo_q[139]==1'b1) && (rxfifo_rreq_reg==1'b1))?1'b1:1'b0;
   assign rx_eop = ((rxfifo_q[138]==1'b1) && (rxfifo_rreq_reg==1'b1))?1'b1:1'b0;
   always @ (posedge clk_in) begin              
       rx_sop_last <= (rxfifo_rreq_reg==1'b1) ? rx_sop : rx_sop_last;
       rx_sop2_last <= (rxfifo_rreq_reg==1'b1) ? rx_sop_last : rx_sop2_last;
   end
   always @(posedge clk_in) begin
      if (srst==1'b1)
         rx_desc0 <=0;
      else  begin
         if (rx_sop_p0==1'b1)
            rx_desc_hi_hold  <= rxfifo_q[127:64];
         if (rx_sop_p1==1'b1) begin
            rx_desc0[63:0]    <=  rxfifo_q[127:64];
            rx_desc0[127:64]  <= rx_desc_hi_hold;
            rx_desc0[135:128] <= rxfifo_q[135:128];
         end
      end
   end
   always @(posedge clk_in) begin
      if ((rx_sop2_last==1'b1) & (ctrlrx_3dw==1'b1)& (ctrlrx_qword_aligned==1'b0)) begin                      
         rx_be0  <=  {rxfifo_q_reg[151:148], zeros_4};
      end
      else if ((rx_sop2_last==1'b1) & (ctrlrx_3dw==1'b0) & (ctrlrx_qword_aligned==1'b0)) begin               
         rx_be0  <=  {rxfifo_q[151:148], zeros_4};                                                              
      end
      else if ((ctrlrx_3dw==1'b1) & (ctrlrx_qword_aligned==1'b0)) begin                                      
          if (ctrlrx_count_length_dqword[9:1]==9'h0) begin                                                    
              case (ctrlrx_count_length_dqword[0])
                  1'b0: rx_be0 <= 8'h00;
                  1'b1: rx_be0 <= {zeros_4,  rxfifo_q_reg[155:152]};                                            
              endcase
          end
          else begin
              rx_be0   <= {rxfifo_q_reg[151:148], rxfifo_q_reg[155:152] };
          end
      end
      else begin                                                                                              
          if (ctrlrx_count_length_dqword[9:1]==9'h0) begin                                                     
              case (ctrlrx_count_length_dqword[0])
                  1'b0: rx_be0 <= 8'h00;
                  1'b1: rx_be0 <= {zeros_4,  rxfifo_q[155:152]};                                                 
              endcase
          end
          else begin
              rx_be0   <= {rxfifo_q[151:148], rxfifo_q[155:152] };
          end
      end
      if ((ctrlrx_3dw==1'b1) & (ctrlrx_qword_aligned==1'b0))
         rx_data0 <= {rxfifo_q_reg[95:64], rxfifo_q_reg[127:96]};    
      else
         rx_data0 <= {rxfifo_q[95:64], rxfifo_q[127:96]};
   end
   always @(posedge clk_in) begin
      if (srst==1'b1)
         rx_req0 <= 1'b0;
      else if (rx_ack0==1'b1)
         rx_req0 <= 1'b0;
      else if (rx_sop_p1==1'b1)
         rx_req0 <= 1'b1;
   end
   always @ (posedge clk_in) begin
      if (srst==1'b1) begin
          rx_ack_pending_del <= 1'b0;
          rx_req_del         <= 1'b0;
          rx_req_phase2      <= 1'b0;
      end
      else begin
          rx_req_del         <= rx_req0;
          rx_req_phase2      <= (rx_ack0==1'b1) ? 1'b0 : ((rx_req_del==1'b0) & (rx_req0==1'b1)) ? 1'b1: rx_req_phase2;  
          rx_ack_pending_del <= rx_ack_pending;
      end
   end
   assign rx_ack_pending = (rx_ack0==1'b1) ? 1'b0 :  (rx_req_phase2==1'b1) ? 1'b1 : rx_ack_pending_del;  
   always @(posedge clk_in) begin
      if (srst==1'b1)  begin
          ctrlrx_count_length_dqword <= 0;
      end
      else begin
           if ((rx_sop_last==1'b1) & (rx_rd_req_del==1'b1))                     
               ctrlrx_count_length_dword <= ctrlrx_length;
           else if ((ctrlrx_count_length_dword>1) & (rx_rd_req_del==1'b1))      
               ctrlrx_count_length_dword <= ctrlrx_count_length_dword - 2;
           if ((rx_sop_p1==1'b1) & (rx_rd_req_del)) begin
              if (ctrlrx_payload==1'b1) begin
                  if (ctrlrx_qword_aligned==1'b1)                     
                     ctrlrx_count_length_dqword <= ctrlrx_length;     
                  else
                     ctrlrx_count_length_dqword <= ctrlrx_length+1;   
               end
               else begin
                   ctrlrx_count_length_dqword <= 0;
               end
           end
           else if ((ctrlrx_count_length_dqword>1) & (rx_rd_req_del==1'b1))  
                 ctrlrx_count_length_dqword <= ctrlrx_count_length_dqword-2;
           else if (rx_rd_req_del==1'b1)
                 ctrlrx_count_length_dqword <= 0;
      end
   end
   assign rx_dfr0 = (ctrlrx_count_length_dqword>0);
   always @(posedge clk_in) begin
      rx_dv0 <=  (rx_rd_req_del==1'b1) ? rx_dfr0 : rx_dv0 ;    
   end
   assign wait_rdreq = ((rx_eop_p0==1'b1) && (rx_req_cycle==1'b1))?1'b1:
                       ((wait_rdreq_reg==1'b1) && (rx_req_cycle==1'b1))?1'b1:1'b0;
   always @(posedge clk_in) begin
      if (srst==1'b1)
         wait_rdreq_reg <= 1'b0;
     else if (rx_eop_p0==1'b1) begin
         if (rx_req_cycle==1'b1)
            wait_rdreq_reg <= 1'b1;
         else
            wait_rdreq_reg <= 1'b0;
      end
      else if ((wait_rdreq_reg ==1'b1)&&(rx_req_cycle==1'b0))
         wait_rdreq_reg <= 1'b0;
   end
   assign rx_req_cycle = (
                          (rx_sop_hold2==1'b1)) ? 1'b1 : 1'b0;
   always @(posedge clk_in) begin
      if (srst==1'b1) begin
         ctrl_next_rx_req <= 0;
         rx_sop_hold2     <= 1'b0;
      end
      else begin
         if (rx_rd_req_del==1'b1) begin
            ctrl_next_rx_req[0] <= rx_sop_p0;
            ctrl_next_rx_req[1] <= ctrl_next_rx_req[0];
            ctrl_next_rx_req[2] <= ctrl_next_rx_req[1];
            rx_sop_hold2        <= (rx_sop_p0==1'b1) || (ctrl_next_rx_req[0]==1'b1) ? 1'b1 : 1'b0;
         end
      end
   end
   assign rx_sop_p0 = (rx_sop==1'b1) ? 1'b1 : 1'b0;  
   assign rx_eop_p0 = (rx_eop==1'b1) ? 1'b1 : 1'b0;  
   assign rx_sop_p1 =  (rx_sop_last==1'b1) & (rxfifo_rreq_reg==1'b1);  
   always @ (posedge clk_in) begin
      if (srst==1'b1) begin
         ctrlrx_single_cycle      <= 1'b0;
         ctrlrx_3dw               <= 1'b0;
         ctrlrx_digest            <= 1'b0;
         ctrlrx_length            <= 0;
         ctrlrx_qword_aligned_reg <= 1'b0;
      end
      else begin
          if ((rxfifo_rreq==1'b1) & (rxfifo_q[139]==1'b1)) begin                      
               ctrlrx_single_cycle  <= (rxfifo_q[105:96]==10'h1) ? 1'b1 : 1'b0;       
               ctrlrx_payload       <= (rxfifo_q[126]==1'b1)     ? 1'b1 : 1'b0;       
               ctrlrx_3dw           <= (rxfifo_q[125]==1'b0)     ? 1'b1 : 1'b0;       
               ctrlrx_digest        <= (rxfifo_q[111]==1'b1)     ? 1'b1 : 1'b0;
               ctrlrx_length[9:0]   <= (rxfifo_q[126]==1'b1)     ? rxfifo_q[105:96] : 10'h0;
          end
          ctrlrx_qword_aligned_reg <= ctrlrx_qword_aligned;
      end
  end
  assign ctrlrx_qword_aligned = (rx_sop_p1==1'b1)? ((((ctrlrx_3dw==1'b1) && (rxfifo_q[98]==0)) ||
                                                     ((ctrlrx_3dw==1'b0) && (rxfifo_q[66]==0))) ? 1'b1 : 0) : ctrlrx_qword_aligned_reg;
   assign count_eop_nop = (((rxfifo_wrreq==1'b1)&&(rxfifo_d[138]==1'b1)) &&
                           ((rxfifo_rreq_reg==1'b1)&&(rxfifo_q[138]==1'b1))) ? 1'b1:1'b0;
   assign last_eop_in_fifo = ((count_eop_in_rxfifo_is_one==1'b1) &&
                              (count_eop_nop==1'b0)&&
                              (rxfifo_rreq_reg==1'b1)&&
                              (rxfifo_q[138]==1'b1)) ?1'b1:1'b0;
   assign tlp_in_rxfifo =((pop_partial_tlp==1'b1) ||                         
                          ((count_eop_in_rxfifo_is_zero==1'b0) &&
                           (last_eop_in_fifo==1'b0))) ?  1'b1:1'b0;
   assign  pop_partial_tlp = (count_eop_in_rxfifo_is_zero==1'b0) ? 1'b0 :
                             (((count_eop_in_rxfifo_is_zero==1'b1) & (rx_data_fifo_almostfull==1'b1)) ? 1'b1 : pop_partial_tlp_reg);
   always @(posedge clk_in) begin
      if (srst==1'b1) begin
          pop_partial_tlp_reg <= 1'b0;
      end
      else begin
          pop_partial_tlp_reg <= pop_partial_tlp;
      end
   end
   always @(posedge clk_in) begin
      if (srst==1'b1) begin
         count_eop_in_rxfifo <= 0;
         count_eop_in_rxfifo_is_one <= 1'b0;
         count_eop_in_rxfifo_is_zero <= 1'b1;
      end
      else if (count_eop_nop==1'b0) begin
         if ((rxfifo_wrreq==1'b1)&&(rxfifo_d[138]==1'b1)) begin
            count_eop_in_rxfifo         <= count_eop_in_rxfifo+1;
            count_eop_in_rxfifo_is_one  <= (count_eop_in_rxfifo==0) ? 1'b1 : 1'b0;
            count_eop_in_rxfifo_is_zero <= 1'b0;
         end
         else if ((rxfifo_rreq_reg==1'b1)&&(rxfifo_q[138]==1'b1)) begin
            count_eop_in_rxfifo         <= count_eop_in_rxfifo-1;
            count_eop_in_rxfifo_is_one  <= (count_eop_in_rxfifo==2) ? 1'b1 : 1'b0;
            count_eop_in_rxfifo_is_zero <= (count_eop_in_rxfifo==1) ? 1'b1 : 1'b0;
         end
      end
   end
   generate begin
      if (ECRC_FORWARD_CHECK==1) begin
         altpcierd_cdma_ecrc_check_64
           altpcierd_cdma_ecrc_check_64_i (
            .rxdata(rxdata),
            .rxdata_be(rxdata_be),
            .rx_stream_ready0(rx_stream_ready0_reg),
            .rx_stream_valid0(rx_stream_valid0),
            .rxdata_ecrc(rxdata_ecrc),
            .rxdata_be_ecrc(rxdata_be_ecrc),
            .rx_stream_ready0_ecrc(rx_stream_ready0_ecrc),
            .rx_stream_valid0_ecrc(rx_stream_valid0_ecrc),
            .rx_ecrc_check_valid(rx_ecrc_check_valid),
            .ecrc_bad_cnt(ecrc_bad_cnt),
            .clk_in(clk_in),
            .srst(srst)
           );
      end
      else begin
         assign rxdata_ecrc = rxdata;
         assign rxdata_be_ecrc = rxdata_be;
         assign rx_stream_ready0_ecrc = rx_stream_ready0;
         assign rx_ecrc_check_valid = 1'b1;
         assign ecrc_bad_cnt        = 0;
      end
   end
   endgenerate
endmodule
