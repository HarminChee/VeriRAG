`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_9_b2s_cmd_translator #
(
  parameter integer C_AXI_ADDR_WIDTH            = 32
)
(
  input  wire                                 clk           , 
  input  wire                                 reset         , 
  input  wire [C_AXI_ADDR_WIDTH-1:0]          s_axaddr        , 
  input  wire [7:0]                           s_axlen         , 
  input  wire [2:0]                           s_axsize        , 
  input  wire [1:0]                           s_axburst       , 
  input  wire                                 s_axhandshake   , 
  output wire [C_AXI_ADDR_WIDTH-1:0]          m_axaddr , 
  output wire                                 incr_burst    , 
  input  wire                                 next          , 
  output wire                                 next_pending
);
localparam P_AXBURST_FIXED = 2'b00;
localparam P_AXBURST_INCR  = 2'b01;
localparam P_AXBURST_WRAP  = 2'b10;
wire [C_AXI_ADDR_WIDTH-1:0]     incr_cmd_byte_addr;
wire                            incr_next_pending;
wire [C_AXI_ADDR_WIDTH-1:0]     wrap_cmd_byte_addr;
wire                            wrap_next_pending;
reg                             sel_first;
reg                             s_axburst_eq1;
reg                             s_axburst_eq0;
reg                             sel_first_i;   
assign m_axaddr         = (s_axburst == P_AXBURST_FIXED) ?  s_axaddr : 
                          (s_axburst == P_AXBURST_INCR)  ?  incr_cmd_byte_addr : 
                                                            wrap_cmd_byte_addr;
assign incr_burst       = (s_axburst[1]) ? 1'b0 : 1'b1;
always @(posedge clk) begin
  if (reset | s_axhandshake) begin
    sel_first <= 1'b1;
  end else if (next) begin
    sel_first <= 1'b0;
  end
end
always @( * ) begin
  if (reset | s_axhandshake) begin
    sel_first_i = 1'b1;
  end else if (next) begin
    sel_first_i = 1'b0;
  end else begin
    sel_first_i = sel_first;
  end
end
assign next_pending = s_axburst[1] ? s_axburst_eq1 : s_axburst_eq0;
always @(posedge clk) begin
  if (sel_first_i || s_axburst[1]) begin
    s_axburst_eq1 <= wrap_next_pending;
  end else begin
    s_axburst_eq1 <= incr_next_pending;
  end
  if (sel_first_i || !s_axburst[1]) begin
    s_axburst_eq0 <= incr_next_pending;
  end else begin
    s_axburst_eq0 <= wrap_next_pending;
  end
end
axi_protocol_converter_v2_1_9_b2s_incr_cmd #(
  .C_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH)
)
incr_cmd_0
(
  .clk           ( clk                ) ,
  .reset         ( reset              ) ,
  .axaddr        ( s_axaddr           ) ,
  .axlen         ( s_axlen            ) ,
  .axsize        ( s_axsize           ) ,
  .axhandshake   ( s_axhandshake      ) ,
  .cmd_byte_addr ( incr_cmd_byte_addr ) ,
  .next          ( next               ) ,
  .next_pending  ( incr_next_pending  ) 
);
axi_protocol_converter_v2_1_9_b2s_wrap_cmd #(
  .C_AXI_ADDR_WIDTH (C_AXI_ADDR_WIDTH)
)
wrap_cmd_0
(
  .clk           ( clk                ) ,
  .reset         ( reset              ) ,
  .axaddr        ( s_axaddr           ) ,
  .axlen         ( s_axlen            ) ,
  .axsize        ( s_axsize           ) ,
  .axhandshake   ( s_axhandshake      ) ,
  .cmd_byte_addr ( wrap_cmd_byte_addr ) ,
  .next          ( next               ) ,
  .next_pending  ( wrap_next_pending  ) 
);
endmodule
`default_nettype wire
