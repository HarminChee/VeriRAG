`timescale 1 ns / 1 ps
`timescale 1 ns / 1 ps
module build_phase(
   input                      clk,
   input                      rst,
   output                     done,
   input    [63:0]            row_start_in,
   input    [63:0]            row_skip_in,
   input    [63:0]            hash_table_mask,
   output                     row_afull_out,
   input                      row_write_en_in,
   input    [63:0]            row_value_in,
   input                      ll_afull_in,
   output                     ll_write_en_out,
   output   [47:0]            ll_address_out,
   output   [63:0]            ll_payload_out,
   input                      ht_rq_afull_in,
   output                     ht_rq_read_en_out, 
   output   [47:0]            ht_rq_address_out,
   output   [63:0]            ht_rq_data_out,
   output                     ht_rs_afull_out,
   input                      ht_rs_write_en_in,
   input    [63:0]            ht_rs_data_in,
   input                      ll_update_afull_in,
   output                     ll_update_write_en_out,
   output   [47:0]            ll_update_addr_out,
   output   [63:0]            ll_update_data_out,
   input                      ll_rs_write_en_in
);
   wire                       hash_valid_s;
   wire  [63:0]               hash_data_out_s;
   wire  [63:0]               hash_masked_value_s;
   wire  [1:0]                phase_1_fifo_afull_s;
   wire                       phase_1_fifo_empty_s;
   wire  [63:0]               phase_1_fifo_payload_s;
   wire  [63:0]               phase_1_fifo_hash_value_s;
   wire                       phase_1_fifo_read_en_s;
   hash_function HASH (
      .clk                    (clk),
      .rst                    (rst),
      .valid_in               (row_write_en_in),
      .data_in                ({32'd0, row_value_in[63:32]}),
      .valid_out              (hash_valid_s),
      .data_out               (hash_data_out_s)
   );
   assign hash_masked_value_s = hash_data_out_s & hash_table_mask;
   sync_2_fifo PHASE_1_FIFO (
      .clk                    (clk),
      .rst                    (rst),
      .afull_out              (phase_1_fifo_afull_s),
      .write_en_in            ({row_write_en_in, hash_valid_s}),
      .data_1_in              (row_value_in),
      .data_0_in              (hash_masked_value_s),
      .empty_out              (phase_1_fifo_empty_s),
      .read_en_in             (phase_1_fifo_read_en_s),
      .data_1_out             (phase_1_fifo_payload_s),
      .data_0_out             (phase_1_fifo_hash_value_s)
   );
   assign row_afull_out = (phase_1_fifo_afull_s != 2'd0);
   reg   [63:0]               phase_2_addr_count_s;
   wire                       outstanding_ht_rq_done_s;
   assign phase_1_fifo_read_en_s = !phase_1_fifo_empty_s && !ll_afull_in && !ht_rq_afull_in;
   always @(posedge clk)
   begin
      if (rst == 1'd1)
         phase_2_addr_count_s <= row_start_in;
      else if (phase_1_fifo_read_en_s)
         phase_2_addr_count_s <= phase_2_addr_count_s + row_skip_in;
   end
   assign ll_write_en_out     = phase_1_fifo_read_en_s;
   assign ll_address_out      = phase_2_addr_count_s[47:0] * 48'd2;
   assign ll_payload_out      = phase_1_fifo_payload_s;
   assign ht_rq_read_en_out   = phase_1_fifo_read_en_s;
   assign ht_rq_address_out   = phase_1_fifo_hash_value_s[47:0];
   assign ht_rq_data_out      = phase_2_addr_count_s;
   outstanding_requests OUTSTANDING_HT_REQ (
      .clk                    (clk),
      .rst                    (rst),
      .done                   (outstanding_ht_rq_done_s),
      .rq_vld_in              (phase_1_fifo_read_en_s),
      .rs_vld_in              (ht_rs_write_en_in)
   );
   wire                       phase_3_fifo_empty_s;
   wire                       phase_3_fifo_read_en_s;
   wire  [63:0]               phase_3_fifo_data_out_s;
   reg   [63:0]               phase_3_addr_count_s;
   wire                       outstanding_ll_rq_done_s;
   fifo_64x512 PHASE_3_FIFO (
      .clk                    (clk),
      .rst                    (rst),
      .din                    (ht_rs_data_in),
      .wr_en                  (ht_rs_write_en_in),
      .rd_en                  (phase_3_fifo_read_en_s),
      .dout                   (phase_3_fifo_data_out_s),
      .full                   (),
      .empty                  (phase_3_fifo_empty_s),
      .prog_full              (ht_rs_afull_out)
   );
   assign phase_3_fifo_read_en_s = !phase_3_fifo_empty_s && !ll_update_afull_in;
   always @(posedge clk)
   begin
      if (rst == 1'd1)
         phase_3_addr_count_s <= row_start_in;
      else if (phase_3_fifo_read_en_s)
         phase_3_addr_count_s <= phase_3_addr_count_s + row_skip_in;
   end
   assign ll_update_write_en_out = phase_3_fifo_read_en_s;
   assign ll_update_addr_out     = (phase_3_addr_count_s[47:0] * 48'd2) + 48'd1;
   assign ll_update_data_out     = phase_3_fifo_data_out_s;
   outstanding_requests OUTSTANDING_LL_REQ (
      .clk                    (clk),
      .rst                    (rst),
      .done                   (outstanding_ll_rq_done_s),
      .rq_vld_in              (phase_3_fifo_read_en_s),
      .rs_vld_in              (ll_rs_write_en_in)
   );
   assign done = phase_1_fifo_empty_s && outstanding_ht_rq_done_s && phase_3_fifo_empty_s &&
                 outstanding_ll_rq_done_s;
endmodule 
