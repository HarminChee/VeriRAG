module multiSRC_onboard(
	input				test_i,
	input				test_clk_i,
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
wire clk_dft;
wire rst;
wire dut_rst_dft;
reg [26:0] cnt;
// DFT clock mux
assign clk_dft = test_i ? test_clk_i : clk;
// DFT reset mux for DUT
assign dut_rst_dft = test_i ? rst : dut_rst; // Use primary input 'rst' during test mode
always @(posedge clk_dft, posedge rst) begin // Use DFT clock, keep primary reset
	if(rst) begin
		cnt <= 0;
	end else begin
		cnt <= cnt+1;
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
assign rst=GPIO_SW_CENTER; // Primary input derived reset
assign test_start=GPIO_SW_RIGHT;
assign GPIO_LED_CENTER=test_pass;
assign GPIO_LED_RIGHT=cnt[26];
assign GPIO_LED_LEFT=locked;
clk_wiz_0 CLKPLL
 (
  .clk_in1_p(SYSCLK_P),
  .clk_in1_n(SYSCLK_N),
  .clk_out1(clk),
  .reset(rst), // Reset driven by primary input is OK for PLL
  .locked(locked)
 );
test_bench_onboard TB
(
	.clk(clk_dft), // Use DFT clock
	.rst(rst),     // Use primary reset
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
        .ap_clk(clk_dft),      // Use DFT clock
        .ap_rst(dut_rst_dft),  // Use DFT reset
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