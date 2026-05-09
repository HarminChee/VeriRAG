module multiSRC_onboard(
	input wire test_i, // Added test mode input
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
wire dft_clk; // Added muxed clock
wire dut_rst;
wire dft_dut_rst; // Added muxed reset for DUT

// Mux clock for testability
assign dft_clk = test_i ? SYSCLK_P : clk; // Assuming SYSCLK_P can be used as test clock

// Mux DUT reset for testability
assign dft_dut_rst = test_i ? rst : dut_rst; // Use primary reset 'rst' in test mode

always @(posedge dft_clk, posedge rst) begin // Use muxed clock, PI reset is OK
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
// wire dut_rst; // Declared above
wire vld_x;
wire vld_y;
wire [15:0] x;
wire [2:0]  rat;
wire [47:0] y;
wire locked;
assign rst=GPIO_SW_CENTER; // rst is a Primary Input - OK for ACNCPI
assign test_start=GPIO_SW_RIGHT;
assign GPIO_LED_CENTER=test_pass;
assign GPIO_LED_RIGHT=cnt[26];
assign GPIO_LED_LEFT=locked;
clk_wiz_0 CLKPLL
 (
  .clk_in1_p(SYSCLK_P),
  .clk_in1_n(SYSCLK_N),
  .clk_out1(clk), // Original clock output
  .reset(rst),   // Reset is PI - OK
  .locked(locked)
 );
test_bench_onboard TB
(
	.clk(dft_clk), // Use muxed clock
	.rst(rst),     // Use PI reset
	.test_start(test_start),
	.test_done(test_done),
	.test_pass(test_pass),
	.ap_ready(ap_ready),
	.ap_idle(ap_idle),
	.ap_done(ap_done),
	.dut_vld_y(vld_y),
	.dut_y(y),
	.dut_rst(dut_rst), // Original reset output from TB
	.dut_start(ap_start),
	.dut_vld_x(vld_x),
	.dut_x(x),
	.dut_rat(rat)
);
multiSRC DUT(
        .ap_clk(dft_clk),     // Use muxed clock
        .ap_rst(dft_dut_rst), // Use muxed reset
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