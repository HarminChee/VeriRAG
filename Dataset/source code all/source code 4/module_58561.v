`timescale 1ps/1ps
`timescale 1ps/1ps
module ecc_buf
  #(
    parameter TCQ = 100,
    parameter PAYLOAD_WIDTH          = 64,
    parameter DATA_BUF_ADDR_WIDTH    = 4,
    parameter DATA_BUF_OFFSET_WIDTH  = 1,
    parameter DATA_WIDTH             = 64
   )
   (
  rd_merge_data,
  clk, rst, rd_data_addr, rd_data_offset, wr_data_addr,
  wr_data_offset, rd_data, wr_ecc_buf
  );
  input clk;
  input rst;
  input [DATA_BUF_ADDR_WIDTH-1:0] rd_data_addr;
  input [DATA_BUF_OFFSET_WIDTH-1:0] rd_data_offset;
  wire [4:0] buf_wr_addr;
  input [DATA_BUF_ADDR_WIDTH-1:0] wr_data_addr;
  input [DATA_BUF_OFFSET_WIDTH-1:0] wr_data_offset;
  reg [4:0] buf_rd_addr_r;
  generate
    if (DATA_BUF_ADDR_WIDTH >= 4) begin : ge_4_addr_bits
      always @(posedge clk)  
        buf_rd_addr_r <= #TCQ{wr_data_addr[3:0], wr_data_offset};
      assign buf_wr_addr = {rd_data_addr[3:0], rd_data_offset};
    end
    else begin : lt_4_addr_bits
      always @(posedge clk) 
        buf_rd_addr_r <= #TCQ{{4-DATA_BUF_ADDR_WIDTH{1'b0}},
                               wr_data_addr[DATA_BUF_ADDR_WIDTH-1:0],
                               wr_data_offset};
      assign buf_wr_addr = {{4-DATA_BUF_ADDR_WIDTH{1'b0}},
                            rd_data_addr[DATA_BUF_ADDR_WIDTH-1:0], 
                            rd_data_offset};
    end
  endgenerate
  input [4*PAYLOAD_WIDTH-1:0] rd_data;
  reg [4*DATA_WIDTH-1:0] payload;
  integer h;
  always @(rd_data)
    for (h=0; h<4; h=h+1)
      payload[h*DATA_WIDTH+:DATA_WIDTH] = 
        rd_data[h*PAYLOAD_WIDTH+:DATA_WIDTH];
  input wr_ecc_buf;
  localparam BUF_WIDTH = 4*DATA_WIDTH;
  localparam FULL_RAM_CNT = (BUF_WIDTH/6);
  localparam REMAINDER = BUF_WIDTH % 6;
  localparam RAM_CNT = FULL_RAM_CNT + ((REMAINDER == 0 ) ? 0 : 1);
  localparam RAM_WIDTH = (RAM_CNT*6);
  wire [RAM_WIDTH-1:0] buf_out_data;
  generate
    begin : ram_buf
      wire [RAM_WIDTH-1:0] buf_in_data;
      if (REMAINDER == 0)
        assign buf_in_data = payload;
      else
        assign buf_in_data = {{6-REMAINDER{1'b0}}, payload};
      genvar i;
      for (i=0; i<RAM_CNT; i=i+1) begin : rd_buffer_ram
        RAM32M
          #(.INIT_A(64'h0000000000000000),
            .INIT_B(64'h0000000000000000),
            .INIT_C(64'h0000000000000000),
            .INIT_D(64'h0000000000000000)
          ) RAM32M0 (
            .DOA(buf_out_data[((i*6)+4)+:2]),
            .DOB(buf_out_data[((i*6)+2)+:2]),
            .DOC(buf_out_data[((i*6)+0)+:2]),
            .DOD(),
            .DIA(buf_in_data[((i*6)+4)+:2]),
            .DIB(buf_in_data[((i*6)+2)+:2]),
            .DIC(buf_in_data[((i*6)+0)+:2]),
            .DID(2'b0),
            .ADDRA(buf_rd_addr_r),
            .ADDRB(buf_rd_addr_r),
            .ADDRC(buf_rd_addr_r),
            .ADDRD(buf_wr_addr),
            .WE(wr_ecc_buf),
            .WCLK(clk)
           );
      end 
    end
  endgenerate
  output wire [4*DATA_WIDTH-1:0] rd_merge_data;
  assign rd_merge_data = buf_out_data[4*DATA_WIDTH-1:0];
endmodule
