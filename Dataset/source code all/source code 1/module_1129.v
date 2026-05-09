`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module ui_rd_data #
  (
   parameter TCQ = 100,
   parameter APP_DATA_WIDTH       = 256,
   parameter ECC                  = "OFF",
   parameter nCK_PER_CLK          = 2 ,
   parameter ORDERING             = "NORM"
  )
  (
  ram_init_done_r, ram_init_addr, app_rd_data_valid, app_rd_data_end,
  app_rd_data, app_ecc_multiple_err, rd_buf_full, rd_data_buf_addr_r,
  rst, clk, rd_data_en, rd_data_addr, rd_data_offset, rd_data_end,
  rd_data, ecc_multiple, rd_accepted
  );
  input rst;
  input clk;
  output wire ram_init_done_r;
  output wire [3:0] ram_init_addr;
  reg [5:0] rd_buf_indx_r;
  reg ram_init_done_r_lcl;
  assign ram_init_done_r = ram_init_done_r_lcl;
  wire app_rd_data_valid_ns;
  wire single_data;
  reg [5:0] rd_buf_indx_ns;
  generate begin : rd_buf_indx
      wire upd_rd_buf_indx = ~ram_init_done_r_lcl || app_rd_data_valid_ns;
      wire ram_init_done_ns =
            ~rst && (ram_init_done_r_lcl || (rd_buf_indx_r[4:0] == 5'h1f));
      always @(posedge clk) ram_init_done_r_lcl <= #TCQ ram_init_done_ns;
      always @(rd_buf_indx_r or rst or single_data
               or upd_rd_buf_indx) begin
        rd_buf_indx_ns = rd_buf_indx_r;
        if (rst) rd_buf_indx_ns = 6'b0;
        else if (upd_rd_buf_indx) rd_buf_indx_ns =
                   rd_buf_indx_r + 6'h1 + single_data;
      end
      always @(posedge clk) rd_buf_indx_r <= #TCQ rd_buf_indx_ns;
    end
  endgenerate
  assign ram_init_addr = rd_buf_indx_r[3:0];
  input rd_data_en;
  input [3:0] rd_data_addr;
  input rd_data_offset;
  input rd_data_end;
  input [APP_DATA_WIDTH-1:0] rd_data;
  output reg app_rd_data_valid;
  output reg app_rd_data_end;
  output reg [APP_DATA_WIDTH-1:0] app_rd_data;
  input [3:0] ecc_multiple;
  reg [2*nCK_PER_CLK-1:0] app_ecc_multiple_err_r = 'b0;
  output wire [2*nCK_PER_CLK-1:0] app_ecc_multiple_err;
  assign app_ecc_multiple_err = app_ecc_multiple_err_r;
  input rd_accepted;
  output wire rd_buf_full;
  output wire [3:0] rd_data_buf_addr_r;
  localparam RD_BUF_WIDTH = APP_DATA_WIDTH + (ECC == "OFF" ? 0 : 2*nCK_PER_CLK);
  localparam FULL_RAM_CNT = (RD_BUF_WIDTH/6);
  localparam REMAINDER = RD_BUF_WIDTH % 6;
  localparam RAM_CNT = FULL_RAM_CNT + ((REMAINDER == 0 ) ? 0 : 1);
  localparam RAM_WIDTH = (RAM_CNT*6);
  generate
    if (ORDERING == "STRICT") begin : strict_mode
      assign app_rd_data_valid_ns = 1'b0;
      assign single_data = 1'b0;
      assign rd_buf_full = 1'b0;
      reg [3:0] rd_data_buf_addr_r_lcl;
      wire [3:0] rd_data_buf_addr_ns =
                   rst
                    ? 4'b0
                    : rd_data_buf_addr_r_lcl + {3'b0, rd_accepted};
      always @(posedge clk) rd_data_buf_addr_r_lcl <=
                                #TCQ rd_data_buf_addr_ns;
      assign rd_data_buf_addr_r = rd_data_buf_addr_ns;
      if (ECC == "OFF") begin : ecc_off
        always @(rd_data) app_rd_data = rd_data;
        always @(rd_data_en) app_rd_data_valid = rd_data_en;
        always @(rd_data_end) app_rd_data_end = rd_data_end;
      end
      else begin : ecc_on  
        always @(posedge clk) app_rd_data <= #TCQ rd_data;
        always @(posedge clk) app_rd_data_valid <= #TCQ rd_data_en;
        always @(posedge clk) app_rd_data_end <= #TCQ rd_data_end;
        always @(posedge clk) app_ecc_multiple_err_r <= #TCQ ecc_multiple;
      end
    end
    else begin : not_strict_mode
      wire rd_buf_we = ~ram_init_done_r_lcl || rd_data_en;
      wire [4:0] rd_buf_wr_addr = {rd_data_addr, rd_data_offset};
      wire [1:0] rd_status;
      begin : status_ram
        wire [4:0] status_ram_wr_addr_ns = ram_init_done_r_lcl
                                           ? rd_buf_wr_addr
                                           : rd_buf_indx_r[4:0];
        reg [4:0] status_ram_wr_addr_r;
        always @(posedge clk) status_ram_wr_addr_r <=
                             #TCQ status_ram_wr_addr_ns;
        wire [1:0] wr_status;
        reg wr_status_r1;
        always @(posedge clk) wr_status_r1 <= #TCQ wr_status[0];
        wire [1:0] status_ram_wr_data_ns =
                         ram_init_done_r_lcl
                           ? {rd_data_end, ~(rd_data_offset
                                              ? wr_status_r1
                                              : wr_status[0])}
                           : 2'b0;
        reg [1:0] status_ram_wr_data_r;
        always @(posedge clk) status_ram_wr_data_r <=
                              #TCQ status_ram_wr_data_ns;
        reg rd_buf_we_r1;
        always @(posedge clk) rd_buf_we_r1 <= #TCQ rd_buf_we;
        RAM32M
          #(.INIT_A(64'h0000000000000000),
            .INIT_B(64'h0000000000000000),
            .INIT_C(64'h0000000000000000),
            .INIT_D(64'h0000000000000000)
           ) RAM32M0 (
            .DOA(rd_status),
            .DOB(),
            .DOC(wr_status),
            .DOD(),
            .DIA(status_ram_wr_data_r),
            .DIB(2'b0),
            .DIC(status_ram_wr_data_r),
            .DID(status_ram_wr_data_r),
            .ADDRA(rd_buf_indx_r[4:0]),
            .ADDRB(5'b0),
            .ADDRC(status_ram_wr_addr_ns),
            .ADDRD(status_ram_wr_addr_r),
            .WE(rd_buf_we_r1),
            .WCLK(clk)
           );
      end 
      wire [RAM_WIDTH-1:0] rd_buf_out_data;
      begin : rd_buf
        wire [RAM_WIDTH-1:0] rd_buf_in_data;
        if (REMAINDER == 0)
          if (ECC == "OFF")
            assign rd_buf_in_data = rd_data;
          else
            assign rd_buf_in_data = {ecc_multiple, rd_data};
        else
          if (ECC == "OFF")
            assign rd_buf_in_data = {{6-REMAINDER{1'b0}}, rd_data};
          else
            assign rd_buf_in_data = 
              {{6-REMAINDER{1'b0}}, ecc_multiple, rd_data};
        (* equivalent_register_removal = "no" *)
        reg [4:0] rd_buf_indx_copy_r;
        always @(posedge clk) rd_buf_indx_copy_r <= #TCQ rd_buf_indx_ns[4:0];
        genvar i;
        for (i=0; i<RAM_CNT; i=i+1) begin : rd_buffer_ram
          RAM32M
            #(.INIT_A(64'h0000000000000000),
              .INIT_B(64'h0000000000000000),
              .INIT_C(64'h0000000000000000),
              .INIT_D(64'h0000000000000000)
          ) RAM32M0 (
              .DOA(rd_buf_out_data[((i*6)+4)+:2]),
              .DOB(rd_buf_out_data[((i*6)+2)+:2]),
              .DOC(rd_buf_out_data[((i*6)+0)+:2]),
              .DOD(),
              .DIA(rd_buf_in_data[((i*6)+4)+:2]),
              .DIB(rd_buf_in_data[((i*6)+2)+:2]),
              .DIC(rd_buf_in_data[((i*6)+0)+:2]),
              .DID(2'b0),
              .ADDRA(rd_buf_indx_copy_r[4:0]),
              .ADDRB(rd_buf_indx_copy_r[4:0]),
              .ADDRC(rd_buf_indx_copy_r[4:0]),
              .ADDRD(rd_buf_wr_addr),
              .WE(rd_buf_we),
              .WCLK(clk)
             );
        end 
      end
      wire rd_data_rdy = (rd_status[0] == rd_buf_indx_r[5]);
      wire bypass = rd_data_en && (rd_buf_wr_addr[4:0] == rd_buf_indx_r[4:0]);
      assign app_rd_data_valid_ns =
              ram_init_done_r_lcl && (bypass || rd_data_rdy);
      wire app_rd_data_end_ns = bypass ? rd_data_end : rd_status[1];
      always @(posedge clk) app_rd_data_valid <= #TCQ app_rd_data_valid_ns;
      always @(posedge clk) app_rd_data_end <= #TCQ app_rd_data_end_ns;
      assign single_data =
          app_rd_data_valid_ns && app_rd_data_end_ns && ~rd_buf_indx_r[0];
      wire [APP_DATA_WIDTH-1:0] app_rd_data_ns =
                              bypass
                                ? rd_data
                                : rd_buf_out_data[APP_DATA_WIDTH-1:0];
      always @(posedge clk) app_rd_data <= #TCQ app_rd_data_ns;
      if (ECC != "OFF") begin : assign_app_ecc_multiple
        wire [3:0] app_ecc_multiple_err_ns =
                              bypass
                                ? ecc_multiple
                                : rd_buf_out_data[APP_DATA_WIDTH+:4];
        always @(posedge clk) app_ecc_multiple_err_r <= 
                                #TCQ app_ecc_multiple_err_ns;
      end
      (* equivalent_register_removal = "no" *)
      reg app_rd_data_valid_copy;
      always @(posedge clk) app_rd_data_valid_copy <= #TCQ app_rd_data_valid_ns;
      wire free_rd_buf = app_rd_data_valid_copy && app_rd_data_end; 
      reg [4:0] occ_cnt_r;
      wire [4:0] occ_minus_one = occ_cnt_r - 5'b1;
      wire [4:0] occ_plus_one = occ_cnt_r + 5'b1;
      begin : occupied_counter
        reg [4:0] occ_cnt_ns;
        always @(free_rd_buf or occ_cnt_r or rd_accepted or rst or occ_minus_one or occ_plus_one) begin
          occ_cnt_ns = occ_cnt_r;
          if (rst) occ_cnt_ns = 5'b0;
          else case ({rd_accepted, free_rd_buf})
                 2'b01 : occ_cnt_ns = occ_minus_one;
                 2'b10 : occ_cnt_ns = occ_plus_one;
          endcase 
        end
        always @(posedge clk) occ_cnt_r <= #TCQ occ_cnt_ns;
        assign rd_buf_full = occ_cnt_ns[4];
`ifdef MC_SVA
  rd_data_buffer_full: cover property (@(posedge clk) (~rst && rd_buf_full));
  rd_data_buffer_inc_dec_15: cover property (@(posedge clk)
         (~rst && rd_accepted && free_rd_buf && (occ_cnt_r == 5'hf)));
  rd_data_underflow: assert property (@(posedge clk)
         (rst || !((occ_cnt_r == 5'b0) && (occ_cnt_ns == 5'h1f))));
  rd_data_overflow: assert property (@(posedge clk)
         (rst || !((occ_cnt_r == 5'h10) && (occ_cnt_ns == 5'h11))));
`endif
    end 
      reg [3:0] rd_data_buf_addr_r_lcl;
      assign rd_data_buf_addr_r = rd_data_buf_addr_r_lcl;
      begin : data_buf_addr
        reg [3:0] rd_data_buf_addr_ns;
        always @(rd_accepted or rd_data_buf_addr_r_lcl or rst) begin
          rd_data_buf_addr_ns = rd_data_buf_addr_r_lcl;
          if (rst) rd_data_buf_addr_ns = 4'b0;
          else if (rd_accepted) rd_data_buf_addr_ns =
                                  rd_data_buf_addr_r_lcl + 4'h1;
        end
        always @(posedge clk) rd_data_buf_addr_r_lcl <=
                                #TCQ rd_data_buf_addr_ns;
      end 
    end 
  endgenerate
endmodule 
