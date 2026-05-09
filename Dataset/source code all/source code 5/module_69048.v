`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module arb_select #
  (
   parameter TCQ = 100,
   parameter ADDR_CMD_MODE            = "UNBUF",
   parameter BANK_VECT_INDX           = 11,
   parameter BANK_WIDTH               = 3,
   parameter BURST_MODE               = "8",
   parameter CS_WIDTH                 = 4,
   parameter DATA_BUF_ADDR_VECT_INDX  = 31,
   parameter DATA_BUF_ADDR_WIDTH      = 8,
   parameter DRAM_TYPE                = "DDR3",
   parameter EARLY_WR_DATA_ADDR       = "OFF",
   parameter ECC                      = "OFF",
   parameter nBANK_MACHS              = 4,
   parameter nCK_PER_CLK              = 2,
   parameter nCS_PER_RANK             = 1,
   parameter nSLOTS                   = 2,
   parameter RANK_VECT_INDX           = 15,
   parameter RANK_WIDTH               = 2,
   parameter ROW_VECT_INDX            = 63,
   parameter ROW_WIDTH                = 16,
   parameter RTT_NOM                  = "40",
   parameter RTT_WR                   = "120",
   parameter SLOT_0_CONFIG            = 8'b0000_0101,
   parameter SLOT_1_CONFIG            = 8'b0000_1010
  )
  (
  col_periodic_rd, col_ra, col_ba, col_a, col_rmw, col_size, col_row,
  col_data_buf_addr, col_wr_data_buf_addr, dfi_bank0, dfi_address0,
  dfi_ras_n0, dfi_cas_n0, dfi_we_n0, dfi_bank1, dfi_address1,
  dfi_ras_n1, dfi_cas_n1, dfi_we_n1, dfi_cs_n0, dfi_cs_n1, io_config,
  dfi_odt_nom0, dfi_odt_wr0, dfi_odt_nom1, dfi_odt_wr1,
  clk, rst, req_rank_r, req_bank_r, req_ras, req_cas, req_wr_r,
  grant_row_r, row_addr, row_cmd_wr, insert_maint_r1, maint_zq_r,
  maint_rank_r, req_periodic_rd_r, req_size_r, rd_wr_r, req_row_r,
  col_addr, req_data_buf_addr_r, grant_col_r, grant_col_wr,
  send_cmd0_col, send_cmd1_row, cs_en0, cs_en1, force_io_config_rd_r1,
  grant_config_r, io_config_strobe, slot_0_present, slot_1_present
  );
  localparam OUT_CMD_WIDTH = RANK_WIDTH + BANK_WIDTH + ROW_WIDTH + 1 + 1 + 1;
  input clk;
  input rst;
  input [RANK_VECT_INDX:0] req_rank_r;
  input [BANK_VECT_INDX:0] req_bank_r;
  input [nBANK_MACHS-1:0] req_ras;
  input [nBANK_MACHS-1:0] req_cas;
  input [nBANK_MACHS-1:0] req_wr_r;
  input [nBANK_MACHS-1:0] grant_row_r;
  input [ROW_VECT_INDX:0] row_addr;
  input [nBANK_MACHS-1:0] row_cmd_wr;
  input insert_maint_r1;
  input maint_zq_r;
  input [RANK_WIDTH-1:0] maint_rank_r;
  integer    i;
  reg [OUT_CMD_WIDTH-1:0] row_cmd_ns;
  generate
    begin : row_mux
      reg [OUT_CMD_WIDTH-1:0] row_cmd_r = {OUT_CMD_WIDTH {1'b0}};
      wire [OUT_CMD_WIDTH-1:0] maint_cmd =
                     {maint_rank_r,                     
                      row_cmd_r[15+:(BANK_WIDTH+ROW_WIDTH-11)],
                      1'b0,                            
                      row_cmd_r[3+:10],                
                      (maint_zq_r ? 3'b110 : 3'b001)   
                     };
      always @(grant_row_r or insert_maint_r1 or maint_cmd
               or req_bank_r or req_cas or req_rank_r or req_ras
               or row_addr or row_cmd_r or row_cmd_wr or rst)
        begin
          row_cmd_ns = rst
                         ? {RANK_WIDTH{1'b0}}
                         : insert_maint_r1
                            ? maint_cmd
                            : row_cmd_r;
          for (i=0; i<nBANK_MACHS; i=i+1)
            if (grant_row_r[i])
               row_cmd_ns = {req_rank_r[(RANK_WIDTH*i)+:RANK_WIDTH],
                             req_bank_r[(BANK_WIDTH*i)+:BANK_WIDTH],
                             row_addr[(ROW_WIDTH*i)+:ROW_WIDTH],
                             req_ras[i],
                             req_cas[i],
                             row_cmd_wr[i]};
        end
      if (~((nCK_PER_CLK == 2) && (ADDR_CMD_MODE != "2T")))
        always @(posedge clk) row_cmd_r <= #TCQ row_cmd_ns;
    end  
  endgenerate
  input [nBANK_MACHS-1:0] req_periodic_rd_r;
  input [nBANK_MACHS-1:0] req_size_r;
  input [nBANK_MACHS-1:0] rd_wr_r;
  input [ROW_VECT_INDX:0] req_row_r;
  input [ROW_VECT_INDX:0] col_addr;
  input [DATA_BUF_ADDR_VECT_INDX:0] req_data_buf_addr_r;
  input [nBANK_MACHS-1:0] grant_col_r;
  input [nBANK_MACHS-1:0] grant_col_wr;
  output wire col_periodic_rd;
  output wire [RANK_WIDTH-1:0] col_ra;
  output wire [BANK_WIDTH-1:0] col_ba;
  output wire [ROW_WIDTH-1:0] col_a;
  output wire col_rmw;
  output wire col_size;
  output wire [ROW_WIDTH-1:0] col_row;
  output wire [DATA_BUF_ADDR_WIDTH-1:0] col_data_buf_addr;
  output wire [DATA_BUF_ADDR_WIDTH-1:0] col_wr_data_buf_addr;
  reg [OUT_CMD_WIDTH-1:0] col_cmd_ns;
  generate
    begin : col_mux
      reg col_periodic_rd_ns;
      reg col_periodic_rd_r;
      reg [OUT_CMD_WIDTH-1:0] col_cmd_r = {OUT_CMD_WIDTH {1'b0}};
      reg col_rmw_ns;
      reg col_rmw_r;
      reg col_size_ns;
      reg col_size_r;
      reg [ROW_WIDTH-1:0] col_row_ns;
      reg [ROW_WIDTH-1:0] col_row_r;
      reg [DATA_BUF_ADDR_WIDTH-1:0] col_data_buf_addr_ns;
      reg [DATA_BUF_ADDR_WIDTH-1:0] col_data_buf_addr_r;
      always @(col_addr or col_cmd_r or col_data_buf_addr_r
               or col_periodic_rd_r or col_rmw_r or col_row_r
               or col_size_r or grant_col_r or rd_wr_r or req_bank_r
               or req_data_buf_addr_r or req_periodic_rd_r
               or req_rank_r or req_row_r or req_size_r or req_wr_r
               or rst)
        begin
          col_periodic_rd_ns = ~rst && col_periodic_rd_r;
          col_cmd_ns = {(rst ? {RANK_WIDTH{1'b0}}
                             : col_cmd_r[(OUT_CMD_WIDTH-1)-:RANK_WIDTH]),
                        ((rst && ECC != "OFF")
                           ? {OUT_CMD_WIDTH-3-RANK_WIDTH{1'b0}}
                           : col_cmd_r[3+:(OUT_CMD_WIDTH-3-RANK_WIDTH)]),
                        (rst ? 3'b0 : col_cmd_r[2:0])};
          col_rmw_ns = col_rmw_r;
          col_size_ns = rst ? 1'b0 : col_size_r;
          col_row_ns = col_row_r;
          col_data_buf_addr_ns = col_data_buf_addr_r;
          for (i=0; i<nBANK_MACHS; i=i+1)
            if (grant_col_r[i]) begin
              col_periodic_rd_ns = req_periodic_rd_r[i];
              col_cmd_ns = {req_rank_r[(RANK_WIDTH*i)+:RANK_WIDTH],
                            req_bank_r[(BANK_WIDTH*i)+:BANK_WIDTH],
                            col_addr[(ROW_WIDTH*i)+:ROW_WIDTH],
                            1'b1,
                            1'b0,
                            rd_wr_r[i]};
              col_rmw_ns = req_wr_r[i] && rd_wr_r[i];
              col_size_ns = req_size_r[i];
              col_row_ns = req_row_r[(ROW_WIDTH*i)+:ROW_WIDTH];
              col_data_buf_addr_ns =
           req_data_buf_addr_r[(DATA_BUF_ADDR_WIDTH*i)+:DATA_BUF_ADDR_WIDTH];
            end
        end 
      if (EARLY_WR_DATA_ADDR == "OFF") begin : early_wr_data_addr_off
        assign col_wr_data_buf_addr = col_data_buf_addr_ns;
      end
      else begin : early_wr_data_addr_on
        reg [DATA_BUF_ADDR_WIDTH-1:0] col_wr_data_buf_addr_ns;
        reg [DATA_BUF_ADDR_WIDTH-1:0] col_wr_data_buf_addr_r;
        always @(col_wr_data_buf_addr_r or grant_col_wr
                 or req_data_buf_addr_r) begin
          col_wr_data_buf_addr_ns = col_wr_data_buf_addr_r;
          for (i=0; i<nBANK_MACHS; i=i+1)
            if (grant_col_wr[i])
              col_wr_data_buf_addr_ns =
           req_data_buf_addr_r[(DATA_BUF_ADDR_WIDTH*i)+:DATA_BUF_ADDR_WIDTH];
        end
        always @(posedge clk) col_wr_data_buf_addr_r <= 
                                #TCQ col_wr_data_buf_addr_ns;
        assign col_wr_data_buf_addr = col_wr_data_buf_addr_ns;
      end
      always @(posedge clk) col_periodic_rd_r <= #TCQ col_periodic_rd_ns;
      always @(posedge clk) col_rmw_r <= #TCQ col_rmw_ns;
      always @(posedge clk) col_size_r <= #TCQ col_size_ns;
      always @(posedge clk) col_data_buf_addr_r <=
                              #TCQ col_data_buf_addr_ns;
      if (ECC != "OFF") begin
        always @(posedge clk) col_cmd_r <= #TCQ col_cmd_ns;
        always @(posedge clk) col_row_r <= #TCQ col_row_ns;
      end
      assign col_periodic_rd = col_periodic_rd_ns;
      assign col_ra = col_cmd_ns[3+ROW_WIDTH+BANK_WIDTH+:RANK_WIDTH];
      assign col_ba = col_cmd_ns[3+ROW_WIDTH+:BANK_WIDTH];
      assign col_a = col_cmd_ns[3+:ROW_WIDTH];
      assign col_rmw = col_rmw_ns;
      assign col_size = col_size_ns;
      assign col_row = col_row_ns;
      assign col_data_buf_addr = col_data_buf_addr_ns;
     end 
  endgenerate
  input send_cmd0_col;
  reg [OUT_CMD_WIDTH-1:0] cmd0;
  always @(col_cmd_ns or row_cmd_ns or send_cmd0_col) begin
    cmd0 = row_cmd_ns;
    if (send_cmd0_col) cmd0 = col_cmd_ns;
  end
  input send_cmd1_row;
  reg [OUT_CMD_WIDTH-1:0] cmd1 = {OUT_CMD_WIDTH{1'b1}};
  generate
    if (nCK_PER_CLK == 2)
     always @(col_cmd_ns or row_cmd_ns or send_cmd1_row) begin
       cmd1 = col_cmd_ns;
       if (send_cmd1_row) cmd1 = row_cmd_ns;
     end
  endgenerate
  wire [RANK_WIDTH-1:0] ra0;
  output wire [BANK_WIDTH-1:0] dfi_bank0;
  output wire [ROW_WIDTH-1:0] dfi_address0;
  output wire dfi_ras_n0;
  output wire dfi_cas_n0;
  output wire dfi_we_n0;
  assign {ra0, dfi_bank0, dfi_address0, dfi_ras_n0, dfi_cas_n0, dfi_we_n0} =
           cmd0;
  wire [RANK_WIDTH-1:0] ra1;
  output wire [BANK_WIDTH-1:0] dfi_bank1;
  output wire [ROW_WIDTH-1:0] dfi_address1;
  output wire dfi_ras_n1;
  output wire dfi_cas_n1;
  output wire dfi_we_n1;
  assign {ra1, dfi_bank1, dfi_address1, dfi_ras_n1, dfi_cas_n1, dfi_we_n1} =
           cmd1;
   localparam ONE = {nCS_PER_RANK{1'b1}};
  wire [(CS_WIDTH*nCS_PER_RANK)-1:0] cs_one_hot = 
				     {{CS_WIDTH{1'b0}},ONE};
  input cs_en0;
  input cs_en1;
  output wire [(CS_WIDTH*nCS_PER_RANK)-1:0] dfi_cs_n0;
  output wire [(CS_WIDTH*nCS_PER_RANK)-1:0] dfi_cs_n1;
  assign dfi_cs_n0 =
     {(~(cs_one_hot << (nCS_PER_RANK*ra0)) | {CS_WIDTH*nCS_PER_RANK{~cs_en0}})};
  assign dfi_cs_n1 =
     {(~(cs_one_hot << (nCS_PER_RANK*ra1)) | {CS_WIDTH*nCS_PER_RANK{~cs_en1}})};
  input force_io_config_rd_r1;
  input [nBANK_MACHS-1:0] grant_config_r;
  input io_config_strobe;
  reg [RANK_WIDTH:0] io_config_ns;
  reg [RANK_WIDTH:0] io_config_r;
  always @(force_io_config_rd_r1 or grant_config_r
           or io_config_r or io_config_strobe or rd_wr_r or req_rank_r
           or rst) begin
    if (rst) io_config_ns = {RANK_WIDTH{1'b0}};
    else begin
      io_config_ns = io_config_r;
      if (io_config_strobe)
        if (force_io_config_rd_r1) io_config_ns =
                                 {1'b0, io_config_r[RANK_WIDTH-1:0]};
        else
          for (i=0; i<nBANK_MACHS; i=i+1)
            if (grant_config_r[i]) io_config_ns =
                       {~rd_wr_r[i], req_rank_r[(RANK_WIDTH*i)+:RANK_WIDTH]};
    end 
  end
  always @(posedge clk) io_config_r <= #TCQ io_config_ns;
  output wire [RANK_WIDTH:0] io_config; 
  assign io_config = io_config_ns;
  input [7:0] slot_0_present;
  input [7:0] slot_1_present;
  wire [CS_WIDTH-1:0] io_config_one_hot =
                        cs_one_hot << io_config_ns[RANK_WIDTH-1:0];
  wire slot_0_select = (nSLOTS == 1) ? |(io_config_one_hot & slot_0_present)
                       : (slot_0_present[2] & slot_0_present[0]) ?
                         |(io_config_one_hot[CS_WIDTH-1:0] & {slot_0_present[2],
			  slot_0_present[0]}) : (slot_0_present[0])?
                          io_config_one_hot[0] : 1'b0;
  wire slot_0_read = slot_0_select && ~io_config_ns[RANK_WIDTH];
  wire slot_0_write = slot_0_select && io_config_ns[RANK_WIDTH];
  reg [1:0] slot_1_population = 2'b0;
  reg[1:0] slot_0_population;
  always @(slot_0_present) begin
    slot_0_population = 2'b0;
    for (i=0; i<8; i=i+1)
      if (~slot_0_population[1])
        if (slot_0_present[i] == 1'b1) slot_0_population =
                                         slot_0_population + 2'b1;
  end
  wire slot_0_dynamic_odt = ~slot_0_population[1];
  wire odt_0_nom = (RTT_NOM != "DISABLED") &&
                    ((DRAM_TYPE == "DDR3")
                       ? slot_0_write     
                       : (slot_0_write && ~|slot_1_population) ||
                           ~slot_0_select);
  wire odt_0_wr = ((RTT_WR != "OFF") && (nSLOTS > 1) && (DRAM_TYPE == "DDR3")) 
                     ? slot_0_write
                     : 1'b0;
  wire [nSLOTS*nCS_PER_RANK-1:0] odt_nom;
  wire [nSLOTS*nCS_PER_RANK-1:0] odt_wr;
  generate
    if (nSLOTS > 1) begin : slot_1_configured
      wire slot_1_select = (slot_1_present[3] & slot_1_present[1])? 
            |({io_config_one_hot[slot_0_population+1],
            io_config_one_hot[slot_0_population]}) :
	   (slot_1_present[1]) ? io_config_one_hot[slot_0_population] :1'b0;
      wire slot_1_read = slot_1_select && ~io_config_ns[RANK_WIDTH];
      wire slot_1_write = slot_1_select && io_config_ns[RANK_WIDTH];
      always @(slot_1_present) begin
        slot_1_population = 2'b0;
        for (i=0; i<8; i=i+1)
          if (~slot_1_population[1])
            if (slot_1_present[i] == 1'b1) slot_1_population =
                                             slot_1_population + 2'b1;
      end
      wire slot_1_dynamic_odt = ~slot_1_population[1];
      wire odt_1_nom = (RTT_NOM != "DISABLED") &&
                        ((DRAM_TYPE == "DDR3")
                           ? slot_1_dynamic_odt ? ~slot_1_read : ~slot_1_select
                           : (slot_1_write && ~|slot_0_population) ||
                                ~slot_1_select);
      wire odt_1_wr = ((RTT_WR != "OFF") && (DRAM_TYPE == "DDR3"))
                         ? slot_1_write
                         : 1'b0;
      assign odt_nom =
              {{nCS_PER_RANK{odt_1_nom}}, {nCS_PER_RANK{odt_0_nom}}};
      assign odt_wr = {{nCS_PER_RANK{odt_1_wr}}, {nCS_PER_RANK{odt_0_wr}}};
    end 
    else begin
      assign odt_nom = {nCS_PER_RANK{odt_0_nom}};
      assign odt_wr = {nCS_PER_RANK{odt_0_wr}};
    end 
  endgenerate
  output wire [(nSLOTS*nCS_PER_RANK)-1:0] dfi_odt_nom0;
  output wire [(nSLOTS*nCS_PER_RANK)-1:0] dfi_odt_wr0;
  output wire [(nSLOTS*nCS_PER_RANK)-1:0] dfi_odt_nom1;
  output wire [(nSLOTS*nCS_PER_RANK)-1:0] dfi_odt_wr1;
  assign dfi_odt_nom0 = odt_nom;
  assign dfi_odt_wr0 = odt_wr;
  assign dfi_odt_nom1 = odt_nom;
  assign dfi_odt_wr1 = odt_wr;
endmodule
