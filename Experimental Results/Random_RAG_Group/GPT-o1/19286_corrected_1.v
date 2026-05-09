`timescale 1ns / 1ps
module multiSRC_onboard(
	input SYSCLK_N,
	input SYSCLK_P,
	input GPIO_SW_RIGHT,
	input GPIO_SW_CENTER,
	output GPIO_LED_CENTER,
	output GPIO_LED_LEFT,
	output GPIO_LED_RIGHT
);
wire test_start;
wire test_done;
wire test_pass;
wire clk;
wire rst;
reg [26:0] cnt;
always @(posedge clk or posedge rst) begin
	if(rst) begin
		cnt <= 0;
	end else begin
		cnt <= cnt + 1;
	end
end 
wire ap_start;
wire ap_ready;
wire ap_idle;
wire ap_done;
wire dut_rst;
wire vld_x;
wire vld_y;
wire [15:0] x;
wire [2:0]  rat;
wire [47:0] y;
wire locked;
assign rst = GPIO_SW_CENTER;
assign test_start = GPIO_SW_RIGHT;
assign GPIO_LED_CENTER = test_pass;
assign GPIO_LED_RIGHT = cnt[26];
assign GPIO_LED_LEFT = locked;
clk_wiz_0 CLKPLL
(
  .clk_in1_p(SYSCLK_P),
  .clk_in1_n(SYSCLK_N),
  .clk_out1(clk),
  .reset(rst),
  .locked(locked)
);
test_bench_onboard TB
(
	.clk(clk),
	.rst(rst),
	.test_start(test_start),
	.test_done(test_done),
	.test_pass(test_pass),
	.ap_ready(ap_ready),
	.ap_idle(ap_idle),
	.ap_done(ap_done),
	.dut_vld_y(vld_y),
	.dut_y(y),
	.dut_rst(dut_rst),
	.dut_start(ap_start),
	.dut_vld_x(vld_x),
	.dut_x(x),
	.dut_rat(rat)
);
multiSRC DUT(
    .ap_clk(clk),
    .ap_rst(dut_rst),
    .ap_start(ap_start),
    .ap_done(ap_done),
    .ap_idle(ap_idle),
    .ap_ready(ap_ready),
    .vld_i(vld_x),
    .x_i_V(x),
    .rat_i_V(rat),
    .vld_o(vld_y),
    .y_o_V(y)
);
endmodule

module clk_wiz_0(
  input clk_in1_p,
  input clk_in1_n,
  output clk_out1,
  input reset,
  output locked
);
endmodule

module test_bench_onboard(
  input clk,
  input rst,
  input test_start,
  output test_done,
  output test_pass,
  input ap_ready,
  input ap_idle,
  input ap_done,
  input dut_vld_y,
  input [47:0] dut_y,
  output dut_rst,
  output dut_start,
  output dut_vld_x,
  output [15:0] dut_x,
  output [2:0] dut_rat
);
endmodule

module multiSRC(
    input ap_clk,
    input ap_rst,
    input ap_start,
    output ap_done,
    output ap_idle,
    output ap_ready,
    input vld_i,
    input [15:0] x_i_V,
    input [2:0] rat_i_V,
    output vld_o,
    output [47:0] y_o_V
);
endmodule