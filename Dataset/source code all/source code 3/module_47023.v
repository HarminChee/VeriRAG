`timescale 1ns / 1ps
`timescale 1ns / 1ps
module altpcierd_cdma_ecrc_gen #( parameter AVALON_ST_128 = 0)
            (clk, rstn,  user_rd_req, user_sop, user_eop, user_data, user_valid,
                tx_stream_ready0, tx_stream_data0_0, tx_stream_data0_1, tx_stream_valid0);
   input        clk;
   input        rstn;
   output       user_rd_req;          
   input        user_sop;             
   input[1:0]   user_eop;             
   input[127:0] user_data;           
   input        user_valid;           
   input        tx_stream_ready0;
   output[75:0] tx_stream_data0_0;
   output[75:0] tx_stream_data0_1;
   output       tx_stream_valid0;
   reg[75:0]    tx_stream_data0_0;
   reg[75:0]    tx_stream_data0_1;
   reg          tx_stream_valid0;
   wire [127:0] crc_data;
   wire         crc_sop;
   wire         crc_eop;
   wire         crc_valid;
   wire[3:0]    crc_empty;
   wire [127:0] tx_data;
   wire         tx_sop;
   wire [1:0]   tx_eop;
   wire         tx_valid;
   wire         tx_shift;
   wire[3:0]    tx_crc_location;
   wire[31:0]   ecrc;
   wire[31:0]   ecrc_reversed;
   wire[135:0]  tx_data_vec;
   wire[135:0]  tx_data_vec_del;
   wire[127:0]  tx_data_output;
   wire         tx_sop_output;
   wire[1:0]    tx_eop_output;
   wire[3:0]    tx_crc_location_output;
   reg[31:0]    ecrc_rev_hold;
   wire         crc_ack;
   wire         tx_data_vec_del_valid; 
   wire         tx_datapath_full;
   wire         tx_digest;
   reg          tx_digest_reg;
   generate  begin: tx_ecrc_128
      if (AVALON_ST_128==1)  begin
           altpcierd_cdma_ecrc_gen_ctl_128 ecrc_gen_ctl_128  (
           .clk(clk), .rstn(rstn), .user_rd_req(user_rd_req), .user_sop(user_sop),
           .user_eop(user_eop), .user_data(user_data),  .user_valid(user_valid),
           .crc_empty(crc_empty), .crc_sop(crc_sop), .crc_eop(crc_eop), .crc_data(crc_data),
           .crc_valid(crc_valid),
           .tx_sop(tx_sop), .tx_eop(tx_eop),
           .tx_data(tx_data), .tx_valid(tx_valid), .tx_crc_location(tx_crc_location), .tx_shift(tx_shift),
           .av_st_ready(~tx_datapath_full)
        );
       end
    end
   endgenerate
   generate  begin: tx_ecrc_64
      if (AVALON_ST_128==0)  begin
           altpcierd_cdma_ecrc_gen_ctl_64 ecrc_gen_ctl_64  (
           .clk(clk), .rstn(rstn), .user_rd_req(user_rd_req), .user_sop(user_sop),
           .user_eop(user_eop), .user_data(user_data),  .user_valid(user_valid),
           .crc_empty(crc_empty), .crc_sop(crc_sop), .crc_eop(crc_eop), .crc_data(crc_data),
           .crc_valid(crc_valid),
           .tx_sop(tx_sop), .tx_eop(tx_eop),
           .tx_data(tx_data), .tx_valid(tx_valid), .tx_crc_location(tx_crc_location), .tx_shift(tx_shift),
           .av_st_ready(~tx_datapath_full)
        );
      end
    end
   endgenerate
   altpcierd_cdma_ecrc_gen_calc #(.AVALON_ST_128(AVALON_ST_128)) ecrc_gen_calc (
       .clk(clk), .rstn(rstn), .crc_data(crc_data), .crc_valid(crc_valid),
       .crc_empty(crc_empty), .crc_eop(crc_eop), .crc_sop(crc_sop),
       .ecrc(ecrc),   .crc_ack(crc_ack)
   );
   assign tx_data_vec = {tx_valid, tx_crc_location, tx_sop, tx_eop, tx_data};
   altpcierd_cdma_ecrc_gen_datapath ecrc_gen_datapath (
       .clk(clk), .rstn(rstn), .data_in(tx_data_vec), .data_valid(tx_valid),
       .rdreq (tx_stream_ready0), .data_out(tx_data_vec_del), .data_out_valid(tx_data_vec_del_valid),
       .full(tx_datapath_full)
   );
   assign tx_crc_location_output = tx_data_vec_del[134:131];
   assign tx_sop_output          = tx_data_vec_del[130];
   assign tx_eop_output          = tx_data_vec_del[129:128];
   assign tx_data_output         = tx_data_vec_del[127:0];
   assign crc_ack                = (tx_digest==1'b1) ? (|tx_data_vec_del[134:131] & tx_data_vec_del_valid) :
                                                       (|tx_data_vec_del[129:128] & tx_data_vec_del_valid) ;  
   assign ecrc_reversed =  {  ecrc[0], ecrc[1], ecrc[2], ecrc[3], ecrc[4], ecrc[5], ecrc[6], ecrc[7],
                              ecrc[8], ecrc[9], ecrc[10], ecrc[11], ecrc[12], ecrc[13], ecrc[14], ecrc[15],
                              ecrc[16], ecrc[17], ecrc[18], ecrc[19], ecrc[20], ecrc[21], ecrc[22], ecrc[23],
                              ecrc[24], ecrc[25], ecrc[26], ecrc[27], ecrc[28], ecrc[29], ecrc[30], ecrc[31]
                            };
   assign tx_digest = (tx_sop_output==1'b1) ? tx_data_output[111] : tx_digest_reg;  
   always @ (posedge clk or negedge rstn) begin
       if (rstn==1'b0) begin
           tx_stream_data0_0    <= 76'h0;
           tx_stream_data0_1    <= 76'h0;
           tx_stream_valid0     <= 1'b0; 
           tx_digest_reg        <= 1'b0;
       end
       else begin
           tx_digest_reg <= tx_digest; 
           tx_stream_data0_0[75:74] <= 2'h0;
           tx_stream_data0_0[71:64] <= 8'h0;
           tx_stream_data0_1[75:74] <= 2'h0;
           tx_stream_data0_1[71:64] <= 8'h0;
           if (tx_digest==1'b1) begin
               tx_stream_data0_1[31:0]  <= (tx_crc_location_output[3]==1'b1) ? ecrc_reversed : tx_data_output[31:0];
               tx_stream_data0_1[63:32] <= (tx_crc_location_output[2]==1'b1) ? ecrc_reversed : tx_data_output[63:32];
               tx_stream_data0_0[31:0]  <= (tx_crc_location_output[1]==1'b1) ? ecrc_reversed : tx_data_output[95:64];
               tx_stream_data0_0[63:32] <= (tx_crc_location_output[0]==1'b1) ? ecrc_reversed : tx_data_output[127:96];
               tx_stream_data0_1[73]    <= (tx_crc_location_output[3:0]!=4'b0000);   
               tx_stream_data0_1[72]    <= tx_sop_output;                            
               tx_stream_data0_0[72]    <= tx_sop_output;                            
               tx_stream_data0_0[73]    <= (tx_crc_location_output[1:0]!=2'b00);     
               tx_stream_valid0         <= tx_data_vec_del_valid;
           end
           else begin
               tx_stream_data0_1[31:0]  <=  tx_data_output[31:0];
               tx_stream_data0_1[63:32] <=  tx_data_output[63:32];
               tx_stream_data0_0[31:0]  <=  tx_data_output[95:64];
               tx_stream_data0_0[63:32] <=  tx_data_output[127:96];
               tx_stream_data0_1[73]    <=  tx_eop_output[1];                       
               tx_stream_data0_1[72]    <=  tx_sop_output;                          
               tx_stream_data0_0[72]    <=  tx_sop_output;                          
               tx_stream_data0_0[73]    <=  tx_eop_output[0];
               tx_stream_valid0         <= (tx_data_vec_del_valid==1'b1) ? 1'b1 : 1'b0;
           end
       end
   end
endmodule
