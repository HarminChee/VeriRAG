`timescale 1ps/1ps
`timescale 1ps/1ps
module mig_7series_v4_0_ecc_merge_enc
  #(
    parameter TCQ = 100,
    parameter PAYLOAD_WIDTH         = 64,
    parameter CODE_WIDTH            = 72,
    parameter DATA_BUF_ADDR_WIDTH   = 4,
    parameter DATA_BUF_OFFSET_WIDTH = 1,
    parameter DATA_WIDTH            = 64,
    parameter DQ_WIDTH              = 72,
    parameter ECC_WIDTH             = 8,
    parameter nCK_PER_CLK           = 4
   )
   (
  mc_wrdata, mc_wrdata_mask,
  clk, rst, wr_data, wr_data_mask, rd_merge_data, h_rows, raw_not_ecc
  );
  input clk;
  input rst;
  input [2*nCK_PER_CLK*PAYLOAD_WIDTH-1:0] wr_data;
  input [2*nCK_PER_CLK*DATA_WIDTH/8-1:0] wr_data_mask;
  input [2*nCK_PER_CLK*DATA_WIDTH-1:0] rd_merge_data;
  reg [2*nCK_PER_CLK*PAYLOAD_WIDTH-1:0] wr_data_r;
  reg [2*nCK_PER_CLK*DATA_WIDTH/8-1:0] wr_data_mask_r;
  reg [2*nCK_PER_CLK*DATA_WIDTH-1:0] rd_merge_data_r;
  always @(posedge clk) wr_data_r <= #TCQ wr_data;
  always @(posedge clk) wr_data_mask_r <= #TCQ wr_data_mask;
  always @(posedge clk) rd_merge_data_r <= #TCQ rd_merge_data;
  wire [2*nCK_PER_CLK*PAYLOAD_WIDTH-1:0] merged_data;
  genvar h;
  genvar i;
  generate
    for (h=0; h<2*nCK_PER_CLK; h=h+1) begin : merge_data_outer
      for (i=0; i<DATA_WIDTH/8; i=i+1) begin : merge_data_inner
        assign merged_data[h*PAYLOAD_WIDTH+i*8+:8] =  
                wr_data_mask[h*DATA_WIDTH/8+i]
                  ? rd_merge_data[h*DATA_WIDTH+i*8+:8]               
                  : wr_data[h*PAYLOAD_WIDTH+i*8+:8];
      end
      if (PAYLOAD_WIDTH > DATA_WIDTH)
        assign merged_data[(h+1)*PAYLOAD_WIDTH-1-:PAYLOAD_WIDTH-DATA_WIDTH]=
                      wr_data[(h+1)*PAYLOAD_WIDTH-1-:PAYLOAD_WIDTH-DATA_WIDTH];
    end
  endgenerate
  input [CODE_WIDTH*ECC_WIDTH-1:0] h_rows;
  input [2*nCK_PER_CLK-1:0] raw_not_ecc;
  reg [2*nCK_PER_CLK-1:0] raw_not_ecc_r;
  always @(posedge clk) raw_not_ecc_r <= #TCQ raw_not_ecc;
  output reg [2*nCK_PER_CLK*DQ_WIDTH-1:0] mc_wrdata;
  reg [2*nCK_PER_CLK*DQ_WIDTH-1:0] mc_wrdata_c;
  genvar j;
  integer k;
  generate
    for (j=0; j<2*nCK_PER_CLK; j=j+1) begin : ecc_word
      always @(h_rows or merged_data or raw_not_ecc_r) begin
        mc_wrdata_c[j*DQ_WIDTH+:DQ_WIDTH] =
          {{DQ_WIDTH-PAYLOAD_WIDTH{1'b0}},
           merged_data[j*PAYLOAD_WIDTH+:PAYLOAD_WIDTH]};
        for (k=0; k<ECC_WIDTH; k=k+1)
          if (~raw_not_ecc_r[j])
            mc_wrdata_c[j*DQ_WIDTH+CODE_WIDTH-k-1] =
              ^(merged_data[j*PAYLOAD_WIDTH+:DATA_WIDTH] & 
                h_rows[k*CODE_WIDTH+:DATA_WIDTH]);
      end
    end
  endgenerate
always @(posedge clk) mc_wrdata <= mc_wrdata_c;
  output wire[2*nCK_PER_CLK*DQ_WIDTH/8-1:0] mc_wrdata_mask;
  assign mc_wrdata_mask = {2*nCK_PER_CLK*DQ_WIDTH/8{1'b0}};
endmodule
