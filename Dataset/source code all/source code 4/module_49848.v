`timescale 1ns / 1ps
`timescale 1ns / 1ps
module altpcierd_cdma_ast_rx_128 #(
   parameter ECRC_FORWARD_CHECK=0
   )(
   input clk_in,
   input rstn,
   input[139:0]      rxdata,
   input[15:0]       rxdata_be,
   input             rx_stream_valid0,
   output            rx_stream_ready0,
   input              rx_ack0  ,
   input              rx_ws0   ,
   output reg         rx_req0  ,
   output reg [135:0] rx_desc0 ,
   output reg [127:0] rx_data0 ,
   output reg [15:0]  rx_be0,
   output reg         rx_dv0   ,
   output reg         rx_dfr0  ,
   output             rx_ecrc_check_valid,
   output [15:0]      ecrc_bad_cnt
   );
   localparam RXFIFO_WIDTH=156;  
   localparam RXFIFO_DEPTH=1024;
   localparam RXFIFO_WIDTHU=10;
   wire [RXFIFO_WIDTHU-1:0]   rxfifo_usedw;
   wire [155:0] rxfifo_d ;
   wire         rxfifo_full;
   wire         rxfifo_empty;
   wire         rxfifo_rreq;
   reg          rxfifo_rreq_reg;
   wire         rxfifo_wrreq;
   wire [155:0] rxfifo_q ;
   reg  [155:0] rxfifo_q_reg;
   reg          rx_stream_ready0_reg;
   wire[139:0]  rxdata_ecrc;
   wire[15:0]   rxdata_be_ecrc;
   wire         rx_stream_valid0_ecrc;
   wire         rx_stream_ready0_ecrc;
   wire         ctrlrx_single_cycle;
   reg          rx_dfr_reg;
   wire         rx_dfr_digest;
   wire         rx_sop;          
   reg          rx_sop_next;
   wire         rx_sop_p0;       
   reg          rx_sop_p1;
   wire         rx_eop;          
   reg          rx_eop_next;
   wire         rx_eop_p0;       
   reg          rx_eop_p1;
   wire         ctrlrx_3dw;                    
   reg          ctrlrx_3dw_reg;
   reg          ctrlrx_3dw_del;
   wire         ctrlrx_3dw_nonaligned;
   reg          ctrlrx_3dw_nonaligned_reg;
   wire[1:0]    ctrlrx_dw_addroffeset;         
   reg [1:0]    ctrlrx_dw_addroffeset_reg;
   wire [9:0]   ctrlrx_length;                 
   reg [9:0]    ctrlrx_length_reg;
   reg [7:0]    ctrlrx_count_length_dqword;
   reg [9:0]    ctrlrx_count_length_dword;
   wire         ctrlrx_payload;
   reg          ctrlrx_payload_reg;
   wire         ctrlrx_qword_aligned;          
   reg          ctrlrx_qword_aligned_reg;
   wire         ctrlrx_digest;                 
   reg          ctrlrx_digest_reg;
   reg [2:0]    ctrl_next_rx_req;
   reg [RXFIFO_WIDTHU-1:0] count_eop_in_rxfifo;   
   wire         count_eop_nop;
   wire         last_eop_in_fifo;
   wire         tlp_in_rxfifo;             
   reg          wait_rdreq_reg;
   wire         wait_rdreq;
   wire         rx_req_cycle;
   reg          rx_ack_pending_del;
   wire         rx_ack_pending;
   reg          rx_req_del;
   reg          rx_req_phase2;
   reg          ctrlrx_single_cycle_reg;
   wire         rx_rd_req;
   reg          rx_rd_req_del;
   reg          rx_sop_last;              
   reg[15:0]    data_tail_be_mask;        
   reg          ctrlrx_count_length_dqword_zero;
   reg          insert_extra_dfr_cycle;
   reg          need_extra_dfr_cycle;
   reg          got_eop;
   wire[3:0]    zeros_4;   assign zeros_4  = 4'h0;
   wire[7:0]    zeros_8;   assign zeros_8  = 8'h0;
   wire[11:0]   zeros_12;  assign zeros_12 = 12'h0;
   wire debug_3dw_aligned_dataless;
   wire debug_3dw_nonaligned_dataless;
   wire debug_4dw_aligned_dataless;
   wire debug_4dw_nonaligned_dataless;
   wire debug_3dw_aligned_withdata;
   wire debug_3dw_nonaligned_withdata;
   wire debug_4dw_aligned_withdata;
   wire debug_4dw_nonaligned_withdata;
   wire debug_3dw_dqw_nonaligned_withdata;
   wire debug_4dw_dqw_nonaligned_withdata;
   wire debug_3dw_dqw_aligned_withdata;
   wire debug_4dw_dqw_aligned_withdata;
   assign debug_3dw_aligned_dataless     = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b00) & (rx_desc0[34]==1'b0);
   assign debug_3dw_nonaligned_dataless  = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b00) & (rx_desc0[34]==1'b1);
   assign debug_3dw_aligned_withdata     = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b10) & (rx_desc0[34]==1'b0);
   assign debug_3dw_nonaligned_withdata  = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b10) & (rx_desc0[34]==1'b1);
   assign debug_4dw_aligned_dataless     = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b01) & (rx_desc0[2]==1'b0);
   assign debug_4dw_nonaligned_dataless  = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b01) & (rx_desc0[2]==1'b1);
   assign debug_4dw_aligned_withdata     = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b11) & (rx_desc0[2]==1'b0);
   assign debug_4dw_nonaligned_withdata  = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b11) & (rx_desc0[2]==1'b1);
   assign debug_3dw_dqw_nonaligned_withdata  = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b10) & (rx_desc0[35]==1'b1);
   assign debug_4dw_dqw_nonaligned_withdata  = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b11) & (rx_desc0[3] ==1'b1);
   assign debug_3dw_dqw_aligned_withdata     = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b10) & (rx_desc0[35]==1'b0);
   assign debug_4dw_dqw_aligned_withdata     = (rx_ack0==1'b1) & (rx_desc0[126:125]==2'b11) & (rx_desc0[3] ==1'b0);
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0)
         rx_stream_ready0_reg <=1'b1;
       else begin
         if ((rxfifo_usedw> (RXFIFO_DEPTH/2))) 
            rx_stream_ready0_reg <=1'b0;
         else
            rx_stream_ready0_reg <=1'b1;
       end
   end
   scfifo # (
             .add_ram_output_register ("ON")          ,
             .intended_device_family  ("Stratix IV"),
             .lpm_numwords            (RXFIFO_DEPTH),
             .lpm_showahead           ("OFF")          ,
             .lpm_type                ("scfifo")       ,
             .lpm_width               (RXFIFO_WIDTH) ,
             .lpm_widthu              (RXFIFO_WIDTHU),
             .overflow_checking       ("OFF")           ,
             .underflow_checking      ("OFF")           ,
             .use_eab                 ("ON")
             )
             rx_data_fifo_128 (
            .clock (clk_in),
            .sclr  (~rstn ),
            .data  (rxfifo_d),
            .wrreq (rxfifo_wrreq),
            .rdreq (rxfifo_rreq),
            .q     (rxfifo_q),
            .empty (rxfifo_empty),
            .full  (rxfifo_full ),
            .usedw (rxfifo_usedw)
            ,
            .aclr (),
            .almost_empty (),
            .almost_full ()
            );
   assign rx_stream_ready0 = (ECRC_FORWARD_CHECK==0)?rx_stream_ready0_reg:rx_stream_ready0_ecrc;
   assign rxfifo_wrreq     = (ECRC_FORWARD_CHECK==0)?rx_stream_valid0:rx_stream_valid0_ecrc;
   assign rxfifo_d         = (ECRC_FORWARD_CHECK==0)?{rxdata_be, rxdata}: {rxdata_be_ecrc, rxdata_ecrc};
   assign rx_rd_req =  ((rx_ack_pending==1'b0) && ((rx_dv0==1'b0) | (rx_ws0==1'b0))) ?1'b1:1'b0;
   assign rxfifo_rreq = ((rxfifo_empty==1'b0)&&
                         (tlp_in_rxfifo==1'b1)&&
                         (rx_rd_req==1'b1) &&  (wait_rdreq==1'b0)) ?1'b1:1'b0;
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0) begin
          rx_rd_req_del   <= 1'b0;
          rxfifo_rreq_reg <= 1'b0;
      end
      else begin
          rx_rd_req_del   <= rx_rd_req;
          rxfifo_rreq_reg <= rxfifo_rreq;
      end
   end
   always @(posedge clk_in) begin
        rxfifo_q_reg    <= rxfifo_q;
   end
   assign rx_sop = ((rxfifo_q[139]==1'b1) && (rxfifo_rreq_reg==1'b1))?1'b1:1'b0;
   assign rx_eop = ((rxfifo_q[136]==1'b1) && (rxfifo_rreq_reg==1'b1))?1'b1:1'b0;
   always @ (posedge clk_in) begin              
       rx_sop_last <= (rxfifo_rreq_reg==1'b1) ? rx_sop : rx_sop_last;
   end
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0) begin
          got_eop <= 1'b0;
          rx_desc0  <=0;
      end
      else begin
          got_eop <= ((rx_sop==1'b1) && (rx_eop==1'b0)) ? 1'b0 : rx_eop ? 1'b1 : got_eop;
         if ((rx_sop_p0==1'b1) )
            rx_desc0[135:0] <= rxfifo_q[135:0];
      end
   end
  always @(posedge clk_in) begin
       if (ctrlrx_3dw_del==1'b1) begin    
           case (ctrlrx_dw_addroffeset_reg)
               2'h0: rx_data0 <= {rxfifo_q[31:0], rxfifo_q[63:32], rxfifo_q[95:64], rxfifo_q[127:96]};                  
               2'h1: rx_data0 <= {rxfifo_q[95:64], rxfifo_q[127:96], rxfifo_q_reg[31:0], rxfifo_q_reg[63:32]};          
               2'h2: rx_data0 <= {rxfifo_q[95:64], rxfifo_q[127:96], rxfifo_q_reg[31:0], rxfifo_q_reg[63:32]};          
               2'h3: rx_data0 <= {rxfifo_q_reg[31:0], rxfifo_q_reg[63:32], rxfifo_q_reg[95:64], rxfifo_q_reg[127:96]};  
           endcase
       end
       else begin
           case (ctrlrx_dw_addroffeset_reg)
               2'h0: rx_data0 <= {rxfifo_q[31:0], rxfifo_q[63:32], rxfifo_q[95:64], rxfifo_q[127:96]};                  
               2'h1: rx_data0 <= {rxfifo_q[31:0], rxfifo_q[63:32], rxfifo_q[95:64], rxfifo_q[127:96]};                  
               2'h2: rx_data0 <= {rxfifo_q[95:64], rxfifo_q[127:96], rxfifo_q_reg[31:0], rxfifo_q_reg[63:32]};          
               2'h3: rx_data0 <= {rxfifo_q[95:64], rxfifo_q[127:96], rxfifo_q_reg[31:0], rxfifo_q_reg[63:32]};          
           endcase
       end
      if ((rx_sop_last==1'b1) & (ctrlrx_3dw_del==1'b1)) begin                                                        
          case (ctrlrx_dw_addroffeset_reg)         
              2'h0: rx_be0  <=  {rxfifo_q[143:140], rxfifo_q[147:144], rxfifo_q[151:148], rxfifo_q[155:152]}         &  data_tail_be_mask;      
              2'h1: rx_be0  <=  {rxfifo_q[151:148], rxfifo_q[155:152], rxfifo_q_reg[143:140], zeros_4}                  &  data_tail_be_mask;      
              2'h2: rx_be0  <=  {rxfifo_q[151:148], rxfifo_q[155:152], zeros_8}                                         &  data_tail_be_mask;      
              2'h3: rx_be0  <=  {rxfifo_q_reg[143:140], zeros_4, zeros_8}                                                  &  data_tail_be_mask;      
          endcase
      end
      else if (ctrlrx_3dw_del==1'b1) begin         
          case (ctrlrx_dw_addroffeset_reg)
              2'h0: rx_be0  <=  {rxfifo_q[143:140], rxfifo_q[147:144], rxfifo_q[151:148], rxfifo_q[155:152]}                 &  data_tail_be_mask;   
              2'h1: rx_be0  <=  {rxfifo_q[151:148], rxfifo_q[155:152], rxfifo_q_reg[143:140], rxfifo_q_reg[147:144]}         &  data_tail_be_mask;   
              2'h2: rx_be0  <=  {rxfifo_q[151:148], rxfifo_q[155:152], rxfifo_q_reg[143:140], rxfifo_q_reg[147:144]}         &  data_tail_be_mask;   
              2'h3: rx_be0  <=  {rxfifo_q_reg[143:140], rxfifo_q_reg[147:144], rxfifo_q_reg[151:148], rxfifo_q_reg[155:152]} &  data_tail_be_mask;   
          endcase
      end
      else if ((rx_sop_last==1'b1) & (ctrlrx_3dw_del==1'b0))  begin         
          case (ctrlrx_dw_addroffeset_reg)
             2'h0: rx_be0  <=  {rxfifo_q[143:140], rxfifo_q[147:144], rxfifo_q[151:148], rxfifo_q[155:152]}  &  data_tail_be_mask;
             2'h1: rx_be0  <=  {rxfifo_q[143:140], rxfifo_q[147:144], rxfifo_q[151:148], zeros_4}               &  data_tail_be_mask;   
             2'h2: rx_be0  <=  {rxfifo_q[151:148], rxfifo_q[155:152], zeros_8}                                  &  data_tail_be_mask;
             2'h3: rx_be0  <=  {rxfifo_q[151:148], zeros_4, zeros_8}                            &  data_tail_be_mask;
          endcase
      end
      else if (ctrlrx_3dw_del==1'b0)  begin                             
          case (ctrlrx_dw_addroffeset_reg)
             2'h0: rx_be0  <=  {rxfifo_q[143:140], rxfifo_q[147:144], rxfifo_q[151:148], rxfifo_q[155:152]}          &  data_tail_be_mask;
             2'h1: rx_be0  <=  {rxfifo_q[143:140], rxfifo_q[147:144], rxfifo_q[151:148], rxfifo_q[155:152]}          &  data_tail_be_mask;
             2'h2: rx_be0  <=  {rxfifo_q[151:148], rxfifo_q[155:152], rxfifo_q_reg[143:140], rxfifo_q_reg[147:144]}  &  data_tail_be_mask;
             2'h3: rx_be0  <=  {rxfifo_q[151:148], rxfifo_q[155:152], rxfifo_q_reg[143:140], rxfifo_q_reg[147:144]}  &  data_tail_be_mask;
          endcase
      end
  end
  always @ (*) begin
      if (ctrlrx_count_length_dword[9:2] > 0) begin     
          data_tail_be_mask = 16'hffff;
      end
      else begin                                        
          case (ctrlrx_count_length_dword[1:0])
              2'b00: data_tail_be_mask = 16'h0000;
              2'b01: data_tail_be_mask = 16'h000f;
              2'b10: data_tail_be_mask = 16'h00ff;
              2'b11: data_tail_be_mask = 16'h0fff;
          endcase
      end
  end
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0) begin
          rx_ack_pending_del <= 1'b0;
          rx_req0            <= 1'b0;
          rx_req_del         <= 1'b0;
          rx_req_phase2      <= 1'b0;
      end
      else begin
         if (rx_ack0==1'b1)
              rx_req0 <= 1'b0;
         else if (rx_sop_p0==1'b1)
              rx_req0 <= 1'b1;
          rx_req_del         <= rx_req0;
          rx_req_phase2      <= (rx_ack0==1'b1) ? 1'b0 : ((rx_req_del==1'b0) & (rx_req0==1'b1)) ? 1'b1: rx_req_phase2;  
          rx_ack_pending_del <= rx_ack_pending;
      end
   end
   assign rx_ack_pending = (rx_ack0==1'b1) ? 1'b0 :  (rx_req_phase2==1'b1) ? 1'b1 : rx_ack_pending_del;  
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0) begin
         ctrlrx_count_length_dqword <= 0;
         ctrlrx_count_length_dword  <= 0;
         ctrlrx_count_length_dqword_zero <= 1'b1;
      end
      else begin
           if (rx_sop_p0==1'b1) begin
               if (ctrlrx_payload==1'b1) begin
                   case (ctrlrx_dw_addroffeset)
                       2'h0: ctrlrx_count_length_dword <= ctrlrx_length;      
                       2'h1: ctrlrx_count_length_dword <= ctrlrx_length + 1;
                       2'h2: ctrlrx_count_length_dword <= ctrlrx_length + 2;
                       2'h3: ctrlrx_count_length_dword <= ctrlrx_length + 3;
                   endcase
               end
               else begin
                   ctrlrx_count_length_dword <= 0;
               end
           end
           else if ((ctrlrx_count_length_dword>3) & (rx_rd_req_del==1'b1))      
               ctrlrx_count_length_dword <= ctrlrx_count_length_dword - 4;
           if ((ctrlrx_single_cycle==1'b1) & (rx_sop_p0==1'b1))
               ctrlrx_count_length_dqword <= 1;
           else if ((rx_sop_p0==1'b1) & (ctrlrx_payload==1'b1))begin
               casex ({ctrlrx_dw_addroffeset, ctrlrx_length[1:0]})
                  4'b00_00:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2];       
                  4'b00_01:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;   
                  4'b00_10:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;   
                  4'b00_11:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;   
                  4'b01_00:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;
                  4'b01_01:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;
                  4'b01_10:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;
                  4'b01_11:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;
                  4'b10_00:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;
                  4'b10_01:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;
                  4'b10_10:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;
                  4'b10_11:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 2;
                  4'b11_00:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;
                  4'b11_01:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 1;
                  4'b11_10:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 2;
                  4'b11_11:  ctrlrx_count_length_dqword[7:0] <= ctrlrx_length[9:2] + 2;
              endcase
          end
          else if ((ctrlrx_count_length_dqword>0) & (rx_rd_req_del==1'b1)) begin       
                ctrlrx_count_length_dqword <= ctrlrx_count_length_dqword-1;
          end
          if ((ctrlrx_count_length_dqword==1) & (rx_rd_req_del==1'b1)) begin       
                ctrlrx_count_length_dqword_zero <= 1'b1;
          end
          else if ((rx_sop_p0==1'b1) & (ctrlrx_payload==1'b1) ) begin
               ctrlrx_count_length_dqword_zero <= 1'b0;
          end
       end
   end
   assign rx_dfr_digest = ((rx_dfr_reg==1'b1)&&(ctrlrx_count_length_dqword>0)) ? 1'b1 : 1'b0;
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0)
         rx_dfr0 <= 1'b0;
      else begin
          if ((rx_sop_p0==1'b1) & (rxfifo_q[126]==1'b1))   
             rx_dfr0 <= 1'b1;
          else if ((ctrlrx_count_length_dqword==1) & (rx_rd_req_del==1'b1))          
             rx_dfr0 <= 1'b0;
      end
   end
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0)
         rx_dfr_reg <= 1'b0;
      else if (ctrlrx_payload==1'b1) begin
         if (ctrlrx_single_cycle==1'b1)
            rx_dfr_reg <= rx_sop_p0;
         else if (rx_sop_p0==1'b1)
            rx_dfr_reg <= 1'b1;
         else if (rx_eop_p0==1'b1)
            rx_dfr_reg <= 1'b0;
      end
      else
         rx_dfr_reg <= 1'b0;
   end
   always @(posedge clk_in) begin
      rx_dv0 <= (rx_rd_req_del==1'b1) ? rx_dfr0 : rx_dv0;  
   end
   assign wait_rdreq =  ((rx_eop_p0==1'b1) && (rx_req_cycle==1'b1)) || (((rx_eop_p0==1'b1) || (got_eop==1'b1)) & (ctrlrx_count_length_dqword_zero==1'b0)) ? 1'b1 : 
                        ((wait_rdreq_reg==1'b1) && (rx_req_cycle==1'b1))?1'b1:1'b0;
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0)
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
   assign rx_req_cycle = ((rx_sop_p0==1'b1) ||
                          (ctrl_next_rx_req[0]==1'b1)||
                          (ctrl_next_rx_req[1]==1'b1) )? 1'b1:1'b0;
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0)
         ctrl_next_rx_req <= 0;
      else begin
         ctrl_next_rx_req[0] <= rx_sop_p0;
         ctrl_next_rx_req[1] <= ctrl_next_rx_req[0];
         ctrl_next_rx_req[2] <= ctrl_next_rx_req[1];
      end
   end
   assign rx_sop_p0 = (rx_sop==1'b1) ? 1'b1 : 1'b0;  
   assign rx_eop_p0 = (rx_eop==1'b1) ? 1'b1 : 1'b0;  
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0) begin
         rx_sop_next <= 1'b0;
         rx_eop_next <= 1'b0;
      end
      else  begin
         rx_sop_next <= rx_sop;
         rx_eop_next <= rx_eop;
      end
   end
   always @(posedge clk_in) begin
      rx_sop_p1 <= rx_sop_p0;
      rx_eop_p1 <= rx_eop_p0;
   end
   assign ctrlrx_single_cycle   =  (rx_sop==1'b1) ? ((rx_eop==1'b1) ? 1'b1 :1'b0) : ctrlrx_single_cycle_reg;
   assign ctrlrx_payload        = ((rx_sop==1'b1)&&(rxfifo_q[126]==1'b1)) ? 1'b1  : ctrlrx_payload_reg;
   assign ctrlrx_3dw            = ((rx_sop==1'b1)&&(rxfifo_q[125]==1'b0))?1'b1:ctrlrx_3dw_reg;
   assign ctrlrx_3dw_nonaligned = ((rx_sop==1'b1)&&(rxfifo_q[125]==1'b0)&&(rxfifo_q[34]==1'b1))?1'b1:ctrlrx_3dw_nonaligned_reg;
   assign ctrlrx_dw_addroffeset = ((rx_sop==1'b1)&&(rxfifo_q[125]==1'b0))? rxfifo_q[35:34] :
                                                          (rx_sop==1'b1) ? rxfifo_q[3:2]   : ctrlrx_dw_addroffeset_reg;
   assign ctrlrx_qword_aligned  = ((rx_sop==1'b1)&& (
                                      ((ctrlrx_3dw==1'b1) && (rxfifo_q[34:32]==0)) ||
                                      ((ctrlrx_3dw==1'b0) && (rxfifo_q[2:0]==0))))?1'b1:  ctrlrx_qword_aligned_reg;
   assign ctrlrx_digest         = (rx_sop==1'b1) ? ((rxfifo_q[111]==1'b1) ? 1'b1: 1'b0) : ctrlrx_digest_reg;
   assign ctrlrx_length[9:0]    = (rx_sop==1'b1) ?  ((rxfifo_q[126]==1'b1) ? rxfifo_q[105:96]: 10'h0) : ctrlrx_length_reg[9:0];
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0) begin
         ctrlrx_single_cycle_reg   <= 1'b0;
         ctrlrx_payload_reg        <= 1'b0;
         ctrlrx_3dw_reg            <= 1'b0;
         ctrlrx_3dw_del            <= 1'b0;
         ctrlrx_dw_addroffeset_reg <= 1'b0;
         ctrlrx_3dw_nonaligned_reg <= 1'b0;
         ctrlrx_qword_aligned_reg  <= 1'b0;
         ctrlrx_digest_reg         <= 1'b0;
         ctrlrx_length_reg         <= 0;
         ctrlrx_length_reg         <= 0;
      end
      else begin
         ctrlrx_single_cycle_reg   <= ctrlrx_single_cycle;
         ctrlrx_dw_addroffeset_reg <= ctrlrx_dw_addroffeset;
         ctrlrx_3dw_nonaligned_reg <= ctrlrx_3dw_nonaligned;
         ctrlrx_3dw_del            <= ctrlrx_3dw;
         ctrlrx_digest_reg         <= ctrlrx_digest;
         ctrlrx_length_reg         <= ctrlrx_length;
          if (rx_sop_p0==1'b1) begin
              ctrlrx_3dw_reg           <= (rxfifo_q[125]==1'b0) ? 1'b1 : 1'b0;
              ctrlrx_payload_reg       <= (rxfifo_q[126]==1'b1) ? 1'b1 : 1'b0;
              ctrlrx_qword_aligned_reg <= (((ctrlrx_3dw==1'b1) && (rxfifo_q[34:32]==0)) ||
                                                 ((ctrlrx_3dw==1'b0) && (rxfifo_q[2:0]==0))) ? 1'b1 : 1'b0;
           end
          else if (((ctrlrx_single_cycle==1'b1)&&(ctrl_next_rx_req[2]==1'b1))||
                    ((ctrlrx_single_cycle==1'b0)&&(rx_eop_p0==1'b1))) begin
              ctrlrx_3dw_reg           <=1'b0;
              ctrlrx_payload_reg       <=1'b0;
              ctrlrx_qword_aligned_reg <= 1'b0;
          end
      end
   end
   assign count_eop_nop = (((rxfifo_wrreq==1'b1)&&(rxfifo_d[136]==1'b1)) &&
                          ((rxfifo_rreq_reg==1'b1)&&(rxfifo_q[136]==1'b1))) ? 1'b1:1'b0;
   assign last_eop_in_fifo = ((count_eop_in_rxfifo==1)&&
                              (count_eop_nop==1'b0)&&
                              (rxfifo_rreq_reg==1'b1)&&
                              (rxfifo_q[136]==1'b1)) ?1'b1:1'b0;
   assign tlp_in_rxfifo =((count_eop_in_rxfifo==0)||
                          (last_eop_in_fifo==1'b1))?  1'b0:1'b1;
   always @ (negedge rstn or posedge clk_in) begin
      if (rstn==1'b0)
         count_eop_in_rxfifo <= 0;
      else if (count_eop_nop==1'b0) begin
         if ((rxfifo_wrreq==1'b1)&&(rxfifo_d[136]==1'b1))
            count_eop_in_rxfifo <= count_eop_in_rxfifo+1;
         else if ((rxfifo_rreq_reg==1'b1)&&(rxfifo_q[136]==1'b1))
            count_eop_in_rxfifo <= count_eop_in_rxfifo-1;
      end
   end
   generate begin
      if (ECRC_FORWARD_CHECK==1) begin
         altpcierd_cdma_ecrc_check_128
           altpcierd_cdma_ecrc_check_128_i (
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
            .srst(~rstn)
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
