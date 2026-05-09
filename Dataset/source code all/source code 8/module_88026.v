`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axi_protocol_converter_v2_1_9_b2s_wr_cmd_fsm (
  input  wire                                 clk           ,
  input  wire                                 reset         ,
  output wire                                 s_awready       ,
  input  wire                                 s_awvalid       ,
  output wire                                 m_awvalid        ,
  input  wire                                 m_awready      ,
  output wire                                 next          ,
  input  wire                                 next_pending  ,
  output wire                                 b_push        ,
  input  wire                                 b_full        ,
  output wire                                 a_push
);
localparam SM_IDLE                = 2'b00;
localparam SM_CMD_EN              = 2'b01;
localparam SM_CMD_ACCEPTED        = 2'b10;
localparam SM_DONE_WAIT           = 2'b11;
reg [1:0]       state;
reg [1:0]       next_state;
always @(posedge clk) begin
  if (reset) begin
    state <= SM_IDLE;
  end else begin
    state <= next_state;
  end
end
always @( * )
begin
  next_state = state;
  case (state)
    SM_IDLE:
      if (s_awvalid) begin
        next_state = SM_CMD_EN;
      end else
        next_state = state;
    SM_CMD_EN:
      if (m_awready & next_pending)
        next_state = SM_CMD_ACCEPTED;
      else if (m_awready & ~next_pending & b_full)
        next_state = SM_DONE_WAIT;
      else if (m_awready & ~next_pending & ~b_full)
        next_state = SM_IDLE;
      else
        next_state = state;
    SM_CMD_ACCEPTED:
      next_state = SM_CMD_EN;
    SM_DONE_WAIT:
      if (!b_full)
        next_state = SM_IDLE;
      else
        next_state = state;
      default:
        next_state = SM_IDLE;
  endcase
end
assign m_awvalid  = (state == SM_CMD_EN);
assign next    = ((state == SM_CMD_ACCEPTED)
                 | (((state == SM_CMD_EN) | (state == SM_DONE_WAIT)) & (next_state == SM_IDLE))) ;
assign a_push  = (state == SM_IDLE);
assign s_awready = ((state == SM_CMD_EN) | (state == SM_DONE_WAIT)) & (next_state == SM_IDLE);
assign b_push  = ((state == SM_CMD_EN) | (state == SM_DONE_WAIT)) & (next_state == SM_IDLE);
endmodule
`default_nettype wire
