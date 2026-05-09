`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module mig_7series_v4_0_axi_mc_r_channel #
(
  parameter integer C_ID_WIDTH                = 4, 
  parameter integer C_DATA_WIDTH              = 32,
  parameter integer C_MC_BURST_LEN              = 1,
  parameter integer C_AXI_ADDR_WIDTH            = 32,
  parameter         C_MC_nCK_PER_CLK            = 2,
  parameter         C_MC_BURST_MODE             = "8" 
)
(
  input  wire                                 clk              , 
  input  wire                                 reset            , 
  output wire  [C_ID_WIDTH-1:0]               rid              , 
  output wire  [C_DATA_WIDTH-1:0]             rdata            , 
  output wire [1:0]                           rresp            , 
  output wire                                 rlast            , 
  output wire                                 rvalid           , 
  input  wire                                 rready           , 
  input  wire [C_DATA_WIDTH-1:0]              mc_app_rd_data   , 
  input  wire                                 mc_app_rd_valid  , 
  input  wire                                 mc_app_rd_last   , 
  input  wire                                 mc_app_ecc_multiple_err ,
  input  wire                                 r_push           ,
  output wire                                 r_data_rdy           , 
  input  wire [C_ID_WIDTH-1:0]                r_arid           , 
  input  wire                                 r_rlast          ,
  input  wire                                 r_ignore_begin   ,
  input  wire                                 r_ignore_end   
);
localparam P_WIDTH = 3+C_ID_WIDTH;
localparam P_DEPTH = 30;
localparam P_AWIDTH = 5;
localparam P_D_WIDTH = C_DATA_WIDTH+1;
localparam P_D_DEPTH  = (C_MC_BURST_LEN == 2)? 64 : 32;
localparam P_D_AWIDTH = (C_MC_BURST_LEN == 2)? 6: 5;
localparam P_OKAY   = 2'b00;
localparam P_EXOKAY = 2'b01;
localparam P_SLVERR = 2'b10;
localparam P_DECERR = 2'b11;
wire                       done;
wire [C_ID_WIDTH+3-1:0]    trans_in;
wire [C_ID_WIDTH+3-1:0]    trans_out;
reg  [C_ID_WIDTH+3-1:0]    trans_buf_out_r1;
reg  [C_ID_WIDTH+3-1:0]    trans_buf_out_r;
wire                       tr_empty;
wire                       tr_rden;
reg [1:0]                  state;
wire [C_ID_WIDTH-1:0]      rid_i;
wire                       assert_rlast;
wire                       ignore_begin;
wire                       ignore_end;
reg                        load_stage1;
wire                       load_stage2;
wire                       load_stage1_from_stage2;
wire                       rhandshake;
wire                       rlast_i;
wire                       r_valid_i;
wire [C_DATA_WIDTH:0]      rd_data_fifo_in;
wire [C_DATA_WIDTH:0]      rd_data_fifo_out; 
wire                       rd_en; 
wire                       rd_full;
wire                       rd_empty;  
wire                       rd_a_full;
reg                        rd_last_r;
wire                       fifo_rd_last;
wire                       trans_a_full;
wire                       trans_full;
reg                        r_ignore_begin_r;
reg                        r_ignore_end_r;
wire                       fifo_full;
localparam [1:0] 
  ZERO = 2'b10,
  ONE  = 2'b11,
  TWO  = 2'b01;
assign rresp  = (rd_data_fifo_out[C_DATA_WIDTH] === 1) ? P_SLVERR : P_OKAY;
assign rid    = rid_i;
assign rdata  = rd_data_fifo_out[C_DATA_WIDTH-1:0];
assign rlast  = assert_rlast & ((~fifo_rd_last & ignore_end) 
                          |  (fifo_rd_last & ~ignore_end));
assign rvalid = ~rd_empty & ((~fifo_rd_last & ~ignore_begin)
                                 | (fifo_rd_last & ~ignore_end ));
assign rd_en      = rhandshake & (~rd_empty);
assign rhandshake =(rvalid & rready) |
(((~fifo_rd_last & ignore_begin) | (fifo_rd_last & ignore_end )) & (~rd_empty));
always @(posedge clk) begin
  r_ignore_begin_r <= r_ignore_begin;
  r_ignore_end_r <= r_ignore_end;
end
assign trans_in[0]  = r_ignore_end_r;
assign trans_in[1]  = r_ignore_begin_r;
assign trans_in[2]  = r_rlast;
assign trans_in[3+:C_ID_WIDTH]  = r_arid;
always @(posedge clk) begin
  if (reset) begin
     rd_last_r <= 1'b0;
  end else if (rhandshake) begin
     rd_last_r <= ~rd_last_r;
  end
end   
assign fifo_rd_last = (C_MC_BURST_LEN == 1) ? 1'b1 : rd_last_r;
mig_7series_v4_0_axi_mc_fifo #
  (
  .C_WIDTH                (P_D_WIDTH),
  .C_AWIDTH               (P_D_AWIDTH),
  .C_DEPTH                (P_D_DEPTH)
)
rd_data_fifo_0
(
  .clk     ( clk              ) ,
  .rst     ( reset            ) ,
  .wr_en   ( mc_app_rd_valid  ) ,
  .rd_en   ( rd_en            ) ,
  .din     ( rd_data_fifo_in  ) ,
  .dout    ( rd_data_fifo_out ) ,
  .a_full  ( rd_a_full        ) ,
  .full    ( rd_full          ) ,
  .a_empty (                  ) ,
  .empty   ( rd_empty         ) 
);
assign rd_data_fifo_in = {mc_app_ecc_multiple_err, mc_app_rd_data};
mig_7series_v4_0_axi_mc_fifo #
  (
  .C_WIDTH                  (P_WIDTH),
  .C_AWIDTH                 (P_AWIDTH),
  .C_DEPTH                  (P_DEPTH)
)
transaction_fifo_0
(
  .clk     ( clk         ) ,
  .rst     ( reset       ) ,
  .wr_en   ( r_push      ) ,
  .rd_en   ( tr_rden     ) ,
  .din     ( trans_in    ) ,
  .dout    ( trans_out   ) ,
  .a_full  ( trans_a_full) ,
  .full    ( trans_full  ) ,
  .a_empty (             ) ,
  .empty   ( tr_empty    ) 
);
assign rid_i = trans_buf_out_r[3+:C_ID_WIDTH];
assign assert_rlast = trans_buf_out_r[2];
assign ignore_begin = trans_buf_out_r[1];
assign ignore_end   = trans_buf_out_r[0];
assign done = fifo_rd_last & rhandshake;
assign fifo_full = (trans_a_full | trans_full) | (rd_a_full | rd_full);
assign r_data_rdy = ~fifo_full ; 
always @(posedge clk) begin
  if(load_stage1)
    if(load_stage1_from_stage2)
      trans_buf_out_r <= trans_buf_out_r1;
    else
      trans_buf_out_r <= trans_out;        
end
always @(posedge clk) begin
  if(load_stage2)
    trans_buf_out_r1 <= trans_out;
end
assign load_stage2 = ~tr_empty & state[1];
always @ (*) begin
  if( ((state == ZERO) && (~tr_empty)) ||
    ((state == ONE) && (~tr_empty) && (done)) ||
    ((state == TWO) && (done)))
    load_stage1 = 1'b1;
  else
    load_stage1 = 1'b0;
end 
assign load_stage1_from_stage2 = (state == TWO);
always @(posedge clk) 
begin
if(reset) 
  state <= ZERO;
else
  case (state)
    ZERO: if (~tr_empty) state <= ONE; 
    ONE: begin
      if (done & tr_empty) state <= ZERO; 
     else if (~done & (~tr_empty)) state <= TWO;  
    end
    TWO: if (done) state <= ONE; 
  endcase
end 
assign tr_rden = ((state == ZERO) || (state == ONE)) && (~tr_empty);
endmodule
`default_nettype wire
