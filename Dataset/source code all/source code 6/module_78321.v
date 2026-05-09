`timescale 1ns / 100ps
`default_nettype none
`default_nettype wire
`timescale 1ns / 100ps
`default_nettype none
module mig_7series_v4_0_axi_mc_simple_fifo #
(
  parameter C_WIDTH  = 8,
  parameter C_AWIDTH = 4,
  parameter C_DEPTH  = 16
)
(
  input  wire               clk,       
  input  wire               rst,       
  input  wire               wr_en,     
  input  wire               rd_en,     
  input  wire [C_WIDTH-1:0] din,       
  output wire [C_WIDTH-1:0] dout,      
  output wire               a_full,
  output wire               full,      
  output wire               a_empty,
  output wire               empty      
);
localparam [C_AWIDTH-1:0] C_EMPTY = ~(0);
localparam [C_AWIDTH-1:0] C_EMPTY_PRE =  (0);
localparam [C_AWIDTH-1:0] C_FULL  = C_EMPTY-1;
localparam [C_AWIDTH-1:0] C_FULL_PRE  = (C_DEPTH < 8) ? C_FULL-1 : C_FULL-(C_DEPTH/8);
reg [C_WIDTH-1:0]  memory [C_DEPTH-1:0];
reg [C_AWIDTH-1:0] cnt_read;
always @(posedge clk) begin : BLKSRL
integer i;
  if (wr_en) begin
    for (i = 0; i < C_DEPTH-1; i = i + 1) begin
      memory[i+1] <= memory[i];
    end
    memory[0] <= din;
  end
end
always @(posedge clk) begin
  if (rst) cnt_read <= C_EMPTY;
  else if ( wr_en & !rd_en) cnt_read <= cnt_read + 1'b1;
  else if (!wr_en &  rd_en) cnt_read <= cnt_read - 1'b1;
end
assign full  = (cnt_read == C_FULL);
assign empty = (cnt_read == C_EMPTY);
assign a_full  = ((cnt_read >= C_FULL_PRE) && (cnt_read != C_EMPTY));
assign a_empty = (cnt_read == C_EMPTY_PRE);
assign dout  = (C_DEPTH == 1) ? memory[0] : memory[cnt_read];
endmodule 
`default_nettype wire
