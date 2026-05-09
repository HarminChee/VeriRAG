`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module mig_7series_v2_0_col_mach #
  (
   parameter TCQ = 100,
   parameter BANK_WIDTH               = 3,
   parameter BURST_MODE               = "8",
   parameter COL_WIDTH                = 12,
   parameter CS_WIDTH                 = 4,
   parameter DATA_BUF_ADDR_WIDTH      = 8,
   parameter DATA_BUF_OFFSET_WIDTH    = 1,
   parameter DELAY_WR_DATA_CNTRL      = 0,
   parameter DQS_WIDTH                = 8,
   parameter DRAM_TYPE                = "DDR3",
   parameter EARLY_WR_DATA_ADDR       = "OFF",
   parameter ECC                      = "OFF",
   parameter MC_ERR_ADDR_WIDTH        = 31,
   parameter nCK_PER_CLK              = 2,
   parameter nPHY_WRLAT               = 0,
   parameter RANK_WIDTH               = 2,
   parameter ROW_WIDTH                = 16
  )
  (
  dq_busy_data, wr_data_offset, mc_wrdata_en, wr_data_en,
  wr_data_addr, rd_rmw, ecc_err_addr, ecc_status_valid, wr_ecc_buf, rd_data_end,
  rd_data_addr, rd_data_offset, rd_data_en, col_read_fifo_empty,
  clk, rst, sent_col, col_size, col_wr_data_buf_addr,
  phy_rddata_valid, col_periodic_rd, col_data_buf_addr, col_rmw,
  col_rd_wr, col_ra, col_ba, col_row, col_a
  );
  input clk;
  input rst;
  input sent_col;
  input col_rd_wr;
  output reg dq_busy_data = 1'b0;
  generate
    if ((nCK_PER_CLK == 1) && ((BURST_MODE == "8") || (DRAM_TYPE == "DDR3")))
    begin : three_bumps
      reg [1:0] granted_col_d_r;
      wire [1:0] granted_col_d_ns = {sent_col, granted_col_d_r[1]};
      always @(posedge clk) granted_col_d_r <= #TCQ granted_col_d_ns;
      always @(granted_col_d_r or sent_col)
                dq_busy_data = sent_col || |granted_col_d_r;
    end
    if (((nCK_PER_CLK == 2) && ((BURST_MODE == "8") || (DRAM_TYPE == "DDR3")))
    || ((nCK_PER_CLK == 1) && ((BURST_MODE == "4") || (DRAM_TYPE == "DDR2"))))
    begin : one_bump
       always @(sent_col) dq_busy_data = sent_col;
    end
  endgenerate
  reg [1:0] offset_r = 2'b0;
  reg [1:0] offset_ns = 2'b0;
  input col_size;
  wire data_end;
  generate
    if(nCK_PER_CLK == 4) begin : data_valid_4_1
      assign data_end = 1'b1;
    end
    else begin
      if(DATA_BUF_OFFSET_WIDTH == 2) begin : data_valid_1_1
        always @(col_size or offset_r or rst or sent_col) begin
          if (rst) offset_ns = 2'b0;
          else begin
            offset_ns = offset_r;
            if (sent_col) offset_ns = 2'b1;
            else if (|offset_r && (offset_r != {col_size, 1'b1}))
              offset_ns = offset_r + 2'b1;
            else offset_ns = 2'b0;
          end
        end
        always @(posedge clk) offset_r <= #TCQ offset_ns;
        assign data_end = col_size ? (offset_r == 2'b11) : offset_r[0];
      end
      else begin : data_valid_2_1
        always @(col_size or rst or sent_col)
          offset_ns[0] = rst ? 1'b0 : sent_col && col_size;
        always @(posedge clk) offset_r[0] <= #TCQ offset_ns[0];
        assign data_end = col_size ? offset_r[0] : 1'b1;
      end
    end
  endgenerate
  reg [DATA_BUF_OFFSET_WIDTH-1:0] offset_r1 = {DATA_BUF_OFFSET_WIDTH{1'b0}};
  reg [DATA_BUF_OFFSET_WIDTH-1:0] offset_r2 = {DATA_BUF_OFFSET_WIDTH{1'b0}};
  reg col_rd_wr_r1;
  reg col_rd_wr_r2;
  generate
    if ((nPHY_WRLAT >= 1) || (DELAY_WR_DATA_CNTRL == 1)) begin : offset_pipe_0
      always @(posedge clk) offset_r1 <=
                              #TCQ offset_r[DATA_BUF_OFFSET_WIDTH-1:0];
      always @(posedge clk) col_rd_wr_r1 <= #TCQ col_rd_wr;
    end
    if(nPHY_WRLAT == 2) begin : offset_pipe_1
      always @(posedge clk) offset_r2 <=
                              #TCQ offset_r1[DATA_BUF_OFFSET_WIDTH-1:0];
      always @(posedge clk) col_rd_wr_r2 <= #TCQ col_rd_wr_r1;
    end
  endgenerate
  output wire [DATA_BUF_OFFSET_WIDTH-1:0] wr_data_offset;
  assign wr_data_offset = (DELAY_WR_DATA_CNTRL == 1)
                            ? offset_r1[DATA_BUF_OFFSET_WIDTH-1:0]
                            : (EARLY_WR_DATA_ADDR == "OFF")
                              ? offset_r[DATA_BUF_OFFSET_WIDTH-1:0]
                              : offset_ns[DATA_BUF_OFFSET_WIDTH-1:0];
  reg sent_col_r1;
  reg sent_col_r2;
  always @(posedge clk) sent_col_r1 <= #TCQ sent_col;
  always @(posedge clk) sent_col_r2 <= #TCQ sent_col_r1;
  wire wrdata_en =  (nPHY_WRLAT == 0) ?
                      (sent_col || |offset_r) & ~col_rd_wr :
                    (nPHY_WRLAT == 1) ?
                      (sent_col_r1 || |offset_r1) & ~col_rd_wr_r1 :
                      (sent_col_r2 || |offset_r2) & ~col_rd_wr_r2;
  output wire mc_wrdata_en;
  assign mc_wrdata_en = wrdata_en;
  output wire wr_data_en;
  assign wr_data_en = (DELAY_WR_DATA_CNTRL == 1)
                              ? ((sent_col_r1 || |offset_r1) && ~col_rd_wr_r1)
                              : ((sent_col || |offset_r) && ~col_rd_wr);
  input [DATA_BUF_ADDR_WIDTH-1:0] col_wr_data_buf_addr;
  output wire [DATA_BUF_ADDR_WIDTH-1:0] wr_data_addr;
  generate
    if (DELAY_WR_DATA_CNTRL == 1) begin : delay_wr_data_cntrl_eq_1
      reg [DATA_BUF_ADDR_WIDTH-1:0] col_wr_data_buf_addr_r;
      always @(posedge clk) col_wr_data_buf_addr_r <= 
                              #TCQ col_wr_data_buf_addr;
      assign wr_data_addr = col_wr_data_buf_addr_r;
    end
    else begin : delay_wr_data_cntrl_ne_1
      assign wr_data_addr = col_wr_data_buf_addr;
    end
  endgenerate
  wire read_data_valid = (sent_col || |offset_r) && col_rd_wr;
function integer clogb2 (input integer size); 
    begin
    size = size - 1;
    for (clogb2=1; size>1; clogb2=clogb2+1)
            size = size >> 1;
  end
endfunction 
  input phy_rddata_valid;
  output wire rd_rmw;
  output reg [MC_ERR_ADDR_WIDTH-1:0] ecc_err_addr;
  output reg ecc_status_valid;
  output reg wr_ecc_buf;
  output reg rd_data_end;
  output reg [DATA_BUF_ADDR_WIDTH-1:0] rd_data_addr;  
  output reg [DATA_BUF_OFFSET_WIDTH-1:0] rd_data_offset;
  output reg rd_data_en ;
  output col_read_fifo_empty;
  input col_periodic_rd;  
  input [DATA_BUF_ADDR_WIDTH-1:0] col_data_buf_addr;
  input col_rmw;
  input [RANK_WIDTH-1:0] col_ra;
  input [BANK_WIDTH-1:0] col_ba;
  input [ROW_WIDTH-1:0] col_row;
  input [ROW_WIDTH-1:0] col_a;
  wire [11:0] col_a_full;
  assign col_a_full[10:0] = {col_a[11], col_a[9:0]};
  generate
     if (ROW_WIDTH >= 14) begin : COL_A_FULL_11_1
        assign col_a_full[11] = col_a[13];
     end else begin : COL_A_FULL_11_0
        assign col_a_full[11] = 0;
     end
  endgenerate
  wire [COL_WIDTH-1:0] col_a_extracted = col_a_full[COL_WIDTH-1:0];
  localparam MC_ERR_LINE_WIDTH = MC_ERR_ADDR_WIDTH-DATA_BUF_OFFSET_WIDTH;
  localparam FIFO_WIDTH = 1  +
                          1  +
                          DATA_BUF_ADDR_WIDTH +
                          DATA_BUF_OFFSET_WIDTH +
                          ((ECC == "OFF") ? 0 : 1+MC_ERR_LINE_WIDTH);
  localparam FULL_RAM_CNT = (FIFO_WIDTH/6);
  localparam REMAINDER = FIFO_WIDTH % 6;
  localparam RAM_CNT = FULL_RAM_CNT + ((REMAINDER == 0 ) ? 0 : 1);
  localparam RAM_WIDTH = (RAM_CNT*6);
  generate
    begin : read_fifo
      wire [MC_ERR_LINE_WIDTH:0] ecc_line;
      if (CS_WIDTH == 1)
        assign ecc_line = {col_rmw, col_ba, col_row, col_a_extracted};
      else
        assign ecc_line = {col_rmw,
                           col_ra,
                           col_ba,
                           col_row,
                           col_a_extracted};
      wire [FIFO_WIDTH-1:0] real_fifo_data;
      if (ECC == "OFF")
         assign real_fifo_data = {data_end,
                                  col_periodic_rd,
                                  col_data_buf_addr,
                                  offset_r[DATA_BUF_OFFSET_WIDTH-1:0]};
      else
         assign real_fifo_data = {data_end,
                                  col_periodic_rd,
                                  col_data_buf_addr,
                                  offset_r[DATA_BUF_OFFSET_WIDTH-1:0],
                                  ecc_line};
      wire [RAM_WIDTH-1:0] fifo_in_data;
      if (REMAINDER == 0)
        assign fifo_in_data = real_fifo_data;
      else
        assign fifo_in_data = {{6-REMAINDER{1'b0}}, real_fifo_data};
      wire [RAM_WIDTH-1:0] fifo_out_data_ns;
      reg [4:0] head_r;
      wire [4:0] head_ns = rst ? 5'b0 : read_data_valid
                                          ? (head_r + 5'b1)
                                          : head_r;
      always @(posedge clk) head_r <= #TCQ head_ns;
      reg [4:0] tail_r;
      wire [4:0] tail_ns = rst ? 5'b0 : phy_rddata_valid
                                          ? (tail_r + 5'b1)
                                          : tail_r;
      always @(posedge clk) tail_r <= #TCQ tail_ns;
      assign col_read_fifo_empty = head_r == tail_r ? 1'b1 : 1'b0;
      genvar i;
      for (i=0; i<RAM_CNT; i=i+1) begin : fifo_ram
        RAM32M
          #(.INIT_A(64'h0000000000000000),
            .INIT_B(64'h0000000000000000),
            .INIT_C(64'h0000000000000000),
            .INIT_D(64'h0000000000000000)
          ) RAM32M0 (
            .DOA(fifo_out_data_ns[((i*6)+4)+:2]),
            .DOB(fifo_out_data_ns[((i*6)+2)+:2]),
            .DOC(fifo_out_data_ns[((i*6)+0)+:2]),
            .DOD(),
            .DIA(fifo_in_data[((i*6)+4)+:2]),
            .DIB(fifo_in_data[((i*6)+2)+:2]),
            .DIC(fifo_in_data[((i*6)+0)+:2]),
            .DID(2'b0),
            .ADDRA(tail_ns),
            .ADDRB(tail_ns),
            .ADDRC(tail_ns),
            .ADDRD(head_r),
            .WE(1'b1),
            .WCLK(clk)
           );
      end 
      reg [RAM_WIDTH-1:0] fifo_out_data_r;
      always @(posedge clk) fifo_out_data_r <= #TCQ fifo_out_data_ns;
      if (ECC == "OFF") begin
        reg periodic_rd;
        always @(phy_rddata_valid or fifo_out_data_r) begin
          {rd_data_end,
           periodic_rd,
           rd_data_addr,
           rd_data_offset} = fifo_out_data_r[FIFO_WIDTH-1:0];
          ecc_err_addr = {MC_ERR_ADDR_WIDTH{1'b0}};
          rd_data_en = phy_rddata_valid && ~periodic_rd;
          ecc_status_valid = 1'b0;
          wr_ecc_buf = 1'b0;
        end
        assign rd_rmw = 1'b0;
      end
      else begin
        wire rd_data_end_ns;
        wire periodic_rd;
        wire [DATA_BUF_ADDR_WIDTH-1:0] rd_data_addr_ns;
        wire [DATA_BUF_OFFSET_WIDTH-1:0] rd_data_offset_ns;
        wire [MC_ERR_ADDR_WIDTH-1:0] ecc_err_addr_ns;
        assign {rd_data_end_ns,
                periodic_rd,
                rd_data_addr_ns,
                rd_data_offset_ns,
                rd_rmw,
                ecc_err_addr_ns[DATA_BUF_OFFSET_WIDTH+:MC_ERR_LINE_WIDTH]} =
                  {fifo_out_data_r[FIFO_WIDTH-1:0]};
        assign ecc_err_addr_ns[0+:DATA_BUF_OFFSET_WIDTH] = rd_data_offset_ns;
        always @(posedge clk) rd_data_end <= #TCQ rd_data_end_ns;
        always @(posedge clk) rd_data_addr <= #TCQ rd_data_addr_ns;
        always @(posedge clk) rd_data_offset <= #TCQ rd_data_offset_ns;
        always @(posedge clk) ecc_err_addr <= #TCQ ecc_err_addr_ns;
        wire rd_data_en_ns = phy_rddata_valid && ~(periodic_rd || rd_rmw);
        always @(posedge clk) rd_data_en <= rd_data_en_ns;
        wire ecc_status_valid_ns = phy_rddata_valid && ~periodic_rd;
        always @(posedge clk) ecc_status_valid <= #TCQ ecc_status_valid_ns;
        wire wr_ecc_buf_ns = phy_rddata_valid && ~periodic_rd && rd_rmw;
        always @(posedge clk) wr_ecc_buf <= #TCQ wr_ecc_buf_ns;
      end
    end
  endgenerate
endmodule
