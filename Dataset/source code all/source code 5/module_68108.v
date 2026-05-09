`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module mig_7series_v4_0_axi_ctrl_write #
(
  parameter integer C_ADDR_WIDTH        = 32,
  parameter integer C_DATA_WIDTH        = 32,
  parameter integer C_NUM_REG           = 5,
  parameter integer C_NUM_REG_WIDTH     = 3,
  parameter         C_REG_ADDR_ARRAY = 160'h0000_f00C_0000_f008_0000_f004_0000_f000_FFFF_FFFF,
  parameter         C_REG_WRAC_ARRAY = 5'b11111
)
(
  input  wire                               clk              , 
  input  wire                               reset           , 
  input  wire                               awvalid     , 
  input  wire                               awready     , 
  input  wire [C_ADDR_WIDTH-1:0]            awaddr      , 
  input  wire                               wvalid      , 
  output wire                               wready      , 
  input  wire [C_DATA_WIDTH-1:0]            wdata       , 
  output wire                               bvalid      , 
  input  wire                               bready      , 
  output wire [1:0]                         bresp       , 
  output wire [C_NUM_REG_WIDTH-1:0]         reg_data_sel     ,
  output wire                               reg_data_write   ,
  output wire [C_DATA_WIDTH-1:0]            reg_data 
);
wire                        awhandshake;
wire                        whandshake;
reg                         whandshake_d1;
wire                        bhandshake;
wire [C_NUM_REG_WIDTH-1:0]  reg_decode_num;
reg                         awready_i;
reg                         wready_i;
reg                         bvalid_i;
reg  [C_DATA_WIDTH-1:0]     data;
assign awhandshake = awvalid & awready;
assign whandshake = wvalid & wready;
assign bhandshake = bvalid & bready;
mig_7series_v4_0_axi_ctrl_addr_decode #
(
  .C_ADDR_WIDTH     ( C_ADDR_WIDTH     ) ,
  .C_NUM_REG        ( C_NUM_REG        ) ,
  .C_NUM_REG_WIDTH  ( C_NUM_REG_WIDTH  ) ,
  .C_REG_ADDR_ARRAY ( C_REG_ADDR_ARRAY ) ,
  .C_REG_RDWR_ARRAY ( C_REG_WRAC_ARRAY ) 
)
axi_ctrl_addr_decode_0
(
  .axaddr         ( awaddr         ) ,
  .reg_decode_num ( reg_decode_num ) 
);
assign wready = wready_i;
always @(posedge clk) begin
  if (reset) begin 
    wready_i <= 1'b0;
  end
  else begin
    wready_i <= (awhandshake | wready_i) & ~whandshake;
  end
end
always @(posedge clk) begin
  data <= wdata;
end
assign bvalid = bvalid_i;
assign bresp = 2'b0; 
always @(posedge clk) begin
  if (reset) begin 
    bvalid_i <= 1'b0;
  end
  else begin
    bvalid_i <= (whandshake | bvalid_i) & ~bhandshake;
  end
end
assign reg_data       = data;
assign reg_data_write = whandshake_d1;
assign reg_data_sel   = reg_decode_num;
always @(posedge clk) begin
  whandshake_d1 <= whandshake;
end
endmodule
`default_nettype wire
