`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module ui_cmd #
  (
   parameter TCQ = 100,
   parameter ADDR_WIDTH         = 33,
   parameter BANK_WIDTH         = 3,
   parameter COL_WIDTH          = 12,
   parameter RANK_WIDTH         = 2,
   parameter ROW_WIDTH          = 16,
   parameter RANKS              = 4,
   parameter MEM_ADDR_ORDER     = "BANK_ROW_COLUMN"
  )
  (
  app_rdy, use_addr, rank, bank, row, col, size, cmd, hi_priority,
  rd_accepted, wr_accepted, data_buf_addr,
  rst, clk, accept_ns, rd_buf_full, wr_req_16, app_addr, app_cmd,
  app_sz, app_hi_pri, app_en, wr_data_buf_addr, rd_data_buf_addr_r
  );
  input rst;
  input clk;
  input accept_ns;
  input rd_buf_full;
  input wr_req_16;
  wire app_rdy_ns = accept_ns && ~rd_buf_full && ~wr_req_16;
  reg app_rdy_r = 1'b0 ;
  always @(posedge clk) app_rdy_r <= #TCQ app_rdy_ns;
  reg app_rdy_inv_r;
  always @(posedge clk) app_rdy_inv_r <= #TCQ ~app_rdy_ns;
  output wire app_rdy;
  assign app_rdy = app_rdy_r;
  input [ADDR_WIDTH-1:0] app_addr;
  input [2:0] app_cmd;
  input app_sz;
  input app_hi_pri;
  input app_en;
  reg [ADDR_WIDTH-1:0] app_addr_r1 = {ADDR_WIDTH{1'b0}};
  reg [ADDR_WIDTH-1:0] app_addr_r2 = {ADDR_WIDTH{1'b0}};
  reg [2:0] app_cmd_r1;
  reg [2:0] app_cmd_r2;
  reg app_sz_r1;
  reg app_sz_r2;
  reg app_hi_pri_r1;
  reg app_hi_pri_r2;
  reg app_en_r1;
  reg app_en_r2;
  wire [ADDR_WIDTH-1:0] app_addr_ns1 = ({ADDR_WIDTH{app_rdy_r}} & {ADDR_WIDTH{app_en}} & app_addr) | ({ADDR_WIDTH{app_rdy_inv_r}} & app_addr_r1);
  wire [ADDR_WIDTH-1:0] app_addr_ns2 = ({ADDR_WIDTH{app_rdy_r}} & app_addr_r1) | ({ADDR_WIDTH{app_rdy_inv_r}} & app_addr_r2);
  wire [2:0] app_cmd_ns1 = ({3{app_rdy_r}} & app_cmd) | ({3{app_rdy_inv_r}} & app_cmd_r1);
  wire [2:0] app_cmd_ns2 = ({3{app_rdy_r}} & app_cmd_r1) | ({3{app_rdy_inv_r}} & app_cmd_r2);
  wire app_sz_ns1 = (app_rdy_r & app_sz) | (app_rdy_inv_r & app_sz_r1);
  wire app_sz_ns2 = (app_rdy_r & app_sz_r1) | (app_rdy_inv_r & app_sz_r2);
  wire app_hi_pri_ns1 = (app_rdy_r & app_hi_pri) | (app_rdy_inv_r & app_hi_pri_r1);
  wire app_hi_pri_ns2 = (app_rdy_r & app_hi_pri_r1) | (app_rdy_inv_r & app_hi_pri_r2);
  wire app_en_ns1 = ~rst && ((app_rdy_r & app_en )| (app_rdy_inv_r & app_en_r1));
  wire app_en_ns2 = ~rst && ((app_rdy_r & app_en_r1 )| (app_rdy_inv_r & app_en_r2));
  always @(posedge clk) begin
    app_addr_r1 <= #TCQ app_addr_ns1;
    app_addr_r2 <= #TCQ app_addr_ns2;
    app_cmd_r1 <= #TCQ app_cmd_ns1;
    app_cmd_r2 <= #TCQ app_cmd_ns2;
    app_sz_r1 <= #TCQ app_sz_ns1;
    app_sz_r2 <= #TCQ app_sz_ns2;
    app_hi_pri_r1 <= #TCQ app_hi_pri_ns1;
    app_hi_pri_r2 <= #TCQ app_hi_pri_ns2;
    app_en_r1 <= #TCQ app_en_ns1;
    app_en_r2 <= #TCQ app_en_ns2;
  end 
  wire use_addr_lcl = app_en_r2 && app_rdy_r;
  output wire use_addr;
  assign use_addr = use_addr_lcl;
  output wire [RANK_WIDTH-1:0] rank;
  output wire [BANK_WIDTH-1:0] bank;
  output wire [ROW_WIDTH-1:0] row;
  output wire [COL_WIDTH-1:0] col;
  output wire size;
  output wire [2:0] cmd;
  output wire hi_priority;
  assign col = ({COL_WIDTH{app_rdy_r}}     & app_addr_r1[0+:COL_WIDTH]) |
               ({COL_WIDTH{app_rdy_inv_r}} & app_addr_r2[0+:COL_WIDTH]);
  generate
    begin
      if (MEM_ADDR_ORDER == "ROW_BANK_COLUMN")
      begin
        assign row = ({ROW_WIDTH{app_rdy_r}}     & app_addr_r1[COL_WIDTH+BANK_WIDTH+:ROW_WIDTH]) |
                     ({ROW_WIDTH{app_rdy_inv_r}} & app_addr_r2[COL_WIDTH+BANK_WIDTH+:ROW_WIDTH]);
        assign bank = ({BANK_WIDTH{app_rdy_r}}     & app_addr_r1[COL_WIDTH+:BANK_WIDTH]) |
                    ({BANK_WIDTH{app_rdy_inv_r}} & app_addr_r2[COL_WIDTH+:BANK_WIDTH]);
      end
      else
      begin
        assign row = ({ROW_WIDTH{app_rdy_r}}     & app_addr_r1[COL_WIDTH+:ROW_WIDTH]) |
                     ({ROW_WIDTH{app_rdy_inv_r}} & app_addr_r2[COL_WIDTH+:ROW_WIDTH]);
        assign bank = ({BANK_WIDTH{app_rdy_r}}     & app_addr_r1[COL_WIDTH+ROW_WIDTH+:BANK_WIDTH]) |
                    ({BANK_WIDTH{app_rdy_inv_r}} & app_addr_r2[COL_WIDTH+ROW_WIDTH+:BANK_WIDTH]);
      end
    end
  endgenerate
  assign rank = (RANKS == 1)
                  ? 1'b0
                  : (({RANK_WIDTH{app_rdy_r}}     & app_addr_r1[COL_WIDTH+ROW_WIDTH+BANK_WIDTH+:RANK_WIDTH]) |
                     ({RANK_WIDTH{app_rdy_inv_r}} & app_addr_r2[COL_WIDTH+ROW_WIDTH+BANK_WIDTH+:RANK_WIDTH]));
  assign size = (app_rdy_r & app_sz_r1) | (app_rdy_inv_r & app_sz_r2);
  assign cmd = ({3{app_rdy_r}} & app_cmd_r1) | ({3{app_rdy_inv_r}} & app_cmd_r2);
  assign hi_priority = (app_rdy_r & app_hi_pri_r1) | (app_rdy_inv_r & app_hi_pri_r2);
  wire request_accepted = use_addr_lcl && app_rdy_r;
  wire rd = app_cmd_r2[1:0] == 2'b01;
  wire wr = app_cmd_r2[1:0] == 2'b00;
  wire wr_bytes = app_cmd_r2[1:0] == 2'b11;
  wire write = wr || wr_bytes;
  output wire rd_accepted;
  assign rd_accepted = request_accepted && rd;
  output wire wr_accepted;
  assign wr_accepted = request_accepted && write;
  input [3:0] wr_data_buf_addr;
  input [3:0] rd_data_buf_addr_r;
  output wire [3:0] data_buf_addr;
  assign data_buf_addr = ~write ? rd_data_buf_addr_r : wr_data_buf_addr;
endmodule 
