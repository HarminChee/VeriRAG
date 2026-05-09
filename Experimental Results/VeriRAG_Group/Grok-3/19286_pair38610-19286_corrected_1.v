module multiSRC_onboard(
	input SYSCLK_N,
	input SYSCLK_P,
	input GPIO_SW_RIGHT,
	input GPIO_SW_CENTER,
	input test_i,
	input scan_clk,
	output GPIO_LED_CENTER,
	output GPIO_LED_LEFT,
	output GPIO_LED_RIGHT
);
wire test_start;
wire test_done;
wire test_pass;
wire clk, dft_clk;
wire rst, dft_rst;
reg [26:0] cnt;
always @(posedge dft_clk or posedge dft_rst) begin
	if(dft_rst) begin
		cnt <= 0;
	end else begin
		cnt <= cnt + 1;
	end
end 
wire ap_start;
wire ap_ready;
wire ap_idle;
wire ap_done;
wire dut_rst, dft_dut_rst;
wire vld_x;
wire vld_y;
wire [15:0] x;
wire [2:0]  rat;
wire [47:0] y;
wire locked;
assign rst = GPIO_SW_CENTER;
assign dft_rst = test_i ? 1'b0 : rst;
assign test_start = GPIO_SW_RIGHT;
assign dft_clk = test_i ? scan_clk : clk;
assign dft_dut_rst = test_i ? 1'b0 : dut_rst;
assign GPIO_LED_CENTER = test_pass;
assign GPIO_LED_RIGHT = cnt[26];
assign GPIO_LED_LEFT = locked;
clk_wiz_0 CLKPLL
 (
  .clk_in1_p(SYSCLK_P),
  .clk_in1_n(SYSCLK_N),
  .clk_out1(clk),
  .reset(dft_rst),
  .locked(locked)
 );
test_bench_onboard TB
(
	.clk(dft_clk),
	.rst(dft_rst),
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
        .ap_clk(dft_clk),
        .ap_rst(dft_dut_rst),
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