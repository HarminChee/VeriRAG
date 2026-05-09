module indicators (
  input  wire           clk,          
  input  wire           rst,          
  input wire  [  8-1:0] track,        
  input wire            f_wr,         
  input wire            f_rd,         
  input wire            h_wr,         
  input wire            h_rd,         
  input wire  [  4-1:0] status,       
  input wire  [  4-1:0] ctrl_status,  
  input wire  [  4-1:0] sys_status,   
  input wire            fifo_full,
  output wire [  7-1:0] hex_0,        
  output wire [  7-1:0] hex_1,        
  output wire [  7-1:0] hex_2,        
  output wire [  7-1:0] hex_3,        
  output wire [  8-1:0] led_g,        
  output wire [ 10-1:0] led_r         
);
sseg_decode #(
  .REG  (1),
  .INV  (1)
) sseg_HEX0 (
  .clk  (clk),
  .rst  (rst),
  .num  (track[3:0]),
  .sseg (hex_0)
);
sseg_decode #(
  .REG  (1),
  .INV  (1)
) sseg_HEX1 (
  .clk  (clk),
  .rst  (rst),
  .num  (track[7:4]),
  .sseg (hex_1)
);
assign hex_2        = 7'h7f;  
assign hex_3        = ~7'h71; 
reg [1:0] r0, r1, g0, g1;
always @ (posedge clk or posedge rst) begin
  if (rst) begin
    r0 <= #1 2'b00;
    r1 <= #1 2'b00;
    g0 <= #1 2'b00;
    g1 <= #1 2'b00;
  end else begin
    r0 <= #1 {r0[0], f_wr};
    r1 <= #1 {r1[0], h_wr};
    g0 <= #1 {g0[0], f_rd};
    g1 <= #1 {g1[0], h_rd};
  end
end
wire r0_out, g0_out, r1_out, g1_out;
assign r0_out = |r0;
assign r1_out = |r1;
assign g0_out = |g0;
assign g1_out = |g1;
reg  [  4-1:0] ctrl_leds;
always @ (posedge clk, posedge rst) begin
  if (rst)
    ctrl_leds <= #1 4'b0;
  else
    ctrl_leds <= #1 ctrl_status;
end
assign led_g = {ctrl_leds, 1'b0,fifo_full,      g1_out, g0_out};
assign led_r = {status,    sys_status, r1_out, r0_out};
endmodule
