`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module mig_7series_v4_0_axi_mc_cmd_arbiter #
(
  parameter integer C_MC_ADDR_WIDTH =   30,
  parameter integer C_MC_BURST_LEN = 1,
  parameter integer C_AXI_WR_STARVE_LIMIT = 256,
  parameter integer C_AXI_STARVE_CNT_WIDTH = 8,
  parameter         C_RD_WR_ARB_ALGORITHM = "RD_PRI_REG"
)
(
  input  wire                                 clk              , 
  input  wire                                 reset            , 
  input  wire                                 awvalid     ,
  input  wire [3:0]                           awqos       ,
  input  wire                                 wr_cmd_en        , 
  input  wire                                 wr_cmd_en_last   ,
  input  wire [2:0]                           wr_cmd_instr     , 
  input  wire [C_MC_ADDR_WIDTH-1:0]           wr_cmd_byte_addr , 
  output wire                                 wr_cmd_full      , 
  input  wire                                 arvalid     ,
  input  wire [3:0]                           arqos       ,
  input  wire                                 rd_cmd_en        , 
  input  wire                                 rd_cmd_en_last   ,
  input  wire [2:0]                           rd_cmd_instr     , 
  input  wire [C_MC_ADDR_WIDTH-1:0]           rd_cmd_byte_addr ,  
  output wire                                 rd_cmd_full      , 
  output wire                                 mc_app_en        , 
  output wire [2:0]                           mc_app_cmd       , 
  output wire                                 mc_app_size      , 
  output wire [C_MC_ADDR_WIDTH-1:0]           mc_app_addr      ,
  output wire                                 mc_app_hi_pri    , 
  input  wire                                 mc_app_rdy
);
wire rnw;
assign mc_app_en     = rnw ? rd_cmd_en        : wr_cmd_en;
assign mc_app_cmd    = rnw ? rd_cmd_instr     : wr_cmd_instr;
assign mc_app_addr   = rnw ? rd_cmd_byte_addr : wr_cmd_byte_addr;
assign mc_app_size   = 1'b0; 
assign wr_cmd_full   = rnw ? 1'b1 : ~mc_app_rdy;
assign rd_cmd_full   = ~rnw ? 1'b1 : ~mc_app_rdy;
assign mc_app_hi_pri = 1'b0;
generate
  if (C_RD_WR_ARB_ALGORITHM == "TDM") begin : TDM
    reg rnw_i;
    always @(posedge clk) begin
      if (reset) begin
        rnw_i <= 1'b0;
      end else begin
        rnw_i <= ~rnw_i;
      end
    end
    assign rnw = rnw_i;
  end
  else if (C_RD_WR_ARB_ALGORITHM == "ROUND_ROBIN") begin : ROUND_ROBIN
    reg rnw_i;
    always @(posedge clk) begin
      if (reset) begin
        rnw_i <= 1'b0;
      end else begin
        rnw_i <= ~rnw;
      end
    end
    assign rnw = (rnw_i & rd_cmd_en) | (~rnw_i & rd_cmd_en & ~wr_cmd_en);
  end
  else if (C_RD_WR_ARB_ALGORITHM == "RD_PRI_REG") begin : RD_PRI_REG
    reg rnw_i;
    reg rd_cmd_hold;
    reg wr_cmd_hold;
    reg [4:0] rd_wait_limit;
    reg [4:0] wr_wait_limit;
    reg [9:0] rd_starve_cnt;
    reg [9:0] wr_starve_cnt;
    always @(posedge clk) begin
      if (~rnw | ~rd_cmd_hold) begin
        rd_wait_limit <= 5'b0;
        rd_starve_cnt <= (C_MC_BURST_LEN * 2);
      end else if (mc_app_rdy) begin
        if (~arvalid | rd_cmd_en)
          rd_wait_limit <= 5'b0;
        else
          rd_wait_limit <= rd_wait_limit + C_MC_BURST_LEN;
        if (rd_cmd_en & ~rd_starve_cnt[8])
          rd_starve_cnt <= rd_starve_cnt + C_MC_BURST_LEN;
      end
    end
    always @(posedge clk) begin
      if (rnw | ~wr_cmd_hold) begin
        wr_wait_limit <= 5'b0;
        wr_starve_cnt <= (C_MC_BURST_LEN * 2);
      end else if (mc_app_rdy) begin
        if (~awvalid | wr_cmd_en)
          wr_wait_limit <= 5'b0;
        else
          wr_wait_limit <= wr_wait_limit + C_MC_BURST_LEN;
        if (wr_cmd_en & ~wr_starve_cnt[8])
          wr_starve_cnt <= wr_starve_cnt + C_MC_BURST_LEN;
      end
    end
    always @(posedge clk) begin
      if (reset) begin
        rd_cmd_hold <= 1'b0;
        wr_cmd_hold <= 1'b0;
      end else begin
        rd_cmd_hold <= (rnw | rd_cmd_hold) & ~(rd_cmd_en_last & ((awvalid & (|awqos)) | rd_starve_cnt[8])) & ~rd_wait_limit[4];
        wr_cmd_hold <= (~rnw | wr_cmd_hold) & ~(wr_cmd_en_last & ((arvalid & (|arqos)) | wr_starve_cnt[8])) & ~wr_wait_limit[4];
      end
    end
    always @(posedge clk) begin
      if (reset)
        rnw_i <= 1'b1;
      else
        rnw_i <= rnw;
    end
    assign rnw = (rnw_i & ~(rd_cmd_hold & arvalid) & awvalid) ? 1'b0 :  
                 (~rnw_i & ~(wr_cmd_hold & awvalid) & arvalid) ? 1'b1 : 
                 rnw_i;
  end 
  else if (C_RD_WR_ARB_ALGORITHM == "RD_PRI_REG_STARVE_LIMIT") begin : RD_PRI_REG_STARVE
    reg rnw_i;
    reg rd_cmd_en_d1;
    reg wr_cmd_en_d1;
    reg [C_AXI_STARVE_CNT_WIDTH-1:0] wr_starve_cnt;
    reg wr_enable;
    reg [8:0] rd_starve_cnt;
   always @(posedge clk) begin
     if(reset | ( ~(wr_cmd_en | wr_cmd_en_d1))
        | rd_starve_cnt[8])begin
       wr_starve_cnt <= 'b0;
       wr_enable <=  'b0;
     end else if(wr_cmd_en & (mc_app_rdy)) begin 
       if(wr_starve_cnt < (C_AXI_WR_STARVE_LIMIT-1))
         wr_starve_cnt <= wr_starve_cnt + rnw_i;
       else
         wr_enable <= 1'b1;
     end 
    end 
   always @(posedge clk) begin
     if(reset | rnw_i)begin
       rd_starve_cnt <= 'b0;
     end else if(rd_cmd_en & (mc_app_rdy)) begin 
       rd_starve_cnt <= rd_starve_cnt + 1;
     end 
    end 
    always @(posedge clk) begin
      if (reset) begin
        rd_cmd_en_d1 <= 1'b0;
        wr_cmd_en_d1 <= 1'b0;
      end else begin
      if (mc_app_rdy) begin
        rd_cmd_en_d1 <= rd_cmd_en & rnw;
        wr_cmd_en_d1 <= wr_cmd_en & ~rnw;
      end
     end
    end
    always @(posedge clk) begin
      if (reset) begin
        rnw_i <= 1'b1;
      end else begin
        rnw_i <= ~(((wr_cmd_en | wr_cmd_en_d1) & (~rd_cmd_en) & (~rd_cmd_en_d1)) | wr_enable);
      end
    end
    assign rnw = rnw_i;
  end
  else if (C_RD_WR_ARB_ALGORITHM == "RD_PRI") begin : RD_PRI
    assign rnw = ~(wr_cmd_en & ~rd_cmd_en);
  end
  else if (C_RD_WR_ARB_ALGORITHM == "WR_PR_REG") begin : WR_PR_REG
    reg rnw_i;
    always @(posedge clk) begin
      if (reset) begin
        rnw_i <= 1'b0;
      end else begin
        rnw_i <=  (~awvalid & arvalid);
      end
    end
    assign rnw = rnw_i;
  end
  else begin : WR_PR 
    assign rnw =  (~awvalid & arvalid);
  end
endgenerate
endmodule
`default_nettype wire
