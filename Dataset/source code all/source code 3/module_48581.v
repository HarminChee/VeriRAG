`timescale 1ps/1ps
`default_nettype none
`default_nettype wire
`timescale 1ps/1ps
`default_nettype none
module axis_infrastructure_v1_1_0_cdc_handshake #
(
  parameter integer C_WIDTH                   = 32,
  parameter integer C_NUM_SYNCHRONIZER_STAGES = 2
)
(
  input  wire                               from_clk,
  input  wire                               req, 
  output wire                               ack,
  input  wire [C_WIDTH-1:0]                 data_in,
  input  wire                               to_clk,
  output wire [C_WIDTH-1:0]                 data_out
);
wire ack_synch;
wire req_synch;
wire data_en;
reg req_synch_d1;
reg [C_WIDTH-1:0] data_r;
assign ack = ack_synch;
axis_infrastructure_v1_1_0_clock_synchronizer #(
  .C_NUM_STAGES ( C_NUM_SYNCHRONIZER_STAGES )
)
inst_ack_synch (
  .clk (from_clk),
  .synch_in (req_synch),
  .synch_out (ack_synch)
);
axis_infrastructure_v1_1_0_clock_synchronizer #(
  .C_NUM_STAGES ( C_NUM_SYNCHRONIZER_STAGES )
)
inst_req_synch (
  .clk (to_clk),
  .synch_in (req),
  .synch_out (req_synch)
);
assign data_out = data_r;
always @(posedge to_clk) begin 
  data_r = data_en ? data_in : data_r;
end
assign data_en = req_synch & ~req_synch_d1;
always @(posedge to_clk) begin 
  req_synch_d1 <= req_synch;
end
endmodule 
`default_nettype wire
