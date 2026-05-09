`timescale 1ns / 1ps
`timescale 1ns / 1ps
module altpcierd_cdma_ast_tx # (
   parameter TL_SELECTION= 0
   )(
   input clk_in,
   input rstn,
   input             tx_stream_ready0,
   output [74:0]     tx_stream_data0,
   output reg        tx_stream_valid0,
   input             tx_req0 ,
   output reg        tx_ack0 ,
   input [127:0]     tx_desc0,
   output            tx_ws0  ,
   input             tx_err0 ,
   input             tx_dv0  ,
   input             tx_dfr0 ,
   input[63:0]       tx_data0);
   reg has_payload;
   reg has_payload_stream;
   reg single_dword;
   reg single_dword_stream;
   reg tx_3dw;
   reg qword_aligned;
   wire qword_3dw_nonaligned;
   reg   tx_req_delay ;
   wire  tx_req_p0;
   reg   tx_req_p1 ;
   wire  tx_stream_ready_for_sop;
   reg   tx_req_delay_from_apps ;
   wire  tx_req_p0_from_apps;
   reg   tx_req_p1_from_apps;
   reg tx_stream_ready_p1;
   reg tx_stream_ready_p2;
   reg  tx_req_p0_apps_stream;
   wire tx_req_distance;
   reg   sop_valid_eop_cycle;
   wire  tx_stream_busy;
   reg   tx_sop;
   reg   tx_eop;
   reg   [63:0] tx_stream_data0_r;
   reg [63:0] tx_data_reg;
   reg tx_dv_reg;
   reg tx_dfr_reg;
   reg  tx_ws0_reg;
   reg tx_req_txready;
   reg tx_dfr_txready;
   reg tx_dv_txready;
   reg [63:0] tx_data_txready;
   reg [127:0] tx_desc_txready;
   reg srst;
  always @ (negedge rstn or posedge clk_in) begin
      if (rstn==0)
         srst <= 1'b1;
      else
         srst <= 1'b0;
   end
   always @(posedge clk_in) begin
      if ((tx_stream_ready0==1'b1)&&(tx_req0==1'b1) &&
                                (tx_stream_busy==1'b0))
         tx_req_txready   <= 1'b1;
      else if (tx_req0==1'b0)
         tx_req_txready   <= 1'b0;
   end
   always @(posedge clk_in) begin
      tx_req_p1     <= tx_req_p0;
      tx_req_delay  <= tx_req_txready;
   end
   assign tx_req_p0 = tx_req_txready & ~tx_req_delay ;
   assign tx_stream_ready_for_sop = tx_req_p0;
   always @(posedge clk_in) begin
     if (has_payload==1'b1) begin
        if (tx_req_p1_from_apps==1'b1) begin
           if (tx_dfr0==1'b0)
               single_dword <= 1'b1;
           else
               single_dword <= 1'b0;
        end
     end
     else
         single_dword <= 1'b0;
   end
   always @(posedge clk_in) begin
      if (srst == 1'b1)
         single_dword_stream     <= 1'b0;
      else begin
         if ((tx_req_p1==1'b1)&&(single_dword==1'b1))
            single_dword_stream     <= 1'b1;
         else if ((tx_stream_ready_p2==1'b1)&&
                  (single_dword_stream==1'b1))
            single_dword_stream     <= 1'b0;
      end
   end
   always @ (posedge clk_in) begin
      tx_ack0 <= tx_stream_ready_for_sop ;
   end
   always @(posedge clk_in) begin
      if (srst == 1'b1)
         has_payload <= 1'b0;
      else if ((tx_req_p0_from_apps==1'b1)&&(tx_dfr0==1'b1))
         has_payload <= 1'b1;
      else if ((tx_req_p0_from_apps==1'b1)&&(tx_dfr0==1'b0))
         has_payload <= 1'b0;
   end
   always @(posedge clk_in) begin
      if (srst == 1'b1)
         tx_3dw <= 1'b0;
      else if (tx_req_p0_from_apps==1'b1) begin
         if (tx_desc0[125]==1'b0)
            tx_3dw <= 1'b1;
         else
            tx_3dw <= 1'b0;
      end
   end
   always @(posedge clk_in) begin
      if (srst == 1'b1)
         qword_aligned <= 1'b0;
      else if (tx_req_p1_from_apps==1'b1) begin
         if (tx_3dw==1'b1) begin
            if (tx_desc0[34:32]==3'b0)
               qword_aligned <= 1'b1;
            else
               qword_aligned <= 1'b0;
         end
         else begin
            if (tx_desc0[2:0]==3'b0)
               qword_aligned <= 1'b1;
            else
               qword_aligned <= 1'b0;
         end
      end
   end
   always @(posedge clk_in) begin
      if (srst == 1'b1)
         tx_req_delay_from_apps  <= 1'b0;
      else
         tx_req_delay_from_apps  <= tx_req0;
   end
   always @ (posedge clk_in) begin
      tx_req_p1_from_apps <= tx_req_p0_from_apps;
   end
   assign tx_req_p0_from_apps = tx_req0 & ~tx_req_delay_from_apps;
   always @ (posedge clk_in) begin
      if (tx_stream_ready_for_sop ==1'b1)
         has_payload_stream  <= has_payload;
   end
   assign tx_req_distance = ((tx_req_p0_apps_stream==1'b1) &&
                               (tx_stream_ready_for_sop==1'b0))?1'b1:1'b0;
   always @ (posedge clk_in) begin
      if (tx_req0==1'b0)
         tx_req_p0_apps_stream <= 1'b0;
      else begin
         if ((tx_req_p0_from_apps==1'b1) && (tx_dfr0==1'b1))
            tx_req_p0_apps_stream <= 1'b1;
         else if (tx_stream_ready_for_sop==1'b1)
            tx_req_p0_apps_stream <= 1'b0;
      end
   end
   always @ (posedge clk_in) begin
       tx_stream_ready_p1 <= tx_stream_ready0;
       tx_stream_ready_p2 <= tx_stream_ready_p1;
   end
   assign tx_ws0 = ((tx_ws0_reg==1'b1)||
                    (tx_req_distance==1'b1))?1'b1:1'b0;
   always @ (posedge clk_in) begin
      if (has_payload==1'b0)
         tx_ws0_reg <= 1'b0;
      else begin
         if (tx_stream_ready0==1'b0)
            tx_ws0_reg <= 1'b1;
         else
            tx_ws0_reg <= 1'b0;
      end
   end
   always @(posedge clk_in) begin
      if (tx_stream_ready0==1'b1)
         tx_desc_txready   <= tx_desc0;
   end
   always @(posedge clk_in) begin
      if (tx_stream_ready_p1==1'b1) begin
         tx_data_txready  <= tx_data0;
         tx_dfr_txready   <= tx_dfr0;
         tx_dv_txready    <= tx_dv0;
      end
   end
   always @ (posedge clk_in) begin
     if (tx_stream_ready_p2==1'b1) begin
         tx_data_reg  <= tx_data_txready;
         tx_dv_reg    <= tx_dv_txready;
         tx_dfr_reg   <= tx_dfr_txready ;
     end
   end
   always @(posedge clk_in) begin
      if (TL_SELECTION==0) begin
         if (tx_stream_ready_for_sop ==1'b1)
            tx_stream_data0_r[63:0] <= tx_desc_txready[127:64];
         else if (tx_req_p1==1'b1)
            tx_stream_data0_r[63:0] <= tx_desc_txready[63:0];
         else if (tx_stream_ready_p2==1'b1)
            tx_stream_data0_r[63:0] <= tx_data_reg[63:0];
      end
      else begin
         if (tx_stream_ready_for_sop ==1'b1)
            tx_stream_data0_r[63:0] <= {tx_desc_txready[95:64],
                                      tx_desc_txready[127:96]};
         else if (tx_req_p1==1'b1) begin
            if ((qword_aligned==1'b0) && (tx_3dw==1'b1))
            tx_stream_data0_r[63:0] <= {tx_data_txready[63:32],
                                      tx_desc_txready[63:32]};
            else
            tx_stream_data0_r[63:0] <= {tx_desc_txready[31:0],
                                      tx_desc_txready[63:32]};
         end
         else if (tx_stream_ready_p2==1'b1) begin
            if ((qword_aligned==1'b0) && (tx_3dw==1'b1))
               tx_stream_data0_r[63:0] <= tx_data_txready[63:0];
            else
               tx_stream_data0_r[63:0] <= tx_data_reg[63:0];
         end
      end
   end
   assign tx_stream_data0[74]    = 1'b0;
   assign tx_stream_data0[73]    = tx_sop;
   assign tx_stream_data0[72]    = tx_eop;
   assign tx_stream_data0[71:64] = 0;
   assign tx_stream_data0[63:0]  = tx_stream_data0_r[63:0];
   always @(negedge rstn or posedge clk_in) begin
      if (rstn == 1'b0)
         tx_stream_valid0 <= 1'b0;
      else begin
         if ((tx_stream_ready_for_sop ==1'b1)||(tx_req_p1==1'b1))
            tx_stream_valid0 <=1'b1;
         else begin
            if ((tx_stream_ready_p2==1'b0)||
                (tx_eop==1'b1))
               tx_stream_valid0<=1'b0;
            else if (sop_valid_eop_cycle==1'b1)
               tx_stream_valid0 <=1'b1;
         end
      end
   end
   always @(negedge rstn or posedge clk_in) begin
      if (rstn == 1'b0)
         tx_sop <= 1'b0;
      else
         tx_sop <= tx_stream_ready_for_sop ;
   end
   assign qword_3dw_nonaligned = (tx_3dw==0)?1'b0:
                                  (qword_aligned==1'b1)?1'b0:1'b1;
   always @(posedge clk_in) begin
      if (srst == 1'b1)
         tx_eop <= 1'b0;
      else if (has_payload_stream==1'b0)
         tx_eop <= tx_req_p1;
      else begin
         if ((TL_SELECTION==0)||(qword_3dw_nonaligned==1'b0)) begin
            if (tx_stream_ready_p2==1'b1) begin
               if ((tx_req_p1==1'b1)||(tx_stream_ready_for_sop ==1'b1))
                  tx_eop <= 1'b0;
               else if (single_dword_stream==1'b1)
                  tx_eop <= 1'b1;
               else if ((tx_dfr_reg==1'b0)&&(tx_dv_reg==1'b1))
                  tx_eop <= 1'b1;
               else
                  tx_eop <= 1'b0;
            end
            else
               tx_eop <= 1'b0;
         end
         else begin
            if (tx_stream_ready_p2==1'b1) begin
               if ((tx_req_p0==1'b1)||(tx_stream_ready_for_sop ==1'b1))
                  tx_eop <= 1'b0;
               else if ((tx_req_p1==1'b1)&&(single_dword==1'b1))
                  tx_eop <= 1'b1;
               else if ((tx_dfr_txready==1'b0)&&(tx_dv_txready==1'b1))
                  tx_eop <= 1'b1;
               else
                  tx_eop <= 1'b0;
            end
            else
               tx_eop <= 1'b0;
         end
      end
   end
   assign tx_stream_busy = ((sop_valid_eop_cycle==1'b1) &&
                            (tx_eop==1'b0))?1'b1:1'b0;
   always @(posedge clk_in) begin
      if (srst == 1'b1)
         sop_valid_eop_cycle <= 1'b0;
      else begin
         if (tx_sop==1'b1)
            sop_valid_eop_cycle <= 1'b1;
         else if (tx_eop==1'b1)
            sop_valid_eop_cycle <= 1'b0;
      end
   end
endmodule
