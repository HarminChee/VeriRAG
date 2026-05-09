module multiSRC_onboard(
	input  SYSCLK_N,
	input  SYSCLK_P,
	input  GPIO_SW_RIGHT,
	input  GPIO_SW_CENTER,
	input  test_i,
	input  test_clk,
	input  test_rst,
	output GPIO_LED_CENTER,
	output GPIO_LED_LEFT,
	output GPIO_LED_RIGHT
);
wire test_start;
wire test_done;
wire test_pass;
wire clk_in;
wire locked;
wire rst_in;
wire dft_clk_in;
wire dft_rst_in;
reg [26:0] cnt;

assign rst_in      = GPIO_SW_CENTER;
assign test_start  = GPIO_SW_RIGHT;
assign GPIO_LED_CENTER = test_pass;
assign GPIO_LED_RIGHT  = cnt[26];
assign GPIO_LED_LEFT   = locked;

clk_wiz_0 CLKPLL (
  .clk_in1_p (SYSCLK_P),
  .clk_in1_n (SYSCLK_N),
  .clk_out1  (clk_in),
  .reset     (rst_in),
  .locked    (locked)
);

assign dft_clk_in = test_i ? test_clk : clk_in;
assign dft_rst_in = test_i ? test_rst : rst_in;

always @(posedge dft_clk_in or posedge dft_rst_in) begin
	if (rst_in)
		cnt <= 0;
	else
		cnt <= cnt + 1;
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

test_bench_onboard TB (
	.clk         (dft_clk_in),
	.rst         (dft_rst_in),
	.test_start  (test_start),
	.test_done   (test_done),
	.test_pass   (test_pass),
	.ap_ready    (ap_ready),
	.ap_idle     (ap_idle),
	.ap_done     (ap_done),
	.dut_vld_y   (vld_y),
	.dut_y       (y),
	.dut_rst     (dut_rst),
	.dut_start   (ap_start),
	.dut_vld_x   (vld_x),
	.dut_x       (x),
	.dut_rat     (rat)
);

multiSRC DUT (
	.ap_clk   (dft_clk_in),
	.ap_rst   (dut_rst),
	.ap_start (ap_start),
	.ap_done  (ap_done),
	.ap_idle  (ap_idle),
	.ap_ready (ap_ready),
	.vld_i    (vld_x),
	.x_i_V    (x),
	.rat_i_V  (rat),
	.vld_o    (vld_y),
	.y_o_V    (y)
);

endmodule