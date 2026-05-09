`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module ui_wr_data #
  (
   parameter TCQ = 100,
   parameter APP_DATA_WIDTH       = 256,
   parameter APP_MASK_WIDTH       = 32,
   parameter ECC                  = "OFF",
   parameter ECC_TEST             = "OFF",
   parameter CWL                  = 5
  )
  (
  app_wdf_rdy, wr_req_16, wr_data_buf_addr, wr_data, wr_data_mask,
  raw_not_ecc,
  rst, clk, app_wdf_data, app_wdf_mask, app_raw_not_ecc, app_wdf_wren,
  app_wdf_end, wr_data_offset, wr_data_addr, wr_data_en, wr_accepted,
  ram_init_done_r, ram_init_addr
  );
  input rst;
  input clk;
  input [APP_DATA_WIDTH-1:0] app_wdf_data;
  input [APP_MASK_WIDTH-1:0] app_wdf_mask;
  input [3:0] app_raw_not_ecc;
  input app_wdf_wren;
  input app_wdf_end;
  reg [APP_DATA_WIDTH-1:0] app_wdf_data_r1;
  reg [APP_MASK_WIDTH-1:0] app_wdf_mask_r1;
  reg [3:0] app_raw_not_ecc_r1 = 4'b0;
  reg app_wdf_wren_r1;
  reg app_wdf_end_r1;
  reg app_wdf_rdy_r;
  reg app_wdf_rdy_r_copy1;
  reg app_wdf_rdy_r_copy2;
  reg app_wdf_rdy_r_copy3;
  reg app_wdf_rdy_r_copy4;
  wire [APP_DATA_WIDTH-1:0] app_wdf_data_ns1 =
         ~app_wdf_rdy_r_copy2 ? app_wdf_data_r1 : app_wdf_data;
  wire [APP_MASK_WIDTH-1:0] app_wdf_mask_ns1 =
         ~app_wdf_rdy_r_copy2 ? app_wdf_mask_r1 : app_wdf_mask;
  wire app_wdf_wren_ns1 =
         ~rst && (~app_wdf_rdy_r_copy2 ? app_wdf_wren_r1 : app_wdf_wren);
  wire app_wdf_end_ns1 =
         ~rst && (~app_wdf_rdy_r_copy2 ? app_wdf_end_r1 : app_wdf_end);
  generate
    if (ECC_TEST != "OFF") begin : ecc_on
      always @(posedge clk) app_raw_not_ecc_r1 <= #TCQ app_raw_not_ecc;
    end
  endgenerate
  always @(posedge clk) begin
      app_wdf_data_r1 <= #TCQ app_wdf_data_ns1;
      app_wdf_mask_r1 <= #TCQ app_wdf_mask_ns1;
      app_wdf_wren_r1 <= #TCQ app_wdf_wren_ns1;
      app_wdf_end_r1 <= #TCQ app_wdf_end_ns1;
  end
  input wr_data_offset;
  input [3:0] wr_data_addr;
  reg wr_data_offset_r;
  reg [3:0] wr_data_addr_r;
  generate
    if (ECC == "OFF" || CWL >= 7) begin : pass_wr_addr
      always @(wr_data_offset) wr_data_offset_r = wr_data_offset;
      always @(wr_data_addr) wr_data_addr_r = wr_data_addr;
    end
    else begin : delay_wr_addr
      always @(posedge clk) wr_data_offset_r <= #TCQ wr_data_offset;
      always @(posedge clk) wr_data_addr_r <= #TCQ wr_data_addr;
    end
  endgenerate
  input wr_data_en;
  wire new_rd_data = wr_data_en && ~wr_data_offset_r;
  reg [3:0] rd_data_indx_r;
  reg rd_data_upd_indx_r;
  generate begin : read_data_indx
      reg [3:0] rd_data_indx_ns;
      always @(new_rd_data or rd_data_indx_r or rst) begin
        rd_data_indx_ns = rd_data_indx_r;
        if (rst) rd_data_indx_ns = 5'b0;
        else if (new_rd_data) rd_data_indx_ns = rd_data_indx_r + 5'h1;
      end
      always @(posedge clk) rd_data_indx_r <= #TCQ rd_data_indx_ns;
      always @(posedge clk) rd_data_upd_indx_r <= #TCQ new_rd_data;
    end
  endgenerate
  input wr_accepted;
  reg [3:0] data_buf_addr_cnt_r;
  generate begin : data_buf_address_counter
      reg [3:0] data_buf_addr_cnt_ns;
      always @(data_buf_addr_cnt_r or rst or wr_accepted) begin
        data_buf_addr_cnt_ns = data_buf_addr_cnt_r;
        if (rst) data_buf_addr_cnt_ns = 4'b0;
        else if (wr_accepted) data_buf_addr_cnt_ns =
                                data_buf_addr_cnt_r + 4'h1;
      end
      always @(posedge clk) data_buf_addr_cnt_r <= #TCQ data_buf_addr_cnt_ns;
    end
  endgenerate
  wire wdf_rdy_ns;
  always @( posedge clk ) begin
  	app_wdf_rdy_r_copy1 <= #TCQ wdf_rdy_ns;
  	app_wdf_rdy_r_copy2 <= #TCQ wdf_rdy_ns;
  	app_wdf_rdy_r_copy3 <= #TCQ wdf_rdy_ns;
  	app_wdf_rdy_r_copy4 <= #TCQ wdf_rdy_ns;
  end
  wire wr_data_end = app_wdf_end_r1 && app_wdf_rdy_r_copy1 && app_wdf_wren_r1;
  wire [3:0] wr_data_pntr;
  wire [4:0] wb_wr_data_addr;
  reg [3:0] wr_data_indx_r;
  generate begin : write_data_control
      wire wr_data_addr_le = (wr_data_end && wdf_rdy_ns) ||
                             (rd_data_upd_indx_r && ~app_wdf_rdy_r_copy1);
      reg [3:0] wr_data_indx_ns;
      always @(rst or wr_data_addr_le or wr_data_indx_r) begin
        wr_data_indx_ns = wr_data_indx_r;
        if (rst) wr_data_indx_ns = 4'b1;
        else if (wr_data_addr_le) wr_data_indx_ns = wr_data_indx_r + 4'h1;
      end
      always @(posedge clk) wr_data_indx_r <= #TCQ wr_data_indx_ns;
      reg [4:1] wb_wr_data_addr_ns;
      reg [4:1] wb_wr_data_addr_r;
      always @(rst or wb_wr_data_addr_r or wr_data_addr_le
               or wr_data_pntr) begin
        wb_wr_data_addr_ns = wb_wr_data_addr_r;
        if (rst) wb_wr_data_addr_ns = 4'b0;
        else if (wr_data_addr_le) wb_wr_data_addr_ns = wr_data_pntr;
      end
      always @(posedge clk) wb_wr_data_addr_r = #TCQ wb_wr_data_addr_ns;
      reg wb_wr_data_addr0_r;
      wire wb_wr_data_addr0_ns = ~rst &&
                     ((app_wdf_rdy_r_copy3 && app_wdf_wren_r1 && ~app_wdf_end_r1) ||
                      (wb_wr_data_addr0_r && ~app_wdf_wren_r1));
      always @(posedge clk) wb_wr_data_addr0_r <= #TCQ wb_wr_data_addr0_ns;
      assign wb_wr_data_addr = {wb_wr_data_addr_r, wb_wr_data_addr0_r};
    end
  endgenerate
  input ram_init_done_r;
  output wire app_wdf_rdy;
  generate begin : occupied_counter
      reg [15:0] occ_cnt;
      always @(posedge clk) begin
      	if ( rst )
	   occ_cnt <= #TCQ 16'h0000;
	else case ({wr_data_end, rd_data_upd_indx_r})
	      2'b01 : occ_cnt <= #TCQ {1'b0,occ_cnt[15:1]};
	      2'b10 : occ_cnt <= #TCQ {occ_cnt[14:0],1'b1};
             endcase 
      end
      assign wdf_rdy_ns = !(rst || ~ram_init_done_r || (occ_cnt[14] && wr_data_end && ~rd_data_upd_indx_r) || (occ_cnt[15] && ~rd_data_upd_indx_r));
      always @(posedge clk) app_wdf_rdy_r <= #TCQ wdf_rdy_ns;
      assign app_wdf_rdy = app_wdf_rdy_r;
`ifdef MC_SVA
  wr_data_buffer_full: cover property (@(posedge clk)
         (~rst && ~app_wdf_rdy_r));
`endif
    end 
  endgenerate
  output wire wr_req_16;
  generate begin : wr_req_counter
      reg [4:0] wr_req_cnt_ns;
      reg [4:0] wr_req_cnt_r;
      always @(rd_data_upd_indx_r or rst or wr_accepted
               or wr_req_cnt_r) begin
        wr_req_cnt_ns = wr_req_cnt_r;
        if (rst) wr_req_cnt_ns = 5'b0;
        else case ({wr_accepted, rd_data_upd_indx_r})
               2'b01 : wr_req_cnt_ns = wr_req_cnt_r - 5'b1;
               2'b10 : wr_req_cnt_ns = wr_req_cnt_r + 5'b1;
             endcase 
      end
      always @(posedge clk) wr_req_cnt_r <= #TCQ wr_req_cnt_ns;
      assign wr_req_16 = (wr_req_cnt_ns == 5'h10);
`ifdef MC_SVA
  wr_req_mc_full: cover property (@(posedge clk) (~rst && wr_req_16));
  wr_req_mc_full_inc_dec_15: cover property (@(posedge clk)
       (~rst && wr_accepted && rd_data_upd_indx_r && (wr_req_cnt_r == 5'hf)));
  wr_req_underflow: assert property (@(posedge clk)
         (rst || !((wr_req_cnt_r == 5'b0) && (wr_req_cnt_ns == 5'h1f))));
  wr_req_overflow: assert property (@(posedge clk)
         (rst || !((wr_req_cnt_r == 5'h10) && (wr_req_cnt_ns == 5'h11))));
`endif
    end 
  endgenerate
  input [3:0] ram_init_addr;
  output wire [3:0] wr_data_buf_addr;
  localparam PNTR_RAM_CNT = 2;
  generate begin : pointer_ram
      wire pointer_we = new_rd_data || ~ram_init_done_r;
      wire [3:0] pointer_wr_data = ram_init_done_r
                                    ? wr_data_addr_r
                                    : ram_init_addr;
      wire [3:0] pointer_wr_addr = ram_init_done_r
                                    ? rd_data_indx_r
                                    : ram_init_addr;
      genvar i;
      for (i=0; i<PNTR_RAM_CNT; i=i+1) begin : rams
        RAM32M
          #(.INIT_A(64'h0000000000000000),
            .INIT_B(64'h0000000000000000),
            .INIT_C(64'h0000000000000000),
            .INIT_D(64'h0000000000000000)
          ) RAM32M0 (
            .DOA(),
            .DOB(wr_data_buf_addr[i*2+:2]),
            .DOC(wr_data_pntr[i*2+:2]),
            .DOD(),
            .DIA(2'b0),
            .DIB(pointer_wr_data[i*2+:2]),
            .DIC(pointer_wr_data[i*2+:2]),
            .DID(2'b0),
            .ADDRA(5'b0),
            .ADDRB({1'b0, data_buf_addr_cnt_r}),
            .ADDRC({1'b0, wr_data_indx_r}),
            .ADDRD({1'b0, pointer_wr_addr}),
            .WE(pointer_we),
            .WCLK(clk)
           );
      end 
    end 
  endgenerate
  localparam WR_BUF_WIDTH = 
               APP_DATA_WIDTH + APP_MASK_WIDTH + (ECC_TEST == "OFF" ? 0 : 4);
  localparam FULL_RAM_CNT = (WR_BUF_WIDTH/6);
  localparam REMAINDER = WR_BUF_WIDTH % 6;
  localparam RAM_CNT = FULL_RAM_CNT + ((REMAINDER == 0 ) ? 0 : 1);
  localparam RAM_WIDTH = (RAM_CNT*6);
  wire [RAM_WIDTH-1:0] wr_buf_out_data;
  generate
    begin : write_buffer
      wire [RAM_WIDTH-1:0] wr_buf_in_data;
      if (REMAINDER == 0)
        if (ECC_TEST == "OFF")
          assign wr_buf_in_data = {app_wdf_mask_r1, app_wdf_data_r1};
        else
          assign wr_buf_in_data = 
                   {app_raw_not_ecc_r1, app_wdf_mask_r1, app_wdf_data_r1};
      else
        if (ECC_TEST == "OFF")
          assign wr_buf_in_data =
               {{6-REMAINDER{1'b0}}, app_wdf_mask_r1, app_wdf_data_r1};
        else 
          assign wr_buf_in_data = {{6-REMAINDER{1'b0}}, app_raw_not_ecc_r1, 
                                   app_wdf_mask_r1, app_wdf_data_r1};
      reg [4:0] rd_addr_r;
      always @(posedge clk) rd_addr_r <= #TCQ {wr_data_addr, wr_data_offset};
      genvar i;
      for (i=0; i<RAM_CNT; i=i+1) begin : wr_buffer_ram
        RAM32M
          #(.INIT_A(64'h0000000000000000),
            .INIT_B(64'h0000000000000000),
            .INIT_C(64'h0000000000000000),
            .INIT_D(64'h0000000000000000)
          ) RAM32M0 (
            .DOA(wr_buf_out_data[((i*6)+4)+:2]),
            .DOB(wr_buf_out_data[((i*6)+2)+:2]),
            .DOC(wr_buf_out_data[((i*6)+0)+:2]),
            .DOD(),
            .DIA(wr_buf_in_data[((i*6)+4)+:2]),
            .DIB(wr_buf_in_data[((i*6)+2)+:2]),
            .DIC(wr_buf_in_data[((i*6)+0)+:2]),
            .DID(2'b0),
            .ADDRA(rd_addr_r),
            .ADDRB(rd_addr_r),
            .ADDRC(rd_addr_r),
            .ADDRD(wb_wr_data_addr),
            .WE(app_wdf_rdy_r_copy4),
            .WCLK(clk)
           );
      end 
    end
  endgenerate
  output [APP_DATA_WIDTH-1:0] wr_data;
  output [APP_MASK_WIDTH-1:0] wr_data_mask;
  assign {wr_data_mask, wr_data} = wr_buf_out_data[WR_BUF_WIDTH-1:0];
  output [3:0] raw_not_ecc;
  generate
    if (ECC_TEST == "OFF") assign raw_not_ecc = 4'b0;
    else assign raw_not_ecc = wr_buf_out_data[WR_BUF_WIDTH-1-:4];
  endgenerate
endmodule 
