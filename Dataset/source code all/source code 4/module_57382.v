`timescale 1 ps / 1 ps
`timescale 1 ps / 1 ps
module ui_top #
  (
   parameter TCQ = 100,
   parameter APP_DATA_WIDTH  = 256,
   parameter APP_MASK_WIDTH  = 32,
   parameter BANK_WIDTH      = 3,
   parameter COL_WIDTH       = 12,
   parameter CWL             = 5,
   parameter ECC             = "OFF",
   parameter ECC_TEST        = "OFF",
   parameter ORDERING        = "NORM",
   parameter RANKS           = 4,
   parameter RANK_WIDTH      = 2,
   parameter ROW_WIDTH       = 16,
   parameter MEM_ADDR_ORDER  = "BANK_ROW_COLUMN"
  )
  (
  wr_data_mask, wr_data, use_addr, size, row, raw_not_ecc, rank,
  hi_priority, data_buf_addr, col, cmd, bank, app_wdf_rdy, app_rdy,
  app_rd_data_valid, app_rd_data_end, app_rd_data,
  app_ecc_multiple_err, correct_en,
  wr_data_offset, wr_data_en, wr_data_addr, rst, rd_data_offset,
  rd_data_end, rd_data_en, rd_data_addr, rd_data, ecc_multiple, clk,
  app_wdf_wren, app_wdf_mask, app_wdf_end, app_wdf_data, app_sz,
  app_raw_not_ecc, app_hi_pri, app_en, app_cmd, app_addr, accept_ns,
  accept, app_correct_en
  );
  input accept;
  localparam ADDR_WIDTH = RANK_WIDTH + BANK_WIDTH + ROW_WIDTH + COL_WIDTH;
  input app_correct_en;
  output wire correct_en;
  assign correct_en = app_correct_en;
  input                 accept_ns;              
  input [ADDR_WIDTH-1:0] app_addr;              
  input [2:0]           app_cmd;                
  input                 app_en;                 
  input                 app_hi_pri;             
  input [3:0]           app_raw_not_ecc;        
  input                 app_sz;                 
  input [APP_DATA_WIDTH-1:0] app_wdf_data;      
  input                 app_wdf_end;            
  input [APP_MASK_WIDTH-1:0] app_wdf_mask;      
  input                 app_wdf_wren;           
  input                 clk;                    
  input [3:0]           ecc_multiple;           
  input [APP_DATA_WIDTH-1:0] rd_data;           
  input [3:0]           rd_data_addr;           
  input                 rd_data_en;             
  input                 rd_data_end;            
  input                 rd_data_offset;         
  input                 rst;                    
  input [3:0]           wr_data_addr;           
  input                 wr_data_en;             
  input                 wr_data_offset;         
  output [3:0]          app_ecc_multiple_err;   
  output [APP_DATA_WIDTH-1:0] app_rd_data;      
  output                app_rd_data_end;        
  output                app_rd_data_valid;      
  output                app_rdy;                
  output                app_wdf_rdy;            
  output [BANK_WIDTH-1:0] bank;                 
  output [2:0]          cmd;                    
  output [COL_WIDTH-1:0] col;                   
  output [3:0]          data_buf_addr;          
  output                hi_priority;            
  output [RANK_WIDTH-1:0] rank;                 
  output [3:0]          raw_not_ecc;            
  output [ROW_WIDTH-1:0] row;                   
  output                size;                   
  output                use_addr;               
  output [APP_DATA_WIDTH-1:0] wr_data;          
  output [APP_MASK_WIDTH-1:0] wr_data_mask;     
  wire [3:0]            ram_init_addr;          
  wire                  ram_init_done_r;        
  wire                  rd_accepted;            
  wire                  rd_buf_full;            
  wire [3:0]            rd_data_buf_addr_r;     
  wire                  wr_accepted;            
  wire [3:0]            wr_data_buf_addr;       
  wire                  wr_req_16;              
  wire [ADDR_WIDTH-1 : 0] app_addr_temp;
  reg [9:0]  rst_reg;
  reg  rst_final;
  always @(posedge clk) begin
  	rst_reg <= {rst_reg[8:0],rst};
  end
  always @(posedge clk) begin
  	rst_final <= rst_reg[9];
  end
  generate
    if ( RANKS > 1 ) 
       assign app_addr_temp = app_addr;
    else
       assign app_addr_temp = {1'b0,app_addr[ADDR_WIDTH-2 : 0]};
  endgenerate
  ui_cmd #
    (
     .TCQ                               (TCQ),
     .ADDR_WIDTH                        (ADDR_WIDTH),
     .BANK_WIDTH                        (BANK_WIDTH),
     .COL_WIDTH                         (COL_WIDTH),
     .RANK_WIDTH                        (RANK_WIDTH),
     .ROW_WIDTH                         (ROW_WIDTH),
     .RANKS                             (RANKS),
     .MEM_ADDR_ORDER                    (MEM_ADDR_ORDER))
    ui_cmd0
      (
       .app_rdy                         (app_rdy),
       .use_addr                        (use_addr),
       .rank                            (rank[RANK_WIDTH-1:0]),
       .bank                            (bank[BANK_WIDTH-1:0]),
       .row                             (row[ROW_WIDTH-1:0]),
       .col                             (col[COL_WIDTH-1:0]),
       .size                            (size),
       .cmd                             (cmd[2:0]),
       .hi_priority                     (hi_priority),
       .rd_accepted                     (rd_accepted),
       .wr_accepted                     (wr_accepted),
       .data_buf_addr                   (data_buf_addr[3:0]),
       .rst                             (rst_final),
       .clk                             (clk),
       .accept_ns                       (accept_ns),
       .rd_buf_full                     (rd_buf_full),
       .wr_req_16                       (wr_req_16),
       .app_addr                        (app_addr_temp[ADDR_WIDTH-1:0]),
       .app_cmd                         (app_cmd[2:0]),
       .app_sz                          (app_sz),
       .app_hi_pri                      (app_hi_pri),
       .app_en                          (app_en),
       .wr_data_buf_addr                (wr_data_buf_addr[3:0]),
       .rd_data_buf_addr_r              (rd_data_buf_addr_r[3:0]));
  ui_wr_data #
    (
     .TCQ                               (TCQ),
     .APP_DATA_WIDTH                    (APP_DATA_WIDTH),
     .APP_MASK_WIDTH                    (APP_MASK_WIDTH),
     .ECC                               (ECC),
     .ECC_TEST                          (ECC_TEST),
     .CWL                               (CWL))
    ui_wr_data0
      (
       .app_wdf_rdy                     (app_wdf_rdy),
       .wr_req_16                       (wr_req_16),
       .wr_data_buf_addr                (wr_data_buf_addr[3:0]),
       .wr_data                         (wr_data[APP_DATA_WIDTH-1:0]),
       .wr_data_mask                    (wr_data_mask[APP_MASK_WIDTH-1:0]),
       .raw_not_ecc                     (raw_not_ecc[3:0]),
       .rst                             (rst_final),
       .clk                             (clk),
       .app_wdf_data                    (app_wdf_data[APP_DATA_WIDTH-1:0]),
       .app_wdf_mask                    (app_wdf_mask[APP_MASK_WIDTH-1:0]),
       .app_raw_not_ecc                 (app_raw_not_ecc[3:0]),
       .app_wdf_wren                    (app_wdf_wren),
       .app_wdf_end                     (app_wdf_end),
       .wr_data_offset                  (wr_data_offset),
       .wr_data_addr                    (wr_data_addr[3:0]),
       .wr_data_en                      (wr_data_en),
       .wr_accepted                     (wr_accepted),
       .ram_init_done_r                 (ram_init_done_r),
       .ram_init_addr                   (ram_init_addr[3:0]));
  ui_rd_data #
    (
     .TCQ                               (TCQ),
     .APP_DATA_WIDTH                    (APP_DATA_WIDTH),
     .ECC                               (ECC),
     .ORDERING                          (ORDERING))
    ui_rd_data0
      (
       .ram_init_done_r                 (ram_init_done_r),
       .ram_init_addr                   (ram_init_addr[3:0]),
       .app_rd_data_valid               (app_rd_data_valid),
       .app_rd_data_end                 (app_rd_data_end),
       .app_rd_data                     (app_rd_data[APP_DATA_WIDTH-1:0]),
       .app_ecc_multiple_err            (app_ecc_multiple_err[3:0]),
       .rd_buf_full                     (rd_buf_full),
       .rd_data_buf_addr_r              (rd_data_buf_addr_r[3:0]),
       .rst                             (rst_final),
       .clk                             (clk),
       .rd_data_en                      (rd_data_en),
       .rd_data_addr                    (rd_data_addr[3:0]),
       .rd_data_offset                  (rd_data_offset),
       .rd_data_end                     (rd_data_end),
       .rd_data                         (rd_data[APP_DATA_WIDTH-1:0]),
       .ecc_multiple                    (ecc_multiple[3:0]),
       .rd_accepted                     (rd_accepted));
endmodule 
